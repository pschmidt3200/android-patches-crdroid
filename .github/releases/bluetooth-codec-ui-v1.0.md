# Bluetooth Codec UI v1.0

Initial standalone release for **crDroid 16.0 / Android 16**.
Reference platforms: tested on **OnePlus 13** (`dodge`, CPH2653). Works with any compatible crDroid 16.0 device.

## Features

* **Codec status & refresh:** SettingsLib reads the active Bluetooth audio codec and sample rate, and dynamically refreshes the device entry when the codec state changes.
* **Device list badges:** Displays active codec badges in the connected devices list (e.g. `[LDAC]`, `[AAC]`, `[aptX Adaptive 44.1 kHz]`).
* **Codec dialog in device details:** Allows choosing from codecs supported by the connected receiver via the Media audio row.
* **Standalone Audio codec entry:** Provides a dedicated *Audio codec* entry on the Connected devices page with current status and direct codec selection dialog.
* **Codec-independent:** Works with standard AOSP codecs (SBC, AAC, aptX, aptX HD, LDAC) as well as optional hardware integrations (such as aptX Adaptive).

## Requirements and source baselines

No ROM image, binaries or vendor firmware are included. Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/bluetooth-codec-ui-v1.0/bluetooth-codec-ui).

| Target repository | NOTICE reference commit |
|---|---|
| `frameworks/base` | `a7b0e5e188fb72a566328bfed0e0412ddb7850e2` |
| `packages/apps/Settings` | `62faa70985307e4e5fca0c7c838f11dba0b2c4ab` |

```bash
git switch --detach bluetooth-codec-ui-v1.0
bash bluetooth-codec-ui/apply-patches.sh --check /path/to/crdroid
```

## Deutsch

Erstveröffentlichung des eigenständigen Bluetooth-Codec-UI-Moduls: Codec-Statusanzeige und Live-Abtastrate
in den Einstellungen, Badges in der Geräteliste, Codec-Auswahldialog in den Gerätedetails sowie ein
eigenständiger Menüeintrag unter „Verbundene Geräte“. Vollständig codec-unabhängig (SBC, AAC, aptX, aptX HD, LDAC etc.).

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
