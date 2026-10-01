#!/usr/bin/env python3
"""Generate standalone Bash installers from one template and module metadata."""

import argparse
import json
import os
from pathlib import Path
import re
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[2]
TOKENS = {"@@TITLE@@", "@@PATCH_ENTRIES@@", "@@OPTIONAL_REPO@@"}


def plain_text(value, field, allow_empty=False):
    if not isinstance(value, str):
        raise ValueError(f"{field}: expected text")
    if not value and not allow_empty:
        raise ValueError(f"{field}: must not be empty")
    if any(ord(char) < 32 or ord(char) == 127 or char in '"\\$`' for char in value):
        raise ValueError(f"{field}: control characters and shell metacharacters are forbidden")
    if "@@" in value:
        raise ValueError(f"{field}: template delimiters are forbidden")
    return value


def relative_path(value, field):
    plain_text(value, field)
    if not re.fullmatch(r"[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*", value):
        raise ValueError(f"{field}: expected a relative path without spaces or colons")
    if any(part in {".", ".."} for part in value.split("/")):
        raise ValueError(f"{field}: path traversal is forbidden")
    return value


def render_installers(root):
    template = (root / ".github/installer/apply-patches.sh.in").read_text(encoding="utf-8")
    if set(re.findall(r"@@[A-Z_]+@@", template)) != TOKENS:
        raise ValueError("template: missing or unknown placeholders")
    for token in ("@@PATCH_ENTRIES@@", "@@OPTIONAL_REPO@@"):
        if template.count(token) != 1:
            raise ValueError(f"template: expected exactly one {token}")
    modules = sorted(path.parent for path in root.glob("*/patches") if path.is_dir())
    configured = {path.parent for path in root.glob("*/installer.json")}
    if not modules or set(modules) != configured:
        raise ValueError("every patch module must have exactly one installer.json")

    rendered = {}
    for module in modules:
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", module.name):
            raise ValueError(f"invalid module name: {module.name}")
        config = json.loads((module / "installer.json").read_text(encoding="utf-8"))
        if not isinstance(config, dict) or set(config) != {"title", "optional_repository", "patches"}:
            raise ValueError(f"{module.name}: invalid configuration keys")
        title = plain_text(config["title"], "title")
        optional = plain_text(config["optional_repository"], "optional_repository", allow_empty=True)
        if optional:
            relative_path(optional, "optional_repository")
        patches = config["patches"]
        if not isinstance(patches, list) or not patches:
            raise ValueError(f"{module.name}: patches must be a non-empty list")
        entries, files, repositories = [], set(), set()
        for patch in patches:
            if not isinstance(patch, dict) or set(patch) != {"repository", "file", "description"}:
                raise ValueError(f"{module.name}: invalid patch keys")
            repo = relative_path(patch["repository"], "repository")
            file = relative_path(patch["file"], "file")
            if "/" in file or not file.endswith(".patch") or file in files:
                raise ValueError(f"{module.name}: invalid or duplicate patch file: {file}")
            description = plain_text(patch["description"], "description")
            patch_path = module / "patches" / file
            if not patch_path.is_file():
                raise ValueError(f"{module.name}: patch file missing: {file}")
            header = patch_path.read_text(encoding="utf-8").splitlines()[0]
            if header != f"# Target repository: {repo}":
                raise ValueError(f"{module.name}: target header differs: {file}")
            files.add(file)
            repositories.add(repo)
            entries.append(f'    "{repo}:{file}:{description}"')
        if files != {path.name for path in (module / "patches").glob("*.patch")}:
            raise ValueError(f"{module.name}: patch list differs from patches directory")
        if optional and optional not in repositories:
            raise ValueError(f"{module.name}: optional repository is not a patch target")
        output = template.replace("@@TITLE@@", title).replace("@@PATCH_ENTRIES@@", "\n".join(entries))
        output = output.replace("@@OPTIONAL_REPO@@", optional)
        rendered[module / "apply-patches.sh"] = output.encode("utf-8")
    return rendered


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="report drift without writing files")
    args = parser.parse_args()
    try:
        # Validate every module before changing the first generated file.
        rendered = render_installers(ROOT)
        drift = []
        for path, content in rendered.items():
            matches = path.is_file() and path.read_bytes() == content
            executable = path.is_file() and (path.stat().st_mode & 0o111) == 0o111
            if matches and executable:
                continue
            drift.append(path.relative_to(ROOT))
            if args.check:
                continue
            mode = (path.stat().st_mode & 0o777) if path.exists() else 0o644
            with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as temp:
                temp_path = Path(temp.name)
                try:
                    temp.write(content)
                    temp.flush()
                    os.chmod(temp_path, mode | 0o111)
                    os.replace(temp_path, path)
                finally:
                    temp_path.unlink(missing_ok=True)
        if args.check and drift:
            for path in drift:
                print(f"installer drift: {path}", file=sys.stderr)
            return 1
        print(f"standalone installers {'verified' if args.check else 'generated'} ({len(rendered)} modules)")
        return 0
    except (OSError, UnicodeError, ValueError, IndexError) as error:
        print(f"installer generation failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
