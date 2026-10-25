# OPlus Battery Capacity v2.0

First edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; this module has no crDroid 16.0 edition.

Manufacturer-aligned battery-health reporting through the existing OPlus gauge capacity correction for crDroid 17.0 / OnePlus sm8750: Android receives the compensated full-charge capacity and a fresh design capacity, with raw-value fallbacks and wide intermediate arithmetic.

## Scope

* New module; there is no crDroid 16.0 edition. It starts at 2.0 because the repository's major version names the crDroid version (2.x = crDroid 17.0).

## Status on crDroid 17.0

**Device-confirmed on crDroid 17.0.** On 2026-10-21 the maintainer confirmed 5472 mAh and 92 % in Settings on a OnePlus 13 running the new 17.0 ROM.

Part of the maintainer's crDroid 17.0 ROM build of 2026-10-22, made from this repository at commit `4bdecab`. See the module for the formula, fallbacks and validation scope.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/oplus-battery-capacity-v2.0/oplus-battery-capacity) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `kernel/oneplus/sm8750-modules` | `204b190250343259fc7925c6f50a9365b2bff629` |

```bash
git switch --detach oplus-battery-capacity-v2.0
bash oplus-battery-capacity/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Neues Modul, erste Fassung (2.0 = crDroid 17.0): herstellernahe Akkugesundheit über die vorhandene OPlus-Korrektur. Am 21.10.2026 am OnePlus 13 bestätigt (5472 mAh, 92 %). Teil des 17.0-Builds vom 22.10.2026.

The kernel patch retains **GPL-2.0-only** and the affected source's Oplus notices; documentation, host fixtures and the generated installer use Apache 2.0. See LICENSE and NOTICE.
