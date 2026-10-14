# SUSFS Core v1.1 — upstream sync & context delta

**Only our maintenance changes are included.** No complete upstream SUSFS core
patch, companion source, KernelSU hooks, userspace tools or binaries are bundled.
The tag identifies the reviewed patch-collection commit.

`susfs-core-context.patch` syncs with upstream simonpunk/susfs4ksu (branch `gki-android15-6.6`,
commit `2d11d711de80f0f749b3055f8da8f7b9682454e4`) and corrects context, hunk
positions and index metadata in `kernel_patches/50_add_susfs_in_gki-android15-6.6.patch`.
All original added/removed kernel-code lines remain exactly upstream.

**Two steps:** prepare this upstream checkout at `external/susfs4ksu` under the
crDroid build root, then run this module installer to correct its patch file.
Use the resulting upstream patch separately in your existing kernel integration.
The corrected file's SHA256 is
`e4a8d393105611dd09d1aa8d74907ea3611fe0e2b7c34fa08a694694aa127433`.
Original input SHA256 is `15587d2d46f5cdf9d707d46604cbdd57f9da865477c84545d7c4b6427a67a67c`.
Kernel target: crDroid `16.0`, OnePlus sm8750 Android15/Linux6.6,
`b69d2cc667dd0a57adb78b54c9a3453f5c5a5b35`.

Local installer tests, upstream patch-file apply/reverse checks, exact result
reconstruction and isolated reference-kernel applicability checks establish source
acceptance. Live device acceptance was previously established on OnePlus 13 with
v1.0; a new runtime build for this rebased edition remains pending.
GPL Version3 upstream terms are preserved; the target kernel's GPL2 boundary
remains unresolved. Own docs/installer use Apache2.0. See LICENSE and NOTICE.
The repository is public; module checks run on GitHub Actions on every push.

Download `susfs-core-v1.1.zip` for only this module and read the
[tagged instructions](https://github.com/pschmidt3200/android-patches-crdroid/tree/susfs-core-v1.1/susfs-core).
Reversal restores the upstream patch file, not a separately patched kernel.

Deutsch: Wartungsaktualisierung auf Upstream-Stand 2d11d711de80 (gki-android15-6.6).
Ausschließlich unser Kontext-Korrekturdelta zur originalen SUSFS-Patchdatei,
kein vollständiger Core-Upload. Erst Upstream-Datei korrigieren, danach getrennt
in bestehende Kernelintegration übernehmen. Quell- und Referenzabgleich grün;
neuer Build/Gerätetest für diese Fassung offen.
