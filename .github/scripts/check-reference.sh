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
export LC_ALL=C.UTF-8
# A busy host may also accept the connection and then stall (19 October 2026: a fetch
# hung for minutes without output). Git aborts transfers slower than 1 KB/s for 60 s,
# lazy blob downloads included; each fetch below has a hard limit as well.
export GIT_HTTP_LOW_SPEED_LIMIT=1000 GIT_HTTP_LOW_SPEED_TIME=60

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

# Network steps against the public upstream hosts are retried: a refused or
# overloaded response (e.g. "unable to handle this request due to load") must not
# fail the check. gitlab.com is regularly overloaded for minutes (12 and 19 October
# 2026), so the waits grow to about 12 minutes in total before the step gives up.
# Retried are fetching, the lazy blob download of the checkout and the final
# `git status`, which in this partial clone may download objects as well (it failed
# with "could not fetch ... from promisor remote" on 19 October 2026). The patch
# checks run exactly once. CHECK_REFERENCE_NETWORK_DELAYS shortens the waits for
# local tests.
read -r -a NETWORK_DELAYS <<< "${CHECK_REFERENCE_NETWORK_DELAYS:-30 60 120 240 300}"
retry_network() {
    local attempt=1 attempts=$((${#NETWORK_DELAYS[@]} + 1)) delay
    "$@" && return 0
    for delay in "${NETWORK_DELAYS[@]}"; do
        echo "   network step failed (attempt ${attempt}/${attempts}), retrying in ${delay} s" >&2
        sleep "${delay}"
        attempt=$((attempt + 1))
        "$@" && return 0
    done
    echo "ERROR: upstream host unreachable after ${attempts} attempts — a network outage, not a patch problem; re-run the check later: $*" >&2
    return 1
}

# Raw-file fallback (19 October 2026): gitlab.com refused every git fetch of
# susfs4ksu ("unable to handle this request due to load" for an exact commit, a
# partial clone and even a shallow branch fetch), while its HTTP raw-file endpoint
# served the same commit's files reliably. When the git fetch fails, the files the
# patches touch come from that endpoint of the original repository, at the same
# commit or branch; the checks that follow are unchanged. CHECK_REFERENCE_FORCE_RAW=1
# takes this path directly, for local tests.
raw_url() { # <repository url> <commit or branch> <path>
    local base="${1%.git}"
    case "${base}" in
        https://gitlab.com/*) echo "${base}/-/raw/$2/$3" ;;
        https://github.com/*) echo "https://raw.githubusercontent.com/${base#https://github.com/}/$2/$3" ;;
        *) return 1 ;;
    esac
}
raw_get() { # <url> <file>: 200 keeps the file, 404 means the file does not exist upstream
    local code
    code="$(curl -sSL --max-time 60 -o "$2" -w '%{http_code}' "$1")" || return 1
    case "${code}" in
        200) return 0 ;;
        404) rm -f "$2"; return 0 ;;
        *) echo "   HTTP ${code} for $1" >&2; return 1 ;;
    esac
}
fetch_raw() { # <dir> <repository url> <commit or branch> <path>...
    local dir="$1" url="$2" target="$3" path found=0
    shift 3
    for path in "$@"; do
        mkdir -p "$(dirname "${dir}/${path}")"
        retry_network raw_get "$(raw_url "${url}" "${target}" "${path}")" "${dir}/${path}" || return 1
        if [[ -e "${dir}/${path}" ]]; then
            found=$((found + 1))
        fi
    done
    if ((found == 0)); then
        echo "ERROR: none of the patched files exists at ${target} in ${url} — wrong commit, branch or path" >&2
        return 1
    fi
    git -C "${dir}" add -A
    git -C "${dir}" -c user.name=check -c user.email=check@localhost commit -q -m "raw files of ${target}"
}

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
    mapfile -t paths < <(for entry in "${ENTRIES[@]}"; do
        IFS=":" read -r entry_repo patch _ <<< "${entry}"
        [[ "${entry_repo}" == "${repo}" ]] || continue
        git apply --numstat "${MOD}/patches/${patch}" | cut -f3
    done | awk '!seen[$0]++')
    fetch=(timeout 180 git -c credential.helper= -C "${dir}" fetch -q --depth 1 --filter=blob:none origin "${target}")
    if raw_url "${url}" x x > /dev/null; then
        # A raw-file endpoint exists: two git attempts, then the raw files.
        fetched=0
        if [[ -z "${CHECK_REFERENCE_FORCE_RAW:-}" ]]; then
            if "${fetch[@]}"; then
                fetched=1
            else
                sleep 30
                if "${fetch[@]}"; then
                    fetched=1
                fi
            fi
        fi
    else
        retry_network "${fetch[@]}"
        fetched=1
    fi
    if ((fetched)); then
        git -C "${dir}" config core.sparseCheckout true
        printf '/%s\n' "${paths[@]}" > "${dir}/.git/info/sparse-checkout"
        retry_network git -C "${dir}" checkout -q FETCH_HEAD
        echo "   ${repo}: $(git -C "${dir}" rev-parse --short=12 HEAD) (${target})"
    else
        echo "   ${repo}: git fetch refused, taking the patched files from the raw-file endpoint" >&2
        fetch_raw "${dir}" "${url}" "${target}" "${paths[@]}" || {
            echo "ERROR: upstream host unreachable for ${repo} — a network outage, not a patch problem; re-run the check later" >&2
            exit 1
        }
        echo "   ${repo}: ${#paths[@]} file(s) at ${target}, raw from ${url}"
    fi
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
    changes="$(retry_network git -C "${TREE}/${repo}" status --porcelain --untracked-files=all)"
    if [[ -n "${changes}" ]]; then
        echo "ERROR: ${repo} was not restored after reversing the patches:" >&2
        printf '%s\n' "${changes}" >&2
        exit 1
    fi
    echo "   restored cleanly: ${repo}"
done

echo ""
echo "real patches apply and revert cleanly on ${BRANCH:+branch }${BRANCH:-the reference commits} (${MODULE})"
