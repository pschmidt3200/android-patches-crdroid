# Oplus Hardware Fixes

Two correctness fixes for `hardware/oplus` on **crDroid 16.0 (Android 16)**: the LTPO
settings screen now shows the panel's real configuration instead of the last stored
preference, and the touch HAL validates driver and Binder responses instead of assuming
they succeeded.

Neither patch enables a feature, changes a sampling rate or touches a kernel node. They
make existing code tell the truth when the hardware says no.

---

## What they fix

### LTPO: show the current configuration, not the last wish

`crdroid_oplus_ltpo_readback.patch`

The settings screen stored your selection and showed it back to you — even if the panel
never accepted it. After a failed write the toggle claimed a state the hardware was not in.

Now the screen reads the panel's `adfr_config` mask when it opens and on resume. A
selection is stored only after writing, flushing, closing and an **exact read-back** of
the mask have all succeeded. If the mask cannot be read, the toggle is disabled rather
than showing a stored wish; if a write fails, the screen shows the actual value where it
can be read. Automatic preference persistence is suppressed, so nothing is saved behind
your back.

### Touch HAL: stop on failure instead of reporting success

`crdroid_oplus_touch_error_handling.patch`

Three paths assumed their writes had worked:

* **GloveMode** now checks the Binder status, negative driver write responses and the read
  format. Empty or malformed answers are an error instead of an implied "off". The existing
  `status:counter` format stays valid (for example `1:2`, `0:10`, `1:100`); only the first
  field determines the reported state.
* **TouchscreenGesture** accepts only configured keycodes, bounded before subtraction and
  shifting, and parses the whole hexadecimal mask response without throwing. The resulting
  decimal mask must fit into eight bytes before any write — longer values are silently
  ignored by the driver, which still reports success.
* **Both touch write steps** check the Binder status and a negative driver result. After the
  first failure no second write is attempted, so a half-applied state cannot arise. The
  power double-tap path additionally validates the vendor proxy and reports parsing or
  write failures locally.

Gesture nodes, the gesture list and touch sampling rates are unchanged.

---

## Prerequisites

* crDroid 16.0 source tree with `hardware/oplus`
* An Oplus/OnePlus device whose tree uses that repository

Both patches apply to `hardware/oplus` only. See `NOTICE` for the exact upstream commit
this series was prepared against.

## Install

```bash
# 1. Check compatibility first (simulates the whole series, modifies nothing):
./apply-patches.sh --check /path/to/crdroid

# 2. Apply:
./apply-patches.sh /path/to/crdroid

# 3. Revert later if needed:
./apply-patches.sh --reverse /path/to/crdroid
```

## Verification

Both patches were applied to a clean `hardware/oplus` at the commit named in `NOTICE`,
then reverted; forward and reverse apply cleanly.

On the reference device (OnePlus 13, crDroid 16.0 build of 2026-10-07):

* **LTPO** — toggling off wrote `adfr_config` from `0x109f` to `0x0`; reopening the screen
  showed the switch **off**, that is the real state rather than the stored preference.
  Toggling back restored exactly `0x109f`, not a partial mask. The display continued to run
  at variable refresh rates (120/90/60 fps) and the log stayed clean.
* **Touch** — double-tap-to-wake was switched on and off under *Settings → Display* and both
  directions worked. The patched path logged the full chain: reading the gesture type,
  writing `gesture_enabled`, writing `gesture_type`, and the driver's success acknowledgement.
  All three touch HAL interfaces stayed registered with no errors after boot.

Glove mode was not exercised on the reference device (not used there), so its fix rests on
the isolated test suite rather than on device verification.

## Scope and limits

* No vendor binaries, firmware or driver source are included or modified.
* No feature is enabled that was not already enabled; no touch rate is raised.
* The error paths these patches guard do not occur in normal operation. Their value shows up
  when a driver or Binder call fails — then nothing crashes, nothing is half-written, and the
  user interface no longer claims a state the hardware is not in.
* Tested on one device family. Reports from other Oplus devices are welcome as information.

## License

Apache License, Version 2.0 — see `LICENSE` and `NOTICE`.
