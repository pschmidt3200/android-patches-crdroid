# aptX Adaptive & aptX Lossless for crDroid 16.0 on the OnePlus 13

Patches that bring working **aptX Adaptive** — including **aptX Lossless** at 44.1 kHz and a
**low-latency mode for games** — to crDroid 16.0 (Android 16) on the OnePlus 13 (`dodge`, CPH2653) with a
Qualcomm FastConnect 7900 controller.

The Android Bluetooth stack can negotiate aptX Adaptive, but on this platform the parts that
actually make it *work* — the vendor-specific controller commands, the DSP mode, and the
sample-rate switch — need this integration in the reference crDroid source tree.

**ROM scope:** This package is currently intended only for **crDroid 16.0**.
Support for other ROMs has not been established.

> 🇩🇪 Diese Datei auf Deutsch: [README.de.md](README.de.md)

---

## What works

The baseline long-term observations were recorded with production revision v39.
The English publication edition translates identifiers and diagnostic text to English.
On 2026-10-01, it was built into crDroid 16.0 and verified on the reference device
(OnePlus 13 with FiiO BTR17), confirming initial 96 kHz high-quality negotiation,
dynamic switching to 44.1 kHz Lossless, and hardware DSP offload streaming with
0 Bluetooth crashes.

| | |
|---|---|
| **aptX Adaptive, 48/96 kHz** | negotiated, confirmed by the controller, audible |
| **aptX Lossless, 44.1 kHz** | sink reports LS with bitrate; switching to and from it needs no reconnect |
| **Low latency for games** | **117.55 ms vs 348.47 ms** over the real user path, both arms measured in one session |
| **Game start / exit** | switches to 48 kHz low latency on start, restores the previous configuration on exit — also when starting *out of* Lossless |
| **Codec menu** | shows the active codec; after a reconnect the full list is available immediately |
| **Long-term behaviour** | 181 logged hours within a 249-hour window: no Bluetooth/audio crashes in the available logs, device counter `Bluetooth crashed 0 times` at 114 h uptime, 203 STARTs / 204 STOPs with one missing log hour, and 234 of 234 mode changes accepted |

The observation window is incomplete; these results are not a universal reliability guarantee.
The FiiO showed no link-loss events in the covered logs. The Bose had eleven link/setup events,
two during playback, so this does not establish dropout-free operation on every receiver.

## What this does not do

Being explicit about the limits is the point of this section.

* **It does not make the Android audio path bit-transparent.** AudioFlinger mixes at 48000 Hz while
  the codec runs at 44100 Hz; the conversion happens in the DSP. For *lossless over the air* that is
  irrelevant, for *bit-perfect from file to ear* it is not. Doing it properly would need a dedicated
  A2DP output at codec rate, which touches the output path of every single playback — a deliberate
  non-goal here.
* **Codec bit-accuracy is the chip vendor's business** (Qualcomm) and cannot be verified from the host.
* **Only one sink has been fully measured** at 48 *and* 96 kHz (FiiO BTR17, QCC5181). A second one was
  not available: of the sinks at hand, one offers 44.1/48 kHz only and one no aptX Adaptive at all.
  Treat anything beyond the measured device as untested.
* **Latency work applies to aptX Adaptive, not to Lossless.** A value above 360 ms at 44.1 kHz is
  expected and is not a defect.

## Requirements

* Reference device: OnePlus 13 (`dodge`, CPH2653), Qualcomm **FastConnect 7900**.
  Other devices need separate integration and validation; sharing the controller is not sufficient.
* A crDroid tree on branch **`16.0`** (Android 16). The exact
  reference commits are listed in [`NOTICE`](NOTICE).
* A sink that actually supports aptX Adaptive — the patches will not fake it. Devices that do not
  offer it keep their previous codec, and the UI says so instead of claiming success.
* Snapdragon Sound R2.2 support in the vendor blobs for Lossless
* A backed-up source tree and device. Do not patch a tree while a build is running.

You only need **Git, the `.patch` files and a compatible crDroid source tree** to apply them.
No generator, additional project tooling or service is required. Normal ROM build dependencies
and the vendor-offload requirements still apply.

## Hardware & Device Compatibility

| Layer | Component | Status / Notes |
|---|---|---|
| **Reference Device** | **OnePlus 13** (`dodge`, CPH2653) | Fully verified reference platform (production revision v39). |
| **SoC / Controller** | Qualcomm **Snapdragon 8 Elite** (SM8750) w/ **FastConnect 7900** | Requires Qualcomm AIDL Audio HAL and DSP offload firmware. |
| **Other Devices** | — | **Untested.** The patches target crDroid 16.0; patch 1 sends FastConnect 7900 vendor commands and patch 6 is device-specific. A port is your own integration and validation work. |
| **Tested Audio Sinks** | **FiiO BTR17** (Qualcomm QCC5181) | Reference sink: 44.1 kHz Lossless, 48 / 96 kHz, 48 kHz low latency. |
| | **Bose QuietComfort Ultra 2** | Offers 44.1 / 48 kHz only (no 96 kHz); link/setup events were logged, see above. |

