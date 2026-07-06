from __future__ import annotations

import ast
import csv
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference/tests/test_architecture_refactor.py"
MANIFEST = ROOT / "assets/architecture_refactor_contracts.tsv"


def _reference_methods() -> list[ast.FunctionDef]:
    tree = ast.parse(REFERENCE.read_text(encoding="utf-8"))
    for node in tree.body:
        if isinstance(node, ast.ClassDef) and node.name == "ArchitectureRefactorRegressionTest":
            return [
                item
                for item in node.body
                if isinstance(item, ast.FunctionDef) and item.name.startswith("test_")
            ]
    raise AssertionError("reference regression class missing")


def _assertion_count(method: ast.FunctionDef) -> int:
    return sum(
        isinstance(node, ast.Call)
        and isinstance(node.func, ast.Attribute)
        and isinstance(node.func.value, ast.Name)
        and node.func.value.id == "self"
        and node.func.attr.startswith("assert")
        for node in ast.walk(method)
    )


def _fingerprint(method: ast.FunctionDef) -> str:
    payload = ast.dump(method, annotate_fields=True, include_attributes=False).encode()
    return hashlib.sha256(payload).hexdigest()


def _rows() -> list[dict[str, str]]:
    with MANIFEST.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


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


def test_manifest_is_an_exact_ordered_70_to_70_transcription() -> None:
    methods = _reference_methods()
    rows = _rows()
    assert len(methods) == len(rows) == 70
    assert sum(_assertion_count(method) for method in methods) == 1060
    assert len({row["python_test"] for row in rows}) == 70
    for ordinal, (method, row) in enumerate(zip(methods, rows, strict=True), 1):
        assert int(row["ordinal"]) == ordinal
        assert row["python_test"] == method.name
        assert int(row["line"]) == method.lineno
        assert int(row["assertions"]) == _assertion_count(method)
        assert row["ast_sha256"] == _fingerprint(method)


def test_every_reference_contract_has_live_native_evidence() -> None:
    rows = _rows()
    assert len({row["category"] for row in rows}) == 18
    assert len({row["native_test"] for row in rows}) == 64
    for row in rows:
        assert row["native_owner"].endswith(".mojo")
        target = ROOT / row["native_test"]
        assert target.is_file(), row["native_test"]
        assert row["evidence"] in target.read_text(encoding="utf-8"), row["python_test"]


def test_native_catalog_is_typed_and_runtime_python_free() -> None:
    source = (ROOT / "src/reta_mojo/architecture_refactor_contracts.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct ArchitectureRefactorContract" in source
    assert "struct ArchitectureRefactorContractSnapshot" in source
    assert "load_architecture_refactor_contracts" in source
    assert "architecture_refactor_contracts_valid" in source
    assert "architecture_refactor_contract_snapshot" in source
    assert "PythonKit" not in source
    assert "run_process" not in source
    assert "subprocess" not in source
    package = (ROOT / "src/reta_mojo/__init__.mojo").read_text(encoding="utf-8")
    assert "from .architecture_refactor_contracts import *" in package


def test_reference_test_package_and_monolith_are_generated_native() -> None:
    mapping = _native_mapping()
    status, owner, note = mapping["tests/test_architecture_refactor.py"]
    assert status == "generiert nativ"
    assert "architecture_refactor_contracts.mojo" in owner
    assert "70" in note and "1.060" in note
    init_status, init_owner, init_note = mapping["tests/__init__.py"]
    assert init_status == "generiert nativ"
    assert "src/reta_mojo/__init__.mojo" in init_owner
    assert "leer" in init_note


def test_stage_12c5ar_remains_in_current_chain_and_compilation_stays_user_invoked() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    monotonic_stage = (ROOT / "scripts/test_stage12c5aw.sh").read_text(encoding="utf-8")
    current_stage = (ROOT / "scripts/test_stage12c5av.sh").read_text(encoding="utf-8")
    startup_stage = (ROOT / "scripts/test_stage12c5au.sh").read_text(encoding="utf-8")
    prompt_stage = (ROOT / "scripts/test_stage12c5at.sh").read_text(encoding="utf-8")
    stage = (ROOT / "scripts/test_stage12c5ar.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert ".sh" in current
    presheaf_stage = (ROOT / "scripts/test_stage12c5bd.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bc.sh" in presheaf_stage
    installed_launcher_stage = (ROOT / "scripts/test_stage12c5bc.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bb.sh" in installed_launcher_stage
    positive_first_stage = (ROOT / "scripts/test_stage12c5bb.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ba.sh" in positive_first_stage
    build_fix_stage = (ROOT / "scripts/test_stage12c5ba.sh").read_text(encoding="utf-8")
    assert "test_stage12c5az.sh" in build_fix_stage
    mixed_fraction_stage = (ROOT / "scripts/test_stage12c5az.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ay.sh" in mixed_fraction_stage
    process_alias_stage = (ROOT / "scripts/test_stage12c5ay.sh").read_text(encoding="utf-8")
    historical_prompt_stage = (ROOT / "scripts/test_stage12c5ax.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ax.sh" in process_alias_stage
    assert "test_stage12c5aw.sh" in historical_prompt_stage
    assert "test_stage12c5av.sh" in monotonic_stage
    assert "test_stage12c5au.sh" in current_stage
    assert "test_stage12c5at.sh" in startup_stage
    assert "test_stage12c5as.sh" in prompt_stage
    assert "tests/test_architecture_refactor_native.mojo" in stage
    assert "generate_architecture_refactor_contracts.py --check" in stage
    # Production builds remain separate from test compilation.
    for name in ("build.sh", "build-heavy.sh", "build-all.sh"):
        source = (ROOT / "scripts" / name).read_text(encoding="utf-8")
        assert "tests/test_*.mojo" not in source
        assert "test_architecture_refactor_native.mojo" not in source
