# aptX Adaptive & aptX Lossless for crDroid / LineageOS on the OnePlus 13

Patches that bring working **aptX Adaptive** — including **aptX Lossless** at 44.1 kHz and a
**low-latency mode for games** — to an AOSP-based ROM on the OnePlus 13 (`dodge`, CPH2653) with a
Qualcomm FastConnect 7900 controller.

The Android Bluetooth stack can negotiate aptX Adaptive, but on this platform the parts that
actually make it *work* — the vendor-specific controller commands, the DSP mode, and the
sample-rate switch — are not wired up in AOSP. These patches wire them up.

> 🇩🇪 Diese Datei auf Deutsch: [README.de.md](README.de.md)

---

## What works

These results were measured on the reference device with production revision v39.
The English publication edition changes identifiers and diagnostic text. It has passed
parity and application checks, but has not been built and tested on a device separately.

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
* An AOSP-based tree, Android 16 / LineageOS 23.2 generation
* A sink that actually supports aptX Adaptive — the patches will not fake it. Devices that do not
  offer it keep their previous codec, and the UI says so instead of claiming success.
* Snapdragon Sound R2.2 support in the vendor blobs for Lossless
* A backed-up source tree and device. Do not patch a tree while a build is running.

## The patches

Apply in this order. Every path inside a patch is relative to its **target repository**, not to the
Android source root.

| # | File | Target repository |
|---|---|---|
| 1 | `patches/crdroid_bluetooth_aptx_adaptive_native.patch` | `packages/modules/Bluetooth` |
| 2 | `patches/crdroid_framework_aptx_adaptive_offload.patch` | `frameworks/base` |
| 3 | `patches/crdroid_framework_settingslib_codec_status.patch` | `frameworks/base` |
| 4 | `patches/crdroid_settings_bluetooth_codec_badges.patch` | `packages/apps/Settings` |
| 5 | `patches/crdroid_gamespace_bluetooth_gaming_audio.patch` | `packages/apps/GameSpace` |
| 6 | `patches/crdroid_aptx_r2_2_property.patch` | `device/oneplus/sm8750-common` |

You only need **Git, the `.patch` files and a compatible crDroid source tree** to apply them.
No generator, additional project tooling or service is required. The files may live in any
directory, and these commands can run from any working directory. Normal ROM build dependencies
and the vendor-offload requirements still apply.

### Apply one patch

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

Patch 5 depends on crDroid's GameSpace. On a ROM without it, omit that entry from both check and
apply passes. Patches 1–4 and 6 cover the codec/offload integration, without automatic game-start
switching; compatibility with that ROM still needs separate validation.

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

## Licence and source baselines

These files are diffs against AOSP / crDroid sources, which are licensed under the Apache License
2.0. The full licence is included as [`LICENSE`](LICENSE). Preserve applicable upstream copyright
and attribution notices. See [`NOTICE`](NOTICE) for reference tree revisions and the disclaimer
that comes with flashing your own build. No proprietary encoder, firmware or vendor library is
included, and this package does not grant rights to redistribute those components.

## A note on the English wording

This package is an English-language patch edition. Apply all files from the same edition and
review them again after an upstream sync. Matching diff context does not replace a build and
device validation. Maintenance tooling and personal diagnostic logs are not part of this package.