---

## Detailed Patch Breakdown: Who does what?

To understand how these patches work together, follow the audio chain from the application down to the hardware:

```text
[App / Game] 
    │
    ▼ (Patch 5: GameSpace detects gaming and triggers Low-Latency mode)
[AudioPolicy / AudioFlinger] 
    │
    ▼ (Patch 2: Enables aptX Adaptive in framework offload capabilities)
[Bluetooth Stack (btif / AIDL)] 
    │
    ▼ (Patch 1: Core native driver — configures DSP session without SW encoder)
[Qualcomm Hexagon DSP & Controller] 
    │
    ▼ (Patch 6: System properties enable Snapdragon Sound R2.2 feature flags)
[Wireless Transmission -> Headphone / DAC]
    ▲
    │ (Patch 3 & 4: SettingsLib & Settings UI display active codec badge)
[User Interface]
```

### 1. `crdroid_bluetooth_aptx_adaptive_native.patch`
* **Target:** `packages/modules/Bluetooth`
* **Source scope:** crDroid's Bluetooth module
* **Hardware portability:** **Qualcomm FastConnect-specific** (vendor controller commands); tested only on the OnePlus 13
* **Role:** **The Engine & Protocol Driver.**
* **What it does:** Allows aptX Adaptive offload session setup in crDroid without a software encoder binary and implements the native session initiation with Qualcomm's AIDL Audio HAL (`AptxAdaptiveConfiguration`). It negotiates AVDTP capabilities (44.1 kHz, 48 kHz, 96 kHz) and manages sample-rate switching directly with the DSP.
* **If omitted:** No aptX Adaptive session can ever start; the system falls back to standard aptX, AAC, or SBC.

### 2. `crdroid_framework_aptx_adaptive_offload.patch`
* **Target:** `frameworks/base`
* **Source scope:** crDroid framework code (`android.media.AudioSystem`); needs patch 1
* **Hardware portability:** no device-specific code; tested only on the OnePlus 13
* **Role:** **The System Gatekeeper.**
* **What it does:** Adds the audio format `AUDIO_FORMAT_APTX_ADAPTIVE` to `AudioSystem`, lists it with the other Bluetooth formats and maps it to the aptX Adaptive Bluetooth codec type.
* **If omitted:** The framework has no audio format for aptX Adaptive and cannot match the negotiated Bluetooth codec to an offload format.

### 3. `crdroid_framework_settingslib_codec_status.patch`
* **Target:** `frameworks/base` (`packages/SettingsLib`)
* **Source scope:** crDroid SettingsLib code
* **Hardware portability:** no device-specific code; tested only on the OnePlus 13
* **Role:** **The Internal State Bridge.**
* **What it does:** Adds `A2dpProfile.getCodecStatus()` and refreshes a device entry when the codec configuration changes (`ACTION_CODEC_CONFIG_CHANGED`).
* **If omitted:** Patch 4 does not build (it calls `getCodecStatus()`), and the device list does not update after a codec change.

### 4. `crdroid_settings_bluetooth_codec_badges.patch`
* **Target:** `packages/apps/Settings`
* **Source scope:** crDroid Settings code; **needs patch 3**
* **Hardware portability:** no device-specific code; tested only on the OnePlus 13
* **Role:** **The User Interface & Visual Badges.**
* **What it does:** Displays the active codec badge (e.g. *aptX Adaptive*, *aptX Lossless*, *96 kHz*) in the summary of a connected device in the Bluetooth device list, so the negotiated mode is visible at a glance.
* **If omitted:** Audio still works, but Settings displays a generic or blank codec label.

### 5. `crdroid_gamespace_bluetooth_gaming_audio.patch`
* **Target:** `packages/apps/GameSpace`
* **Source scope:** crDroid's GameSpace app; needs patch 1
* **Hardware portability:** no device-specific code; tested only on crDroid `16.0` / OnePlus 13
* **Role:** **Automatic Low-Latency Trigger.**
* **What it does:** Hooks into GameSpace game lifecycle events. When a game is launched, it automatically switches aptX Adaptive from High-Quality (~348 ms) to Low-Latency (~117 ms). When closing the game, it seamlessly restores the previous HQ or Lossless profile.
* **If omitted:** Gaming mode switching must be triggered manually or remains at standard latency.

