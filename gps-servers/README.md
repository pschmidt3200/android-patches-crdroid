# GPS server choices for crDroid

[Deutsch](README.de.md)

Two independently selectable configuration patches for **crDroid 16.0 (Android 16)**,
OnePlus `device/oneplus/sm8750-common`, file `configs/gps/gps.conf`.
They are build-time choices, not a new Android Settings menu.

## Choose either, both or neither

| Choice | Patch | Configuration |
|---|---|---|
| GrapheneOS SUPL proxy | [sm8750_grapheneos_supl.patch](patches/sm8750_grapheneos_supl.patch) | Sets `SUPL_HOST=supl.grapheneos.org`, `SUPL_PORT=7275` instead of the commented baseline placeholders. |
| German GNSS NTP pool | [sm8750_ntp_germany.patch](patches/sm8750_ntp_germany.patch) | Replaces `NTP_SERVER=time.xtracloud.net` with `NTP_SERVER=0.de.pool.ntp.org`. This is a regional preference. |
| Upstream configuration | Apply neither, or reverse the chosen patch | Keeps the original SUPL placeholders and/or NTP hostname from the reference tree. |

GrapheneOS documents its SUPL proxy and its own additional protections in its
[FAQ](https://grapheneos.org/faq#other-connections). This hostname change does
not port those protections to crDroid. Carrier/modem configuration may override
the file; actual use of the selected server still needs a device trace.
The [German NTP pool](https://www.ntppool.org/en/zone/de) is a pool of servers;
this choice does not change Android's general network-time service.
No faster fix, improved accuracy or verified privacy improvement is claimed.
The patches leave PSDS/XTRA URLs, GNSS capabilities and emergency settings unchanged.

## Apply one choice

Run from this repository's root, with no build using the target tree:

```bash
PATCH_ROOT="$(pwd)/gps-servers/patches"
ANDROID_ROOT=/path/to/crdroid
# Select SUPL only:
git -C "$ANDROID_ROOT/device/oneplus/sm8750-common" apply --check "$PATCH_ROOT/sm8750_grapheneos_supl.patch"
git -C "$ANDROID_ROOT/device/oneplus/sm8750-common" apply "$PATCH_ROOT/sm8750_grapheneos_supl.patch"
# Restore upstream SUPL configuration:
git -C "$ANDROID_ROOT/device/oneplus/sm8750-common" apply --reverse "$PATCH_ROOT/sm8750_grapheneos_supl.patch"
```

For the NTP choice, use `sm8750_ntp_germany.patch` with the same commands.
The two patches can be applied and reversed independently.

## Apply both choices

**The helper selects both alternatives.** Its `--check` simulates them on copies
before any change; missing, conflicting and locally modified targets are refused.

```bash
bash gps-servers/apply-patches.sh --check /path/to/crdroid
bash gps-servers/apply-patches.sh /path/to/crdroid
bash gps-servers/apply-patches.sh --check --reverse /path/to/crdroid
bash gps-servers/apply-patches.sh --reverse /path/to/crdroid
```

## Validation and limits

Reference sources: [NOTICE](NOTICE). Source checks cover both patches as a series
and application/reversal of the real configuration at the reference and current branch.

```bash
bash .github/scripts/check-reference.sh gps-servers
bash .github/scripts/check-reference.sh --branch 16.0 gps-servers
```

**Documented ROM and device acceptance:** Validated live on the **OnePlus 13 (`dodge`, CPH2653)**
running crDroid 16.0 (build `Sat Oct 3 23:45:41 CEST 2026`):
`/odm/etc/gps.conf` actively configures `SUPL_HOST=supl.grapheneos.org`, `SUPL_PORT=7275`, and
`NTP_SERVER=0.de.pool.ntp.org`. The GNSS location service (`GnssService`) is operational and
acquires satellite fixes across multi-frequency bands (GPS, Galileo, BeiDou, GLONASS).
License and attribution: [LICENSE](LICENSE), [NOTICE](NOTICE).

