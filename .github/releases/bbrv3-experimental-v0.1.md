# BBRv3 experimental v0.1 — testing only

**Experimental module. Use it only to test; for regular builds use `bbrv3`.**
It replaces `bbrv3` in a test build and must not be applied together with it.

Complete series for crDroid `16.0` and its OnePlus sm8750 Android15/Linux6.6 kernel,
reference `b69d2cc667dd0a57adb78b54c9a3453f5c5a5b35`:

* `bbrv3-android15-6.6.patch` and `bbrv3-default-android15-6.6.patch`, byte-identical to `bbrv3-v1.2`.
* `bbrv3-2026-experimental-android15-6.6.patch`: Google's TCP BBR branch
  `bbr-v3-2026-09-16-01` (revision `674859761ded`) backported to Linux 6.6 — DRAIN gain
  0.5 with a round limit, revised spurious-loss undo, BBR ECN/PLB removed. Google's BPF
  kfunc interface is not ported.

On a device, `/sys/module/tcp_bbr3/version` reads `3-2026x` while this edition runs.
An A/B test against `bbrv3` through a controlled 100 Mbit/s bottleneck showed no measurable
difference and no regression; targeted tests are still open. Details in the module README.

Download `bbrv3-experimental-v0.1.zip` for just the tagged module, or use the
[tagged instructions](https://github.com/pschmidt3200/android-patches-crdroid/tree/bbrv3-experimental-v0.1/bbrv3-experimental).
Kernel GPL/file terms and BBR's preserved `Dual BSD/GPL` declaration differ from
Apache2.0 for own docs/installer; see NOTICE.

Deutsch: Experimentelles Modul, nur zum Testen; für normale Builds `bbrv3` verwenden und
nie beide Module zusammen anwenden. Am Gerät zeigt `/sys/module/tcp_bbr3/version` dann `3-2026x`.