### 6. `crdroid_aptx_r2_2_property.patch`
* **Target:** `device/oneplus/sm8750-common` (or your device's vendor property tree)
* **Source scope:** **device-specific template**
* **Role:** **Hardware & Vendor Configuration Flags.**
* **What it does:** Sets the necessary `persist.vendor.qcom.bluetooth.*` system properties required by the Qualcomm Bluetooth stack and DSP firmware to unlock Snapdragon Sound R2.2 and aptX Adaptive feature sets.
* **For other devices:** Copy these property definitions into your target device's `vendor.prop` or `device.mk`.

---

## The patches

Apply in this order. Every path inside a patch is relative to its **target repository**, not to the
Android source root — `framework/java/android/bluetooth/`, for example, belongs to the Bluetooth
repository. Do not stack these patches on top of an older edition or prototype.

| # | File | Target repository | Scope |
|---|---|---|---|
| 1 | [crdroid_bluetooth_aptx_adaptive_native.patch](patches/crdroid_bluetooth_aptx_adaptive_native.patch) | `packages/modules/Bluetooth` | Core Stack & HAL Session Driver |
| 2 | [crdroid_framework_aptx_adaptive_offload.patch](patches/crdroid_framework_aptx_adaptive_offload.patch) | `frameworks/base` | AudioPolicy Offload Routing |
| 3 | [crdroid_framework_settingslib_codec_status.patch](patches/crdroid_framework_settingslib_codec_status.patch) | `frameworks/base` | SettingsLib State & Events |
| 4 | [crdroid_settings_bluetooth_codec_badges.patch](patches/crdroid_settings_bluetooth_codec_badges.patch) | `packages/apps/Settings` | Settings UI Codec Badges |
| 5 | [crdroid_gamespace_bluetooth_gaming_audio.patch](patches/crdroid_gamespace_bluetooth_gaming_audio.patch) | `packages/apps/GameSpace` | Automatic Gaming Low-Latency Hook |
| 6 | [crdroid_aptx_r2_2_property.patch](patches/crdroid_aptx_r2_2_property.patch) | `device/oneplus/sm8750-common` | Vendor System Properties |

---

## How to Apply

### Method A: Automated Script (Recommended)

This repository includes a convenient helper script (`apply-patches.sh`) that verifies patch applicability and applies all patches in one step:

```bash
# 1. Dry-run check (simulates the whole series without modifying any files):
./apply-patches.sh --check /path/to/crdroid-source

# 2. Apply all patches:
./apply-patches.sh /path/to/crdroid-source

# 3. (Optional) To cleanly revert all patches later:
./apply-patches.sh --reverse /path/to/crdroid-source
```

What the script does before it changes anything:

* **It simulates the whole series** on a temporary copy of the affected files. The two
  `frameworks/base` patches are checked one on top of the other, not each against the untouched
  tree. If anything does not fit, nothing is changed (exit code 2).
* **It refuses target repositories with uncommitted changes** (exit code 4), so your own edits do
  not get mixed into the series. `--allow-dirty` overrides this on purpose. Reverting is exempt,
  because an applied series is itself an uncommitted change.
* **It shows how each repository relates to the reference commit** in [`NOTICE`](NOTICE):
  `matches reference`, `newer than reference` or `not in local history`. This is information
  only — a newer tree is not refused — but it is the first thing to look at when a patch fails.

Should it still abort mid-way (exit code 3, only possible if the tree changes during the run), it
lists the patches already processed and how to undo them.

---

### Method B: Manual Application via Git

You only need **Git, the `.patch` files and a compatible crDroid source tree** to apply them.
No generator or background service is required.

#### Apply one patch manually:
Select the target repository from the table or the patch's first header line. Replace both
placeholders with **absolute paths**:

```sh
TARGET_REPO="/path/to/crdroid/packages/modules/Bluetooth"
PATCH_FILE="/path/to/aptx-patches/crdroid_bluetooth_aptx_adaptive_native.patch"
git -C "$TARGET_REPO" status --short
git -C "$TARGET_REPO" apply --check "$PATCH_FILE"
```

Back up local changes first. Only after the check succeeds:

```sh
git -C "$TARGET_REPO" apply "$PATCH_FILE"
git -C "$TARGET_REPO" diff --check
git -C "$TARGET_REPO" diff --stat
```

`git apply --check` changes nothing. `git apply` changes source files; it does not create a commit
or install anything on the phone. The Bluetooth patch alone is not the complete feature bundle;
the other five files are listed in the table. Use `git apply`, not `git am`, for these files.
If a command fails, stop rather than continuing with the next command.

### Apply all six patches

`ANDROID_ROOT` is the crDroid source root; `PATCH_DIR` is the directory **directly containing**
the six `.patch` files. Replace both placeholders. Review `git status --short` in every target
repository first. All six patches are checked before the first is applied; this is not an atomic
transaction.

```sh
(
set -eu
ANDROID_ROOT="/path/to/android-source"
PATCH_DIR="/path/to/aptx-patches"
patches="packages/modules/Bluetooth:crdroid_bluetooth_aptx_adaptive_native.patch
frameworks/base:crdroid_framework_aptx_adaptive_offload.patch
frameworks/base:crdroid_framework_settingslib_codec_status.patch
packages/apps/Settings:crdroid_settings_bluetooth_codec_badges.patch
packages/apps/GameSpace:crdroid_gamespace_bluetooth_gaming_audio.patch
device/oneplus/sm8750-common:crdroid_aptx_r2_2_property.patch"
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

Stop on conflicts or an already-applied edition; do not force application or discard local changes.
Build through the ROM's normal device-specific workflow, then validate codec/rate negotiation,
controller acknowledgements, audible output, gaming transitions and reconnect behavior.

Patch 5 depends on GameSpace as shipped by crDroid 16.0. Apply the complete six-patch series
to the documented crDroid target. Other ROMs are outside this package's current scope.

### Undo, sync again and build

A successful forward check means the patch can be applied to the current tree. If it fails but
`git -C "$TARGET_REPO" apply --reverse --check "$PATCH_FILE"` succeeds, the tree already matches
the changes; do not apply them again. If both checks fail, possible causes include a different
source revision, partial changes or the wrong target repository. Review the hunks and diffs;
do not force application. `--reverse --check` only tests whether reversal is possible.

To undo deliberately, back up local changes and use
`git -C "$TARGET_REPO" apply --reverse "$PATCH_FILE"`. Reverse the table's order for the whole
bundle. Do not apply or undo patches during a running build.

Review `git diff --check` and the resulting diffs in every target repository, then build, test,
sign and install the ROM using its normal device-specific procedure. `repo sync` does not apply
this package automatically; repeat the forward/reverse checks and review after a sync. A patch
file is not flashed directly: installing these changes requires a newly built ROM.

## How it works, in one pass through the stack

A codec claim is only complete once the whole path has been looked at. In order:

1. **Capability exchange (AVDTP).** The sink advertises what it can do; the phone picks a
   configuration and the sink confirms it. For Lossless the relevant bits are the sample-rate mask
   and the vendor feature byte — the patch keeps the sink's own feature byte instead of overwriting
   it, which is what made the DSP produce sound rather than silence.
2. **Controller (vendor-specific commands).** Starting an offload stream on this controller needs a
   vendor command, and so does changing the mode of a *running* stream. The patch sends START/STOP
   around the session and `UPDATE_MODE` for changes in between, and only treats a mode as applied
   once the controller has acknowledged it. An unacknowledged state is reported as such in the UI
   instead of being shown as success.
3. **HAL / DSP.** The offload container is 24-bit; at 16-bit the DSP stays silent. The sink's
   configuration has to reach the DSP intact, otherwise the stream runs but produces nothing.
   This container width is not evidence of 24-bit Lossless or end-to-end bit transparency.
4. **Sample rate.** Low latency only takes effect at 48 kHz on this hardware. The patch therefore
   requests 48 kHz first and enables low latency only after that rate is confirmed — a game that
   starts, exits and restarts within 137 ms used to be enough to land low latency on a 44.1 kHz
   Lossless stream.
5. **Game start / exit.** GameSpace reports the transition; the patch sets rate and mode, and
   restores the previous configuration afterwards. Which apps count as games is the user's list,
   not this patch's business.

## Support Policy & Disclaimer

> [!IMPORTANT]
> * **Personal Project:** This is a private hobby project developed for personal use on specific hardware. It is **not** a commercially maintained software distribution.
> * **Device Support Limits:** Verification and fixes can only be performed on hardware I physically own (the OnePlus 13 reference device). Requests to port or troubleshoot other devices cannot be actively fulfilled.
> * **Builder Responsibility:** Applying custom patches and compiling ROMs requires technical knowledge. You are responsible for your own build, testing, and device recovery.

## Licence and source baselines

These files are diffs against crDroid sources, which are licensed under the Apache License
2.0. The full licence is included as [`LICENSE`](LICENSE). Preserve applicable upstream copyright
and attribution notices. See [`NOTICE`](NOTICE) for reference tree revisions and the disclaimer
that comes with flashing your own build. No proprietary encoder, firmware or vendor library is
included, and this package does not grant rights to redistribute those components.

## A note on the English wording

This package is an English-language patch edition. Apply all files from the same edition and
review them again after an upstream sync. Matching diff context does not replace a build and
device validation. Maintenance tooling and personal diagnostic logs are not part of this package.
