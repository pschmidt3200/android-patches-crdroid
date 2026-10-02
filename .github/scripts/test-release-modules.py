#!/usr/bin/env python3
"""Test release selection and fail-before-publication gates without GitHub writes."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
MODULES = ("aptx-adaptive", "donation-disable", "gms-fixes", "gps-servers")


class ReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        scripts = self.root / ".github/scripts"
        scripts.mkdir(parents=True)
        notes = self.root / ".github/releases"
        notes.mkdir()
        shutil.copy(ROOT / ".github/scripts/release-modules.sh", scripts)
        self.events = self.root / "events.log"
        self.env = dict(os.environ, GH_REPO="fixture/repository", EVENT_LOG=str(self.events),
                        GIT_AUTHOR_NAME="ci", GIT_AUTHOR_EMAIL="ci@localhost",
                        GIT_COMMITTER_NAME="ci", GIT_COMMITTER_EMAIL="ci@localhost",
                        PUBLISHED="", ASSETS="{}", API_FAIL="", CREATE_FAIL="", UPLOAD_FAIL="",
                        FAIL_GATE="")
        # Gate stubs record calls; the real gates have their own behavioural tests.
        for name in ("check-modules.sh", "test-apply-script.sh", "check-reference.sh"):
            (scripts / name).write_text(
                '#!/usr/bin/env bash\nset -eu\n'
                f'event="{name} $*"\nprintf "%s\\n" "$event" >> "$EVENT_LOG"\n'
                '[[ "$event" != "${FAIL_GATE:-}" ]]\n'
            )
        (scripts / "generate-installers.py").write_text(
            'import os,sys\n'
            'event="generate " + " ".join(sys.argv[1:])\n'
            'with open(os.environ["EVENT_LOG"],"a") as log: log.write(event+"\\n")\n'
            'sys.exit(1 if event == os.environ.get("FAIL_GATE") else 0)\n'
        )
        bin_dir = self.root / "bin"
        bin_dir.mkdir()
        gh = bin_dir / "gh"
        # ASSETS maps an existing release tag to its asset names. Every uploaded .zip is
        # logged with its entries and contents, so tests can see what users would get.
        gh.write_text(
            '#!/usr/bin/env python3\nimport json,os,sys,zipfile\n'
            'args=sys.argv[1:]\n'
            'with open(os.environ["EVENT_LOG"],"a") as log: log.write("gh "+json.dumps(args)+"\\n")\n'
            'def log_zips(tag):\n'
            '    for arg in args[3:]:\n'
            '        if arg.endswith(".zip"):\n'
            '            z=zipfile.ZipFile(arg)\n'
            '            files={n: z.read(n).decode() for n in z.namelist() if not n.endswith("/")}\n'
            '            with open(os.environ["EVENT_LOG"],"a") as log:\n'
            '                log.write("zip "+json.dumps([tag, os.path.basename(arg), files])+"\\n")\n'
            'if args[0] == "api":\n'
            '    if os.environ.get("API_FAIL"): sys.exit(1)\n'
            '    if "/releases/tags/" in args[1]:\n'
            '        tag=args[1].rsplit("/",1)[1]\n'
            '        print("\\n".join(json.loads(os.environ.get("ASSETS","{}")).get(tag, [])))\n'
            '    else: print(os.environ.get("PUBLISHED", ""))\n'
            'elif args[:2] == ["release", "create"]:\n'
            '    if args[2] == os.environ.get("CREATE_FAIL"): sys.exit(1)\n'
            '    log_zips(args[2])\n'
            'elif args[:2] == ["release", "upload"]:\n'
            '    if "--clobber" in args: sys.exit("never replace an asset")\n'
            '    if args[2] == os.environ.get("UPLOAD_FAIL"): sys.exit(1)\n'
            '    log_zips(args[2])\n'
            'else: sys.exit("unexpected gh call")\n'
        )
        gh.chmod(0o755)
        self.env["PATH"] = str(bin_dir) + os.pathsep + os.environ["PATH"]
        for module in MODULES:
            directory = self.root / module
            directory.mkdir()
            (directory / "installer.json").write_text(json.dumps({"title": module}))
            (directory / "NOTICE").write_text("fixture\n")
            (directory / "apply-patches.sh").write_text("#!/usr/bin/env bash\n")
            (notes / f"{module}-v1.0.md").write_text(f"Release notes for {module}\n")
        self.git("init", "-q")
        self.git("add", ".github", *MODULES)
        self.git("commit", "-qm", "fixture")
        for module in MODULES:
            self.git("tag", f"{module}-v1.0")

    def git(self, *args):
        subprocess.run(["git", *args], cwd=self.root, env=self.env, check=True, capture_output=True)

    def release(self, *args, success=True, **env):
        result = subprocess.run(
            ["bash", str(self.root / ".github/scripts/release-modules.sh"), *args],
            cwd=self.root, env=dict(self.env, **env), capture_output=True, text=True, check=False,
        )
        self.assertEqual(result.returncode, 0 if success else 1, result.stdout + result.stderr)
        return result

    def calls(self):
        return self.events.read_text().splitlines() if self.events.exists() else []

    def creations(self):
        return [json.loads(line[3:]) for line in self.calls() if line.startswith('gh ["release", "create"')]

    def uploads(self):
        return [json.loads(line[3:]) for line in self.calls() if line.startswith('gh ["release", "upload"')]

    def zips(self):
        """[tag, asset name, {entry: content}] for every archive handed to GitHub."""
        return [json.loads(line[4:]) for line in self.calls() if line.startswith("zip ")]

    def writes(self):
        return self.creations() + self.uploads()

    def module_files(self, module):
        return {f"{module}/{name}" for name in ("installer.json", "NOTICE", "apply-patches.sh")}

    def collection(self):
        (self.root / ".github/releases/v1.0.md").write_text("# crDroid Patches v1.0\n")
        (self.root / "README.md").write_text("Collection documentation\n")
        self.git("add", ".github/releases/v1.0.md", "README.md")
        self.git("commit", "-qm", "collection")
        self.git("tag", "v1.0")

    def test_all_modules_preflight_before_first_publication(self):
        self.release()
        self.assertEqual([call[2] for call in self.creations()], [f"{mod}-v1.0" for mod in MODULES])
        events = self.calls()
        first_create = next(i for i, event in enumerate(events) if event.startswith('gh ["release", "create"'))
        for module in MODULES:
            for gate in (f"test-apply-script.sh {module}", f"check-reference.sh {module}",
                         f"check-reference.sh --branch 16.0 {module}"):
                self.assertLess(events.index(gate), first_create)
        for call in self.creations():
            self.assertIn("--verify-tag", call)
            self.assertIn("--latest=false", call)
            self.assertEqual(call[-2:], ["--notes-file", f".github/releases/{call[2]}.md"])

    def test_selected_tag_and_read_only_preflight(self):
        self.release("--check", "gms-fixes-v1.0")
        self.assertEqual(self.creations(), [])
        self.assertIn("test-apply-script.sh gms-fixes", self.calls())
        self.assertNotIn("test-apply-script.sh aptx-adaptive", self.calls())
        self.events.unlink()
        self.release("gps-servers-v1.0")
        self.assertEqual([call[2] for call in self.creations()], ["gps-servers-v1.0"])

    def test_existing_release_is_untouched_despite_payload_change(self):
        (self.root / "aptx-adaptive/NOTICE").write_text("changed after existing release\n")
        result = self.release("aptx-adaptive-v1.0", PUBLISHED="aptx-adaptive-v1.0",
                              ASSETS=json.dumps({"aptx-adaptive-v1.0": ["aptx-adaptive-v1.0.zip"]}))
        self.assertIn("leaving release unchanged", result.stdout)
        self.assertEqual(self.writes(), [])
        # Only read-only GitHub API requests: the release list and this release's assets.
        self.assertTrue(all(call.startswith('gh ["api"') for call in self.calls()), self.calls())

    def test_new_module_release_carries_exactly_its_module_archive(self):
        self.release()
        self.assertEqual(len(self.zips()), len(MODULES))
        for call in self.creations():
            tag = call[2]
            self.assertTrue(call[3].endswith(f"/{tag}.zip"), call)
        for tag, name, files in self.zips():
            module = tag[: -len("-v1.0")]
            self.assertEqual(name, f"{tag}.zip")
            # Only this module's directory: no other module, no .github, no root files.
            self.assertEqual(set(files), self.module_files(module))

    def test_collection_release_gets_no_archive(self):
        self.collection()
        self.release("v1.0")
        self.assertEqual([call[2] for call in self.creations()], ["v1.0"])
        self.assertFalse(any(arg.endswith(".zip") for arg in self.creations()[0]))
        self.assertEqual(self.zips(), [])

    def test_existing_release_gets_missing_archive_built_from_its_tag(self):
        # The module changes after its release; the archive must still show the tag.
        (self.root / "gms-fixes/NOTICE").write_text("edition after the tag\n")
        self.git("add", "gms-fixes/NOTICE")
        self.git("commit", "-qm", "later edition")
        result = self.release("gms-fixes-v1.0", PUBLISHED="gms-fixes-v1.0")
        self.assertIn("tag and notes stay unchanged", result.stdout)
        self.assertEqual(self.creations(), [])
        self.assertEqual([call[2] for call in self.uploads()], ["gms-fixes-v1.0"])
        [(tag, name, files)] = self.zips()
        self.assertEqual((tag, name), ("gms-fixes-v1.0", "gms-fixes-v1.0.zip"))
        self.assertEqual(set(files), self.module_files("gms-fixes"))
        self.assertEqual(files["gms-fixes/NOTICE"], "fixture\n")

    def test_backfill_attaches_every_missing_module_archive_but_not_the_collection(self):
        self.collection()
        published = "\n".join([f"{mod}-v1.0" for mod in MODULES] + ["v1.0"])
        self.release(PUBLISHED=published,
                     ASSETS=json.dumps({"gps-servers-v1.0": ["gps-servers-v1.0.zip"]}))
        self.assertEqual(self.creations(), [])
        self.assertEqual(sorted(call[2] for call in self.uploads()),
                         [f"{mod}-v1.0" for mod in MODULES if mod != "gps-servers"])

    def test_check_mode_reports_missing_archives_without_writing(self):
        result = self.release("--check", PUBLISHED="\n".join(f"{mod}-v1.0" for mod in MODULES))
        self.assertEqual(self.writes(), [])
        for module in MODULES:
            self.assertIn(f"Would attach {module}-v1.0.zip", result.stdout)

    def test_gate_failure_also_blocks_archive_attachment(self):
        published = "\n".join(f"{mod}-v1.0" for mod in MODULES)
        for gate in ("generate --check", "check-modules.sh "):
            with self.subTest(gate=gate):
                self.release(success=False, PUBLISHED=published, FAIL_GATE=gate)
                self.assertEqual(self.writes(), [])

    def test_failed_attachment_reports_what_was_already_attached(self):
        published = "\n".join(f"{mod}-v1.0" for mod in MODULES)
        result = self.release(success=False, PUBLISHED=published, UPLOAD_FAIL="gms-fixes-v1.0")
        self.assertIn("attaching gms-fixes-v1.0.zip failed", result.stderr)
        self.assertIn("Already attached; left unchanged: aptx-adaptive-v1.0.zip", result.stderr)
        self.assertEqual([call[2] for call in self.uploads()],
                         ["aptx-adaptive-v1.0", "donation-disable-v1.0", "gms-fixes-v1.0"])

    def test_invalid_tag_unknown_module_and_missing_notes(self):
        for tag in ("../aptx-adaptive-v1.0", "aptx-adaptive-v", "aptx-adaptive-v1x0",
                    "unknown-v1.0", "gms-fixes-v2.0"):
            with self.subTest(tag=tag):
                self.release(tag, success=False)
                self.assertEqual(self.creations(), [])

    def test_missing_tag_and_payload_mismatch(self):
        self.git("tag", "-d", "gms-fixes-v1.0")
        self.release("gms-fixes-v1.0", success=False)
        self.assertEqual(self.creations(), [])
        (self.root / "gps-servers/NOTICE").write_text("new payload\n")
        self.git("add", "gps-servers/NOTICE")
        self.git("commit", "-qm", "changed")
        self.release("gps-servers-v1.0", success=False)
        self.assertEqual(self.creations(), [])

    def test_uncommitted_module_changes_abort(self):
        (self.root / "gps-servers/NOTICE").write_text("uncommitted payload\n")
        result = self.release("gps-servers-v1.0", success=False)
        self.assertIn("uncommitted changes", result.stderr)
        self.assertEqual(self.creations(), [])
        self.git("add", "gps-servers/NOTICE")
        self.release("gps-servers-v1.0", success=False)
        self.assertEqual(self.creations(), [])

    def test_api_failure_and_missing_repository_abort(self):
        self.release(success=False, API_FAIL="1")
        self.release(success=False, GH_REPO="")
        self.assertEqual(self.creations(), [])

    def test_failed_gate_never_publishes_any_candidate(self):
        for gate in ("generate --check", "check-modules.sh ", "test-apply-script.sh gps-servers",
                     "check-reference.sh gps-servers", "check-reference.sh --branch 16.0 gps-servers"):
            with self.subTest(gate=gate):
                self.release(success=False, FAIL_GATE=gate)
                self.assertEqual(self.creations(), [])

    def test_partial_publication_failure_reports_created_release(self):
        result = self.release(success=False, CREATE_FAIL="donation-disable-v1.0")
        self.assertIn("Already published; left unchanged: aptx-adaptive-v1.0", result.stderr)
        self.assertEqual([call[2] for call in self.creations()],
                         ["aptx-adaptive-v1.0", "donation-disable-v1.0"])

    def test_collection_is_last_latest_and_reuses_module_checks(self):
        self.collection()
        self.release()
        self.assertEqual([call[2] for call in self.creations()],
                         [f"{mod}-v1.0" for mod in MODULES] + ["v1.0"])
        self.assertIn("--latest=true", self.creations()[-1])
        for call in self.creations()[:-1]:
            self.assertIn("--latest=false", call)
        for module in MODULES:
            self.assertEqual(self.calls().count(f"test-apply-script.sh {module}"), 1)

    def test_collection_only_preflight_covers_every_module(self):
        self.collection()
        self.release("--check", "v1.0")
        self.assertEqual(self.creations(), [])
        for module in MODULES:
            self.assertIn(f"check-reference.sh --branch 16.0 {module}", self.calls())

    def test_collection_gate_failure_or_changed_root_prevents_publication(self):
        self.collection()
        self.release("v1.0", success=False, FAIL_GATE="check-reference.sh --branch 16.0 gps-servers")
        self.assertEqual(self.creations(), [])
        (self.root / "README.md").write_text("uncommitted documentation\n")
        result = self.release("v1.0", success=False)
        self.assertIn("uncommitted changes", result.stderr)
        self.git("add", "README.md")
        self.git("commit", "-qm", "different root snapshot")
        result = self.release("v1.0", success=False)
        self.assertIn("differs from the payload", result.stderr)
        self.assertEqual(self.creations(), [])

    def test_existing_collection_is_immutable(self):
        self.collection()
        (self.root / "README.md").write_text("new documentation\n")
        self.release("v1.0", PUBLISHED="v1.0")
        self.assertEqual(self.creations(), [])
        self.assertEqual(len(self.calls()), 1)


if __name__ == "__main__":
    unittest.main(verbosity=2)
