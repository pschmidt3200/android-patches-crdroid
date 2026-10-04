# Bluetooth codec status, badges and selection for crDroid 16.0

Settings patches that show the active Bluetooth audio codec and sample rate, and let you choose
the codec and its sample rate. They are codec-independent: everything shown or offered comes from the
Bluetooth stack and the connected device, for example SBC, AAC, aptX, aptX HD, LDAC or — when
the stack provides it — aptX Adaptive.

**ROM scope:** This package is currently intended only for **crDroid 16.0** (Android 16).
Support for other ROMs has not been established.

German version: [README.de.md](README.de.md)

---

## What it adds

| | |
|---|---|
| **Codec status** | SettingsLib can read the active codec configuration of a device and refreshes the device entry when it changes |
| **Codec badge** | the device list shows the active codec and rate, for example `[aptX Adaptive 44.1 kHz]` |
| **Codec dialog** | in the device details, the media audio row opens a dialog with the codecs the device offers |
| **Audio codec entry** | the Connected devices page displays an *Audio codec* entry for the active A2DP device, showing the current codec and sample rate, with codec selection; a *Sample rate* row below it lets you choose one of the rates the device offers for the current codec (shown when there are at least two) |

The standalone entry exists because the device details are not always reachable: for devices
that also support LE Audio, Android hides the media audio row, and for devices with a companion
app the details page is defined by that app.

## How the selection behaves

* Only the codec type, and optionally the sample rate, is requested through the public
  `BluetoothA2dp.setCodecConfigPreference` API; every other field stays automatic. The Bluetooth
  stack decides, and Settings displays the configuration read back from the stack afterwards.
* Only codecs and sample rates that the stack reports as selectable for the device are offered.
* A selection applies to the current connection. After a reconnect the codec is negotiated again.
* With HD audio switched off, only SBC can be selected.
* While LE Audio is the active route for the device, no A2DP request is sent.
* Components that change the codec configuration themselves, such as a game mode, may later
  replace a manual choice.

This package contains no codec. The optional [`aptx-adaptive`](../aptx-adaptive/README.md)
module adds aptX Adaptive to the Bluetooth stack on its reference hardware; this package works
with or without it.

## Requirements

* A crDroid tree on branch **`16.0`** (Android 16). The exact reference commits are listed in
  [`NOTICE`](NOTICE).
* No device-specific code is involved. The series was built and used on the OnePlus 13.
* A backed-up source tree and device. Do not patch a tree while a build is running.

You only need **Git, the `.patch` files and a compatible crDroid source tree** to apply them.

---

## The patches

Apply in this order. Every path inside a patch is relative to its **target repository**, not
to the Android source root. Patches 2 to 4 need patch 1; patch 4 is applied after patch 3.

| # | File | Target repository | Scope |
|---|---|---|---|
| 1 | [crdroid_framework_settingslib_codec_status.patch](patches/crdroid_framework_settingslib_codec_status.patch) | `frameworks/base` | SettingsLib codec status and refresh |
| 2 | [crdroid_settings_bluetooth_codec_badges.patch](patches/crdroid_settings_bluetooth_codec_badges.patch) | `packages/apps/Settings` | Codec badges in the device list |
| 3 | [crdroid_settings_bluetooth_codec_menu.patch](patches/crdroid_settings_bluetooth_codec_menu.patch) | `packages/apps/Settings` | Codec dialog in the device details |
| 4 | [crdroid_settings_bluetooth_codec_entry.patch](patches/crdroid_settings_bluetooth_codec_entry.patch) | `packages/apps/Settings` | *Audio codec* entry with codec and sample-rate choice |

---

## How to Apply

### Method A: Automated Script (Recommended)

```bash
# 1. Dry-run check (simulates the whole series without modifying any files):
./apply-patches.sh --check /path/to/crdroid-source

# 2. Apply all patches:
./apply-patches.sh /path/to/crdroid-source

# 3. (Optional) To cleanly revert all patches later:
./apply-patches.sh --reverse /path/to/crdroid-source
```

The script simulates the whole series on a temporary copy of the affected files first — the
three `packages/apps/Settings` patches one on top of the other — and changes nothing if
anything does not fit. It refuses target repositories with uncommitted changes unless
`--allow-dirty` is given, and shows how each repository relates to the reference commit in
[`NOTICE`](NOTICE).

### Method B: Manual Application via Git

#### Apply one patch manually:
Replace both placeholders with **absolute paths**:

```sh
TARGET_REPO="/path/to/crdroid/frameworks/base"
PATCH_FILE="/path/to/codec-ui-patches/crdroid_framework_settingslib_codec_status.patch"
git -C "$TARGET_REPO" status --short
git -C "$TARGET_REPO" apply --check "$PATCH_FILE"
```

Back up local changes first. Only after the check succeeds:

```sh
git -C "$TARGET_REPO" apply "$PATCH_FILE"
git -C "$TARGET_REPO" diff --check
git -C "$TARGET_REPO" diff --stat
```

Use `git apply`, not `git am`, for these files. If a command fails, stop rather than continuing
with the next command.

### Apply all four patches

`ANDROID_ROOT` is the crDroid source root; `PATCH_DIR` is the directory **directly containing**
the four `.patch` files. Replace both placeholders. All four patches are checked before the
first is applied; this is not an atomic transaction.

```sh
(
set -eu
ANDROID_ROOT="/path/to/android-source"
PATCH_DIR="/path/to/codec-ui-patches"
patches="frameworks/base:crdroid_framework_settingslib_codec_status.patch
packages/apps/Settings:crdroid_settings_bluetooth_codec_badges.patch
packages/apps/Settings:crdroid_settings_bluetooth_codec_menu.patch
packages/apps/Settings:crdroid_settings_bluetooth_codec_entry.patch"
for item in $patches; do
    repository="${item%%:*}"
    patch="${item#*:}"
    git -C "$ANDROID_ROOT/$repository" apply --check "$PATCH_DIR/$patch"
done
for item in $patches; do
    repository="${item%%:*}"
    patch="${item#*:}"
    git -C "$ANDROID_ROOT/$repository" apply "$PATCH_DIR/$patch"
done
)
```

The three Settings patches change different files, so each check is meaningful on its own at
the reference commit. Stop on conflicts or an already-applied edition; do not force application. To undo, use
`git -C "$TARGET_REPO" apply --reverse "$PATCH_FILE"` in the reverse order of the table.

A patch file is not flashed directly: installing these changes requires a newly built ROM.

## Checking on the device

1. Connect a receiver and look at the badge in the device list: codec and rate must match what
   the device actually plays.
2. Open *Audio codec* on the Connected devices page, choose another codec and check that the
   badge and the entry show the new configuration after the stack has applied it.
3. Choose other sample rates in the *Sample rate* row; check the read-back each time.
4. Disconnect and reconnect: the codec is negotiated again and the entry follows.

## Licence and source baselines

These files are diffs against crDroid sources, which are licensed under the Apache License 2.0.
The full licence is included as [`LICENSE`](LICENSE). Preserve applicable upstream copyright and
attribution notices. See [`NOTICE`](NOTICE) for reference tree revisions and the disclaimer that
comes with flashing your own build.
