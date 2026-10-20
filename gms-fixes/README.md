# GMS compatibility fixes for crDroid

[Deutsch](README.de.md)

Four independent source patches for **crDroid 17.0 (Android 17)** using
Evolution X `vendor_gms`, branch `cnb`, installed at `vendor/gms`.
They change framework visibility and vendor build configuration. They do not
install GApps or provide Google APKs. Other GApps vendors are outside this module's scope.

> **crDroid 17.0 edition: source-checked, not yet device-tested.** These patches target
> crDroid 17.0 and apply and revert cleanly at the [`NOTICE`](NOTICE) reference commits.
> A ROM build and device verification on 17.0 are pending; the results described below were
> measured on crDroid 16.0. The 16.0 edition stays on branch [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0/gms-fixes).

## Choose the changes

| Patch | Target repository | Effect |
|---|---|---|
| [gms_query_visibility.patch](patches/gms_query_visibility.patch) | `frameworks/base` | Adds only `com.google.android.gms` to `config_forceQueryablePackages`, for apps affected by package visibility (the original case was Net Analyzer). No additional permissions or other globally queryable packages. |
| [gms_google_clock_permission.patch](patches/gms_google_clock_permission.patch) | `vendor/gms` | Adds `SCHEDULE_EXACT_ALARM` only to Google Clock's privileged permission list. Privileged-permission enforcement remains enabled. |
| [gms_uses_libraries.patch](patches/gms_uses_libraries.patch) | `vendor/gms` | Aligns required/optional uses-library metadata with the APK manifests across 18 build files; retains the existing narrow exceptions for `CustomizationBundlePrebuiltFullVersion` and `SafetyHubPrebuilt`. `PersistentBackgroundServices` is absent from branch `cnb`. |
| [gms_oneplus_package_selection.patch](patches/gms_oneplus_package_selection.patch) | `vendor/gms` | Removes the ten Pixel package prefixes below from the full, tablet, mini and pico product lists. This is an explicit OnePlus build selection. |

The uses-library patch is a targeted build workaround, **not an implementation
of missing libraries**. It does not establish that those apps function at runtime.
The package-selection patch removes these prefixes (including versioned names):

* `FamilySpacePrebuilt`, `OdadPrebuilt`, `SearchSelectorPrebuilt`, `DeviceConnectivityServicePrebuilt`
* `NexusLauncherRelease`, `WallpaperPickerGoogleRelease`
* `SetupWizardPrebuilt`, `SetupWizardPixelPrebuilt`, `GooglePackageInstaller`
* `WeatherPixelPrebuilt`

Keep crDroid's own launcher, setup wizard, package installer and wallpaper picker
available when choosing that patch. It leaves Play Services, Play Store, Google
Clock and unrelated add-ons in the product lists. Do not apply this selection to a Pixel build.

## Apply and undo

Use a clean source tree with no build running. Reference commits are in [NOTICE](NOTICE).
**The helper applies all four patches, including the package selection.** Review
that choice before running it. It checks the whole series on copies before any write.

```bash
bash gms-fixes/apply-patches.sh --check /path/to/crdroid
bash gms-fixes/apply-patches.sh /path/to/crdroid
bash gms-fixes/apply-patches.sh --check --reverse /path/to/crdroid
bash gms-fixes/apply-patches.sh --reverse /path/to/crdroid
```

For only the visibility fix, select that patch directly:

```bash
PATCH_ROOT="$(pwd)/gms-fixes/patches"
ANDROID_ROOT=/path/to/crdroid
git -C "$ANDROID_ROOT/frameworks/base" apply --check "$PATCH_ROOT/gms_query_visibility.patch"
git -C "$ANDROID_ROOT/frameworks/base" apply "$PATCH_ROOT/gms_query_visibility.patch"
# Undo the selected patch:
git -C "$ANDROID_ROOT/frameworks/base" apply --reverse "$PATCH_ROOT/gms_query_visibility.patch"
```

Select other individual patches the same way, using `vendor/gms` as their target.
An already applied or conflicting patch is refused; the helper is not an automatic reapply tool.

## Validation and limits

The public edition is checked for format, installer failure handling, and real
source apply/reverse at the [NOTICE](NOTICE) commits and current upstream branches.
Branch checks use `17.0` for crDroid and NOTICE's `branch=cnb` for the vendor.
Local source checks:

```bash
bash .github/scripts/check-reference.sh gms-fixes
bash .github/scripts/check-reference.sh --branch 17.0 gms-fixes
```

**Documented ROM and device acceptance:** Validated live on the **OnePlus 13**
running crDroid 16.0 (build `v12.12-20261003`): clean boot without bootloops, Google Play Services (26.37)
and Play Store (53.3) running stable without crashes, `com.google.android.gms` globally queryable (`forceQueryable`),
Google Clock alarms working with privileged `SCHEDULE_EXACT_ALARM`, and Launcher/PackageInstaller stable.
Recheck vendor APK manifests and product lists on upstream vendor updates.
License and upstream attribution: [LICENSE](LICENSE), [NOTICE](NOTICE).
