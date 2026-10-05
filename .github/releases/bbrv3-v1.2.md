# BBRv3 v1.2 — ECN flag correction in the core patch

Third module edition for crDroid `16.0` and its OnePlus sm8750 Android15/Linux6.6
kernel, reference `b69d2cc667dd0a57adb78b54c9a3453f5c5a5b35`.
The release tag identifies the reviewed patch-collection commit.

* Correct one added line of `bbrv3-android15-6.6.patch`: `TCP_ECN_ECT_PERMANENT` in
  `include/net/tcp.h` is now `32`, the value of Google's BBRv3 tree. The previous value
  `3` overlapped `TCP_ECN_OK|TCP_ECN_QUEUE_CWR`, so `tcp_ecn_send()` left ECT set on
  pure ACKs and retransmissions of every ECN-negotiated connection, independent of
  the congestion control in use.
* The default companion `bbrv3-default-android15-6.6.patch` is unchanged.
* The algorithm is unchanged; this is still the existing BBRv3 algorithm,
  **not Google's newer September2026 update**.

Source acceptance: real application, reversal and re-application of the core alone and
of core plus companion at the reference `16.0` commit, without fuzz or offset.
**New kernel/ROM build and device acceptance remain pending.**

Download `bbrv3-v1.2.zip` for just the tagged module, or use the
[tagged instructions](https://github.com/pschmidt3200/android-patches-crdroid/tree/bbrv3-v1.2/bbrv3).
Keep the module files together. Kernel GPL/file terms and BBR's preserved
`Dual BSD/GPL` declaration differ from Apache2.0 for own docs/installer; see NOTICE.

Deutsch: V1.2 korrigiert eine Zeile im Kernpatch: `TCP_ECN_ECT_PERMANENT` ist jetzt `32`
wie bei Google. Mit `3` blieb ECT bei ECN-Verbindungen auf reinen ACKs und
Wiederholungen gesetzt. Zusatzpatch und Algorithmus sind unverändert;
neuer Build und Geräteabnahme bleiben offen.
