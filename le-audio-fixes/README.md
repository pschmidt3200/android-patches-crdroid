# LE Audio fixes for crDroid 16.0

Three fixes that make LE Audio usable with receivers such as the FiiO BTR17:

1. **Connection** — receivers that advertise EATT but never answer the stack's grouped attribute
   read can connect at all (one build-time flag value).
2. **Codec preference** — a chosen sample rate or frame duration actually reaches the stream instead
   of being stored and ignored (stack fix).
3. **More media configurations** — 32 kHz (7.5 and 10 ms) and 24 kHz / 7.5 ms become available for
   media playback (configuration list).

**ROM scope:** This package is currently intended only for **crDroid 16.0** (Android 16).
Support for other ROMs has not been established.

German version: [README.de.md](README.de.md)

---

## What it changes

| Patch | Target repository | Change |
|---|---|---|
| `crdroid_build_release_le_ase_read_multi_off.patch` | `build/release` | sets `com.android.bluetooth.flags.le_ase_read_multiple_variable` to `DISABLED` for the release configuration `bp4a`; no source change |
| `crdroid_bluetooth_le_codec_preference_match.patch` | `packages/modules/Bluetooth` | the ASE configuration matcher treats preference fields that are not set (and a channel count of 0) as "any", and compares the requested frame duration with the candidate |
| `crdroid_bluetooth_le_media_32khz.patch` | `packages/modules/Bluetooth` | appends eight existing LC3 sink configurations (32 kHz at 7.5/10 ms, 24 kHz at 7.5 ms) to the end of the Media scenario |

No driver, codec implementation or Settings source is touched. A user interface for choosing the
codec, sample rate and frame duration is provided by the separate
[`bluetooth-codec-ui`](../bluetooth-codec-ui/) module; privileged system apps can also use the
system API `BluetoothLeAudio.setCodecConfigPreference`.

## 1. Connection: grouped attribute reads

When the flag is enabled, the LE Audio client and Volume Control send ATT *Read Multiple Variable
Length* to any peer that advertises EATT. This saves round trips and is a sensible optimisation —
as long as the peer answers.

Some receivers advertise EATT but never answer that specific request. The stack then waits for the
response, times out after about 30 seconds and drops the link. The connection never reaches the
`Connected` state, so LE Audio appears simply broken while Bluetooth Classic on the same device
keeps working.

Measured on a FiiO BTR17 (QCC5181) with crDroid 16.0 on a OnePlus 13:

| | Before | After |
|---|---|---|
| Grouped reads sent / answered | 8 / 0 | — |
| Connection result | timeout after ~30 s, link dropped | `STATE_CONNECTED` after **264 ms** |
| `LeAudioStateMachine` | never reached `Connected` | `Connected` |

The flag is `READ_ONLY`. On the device it can be read but not changed:

```
$ adb shell aflags list | grep le_ase_read_multiple_variable
com.android.bluetooth.flags.le_ase_read_multiple_variable   enabled - default read-only
```

The value inherited from `bp1a` is `ENABLED` / `READ_ONLY`, so the only way to change it is at build
time. One value covers both callers — the LE Audio client and Volume Control.

## 2. Codec preference: the matcher

A codec preference (for example 24 kHz, or 7.5 ms instead of 10 ms) is stored by the stack, but the
function that checks whether an ASE configuration matches the preference rejected every candidate:

* it required every preference field to be set, although a preference normally sets only some of
  them (for example only the sample rate);
* it compared a channel count of 0 ("any") exactly;
* it compared the frame duration of the candidate with itself instead of with the request.

The stream therefore stayed on the default configuration (48 kHz / 10 ms) while the preference
reported the new value. The patch treats fields that are not set, and a channel count of 0, as
"any", and compares the requested frame duration with the candidate. The checks that every ASE of
a candidate has a configuration and that the topology fits stay unchanged.

## 3. Media configurations: 32 kHz and 24 kHz / 7.5 ms

The stack chooses media configurations only from the list of the `Media` scenario. That list
contained no 32 kHz sink configuration and no 24 kHz / 7.5 ms one, although both exist in the
stack's configuration catalogue and are used by other scenarios. A preference for them could not
be fulfilled and fell back to 48 kHz / 10 ms.

