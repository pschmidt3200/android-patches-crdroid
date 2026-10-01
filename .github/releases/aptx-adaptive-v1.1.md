# aptX Adaptive & Lossless v1.1

Maintenance release of the English source-patch edition for **crDroid 16.0 / Android 16**.
Reference platforms: **OnePlus 13** (`dodge`, CPH2653) and **OnePlus Pad 3 / Pad 2 Pro**
(`erhai`, OPD2415), SM8750 / Qualcomm FastConnect 7900, with **FiiO BTR17**.
Implementation baseline: `f62057a0120f044d65278770fad17af96f0fdc5c`.

## Changes from v1.0

* Documents the 2026-10-01 ROM/device acceptance of the English edition on both
  reference platforms, including 96/48 kHz Adaptive, dynamic 44.1 kHz Lossless
  selection and hardware DSP offload.
* Adds the second reference platform to the requirements and acceptance record.
* Uses the common maintainer template and module metadata to generate the
  standalone installer, with the same executable installer behaviour.
* Retains all six patch payloads unchanged. The original v1.0 tag/release stays
  available as the previous reference; use this release for the current module edition.

## Requirements and source baselines

Compatible device audio-provider/DSP firmware remains required. Other hardware
needs separate integration and testing. No ROM image, codec binaries or vendor
firmware are included. Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/aptx-adaptive-v1.1/aptx-adaptive).

| Target repository | NOTICE reference commit |
|---|---|
| `packages/modules/Bluetooth` | `c575db642364a8e3e2f9878d2fdd55dc4451230e` |
| `frameworks/base` | `a7b0e5e188fb72a566328bfed0e0412ddb7850e2` |
| `packages/apps/GameSpace` | `ca3a15a2cb779339a4faff22f1ab5f59e59f7d85` |
| `packages/apps/Settings` | `62faa70985307e4e5fca0c7c838f11dba0b2c4ab` |
| `device/oneplus/sm8750-common` | `30beb69ed08ff93111c6e4bfed0d1b8f12fc9dc2` |

```bash
git switch --detach aptx-adaptive-v1.1
bash aptx-adaptive/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at
these commits and current `16.0` branches. The device record concerns the
documented reference setup; different devices, firmware and source revisions
need their own acceptance. Long-run findings are distinguished from the
English-edition acceptance in the module README.

## Deutsch

Aktuelle aptX-V1-Fassung mit dokumentierter Geräteabnahme auf OnePlus 13 und
OnePlus Pad 3, gemeinsamer Installer-Vorlage und unveränderten Patchdateien.
Die alte v1.0 bleibt als historische Referenz erhalten. Nur für crDroid 16.0;
andere Hardware und Quellstände separat prüfen.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
