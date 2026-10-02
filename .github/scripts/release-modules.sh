#!/usr/bin/env bash
# Verify and publish module/collection tags with .github/releases/<tag>.md notes.
# --check performs the same preflight without creating releases. Tags must already
# exist locally and on GitHub.
#
# Every module release carries <tag>.zip: exactly the <module>/ directory of the tag,
# built with git archive. GitHub's automatic "Source code" archives always contain
# the whole repository, so they are no way to download one module. Collection
# releases keep those full archives and get no extra file. An existing release keeps
# its tag, title and notes; the only later change is attaching a missing module
# archive once. An archive that is already attached is never replaced.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT}"
CHECK=0
if [[ "${1:-}" == "--check" ]]; then
    CHECK=1
    shift
fi
[[ $# -le 1 ]] || { echo 'ERROR: usage: release-modules.sh [--check] [<module>-v<version>|v<version>]' >&2; exit 1; }
REQUESTED="${1:-}"
[[ -n "${GH_REPO:-}" ]] || { echo 'ERROR: GH_REPO is required' >&2; exit 1; }

if [[ -n "${REQUESTED}" ]]; then
    [[ "${REQUESTED}" != */* ]] || { echo 'ERROR: tag must not contain a slash' >&2; exit 1; }
    NOTES=(".github/releases/${REQUESTED}.md")
else
    shopt -s nullglob
    # Collection releases are published after all pending module releases.
    NOTES=(.github/releases/*-v*.md .github/releases/v*.md)
fi
TAGS=()
MODULES=()
for notes in "${NOTES[@]}"; do
    tag="$(basename "${notes}" .md)"
    if [[ "${tag}" =~ ^([a-z0-9]+(-[a-z0-9]+)*)-v[0-9]+\.[0-9]+(\.[0-9]+)?(-[A-Za-z0-9]+([.-][A-Za-z0-9]+)*)?$ ]]; then
        module="${BASH_REMATCH[1]}"
        for required in installer.json apply-patches.sh NOTICE; do
            [[ -f "${module}/${required}" ]] || { echo "ERROR: unknown or incomplete module: ${module}" >&2; exit 1; }
        done
    elif [[ "${tag}" =~ ^v[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
        module=""
    else
        echo "ERROR: invalid release tag: ${tag}" >&2
        exit 1
    fi
    [[ -f "${notes}" ]] || { echo "ERROR: release notes are missing: ${notes}" >&2; exit 1; }
    TAGS+=("${tag}")
    MODULES+=("${module}")
done

# An API/authentication failure aborts; it never means "not yet published".
published="$(gh api "repos/${GH_REPO}/releases" --paginate --jq '.[].tag_name')"
PENDING=()
ATTACH=()
for i in "${!TAGS[@]}"; do
    if ! grep -Fxq -- "${TAGS[i]}" <<< "${published}"; then
        PENDING+=("${i}")
    elif [[ -z "${MODULES[i]}" ]]; then
        echo "Already exists; leaving release unchanged: ${TAGS[i]}"
    else
        assets="$(gh api "repos/${GH_REPO}/releases/tags/${TAGS[i]}" --jq '.assets[].name')"
        if grep -Fxq -- "${TAGS[i]}.zip" <<< "${assets}"; then
            echo "Already exists with its module archive; leaving release unchanged: ${TAGS[i]}"
        else
            echo "Already exists without module archive; tag and notes stay unchanged: ${TAGS[i]}"
            ATTACH+=("${i}")
        fi
    fi
done
if [[ ${#PENDING[@]} -eq 0 && ${#ATTACH[@]} -eq 0 ]]; then
    echo 'No unpublished releases and no missing module archives.'
    exit 0
fi

# Module archive: the <module>/ directory exactly as in the tag, nothing else of the
# repository. Built before the first write, so a bad archive stops every publication.
ARCHIVE_DIR="$(mktemp -d)"
trap 'rm -rf "${ARCHIVE_DIR}"' EXIT
declare -A ARCHIVE=()
build_archive() { # <index>
    local tag="${TAGS[$1]}" module="${MODULES[$1]}" archive
    archive="${ARCHIVE_DIR}/${tag}.zip"
    git archive --format=zip -o "${archive}" "refs/tags/${tag}" -- "${module}"
    git ls-tree -r --name-only "refs/tags/${tag}" -- "${module}" | python3 -c '
import sys, zipfile
expected = set(sys.stdin.read().split("\n")) - {""}
names = [n for n in zipfile.ZipFile(sys.argv[1]).namelist() if not n.endswith("/")]
if not expected or set(names) != expected or len(names) != len(expected):
    sys.exit("ERROR: module archive does not match the tagged module: " + sys.argv[1])
' "${archive}"
    ARCHIVE[$1]="${archive}"
}
for i in "${ATTACH[@]}"; do
    git rev-parse --verify "refs/tags/${TAGS[i]}^{commit}" >/dev/null || {
        echo "ERROR: tag does not exist locally: ${TAGS[i]}" >&2
        exit 1
    }
    build_archive "${i}"
done

# Validate ALL candidates before the first externally visible write.
python3 .github/scripts/generate-installers.py --check
bash .github/scripts/check-modules.sh
TITLES=()
declare -A CHECKED=()
for i in "${PENDING[@]}"; do
    tag="${TAGS[i]}"
    module="${MODULES[i]}"
    git rev-parse --verify "refs/tags/${tag}^{commit}" >/dev/null || {
        echo "ERROR: tag does not exist locally: ${tag}" >&2
        exit 1
    }
    scope="${module:-.}"
    git diff --quiet "refs/tags/${tag}" HEAD -- "${scope}/" || {
        echo "ERROR: ${tag} differs from the payload being tested" >&2
        exit 1
    }
    git diff --quiet HEAD -- "${scope}/" || {
        echo "ERROR: uncommitted changes in release scope: ${scope}" >&2
        exit 1
    }
    targets=("${module}")
    if [[ -z "${module}" ]]; then
        TITLES[i]="crDroid Patches ${tag}"
        targets=()
        for config in */installer.json; do
            targets+=("${config%/installer.json}")
        done
    else
        title="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["title"])' "${module}/installer.json")"
        TITLES[i]="${title} ${tag#"${module}-"}"
        build_archive "${i}"
    fi
    for target in "${targets[@]}"; do
        [[ -n "${CHECKED[${target}]+set}" ]] && continue
        bash .github/scripts/test-apply-script.sh "${target}"
        bash .github/scripts/check-reference.sh "${target}"
        bash .github/scripts/check-reference.sh --branch 16.0 "${target}"
        CHECKED[${target}]=1
    done
done
if [[ ${CHECK} -eq 1 ]]; then
    for i in "${ATTACH[@]}"; do
        echo "Would attach ${TAGS[i]}.zip to the existing release ${TAGS[i]}"
    done
    echo "Release preflight passed (${#PENDING[@]} release(s), ${#ATTACH[@]} archive(s) to attach); nothing published."
    exit 0
fi

CREATED=()
ATTACHED=()
report_failure() { # <message>
    echo "ERROR: $1" >&2
    if [[ ${#CREATED[@]} -gt 0 ]]; then
        printf 'Already published; left unchanged: %s\n' "${CREATED[@]}" >&2
    fi
    if [[ ${#ATTACHED[@]} -gt 0 ]]; then
        printf 'Already attached; left unchanged: %s\n' "${ATTACHED[@]}" >&2
    fi
    exit 1
}
for i in "${PENDING[@]}"; do
    tag="${TAGS[i]}"
    module="${MODULES[i]}"
    latest=false
    files=()
    if [[ -z "${module}" ]]; then
        latest=true
    else
        files=("${ARCHIVE[${i}]}")
    fi
    gh release create "${tag}" "${files[@]}" --verify-tag --latest="${latest}" \
        --title "${TITLES[i]}" --notes-file "${NOTES[i]}" || report_failure "publication failed: ${tag}"
    CREATED+=("${tag}")
done
for i in "${ATTACH[@]}"; do
    # No --clobber: an asset of that name appearing in the meantime makes this fail.
    gh release upload "${TAGS[i]}" "${ARCHIVE[${i}]}" || report_failure "attaching ${TAGS[i]}.zip failed"
    ATTACHED+=("${TAGS[i]}.zip")
done
echo "Published releases: ${#PENDING[@]}; attached module archives: ${#ATTACH[@]}."
