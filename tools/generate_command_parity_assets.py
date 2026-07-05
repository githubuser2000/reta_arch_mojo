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
REFERENCE_RUNTIME_STUBS = ROOT / "tools/reference_runtime_stubs"

# Hashes produced by the pre-12c5bg ambient-runtime snapshots that reached a
# developer tree through the historical patch chain.  Only these exact stale
# states may be migrated automatically; every unknown mismatch remains a hard
# failure so a real reference change cannot silently rewrite fixtures.

# Byte-identical command-parity fixtures are a versioned native contract.
# Stage tests validate these hashes without executing the frozen Python renderer,
# because CPython minor versions may alter incidental HTML serialization even
# after third-party Rich imports have been isolated.  Reference regeneration is
# still available explicitly through --check-reference or the default write mode.
CANONICAL_ASSET_HASHES: dict[str, str] = {
    "assets/command_parity/html-religion-basic.out":
        "a8a0d2a1bdc526900647d5ab9bb0f7963adcb941160624dcff19f2bc18a55d5e",
    "assets/command_parity/markdown-religion-basic.out":
        "0a2f6b9c8c02edf13933cfe4e06912628cbf78f8b43934caf9d005eb6c784f8e",
    "assets/command_parity/shell-fractional-csv-gluing.out":
        "9a37c341d65e55ea40a17bdec9a3e07c0b50aa09561512791722a654264dc35f",
    "assets/command_parity/shell-religion-basic.out":
        "8b3a3ebd821ad9399b4978b2c7f6c5e3500ed0762055b51da7e38839bab2826a",
    "assets/command_parity.tsv":
        "9fdefe9a6a5301099483a0354fd25285b05f546c5895ce48040ca2843addb556",
}

LEGACY_ASSET_HASHES: dict[str, set[str]] = {
    "assets/command_parity/html-religion-basic.out": {
        "17453b000830c6e0e70189ab4475204b29aa808763693e094cda854d223c3820",
    },
    "assets/command_parity.tsv": {
        "87f6d8c460428b371cb9b5fea8ec280efec54063693df19cc0b2a9e2da25b0c0",
    },
}


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
    env["PYTHONNOUSERSITE"] = "1"
    previous_pythonpath = env.get("PYTHONPATH", "")
    env["PYTHONPATH"] = str(REFERENCE_RUNTIME_STUBS) + (
        os.pathsep + previous_pythonpath if previous_pythonpath else ""
    )
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




def canonical_asset_mismatches() -> list[tuple[str, str, str]]:
    """Return relative path, actual hash and pinned hash for noncanonical files."""
    mismatches: list[tuple[str, str, str]] = []
    for relative, expected_hash in CANONICAL_ASSET_HASHES.items():
        path = ROOT / relative
        actual_hash = (
            hashlib.sha256(path.read_bytes()).hexdigest()
            if path.exists()
            else "missing"
        )
        if actual_hash != expected_hash:
            mismatches.append((relative, actual_hash, expected_hash))
    return mismatches


def generated_payload_hash_mismatches(
    files: dict[Path, bytes],
) -> list[tuple[str, str, str]]:
    """Compare freshly generated reference payloads with the pinned contract."""
    mismatches: list[tuple[str, str, str]] = []
    for relative, expected_hash in CANONICAL_ASSET_HASHES.items():
        path = ROOT / relative
        payload = files.get(path)
        actual_hash = (
            hashlib.sha256(payload).hexdigest() if payload is not None else "missing"
        )
        if actual_hash != expected_hash:
            mismatches.append((relative, actual_hash, expected_hash))
    return mismatches

def migrate_legacy_assets(files: dict[Path, bytes], mismatches: list[str]) -> tuple[bool, list[str]]:
    """Replace only exact historical asset states; return success and errors."""
    unknown: list[str] = []
    for relative in mismatches:
        path = ROOT / relative
        actual = path.read_bytes() if path.exists() else b""
        actual_hash = hashlib.sha256(actual).hexdigest() if path.exists() else "missing"
        if actual_hash not in LEGACY_ASSET_HASHES.get(relative, set()):
            unknown.append(f"{relative}: {actual_hash}")
    if unknown:
        return False, unknown
    for relative in mismatches:
        path = ROOT / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(files[path])
    return True, []

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--check-reference", action="store_true")
    parser.add_argument("--migrate-legacy", action="store_true")
    args = parser.parse_args()

    selected = sum(
        int(value)
        for value in (args.check, args.check_reference, args.migrate_legacy)
    )
    if selected > 1:
        parser.error(
            "--check, --check-reference and --migrate-legacy are mutually exclusive"
        )

    if args.check:
        mismatches = canonical_asset_mismatches()
        if mismatches:
            print("command parity assets differ from the pinned canonical contract:")
            for relative, actual_hash, expected_hash in mismatches:
                print(
                    f"  {relative}: actual={actual_hash} expected={expected_hash}"
                )
            return 1
        print(
            "command parity assets verified: "
            f"{len(CANONICAL_ASSET_HASHES) - 1} pinned cases"
        )
        return 0

    if args.migrate_legacy:
        mismatches = canonical_asset_mismatches()
        if not mismatches:
            print("command parity assets already canonical")
            return 0

        unknown: list[str] = []
        for relative, actual_hash, _ in mismatches:
            if actual_hash not in LEGACY_ASSET_HASHES.get(relative, set()):
                unknown.append(f"{relative}: {actual_hash}")
        if unknown:
            print("refusing to migrate unknown command parity assets:")
            for item in unknown:
                print(f"  {item}")
            return 1

        files = expected_files()
        generated_mismatches = generated_payload_hash_mismatches(files)
        if generated_mismatches:
            print(
                "refusing to migrate: this Python interpreter does not "
                "reproduce the pinned command parity contract:"
            )
            for relative, actual_hash, expected_hash in generated_mismatches:
                print(
                    f"  {relative}: generated={actual_hash} pinned={expected_hash}"
                )
            return 1

        relative_paths = [relative for relative, _, _ in mismatches]
        migrated, unknown = migrate_legacy_assets(files, relative_paths)
        if not migrated:
            print("refusing to migrate unknown command parity assets:")
            for item in unknown:
                print(f"  {item}")
            return 1
        print(f"migrated legacy command parity assets: {len(relative_paths)}")
        return 0

    files = expected_files()
    mismatches: list[str] = []
    for path, payload in files.items():
        if args.check_reference:
            if not path.exists() or path.read_bytes() != payload:
                mismatches.append(path.relative_to(ROOT).as_posix())
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(payload)

    if mismatches:
        print("command parity reference output differs from pinned assets:")
        for relative in mismatches:
            path = ROOT / relative
            expected = files[path]
            actual = path.read_bytes() if path.exists() else b""
            expected_hash = hashlib.sha256(expected).hexdigest()
            actual_hash = (
                hashlib.sha256(actual).hexdigest() if path.exists() else "missing"
            )
            print(f"  {relative}: actual={actual_hash} generated={expected_hash}")
        return 1
    action = "reference-verified" if args.check_reference else "generated"
    print(f"command parity assets {action}: {len(files) - 1} cases")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
