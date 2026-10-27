# GPS Server Choices v2.0

First edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; the final crDroid 16.0 edition is [`gps-servers-v1.0`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/gps-servers-v1.0) on branch [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0).

Two independently selectable configuration patches for the GNSS configuration of OnePlus `device/oneplus/sm8750-common`: alternative SUPL and NTP servers.

## Changes from the crDroid 16.0 edition

* The patches are unchanged and apply to crDroid 17.0 as they are; only the NOTICE reference commit moves to 17.0.

## Status on crDroid 17.0

Part of the maintainer's crDroid 17.0 ROM build of 2026-10-22 for the OnePlus 13, made from this repository at commit `4bdecab`; builds of this series have been running on the device since 2026-10-20.

**Configuration verified on 2026-10-27** (OnePlus 13, crDroid 17.0 build of 2026-10-25): `/odm/etc/gps.conf` sets `SUPL_HOST=supl.grapheneos.org`, `SUPL_PORT=7275` and `NTP_SERVER=0.de.pool.ntp.org`, and the GNSS service runs. A satellite fix on 17.0 was not yet observed (indoor check).

These results were recorded after this release in the [module README on `main`](https://github.com/pschmidt3200/android-patches-crdroid/tree/main/gps-servers); the files of this tag are unchanged.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/gps-servers-v2.0/gps-servers) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `device/oneplus/sm8750-common` | `c63ac897067e072fd6bb9306a5c0c8aa6c1b4d11` |

```bash
git switch --detach gps-servers-v2.0
bash gps-servers/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Erste Fassung für crDroid 17.0: Patches unverändert, Referenz auf 17.0. Teil des 17.0-Builds vom 22.10.2026. Am 27.10.2026 auf einem OnePlus 13 geprüft (Build vom 25.10.2026): `/odm/etc/gps.conf` enthält beide Einstellungen, der GNSS-Dienst läuft; ein Satelliten-Fix unter 17.0 steht noch aus.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
