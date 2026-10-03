# SUSFS core context corrections for crDroid sm8750

**Only our maintenance delta is included.** `patches/susfs-core-context.patch`
corrects the original upstream patch file's context, hunk positions and index
metadata for crDroid's OnePlus sm8750 kernel. It does not contain a complete
SUSFS core patch or change its added/removed kernel code.

The relevant context now uses `vma_data_pages()` instead of the obsolete
`vma_pages()`. The corrected complete upstream patch is applicable to
`kernel/oneplus/sm8750`, branch `16.0`, commit
`b69d2cc667dd0a57adb78b54c9a3453f5c5a5b35` (Android 15 / Linux 6.6),
used by crDroid 16.0. Other revisions require separate validation.

## Two separate application steps

The module installer modifies **one upstream patch file**, not kernel sources.
Its target is a separate Git checkout at `external/susfs4ksu` under your crDroid
build root. Prepare it from the exact upstream revision if it is not already there:

```bash
cd /path/to/crdroid
git clone --branch gki-android15-6.6 https://gitlab.com/simonpunk/susfs4ksu.git external/susfs4ksu
git -C external/susfs4ksu checkout --detach a0f9c59e2243f8a5db955f4ad1686d5e0ad26e1a
```

From this patch collection, with all module files from the same edition:

```bash
bash susfs-core/apply-patches.sh --check /path/to/crdroid
bash susfs-core/apply-patches.sh /path/to/crdroid
sha256sum /path/to/crdroid/external/susfs4ksu/kernel_patches/50_add_susfs_in_gki-android15-6.6.patch
```

Expected corrected SHA256:
`17d0e86e625afab0bbe2a3e3a4f46d326aeec641930d8a922bd747e5955b9c4a`.
The original input SHA256 and upstream attribution are in [NOTICE](NOTICE).
The installer rejects an already modified target checkout by default.
`--check --reverse` followed by `--reverse` restores **that patch file**;
it does not undo a separate application to your kernel.

Then use the corrected upstream patch with your existing SUSFS/KernelSU kernel
integration. Inspect with `git apply --check` in the target kernel before applying.
This module does not install companion `fs/susfs.c`, `include/linux/susfs.h`,
`include/linux/susfs_def.h`, KernelSU hooks, configuration or userspace tools.
Obtain matching components separately from the pinned upstream and review its
instructions. Existing/custom hooks may conflict. Core source version `v2.3.0`
and WildKernels fix-package version `v2.2.0` are independent.

## Validation and limits

Local checks cover structure, standalone installer behaviour, real patch-file
application/reversal at the pinned upstream and its current `gki-android15-6.6`
branch, plus reconstruction of the exact corrected SHA256. The resulting full
patch is checked separately with BBRv3 in an isolated reference-kernel index.
**No new kernel/ROM build or device acceptance is established.** This is not a
complete SUSFS installer or a guarantee that apps accept a modified system.
Module checks run on GitHub Actions on every push. Productive patch files stay
unchanged; only the delta is uploaded here.

## License boundary

[LICENSE](LICENSE) preserves the exact upstream **GPL Version 3** text at the
pinned revision. Own documentation, metadata and installer use
[Apache 2.0](LICENSE-APACHE-2.0). Upstream-derived patch material retains its
upstream terms. The target Linux kernel declares GPL-2.0-only; the GPL3/GPL2
boundary for a combined kernel remains unresolved. This source correction does
not establish compatibility or legal clearance. No upstream core or binaries
are bundled. Preserve upstream authors and individual file notices.

[Deutsche Anleitung](README.de.md)
