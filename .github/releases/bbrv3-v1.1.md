# BBRv3 v1.1 — bbr3 as the kernel TCP default

Second module edition for crDroid `16.0` and its OnePlus sm8750 Android15/Linux6.6
kernel, reference `b69d2cc667dd0a57adb78b54c9a3453f5c5a5b35`.
The release tag identifies the reviewed patch-collection commit.

* Add the companion `bbrv3-default-android15-6.6.patch` for
  `arch/arm64/configs/gki_defconfig`: it builds BBRv3 in and selects its registered
  name `bbr3` as the TCP default (`CONFIG_TCP_CONG_BBR3=y`, `CONFIG_DEFAULT_BBR3=y`,
  `CONFIG_DEFAULT_TCP_CONG="bbr3"`). BBRv1 (`bbr`) and other controllers remain available.
* The installer applies the unchanged v1.0 core patch first, then the companion.
  Apply both before generating the kernel `.config`.
* The real kernel Kconfig tool, using `gki_defconfig` and both `sun_perf` vendor
  fragments, resolves the default from `cubic` to `bbr3` with BBRv3 built in.

This is still the existing BBRv3 algorithm, **not Google's newer September2026 update**.
The patches do not change a running system; runtime tuning can override the kernel default.

Local structure/installer tests (34/34) and real source application/reversal of both
patches at the reference/current `16.0` branch are the source acceptance.
**New kernel/ROM build and device acceptance remain pending**; the reference device
currently runs BBRv1. The repository is public; module checks run on GitHub Actions on every push.

Download `bbrv3-v1.1.zip` for just the tagged module, or use the
[tagged instructions](https://github.com/pschmidt3200/android-patches-crdroid/tree/bbrv3-v1.1/bbrv3).
Keep the module files together. Kernel GPL/file terms and BBR's preserved
`Dual BSD/GPL` declaration differ from Apache2.0 for own docs/installer; see NOTICE.

Deutsch: V1.1 ergänzt einen separaten Zusatzpatch, der BBRv3 fest einbaut und `bbr3`
als TCP-Standard des Kernels wählt; BBRv1 bleibt verfügbar, der Kernpatch ist
unverändert. Neuer Build und Geräteabnahme bleiben offen. `bbrv3-v1.0` bleibt unverändert.
