# aptX Adaptive & Lossless v1.0

English source-patch edition for **crDroid 16.0 / Android 16**, with **OnePlus 13
(`dodge`, CPH2653)** as the reference device. Patch commit:
`d3117d5e066eabf102a8d5e199201bb20d988734`.

Six patches cover Bluetooth controller/session setup, framework offload configuration,
Settings codec display, GameSpace audio profiles and the device Bluetooth overlay.
They integrate aptX Adaptive, 44.1 kHz Lossless and 48 kHz low latency for games with
the device's existing compatible Qualcomm audio provider and DSP firmware.

## Requirements and use

This is a source-patch release for ROM builders. No ROM image, codec binaries or
vendor firmware are included. Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/aptx-adaptive-v1.0/aptx-adaptive)
and use every module file from the same tag. Hardware support beyond the documented
reference device is untested.

```bash
git clone https://github.com/pschmidt3200/android-patches-crdroid.git
cd android-patches-crdroid
git switch --detach aptx-adaptive-v1.0
bash aptx-adaptive/apply-patches.sh --check /path/to/android/source
```

## Source baselines

| Target repository | Reference commit |
|---|---|
| `packages/modules/Bluetooth` | `c575db642364a8e3e2f9878d2fdd55dc4451230e` |
| `frameworks/base` | `a7b0e5e188fb72a566328bfed0e0412ddb7850e2` |
| `packages/apps/GameSpace` | `ca3a15a2cb779339a4faff22f1ab5f59e59f7d85` |
| `packages/apps/Settings` | `62faa70985307e4e5fca0c7c838f11dba0b2c4ab` |
| `device/oneplus/sm8750-common` | `30beb69ed08ff93111c6e4bfed0d1b8f12fc9dc2` |

## Validation and limits

Publication requires the module structure and synthetic application tests, plus
real check/apply/reverse-check/reverse roundtrips against both these NOTICE commits
and the current `16.0` branch. Every temporary source repository must be clean afterwards.

**The English edition has not been built into a ROM or separately tested on a device.**
The production-device results in the module README refer to production revision v39;
they do not establish device acceptance of this translated edition. Successful source
checks establish applicability and rollback only.

## Deutsch

Sechs Quellcode-Patches für crDroid 16.0, Referenzgerät OnePlus 13. Voraussetzungen
und Anwendung stehen in der [deutschen Modul-Anleitung](https://github.com/pschmidt3200/android-patches-crdroid/blob/aptx-adaptive-v1.0/aptx-adaptive/README.de.md).
Die englische Fassung ist auf Anwendung und Rücknahme geprüft; ein eigener ROM-Build
und Gerätetest dieser Fassung stehen noch aus. Alle Dateien aus demselben Tag verwenden.

Apache License 2.0; preserve the included LICENSE and NOTICE and upstream file notices.
