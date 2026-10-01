# android-patches-crdroid

A curated collection of modular patches, framework improvements, and hardware integrations for **crDroid**.

The goal of this repository is to maintain clean, modular source patches for crDroid — including hardware-specific integrations where a module documents them — without bundled proprietary vendor binaries. The patches are applied directly to a compatible crDroid source tree.

**Current ROM scope: crDroid only.** Each module documents its crDroid branch and reference hardware.
Support for other ROMs has not been established.

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
`.github/scripts/test-markdown-links.sh` verifies that external URLs are ignored and broken local
links are rejected, including local links with fragments.
The *reference-check* workflow (`.github/scripts/check-reference.sh`) also runs when patches,
application scripts, reference notices or CI scripts change, checking the commits in each module's
`NOTICE`. Every Monday at 06:23 UTC it checks the current crDroid `16.0` branch. Manual runs accept
another branch; leaving the branch empty selects the NOTICE commits. It checks, applies and
reverses the real patches, requiring every source repository to be clean afterwards. Only the
touched files are downloaded. All four scripts can be run locally from the repository root.

CI uses standard `ubuntu-latest` runners, which are [free for public repositories](https://docs.github.com/en/billing/concepts/product-billing/github-actions).
Jobs skip private repositories, have time limits and use no cache or artifact uploads. GitHub may
delay scheduled runs and [disables them after 60 days without repository activity](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule);
check the Actions page before relying on the weekly test. These checks establish source
applicability and rollback, not a ROM build or device acceptance.

---

## Design Principles & Standards

* **Modular & Independent:** Each topic or feature resides in its own directory with dedicated documentation, requirements, and patch files.
* **Pure Source Diffs:** All patches are standard git diffs against crDroid's open-source repositories. No proprietary blobs, compiled firmware binaries, or device secrets are hosted here.
* **Upstream Hygiene:** Changes are kept atomic and cleanly separated by Android subsystem (`packages/modules/*`, `frameworks/*`, `hardware/*`).

---

## General Usage

Each subfolder contains its own detailed `README.md` with prerequisites, target commits, and instructions.

In general, patches can be applied using standard git tooling:
```bash
# Navigate to the target repository inside your crDroid source tree
cd /path/to/crdroid/source/<target-subrepo>

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
with the **Patch problem** form and include the patch release tag or commit SHA and exact error output.
Find the patch commit with `git rev-parse HEAD` in this repository. Remove Bluetooth MAC addresses and
serial numbers from logs before posting. Reports from other devices are welcome as information —
please read the disclaimer below first.

---

## Reproducible Releases

To use the existing aptX release, keep the whole module at its release tag:

```bash
git clone https://github.com/pschmidt3200/android-patches-crdroid.git
cd android-patches-crdroid
git switch --detach aptx-adaptive-v1.0
```

Follow the module's README to check and apply its patches to your source tree. Do not mix files
from different tags or commits. A tag identifies the patch edition; source checks do not establish
a successful ROM build or device test.

The [release page](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/aptx-adaptive-v1.0)
provides notes and GitHub's source archives. To publish an aptX release, first create its immutable
tag and add `.github/releases/<tag>.md`. Pushing new notes to `main` runs the *release* workflow;
it can also be started manually with a tag. The tagged module must match the module being tested.
All four checks below must pass before publication. Existing releases are left unchanged.
Only the release job receives `contents: write` via GitHub's temporary job token; it runs only
on `main` in this public repository, using the same free standard runner and no asset uploads.

For maintainers, run these checks from the repository root before a new aptX release:

```bash
bash .github/scripts/check-modules.sh
bash .github/scripts/test-apply-script.sh aptx-adaptive
bash .github/scripts/check-reference.sh aptx-adaptive
bash .github/scripts/check-reference.sh --branch 16.0 aptx-adaptive
```

The reference checks use temporary source trees. Any failure stops the release: record the target
repository, source revision and exact error, then correct the patch or its documented baseline.
Commit the reviewed changes and attach the release tag to that verified commit.

**Existing tags are immutable.** When published patches change, use a new module tag, for example
`aptx-adaptive-v1.1`; never move, delete or reuse `aptx-adaptive-v1.0`. Release notes must identify
the patch commit, source baselines, changed behaviour and known limits. Report source checks,
ROM builds and device tests separately, including any checks that remain unperformed.

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
