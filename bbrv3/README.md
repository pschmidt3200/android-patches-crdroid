# BBRv3 for crDroid sm8750

Maintained TCP BBRv3 source patch for **crDroid 17.0**, using its OnePlus
`sm8750` Android 15 / Linux 6.6 kernel. The ROM version and kernel Android
generation are different; this is not a general Android kernel port.

`patches/bbrv3-android15-6.6.patch` adds the BBRv3 congestion controller and
its TCP integration across 13 kernel files. It rebases the pinned WildKernels
backport on the current kernel without changing its algorithm.
The separate companion `patches/bbrv3-default-android15-6.6.patch` builds BBRv3
into the kernel and selects `bbr3` as its TCP congestion-control default in
`gki_defconfig`. The installer applies the core first, then the companion.
BBRv1 (`bbr`) and other congestion controllers remain available.

> **crDroid 17.0 edition: shared patches verified on the device.** These patches target crDroid
> 17.0 and apply and revert cleanly at the [`NOTICE`](NOTICE) reference commits. On 2026-10-26,
> a OnePlus 13 ran the maintainer's crDroid 17.0 build of 2026-10-25 (made from this repository
> at commit `4bdecab`) with the [bbrv3-experimental](../bbrv3-experimental/) series, whose first
> two patches are byte-identical to this module's; `bbr3` was the default congestion control and
> all established TCP connections used it; see *Packaging and validation*. The 16.0 edition
> stays on branch
> [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0/bbrv3).

## Requirements and use

* Target: `kernel/oneplus/sm8750`, branch `17.0`, reference commit
  `48baf0c723f8d6d1efa4db9d2cb5ad6df83ab976`.
* Reference hardware: OnePlus 13 / Pad 3 using this shared kernel.
  Other kernel trees and devices require their own validation.
* Bash and Git; keep all module files from the same patch commit/tag.
  Reconcile previous BBR modifications before using this edition.

```bash
bash bbrv3/apply-patches.sh --check /path/to/crdroid
bash bbrv3/apply-patches.sh /path/to/crdroid
# To remove this source change:
bash bbrv3/apply-patches.sh --check --reverse /path/to/crdroid
bash bbrv3/apply-patches.sh --reverse /path/to/crdroid
```

The installer checks source applicability in a sandbox and refuses to modify
a dirty target repository by default. Apply the series before generating the
kernel `.config`, then build and install the kernel/ROM. The companion sets
`CONFIG_TCP_CONG_BBR3=y`, `CONFIG_DEFAULT_BBR3=y` and
`CONFIG_DEFAULT_TCP_CONG="bbr3"`. It does not change a running device.

The real kernel Kconfig tool resolved `gki_defconfig` with both
`vendor/sun_perf.config` and `vendor/oplus/sun_perf.config`: the default changed
from `cubic` to `bbr3`, with BBRv3 built in. After installing a new build, check
`/proc/sys/net/ipv4/tcp_congestion_control`; runtime tuning can override the
kernel default. Device verification remains pending.

## Algorithm status, checked 2026-10-03

All 38 compared constants agree with Google's published TCP `v3` revision
`90210de4b779d40496dee0b89081780eeddf2a60` (2025-03-18).
The newer Google branch `bbr-v3-2026-09-16-01`, revision
`674859761ded9f32690c7bdaf22ef585531452ed`, contains further changes:

| Area | This edition | New Google TCP BBR |
|---|---|---|
| DRAIN pacing gain | `88/256` (~0.344) | `128/256` (0.5) |
| DRAIN round limit | absent | exit after more than 3 rounds |
| Spurious loss undo | earlier model-bound restoration | save before first lost skb and restore STARTUP/PROBE_UP state |
| PROBE_UP congestion window | 2.25 BDP already present | 2.25 BDP |

The newer implementation also changes ECN/PLB handling, private congestion-control
storage and callback/BPF interfaces. Those changes need a targeted Android 6.6
backport. **They are not included in this release.** Being current with the pinned
WildKernels patch does not mean this contains Google's newest algorithm.
QUICHE has its own QUIC implementation; this patch affects TCP only.

Comparison sources: [Google TCP v3](https://github.com/google/bbr/blob/90210de4b779d40496dee0b89081780eeddf2a60/net/ipv4/tcp_bbr.c),
[newer Google TCP](https://github.com/google/bbr/blob/674859761ded9f32690c7bdaf22ef585531452ed/net/ipv4/tcp_bbr3.c),
[QUICHE comparison](https://github.com/google/quiche/blob/f9e75eb8ab1de3ea1c422deb561abbaa84ef2df6/quiche/quic/core/congestion_control/bbr3_sender.cc).

## Packaging and validation

Source, authors, revisions and SHA256 values are in [NOTICE](NOTICE).
This repository adds a target header and trims trailing whitespace in five
added lines; the productive maintained patch remains unchanged.
The editions therefore have different byte hashes, with no algorithm change.
Edition v1.2 corrects one added line: `TCP_ECN_ECT_PERMANENT` is now `32`, as in
Google's tree; `3` overlapped `TCP_ECN_OK|TCP_ECN_QUEUE_CWR` and kept ECT on pure
ACKs and retransmissions of ECN connections. An experimental update of the algorithm
is kept apart in the testing-only module [bbrv3-experimental](../bbrv3-experimental/).

Source and helper validation is fully verified:

- 34 of 34 helper tests (`test-apply-script.sh bbrv3`) passed cleanly.
- Strict apply and reverse (2/2 patches) on reference commit `48baf0c723f8` and current branch `17.0` (`check-reference.sh`, 2026-10-20);
  before that on the 16.0 commit `b69d2cc667dd`.
- Successful core-patch dry-run simulation against the local OnePlus `sm8750` kernel tree.
- Combined BBRv3 core application with the corrected SUSFS upstream patch verified in an isolated kernel index,
  for the 16.0 kernel and for the 17.0 kernel `48baf0c723f8` (2026-10-20).

**Documented kernel and device acceptance:** Validated live on the **OnePlus 13**
running Linux 6.6 (build `Sat Oct 3 23:45:41 CEST 2026`):
BBRv3 is active as the default congestion control algorithm (`net.ipv4.tcp_congestion_control = bbr3`),
kernel symbols (`bbr3_*`) are loaded, and all active TCP sockets (`ss -tin`) run on `bbr3`.

**crDroid 17.0 device check (2026-10-26):** OnePlus 13, kernel 6.6.144, build of 2026-10-25:
`net.ipv4.tcp_congestion_control = bbr3`, available `reno bbr bbr3 cubic`, and `ss -tin`
showed `bbr3` on all 29 established connections, including NAT64 destinations. That build
used the testing-only [bbrv3-experimental](../bbrv3-experimental/) series instead
(`/sys/module/tcp_bbr3/version` = `3-2026x`), whose patches 1 and 2 are byte-identical to this
module's two patches. The check therefore confirms these shared patches (registration and
default), not this module's unchanged algorithm alone.

Source checks do not measure throughput or latency. Module checks run on GitHub Actions on every push.



## License

Kernel material follows upstream file notices and the kernel's
[COPYING](COPYING.kernel), [GPL text](LICENSE) and
[syscall exception](LICENSE-Linux-syscall-note). BBR core preserves its
`Dual BSD/GPL` declaration and authors; the exact BSD variant is not inferred.
Own documentation, metadata and installer use [Apache 2.0](LICENSE-APACHE-2.0).

[Deutsche Anleitung](README.de.md)

Mail preamble bullets and separator are comment-prefixed for strict patch parsing.
