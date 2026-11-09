# Morphe Runtime Compatibility v2.1

Second edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; this edition replaces [`morphe-runtime-v2.0`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/morphe-runtime-v2.0).

Morphe runtime compatibility for crDroid in libc.

## Changes from v2.0

* **Rebased onto upstream's `custom_rom_hide` hardening.** On 2026-11-02/03 crDroid reworked `libc/bionic/custom_rom_hide.cpp` (`c8be18d0` to `dd42d691`), including the exemption check and the per-process cache, so v2.0 no longer applied. The patch keeps the same three changes: the `app.morphe.manager` allowlist entry, the transient `/system/bin/app_process*` launcher names and the deferred caching.
* Upstream's new exemption of empty or unreadable process names and of the bare `app_process` names is kept.
* The NOTICE reference commit moves to `bionic` `dd42d691`.

## Status on crDroid 17.0

Source-checked: the patch applies and reverts cleanly at the NOTICE reference commit and on branch `17.0` (2026-11-09). Host probe of the real filter against `dd42d691`: 44 checks, zero failures; the unpatched source fails nine, the allowlist entry alone still fails the three late-rename cases. The same patch content is part of the maintainer's crDroid 17.0 ROM builds for the OnePlus 13 since 2026-11-03.

The device check of v2.0 (2026-10-27) predates this rebase; v2.1 has not yet been re-checked on the device.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/morphe-runtime-v2.1/morphe-runtime) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `bionic` | `dd42d6911f3d7822038aadf795f37d182efb116e` |

```bash
git switch --detach morphe-runtime-v2.1
bash morphe-runtime/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Zweite Fassung für crDroid 17.0: Neu aufgesetzt auf die Härtung von `custom_rom_hide` (`c8be18d0` bis `dd42d691`) mit denselben drei Änderungen; die neuen Upstream-Ausnahmen für leere oder unlesbare Prozessnamen und die nackten `app_process`-Namen bleiben erhalten. Referenz jetzt `bionic` `dd42d691`. Am Quellstand geprüft (09.11.2026); Host-Probe 44 Prüfungen ohne Fehler, ungepatcht neun Fehler. Seit 03.11.2026 steckt derselbe Patchinhalt in den 17.0-Builds des Maintainers. Die Geräteprüfung vom 27.10.2026 stammt aus der Zeit vor dem Neuaufsetzen.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
