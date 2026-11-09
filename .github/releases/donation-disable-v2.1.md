# Donation Disable v2.1

Second edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; this edition replaces [`donation-disable-v2.0`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/donation-disable-v2.0).

Removes the donation prompts in Settings. Personal preference against this form of donation request inside the ROM, not an objection to donations in general.

## Changes from v2.0

* **Rebased onto upstream's rewrite of the maintainer preference.** On 2026-11-01 crDroid rewrote `BuildMaintainerPreference` and the related strings, so v2.0 no longer applied. Both affected patches keep their effect on the new code: `donation_settings.patch` still removes the donation activity registration and the donation links from the maintainer and version preferences in Settings, and `donation_about.patch` still removes the donation entry and the default donation URL in crDroidSettings. `donation_components.patch` is unchanged.
* The NOTICE reference commits move to `packages/apps/Settings` `07f7f688d4fe` and `packages/apps/crDroidSettings` `1c50ab11e2a6`.
* Upstream change, not part of this module: builds not signed with the official key now show "Unofficial" instead of a maintainer name.

## Status on crDroid 17.0

Source-checked: all three patches apply and revert cleanly at the NOTICE reference commits and on branch `17.0` (last checked 2026-11-09). The same patches are part of the maintainer's crDroid 17.0 ROM builds for the OnePlus 13 since 2026-11-02.

The device check of v2.0 (2026-10-27) predates this rebase; v2.1 has not yet been re-checked on the device.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/donation-disable-v2.1/donation-disable) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `packages/apps/crDroidSettings` | `1c50ab11e2a64a731608588b73bd9796c508ab56` |
| `packages/apps/Settings` | `07f7f688d4fe34c18026a4c1540bdf2e06d752df` |

```bash
git switch --detach donation-disable-v2.1
bash donation-disable/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Zweite Fassung für crDroid 17.0: Neu aufgesetzt auf die von crDroid am 01.11.2026 umgeschriebene Maintainer-Einstellung (`BuildMaintainerPreference`) und ihre Texte; Wirkung unverändert, kein Spendenlink. Referenzen jetzt Settings `07f7f688d4fe` und crDroidSettings `1c50ab11e2a6`. Am Quellstand geprüft (Anwenden und Zurücknehmen an den Referenzcommits und auf Branch `17.0`, zuletzt 09.11.2026); seit 02.11.2026 Teil der 17.0-Builds des Maintainers. Die Geräteprüfung vom 27.10.2026 stammt aus der Zeit vor dem Neuaufsetzen.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
