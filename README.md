# android-patches-crdroid
A curated collection of modular patches, framework improvements, and hardware integrations for **crDroid** and AOSP-based custom ROMs.

The goal of this repository is to maintain clean, vendor-neutral source patches that can be applied directly to a ROM build tree or integrated via local manifests.

---

## Repository Structure

Patches and improvements are organized into topic-specific directories:

```text
android-patches-crdroid/
├── README.md                  # General documentation & overview
├── LICENSE                    # Repository license (Apache 2.0)
│
├── aptx-adaptive/             # Qualcomm aptX Adaptive DSP offload & BT integration
│   ├── README.md              # Detailed module documentation & requirements
│   ├── NOTICE                 # Upstream attribution & component licensing
│   └── patches/               # Target-specific .patch files (Bluetooth, Framework, HAL)
│
└── [future-modules]/          # Future patch sets (kernel, system, display, etc.)
