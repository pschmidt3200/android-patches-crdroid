# GPS Server Choices v1.0

First public module release for **crDroid 16.0 / Android 16**, OnePlus
`device/oneplus/sm8750-common`, GNSS configuration `configs/gps/gps.conf`.
Implementation baseline: `f62057a0120f044d65278770fad17af96f0fdc5c`.

## Independently selectable choices

* GrapheneOS SUPL proxy: `SUPL_HOST=supl.grapheneos.org`, `SUPL_PORT=7275`.
* German GNSS NTP pool: `NTP_SERVER=0.de.pool.ntp.org`.

Apply either patch, both or neither. **The helper selects both choices.**
These are build-time settings, not an Android Settings menu. The patches
leave PSDS/XTRA URLs, GNSS capabilities and emergency settings unchanged.
Read the [module instructions](https://github.com/pschmidt3200/android-patches-crdroid/tree/gps-servers-v1.0/gps-servers)
for selecting or reversing an individual choice.

## Source baseline

| Target repository | NOTICE reference commit |
|---|---|
| `device/oneplus/sm8750-common` | `30beb69ed08ff93111c6e4bfed0d1b8f12fc9dc2` |

```bash
git switch --detach gps-servers-v1.0
bash gps-servers/apply-patches.sh --check /path/to/crdroid
```

## Validation and remaining acceptance

Publication checks module format, installer behaviour and real source
application/reversal at the NOTICE commit and current `16.0` branch.
**A public-edition ROM build, effective-server trace and GNSS measurements remain pending.**
Carrier/modem configuration can override the file. Validate actual SUPL/NTP
endpoints, fix time and accuracy on the intended device and network.
The hostname change does not port GrapheneOS's complete protections to crDroid;
no measured accuracy, speed or privacy improvement is claimed.

## Deutsch

Erste öffentliche V1 der optionalen GPS-Serverauswahl. SUPL und NTP sind
getrennt wählbar; der Installer wählt beide. Quellprüfung und Rücknahme
sind geprüft, tatsächliche Servernutzung und GNSS-Gerätemessungen noch offen.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
