# SUSFS Core v1.0 — our patch-file context delta only

**Only our maintenance changes are included.** No complete upstream SUSFS core
patch, companion source, KernelSU hooks, userspace tools or binaries are bundled.
The tag identifies the reviewed patch-collection commit.

`susfs-core-context.patch` corrects context, positions and index metadata in
`kernel_patches/50_add_susfs_in_gki-android15-6.6.patch` from simonpunk/susfs4ksu,
branch `gki-android15-6.6`, commit `a0f9c59e2243f8a5db955f4ad1686d5e0ad26e1a`.
All original added/removed kernel-code lines remain unchanged.

**Two steps:** prepare this upstream checkout at `external/susfs4ksu` under the
crDroid build root, then run this module installer to correct its patch file.
Use the resulting upstream patch separately in your existing kernel integration.
The corrected file's SHA256 is
`17d0e86e625afab0bbe2a3e3a4f46d326aeec641930d8a922bd747e5955b9c4a`.
Kernel target: crDroid `16.0`, OnePlus sm8750 Android15/Linux6.6,
`b69d2cc667dd0a57adb78b54c9a3453f5c5a5b35`.

Local installer tests, upstream patch-file apply/reverse checks, exact result
reconstruction and isolated combined kernel applicability checks establish source
acceptance. **New kernel/ROM build and device acceptance remain pending.**
GPL Version3 upstream terms are preserved; the target kernel's GPL2 boundary
remains unresolved. Own docs/installer use Apache2.0. See LICENSE and NOTICE.
The repository/release stay private and Actions remain off.

Download `susfs-core-v1.0.zip` for only this module and read the
[tagged instructions](https://github.com/pschmidt3200/android-patches-crdroid/tree/susfs-core-v1.0/susfs-core).
Reversal restores the upstream patch file, not a separately patched kernel.

Deutsch: Ausschließlich unser Kontext-Korrekturdelta zur originalen SUSFS-Patchdatei,
kein vollständiger Core-Upload. Erst Upstream-Datei korrigieren, danach getrennt
in bestehende Kernelintegration übernehmen. Neuer Build/Gerätetest und GPL3/GPL2-
Abgrenzung bleiben offen; vorhandene V1-Tags bleiben unverändert.
