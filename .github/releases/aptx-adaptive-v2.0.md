# aptX Adaptive v2.0

First edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; the final crDroid 16.0 edition is [`aptx-adaptive-v1.6`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/aptx-adaptive-v1.6) on branch [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0).

aptX Adaptive and aptX Lossless for the Bluetooth stack, the AudioPolicy framework offload and the GameSpace low-latency hook. Reference platform: **OnePlus 13**, SM8750 / Qualcomm FastConnect 7900, with **FiiO BTR17**.

## Changes from the crDroid 16.0 edition

* Native stack, framework offload and GameSpace audio are ported to Android 17.
* Android 17 gives legacy codec slot 7 to LHDC, so aptX Adaptive moves to extension slot 8 (vendor codec ID `0x00ad00d7ff`) across the native stack, both Java codec factories and the framework.
* The device-tree property patch is unchanged.

## Status on crDroid 17.0

On 2026-10-20 the maintainer reported working Bluetooth playback on a running 17.0 ROM; this does not revalidate every codec, rate, frame duration or gaming transition.

Part of the maintainer's crDroid 17.0 ROM build of 2026-10-22 for the OnePlus 13, made from this repository at commit `4bdecab`; builds of this series have been running on the device since 2026-10-20.

Compatible device audio-provider/DSP firmware remains required. No codec binaries or vendor firmware are included.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/aptx-adaptive-v2.0/aptx-adaptive) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `packages/modules/Bluetooth` | `f3fb97e5f1ddb23e4674d60b91c4f6a4895d9d6b` |
| `frameworks/base` | `c2382c14b024f5701071d31d9cc8fe1401dc9a88` |
| `packages/apps/GameSpace` | `6ee68e38389c30454e5626aa9a048d2617542382` |
| `device/oneplus/sm8750-common` | `c63ac897067e072fd6bb9306a5c0c8aa6c1b4d11` |

```bash
git switch --detach aptx-adaptive-v2.0
bash aptx-adaptive/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Erste Fassung für crDroid 17.0: Stack, Framework-Offload und GameSpace-Audio portiert; aptX Adaptive nutzt unter Android 17 den Erweiterungsplatz 8 (Platz 7 ist LHDC). Bluetooth-Wiedergabe am Gerät gemeldet, Teil des 17.0-Builds vom 22.10.2026; nicht jede Codec-Konfiguration einzeln geprüft.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
