# BBRv3 experimental 2026 update for crDroid sm8750

> **EXPERIMENTAL — use only if you want to test something.**
> For regular builds use the [bbrv3](../bbrv3/) module. This module is a
> replacement for a test build, **never an addition**: do not apply both modules
> to the same kernel tree. It has no measured benefit over `bbrv3` so far (see
> *Measurements*), and Google's newer upstream code is not yet a finished release.

This module carries a complete series for **crDroid 16.0** and its OnePlus
`sm8750` Android 15 / Linux 6.6 kernel:

1. `patches/bbrv3-android15-6.6.patch` — the BBRv3 core, byte-identical to `bbrv3` v1.2.
2. `patches/bbrv3-default-android15-6.6.patch` — builds BBRv3 in and selects `bbr3`
   as the TCP default, byte-identical to the `bbrv3` companion.
3. `patches/bbrv3-2026-experimental-android15-6.6.patch` — **the experiment**: Google's
   TCP BBR branch `bbr-v3-2026-09-16-01` (revision `674859761ded`) backported to Linux 6.6.

## What the experiment changes

| Area | `bbrv3` core | This experiment (Google 2026) |
|---|---|---|
| DRAIN pacing gain | `88/256` (~0.344) | `128/256` (0.5) |
| DRAIN round limit | absent | exit after more than 3 rounds |
| Spurious loss undo | earlier model-bound restoration | save state before the first lost skb, restore STARTUP/PROBE_UP |
| BBRv3-specific ECN, `ecn_low`, PLB | present | removed, as in Google's update (generic TCP ECN and kernel PLB unchanged) |

Linux 6.6 cannot take Google's file unchanged. The adaptation keeps the core's
heap-private state and callback interface; Google's BPF kfunc interface is **not**
ported. The Linux 6.6 core's `tcp_congestion_ops.min_tso_segs` hook is retained
(Google's 2026 version no longer registers that callback, while keeping internal
TSO/GSO helpers), so a comparison against `bbrv3` measures only the algorithm update. Details and sources are in [NOTICE](NOTICE).

## Requirements and use

* Target: `kernel/oneplus/sm8750`, branch `16.0`, reference commit
  `b69d2cc667dd0a57adb78b54c9a3453f5c5a5b35`, on a tree **without** the `bbrv3` module.
* Reference hardware: OnePlus 13 / Pad 3 using this shared kernel.
* Bash and Git; keep all module files from the same patch commit/tag.

```bash
bash bbrv3-experimental/apply-patches.sh --check /path/to/crdroid
bash bbrv3-experimental/apply-patches.sh /path/to/crdroid
# To return to a regular build, remove it and use the bbrv3 module instead:
bash bbrv3-experimental/apply-patches.sh --check --reverse /path/to/crdroid
bash bbrv3-experimental/apply-patches.sh --reverse /path/to/crdroid
```

The installer checks the whole series in a sandbox and refuses to modify a dirty
target repository by default. Apply before generating the kernel `.config`.

**Check on the device** that the experiment kernel really runs:

```bash
adb shell cat /sys/module/tcp_bbr3/version
```

`3-2026x` means this experiment is active; the regular `bbrv3` kernel reports `3`.
`/proc/sys/net/ipv4/tcp_congestion_control` should read `bbr3` in both cases.

## Measurements

Uploads from a OnePlus 13 (`dodge`) over Wi-Fi 7 to a wired host, `iperf3`, 20 s
single stream, five rounds per kernel, through an identical controlled bottleneck
(100 Mbit/s, +20 ms delay, 0.3 % random loss) so Wi-Fi variation does not decide the
result. Medians, exact two-sided Mann-Whitney test:

| `bbr3` | `bbrv3` core | Experiment | p |
|---|---|---|---|
| Throughput | 47.3 Mbit/s | 45.2 Mbit/s | 1.00 |
| Retransmits | 304 | 268 | 0.04 * |
| TCP RTT | 36 ms | 43 ms | 0.69 |
| Ping under load | 62 ms | 69 ms | 0.42 |

\* The control algorithms (`bbr`, `cubic`) showed a similar drop in retransmits in
the same period, so this is not attributed to the experiment. Result: **no
measurable difference and no regression** in this scenario. Random loss does not
trigger the spurious-loss undo, and 20 s runs weigh the DRAIN change little;
targeted tests (packet reordering, short flows) have not been done.

**Device acceptance:** OnePlus 13 (`dodge`, CPH2653), kernel build
`Sun Oct 4 11:15:40 CEST 2026`: `version` = `3-2026x`, `bbr3` default, 64
established TCP sockets on `bbr3` (`ss -tin`), no BBR/TCP warnings in the kernel log. The
complete kernel and its modules were built from the patched tree.

## Packaging and validation

Patches 1 and 2 are copies of the `bbrv3` module files (SHA256 in [NOTICE](NOTICE)).
Patch 3 was validated before packaging on the reference commit: strict apply,
reverse and re-apply with fuzz 0 on both the v1.1 and the v1.2 core, with and
without the companion; ARM64 compile of `tcp_bbr3.o` and the touched TCP objects
with Android clang `r563880c`, no warnings. The packaged file differs from the
tested one only in its comment header and one code comment.

## License

Kernel material follows upstream file notices and the kernel's
[COPYING](COPYING.kernel), [GPL text](LICENSE) and
[syscall exception](LICENSE-Linux-syscall-note). Google's algorithm file is
`GPL-2.0 OR BSD-3-Clause`; BBR preserves its `Dual BSD/GPL` declaration and authors.
Own documentation, metadata and installer use [Apache 2.0](LICENSE-APACHE-2.0).

[Deutsche Anleitung](README.de.md)
