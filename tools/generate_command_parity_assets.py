#!/usr/bin/env python3
"""Generate native command-parity fixtures from the canonical Python test.

The command matrix remains defined exactly once in
``python_reference/tests/test_command_parity.py``.  This generator extracts the
literal cases from that file, executes the maintained Python reference, and
freezes the observable output for the native Mojo regression test.
"""
from __future__ import annotations

import argparse
import ast
import hashlib
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE_TEST = ROOT / "python_reference/tests/test_command_parity.py"
REFERENCE_RETA = ROOT / "python_reference/reta.py"
ASSET_DIR = ROOT / "assets/command_parity"
MANIFEST = ROOT / "assets/command_parity.tsv"


def extract_cases() -> list[tuple[str, str, str]]:
    tree = ast.parse(REFERENCE_TEST.read_text(encoding="utf-8"))
    for node in tree.body:
        if not isinstance(node, ast.ClassDef) or node.name != "CommandParityMatrixTest":
            continue
        for item in node.body:
            if not isinstance(item, ast.FunctionDef) or item.name != "test_representative_command_matrix_matches_original":
                continue
            for statement in item.body:
                if not isinstance(statement, ast.Assign):
                    continue
                if not any(isinstance(target, ast.Name) and target.id == "cases" for target in statement.targets):
                    continue
                value = ast.literal_eval(statement.value)
                if not isinstance(value, list):
                    raise TypeError("command parity cases must be a list")
                result: list[tuple[str, str, str]] = []
                for entry in value:
                    if not (
                        isinstance(entry, tuple)
                        and len(entry) == 3
                        and all(isinstance(part, str) for part in entry)
                    ):
                        raise TypeError(f"invalid command parity entry: {entry!r}")
                    result.append(entry)
                return result
    raise RuntimeError("representative command parity matrix not found")


def normalize_html(text: str) -> str:
    def sort_p4(match: re.Match[str]) -> str:
        values = [item for item in match.group(1).split(",") if item]
        try:
            values = [str(value) for value in sorted(int(item) for item in values)]
        except ValueError:
            return match.group(0)
        return "p4_" + ",".join(values)

    text = re.sub(r"p4_([0-9,]+)", sort_p4, text)
    return re.sub(r"\s+", " ", text).strip()


def strip_stty_noise(text: str) -> str:
    lines: list[str] = []
    for line in text.splitlines():
        if line.startswith("stty: "):
            continue
        if line.startswith("Exception ignored in:"):
            continue
        if line.startswith("BrokenPipeError:"):
            continue
        if "SyntaxWarning:" in line or "invalid escape sequence" in line:
            continue
        lines.append(line)
    return "\n".join(lines).strip()


def run_reference(command: str) -> str:
    import shlex

    env = dict(os.environ)
    env["PYTHONHASHSEED"] = "0"
    env["PYTHONWARNINGS"] = "ignore"
    proc = subprocess.run(
        [sys.executable, str(REFERENCE_RETA), *shlex.split(command)],
        cwd=ROOT,
        env=env,
        capture_output=True,
        text=True,
        timeout=300,
    )
    if proc.returncode != 0:
        raise RuntimeError(
            f"reference command failed ({proc.returncode}): {command}\n{proc.stderr}"
        )
    noise = strip_stty_noise(proc.stderr)
    if noise:
        raise RuntimeError(f"unexpected reference stderr for {command!r}: {noise}")
    return proc.stdout


def expected_files() -> dict[Path, bytes]:
    files: dict[Path, bytes] = {}
    manifest_lines = ["label\tmode\tasset\tsha256\ttokens...\n"]
    for label, command, mode in extract_cases():
        output = run_reference(command)
        comparison_mode = "html" if mode == "html" else "exact"
        payload = normalize_html(output) if comparison_mode == "html" else output
        asset_name = f"{label}.out"
        encoded = payload.encode("utf-8")
        files[ASSET_DIR / asset_name] = encoded
        digest = hashlib.sha256(encoded).hexdigest()
        import shlex

        tokens = shlex.split(command)
        manifest_lines.append(
            "\t".join([label, comparison_mode, asset_name, digest, *tokens]) + "\n"
        )
    files[MANIFEST] = "".join(manifest_lines).encode("utf-8")
    return files


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()

    files = expected_files()
    mismatches: list[str] = []
    for path, payload in files.items():
        if args.check:
            if not path.exists() or path.read_bytes() != payload:
                mismatches.append(path.relative_to(ROOT).as_posix())
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(payload)

    if mismatches:
        print("command parity assets differ:")
        for path in mismatches:
            print(f"  {path}")
        return 1
    action = "verified" if args.check else "generated"
    print(f"command parity assets {action}: {len(files) - 1} cases")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
