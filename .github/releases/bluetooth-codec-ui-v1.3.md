# Bluetooth Codec UI v1.3

Maintenance release for **crDroid 16.0 / Android 16**.
Reference platform: **OnePlus 13** with **FiiO BTR17** (LC3 over LE Audio; aptX Adaptive, AAC, SBC over A2DP).

## Changes from v1.2

* **Classic codec menu with LE Audio allowed:** the menu no longer hides itself when LE Audio is
  merely permitted for a dual-mode receiver. It now follows the active route, as the dashboard
  entry already did, so A2DP codec choices stay available while media runs over A2DP.
* **LE Audio after a stack restart:** refreshing the page requests a new LE Audio proxy after the
  service disconnected, so LE Audio no longer stays unavailable until the page is reopened.
* **Codec badge:** shows *LC3* only while LE Audio is the active route, not when it is merely
  connected.

All three patches apply and revert byte for byte at the NOTICE reference commits and on the
current `16.0` branch; module and installer checks pass. These are source checks: a new ROM build
and device verification of the three changes remain pending.

## Requirements and source baselines

No ROM image, binaries or vendor firmware are included. Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/bluetooth-codec-ui-v1.3/bluetooth-codec-ui).

| Target repository | NOTICE reference commit |
|---|---|
| `frameworks/base` | `a7b0e5e188fb72a566328bfed0e0412ddb7850e2` |
| `packages/apps/Settings` | `62faa70985307e4e5fca0c7c838f11dba0b2c4ab` |

```bash
git switch --detach bluetooth-codec-ui-v1.3
bash bluetooth-codec-ui/apply-patches.sh --check /path/to/crdroid
```

## Deutsch

Wartungsfassung: Das klassische Codec-Menü verschwindet nicht mehr, nur weil LE Audio für einen
Dual-Mode-Empfänger erlaubt ist, sondern folgt der aktiven Route. Nach einem Neustart des
Bluetooth-Stacks holt die Seite die LE-Audio-Verbindung beim Aktualisieren neu. Das Abzeichen zeigt
*LC3* nur, solange LE Audio die aktive Route ist. Quellprüfungen bestanden; neuer ROM-Build und
Geräteabnahme dieser drei Änderungen stehen noch aus.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
