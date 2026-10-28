# GPS server choices for crDroid

[Deutsch](README.de.md)

Two independently selectable configuration patches for **crDroid 17.0 (Android 17)**,
OnePlus `device/oneplus/sm8750-common`, file `configs/gps/gps.conf`; the SUPL choice also adds
`configs/gps/gps_debug.conf`, installed to `/vendor/etc`.
They are build-time choices, not a new Android Settings menu.

> **crDroid 17.0 edition 2.1: checked on the device.** These patches target crDroid 17.0 and
> apply and revert cleanly at the [`NOTICE`](NOTICE) reference commits. The device check of
> edition 2.0 on 2026-10-27 found the SUPL choice overridden at runtime by the
> carrier-configuration SUPL host (`supl.google.com` there). Edition 2.1 therefore also installs
> `/vendor/etc/gps_debug.conf`. On 2026-10-28 a OnePlus 13 running the maintainer's crDroid 17.0
> build of 2026-10-28, made from this repository at commit `d627ee4`, had the file in place, and
> the framework configuration resolves to `supl.grapheneos.org`. Which server is then contacted
> cannot be observed on that device: it has no SIM card, and Android requests SUPL only over a
> cellular connection; see *Validation and limits*. The 16.0 edition stays on branch
> [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0/gps-servers).

## Choose either, both or neither

| Choice | Patch | Configuration |
|---|---|---|
| GrapheneOS SUPL proxy | [sm8750_grapheneos_supl.patch](patches/sm8750_grapheneos_supl.patch) | Sets `SUPL_HOST=supl.grapheneos.org`, `SUPL_PORT=7275` in `gps.conf` instead of the commented baseline placeholders, and installs the same two values as `/vendor/etc/gps_debug.conf` (new file plus one `common.mk` entry), which the Android framework applies over the carrier configuration. |
| German GNSS NTP pool | [sm8750_ntp_germany.patch](patches/sm8750_ntp_germany.patch) | Replaces `NTP_SERVER=time.xtracloud.net` with `NTP_SERVER=0.de.pool.ntp.org`. This is a regional preference. |
| Upstream configuration | Apply neither, or reverse the chosen patch | Keeps the original SUPL placeholders and/or NTP hostname from the reference tree. |

GrapheneOS documents its SUPL proxy and its own additional protections in its
[FAQ](https://grapheneos.org/faq#other-connections). This hostname change does
not port those protections to crDroid. Because `gps_debug.conf` is read after the
carrier configuration, the SUPL choice also replaces a carrier's SUPL server, including
for emergency calls. Actual use of the selected server still needs a device trace.
The [German NTP pool](https://www.ntppool.org/en/zone/de) is a pool of servers;
this choice does not change Android's general network-time service.
No faster fix, improved accuracy or verified privacy improvement is claimed.
The patches leave PSDS/XTRA URLs, GNSS capabilities and the other emergency settings unchanged.

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
bash .github/scripts/check-reference.sh --branch 17.0 gps-servers
```

Edition 2.1 adds `configs/gps/gps_debug.conf` and its `common.mk` entry to the SUPL patch. Both
patches apply and revert cleanly, alone and together, at the reference commit and on branch `17.0`.

**crDroid 17.0 device check of edition 2.1 (2026-10-28):** OnePlus 13, crDroid 17.0 build of
2026-10-28 with both patches.
* `/vendor/etc/gps_debug.conf` is installed (`SUPL_HOST=supl.grapheneos.org`, `SUPL_PORT=7275`),
  with the SELinux label `vendor_configs_file`, which every domain may read.
* `GnssConfiguration` reads its sources in this order, later ones overriding earlier ones:
  carrier configuration (`gps.supl_host = supl.google.com`), `config_gnssParameters` (empty in
  the framework; none of the 237 overlay APKs of the build sets it),
  `/vendor/etc/gps_debug.conf` (`supl.grapheneos.org`) and `/system/etc/gps_debug.conf` (no
  active lines). The framework therefore passes `supl.grapheneos.org:7275` to the HAL with
  `setAgpsServer`.
* Not verifiable on the reference device: which server is actually contacted. Android requests
  SUPL only over a cellular connection (`NET_CAPABILITY_SUPL`, `TRANSPORT_CELLULAR`), and the
  reference device has no SIM card, so no SUPL session can take place there; none was logged
  during the check.
* With XTRA assistance running (enabled by a separate ROM change), the first fix at an open
  window came after 91 s (edition 2.0 check without XTRA: 208 s), from GPS, GLONASS, BeiDou and
  Galileo. This is not attributed to this module.

**crDroid 17.0 device check of edition 2.0 (2026-10-27):** OnePlus 13, crDroid 17.0 build of 2026-10-25 with
both patches.
* `/odm/etc/gps.conf` sets `SUPL_HOST=supl.grapheneos.org`, `SUPL_PORT=7275` and
  `NTP_SERVER=0.de.pool.ntp.org`; all three hosts resolve on the device.
* The framework does not keep that SUPL host. `GnssConfiguration` builds its values from the
  carrier configuration (`gps.supl_host = supl.google.com` on this device), resource overlays
  and `gps_debug.conf` (empty here), and `GnssLocationProvider.setSuplHostPort()` hands the
  result to the HAL with `setAgpsServer`. The GrapheneOS SUPL choice therefore does not take
  effect here; it would have to be set in `/vendor/etc/gps_debug.conf` or a
  carrier-configuration overlay, which edition 2.1 does. No network trace was taken.
* `NTP_SERVER` replaces the upstream `time.xtracloud.net`, Qualcomm's XTRA time service.
  `xtra-daemon` was not running on this build, so no XTRA assistance reached the receiver, and
  whether the NTP choice is used could not be observed.
* GNSS itself works. Behind a closed window 13 of 49 satellites had signal (12–22 dB-Hz,
  ephemeris for one) and there was no fix. With the window open, the first fix came after 208 s
  without assistance data, followed by 40 positions with a mean accuracy of 18 m from GPS,
  GLONASS and BeiDou, including L5.

**Documented ROM and device acceptance:** Validated live on the **OnePlus 13**
running crDroid 16.0 (build `Sat Oct 3 23:45:41 CEST 2026`):
`/odm/etc/gps.conf` actively configures `SUPL_HOST=supl.grapheneos.org`, `SUPL_PORT=7275`, and
`NTP_SERVER=0.de.pool.ntp.org`. The GNSS location service (`GnssService`) is operational and
acquires satellite fixes across multi-frequency bands (GPS, Galileo, BeiDou, GLONASS).
License and attribution: [LICENSE](LICENSE), [NOTICE](NOTICE).

