#!/usr/bin/env python3
"""Exercise generation, drift detection and malformed module configurations."""

import copy
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]


class GeneratorTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        scripts = self.root / ".github/scripts"
        scripts.mkdir(parents=True)
        shutil.copy(ROOT / ".github/scripts/generate-installers.py", scripts)
        shutil.copytree(ROOT / ".github/installer", self.root / ".github/installer")
        self.config = {
            "title": "Test module", "optional_repository": "",
            "patches": [{"repository": "frameworks/base", "file": "test.patch", "description": "Test patch"}],
        }
        for module in ("first", "second"):
            patches = self.root / module / "patches"
            patches.mkdir(parents=True)
            (patches / "test.patch").write_text("# Target repository: frameworks/base\n")
            self.save(module, self.config)

    def save(self, module, config):
        (self.root / module / "installer.json").write_text(json.dumps(config))

    def run_generator(self, *args, success=True):
        result = subprocess.run(
            [sys.executable, str(self.root / ".github/scripts/generate-installers.py"), *args],
            capture_output=True, text=True, check=False,
        )
        self.assertEqual(result.returncode, 0 if success else 1, result.stdout + result.stderr)
        return result

    def test_generation_is_deterministic_and_standalone(self):
        self.run_generator()
        original = (self.root / "first/apply-patches.sh").read_bytes()
        self.run_generator("--check")
        self.run_generator()
        self.assertEqual(original, (self.root / "first/apply-patches.sh").read_bytes())
        standalone = self.root / "standalone.sh"
        shutil.copy(self.root / "first/apply-patches.sh", standalone)
        shutil.rmtree(self.root / ".github")
        result = subprocess.run([str(standalone), "--help"], capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Test module patch series", result.stdout)

    def test_drift_check_never_writes(self):
        self.run_generator()
        path = self.root / "first/apply-patches.sh"
        path.write_text("changed\n")
        self.run_generator("--check", success=False)
        self.assertEqual(path.read_text(), "changed\n")
        self.run_generator()
        self.run_generator("--check")
        path.chmod(0o644)
        self.run_generator("--check", success=False)

    def test_invalid_later_module_prevents_all_writes(self):
        path = self.root / "first/apply-patches.sh"
        path.write_text("keep me\n")
        invalid = copy.deepcopy(self.config)
        invalid["patches"][0]["file"] = "missing.patch"
        self.save("second", invalid)
        self.run_generator(success=False)
        self.assertEqual(path.read_text(), "keep me\n")

    def test_missing_configuration_and_unlisted_patch(self):
        config = self.root / "second/installer.json"
        config.unlink()
        self.run_generator(success=False)
        self.save("second", self.config)
        (self.root / "second/patches/extra.patch").write_text("extra\n")
        self.run_generator(success=False)

    def test_invalid_metadata(self):
        mutations = [
            {"title": '$(touch hacked)'}, {"title": "bad\nline"}, {"title": 'bad"quote'},
            {"title": "@@TITLE@@"}, {"optional_repository": "absent/repo"},
            {"patches": []}, {"patches": self.config["patches"] * 2}, {"unknown": True},
        ]
        for changes in mutations:
            with self.subTest(changes=changes):
                config = copy.deepcopy(self.config)
                config.update(changes)
                self.save("second", config)
                self.run_generator(success=False)
        for field, value in (("repository", "../base"), ("file", "../test.patch"),
                             ("description", "`uname`"), ("description", "bad\\escape")):
            with self.subTest(field=field, value=value):
                config = copy.deepcopy(self.config)
                config["patches"][0][field] = value
                self.save("second", config)
                self.run_generator(success=False)

    def test_wrong_or_empty_target_header(self):
        path = self.root / "second/patches/test.patch"
        for contents in ("# Target repository: vendor/gms\n", ""):
            path.write_text(contents)
            self.run_generator(success=False)

    def test_broken_template(self):
        path = self.root / ".github/installer/apply-patches.sh.in"
        original = path.read_text()
        for changed in (original.replace("@@TITLE@@", "title"), original + "@@UNKNOWN@@",
                        original + "@@OPTIONAL_REPO@@"):
            path.write_text(changed)
            self.run_generator(success=False)


if __name__ == "__main__":
    unittest.main(verbosity=2)
