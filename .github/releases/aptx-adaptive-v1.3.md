# aptX Adaptive & Lossless v1.3

Modular decoupling release for **crDroid 16.0 / Android 16**.
Reference platforms: **OnePlus 13** (`dodge`, CPH2653) and **OnePlus Pad 3 / Pad 2 Pro**
(`erhai`, OPD2415), SM8750 / Qualcomm FastConnect 7900, with **FiiO BTR17**.

## Changes from v1.2

* Decouples the Bluetooth codec selection and status UI into the standalone
  [`bluetooth-codec-ui`](https://github.com/pschmidt3200/android-patches-crdroid/tree/main/bluetooth-codec-ui)
  module.
* Removes previous Settings patches from this package. The module now contains exclusively
  the Bluetooth audio stack, AudioPolicy framework offload, GameSpace hook, and device tree properties.
* Keeps audio streaming, hardware DSP offload, and dynamic rate switching fully intact.

## Requirements and source baselines

Compatible device audio-provider/DSP firmware remains required. Other hardware
needs separate integration and testing. No ROM image, codec binaries or vendor
firmware are included. Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/aptx-adaptive-v1.3/aptx-adaptive).

| Target repository | NOTICE reference commit |
|---|---|
| `packages/modules/Bluetooth` | `c575db642364a8e3e2f9878d2fdd55dc4451230e` |
| `frameworks/base` | `a7b0e5e188fb72a566328bfed0e0412ddb7850e2` |
| `packages/apps/GameSpace` | `2fecfaa6e963a288048dceedc6520f12b0116cd2` |
| `device/oneplus/sm8750-common` | `30beb69ed08ff93111c6e4bfed0d1b8f12fc9dc2` |

```bash
git switch --detach aptx-adaptive-v1.3
bash aptx-adaptive/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at
these commits and current `16.0` branches. The device record concerns the
documented reference setup; different devices, firmware and source revisions
need their own acceptance.

## Deutsch

Entkoppeltes aptX-Modul: Benutzeroberfläche und Codec-Auswahl wurden vollständig in das
separate Modul `bluetooth-codec-ui` ausgegliedert. Dieses Modul umfasst rein den Audio-Stack,
AudioPolicy-Offload, GameSpace-Hook und Device-Tree-Konfiguration.
Hardware-Streaming und Offload unverändert verifiziert auf OnePlus 13 und OnePlus Pad 3.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
