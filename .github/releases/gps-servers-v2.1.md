# GPS Server Choices v2.1

Second edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; this edition replaces [`gps-servers-v2.0`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/gps-servers-v2.0).

Two independently selectable configuration patches for the GNSS configuration of OnePlus `device/oneplus/sm8750-common`: alternative SUPL and NTP servers.

## Changes from v2.0

* **The SUPL choice now reaches the framework.** A device check of v2.0 showed that the Android framework passes the carrier-configuration SUPL host (`supl.google.com` there) to the GNSS HAL and so overrides `SUPL_HOST` from `gps.conf`. `sm8750_grapheneos_supl.patch` now also adds `configs/gps/gps_debug.conf` with `SUPL_HOST=supl.grapheneos.org` and `SUPL_PORT=7275` and installs it to `/vendor/etc/gps_debug.conf`, which the framework reads after the carrier configuration. This also replaces a carrier's SUPL server for emergency calls.
* `sm8750_ntp_germany.patch` is unchanged.

## Status on crDroid 17.0

Source-checked: both patches apply and revert cleanly, alone and together, at the NOTICE reference commit and on branch `17.0`.

**Checked on the device on 2026-10-28** (OnePlus 13, crDroid 17.0 build of 2026-10-28, made from this repository at commit `d627ee4`): `/vendor/etc/gps_debug.conf` is installed, and the framework's configuration chain (carrier configuration, resource overlays, `/vendor/etc/gps_debug.conf`, `/system/etc/gps_debug.conf`) resolves to `supl.grapheneos.org:7275`, which it passes to the GNSS HAL. Which server is actually contacted could not be observed: Android requests SUPL only over a cellular connection, and the test device has no SIM card.

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

Zweite Fassung für crDroid 17.0: Der SUPL-Patch installiert zusätzlich `/vendor/etc/gps_debug.conf` mit denselben SUPL-Werten, weil das Android-Framework sonst den SUPL-Server aus der Carrier-Konfiguration an die GNSS-HAL übergibt und `gps.conf` übersteuert. Das ersetzt auch bei Notrufen den SUPL-Server des Netzbetreibers. Am 28.10.2026 auf einem OnePlus 13 geprüft (Build vom 28.10.2026): `/vendor/etc/gps_debug.conf` ist installiert, die Konfigurationskette des Frameworks ergibt `supl.grapheneos.org:7275`; welcher Server tatsächlich angefragt wird, ließ sich nicht beobachten, weil Android SUPL nur über Mobilfunk anfordert und das Testgerät keine SIM-Karte hat. Der NTP-Patch ist unverändert.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
