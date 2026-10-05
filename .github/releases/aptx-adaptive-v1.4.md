# aptX Adaptive & Lossless v1.4

Bug-fix release for **crDroid 16.0 / Android 16**.
Reference platform: **OnePlus 13** (`dodge`, CPH2653), SM8750 / Qualcomm FastConnect 7900,
with **FiiO BTR17** and **Bose QC Ultra 2 Earbuds**.

## Changes from v1.3

* **Fix:** the feature byte of a locally selected R2.2 (44.1 kHz) configuration now
  confirms only features both sides support. Previously the sink's lower feature bits
  were passed through unfiltered, so a sink advertising a feature the source lacks
  could have it confirmed. No change for the tested receivers: FiiO BTR17 `0x82 -> 0x92`,
  Bose QC Ultra 2 `0x87 -> 0x97`.
* **New:** the sink's R2.2 support is reported to the framework in `codec_specific_3`
  (bits 12-13: `0x2000` available, `0x1000` not available), only with the R2.2 property
  enabled.
* Feature negotiation and capability layout verified against Qualcomm's public
  CodeLinaro Bluetooth stack.

Device check of this edition: FiiO BTR17 negotiates 44.1 kHz with feature byte `0x92` and
plays aptX Lossless with sound; Bose QC Ultra 2 selects `0x97` and plays with sound;
`codec_specific_3` reads `0x2000` on both. The long-term record of the previous edition covers the
unchanged behaviour of these receivers; this edition has a short device check, not a
new long-term run.

**Known limitation:** the TWS channel modes of aptX Adaptive (TWS stereo, TWS mono,
TWS+) are not offered. True-wireless earbuds tested here use the regular stereo mode
and are not affected; a sink that offers only TWS modes falls back to another codec.

## Requirements and source baselines

Compatible device audio-provider/DSP firmware remains required. Other hardware
needs separate integration and testing. No ROM image, codec binaries or vendor
firmware are included. Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/aptx-adaptive-v1.4/aptx-adaptive).

| Target repository | NOTICE reference commit |
|---|---|
| `packages/modules/Bluetooth` | `c575db642364a8e3e2f9878d2fdd55dc4451230e` |
| `frameworks/base` | `a7b0e5e188fb72a566328bfed0e0412ddb7850e2` |
| `packages/apps/GameSpace` | `2fecfaa6e963a288048dceedc6520f12b0116cd2` |
| `device/oneplus/sm8750-common` | `30beb69ed08ff93111c6e4bfed0d1b8f12fc9dc2` |

```bash
git switch --detach aptx-adaptive-v1.4
bash aptx-adaptive/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at
these commits and current `16.0` branches. The device record concerns the
documented reference setup; different devices, firmware and source revisions
need their own acceptance.

## Deutsch

Fehlerbehebung: Bei einer lokal gewählten R2.2-Konfiguration (44,1 kHz) bestätigt das
Merkmalsbyte jetzt nur Merkmale, die beide Seiten unterstützen; bisher wurden die unteren
Merkmalsbits der Senke ungefiltert übernommen. Für FiiO BTR17 (`0x92`) und Bose QC Ultra 2
(`0x97`) unverändert, beide am Gerät mit Ton geprüft. Neu: Die R2.2-Fähigkeit der Senke wird
in `codec_specific_3` gemeldet. Bekannte Grenze: keine TWS-Kanalarten.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
