#!/usr/bin/env bash
# ==============================================================================
# apply-patches.sh — Automated Patch Installer for aptX Adaptive on crDroid/AOSP
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_DIR="${SCRIPT_DIR}/patches"

MODE="apply"
DRY_RUN=0

usage() {
    local exit_code="${1:-0}"
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] <ANDROID_BUILD_ROOT>

Applies or reverts the aptX Adaptive patch series to your ROM source tree.

Options:
    -c, --check       Perform a dry-run check without modifying any files.
    -r, --reverse     Revert previously applied patches.
    -h, --help        Show this help message.

Arguments:
    <ANDROID_BUILD_ROOT>   Path to the root of your crDroid / AOSP source tree.

Examples:
    $(basename "$0") /media/Android/crdroid
    $(basename "$0") --check /media/Android/crdroid
    $(basename "$0") --reverse /media/Android/crdroid
EOF
    exit "${exit_code}"
}

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--check)
            DRY_RUN=1
            shift
            ;;
        -r|--reverse)
            MODE="reverse"
            shift
            ;;
        -h|--help)
            usage 0
            ;;
        -*)
            echo "[-] Error: Unknown option: $1" >&2
            usage 1
            ;;
        *)
            break
            ;;
    esac
done

if [[ $# -lt 1 ]]; then
    echo "[-] Error: Missing ANDROID_BUILD_ROOT argument." >&2
    usage 1
fi

if [[ ! -d "$1" ]]; then
    echo "[-] Error: ANDROID_BUILD_ROOT is not a directory: $1" >&2
    exit 1
fi
ANDROID_ROOT="$(cd "$1" && pwd)"

# Definition of the 6 patches and their respective target repositories
PATCHES=(
    "packages/modules/Bluetooth:crdroid_bluetooth_aptx_adaptive_native.patch:Bluetooth Stack & Audio HAL"
    "frameworks/base:crdroid_framework_aptx_adaptive_offload.patch:AudioPolicy Framework Offload"
    "frameworks/base:crdroid_framework_settingslib_codec_status.patch:SettingsLib Codec Status"
    "packages/apps/Settings:crdroid_settings_bluetooth_codec_badges.patch:Settings UI Codec Badges"
    "packages/apps/GameSpace:crdroid_gamespace_bluetooth_gaming_audio.patch:GameSpace Low-Latency Hook"
    "device/oneplus/sm8750-common:crdroid_aptx_r2_2_property.patch:Device Tree Properties"
)

echo "===================================================================="
echo " aptX Adaptive Patch Tool [Mode: ${MODE^^}]"
echo " Android Root: ${ANDROID_ROOT}"
echo "===================================================================="

# Phase 1: Verify directories and run git apply --check
echo ""
echo "[*] Phase 1: Verifying targets and checking patch applicability..."

FAILED_CHECKS=0

for item in "${PATCHES[@]}"; do
    IFS=":" read -r rel_repo patch_file desc <<< "$item"
    target_repo="${ANDROID_ROOT}/${rel_repo}"
    patch_path="${PATCH_DIR}/${patch_file}"

    if [[ ! -f "${patch_path}" ]]; then
        echo " [-] Patch file not found: ${patch_path}" >&2
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        continue
    fi

    if [[ ! -d "${target_repo}" ]]; then
        if [[ "${rel_repo}" == "device/oneplus/sm8750-common" ]]; then
            echo " [!] Note: Optional target '${rel_repo}' not found in tree (device-specific)."
            continue
        else
            echo " [-] Missing required target repository: ${rel_repo}" >&2
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            continue
        fi
    fi

    APPLY_ARGS=(--check)
    if [[ "${MODE}" == "reverse" ]]; then
        APPLY_ARGS+=(--reverse)
    fi

    if check_output="$(git -C "${target_repo}" apply "${APPLY_ARGS[@]}" "${patch_path}" 2>&1)"; then
        echo " [+] OK: ${patch_file} -> ${rel_repo} (${desc})"
    else
        echo " [-] FAILED check: ${patch_file} cannot be applied to ${rel_repo}" >&2
        # Show git's own reason (first lines only), e.g. "patch does not apply".
        printf '%s\n' "${check_output}" | head -n 5 | sed 's/^/       /' >&2
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
done

if [[ ${FAILED_CHECKS} -gt 0 ]]; then
    echo ""
    echo "[-] ABORTING: ${FAILED_CHECKS} patch check(s) failed." >&2
    echo "    Check if the patches are already applied or if your source tree diverged." >&2
    exit 2
fi

if [[ ${DRY_RUN} -eq 1 ]]; then
    echo ""
    echo "[+] Dry-run check successful! All patches can be cleanly applied."
    exit 0
fi

# Phase 2: Apply / Reverse patches
echo ""
echo "[*] Phase 2: Executing [${MODE^^}]..."

# Revert in the opposite order of application.
ORDER=("${PATCHES[@]}")
if [[ "${MODE}" == "reverse" ]]; then
    ORDER=()
    for (( i=${#PATCHES[@]}-1; i>=0; i-- )); do
        ORDER+=("${PATCHES[i]}")
    done
fi

DONE_LIST=()
for item in "${ORDER[@]}"; do
    IFS=":" read -r rel_repo patch_file desc <<< "$item"
    target_repo="${ANDROID_ROOT}/${rel_repo}"
    patch_path="${PATCH_DIR}/${patch_file}"

    if [[ ! -d "${target_repo}" && "${rel_repo}" == "device/oneplus/sm8750-common" ]]; then
        echo " [~] Skipping optional target: ${rel_repo}"
        continue
    fi

    EXEC_ARGS=()
    if [[ "${MODE}" == "reverse" ]]; then
        EXEC_ARGS+=(--reverse)
    fi

    if ! git -C "${target_repo}" apply "${EXEC_ARGS[@]}" "${patch_path}"; then
        echo "" >&2
        echo "[-] ABORTED: ${patch_file} failed on ${rel_repo} although the check passed." >&2
        if [[ ${#DONE_LIST[@]} -gt 0 ]]; then
            echo "    Already processed in this run (tree is now partially changed):" >&2
            printf '      %s\n' "${DONE_LIST[@]}" >&2
            echo "    Inspect with 'git -C <repo> status' and undo with 'git -C <repo> apply --reverse <patch>'." >&2
        fi
        exit 3
    fi
    DONE_LIST+=("${patch_file} -> ${rel_repo}")
    if [[ "${MODE}" == "reverse" ]]; then
        echo " [✓] Reverted: ${patch_file} from ${rel_repo}"
    else
        echo " [✓] Applied: ${patch_file} to ${rel_repo}"
    fi
done

echo ""
echo "===================================================================="
if [[ "${MODE}" == "reverse" ]]; then
    echo " [+] Reverted all aptX Adaptive patches."
else
    echo " [+] Applied all aptX Adaptive patches."
    echo "     Next: review 'git -C <repo> diff' in each target repository, then"
    echo "     build and validate on your device. A clean apply is not a working build."
fi
echo "===================================================================="
