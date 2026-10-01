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
├── .github/                   # Issue form, installer template, CI and release tooling
│
├── aptx-adaptive/             # Qualcomm aptX Adaptive DSP offload & BT integration
│   ├── README.md              # Detailed module documentation & requirements
│   ├── README.de.md           # German module documentation
│   ├── apply-patches.sh       # Automated patch installation & verification script
│   ├── installer.json         # Title, ordered patch list and optional target repository
│   ├── NOTICE                 # Upstream attribution, reference commits & licensing
│   ├── LICENSE                # Module license (Apache 2.0)
│   └── patches/               # .patch files (Bluetooth, frameworks, Settings, GameSpace, device)
│
├── gms-fixes/                 # GMS visibility and vendor build compatibility
├── gps-servers/               # Optional SUPL and GNSS NTP server choices
└── donation-disable/          # Remove in-ROM donation prompts and links
```

---

## How Modules Are Kept Apart

Every patch set is a **self-contained module directory**. A module never depends on, refers to or
documents another module unless its own README says so explicitly.

| Location | Belongs to | Contains |
|---|---|---|
| Repository root | the whole collection | this overview, the module index, the disclaimer and the default `LICENSE` — **no patches** |
| `<module>/` | exactly one patch set | `README.md` + `README.de.md`, `NOTICE` (upstream sources and reference commits), `LICENSE`, `installer.json` and standalone `apply-patches.sh` |
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
another branch; leaving the branch empty selects the NOTICE commits. A fourth NOTICE field,
`branch=<name>`, maps a vendor's Android branch (GMS uses `bka`) during branch checks.
It checks, applies and
reverses the real patches, requiring every source repository to be clean afterwards. Only the
touched files are downloaded. All four scripts can be run locally from the repository root.

Installer logic is maintained once in `.github/installer/apply-patches.sh.in`. Each module's
`installer.json` supplies its title, patch order and optional target repository. The generated
`apply-patches.sh` remains a complete standalone Bash script: users need only the module directory,
Bash and Git; Python and the template are used only when maintaining this repository.
Edit the template or metadata, then regenerate from the repository root:

```bash
python3 .github/scripts/generate-installers.py
python3 .github/scripts/generate-installers.py --check
```

Do not edit generated installers directly. CI rejects generation drift and tests malformed
metadata, standalone use and every module's existing installer behaviour. The generator validates
all modules before writing the first installer. If an I/O failure interrupts generation, fix the
reported error and rerun it; `--check` never changes files.

CI uses standard `ubuntu-latest` runners, which are [free for public repositories](https://docs.github.com/en/billing/concepts/product-billing/github-actions).
Jobs skip private repositories, have time limits and use no cache or artifact uploads. GitHub may
delay scheduled runs and [disables them after 60 days without repository activity](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule);
check the Actions page before relying on the weekly test. These checks establish source
applicability and rollback, not a ROM build or device acceptance.

---

## Design Principles & Standards

* **Modular & Independent:** Each topic or feature resides in its own directory with dedicated documentation, requirements, and patch files.
* **Pure Source Diffs:** Patches are standard git diffs against source and build configuration used by crDroid. No proprietary blobs, compiled firmware binaries, or device secrets are hosted here.
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
  Base: crDroid branch `16.0` (Android 16). Reference devices: OnePlus 13 (`dodge`), OnePlus Pad 3 / Pad 2 Pro (`erhai`). Other devices: untested.
* **[GMS Compatibility Fixes](gms-fixes/):** Package visibility, Google Clock permission, targeted uses-library workarounds and an optional OnePlus package selection.
  Base: crDroid `16.0` with Evolution X `vendor_gms` branch `bka`. Public edition: source checks; ROM/device validation pending.
* **[GPS Server Choices](gps-servers/):** Independently selectable GrapheneOS SUPL and German NTP pool configuration.
  Base: crDroid `16.0`, OnePlus `sm8750-common`. Public edition: source checks; effective server use and GNSS measurements pending.
* **[Disable Donation Requests](donation-disable/):** Removes donation UI and links, clears old reminders and preserves maintainer names.
  Base: crDroid `16.0`. Personal UI preference; public edition: source/host checks, ROM/device validation pending.

---

## Reporting Problems

If a patch does not apply, does not build or misbehaves on the reference setup, please open an issue
with the **Patch problem** form and include the patch release tag or commit SHA and exact error output.
Find the patch commit with `git rev-parse HEAD` in this repository. Remove Bluetooth MAC addresses and
serial numbers from logs before posting. Reports from other devices are welcome as information —
please read the disclaimer below first.

---

## Module Releases

Each module uses its own `<module>-v<version>` tags. For example:

| Module | Tag format example |
|---|---|
| `aptx-adaptive` | `aptx-adaptive-v1.0` (existing release) |
| `gms-fixes` | `gms-fixes-v1.0` |
| `gps-servers` | `gps-servers-v1.0` |
| `donation-disable` | `donation-disable-v1.0` |

Examples describe the naming scheme; they do not mean a release exists for every module.
Versions have two or three numeric components and may have a suffix such as `-rc.1`.

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
provides notes and GitHub's source archives. To publish a module release, first create and push
its immutable tag, then add `.github/releases/<tag>.md`. Pushing new notes to `main` runs the
*release* workflow; it can also be started manually with a tag. The tagged module must match
the tested commit and have no uncommitted changes. The helper checks **all unpublished candidates
before creating any release**, including generated installer consistency and the four checks below.
Existing releases are left unchanged. A publication failure reports which releases were already
created; rerunning checks the remaining candidates. New module releases do not automatically
replace GitHub's global *Latest* selection.
Only the release job receives `contents: write` via GitHub's temporary job token; it runs only
on `main` in this public repository, using the same free standard runner and no asset uploads.

For maintainers, run these checks from the repository root for the selected module:

```bash
MODULE=aptx-adaptive  # or gms-fixes, gps-servers, donation-disable
python3 .github/scripts/generate-installers.py --check
bash .github/scripts/check-modules.sh
bash .github/scripts/test-apply-script.sh "$MODULE"
bash .github/scripts/check-reference.sh "$MODULE"
bash .github/scripts/check-reference.sh --branch 16.0 "$MODULE"
```

With an authenticated GitHub CLI, `GH_REPO=pschmidt3200/android-patches-crdroid bash
.github/scripts/release-modules.sh --check <tag>` runs the complete release preflight without
publishing. Omitting the tag selects all notes in `.github/releases/`. The same helper is used
by the workflow. [`--verify-tag`](https://cli.github.com/manual/gh_release_create) requires a tag
already on GitHub; the helper never creates or moves tags.

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
