#!/usr/bin/env bash
# Exercise the real structure checker with release notes of one and several editions:
# every older edition must carry the "> **Superseded.**" line linking to a newer one.
set -euo pipefail
export LC_ALL=C

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT
mkdir -p "${WORK}/.github/scripts" "${WORK}/.github/releases" "${WORK}/module/patches"
cp "${REPO_ROOT}/.github/scripts/check-modules.sh" "${WORK}/.github/scripts/"
for readme in README.md README.de.md; do
    echo 'Module with change.patch' > "${WORK}/module/${readme}"
done
echo 'Fixture license' > "${WORK}/module/LICENSE"
echo 'source 0000000000000000000000000000000000000000 https://example.test/source' > "${WORK}/module/NOTICE"
cat > "${WORK}/module/patches/change.patch" <<'PATCH'
# Target repository: source
diff --git a/source.txt b/source.txt
--- a/source.txt
+++ b/source.txt
@@ -1 +1 @@
-before
+after
PATCH

NOTES="${WORK}/.github/releases"
OUT="${WORK}/result"
CASES=0
superseded() { # <notes file> <tag the Superseded line links to>
    printf '# Module\n\n> **Superseded.** This is an older release, replaced by [%s](https://example.test/releases/tag/%s).\n> Use the newest module release.\n\nNotes\n' \
        "$2" "$2" > "${NOTES}/$1"
}
accept() {
    if ! bash "${WORK}/.github/scripts/check-modules.sh" > "${OUT}" 2>&1; then
        cat "${OUT}" >&2
        echo "FAIL: $*" >&2
        exit 1
    fi
    CASES=$((CASES + 1))
    echo "ok   $*"
}
reject() { # <expected error text> <description>
    if bash "${WORK}/.github/scripts/check-modules.sh" > "${OUT}" 2>&1; then
        echo "FAIL: accepted $2" >&2
        exit 1
    fi
    if ! grep -Fq "$1" "${OUT}"; then
        cat "${OUT}" >&2
        echo "FAIL: wrong rejection for $2" >&2
        exit 1
    fi
    CASES=$((CASES + 1))
    echo "ok   rejects $2"
}

echo '# Module v1.0' > "${NOTES}/module-v1.0.md"
accept 'a single edition needs no Superseded line'
echo '# Module v1.1' > "${NOTES}/module-v1.1.md"
reject 'module-v1.0.md: module-v1.1 exists' 'an older edition without the Superseded line'
superseded module-v1.0.md module-v1.1
accept 'an older edition linking to its successor'
echo '# Experimental v0.1' > "${NOTES}/module-experimental-v0.1.md"
accept 'a release line with a longer name is not an edition of this module'
superseded module-v1.0.md module-v0.9
reject 'must link to a newer module release' 'a link to an older edition'
superseded module-v1.0.md other-v2.0
reject 'must link to a newer module release' 'a link to another module'
superseded module-v1.0.md module-v1.2
reject 'must link to a newer module release' 'a link to an edition without notes'
echo '# Module v1.2' > "${NOTES}/module-v1.2.md"
reject 'module-v1.1.md: module-v1.2 exists' 'a middle edition without the Superseded line'
superseded module-v1.1.md module-v1.2
accept 'every older edition links to a newer one, not necessarily the newest'
echo "all release-notes tests passed (${CASES} cases)"
