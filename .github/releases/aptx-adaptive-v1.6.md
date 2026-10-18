# aptX Adaptive & Lossless v1.6

Behaviour update for **crDroid 16.0 / Android 16**.
Reference platform: **OnePlus 13** (`dodge`, CPH2653), SM8750 / Qualcomm FastConnect 7900,
with **FiiO BTR17**.

## Changes from v1.5

* **Suspend order.** When a running aptX Adaptive stream is suspended, the AVDTP SUSPEND is
  sent to the sink first and the controller offload is stopped right after it.
  `persist.bluetooth.aptx_adaptive.suspend_before_offload_stop=false` restores the previous
  order (offload stop first) without a rebuild. Closing a stream and the other codecs keep
  their order.
* Mode commands following the stream state, Stereo as the default channel mode, the
  feature-byte negotiation and R2.2 reporting are unchanged from v1.5.

Device check of this edition: built into crDroid 16.0 and checked on the reference device —
300 pause/resume cycles at 96 kHz with the new order in the HCI log, and playback at 44.1 kHz.
Low-latency switching was not measured again for this edition.

**Known limitation:** the TWS channel modes of aptX Adaptive (TWS stereo, TWS mono,
TWS+) are not offered. True-wireless earbuds tested here use the regular stereo mode
and are not affected; a sink that offers only TWS modes falls back to another codec.

## Requirements and source baselines

Compatible device audio-provider/DSP firmware remains required. Other hardware
needs separate integration and testing. No ROM image, codec binaries or vendor
firmware are included. Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/aptx-adaptive-v1.6/aptx-adaptive).

| Target repository | NOTICE reference commit |
|---|---|
| `packages/modules/Bluetooth` | `c575db642364a8e3e2f9878d2fdd55dc4451230e` |
| `frameworks/base` | `a7b0e5e188fb72a566328bfed0e0412ddb7850e2` |
| `packages/apps/GameSpace` | `2fecfaa6e963a288048dceedc6520f12b0116cd2` |
| `device/oneplus/sm8750-common` | `30beb69ed08ff93111c6e4bfed0d1b8f12fc9dc2` |

```bash
git switch --detach aptx-adaptive-v1.6
bash aptx-adaptive/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at
these commits and current `16.0` branches. The device record concerns the
documented reference setup; different devices, firmware and source revisions
need their own acceptance.

## Deutsch

Verhaltensanpassung: Beim Pausieren eines laufenden aptX-Adaptive-Streams geht zuerst AVDTP
SUSPEND an die Senke, direkt danach wird der Offload im Controller gestoppt.
`persist.bluetooth.aptx_adaptive.suspend_before_offload_stop` auf `false` stellt die bisherige
Reihenfolge ohne Neubau wieder her; Schließen und andere Codecs bleiben unverändert. Geprüft:
300 Pause/Wiedergabe-Zyklen bei 96 kHz mit der neuen Reihenfolge im HCI-Mitschnitt sowie Ton
bei 44,1 kHz; Low Latency für diese Fassung nicht neu gemessen.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
