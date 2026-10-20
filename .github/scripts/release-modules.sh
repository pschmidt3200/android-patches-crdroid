#!/usr/bin/env bash
# Verify and publish module/collection tags with .github/releases/<tag>.md notes.
# --check performs the same preflight without creating releases. Tags must already
# exist locally and on GitHub.
#
# Every module release carries <tag>.zip: exactly the <module>/ directory of the tag,
# built with git archive. GitHub's automatic "Source code" archives always contain
# the whole repository, so they are no way to download one module. Collection
# releases keep those full archives and get no extra file. An existing release keeps
# its tag, title and notes; the only later changes are attaching a missing module
# archive once and, once its notes carry the "> **Superseded.**" line, marking it as
# superseded (title suffix plus that line under its heading). An archive that is
# already attached is never replaced.
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
DETAILS=()
for i in "${!TAGS[@]}"; do
    if ! grep -Fxq -- "${TAGS[i]}" <<< "${published}"; then
        PENDING+=("${i}")
    elif [[ -z "${MODULES[i]}" ]]; then
        echo "Already exists; leaving release unchanged: ${TAGS[i]}"
    else
        DETAILS[i]="$(gh api "repos/${GH_REPO}/releases/tags/${TAGS[i]}" \
            --jq '{name: .name, body: .body, assets: [.assets[].name]}')"
        assets="$(python3 -c 'import json,sys; print("\n".join(json.load(sys.stdin)["assets"]))' <<< "${DETAILS[i]}")"
        if grep -Fxq -- "${TAGS[i]}.zip" <<< "${assets}"; then
            echo "Already exists with its module archive; leaving release unchanged: ${TAGS[i]}"
        else
            echo "Already exists without module archive; tag and notes stay unchanged: ${TAGS[i]}"
            ATTACH+=("${i}")
        fi
    fi
done

# Superseded marks (Pascal 2026-10-19: older releases must be recognisable). A module
# release whose notes carry the "> **Superseded.**" line, while its GitHub title or body
# do not show it yet, is marked once. The line must link to one newer release of the same
# module that is already published or published in this run; anything else aborts here,
# before the first write.
pending_tags="$(for i in "${PENDING[@]}"; do echo "${TAGS[i]}"; done)"
MARK=()
declare -A MARK_TO=()
for i in "${!DETAILS[@]}"; do
    target="$(TAG="${TAGS[i]}" MODULE="${MODULES[i]}" NOTES_FILE="${NOTES[i]}" DETAILS="${DETAILS[i]}" \
        KNOWN="${published}"$'\n'"${pending_tags}" python3 - <<'PY'
import json, os, re, sys
module, tag, notes_file = os.environ["MODULE"], os.environ["TAG"], os.environ["NOTES_FILE"]
lines = open(notes_file, encoding="utf-8").read().split("\n")
start = next((n for n, line in enumerate(lines) if line.startswith("> **Superseded.**")), None)
if start is None:
    sys.exit(0)
block = []
for line in lines[start:]:
    if not line.startswith(">"):
        break
    block.append(line)
def version(name):
    match = re.fullmatch(re.escape(module) + r"-v([0-9]+(?:\.[0-9]+)+)(?:-[A-Za-z0-9.-]+)?", name)
    return tuple(int(part) for part in match.group(1).split(".")) if match else None
links = set(re.findall(r"/releases/tag/([^)\s]+)\)", "\n".join(block)))
target = links.pop() if len(links) == 1 else ""
if not target or version(target) is None or version(target) <= version(tag) \
        or target not in os.environ["KNOWN"].split():
    sys.exit(f"ERROR: {notes_file}: the Superseded line must link to one newer {module} "
             "release that is published or published in this run")
details = json.loads(os.environ["DETAILS"])
if "(superseded by " not in (details.get("name") or "") or "**Superseded.**" not in (details.get("body") or ""):
    print(target)
PY
)"
    if [[ -n "${target}" ]]; then
        MARK+=("${i}")
        MARK_TO[${i}]="${target}"
    fi
done
if [[ ${#PENDING[@]} -eq 0 && ${#ATTACH[@]} -eq 0 && ${#MARK[@]} -eq 0 ]]; then
    echo 'No unpublished releases, no missing module archives and no superseded marks due.'
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
        bash .github/scripts/check-reference.sh --branch 17.0 "${target}"
        CHECKED[${target}]=1
    done
done
if [[ ${CHECK} -eq 1 ]]; then
    for i in "${ATTACH[@]}"; do
        echo "Would attach ${TAGS[i]}.zip to the existing release ${TAGS[i]}"
    done
    for i in "${MARK[@]}"; do
        echo "Would mark ${TAGS[i]} as superseded by ${MARK_TO[${i}]}"
    done
    echo "Release preflight passed (${#PENDING[@]} release(s), ${#ATTACH[@]} archive(s) to attach, ${#MARK[@]} superseded mark(s)); nothing published."
    exit 0
fi

CREATED=()
ATTACHED=()
MARKED=()
report_failure() { # <message>
    echo "ERROR: $1" >&2
    if [[ ${#CREATED[@]} -gt 0 ]]; then
        printf 'Already published; left unchanged: %s\n' "${CREATED[@]}" >&2
    fi
    if [[ ${#ATTACHED[@]} -gt 0 ]]; then
        printf 'Already attached; left unchanged: %s\n' "${ATTACHED[@]}" >&2
    fi
    if [[ ${#MARKED[@]} -gt 0 ]]; then
        printf 'Already marked superseded; left unchanged: %s\n' "${MARKED[@]}" >&2
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
# Last, so a successor published in this run already exists when the mark links to it.
# Only the Superseded block is added under the published heading; the rest of the
# published body stays as it is.
for i in "${MARK[@]}"; do
    notes="${ARCHIVE_DIR}/${TAGS[i]}.notes.md"
    title="$(TAG="${TAGS[i]}" MODULE="${MODULES[i]}" TARGET="${MARK_TO[${i}]}" NOTES_FILE="${NOTES[i]}" \
        DETAILS="${DETAILS[i]}" python3 - "${notes}" <<'PY'
import json, os, re, sys
details = json.loads(os.environ["DETAILS"])
lines = open(os.environ["NOTES_FILE"], encoding="utf-8").read().split("\n")
start = next(n for n, line in enumerate(lines) if line.startswith("> **Superseded.**"))
block = []
for line in lines[start:]:
    if not line.startswith(">"):
        break
    block.append(line)
body = (details.get("body") or "").split("\n")
if "**Superseded.**" not in "\n".join(body):
    head = 1 if body[0].startswith("# ") else 0
    rest = body[head:]
    while rest and rest[0] == "":
        rest = rest[1:]
    body = body[:head] + ([""] if head else []) + block + [""] + rest
with open(sys.argv[1], "w", encoding="utf-8") as out:
    out.write("\n".join(body))
title = re.sub(r" \(superseded by [^)]*\)$", "", details.get("name") or "") or os.environ["TAG"]
print(f"{title} (superseded by {os.environ['TARGET'][len(os.environ['MODULE']) + 1:]})")
PY
)"
    gh release edit "${TAGS[i]}" --title "${title}" --notes-file "${notes}" \
        || report_failure "marking ${TAGS[i]} as superseded failed"
    MARKED+=("${TAGS[i]}")
done
echo "Published releases: ${#PENDING[@]}; attached module archives: ${#ATTACH[@]}; marked superseded: ${#MARK[@]}."
