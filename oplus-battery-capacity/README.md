# OPlus Battery Capacity

`crdroid_oplus_battery_capacity.patch` exposes the existing OPlus gauge full-charge
capacity (FCC) compensation through the Android power-supply reporting path on
**crDroid 17.0 / OnePlus sm8750**. The generic path previously reported raw FCC,
while the OPlus reporting code already applied a device-specific correction.

## Motivation

The goal is a manufacturer-aligned battery-health display: Android should use
the existing OPlus capacity correction to report values closer to those of the
manufacturer ROM. This addresses a low battery-health percentage derived from
raw, uncompensated capacity. The displayed value should follow the device's
correction data rather than a fixed target percentage.

## Acceptance

**Prepared publication wording, to use only after the ROM test passes:**

> Acceptance completed successfully; the patch works as expected. The aim is
> manufacturer-aligned battery-health values using the existing OPlus capacity
> correction.

**Current status:** the maintainer is building the ROM. The device test has not
yet been confirmed; publication is held until that test succeeds.

**Technical checks passed:** source application and reversal, 20 host cases with
ASan/UBSan and a negative control, and compilation of the complete changed driver
translation unit with Android clang r596125 / 22.0.2.

## Behaviour

The patch changes `oplus/kernel/charger/v2/oplus_chg_gki.c` in
`kernel/oneplus/sm8750-modules`. It follows the FCC compensation already present in
the upstream [OPlus configfs reporting code](https://github.com/crdroidandroid/android_kernel_oneplus_sm8750-modules/blob/204b190250343259fc7925c6f50a9365b2bff629/oplus/kernel/charger/v2/oplus_configfs.c).

```text
compensated FCC = min(raw FCC + FCC coefficient * SOH / 100, design capacity)
```

SOH is the gauge state-of-health value, valid from 1 to 100. The FCC coefficient
comes from the gauge; no correction amount or percentage is hardcoded.

* `CHARGE_FULL` reports compensated FCC when the required metadata is valid.
* `CHARGE_FULL_DESIGN` reads the current gauge design capacity and falls back to
  the cached capacity when the gauge is absent or returns no positive capacity.
* Missing gauge, failed metadata reads, invalid SOH, nonpositive coefficient,
  nonpositive raw FCC or no usable design capacity retain raw FCC.
* The intermediate calculation uses 64 bits. Both reported capacities are
  converted from mAh to microamp-hours exactly once.

This changes reporting only. Charging control, learned gauge data and the
separate UI-SOH estimate are not written or replaced. It does not claim to
reproduce a manufacturer's complete battery-health display or independently
measure physical battery wear. A fixed display percentage is not an acceptance
criterion.

## Requirements and installation

Use a crDroid 17.0 source tree with `kernel/oneplus/sm8750-modules` at a compatible
revision. The exact public source reference is in [NOTICE](NOTICE). Other charging
implementations and the crDroid 16.0 edition are outside this module's scope.

Run from this module directory:

```bash
./apply-patches.sh --check /path/to/crdroid
./apply-patches.sh /path/to/crdroid
# Reverse the source change on an otherwise compatible tree:
./apply-patches.sh --reverse /path/to/crdroid
```

Rebuild and install the kernel/ROM through your normal device-specific process.
Running the source installer alone does not change an installed ROM.

## Verification

Run the host check with Python 3 and a C compiler supporting ASan/UBSan:

```bash
python3 tests/check-capacity.py
```

The check extracts the actual helpers and property cases from the patch and
compiles them with `-Wall -Wextra -Werror` and sanitizers. Gauge APIs are fixtures;
cases cover correction, aging, capacity ceiling, wide intermediate arithmetic,
units and missing or invalid metadata. A negative control removes compensation
and must fail. This is not a kernel link, ROM build or device test.

From the repository root, verify the real source installer and its reversal:

```bash
bash .github/scripts/check-reference.sh oplus-battery-capacity
bash .github/scripts/check-reference.sh --branch 17.0 oplus-battery-capacity
```

After installation, compare Android's FCC and design capacity with fresh gauge
values from the same boot. Check the resulting ratio without treating a
separate SOH estimate as an interchangeable FCC measurement.

## License

The kernel patch retains **GPL-2.0-only** and the affected source's Oplus notices;
see [LICENSE](LICENSE) and [NOTICE](NOTICE). Documentation, host fixtures and the
generated installer use [Apache 2.0](LICENSE-APACHE-2.0).
