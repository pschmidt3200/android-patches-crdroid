# GPS Server Choices v2.1

Second edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; this edition replaces [`gps-servers-v2.0`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/gps-servers-v2.0).

Two independently selectable configuration patches for the GNSS configuration of OnePlus `device/oneplus/sm8750-common`: alternative SUPL and NTP servers.

## Changes from v2.0

* **The SUPL choice now reaches the framework.** A device check of v2.0 showed that the Android framework passes the carrier-configuration SUPL host (`supl.google.com` there) to the GNSS HAL and so overrides `SUPL_HOST` from `gps.conf`. `sm8750_grapheneos_supl.patch` now also adds `configs/gps/gps_debug.conf` with `SUPL_HOST=supl.grapheneos.org` and `SUPL_PORT=7275` and installs it to `/vendor/etc/gps_debug.conf`, which the framework reads after the carrier configuration. This also replaces a carrier's SUPL server for emergency calls.
* `sm8750_ntp_germany.patch` is unchanged.

## Status on crDroid 17.0

Source-checked: both patches apply and revert cleanly, alone and together, at the NOTICE reference commit and on branch `17.0`. This edition has not yet been built into a ROM or checked on a device.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/gps-servers-v2.1/gps-servers) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `device/oneplus/sm8750-common` | `c63ac897067e072fd6bb9306a5c0c8aa6c1b4d11` |

```bash
git switch --detach gps-servers-v2.1
bash gps-servers/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Zweite Fassung für crDroid 17.0: Der SUPL-Patch installiert zusätzlich `/vendor/etc/gps_debug.conf` mit denselben SUPL-Werten, weil das Android-Framework sonst den SUPL-Server aus der Carrier-Konfiguration an die GNSS-HAL übergibt und `gps.conf` übersteuert. Das ersetzt auch bei Notrufen den SUPL-Server des Netzbetreibers. Quellgeprüft, noch nicht gebaut oder am Gerät geprüft. Der NTP-Patch ist unverändert.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
