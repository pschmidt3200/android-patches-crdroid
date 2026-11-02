# SUSFS core context corrections for crDroid sm8750

**Only our maintenance delta is included.** `patches/susfs-core-context.patch`
removes the stray leading blank line of the original upstream patch file. It does not
contain a complete SUSFS core patch or change its added/removed kernel code.

Since upstream `c7f670f57b7d` the upstream core applies to crDroid's OnePlus sm8750 kernel
without any context correction; upstream now uses `vma_data_pages()` itself. The patch is
applicable to `kernel/oneplus/sm8750`, branch `17.0`, commit
`acb4c5815254d4ca0815d8740794ad40303197d5` (Android 15 / Linux 6.6),
used by crDroid 17.0, alone and after the `bbrv3` patches (checked 2026-11-02 in an isolated
kernel index). The crDroid 16.0 edition is frozen separately. Other revisions
require separate validation.

> **17.0 update, 2026-11-02:** moved to upstream `c7f670f57b7d` on `gki-android15-6.6`, which
> brings the priority UID filter that KernelSU-Next `dev-susfs` now binds (`0x60030`). Pinned
> and current-branch source application/reversal pass. Kernel additions, removals and context
> are identical to upstream. The kernel objects touched by the core compile together with
> KernelSU-Next `dev-susfs` `bea056e5` (no full kernel link). This edition is not yet built into
> a ROM or checked on a device. Device measurements below refer to the frozen crDroid 16.0
> edition, which stays on branch
> [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0/susfs-core).

## Two separate application steps

The module installer modifies **one upstream patch file**, not kernel sources.
Its target is a separate Git checkout at `external/susfs4ksu` under your crDroid
build root. Prepare it from the exact upstream revision if it is not already there:

```bash
cd /path/to/crdroid
git clone --branch gki-android15-6.6 https://gitlab.com/simonpunk/susfs4ksu.git external/susfs4ksu
git -C external/susfs4ksu checkout --detach c7f670f57b7d43d75066b6657f8aee9cdf580d96
```

From this patch collection, with all module files from the same edition:

```bash
bash susfs-core/apply-patches.sh --check /path/to/crdroid
bash susfs-core/apply-patches.sh /path/to/crdroid
sha256sum /path/to/crdroid/external/susfs4ksu/kernel_patches/50_add_susfs_in_gki-android15-6.6.patch
```

Expected corrected SHA256:
`570f59daec43fe603a80ab3905a254e4a505757d46bbd9bfab4876fdf0196012`.
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
application/reversal at the pinned upstream and the current `gki-android15-6.6`
branch, plus reconstruction of the exact corrected SHA256. The resulting full
patch is checked separately with BBRv3 in an isolated reference-kernel index.
**Documented kernel and device acceptance:** Validated live on the **OnePlus 13**
running Linux 6.6 (build `Sat Oct 3 23:45:41 CEST 2026`):
SUSFS `v2.3.0` (GKI) is initialized in kernel (`susfs is initialized! version: v2.3.0`), KSU integration
and userspace tools (`/data/adb/ksu/bin/susfs`) are active, and all kernel features (`SUS_PATH`,
`SUS_MOUNT`, `SUS_KSTAT`, `SPOOF_UNAME`, `HIDE_KSU_SUSFS_SYMBOLS`, `OPEN_REDIRECT`, `SUS_MAP`) are enabled.
Module checks run on GitHub Actions on every push.


## License boundary

[LICENSE](LICENSE) preserves the exact upstream **GPL Version 3** text at the
pinned revision. Own documentation, metadata and installer use
[Apache 2.0](LICENSE-APACHE-2.0). Upstream-derived patch material retains its
upstream terms. The target Linux kernel declares GPL-2.0-only; the GPL3/GPL2
boundary for a combined kernel remains unresolved. This source correction does
not establish compatibility or legal clearance. No upstream core or binaries
are bundled. Preserve upstream authors and individual file notices.

[Deutsche Anleitung](README.de.md)
