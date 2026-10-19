#!/usr/bin/env bash
# Structure and format checks for every module directory.
#
# Enforces the rules in README.md, "How Modules Are Kept Apart": no patches in the
# repository root, every module self-contained, every patch parseable and labelled
# with its target repository, and the apply script, the READMEs and NOTICE naming
# the same patches and repositories.
#
# Usage: .github/scripts/check-modules.sh
set -euo pipefail
export LC_ALL=C

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${REPO_ROOT}"

ERRORS=0
err() {
    echo "ERROR: $*" >&2
    ERRORS=$((ERRORS + 1))
}

if compgen -G "*.patch" > /dev/null; then
    err "patch files in the repository root — patches belong into <module>/patches/"
fi

mapfile -t MODULES < <(find . -mindepth 2 -maxdepth 2 -type d -name patches -not -path './.git/*' \
    | sed 's|^\./||; s|/patches$||' | sort)
[[ ${#MODULES[@]} -gt 0 ]] || err "no module with a patches/ directory found"

for module in "${MODULES[@]}"; do
    echo "== ${module}"
    for required in README.md README.de.md NOTICE LICENSE; do
        [[ -f "${module}/${required}" ]] || err "${module}: missing ${required}"
    done

    mapfile -t patches < <(find "${module}/patches" -maxdepth 1 -type f -name '*.patch' -printf '%f\n' | sort)
    [[ ${#patches[@]} -gt 0 ]] || err "${module}: patches/ contains no .patch file"

    declare -A target=()
    for patch in "${patches[@]}"; do
        path="${module}/patches/${patch}"
        header="$(head -n 1 "${path}")"
        if [[ "${header}" =~ ^\#\ Target\ repository:\ ([^[:space:]]+)$ ]]; then
            target[${patch}]="${BASH_REMATCH[1]}"
        else
            err "${path}: first line must be '# Target repository: <repository>'"
        fi
        # `git apply --stat` alone is not enough: it accepts a section whose hunk headers
        # are garbage as "0 changes". So every +/- line in the file must also be one that
        # git counted. (File headers are the "--- a/", "+++ b/" and "/dev/null" lines.)
        if ! parsed="$(git apply --numstat "${path}" 2>&1)"; then
            err "${path}: git cannot parse this patch: ${parsed%%$'\n'*}"
        else
            parsed_total="$(awk '{ total += $1 + $2 } END { print total + 0 }' <<< "${parsed}")"
            raw_total="$(grep -E '^[+-]' "${path}" | grep -cvE '^(\+\+\+|---) (a/|b/|/dev/null)' || true)"
            if [[ "${parsed_total}" != "${raw_total}" ]]; then
                err "${path}: git parsed ${parsed_total} changed lines, the file has ${raw_total} — broken hunk?"
            fi
        fi
        # Trailing whitespace in added lines (context lines are upstream code and stay as they are).
        while IFS= read -r hit; do
            err "${path}:${hit%%:*}: trailing whitespace in an added line"
        done < <(grep -nE '^\+' "${path}" | grep -vE '^[0-9]+:\+\+\+ ' | grep -E '[[:space:]]$' || true)
        for readme in README.md README.de.md; do
            if [[ -f "${module}/${readme}" ]] && ! grep -qF "${patch}" "${module}/${readme}"; then
                err "${module}/${readme} does not mention ${patch}"
            fi
        done
    done

    if [[ -f "${module}/apply-patches.sh" ]]; then
        [[ -x "${module}/apply-patches.sh" ]] || err "${module}/apply-patches.sh is not executable"
        bash -n "${module}/apply-patches.sh" || err "${module}/apply-patches.sh: syntax error"
        mapfile -t entries < <(sed -n '/^PATCHES=(/,/^)/p' "${module}/apply-patches.sh" \
            | grep -oE '"[^"]+"' | tr -d '"')
        [[ ${#entries[@]} -gt 0 ]] || err "${module}/apply-patches.sh: PATCHES array not found"
        listed=" "
        for entry in "${entries[@]}"; do
            IFS=":" read -r repo patch _ <<< "${entry}"
            listed+="${patch} "
            if [[ ! -f "${module}/patches/${patch}" ]]; then
                err "${module}/apply-patches.sh lists ${patch}, which does not exist"
            elif [[ "${target[${patch}]:-}" != "${repo}" ]]; then
                err "${module}: ${patch} header says '${target[${patch}]:-?}', apply-patches.sh says '${repo}'"
            fi
        done
        for patch in "${patches[@]}"; do
            [[ "${listed}" == *" ${patch} "* ]] || err "${module}/patches/${patch} is not listed in apply-patches.sh"
        done
    fi

    if [[ -f "${module}/NOTICE" ]]; then
        while IFS= read -r repo; do
            awk -v r="${repo}" '$1 == r && length($2) == 40 && $2 ~ /^[0-9a-f]+$/ && $3 ~ /^https:\/\// { found = 1 } END { exit !found }' \
                "${module}/NOTICE" || err "${module}/NOTICE: no '<repository> <40-digit commit> <https-url>' line for ${repo}"
        done < <(printf '%s\n' "${target[@]}" | sort -u)
    fi
    unset target
done

# Release notes of a module with several editions: every older edition carries the
# "> **Superseded.**" line linking to a newer edition of the same module, so readers can
# tell old releases apart (Pascal 2026-10-19). release-modules.sh then marks the published
# release once.
for module in "${MODULES[@]}"; do
    mapfile -t versions < <(
        for notes in .github/releases/"${module}"-v[0-9]*.md; do
            [[ -e "${notes}" ]] || continue
            name="$(basename "${notes}" .md)"
            echo "${name#"${module}-v"}"
        done | sort -V)
    [[ ${#versions[@]} -gt 1 ]] || continue
    for version in "${versions[@]:0:${#versions[@]}-1}"; do
        notes=".github/releases/${module}-v${version}.md"
        block="$(sed -n '/^> \*\*Superseded\.\*\*/,/^[^>]/p' "${notes}")"
        if [[ -z "${block}" ]]; then
            err "${notes}: ${module}-v${versions[-1]} exists — add a '> **Superseded.**' line under the heading linking to a newer ${module} release"
            continue
        fi
        # Not "target": the module loop above uses that name for an associative array.
        successor="$(grep -oE "/releases/tag/${module}-v[0-9][^) ]*\)" <<< "${block}" | head -n 1 || true)"
        successor="${successor#/releases/tag/"${module}"-v}"
        successor="${successor%)}"
        if [[ -z "${successor}" || "${successor}" == "${version}" \
                || "$(printf '%s\n' "${version}" "${successor}" | sort -V | tail -n 1)" != "${successor}" \
                || ! -f ".github/releases/${module}-v${successor}.md" ]]; then
            err "${notes}: the Superseded line must link to a newer ${module} release with notes"
        fi
    done
done

# Relative links in Markdown files must resolve (external links and anchors are not checked).
while IFS= read -r markdown; do
    dir="$(dirname "${markdown}")"
    while IFS= read -r link; do
        if [[ "${link}" =~ ^[A-Za-z][A-Za-z0-9+.-]*: ]] || [[ "${link}" == //* ]]; then
            continue
        fi
        link="${link%%#*}"
        [[ -n "${link}" ]] || continue
        [[ -e "${dir}/${link}" ]] || err "${markdown}: broken link '${link}'"
    done < <(grep -oE '\]\([^)]*\)' "${markdown}" | sed 's/^](//; s/)$//' | sort -u)
done < <(find . -name '*.md' -not -path './.git/*' | sed 's|^\./||' | sort)

if [[ ${ERRORS} -gt 0 ]]; then
    echo "${ERRORS} problem(s) found" >&2
    exit 1
fi
echo "all module checks passed (${#MODULES[@]} module(s))"
