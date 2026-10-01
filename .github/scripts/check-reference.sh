#!/usr/bin/env bash
# Checks a module's real patches against the real upstream sources.
#
# For every target repository, the module's NOTICE lists the reference commit and
# the public repository URL. This script fetches exactly that commit — or the tip
# of a branch given with --branch — but only the files the patches touch (partial
# clone plus sparse checkout: frameworks/base costs about 13 MB instead of several
# GB). It then runs the module's own apply-patches.sh: check, apply, reverse check,
# reverse. Every repository must be back at its original, clean source state.
# An optional fourth NOTICE field, branch=<name>, selects a vendor's differently
# named Android branch during branch checks; pinned commit checks ignore it.
#
# Usage: .github/scripts/check-reference.sh [--branch <name>] [module-directory]
#        default: the reference commits from NOTICE, module aptx-adaptive
set -euo pipefail
export LC_ALL=C

BRANCH=""
if [[ "${1:-}" == "--branch" ]]; then
    BRANCH="${2:?--branch needs a branch name}"
    shift 2
fi
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MODULE="${1:-aptx-adaptive}"
MOD="${REPO_ROOT}/${MODULE}"
for required in apply-patches.sh NOTICE; do
    [[ -f "${MOD}/${required}" ]] || { echo "ERROR: missing ${MODULE}/${required}" >&2; exit 1; }
done

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT
TREE="${WORK}/tree"

mapfile -t ENTRIES < <(sed -n '/^PATCHES=(/,/^)/p' "${MOD}/apply-patches.sh" | grep -oE '"[^"]+"' | tr -d '"')
mapfile -t REPOS < <(printf '%s\n' "${ENTRIES[@]}" | cut -d: -f1 | awk '!seen[$0]++')

if [[ -n "${BRANCH}" ]]; then
    echo "== ${MODULE}: fetching branch ${BRANCH}, with per-repository NOTICE branch overrides"
else
    echo "== ${MODULE}: fetching every target repository at its NOTICE reference commit"
fi
for repo in "${REPOS[@]}"; do
    sha=""
    url=""
    branch_hint=""
    read -r _ sha url branch_hint _ < <(awk -v r="${repo}" '$1 == r { print; exit }' "${MOD}/NOTICE") || true
    if [[ -z "${sha}" || "${url}" != https://* ]]; then
        echo "ERROR: ${MODULE}/NOTICE has no '<repository> <commit> <https-url>' line for ${repo}" >&2
        exit 1
    fi
    target="${BRANCH:-${sha}}"
    if [[ -n "${BRANCH}" && "${branch_hint}" == branch=* ]]; then
        target="${branch_hint#branch=}"
    fi
    dir="${TREE}/${repo}"

    git -c init.defaultBranch=check init -q "${dir}"
    git -C "${dir}" remote add origin "${url}"
    git -C "${dir}" fetch -q --depth 1 --filter=blob:none origin "${target}"
    git -C "${dir}" config core.sparseCheckout true
    for entry in "${ENTRIES[@]}"; do
        IFS=":" read -r entry_repo patch _ <<< "${entry}"
        [[ "${entry_repo}" == "${repo}" ]] || continue
        git apply --numstat "${MOD}/patches/${patch}" | cut -f3 | sed 's|^|/|'
    done > "${dir}/.git/info/sparse-checkout"
    git -C "${dir}" checkout -q FETCH_HEAD
    echo "   ${repo}: $(git -C "${dir}" rev-parse --short=12 HEAD) (${target})"
done

run() {
    echo ""
    echo "== apply-patches.sh $*"
    bash "${MOD}/apply-patches.sh" "$@" "${TREE}"
}
run --check
run
run --check --reverse
run --reverse

for repo in "${REPOS[@]}"; do
    changes="$(git -C "${TREE}/${repo}" status --porcelain --untracked-files=all)"
    if [[ -n "${changes}" ]]; then
        echo "ERROR: ${repo} was not restored after reversing the patches:" >&2
        printf '%s\n' "${changes}" >&2
        exit 1
    fi
    echo "   restored cleanly: ${repo}"
done

echo ""
echo "real patches apply and revert cleanly on ${BRANCH:+branch }${BRANCH:-the reference commits} (${MODULE})"
