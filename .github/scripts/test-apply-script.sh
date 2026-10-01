#!/usr/bin/env bash
# Behaviour test for <module>/apply-patches.sh against a throwaway source tree.
#
# The real patches need a full crDroid tree, which CI does not have. This test
# therefore builds one small git repository per target repository listed in the
# script's PATCHES array, writes synthetic patches with the same names, and
# drives the real script through every path that matters to a user.
#
# Usage: .github/scripts/test-apply-script.sh [module-directory]   (default: aptx-adaptive)
set -euo pipefail
export LC_ALL=C

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MODULE="${1:-aptx-adaptive}"
SCRIPT_SRC="${REPO_ROOT}/${MODULE}/apply-patches.sh"
[[ -f "${SCRIPT_SRC}" ]] || { echo "no apply-patches.sh in ${MODULE}" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT
TOOL="${WORK}/tool"
TREE="${WORK}/tree"
mkdir -p "${TOOL}/patches" "${TREE}"
cp "${SCRIPT_SRC}" "${TOOL}/apply-patches.sh"

export GIT_AUTHOR_NAME=ci GIT_AUTHOR_EMAIL=ci@localhost
export GIT_COMMITTER_NAME=ci GIT_COMMITTER_EMAIL=ci@localhost

# "repo:file:description" entries, exactly as the script defines them.
mapfile -t ENTRIES < <(sed -n '/^PATCHES=(/,/^)/p' "${SCRIPT_SRC}" | grep -oE '"[^"]+"' | tr -d '"')
[[ ${#ENTRIES[@]} -gt 0 ]] || { echo "PATCHES array not found in ${SCRIPT_SRC}" >&2; exit 1; }

fail() { echo "FAIL: $*" >&2; exit 1; }
OUT=""
RC=0
run() {
    set +e
    OUT="$(bash "${TOOL}/apply-patches.sh" "$@" 2>&1)"
    RC=$?
    set -e
}
expect_rc() {
    if [[ "${RC}" -ne "$1" ]]; then
        printf '%s\n' "${OUT}" >&2
        fail "$2: expected exit $1, got ${RC}"
    fi
    echo "ok   $2"
}
expect_out() {
    if ! grep -qE -- "$1" <<< "${OUT}"; then
        printf '%s\n' "${OUT}" >&2
        fail "$2: output does not match /$1/"
    fi
    echo "ok   $2"
}
# Unified diff that replaces the single line of <file>.
write_patch() { # <patch file> <file> <old line> <new line>
    printf 'diff --git a/%s b/%s\n--- a/%s\n+++ b/%s\n@@ -1 +1 @@\n-%s\n+%s\n' \
        "$2" "$2" "$2" "$2" "$3" "$4" > "${TOOL}/patches/$1"
}
content() { cat "${TREE}/$1"; }

# --- Build the throwaway tree: one file per patch, plus one unrelated file ----
declare -A FILE_OF=()
n=0
for entry in "${ENTRIES[@]}"; do
    IFS=":" read -r repo patch _ <<< "${entry}"
    n=$((n + 1))
    mkdir -p "${TREE}/${repo}"
    if [[ ! -d "${TREE}/${repo}/.git" ]]; then
        git -C "${TREE}/${repo}" init -q
        echo "unrelated" > "${TREE}/${repo}/unrelated.txt"
    fi
    FILE_OF[${patch}]="file${n}.txt"
    echo "base" > "${TREE}/${repo}/file${n}.txt"
    write_patch "${patch}" "file${n}.txt" "base" "patched${n}"
done
for repo in $(printf '%s\n' "${ENTRIES[@]}" | cut -d: -f1 | sort -u); do
    git -C "${TREE}/${repo}" add -A
    git -C "${TREE}/${repo}" commit -qm base
done

# NOTICE with the current HEADs as reference commits.
write_notice() { # [repo-to-fake] [fake-sha]
    {
        echo "Reference repositories and commits:"
        for repo in $(printf '%s\n' "${ENTRIES[@]}" | cut -d: -f1 | sort -u); do
            sha="$(git -C "${TREE}/${repo}" rev-parse HEAD)"
            [[ "${repo}" == "${1:-}" ]] && sha="$2"
            printf '  %-32s %s\n' "${repo}" "${sha}"
        done
    } > "${TOOL}/NOTICE"
}
write_notice

first_entry="${ENTRIES[0]}"
first_repo="${first_entry%%:*}"
first_patch="$(cut -d: -f2 <<< "${first_entry}")"
last_patch="$(cut -d: -f2 <<< "${ENTRIES[${#ENTRIES[@]}-1]}")"

# --- 1. Check, apply, re-check, reverse ------------------------------------
run --check "${TREE}";   expect_rc 0 "check on a clean tree"
expect_out "matches reference" "check reports the reference state"
[[ "$(content "${first_repo}/${FILE_OF[${first_patch}]}")" == "base" ]] || fail "check modified the tree"
echo "ok   check leaves the tree untouched"

run "${TREE}";           expect_rc 0 "apply"
[[ "$(content "${first_repo}/${FILE_OF[${first_patch}]}")" == "patched1" ]] || fail "apply did not patch"
echo "ok   apply changes the files"

run --check "${TREE}";   expect_rc 2 "check on an already patched tree fails"
expect_out '^ {7}[^ ]' "failed check shows git's reason"

run --reverse "${TREE}"; expect_rc 0 "reverse"
expect_out "Reverted: ${last_patch}" "reverse starts with the last patch"
first_reverted="$(grep -m1 -oE 'Reverted: [^ ]+' <<< "${OUT}" | cut -d' ' -f2)"
[[ "${first_reverted}" == "${last_patch}" ]] || fail "reverse order: first was ${first_reverted}"
echo "ok   reverse order is last-to-first"
[[ "$(content "${first_repo}/${FILE_OF[${first_patch}]}")" == "base" ]] || fail "reverse did not restore"
echo "ok   reverse restores the files"

# --- 2. Argument errors -----------------------------------------------------
run "${WORK}/does-not-exist"; expect_rc 1 "missing source root"

# --- 3. Dirty target repositories -------------------------------------------
echo "local change" >> "${TREE}/${first_repo}/unrelated.txt"
run "${TREE}";           expect_rc 4 "apply refuses a dirty target repository"
expect_out "${first_repo}" "dirty refusal names the repository"
[[ "$(content "${first_repo}/${FILE_OF[${first_patch}]}")" == "base" ]] || fail "dirty refusal changed files"
echo "ok   dirty refusal changes nothing"
run --allow-dirty "${TREE}"; expect_rc 0 "--allow-dirty applies anyway"
run --reverse "${TREE}"; expect_rc 0 "reverse works on the (necessarily dirty) patched tree"
git -C "${TREE}/${first_repo}" checkout -q -- unrelated.txt

# --- 4. Reference commits ---------------------------------------------------
echo "newer" > "${TREE}/${first_repo}/later.txt"
git -C "${TREE}/${first_repo}" add later.txt
git -C "${TREE}/${first_repo}" commit -qm later
run --check "${TREE}";   expect_rc 0 "check on a newer tree still runs"
expect_out "newer than reference" "newer tree is reported as newer"
write_notice "${first_repo}" "0123456789abcdef0123456789abcdef01234567"
run --check "${TREE}";   expect_rc 0 "unknown reference does not abort"
expect_out "not in local history" "unknown reference is reported"
rm -f "${TOOL}/NOTICE"
run --check "${TREE}";   expect_rc 0 "missing NOTICE does not abort"
write_notice

# --- 5. Series inside one repository ---------------------------------------
series_repo="$(printf '%s\n' "${ENTRIES[@]}" | cut -d: -f1 | sort | uniq -d | head -n1)"
if [[ -n "${series_repo}" ]]; then
    mapfile -t series < <(printf '%s\n' "${ENTRIES[@]}" | awk -F: -v r="${series_repo}" '$1 == r {print $2}')
    shared="${FILE_OF[${series[0]}]}"
    # Second patch builds on the first: only valid as a series.
    write_patch "${series[0]}" "${shared}" "base" "step1"
    write_patch "${series[1]}" "${shared}" "step1" "step2"
    run --check "${TREE}";   expect_rc 0 "dependent patches pass as a series"
    run "${TREE}";           expect_rc 0 "dependent patches apply as a series"
    [[ "$(content "${series_repo}/${shared}")" == "step2" ]] || fail "series result wrong"
    run --check --reverse "${TREE}"; expect_rc 0 "dependent patches revert as a series"
    run --reverse "${TREE}"; expect_rc 0 "reverse of the series"
    [[ "$(content "${series_repo}/${shared}")" == "base" ]] || fail "series reverse result wrong"
    # Conflicting patches: each fits the untouched tree, together they do not.
    write_patch "${series[1]}" "${shared}" "base" "other"
    run --check "${TREE}";   expect_rc 2 "conflicting patches fail the check"
    expect_out "${series[1]}" "conflict names the second patch"
    run "${TREE}";           expect_rc 2 "conflicting series is refused before anything changes"
    [[ "$(content "${series_repo}/${shared}")" == "base" ]] || fail "conflict changed the tree"
    [[ "$(content "${first_repo}/${FILE_OF[${first_patch}]}")" == "base" ]] || fail "conflict changed another repository"
    echo "ok   conflicting series leaves every repository untouched"
else
    echo "skip series tests: no target repository has two patches"
fi

echo "all apply-patches.sh behaviour tests passed (${MODULE})"
