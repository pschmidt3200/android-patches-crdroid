# Morphe runtime compatibility for crDroid

[Deutsch](README.de.md)

Optional source patch for **crDroid 17.0 (Android 17)**. The custom ROM
filter in libc can hide `org.lineageos.platform-res.apk` from Morphe's
separate ART patcher, even though the resource exists. This module grants
Morphe the same process exemption already used for the LineageOS updater.

| Patch | Target repository | Change |
|---|---|---|
| [crdroid_bionic_morphe_runtime.patch](patches/crdroid_bionic_morphe_runtime.patch) | `bionic` | Add `app.morphe.manager` to the existing allowlist and defer caching while the process still has its initial launcher name. |

The existing process-name parser also handles `app.morphe.manager:Patcher`.
Early calls under `/system/bin/app_process`, `/system/bin/app_process32`
or `/system/bin/app_process64` remain filtered, but their negative result
is not cached before `--nice-name` takes effect. Other apps and package-name
lookalikes remain filtered; updater and zygote handling are retained.
This is a process-name compatibility rule, not package-signature validation.

> **crDroid 17.0 edition: device-verified.** These patches target crDroid 17.0 and apply and
> revert cleanly at the [`NOTICE`](NOTICE) reference commits. On 2026-10-27 Morphe's process
> runtime was checked on a OnePlus 13 running the maintainer's crDroid 17.0 build of 2026-10-25,
> made from this repository at commit `4bdecab`; see *Validation and limits*. The 16.0 edition
> stays on branch
> [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0/morphe-runtime).

## Apply and undo

Use a compatible, clean source tree with no build running. Reference
commit and attribution are in [NOTICE](NOTICE). From this repository:

```bash
bash morphe-runtime/apply-patches.sh --check /path/to/crdroid
bash morphe-runtime/apply-patches.sh /path/to/crdroid
bash morphe-runtime/apply-patches.sh --check --reverse /path/to/crdroid
bash morphe-runtime/apply-patches.sh --reverse /path/to/crdroid
```

Review the source diff, rebuild the ROM and install it normally. This is
not a flashable ZIP or an installed-ROM toggle. Reversing the source patch
also requires another ROM build and installation to change device behavior.
Do not apply it twice through different patch managers.

## Validation and limits

The actual C++ filter was compiled and exercised on the host with controlled
UID, PID and `/proc/self/cmdline` inputs: **43 checks, zero failures**.
Unpatched source failed nine checks. A counterprobe with only the allowlist
entry still fails the three late-rename cases. The host probe does not run
ART and does not establish ROM or device acceptance.

After installing a patched ROM, enable Morphe's **Process runtime** and
repeat the failing patch operation. Confirm that loading the LineageOS
framework resource no longer fails. This patch does not change ART heap
limits or fix the separate `Could not find contiguous low-memory space`
error.

**crDroid 17.0 device check (2026-10-27):** OnePlus 13, crDroid 17.0 build of 2026-10-25. The
device's `libc.so` carries the `app.morphe.manager` exemption next to the LineageOS updater.
Morphe Manager is installed with **Process runtime** enabled, and the maintainer reports that
the patcher runs cleanly; the device log shows no Morphe errors.

Source references: [Morphe launcher](https://github.com/MorpheApp/morphe-manager/blob/da8545c92c94b83e23adf7b573b46b282fa2b062/app/src/main/java/app/morphe/manager/patcher/runtime/ProcessRuntime.kt#L314),
[process runtime documentation](https://github.com/MorpheApp/morphe-manager/blob/da8545c92c94b83e23adf7b573b46b282fa2b062/docs/patching-process.md).
License: [LICENSE](LICENSE). An upstream fix replacing this patch must be
reviewed before removing the patch; do not silently weaken applicability checks.
