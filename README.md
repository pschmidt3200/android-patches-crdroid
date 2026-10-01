# android-patches-crdroid

A curated collection of modular patches, framework improvements, and hardware integrations for **crDroid** and AOSP-based custom ROMs.

The goal of this repository is to maintain clean, vendor-neutral source patches that can be applied directly to a ROM build tree or integrated via local manifests.

---

## Repository Structure

Patches and improvements are organized into topic-specific directories:

```text
android-patches-crdroid/
├── README.md                  # General documentation & overview
├── README.de.md               # German documentation
├── LICENSE                    # Repository license (Apache 2.0)
│
├── aptx-adaptive/             # Qualcomm aptX Adaptive DSP offload & BT integration
│   ├── README.md              # Detailed module documentation & requirements
│   ├── README.de.md           # German module documentation
│   ├── apply-patches.sh       # Automated patch installation & verification script
│   ├── NOTICE                 # Upstream attribution & component licensing
│   └── patches/               # Target-specific .patch files (Bluetooth, Framework, HAL)
│
└── [future-modules]/          # Future patch sets (kernel, system, display, etc.)
```

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
