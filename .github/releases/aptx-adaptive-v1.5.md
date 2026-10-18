# aptX Adaptive & Lossless v1.5

> **Superseded.** This is an older release. The current edition is [aptX Adaptive v1.6](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/aptx-adaptive-v1.6);
> use it unless you need exactly this revision. Deutsch: Ältere Version, aktuell ist aptX Adaptive v1.6.

Behaviour update for **crDroid 16.0 / Android 16**.
Reference platform: **OnePlus 13** (`dodge`, CPH2653), SM8750 / Qualcomm FastConnect 7900,
with **FiiO BTR17**.

## Changes from v1.4

* **Mode commands follow the stream state.** The first aptX Adaptive mode of a stream is
  sent only after the start has been reported to the audio HAL, and not at all while the
  stream is already being suspended or stopped. Later mode requests (latency changes,
  game start/exit) pass through the Bluetooth stack's per-device state machine, so they
  reach the controller only for a running stream.
* **Stereo is the default channel mode.** Joint Stereo is offered only when
  `persist.bluetooth.aptx_adaptive.offer_joint_stereo` is `true`.
* The feature-byte negotiation and R2.2 reporting of v1.4 are unchanged.

Device check of this edition: built into crDroid 16.0 and checked on the reference device —
playback at 44.1 kHz Lossless and 96 kHz, and switching between the two. Low-latency
switching was not measured again for this edition.

**Known limitation:** the TWS channel modes of aptX Adaptive (TWS stereo, TWS mono,
TWS+) are not offered. True-wireless earbuds tested here use the regular stereo mode
and are not affected; a sink that offers only TWS modes falls back to another codec.

## Requirements and source baselines

Compatible device audio-provider/DSP firmware remains required. Other hardware
needs separate integration and testing. No ROM image, codec binaries or vendor
firmware are included. Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/aptx-adaptive-v1.5/aptx-adaptive).

| Target repository | NOTICE reference commit |
|---|---|
| `packages/modules/Bluetooth` | `c575db642364a8e3e2f9878d2fdd55dc4451230e` |
| `frameworks/base` | `a7b0e5e188fb72a566328bfed0e0412ddb7850e2` |
| `packages/apps/GameSpace` | `2fecfaa6e963a288048dceedc6520f12b0116cd2` |
| `device/oneplus/sm8750-common` | `30beb69ed08ff93111c6e4bfed0d1b8f12fc9dc2` |

```bash
git switch --detach aptx-adaptive-v1.5
bash aptx-adaptive/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at
these commits and current `16.0` branches. The device record concerns the
documented reference setup; different devices, firmware and source revisions
need their own acceptance.

## Deutsch

Verhaltensanpassung: Moduswechsel folgen jetzt dem Stream-Zustand. Der erste Modus eines
Streams geht erst nach der gemeldeten Startfreigabe an den Controller, spätere Wechsel laufen
über die Zustandsmaschine des Bluetooth-Stacks und erreichen den Controller nur bei laufendem
Stream. Standard-Kanalmodus ist Stereo; Joint Stereo nur per Property. Geprüft: Wiedergabe
bei 44,1 kHz Lossless und 96 kHz sowie der Wechsel dazwischen; Low Latency für diese Fassung
nicht neu gemessen.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
