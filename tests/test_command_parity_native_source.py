from __future__ import annotations

import ast
import csv
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _native_mapping() -> dict[str, tuple[str, str, str]]:
    tree = ast.parse((ROOT / "tools/generate_porting_matrix.py").read_text(encoding="utf-8"))
    for node in tree.body:
        if isinstance(node, ast.Assign) and any(
            isinstance(target, ast.Name) and target.id == "NATIVE"
            for target in node.targets
        ):
            value = ast.literal_eval(node.value)
            assert isinstance(value, dict)
            return value
    raise AssertionError("NATIVE mapping missing")


def _reference_cases() -> list[tuple[str, str, str]]:
    tree = ast.parse(
        (ROOT / "python_reference/tests/test_command_parity.py").read_text(
            encoding="utf-8"
        )
    )
    for node in ast.walk(tree):
        if not isinstance(node, ast.Assign):
            continue
        if not any(
            isinstance(target, ast.Name) and target.id == "cases"
            for target in node.targets
        ):
            continue
        value = ast.literal_eval(node.value)
        if isinstance(value, list) and len(value) == 4:
            return value
    raise AssertionError("reference command cases missing")


def test_generated_manifest_is_the_exact_reference_matrix() -> None:
    reference = _reference_cases()
    with (ROOT / "assets/command_parity.tsv").open(newline="", encoding="utf-8") as handle:
        rows = list(csv.reader(handle, delimiter="\t"))
    assert rows[0][:4] == ["label", "mode", "asset", "sha256"]
    assert len(rows[1:]) == len(reference) == 4
    for row, (label, command, mode) in zip(rows[1:], reference, strict=True):
        row_label, comparison_mode, asset, digest, *tokens = row
        assert row_label == label
        assert comparison_mode == ("html" if mode == "html" else "exact")
        import shlex

        assert tokens == shlex.split(command)
        payload = (ROOT / "assets/command_parity" / asset).read_bytes()
        assert hashlib.sha256(payload).hexdigest() == digest
        assert payload


def test_native_owner_is_typed_and_has_no_process_boundary() -> None:
    source = (ROOT / "src/reta_mojo/command_parity.mojo").read_text(encoding="utf-8")
    assert "struct CommandParityCase" in source
    assert "struct CommandParitySnapshot" in source
    assert "normalize_command_parity_html" in source
    assert "load_command_parity_cases" in source
    assert "import subprocess" not in source
    assert "PythonKit" not in source
    assert "run_process" not in source
    assert "native_reta_cli" not in source


def test_native_runtime_checker_uses_the_compiled_reta_binary() -> None:
    source = (ROOT / "scripts/check_command_parity_native.py").read_text(encoding="utf-8")
    assert 'ROOT / "target/bin/reta-native"' in source
    assert 'ROOT / "assets/command_parity.tsv"' in source
    assert "LD_LIBRARY_PATH" in source
    assert "python_reference/reta.py" not in source


def test_command_parity_reference_is_generated_native_and_current() -> None:
    mapping = _native_mapping()
    status, owner, note = mapping["tests/test_command_parity.py"]
    assert status == "generiert nativ"
    assert "command_parity.mojo" in owner
    assert "vier" in note
    package = (ROOT / "src/reta_mojo/__init__.mojo").read_text(encoding="utf-8")
    assert "from .command_parity import *" in package
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ba.sh" in current
    build_fix_stage = (ROOT / "scripts/test_stage12c5ba.sh").read_text(encoding="utf-8")
    assert "test_stage12c5az.sh" in build_fix_stage
    mixed_fraction_stage = (ROOT / "scripts/test_stage12c5az.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ay.sh" in mixed_fraction_stage
    process_alias_stage = (ROOT / "scripts/test_stage12c5ay.sh").read_text(encoding="utf-8")
    historical_prompt_stage = (ROOT / "scripts/test_stage12c5ax.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ax.sh" in process_alias_stage
    assert "test_stage12c5aw.sh" in historical_prompt_stage
    monotonic_stage = (ROOT / "scripts/test_stage12c5aw.sh").read_text(encoding="utf-8")
    assert "test_stage12c5av.sh" in monotonic_stage
    build_stage = (ROOT / "scripts/test_stage12c5av.sh").read_text(encoding="utf-8")
    assert "test_stage12c5au.sh" in build_stage
    startup_stage = (ROOT / "scripts/test_stage12c5au.sh").read_text(encoding="utf-8")
    assert "test_stage12c5at.sh" in startup_stage
    current_stage = (ROOT / "scripts/test_stage12c5at.sh").read_text(encoding="utf-8")
    assert "test_stage12c5as.sh" in current_stage
    refactor_stage = (ROOT / "scripts/test_stage12c5ar.sh").read_text(encoding="utf-8")
    assert "test_stage12c5aq.sh" in refactor_stage
