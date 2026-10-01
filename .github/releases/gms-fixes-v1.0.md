# GMS Compatibility Fixes v1.0

First public module release for **crDroid 16.0 / Android 16** with
Evolution X `vendor_gms`, Android branch **`bka`**, at `vendor/gms`.
Implementation baseline: `f62057a0120f044d65278770fad17af96f0fdc5c`.

## Included changes

* Make only `com.google.android.gms` queryable through PackageManager.
* Add `SCHEDULE_EXACT_ALARM` to Google Clock's privileged permission list.
* Limit uses-library exceptions to three prebuilts and correct the optional
  library declaration of CrossDeviceAccessServicePrimary.
* Offer the OnePlus product selection that excludes ten incompatible Pixel
  package prefixes while retaining Play Services, Play Store and Google Clock.

**The helper applies all four patches, including the package selection.**
Read the [module instructions](https://github.com/pschmidt3200/android-patches-crdroid/tree/gms-fixes-v1.0/gms-fixes)
before choosing this on a build. Individual patches can be selected directly;
the OnePlus selection is not intended for Pixel builds. The module does not
install GApps or bundle Google APKs.

## Source baselines

| Target repository | NOTICE reference commit |
|---|---|
| `frameworks/base` | `a7b0e5e188fb72a566328bfed0e0412ddb7850e2` |
| `vendor/gms` | `89c3940a77298c204c55a21efded92ddafb59fe9` (`bka`) |

```bash
git switch --detach gms-fixes-v1.0
bash gms-fixes/apply-patches.sh --check /path/to/crdroid
```

## Validation and remaining acceptance

Publication checks metadata/format, installer behaviour and real source
application/reversal at the NOTICE commits and current Android 16 branches.
**A new ROM build and device acceptance of the public module remain pending.**
After building, verify boot, Net Analyzer, Google Clock alarms, launcher/recents,
setup and package installation. The targeted build workarounds do not implement
missing libraries or establish runtime compatibility of the affected apps.
Other GApps vendors and different vendor revisions need separate validation.

## Deutsch

Erste öffentliche V1 der vier GMS-Fixes für crDroid 16.0 mit dem genannten
Vendor-Stand. Der Installer nimmt alle vier Änderungen mit. Quellanwendung
und Rücknahme sind geprüft; ROM-Build und Geräteabnahme der öffentlichen
Gesamtfassung stehen noch aus.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
