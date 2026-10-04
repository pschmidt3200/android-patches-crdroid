# android-patches-crdroid

A curated collection of modular patches, framework improvements, and hardware integrations for **crDroid**.

The goal of this repository is to maintain clean, modular source patches for crDroid — including hardware-specific integrations where a module documents them — without bundled proprietary vendor binaries. The patches are applied directly to a compatible crDroid source tree.

**Current ROM scope: crDroid only.** Each module documents its crDroid branch and reference hardware. Support for other ROMs has not been established.

**Current repository status: public; GitHub Actions enabled.** Module checks run on every push. Kernel modules retain their upstream license terms; read each module's `NOTICE` before building or redistributing.

---

## Available Modules

Patches are organized into topic-specific, self-contained module directories:

### Hardware & Media Subsystems
* **[aptx-adaptive](aptx-adaptive/):** Hardware stack integration for Qualcomm FastConnect 7900 / SM8750 (aptX Adaptive, 44.1 kHz Lossless, Game Audio low-latency mode). Reference hardware: OnePlus 13 (`dodge`), OnePlus Pad 3 / Pad 2 Pro (`erhai`).

### User Interface & Preferences
* **[donation-disable](donation-disable/):** Removal of donation prompts and promotional entries in crDroidSettings. Scope: Universal (crDroid 16.0).

### System Services & Networking
* **[gps-servers](gps-servers/):** Configuration of privacy-preserving SUPL (location) and NTP (time sync) server endpoints. Scope: Universal (crDroid 16.0).
* **[gms-fixes](gms-fixes/):** Package visibility and permission adjustments for Google Play Services (GApps / MicroG). Scope: Universal (crDroid 16.0 with GApps).

### Kernel Subsystems
* **[bbrv3](bbrv3/):** Google BBRv3 TCP congestion-control implementation for Linux 6.6 kernels.
* **[bbrv3-experimental](bbrv3-experimental/):** Experimental update of the TCP congestion-control patch, for testing only; replaces `bbrv3` in a test build.
* **[susfs-core](susfs-core/):** Patch corrections for the SUSFS kernel driver module. Scope: Linux Kernel 6.6.

---

## How to Use These Modules

### Option 1: Download a Ready-to-Use Module Release (Recommended)

