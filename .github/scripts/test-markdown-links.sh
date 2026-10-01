#!/usr/bin/env bash
# Exercise the real structure checker with external and local Markdown links.
set -euo pipefail
export LC_ALL=C

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT
mkdir -p "${WORK}/.github/scripts" "${WORK}/module/patches"
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

OUT="${WORK}/result"
accept() {
    if ! bash "${WORK}/.github/scripts/check-modules.sh" > "${OUT}" 2>&1; then
        cat "${OUT}" >&2
        echo "FAIL: $*" >&2
        exit 1
    fi
    echo "ok   $*"
}
reject() {
    local expected="$1"
    if bash "${WORK}/.github/scripts/check-modules.sh" > "${OUT}" 2>&1; then
        echo "FAIL: accepted broken link '${expected}'" >&2
        exit 1
    fi
    if ! grep -Fq "broken link '${expected}'" "${OUT}"; then
        cat "${OUT}" >&2
        echo "FAIL: wrong rejection for '${expected}'" >&2
        exit 1
    fi
    echo "ok   rejects ${expected}"
}

accept 'valid module without links'
cat > "${WORK}/links.md" <<'MARKDOWN'
[HTTPS](https://example.test/path#section)
[HTTP](http://example.test/path)
[Email](mailto:fixture@example.test)
[Protocol relative](//example.test/path)
[Anchor](#section)
[Empty]()
[Local](module/README.md)
[Local fragment](module/README.md#section)
MARKDOWN
accept 'external URLs, anchors and existing local targets'
echo '[Missing](module/missing.md)' > "${WORK}/links.md"
reject 'module/missing.md'
echo '[Missing fragment](module/missing.md#section)' > "${WORK}/links.md"
reject 'module/missing.md'
echo '[Local HTTPS name](https-guide.md)' > "${WORK}/links.md"
reject 'https-guide.md'
touch "${WORK}/https-guide.md"
accept 'local HTTPS name resolves when its file exists'
echo 'all Markdown link tests passed (6 cases)'
