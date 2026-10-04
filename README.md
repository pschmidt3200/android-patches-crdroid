# android-patches-crdroid

A collection of modular source patches, framework enhancements, and hardware integrations for **crDroid 16.0 (Android 16)**.

All patches are pure source diffs without proprietary binaries, designed to be applied directly to a crDroid source tree.

---

## Available Modules

Each module is self-contained and focuses on a single feature:

### Hardware & Media
* **[aptx-adaptive](aptx-adaptive/):** Bluetooth audio integration. See the module directory for technical details and prerequisites.

### User Interface & Settings
* **[bluetooth-codec-ui](bluetooth-codec-ui/):** Bluetooth audio codec selection menu and status display in Settings. See the module directory for technical details.
* **[donation-disable](donation-disable/):** Removal of donation prompts in Settings. See the module directory for technical details.

### System Services & Networking
* **[gps-servers](gps-servers/):** Alternative SUPL and NTP server configuration. See the module directory for technical details.
* **[gms-fixes](gms-fixes/):** Compatibility adjustments for Google services. See the module directory for technical details.

### Kernel Subsystems
* **[bbrv3](bbrv3/):** TCP congestion-control patch. See the module directory for technical details.
* **[bbrv3-experimental](bbrv3-experimental/):** Experimental update of the TCP congestion-control patch, for testing only; replaces `bbrv3` in a test build. See the module directory for technical details.
* **[susfs-core](susfs-core/):** Kernel patch corrections. See the module directory for technical details.

---

## How to Install

### Step 1: Download the Module
Choose the module you want from the [Releases page](https://github.com/pschmidt3200/android-patches-crdroid/releases) and download its `.zip` archive (e.g. `aptx-adaptive-v1.2.zip`).

### Step 2: Apply to Your crDroid Source Tree
1. Extract the downloaded zip file anywhere outside or alongside your crDroid source tree.
2. Open a terminal in the extracted folder and run:
   ```bash
   ./apply-patches.sh /path/to/crdroid
   ```
The installer automatically checks compatibility and applies the patches to the correct sub-repositories (`frameworks/base`, `packages/modules/Bluetooth`, etc.).

To check compatibility without applying changes:
```bash
./apply-patches.sh --check /path/to/crdroid
```

To revert the patches:
```bash
./apply-patches.sh --reverse /path/to/crdroid
```

*(Advanced users who prefer git directly can clone this repository and use `git apply` as documented in each module's README).*

---

## Reporting Issues

If a patch does not apply cleanly or causes build errors on crDroid 16.0:
1. Please [open an issue](https://github.com/pschmidt3200/android-patches-crdroid/issues/new?template=patch-problem.yml) using the **Patch problem** template.
2. Include the module name, release tag or repository commit, your device model, and the terminal error output.
3. *Please ensure personal data (such as Bluetooth MAC addresses or serial numbers) is removed from logs before posting.*

---

## Disclaimer & Notes

* **Personal Hobby Project:** This repository is maintained in personal spare time. Testing is conducted on personal reference hardware (such as the OnePlus 13).
* **Support:** Issue responses, updates, and testing are provided when personal time and hardware allow.
* **Target Audience:** These patches are intended for ROM builders and experienced Android enthusiasts familiar with building crDroid from source.
* **No Proprietary Blobs:** This repository contains only open-source patches and diffs. No proprietary vendor binaries, firmware, or licensed codec blobs are distributed here.
* **Reversible:** All modules support reverse application (`--reverse`) on a compatible, otherwise unchanged source tree. Conflicting local modifications may require manual resolution.
* **Provided As-Is:** Modifications are applied at your own discretion without warranty.

---

## License

Unless otherwise noted within a specific module, documentation and patches in this repository are licensed under the **Apache License 2.0**. Kernel patches retain their upstream GPL licensing. See [LICENSE](LICENSE) and individual module `NOTICE` files for details.
