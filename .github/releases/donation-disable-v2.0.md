# Donation Disable v2.0

First edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; the final crDroid 16.0 edition is [`donation-disable-v1.0`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/donation-disable-v1.0) on branch [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0).

Removes the donation prompts in Settings. Personal preference against this form of donation request inside the ROM, not an objection to donations in general.

## Changes from the crDroid 16.0 edition

* The patches are unchanged and apply to crDroid 17.0 as they are; only the NOTICE reference commits move to 17.0.

## Status on crDroid 17.0

Part of the maintainer's crDroid 17.0 ROM build of 2026-10-22 for the OnePlus 13, made from this repository at commit `4bdecab`; builds of this series have been running on the device since 2026-10-20.

The module's own functions have not yet been checked individually on 17.0.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/donation-disable-v2.0/donation-disable) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `packages/apps/crDroidSettings` | `4eeb1fb361a25985b675bf2bad448a8ce963c14f` |
| `packages/apps/Settings` | `927b09818133aa37cf6acd057c656859aa3a5ce6` |

```bash
git switch --detach donation-disable-v2.0
bash donation-disable/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Erste Fassung für crDroid 17.0: Patches unverändert, Referenzen auf 17.0. Teil des 17.0-Builds vom 22.10.2026; nicht einzeln geprüft.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
