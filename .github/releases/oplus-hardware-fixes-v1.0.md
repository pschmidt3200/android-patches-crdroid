# Oplus Hardware Fixes v1.0

> **Superseded.** This is the final crDroid 16.0 edition; for crDroid 17.0 use [Oplus Hardware Fixes v2.0](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/oplus-hardware-fixes-v2.0).
> On a crDroid 16.0 tree this release stays valid (branch `16.0`). Deutsch: Letzte crDroid-16.0-Fassung; für crDroid 17.0 gilt Oplus Hardware Fixes v2.0, für 16.0-Bäume bleibt diese Fassung gültig.

First public module release for **crDroid 16.0 / Android 16**. Two correctness
fixes for `hardware/oplus`: the LTPO settings screen shows the panel's real
configuration instead of the last stored preference, and the touch HAL validates
driver and Binder responses instead of assuming they succeeded.

Neither patch enables a feature, changes a sampling rate or writes a kernel node.
They make existing code tell the truth when the hardware says no.

## Included changes

* `crdroid_oplus_ltpo_readback.patch` — the settings screen reads the panel's
  `adfr_config` mask on open and on resume. A selection is stored only after
  writing, flushing, closing and an **exact read-back** have all succeeded. If the
  mask cannot be read, the toggle is disabled rather than presenting a stored wish
  as the current state; automatic preference persistence is suppressed.
* `crdroid_oplus_touch_error_handling.patch` — **GloveMode** checks the Binder
  status, negative driver write responses and the read format (the existing
  `status:counter` format stays valid; only the first field decides the reported
  state). **TouchscreenGesture** accepts only configured keycodes, bounded before
  subtraction and shifting, and parses the full hexadecimal mask without throwing;
  the resulting decimal mask must fit into eight bytes, because longer values are
  ignored by the driver while it still reports success. **Both touch write steps**
  check the Binder status and a negative driver result, and after the first failure
  no second write is attempted, so a half-applied state cannot arise.

No gesture node, gesture list or touch sampling rate is modified.

Read the [module instructions](https://github.com/pschmidt3200/android-patches-crdroid/tree/oplus-hardware-fixes-v1.0/oplus-hardware-fixes)
before choosing this on a build.

## Source baselines

| Target repository | NOTICE reference commit |
|---|---|
| `hardware/oplus` | `2c423457fffc1eea6d1eeb21abf26af66e541186` |

```bash
git switch --detach oplus-hardware-fixes-v1.0
bash oplus-hardware-fixes/apply-patches.sh --check /path/to/crdroid
```

## Verified on a device, and what was not

Verified on a OnePlus 13, crDroid 16.0 build of 2026-10-07:

* **LTPO** — toggling off wrote `adfr_config` from `0x109f` to `0x0`; reopening the
  screen showed the switch **off**, that is the real state rather than the stored
  preference. Toggling back restored exactly `0x109f`, not a partial mask. The
  display continued to run at variable refresh rates (120/90/60 fps) and the log
  stayed clean.
* **Touch** — double-tap-to-wake was switched on and off under *Settings → Display*,
  both directions worked, and the patched path logged the full chain: reading the
  gesture type, writing `gesture_enabled`, writing `gesture_type`, and the driver's
  acknowledgement. All three touch HAL interfaces stayed registered with no errors
  after boot.

**Not verified on a device: glove mode.** It is not used on the reference device,
so that fix rests on the isolated test suite rather than on device verification.

Because the guarded error paths do not occur in normal operation, their value shows
up only when a driver or Binder call fails — then nothing crashes, nothing is
half-written, and the interface no longer claims a state the hardware is not in.
Tested on one device family; reports from other Oplus devices are welcome.

## Validation

Publication checks metadata and format, installer behaviour, and real source
application **and reversal** at the NOTICE commit and against the current
Android 16 branches.

## Deutsch

Erste öffentliche V1 der zwei Korrektheitsfixes für `hardware/oplus`. Der
LTPO-Bildschirm liest die echte `adfr_config`-Maske des Panels statt der zuletzt
gespeicherten Absicht; der Touch-HAL prüft Binder-Status und Treiberantworten,
statt Erfolg zu unterstellen. Keine Funktion wird freigeschaltet, keine Abtastrate
geändert, kein Kernel-Node geschrieben. **Am Gerät belegt** sind LTPO-Rückschreiben
(0x109f → 0x0 → 0x109f) und der Doppeltipp-Pfad; **nicht am Gerät geprüft** ist der
Handschuhmodus — dort trägt nur die Testsuite.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
