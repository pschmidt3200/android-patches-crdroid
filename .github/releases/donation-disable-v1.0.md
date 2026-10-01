# Donation Disable v1.0

First public source-patch release for **crDroid 16.0 / Android 16**.
Personal preference against this form of donation request inside the ROM,
not an objection to donations in general.
Implementation baseline: `f62057a0120f044d65278770fad17af96f0fdc5c`.

## Included changes

* Remove the donation activity, donation page and identified donation links
  and entry points in Settings/crDroidSettings, including repeated version taps.
* Keep the old reminder receiver only to clear earlier alarms, notifications
  and its notification channel after boot/unlock; it creates no new reminders.
* Preserve maintainer names/copying, OTA lookup, project credits and unrelated
  About entries. Unused upstream resources and external website content remain.

**Use all three patches together.** Read the
[module instructions](https://github.com/pschmidt3200/android-patches-crdroid/tree/donation-disable-v1.0/donation-disable)
and reconcile any previous donation modification before applying.
This is a source modification requiring a ROM build and installation.

## Source baselines

| Target repository | NOTICE reference commit |
|---|---|
| `packages/apps/crDroidSettings` | `e43ad3d1c83290d25f2b721d8979a7095e53eecb` |
| `packages/apps/Settings` | `62faa70985307e4e5fca0c7c838f11dba0b2c4ab` |

```bash
git switch --detach donation-disable-v1.0
bash donation-disable/apply-patches.sh --check /path/to/crdroid
```

## Validation and remaining acceptance

Publication checks format, installer behaviour and real source application/reversal
at the NOTICE commits and current `16.0` branches. The module documentation also
records Java/Kotlin host probes using Android API stubs.
**Full ROM build and device acceptance of the public edition remain pending.**
After upgrading, check Settings/About, repeated crDroid-version taps, maintainer
display/copying and cleanup of old alarms/notifications after boot/unlock.
Host probes do not establish Android framework behaviour on a device.

## Deutsch

Erste öffentliche V1 des persönlichen Spendenabschalter-Moduls. Es entfernt
Spendenanfragen und erreichbare Links, räumt alte Erinnerungen auf und erhält
Maintainer-Namen. Alle drei Patches zusammen verwenden. Quell- und dokumentierte
Host-Prüfungen liegen vor; ROM-Build und Geräteabnahme bleiben offen.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
