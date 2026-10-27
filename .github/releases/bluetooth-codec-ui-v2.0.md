# Bluetooth Codec UI v2.0

First edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; the final crDroid 16.0 edition is [`bluetooth-codec-ui-v1.3`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/bluetooth-codec-ui-v1.3) on branch [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0).

Bluetooth audio codec status, badges and selection menu in Settings. Reference platform: **OnePlus 13** with **FiiO BTR17**.

## Changes from the crDroid 16.0 edition

* The SettingsLib codec status and the Settings codec menu are ported to Android 17.
* The badge and entry patches are unchanged.

## Status on crDroid 17.0

Part of the maintainer's crDroid 17.0 ROM build of 2026-10-22 for the OnePlus 13, made from this repository at commit `4bdecab`; builds of this series have been running on the device since 2026-10-20.

**Device-verified on 2026-10-27** (OnePlus 13, crDroid 17.0 build of 2026-10-25): the codec entry, the selection dialog and the sample-rate read-back work with an aptX Adaptive receiver, and the Bluetooth stack applied the selected configurations. The LE Audio frame-duration choice was not checked.

These results were recorded after this release in the [module README on `main`](https://github.com/pschmidt3200/android-patches-crdroid/tree/main/bluetooth-codec-ui); the files of this tag are unchanged.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/bluetooth-codec-ui-v2.0/bluetooth-codec-ui) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `frameworks/base` | `c2382c14b024f5701071d31d9cc8fe1401dc9a88` |
| `packages/apps/Settings` | `927b09818133aa37cf6acd057c656859aa3a5ce6` |

```bash
git switch --detach bluetooth-codec-ui-v2.0
bash bluetooth-codec-ui/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Erste Fassung für crDroid 17.0: Codec-Status in SettingsLib und Codec-Menü in den Einstellungen portiert. Teil des 17.0-Builds vom 22.10.2026. Am 27.10.2026 auf einem OnePlus 13 geprüft (Build vom 25.10.2026): Codec-Eintrag, Auswahl und Rückmeldung der Abtastrate funktionieren mit einem aptX-Adaptive-Empfänger; die LE-Audio-Frame-Dauer wurde nicht geprüft.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
