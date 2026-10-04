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

## Release Process

1. Prepare release notes under `.github/releases/<tag>.md`.
2. Run the preflight checks for all affected modules.
3. Commit and tag:
   ```bash
   git tag -a <module>-v<version> -m "<module> v<version>"
   ```
4. Push `main` and tags together:
   ```bash
   git push origin main --tags
   ```
   The `.github/workflows/release.yml` action will build the module ZIP archives and publish them as GitHub release assets.
