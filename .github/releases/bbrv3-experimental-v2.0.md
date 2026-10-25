# BBRv3 experimental 2026 update for crDroid sm8750 (testing only) v2.0

First edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; the final crDroid 16.0 edition is [`bbrv3-experimental-v0.1`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/bbrv3-experimental-v0.1) on branch [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0).

**Experimental module. Use it only to test; for regular builds use `bbrv3`.** It replaces `bbrv3` in a test build and must not be applied together with it. Complete series for the OnePlus sm8750 Android15/Linux 6.6 kernel of crDroid 17.0: the two `bbrv3` patches plus Google's TCP BBR branch `bbr-v3-2026-09-16-01` backported to Linux 6.6.

## Changes from the crDroid 16.0 edition

* All three patches are unchanged from `bbrv3-experimental-v0.1`; the two base patches stay byte-identical to `bbrv3-v2.0`.
* Only the NOTICE reference commit moves to the 17.0 kernel.
* Version 2.0 follows the repository rule (2.x = crDroid 17.0); it is still a testing-only line.

## Status on crDroid 17.0

Part of the maintainer's crDroid 17.0 ROM build of 2026-10-22 for the OnePlus 13, made from this repository at commit `4bdecab`; builds of this series have been running on the device since 2026-10-20.

On a device, `/sys/module/tcp_bbr3/version` reads `3-2026x` while this edition runs. The module's own functions have not yet been checked individually on 17.0.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/bbrv3-experimental-v2.0/bbrv3-experimental) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `kernel/oneplus/sm8750` | `48baf0c723f8d6d1efa4db9d2cb5ad6df83ab976` |

```bash
git switch --detach bbrv3-experimental-v2.0
bash bbrv3-experimental/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Experimentell, nur zum Testen. Erste Fassung für crDroid 17.0: Patches unverändert, Referenz auf den 17.0-Kernel. Teil des 17.0-Builds vom 22.10.2026; nicht einzeln gemessen.

Keep the module files together. Kernel GPL/file terms and BBR's preserved `Dual BSD/GPL` declaration differ from Apache2.0 for own docs/installer; see NOTICE.
