# android-patches-crdroid

A curated collection of modular patches, framework improvements, and hardware integrations for **crDroid** and AOSP-based custom ROMs.

The goal of this repository is to maintain clean, modular source patches for AOSP/crDroid — including hardware-specific integrations where a module documents them — without bundled proprietary vendor binaries. The patches are applied directly to a compatible ROM source tree.

---

## Repository Structure

Patches and improvements are organized into topic-specific directories:

```text
android-patches-crdroid/
├── README.md                  # General documentation & overview
├── README.de.md               # German documentation
├── LICENSE                    # Repository license (Apache 2.0)
├── .github/                   # Issue form and CI checks (workflows/, scripts/)
│
├── aptx-adaptive/             # Qualcomm aptX Adaptive DSP offload & BT integration
│   ├── README.md              # Detailed module documentation & requirements
│   ├── README.de.md           # German module documentation
│   ├── apply-patches.sh       # Automated patch installation & verification script
│   ├── NOTICE                 # Upstream attribution, reference commits & licensing
│   ├── LICENSE                # Module license (Apache 2.0)
│   └── patches/               # .patch files (Bluetooth, frameworks, Settings, GameSpace, device)
│
└── [future-modules]/          # Future patch sets (kernel, system, display, etc.)
```

---

## How Modules Are Kept Apart

Every patch set is a **self-contained module directory**. A module never depends on, refers to or
documents another module unless its own README says so explicitly.

| Location | Belongs to | Contains |
|---|---|---|
| Repository root | the whole collection | this overview, the module index, the disclaimer and the default `LICENSE` — **no patches** |
| `<module>/` | exactly one patch set | `README.md` + `README.de.md`, `NOTICE` (upstream sources and reference commits), `LICENSE`, optional `apply-patches.sh` |
| `<module>/patches/` | that patch set only | `.patch` files; each starts with a `# Target repository:` header naming the Android repository it applies to |

Rules for every module:

* **One feature, one directory** (`kebab-case`). Unrelated changes never go into an existing module's `patches/`.
* **Docs describe only their own module:** requirements, crDroid branch, reference commits, tested devices and known limits.
* **Support ends where the module README ends.** A module is only as tested as its README states.
* **Scripts stay inside their module** and only touch that module's own `patches/` directory.
* **Editions are not mixed:** apply all patches of a module from the same commit of this repository.
* **The *Available Modules* list below is the only place where modules are linked together.**

These rules are checked automatically on every push: `.github/scripts/check-modules.sh` verifies the
layout, patch headers and format, and that script, READMEs and `NOTICE` name the same patches;
`.github/scripts/test-apply-script.sh` runs each module's `apply-patches.sh` against a throwaway tree.
Before a release, the manual *reference-check* workflow (`.github/scripts/check-reference.sh`) applies
the real patches to the real upstream sources at the commits listed in each module's `NOTICE` — or to
the current tip of a branch. It downloads only the files the patches touch. All three scripts can be
run locally from the repository root.

---

## Design Principles & Standards

* **Modular & Independent:** Each topic or feature resides in its own directory with dedicated documentation, requirements, and patch files.
* **Pure Source Diffs:** All patches are standard git diffs against upstream open-source code (AOSP / crDroid). No proprietary blobs, compiled firmware binaries, or device secrets are hosted here.
* **Upstream Hygiene:** Changes are kept atomic and cleanly separated by Android subsystem (`packages/modules/*`, `frameworks/*`, `hardware/*`).

---

## General Usage

Each subfolder contains its own detailed `README.md` with prerequisites, target commits, and instructions.

In general, patches can be applied using standard git tooling:
```bash
# Navigate to the target repository inside your ROM source tree
cd /path/to/android/source/<target-subrepo>

# Apply the respective patch
git apply /path/to/android-patches-crdroid/<module>/patches/<target_patch>.patch
```

---

## Available Modules

* **[aptX Adaptive Audio Integration](aptx-adaptive/):** Complete session setup and framework offload integration for Qualcomm hardware DSP audio.
  Base: crDroid branch `16.0` (Android 16). Reference device: OnePlus 13 (`dodge`). Other devices: untested.

---

## Reporting Problems

If a patch does not apply, does not build or misbehaves on the reference setup, please open an issue
with the **Patch problem** form and paste the exact error output. Remove Bluetooth MAC addresses and
serial numbers from logs before posting. Reports from other devices are welcome as information —
please read the disclaimer below first.

---

## Disclaimer & Support Notice

> [!IMPORTANT]
> **Personal / Hobby Project — Use at Your Own Risk:**
> * **Private Nature:** This repository is maintained in my spare time as a personal hobby project for custom ROM experimentation. It is **not** a commercially maintained distribution or a full-time support platform.
> * **No Universal Device Support:** Hardware tests are strictly limited to the devices I personally own and use (such as the OnePlus 13 reference device). I cannot test, port, or provide active troubleshooting/support for hardware I do not possess.
> * **For Experienced Builders:** These patches are intended for developers, ROM maintainers, and advanced users who are familiar with the Android build system, know how to interpret compilation errors, and know how to recover or debug their devices in case of boot issues or unexpected behavior.
> * **No Warranty:** Everything here is provided "as is", without warranty of any kind. You are solely responsible for any modifications made to your device or ROM builds.

---

## License

Unless otherwise stated within specific module subdirectories, patches and documentation in this repository are licensed under the **Apache License, Version 2.0**. See the [LICENSE](LICENSE) file for details.
