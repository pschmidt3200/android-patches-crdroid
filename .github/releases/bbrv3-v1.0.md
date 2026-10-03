# BBRv3 v1.0 — maintained crDroid sm8750 source patch

First module edition for crDroid `16.0` and its OnePlus sm8750 Android15/Linux6.6
kernel, reference `b69d2cc667dd0a57adb78b54c9a3453f5c5a5b35`.
The release tag identifies the reviewed patch-collection commit.

* Rebase the WildKernels backport at `41ae18b35d20e0c6ac04116785a4a1089528ae94`
  to the current kernel. TCP functionality and upstream authors are retained.
* Include standalone check/apply/reverse installer, English/German instructions,
  source hashes and distinct kernel/installer license notices.
* Packaging only: target header, five added-line whitespace trims and commented
  mail-preamble bullets/separator; productive input is unchanged.

This is the existing BBRv3 algorithm, **not Google's newer September2026 update**.
DRAIN-gain/round limit and expanded spurious-loss undo backport remain pending.
The patch does not enable BBRv3 in device configuration or change a running system.

Local structure/installer tests and real source application/reversal at the
reference/current `16.0` branch are the source acceptance. Combined BBR/SUSFS
application is checked in an isolated kernel index. **New kernel/ROM build,
device acceptance and throughput/latency measurements remain pending.**
The repository is public; module checks run on GitHub Actions on every push.

Download `bbrv3-v1.0.zip` for just the tagged module, or use the
[tagged instructions](https://github.com/pschmidt3200/android-patches-crdroid/tree/bbrv3-v1.0/bbrv3).
Keep the module files together. Kernel GPL/file terms and BBR's preserved
`Dual BSD/GPL` declaration differ from Apache2.0 for own docs/installer; see NOTICE.

Deutsch: Gepflegte V1 für den aktuellen crDroid-sm8750-Quellbaum, mit lokal
geprüftem Installer und Rücknahme. Neuere Google-Algorithmusänderungen sowie
neuer Build und Geräteabnahme bleiben offen. Bestehende V1-Tags werden nicht verändert.
