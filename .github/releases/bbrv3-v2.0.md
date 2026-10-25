# BBRv3 for crDroid sm8750 v2.0

First edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; the final crDroid 16.0 edition is [`bbrv3-v1.2`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/bbrv3-v1.2) on branch [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0).

Maintained TCP BBRv3 source patch for the OnePlus sm8750 Android15/Linux 6.6 kernel of crDroid 17.0, with the default companion patch.

## Changes from the crDroid 16.0 edition

* Both patches are unchanged from `bbrv3-v1.2` and apply to the crDroid 17.0 kernel as they are; only the NOTICE reference commit moves to the 17.0 kernel.
* This is still the existing BBRv3 algorithm, **not Google's September 2026 update** (see `bbrv3-experimental`).

## Status on crDroid 17.0

Part of the maintainer's crDroid 17.0 ROM build of 2026-10-22 for the OnePlus 13, made from this repository at commit `4bdecab`; builds of this series have been running on the device since 2026-10-20.

The module's own functions have not yet been checked individually on 17.0.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/bbrv3-v2.0/bbrv3) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `kernel/oneplus/sm8750` | `48baf0c723f8d6d1efa4db9d2cb5ad6df83ab976` |

```bash
git switch --detach bbrv3-v2.0
bash bbrv3/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Erste Fassung für crDroid 17.0: Patches unverändert gegenüber v1.2, Referenz auf den 17.0-Kernel umgestellt. Teil des 17.0-Builds vom 22.10.2026; Funktion unter 17.0 nicht einzeln gemessen.

Keep the module files together. Kernel GPL/file terms and BBR's preserved `Dual BSD/GPL` declaration differ from Apache2.0 for own docs/installer; see NOTICE.
