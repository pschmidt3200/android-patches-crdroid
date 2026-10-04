# Bluetooth Codec UI v1.1

Bug-fix release for **crDroid 16.0 / Android 16**.
Reference platform: **OnePlus 13** (`dodge`, CPH2653) with **FiiO BTR17** (aptX Adaptive, AAC, SBC).

## Changes from v1.0

* **Sample rate row:** the sample-rate choice moves from a borderless button in the codec dialog to its own
  *Sample rate* row below *Audio codec* on the Connected devices page. The row is shown only when the current codec
  offers at least two rates; with a single rate (e.g. SBC or AAC at 44.1 kHz) it is hidden and the rate stays visible
  in the *Audio codec* summary.
* **No "Automatic" option:** without an explicit rate the Bluetooth stack falls back to the audio output rate or the
  codec default, so the option had no visible effect. The list now contains only the rates the device offers.
* **Codec dialog:** the hint no longer refers to the HD audio switch (which is not shown for many devices) and uses the
  standard dialog padding.
* **Icons:** both rows carry an icon (Bluetooth audio, equalizer); the vector paths come from AOSP.

## Requirements and source baselines

No ROM image, binaries or vendor firmware are included. Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/bluetooth-codec-ui-v1.1/bluetooth-codec-ui).

| Target repository | NOTICE reference commit |
|---|---|
| `frameworks/base` | `a7b0e5e188fb72a566328bfed0e0412ddb7850e2` |
| `packages/apps/Settings` | `62faa70985307e4e5fca0c7c838f11dba0b2c4ab` |

```bash
git switch --detach bluetooth-codec-ui-v1.1
bash bluetooth-codec-ui/apply-patches.sh --check /path/to/crdroid
```

## Deutsch

Fehlerbehebung: Die Abtastrate hat jetzt eine eigene Zeile *Abtastrate* unter *Audio-Codec* auf „Verbundene Geräte“,
sichtbar nur, wenn der Codec mindestens zwei Raten anbietet. Die Option *Automatisch* entfällt, weil sie keine sichtbare
Wirkung hatte. Der Hinweis im Codec-Dialog nennt den HD-Audio-Schalter nicht mehr, und beide Zeilen haben ein Symbol.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
