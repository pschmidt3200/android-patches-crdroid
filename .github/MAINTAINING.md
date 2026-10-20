# Maintainer Guide & CI Notes

This document contains internal development workflows, verification procedures, and release guidelines for `android-patches-crdroid`.

---

## Modularity & Verification Rules

Every patch set is a self-contained module directory. Unrelated changes must not be mixed into existing modules.

### Preflight Checks

Run these checks from the repository root before committing changes or creating release tags:

```bash
# Check all module structures and patch formats
bash .github/scripts/check-modules.sh

# Verify documentation links
bash .github/scripts/test-markdown-links.sh

# Test patch application on a throwaway mock tree
bash .github/scripts/test-apply-script.sh <module-name>

# Verify patches against crDroid upstream reference commits
bash .github/scripts/check-reference.sh <module-name>

# Verify patches against the live 17.0 branch (main targets crDroid 17.0)
bash .github/scripts/check-reference.sh --branch 17.0 <module-name>
```

---

## Installer Generation

Installer logic is maintained centrally in `.github/installer/apply-patches.sh.in`. Metadata for each module comes from `<module>/installer.json`.

Never edit `apply-patches.sh` files manually. Regenerate them using:

```bash
python3 .github/scripts/generate-installers.py
python3 .github/scripts/generate-installers.py --check
```

CI will reject any generation drift.

---

## Release Process & Tagging Policy

### Tagging Policy: Release Only on Payload Change

To keep releases clear and focused, module tags are created only when the distributed payload or its compatibility changes. Repository maintenance and documentation improvements do not trigger new release tags.

**A new module tag is warranted when:**
1. Patch content changes functionally.
2. Target repositories, dependencies, or patch order change.
3. Modules are split or merged (such as decoupling UI from core audio).
4. A bug in a published patch is resolved.
5. An experimental release matures into a stable release.

**No new tags are created for:**
* Documentation fixes, spelling corrections, or phrasing improvements.
* CI workflow, test suite, or maintainer script refactoring.
* Issue template adjustments.
* Device measurement updates without code modifications.

### How to Release a Module

1. Prepare release notes under `.github/releases/<module>-v<version>.md`.
2. If the module already has a release, add this line under the heading of the previous
   edition's notes so readers recognise it as old:
   ```markdown
   > **Superseded.** This is an older release, replaced by [<Module> v<version>](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/<module>-v<version>).
   > Use the newest `<module>` release unless you need exactly this revision. Deutsch: Ältere Version, ersetzt durch <Module> v<version>.
   ```
   `check-modules.sh` rejects an older edition without it. After the new release exists,
   the release workflow marks the previous GitHub release once: `(superseded by v<version>)`
   in its title and the same line under its heading. Its tag, archive and remaining text
   stay unchanged.
3. Run the preflight checks for all affected modules (`check-modules.sh`, `test-markdown-links.sh`,
   `test-release-notes.sh`).
4. Commit release notes to `main`.
5. Create an annotated git tag:
   ```bash
   git tag -a <module>-v<version> -m "<module> v<version>"
   ```
6. Push `main` and the tag:
   ```bash
   git push origin main --tags
   ```
   The `.github/workflows/release.yml` action will automatically build the standalone module ZIP archive (`<module>-v<version>.zip`) and publish it to the GitHub Releases page.
