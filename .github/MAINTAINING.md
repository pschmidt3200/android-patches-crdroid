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

# Verify patches against the live 16.0 branch
bash .github/scripts/check-reference.sh --branch 16.0 <module-name>
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
2. Run the preflight checks for all affected modules (`check-modules.sh`, `test-markdown-links.sh`).
3. Commit release notes to `main`.
4. Create an annotated git tag:
   ```bash
   git tag -a <module>-v<version> -m "<module> v<version>"
   ```
5. Push `main` and the tag:
   ```bash
   git push origin main --tags
   ```
   The `.github/workflows/release.yml` action will automatically build the standalone module ZIP archive (`<module>-v<version>.zip`) and publish it to the GitHub Releases page.
