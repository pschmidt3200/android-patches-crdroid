# Morphe Runtime Compatibility v1.0

Initial release for **crDroid 16.0 / Android 16**.

## Contents

* **Process exemption:** `crdroid_bionic_morphe_runtime.patch` (`bionic`) adds
  `app.morphe.manager` to the libc process allowlist already used for the LineageOS updater, so
  Morphe's separate ART patcher can load `org.lineageos.platform-res.apk`.
* **Late process names:** early calls under `/system/bin/app_process`, `app_process32` or
  `app_process64` stay filtered, but their negative result is not cached before `--nice-name`
  takes effect; `app.morphe.manager:Patcher` is covered. Other apps and look-alike names stay
  filtered; updater and zygote handling are unchanged.

This is a process-name compatibility rule, not a package-signature check. It does not change ART
heap limits or the separate `Could not find contiguous low-memory space` error.

The C++ filter was compiled and exercised on the host with controlled UID, PID and
`/proc/self/cmdline` inputs: 43 checks, zero failures (the unpatched source fails nine). The patch
applies and reverts cleanly at the NOTICE reference commit and on the current `16.0` branch. ROM
build and device verification remain pending.

## Requirements and source baselines

No ROM image, binaries or vendor firmware are included. Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/morphe-runtime-v1.0/morphe-runtime).

| Target repository | NOTICE reference commit |
|---|---|
| `bionic` | `fcfacc3e0ba78b59de4bdd46b8bec3676e5c305c` |

```bash
git switch --detach morphe-runtime-v1.0
bash morphe-runtime/apply-patches.sh --check /path/to/crdroid
```

## Deutsch

Erstveröffentlichung: Eine Prozessausnahme in libc lässt Morphes eigenen ART-Patcher die
LineageOS-Framework-Ressource laden, wie es für den LineageOS-Updater schon gilt. Frühe Aufrufe vor
dem endgültigen Prozessnamen bleiben gefiltert, ihr Ergebnis wird aber nicht vorzeitig
zwischengespeichert. Host-Prüfung 43/43; ROM-Build und Geräteabnahme stehen noch aus.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
