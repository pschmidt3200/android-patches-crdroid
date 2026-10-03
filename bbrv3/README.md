# BBRv3 for crDroid sm8750

Maintained TCP BBRv3 source patch for **crDroid 16.0**, using its OnePlus
`sm8750` Android 15 / Linux 6.6 kernel. The ROM version and kernel Android
generation are different; this is not a general Android kernel port.

`patches/bbrv3-android15-6.6.patch` adds the BBRv3 congestion controller and
its TCP integration across 13 kernel files. It rebases the pinned WildKernels
backport on the current kernel without changing its algorithm.
The separate companion `patches/bbrv3-default-android15-6.6.patch` builds BBRv3
into the kernel and selects `bbr3` as its TCP congestion-control default in
`gki_defconfig`. The installer applies the core first, then the companion.
BBRv1 (`bbr`) and other congestion controllers remain available.

## Requirements and use

* Target: `kernel/oneplus/sm8750`, branch `16.0`, reference commit
  `b69d2cc667dd0a57adb78b54c9a3453f5c5a5b35`.
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

Source and helper validation is fully verified:

- 34 of 34 helper tests (`test-apply-script.sh bbrv3`) passed cleanly.
- Strict apply and reverse (2/2 patches) on reference commit `b69d2cc667dd` and current branch `16.0` (`check-reference.sh`).
- Successful core-patch dry-run simulation against the local OnePlus `sm8750` kernel tree.
- Combined BBRv3 core application with the corrected SUSFS upstream patch verified in an isolated kernel index.

**Documented kernel and device acceptance:** Validated live on the **OnePlus 13 (`dodge`, CPH2653)**
running Linux 6.6 (build `Sat Oct 3 23:45:41 CEST 2026`):
BBRv3 is active as the default congestion control algorithm (`net.ipv4.tcp_congestion_control = bbr3`),
kernel symbols (`bbr3_*`) are loaded, and all active TCP sockets (`ss -tin`) run on `bbr3`.
Source checks do not measure throughput or latency. Module checks run on GitHub Actions on every push.



## License

Kernel material follows upstream file notices and the kernel's
[COPYING](COPYING.kernel), [GPL text](LICENSE) and
[syscall exception](LICENSE-Linux-syscall-note). BBR core preserves its
`Dual BSD/GPL` declaration and authors; the exact BSD variant is not inferred.
Own documentation, metadata and installer use [Apache 2.0](LICENSE-APACHE-2.0).

[Deutsche Anleitung](README.de.md)

Mail preamble bullets and separator are comment-prefixed for strict patch parsing.
