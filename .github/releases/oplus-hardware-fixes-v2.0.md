# Oplus Hardware Fixes v2.0

First edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; the final crDroid 16.0 edition is [`oplus-hardware-fixes-v1.0`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/oplus-hardware-fixes-v1.0) on branch [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0).

Two correctness fixes for `hardware/oplus`: the LTPO settings screen shows the panel's real configuration instead of the last stored preference, and the touch HAL validates driver and Binder responses instead of assuming they succeeded.

## Changes from the crDroid 16.0 edition

* The touch error handling is ported on top of upstream's multiple gesture-mask nodes (`9c2778c5`).
* The LTPO readback patch is unchanged.

## Status on crDroid 17.0

Part of the maintainer's crDroid 17.0 ROM build of 2026-10-22 for the OnePlus 13, made from this repository at commit `4bdecab`; builds of this series have been running on the device since 2026-10-20.

**Device-verified on 2026-10-26** (OnePlus 13, crDroid 17.0 build of 2026-10-25):

* **LTPO:** switching off wrote `adfr_config` from `0x109f` to `0x0`; after reopening, the screen showed the real state (off), and switching on restored exactly `0x109f`. Variable refresh rates (60/120 Hz) were kept.
* **Touch:** with double-tap-to-wake on, every screen-off ran the full touch-driver chain and a double-tap woke the device; with the setting off, it did not. All four touch HAL interfaces were registered and no touch error was logged.
* **Not covered:** one glove-mode write was acknowledged by the touch HAL, but its effect was not assessed; screen-off gestures other than double-tap were not exercised.

These results were recorded after this release in the [module README on `main`](https://github.com/pschmidt3200/android-patches-crdroid/tree/main/oplus-hardware-fixes); the files of this tag are unchanged.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/oplus-hardware-fixes-v2.0/oplus-hardware-fixes) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `hardware/oplus` | `f5f9acbc690d9c5488ea994a15df9340b1192e22` |

```bash
git switch --detach oplus-hardware-fixes-v2.0
bash oplus-hardware-fixes/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Erste Fassung für crDroid 17.0: Touch-Fehlerbehandlung auf die neuen Gesture-Mask-Knoten von Upstream portiert, LTPO-Patch unverändert. Teil des 17.0-Builds vom 22.10.2026. Am 26.10.2026 auf einem OnePlus 13 geprüft (Build vom 25.10.2026): Der LTPO-Schalter zeigt den echten Zustand (`0x109f` → `0x0` → `0x109f`), Double-Tap-to-Wake weckt nur bei eingeschalteter Einstellung. Handschuhmodus und weitere Bildschirm-aus-Gesten wurden nicht bewertet.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
