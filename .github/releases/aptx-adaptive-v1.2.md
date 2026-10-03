# aptX Adaptive & Lossless v1.2

Maintenance and license-neutralization release for **crDroid 16.0 / Android 16**.
Reference platforms: **OnePlus 13** (`dodge`, CPH2653) and **OnePlus Pad 3 / Pad 2 Pro**
(`erhai`, OPD2415), SM8750 / Qualcomm FastConnect 7900, with **FiiO BTR17**.

## Changes from v1.1

* Neutralizes license headers in newly added Bluetooth files (`a2dp_vendor_aptx_adaptive.cc`,
  `.h`, `constants.h`) under Apache 2.0, removing inaccurate AOSP copyright attribution lines.
* Documents controller vendor command opcodes and session parameters (VSQC `0xFC0A`) as
  live HCI protocol observation on lawfully acquired reference hardware for the purpose of interoperability.
* Formulates purpose and host-side integration in the open Android Bluetooth stack without distributing
  proprietary codec algorithms, vendor firmware or binaries.
* Retains verified audio streaming and offload behavior identical to v1.1 and the productive v39 baseline.

## Requirements and source baselines

Compatible device audio-provider/DSP firmware remains required. Other hardware
needs separate integration and testing. No ROM image, codec binaries or vendor
firmware are included. Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/aptx-adaptive-v1.2/aptx-adaptive).

| Target repository | NOTICE reference commit |
|---|---|
| `packages/modules/Bluetooth` | `c575db642364a8e3e2f9878d2fdd55dc4451230e` |
| `frameworks/base` | `a7b0e5e188fb72a566328bfed0e0412ddb7850e2` |
| `packages/apps/GameSpace` | `ca3a15a2cb779339a4faff22f1ab5f59e59f7d85` |
| `packages/apps/Settings` | `62faa70985307e4e5fca0c7c838f11dba0b2c4ab` |
| `device/oneplus/sm8750-common` | `30beb69ed08ff93111c6e4bfed0d1b8f12fc9dc2` |

```bash
git switch --detach aptx-adaptive-v1.2
bash aptx-adaptive/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at
these commits and current `16.0` branches. The device record concerns the
documented reference setup; different devices, firmware and source revisions
need their own acceptance.

## Deutsch

Aktualisierte aptX-Fassung mit neutralisierten Apache-2.0-Dateiköpfen, dokumentierter
HCI-Interoperabilität zur offenen Host-seitigen Anbindung und sachlicher Zweck-Dokumentation.
Geräteabnahme auf OnePlus 13 und OnePlus Pad 3 unverändert verifiziert.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
