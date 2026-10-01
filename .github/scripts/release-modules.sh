#!/usr/bin/env bash
# Verify and publish module tags with matching .github/releases/<tag>.md notes.
# --check performs the same preflight without creating releases. Existing releases
# are always left unchanged. Tags must already exist locally and on GitHub.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT}"
CHECK=0
if [[ "${1:-}" == "--check" ]]; then
    CHECK=1
    shift
fi
[[ $# -le 1 ]] || { echo 'ERROR: usage: release-modules.sh [--check] [<module>-v<version>]' >&2; exit 1; }
REQUESTED="${1:-}"
[[ -n "${GH_REPO:-}" ]] || { echo 'ERROR: GH_REPO is required' >&2; exit 1; }

if [[ -n "${REQUESTED}" ]]; then
    [[ "${REQUESTED}" != */* ]] || { echo 'ERROR: tag must not contain a slash' >&2; exit 1; }
    NOTES=(".github/releases/${REQUESTED}.md")
else
    shopt -s nullglob
    NOTES=(.github/releases/*-v*.md)
fi
TAGS=()
MODULES=()
for notes in "${NOTES[@]}"; do
    tag="$(basename "${notes}" .md)"
    if [[ ! "${tag}" =~ ^([a-z0-9]+(-[a-z0-9]+)*)-v[0-9]+\.[0-9]+(\.[0-9]+)?(-[A-Za-z0-9]+([.-][A-Za-z0-9]+)*)?$ ]]; then
        echo "ERROR: invalid module release tag: ${tag}" >&2
        exit 1
    fi
    module="${BASH_REMATCH[1]}"
    for required in installer.json apply-patches.sh NOTICE; do
        [[ -f "${module}/${required}" ]] || { echo "ERROR: unknown or incomplete module: ${module}" >&2; exit 1; }
    done
    [[ -f "${notes}" ]] || { echo "ERROR: release notes are missing: ${notes}" >&2; exit 1; }
    TAGS+=("${tag}")
    MODULES+=("${module}")
done

# An API/authentication failure aborts; it never means "not yet published".
published="$(gh api "repos/${GH_REPO}/releases" --paginate --jq '.[].tag_name')"
PENDING=()
for i in "${!TAGS[@]}"; do
    if grep -Fxq -- "${TAGS[i]}" <<< "${published}"; then
        echo "Already exists; leaving release unchanged: ${TAGS[i]}"
    else
        PENDING+=("${i}")
    fi
done
if [[ ${#PENDING[@]} -eq 0 ]]; then
    echo 'No unpublished module releases.'
    exit 0
fi

# Validate ALL candidates before the first externally visible write.
python3 .github/scripts/generate-installers.py --check
bash .github/scripts/check-modules.sh
TITLES=()
for i in "${PENDING[@]}"; do
    tag="${TAGS[i]}"
    module="${MODULES[i]}"
    git rev-parse --verify "refs/tags/${tag}^{commit}" >/dev/null || {
        echo "ERROR: tag does not exist locally: ${tag}" >&2
        exit 1
    }
    git diff --quiet "refs/tags/${tag}" HEAD -- "${module}/" || {
        echo "ERROR: ${tag} differs from the module being tested" >&2
        exit 1
    }
    git diff --quiet HEAD -- "${module}/" || {
        echo "ERROR: uncommitted changes in release module: ${module}" >&2
        exit 1
    }
    TITLES[i]="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["title"])' "${module}/installer.json")"
    bash .github/scripts/test-apply-script.sh "${module}"
    bash .github/scripts/check-reference.sh "${module}"
    bash .github/scripts/check-reference.sh --branch 16.0 "${module}"
done
if [[ ${CHECK} -eq 1 ]]; then
    echo "Release preflight passed (${#PENDING[@]} module release(s)); no releases created."
    exit 0
fi

CREATED=()
for i in "${PENDING[@]}"; do
    tag="${TAGS[i]}"
    module="${MODULES[i]}"
    if ! gh release create "${tag}" --verify-tag --latest=false \
        --title "${TITLES[i]} ${tag#"${module}-"}" --notes-file "${NOTES[i]}"; then
        echo "ERROR: publication failed: ${tag}" >&2
        if [[ ${#CREATED[@]} -gt 0 ]]; then
            printf 'Already published; left unchanged: %s\n' "${CREATED[@]}" >&2
        fi
        exit 1
    fi
    CREATED+=("${tag}")
done
echo "Published module releases (${#CREATED[@]})."
