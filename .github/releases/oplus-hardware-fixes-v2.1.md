# Oplus Hardware Fixes v2.1

Second edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; this edition replaces [`oplus-hardware-fixes-v2.0`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/oplus-hardware-fixes-v2.0).

Two correctness fixes for `hardware/oplus`: the LTPO settings screen shows the panel's real configuration instead of the last stored preference, and the touch HAL validates driver and Binder responses instead of assuming they succeeded.

## Changes from v2.0

* **LTPO patch rebased onto upstream's `min_fps` change.** On 2026-11-22 crDroid made the minimum refresh rate follow the LTPO switch (`/sys/kernel/oplus_display/min_fps`: 1 with LTPO on, 120 off), both when switching and on boot restore (`e53c884`, merged as `7b5c133`). The LTPO patch rewrote exactly those paths, so it no longer applied. It now keeps upstream's behaviour: the minimum refresh rate is written once the LTPO config has been written and read back, and only if the node is writable — the same condition crDroid uses.
* The touch error handling patch is unchanged.
* The NOTICE reference commit for `hardware/oplus` moves to `7b5c1335`.

## Status on crDroid 17.0

Source-checked: both patches apply and revert cleanly at the NOTICE reference commit and on branch `17.0` (last checked 2026-11-22).

The device check of v2.0 (2026-10-26) predates the `min_fps` change; v2.1 has not yet been checked on the device.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/oplus-hardware-fixes-v2.1/oplus-hardware-fixes) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `hardware/oplus` | `7b5c1335ea5dd65e18b088b18db242bd00182297` |

```bash
git switch --detach oplus-hardware-fixes-v2.1
bash oplus-hardware-fixes/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Zweite Fassung für crDroid 17.0: Der LTPO-Patch ist neu aufgesetzt auf crDroids Änderung vom 22.11.2026, bei der die Mindest-Bildrate (`min_fps`) dem LTPO-Schalter folgt. Sie bleibt erhalten und wird geschrieben, sobald der LTPO-Wert bestätigt zurückgelesen ist, und nur, wenn der Knoten beschreibbar ist. Touch-Patch unverändert. Referenz `hardware/oplus` jetzt `7b5c1335`. Am Quellstand geprüft (Anwenden und Zurücknehmen am Referenzcommit und auf Branch `17.0`, 22.11.2026); noch keine Geräteprüfung dieser Fassung.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
