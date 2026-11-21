# Donation Disable v2.2

Third edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; this edition replaces [`donation-disable-v2.1`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/donation-disable-v2.1).

Removes the donation prompts in Settings. Personal preference against this form of donation request inside the ROM, not an objection to donations in general.

## Changes from v2.1

* **Rebased onto upstream's reminder rework.** On 2026-11-19 crDroid reworked `DonateReceiver` (no stacked reminders, a new reminder a day after a swipe-dismiss), so `donation_components.patch` no longer applied. The patch still deletes `DonateActivity` and keeps the receiver for cleanup only; it never schedules or shows a reminder.
* **Maintainer and version entries no longer look disabled.** v2.1 marked both entries in Settings as not selectable, which Android 17 draws in grey. `donation_settings.patch` now leaves them selectable; taps on both still do nothing, and copying by long press stays. Builds without the official signature keep upstream's "Unofficial" state.
* The NOTICE reference commit for `packages/apps/crDroidSettings` moves to `8aa2aa998056`; `packages/apps/Settings` stays at `07f7f688d4fe`.

## Status on crDroid 17.0

Source-checked: all three patches apply and revert cleanly at the NOTICE reference commits and on branch `17.0` (last checked 2026-11-21).

The device check of v2.0 (2026-10-27) predates both rebases; v2.2 has not yet been checked on the device.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/donation-disable-v2.2/donation-disable) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `packages/apps/crDroidSettings` | `8aa2aa99805668d75256a9fd81ff03f1fe4d6c3e` |
| `packages/apps/Settings` | `07f7f688d4fe34c18026a4c1540bdf2e06d752df` |

```bash
git switch --detach donation-disable-v2.2
bash donation-disable/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Dritte Fassung für crDroid 17.0: Neu aufgesetzt auf den von crDroid am 19.11.2026 umgebauten `DonateReceiver`; `DonateActivity` bleibt gelöscht, der Receiver räumt nur auf. Maintainer- und Versionseintrag in den Einstellungen sind nicht mehr grau; Tippen bewirkt weiter nichts, Kopieren per langem Druck bleibt. Referenz crDroidSettings jetzt `8aa2aa998056`, Settings unverändert `07f7f688d4fe`. Am Quellstand geprüft (Anwenden und Zurücknehmen an den Referenzcommits und auf Branch `17.0`, 21.11.2026); noch keine Geräteprüfung dieser Fassung.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
