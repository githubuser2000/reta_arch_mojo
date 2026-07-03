#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def run(command: list[str], *, env: dict[str, str] | None = None) -> bytes:
    return subprocess.check_output(command, cwd=ROOT, env=env)


def reference(python: str, code: str, *args: str) -> bytes:
    env = os.environ.copy()
    env["PYTHONPATH"] = str(ROOT / "python_reference")
    env["PYTHONHASHSEED"] = "0"
    return run([python, "-c", code, *args], env=env)


def native(binary: Path, *args: str) -> bytes:
    env = os.environ.copy()
    env["RETA_ROOT"] = str(ROOT)
    env["RETA_ASSET_DIR"] = str(ROOT / "assets")
    return run([str(binary), *args], env=env)


def parse_summary(payload: bytes) -> dict[str, object]:
    result: dict[str, object] = {"morphisms": [], "compatibility_names": []}
    for raw in payload.decode("utf-8").splitlines():
        key, value = raw.split("=", 1)
        if key == "morphism":
            result["morphisms"].append(value)  # type: ignore[union-attr]
        elif key == "compatibility":
            result["compatibility_names"].append(value)  # type: ignore[union-attr]
        elif key == "stage":
            result[key] = int(value)
        elif key != "repo_root":
            result[key] = value
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--python", required=True)
    parser.add_argument("--binary", required=True, type=Path)
    args = parser.parse_args()

    snapshot_code = r'''
import json
from reta_architecture.console_io import bootstrap_console_io_morphisms
snapshot = bootstrap_console_io_morphisms().snapshot()
snapshot.pop("repo_root", None)
print(json.dumps(snapshot, ensure_ascii=False, sort_keys=True))
'''
    expected_snapshot = json.loads(reference(args.python, snapshot_code))
    actual_snapshot = parse_summary(native(args.binary, "--summary"))
    assert actual_snapshot == expected_snapshot, (actual_snapshot, expected_snapshot)

    chunks_code = r'''
from reta_architecture.console_io import chunks
values = ["a", "b", "c", "d", "e"]
for chunk in chunks(values, 2):
    print("chunk=" + "\x1f".join(chunk))
'''
    assert native(args.binary, "--chunks", "2", "a", "b", "c", "d", "e") == reference(
        args.python, chunks_code
    )

    unique_code = r'''
from reta_architecture.console_io import unique_everseen
values = ["A", "b", "a", "B", "c"]
print("unique=" + "\x1f".join(unique_everseen(values)))
'''
    assert native(args.binary, "--unique", "A", "b", "a", "B", "c") == reference(
        args.python, unique_code
    )

    lower_code = r'''
from reta_architecture.console_io import unique_everseen
values = ["A", "b", "a", "B", "c"]
print("unique=" + "\x1f".join(unique_everseen(values, key=str.lower)))
'''
    assert native(args.binary, "--unique-lower", "A", "b", "a", "B", "c") == reference(
        args.python, lower_code
    )

    cli_code = r'''
import contextlib, io
import reta_architecture.console_io as console_io
class PlainSyntax:
    def __init__(self, text, *args, **kwargs):
        self.text = text
    def __str__(self):
        return self.text
class PlainConsole:
    def __init__(self, *args, **kwargs):
        pass
    def print(self, *args, **kwargs):
        print(" ".join(str(arg) for arg in args), end=kwargs.get("end", "\n"))
console_io.Syntax = PlainSyntax
console_io.Console = PlainConsole
buffer = io.StringIO()
with contextlib.redirect_stdout(buffer):
    console_io.cli_output("  eins\n zwei\t drei ", color=True)
print(buffer.getvalue(), end="")
'''
    assert native(
        args.binary, "--cli", "true", "true", "  eins\n zwei\t drei "
    ) == reference(args.python, cli_code)

    help_code = r'''
import sys
from pathlib import Path
from types import SimpleNamespace
from reta_architecture.console_io import reta_help_text, reta_prompt_help_text
kind, language = sys.argv[1:]
suffix = "-en" if language == "english" else ""
i18n = SimpleNamespace(readMeFileNames=SimpleNamespace(
    retaPrompt=f"readme-retaPrompt{suffix}.md",
    reta=f"readme-reta{suffix}.md",
))
root = Path("python_reference")
text = reta_prompt_help_text(root, i18n) if kind == "prompt" else reta_help_text(root, i18n)
sys.stdout.write(text)
'''
    for kind in ("prompt", "reta"):
        for language in ("german", "english"):
            assert native(args.binary, "--help-text", kind, language) == reference(
                args.python, help_code, kind, language
            )

    print("console-io parity: ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