For individual modules, you do not need to clone this entire repository:
1. Go to the [Releases page](https://github.com/pschmidt3200/android-patches-crdroid/releases) and download the `<module>-<version>.zip` of your choice (e.g. `aptx-adaptive-v1.2.zip`).
2. Extract the archive into your crDroid source directory.
3. Open a terminal, navigate into the extracted module folder, and run:
   ```bash
   ./apply-patches.sh
   ```
   The script checks whether your source tree is compatible and cleanly applies all necessary patches.

### Option 2: Using the Complete Git Repository

```bash
# Clone the repository
git clone https://github.com/pschmidt3200/android-patches-crdroid.git
cd android-patches-crdroid

# Switch to a specific collection release (e.g. v1.0)
git switch --detach v1.0

# Run the installer for the desired module
cd <module-directory>
./apply-patches.sh
```

Alternatively, patches can be applied manually with standard git tooling:
```bash
cd /path/to/crdroid/source/<target-repository>
git apply /path/to/android-patches-crdroid/<module>/patches/<target_patch>.patch
```

---

## How Modules Are Kept Apart

Every patch set is a **self-contained module directory**. A module never depends on, refers to, or documents another module unless its own README explicitly says so.

| Location | Belongs to | Contains |
|---|---|---|
| Repository root | the whole collection | Overview, module index, disclaimer, and default `LICENSE` — **no patches** |
| `<module>/` | exactly one patch set | `README.md` + `README.de.md`, `NOTICE` (upstream sources & reference commits), `LICENSE`, `installer.json`, and standalone `apply-patches.sh` |
| `<module>/patches/` | that patch set only | `.patch` files; each starts with a `# Target repository:` header naming the Android repository it applies to |

**Core rules for every module:**
* **One feature, one directory** (`kebab-case`). Unrelated changes never go into an existing module's `patches/`.
* **Pure source diffs:** Patches are standard git diffs against source and build configuration used by crDroid. No proprietary blobs, compiled firmware binaries, or device secrets are hosted here.
* **Docs describe only their own module:** Requirements, crDroid branch, reference commits, tested devices, and known limits.
* **Support ends where the module README ends:** A module is only as tested as its README states.
* **Scripts stay inside their module** and only touch that module's own `patches/` directory.
* **Editions are not mixed:** Apply all patches of a module from the same commit or release archive.

---

## Reporting Problems

If a patch does not apply, does not build, or misbehaves on the reference setup, please [open an issue](https://github.com/pschmidt3200/android-patches-crdroid/issues/new?template=patch-problem.yml) using the **Patch problem** template.

Please include:
* The module name and release tag (e.g. `aptx-adaptive-v1.2`) or commit SHA.
* The exact error output or relevant log excerpt.
* Please remove personal data (Bluetooth MAC addresses, serial numbers) from logs before posting.

Reports from other devices are welcome as informational feedback. Please check the disclaimer below before reporting.

---

## Module Releases

The [V1 collection release](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/v1.0) freezes the complete 2026-10-01 source-patch collection. Its module editions are:

| Module | Release tag |
|---|---|
| `aptx-adaptive` | `aptx-adaptive-v1.2` |
| `gms-fixes` | `gms-fixes-v1.0` |
| `gps-servers` | `gps-servers-v1.0` |
| `donation-disable` | `donation-disable-v1.0` |

Separate kernel editions added on 2026-10-03: `bbrv3-v1.0`, `bbrv3-v1.1`, `bbrv3-v1.2`, `bbrv3-experimental-v0.1`, and `susfs-core-v1.0`. They are not part of the immutable `v1.0` collection snapshot. Each has its own release notes and standalone module ZIP.

---

## Continuous Integration & Automated Testing

All modularity rules and patch applicabilities are verified automatically by GitHub Actions on every push:

* **Modularity and Format:** `.github/scripts/check-modules.sh` verifies directory layout, patch headers, and consistency between `apply-patches.sh`, READMEs, and `NOTICE`.
* **Throwaway Tree Test:** `.github/scripts/test-apply-script.sh` runs each module's `apply-patches.sh` against an isolated mock source tree.
* **Link Validation:** `.github/scripts/test-markdown-links.sh` ensures local documentation links resolve correctly.
* **Reference Upstream Checks:** `.github/scripts/check-reference.sh` downloads the exact files touched by patches from upstream crDroid repositories, applies and reverses the patches, and ensures the source tree returns to a clean state.
* **Installer Generation:** Installer logic is maintained in `.github/installer/apply-patches.sh.in`. Each module's `installer.json` supplies its metadata. To regenerate installers:
  ```bash
  python3 .github/scripts/generate-installers.py
  python3 .github/scripts/generate-installers.py --check
  ```

For local maintainer preflight:
```bash
MODULE=aptx-adaptive  # or gms-fixes, gps-servers, donation-disable, bbrv3, bbrv3-experimental, susfs-core
python3 .github/scripts/generate-installers.py --check
bash .github/scripts/check-modules.sh
bash .github/scripts/test-apply-script.sh "$MODULE"
bash .github/scripts/check-reference.sh "$MODULE"
bash .github/scripts/check-reference.sh --branch 16.0 "$MODULE"
```

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

Kernel exceptions: `bbrv3` and `bbrv3-experimental` preserve kernel GPL terms, individual file notices, and the BBR core's `Dual BSD/GPL` declaration. `susfs-core` preserves upstream GPL Version 3 for its patch-file delta. Their own docs, metadata, and installers remain Apache 2.0. The module `LICENSE` and `NOTICE` files define these distinctions.
