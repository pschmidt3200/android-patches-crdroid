# LE Audio Fixes v2.0

First edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; the final crDroid 16.0 edition is [`le-audio-fixes-v1.0`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/le-audio-fixes-v1.0) on branch [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0).

LE Audio fixes: receivers that never answer the stack's grouped attribute read can connect, a chosen sample rate or frame duration reaches the stream, and 32 kHz and 24 kHz / 7.5 ms become available for media. Reference platform: **OnePlus 13** with **FiiO BTR17** (LC3 over LE Audio).

## Changes from the crDroid 16.0 edition

* Android 17 removed the grouped-read flag and its callers. `crdroid_bluetooth_le_codec_preference_match.patch` now restores the flag declaration and the LE Audio / Volume Control gates; `crdroid_build_release_le_ase_read_multi_off.patch` disables the flag through `bp4a`, inherited by the `cp2a` release configuration.
* The 32 kHz / 24 kHz media patch is unchanged.

## Status on crDroid 17.0

On 2026-10-20 the maintainer reported a running 17.0 ROM with Bluetooth playback and an LC3 connection to a FiiO receiver; this does not revalidate every rate, frame duration or gaming transition.

Part of the maintainer's crDroid 17.0 ROM build of 2026-10-22 for the OnePlus 13, made from this repository at commit `4bdecab`; builds of this series have been running on the device since 2026-10-20.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/le-audio-fixes-v2.0/le-audio-fixes) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `build/release` | `c85f4aebe46714235599a9bd6430a0fe30c6e8d5` |
| `packages/modules/Bluetooth` | `f3fb97e5f1ddb23e4674d60b91c4f6a4895d9d6b` |

```bash
git switch --detach le-audio-fixes-v2.0
bash le-audio-fixes/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Erste Fassung für crDroid 17.0: Android 17 entfernte das Flag für gesammelte Attributabfragen; der Patch stellt Deklaration und Abfragen wieder her. LC3-Verbindung am Gerät gemeldet, Teil des 17.0-Builds vom 22.10.2026.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