The patch appends eight existing configurations to the end of the `Media` list — one stereo CIS and
two mono CIS variants each:

| Configuration | Sample rate | Frame | Octets per frame |
|---|---|---|---|
| `…Lc3_32_1_Low_Latency` | 32 kHz | 7.5 ms | 60 |
| `…Lc3_32_2_Low_Latency` | 32 kHz | 10 ms | 80 |
| `…Lc3_24_1_Low_Latency` | 24 kHz | 7.5 ms | 45 |

Because they are appended at the end, the default choice without a preference does not change. A
single mono ASE at 24 kHz / 7.5 ms has no definition in the catalogue and is not added.

Measured on the same setup (LC3, hardware offload, media context), each step with clean audio:

| Preference | Active stream configuration | SDU |
|---|---|---:|
| 48 kHz / 10 ms (default) | `One-TwoChan-SnkAse-Lc3_48_4_High_Reliability` | 240 |
| 48 kHz / 7.5 ms | `One-TwoChan-SnkAse-Lc3_48_3_High_Reliability` | 180 |
| 24 kHz / 7.5 ms | `One-TwoChan-SnkAse-Lc3_24_1_Low_Latency` | 90 |
| 32 kHz / 7.5 ms | `One-TwoChan-SnkAse-Lc3_32_1_Low_Latency` | 120 |
| 32 kHz / 10 ms | `One-TwoChan-SnkAse-Lc3_32_2_Low_Latency` | 160 |

## Prerequisites and scope

* **Check which release configuration your build selects.** The flag file is placed in the `bp4a`
  directory. A build that selects a different release configuration will not read it. On a
  LineageOS-style tree the value comes from `vendor/lineage/vars/aosp_target_release`. The
  directory collects its values by glob, so no further registration is needed.
* **Audio needs a working vendor path.** Whether LE Audio produces sound depends on your vendor
  audio path. On Qualcomm platforms the LE offload path must be registered, otherwise the audio HAL
  cannot open the `bt-ble` device and no stream is created.
* **The receiver and the audio DSP decide what is possible.** The configuration list only offers
  candidates; a configuration is used only if the receiver supports it and the platform can run it.
  Verified with the FiiO BTR17 only; other receivers need their own check.
* **You may not need the flag.** Receivers that answer grouped reads correctly work with the flag
  enabled and keep the round-trip savings. The two stack patches are independent of the flag.
* **Not verified:** the read-back right after a reboot or reconnection, 16 kHz, single mono
  ASEs, and other receivers.

## Verification

After building and flashing:

```bash
# 1. the flag must report "disabled"
adb shell aflags list | grep le_ase_read_multiple_variable

# 2. connect the receiver over LE Audio and start playback, then check the stream
adb shell "dumpsys bluetooth_manager | grep -E 'name=LeAudioStateMachine state=|Current state:|Active config:|Stream config:'"
```

Expected: the flag reports `disabled`, `LeAudioStateMachine` reaches `state=Connected`, and after
choosing a sample rate or frame duration, `Active config` and `Stream config` name a configuration
with that rate and frame (for example `Lc3_24_1` for 24 kHz / 7.5 ms).

If you have more than one source paired to the receiver, disconnect the others first. Dual-mode
receivers hold two links, and a second source changes what the receiver reports and displays.

## Applying

```bash
git -C build/release apply --check le-audio-fixes/patches/crdroid_build_release_le_ase_read_multi_off.patch
git -C build/release apply       le-audio-fixes/patches/crdroid_build_release_le_ase_read_multi_off.patch
git -C packages/modules/Bluetooth apply --check le-audio-fixes/patches/crdroid_bluetooth_le_codec_preference_match.patch
git -C packages/modules/Bluetooth apply       le-audio-fixes/patches/crdroid_bluetooth_le_codec_preference_match.patch
git -C packages/modules/Bluetooth apply --check le-audio-fixes/patches/crdroid_bluetooth_le_media_32khz.patch
git -C packages/modules/Bluetooth apply       le-audio-fixes/patches/crdroid_bluetooth_le_media_32khz.patch
```

Paths inside the patches are relative to their target repository, not to the Android source root.
The installer script `apply-patches.sh` does the same with the checks included.

See [NOTICE](NOTICE) for upstream references, licensing and the application checklist.
