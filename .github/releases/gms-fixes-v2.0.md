# GMS Compatibility v2.0

First edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; the final crDroid 16.0 edition is [`gms-fixes-v1.0`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/gms-fixes-v1.0) on branch [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0).

Compatibility adjustments for Google services with Evolution X `vendor_gms`, branch **`cnb`**, at `vendor/gms`.

## Changes from the crDroid 16.0 edition

* `gms_uses_libraries.patch`: required and optional uses-library declarations are aligned with the prebuilt manifests; the two existing build-check exceptions remain.
* `gms_oneplus_package_selection.patch`: excludes ten incompatible Pixel package prefixes from the OnePlus product lists of the `cnb` branch.
* The query-visibility and Google Clock permission patches are unchanged.

## Status on crDroid 17.0

Part of the maintainer's crDroid 17.0 ROM build of 2026-10-22 for the OnePlus 13, made from this repository at commit `4bdecab`; builds of this series have been running on the device since 2026-10-20.

**Device-verified on 2026-10-27** (OnePlus 13, crDroid 17.0 build of 2026-10-25): Google Play services are force-queryable, Play services and the Play Store run, an alarm in Google Clock rang as set, none of the removed Pixel packages comes from the system image, and the device log shows no uses-library errors. The Google Clock version installed through the Play Store requests `USE_EXACT_ALARM` instead of `SCHEDULE_EXACT_ALARM`, so that permission patch currently has no effect on it.

These results were recorded after this release in the [module README on `main`](https://github.com/pschmidt3200/android-patches-crdroid/tree/main/gms-fixes); the files of this tag are unchanged.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/gms-fixes-v2.0/gms-fixes) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `frameworks/base` | `c2382c14b024f5701071d31d9cc8fe1401dc9a88` |
| `vendor/gms` | `d5490a1323f348fff1cc35f091b29ba583c67a84` |

```bash
git switch --detach gms-fixes-v2.0
bash gms-fixes/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Erste Fassung für crDroid 17.0 mit Evolution X vendor_gms `cnb`: uses-library-Angaben an die APK-Manifeste angeglichen, Paketauswahl für OnePlus angepasst. Teil des 17.0-Builds vom 22.10.2026. Am 27.10.2026 auf einem OnePlus 13 geprüft (Build vom 25.10.2026): Play-Dienste für alle sichtbar, Wecker in Google Clock funktioniert, kein entferntes Pixel-Paket im Systemabbild, keine uses-library-Fehler im Protokoll. Die per Play Store aktualisierte Clock fordert `SCHEDULE_EXACT_ALARM` nicht mehr an.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
