from __future__ import annotations

import ast
import hashlib
import subprocess
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PY_SOURCE = ROOT / "python_reference/reta_architecture/input_semantics.py"
MOJO_INPUT = ROOT / "src/reta_mojo/input_semantics.mojo"
MOJO_RANGES = ROOT / "src/reta_mojo/row_ranges.mojo"
CATALOG = ROOT / "assets/input_semantics_catalog.tsv"


def _python_surface() -> tuple[dict[str, tuple[str, ...]], tuple[str, ...]]:
    tree = ast.parse(PY_SOURCE.read_text(encoding="utf-8"))
    classes: dict[str, tuple[str, ...]] = {}
    functions: list[str] = []
    for node in tree.body:
        if isinstance(node, ast.ClassDef):
            classes[node.name] = tuple(
                child.name
                for child in node.body
                if isinstance(child, (ast.FunctionDef, ast.AsyncFunctionDef))
            )
        elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            functions.append(node.name)
    return classes, tuple(functions)


def test_complete_python_input_surface_has_native_owners() -> None:
    classes, functions = _python_surface()
    assert set(classes) == {
        "RowRangeSyntax",
        "PromptVocabulary",
        "PromptVocabularyBuilder",
        "InputBundle",
    }
    assert functions == ()
    input_source = MOJO_INPUT.read_text(encoding="utf-8")
    range_source = MOJO_RANGES.read_text(encoding="utf-8")
    owners = input_source + range_source
    for class_name in classes:
        assert f"struct {class_name}" in owners
    for class_name, methods in classes.items():
        for method in methods:
            if method == "__init__":
                continue
            assert f"def {method}(" in owners or f"def {method}(\n" in owners
    for field in (
        "main_parameters",
        "spalten",
        "eigs_n",
        "eigs_r",
        "spalten_dict",
        "ausgabe_paras",
        "kombi_main_paras",
        "zeilen_paras",
        "haupt_for_neben",
        "not_parameter_values",
        "haupt_for_neben_set",
        "ausgabe_art",
        "zeilen_typen",
        "zeilen_zeit",
        "zeilen_typen_b",
        "gebrochen_erlaubte_zahlen",
        "befehle",
        "befehle2",
    ):
        assert f"var {field}:" in input_source


def test_generated_catalog_is_idempotent_and_complete() -> None:
    before = hashlib.sha256(CATALOG.read_bytes()).hexdigest()
    result = subprocess.run(
        ["python3", "tools/generate_input_semantics_catalog.py"],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    after = hashlib.sha256(CATALOG.read_bytes()).hexdigest()
    assert before == after
    assert "input_semantics_catalog=17741 rows" in result.stdout

    rows = [
        line.split("\t")
        for line in CATALOG.read_text(encoding="utf-8").splitlines()
        if line and not line.startswith("#")
    ]
    assert len(rows) == 17741
    assert all(len(row) == 5 for row in rows)
    counts = Counter((row[0], row[1]) for row in rows)
    assert counts[("list", "main_parameters")] == 7
    assert counts[("list", "spalten")] == 4160
    assert counts[("list", "ausgabe_paras")] == 14
    assert counts[("list", "kombi_main_paras")] == 3
    assert counts[("list", "zeilen_paras")] == 15
    assert counts[("list", "befehle")] == 386
    assert counts[("set", "befehle2")] == 385
    assert counts[("intset", "gebrochen_erlaubte_zahlen")] == 21
    map_keys = {row[2] for row in rows if row[0] in {"map", "map-empty"}}
    assert len(map_keys) == 84


def test_catalog_preserves_reference_order_duplicates_and_empty_domains() -> None:
    fields: dict[str, list[str]] = defaultdict(list)
    maps: dict[str, list[str]] = defaultdict(list)
    empty_maps: set[str] = set()
    for raw in CATALOG.read_text(encoding="utf-8").splitlines():
        if not raw or raw.startswith("#"):
            continue
        kind, field, key, ordinal, value = raw.split("\t")
        if kind == "list":
            assert int(ordinal) == len(fields[field])
            fields[field].append(value)
        elif kind == "map":
            assert int(ordinal) == len(maps[key])
            maps[key].append(value)
        elif kind == "map-empty":
            empty_maps.add(key)
    assert fields["main_parameters"] == [
        "-zeilen",
        "-spalten",
        "-kombination",
        "-ausgabe",
        "-debug",
        "-h",
        "-help",
    ]
    assert fields["spalten"][:4] == [
        "--Wichtigstes_zum_verstehen=",
        "--Wichtigstes_zum_verstehen=",
        "--wichtigsteverstehen=",
        "--wichtigsteverstehen=",
    ]
    assert "sternpolygon" in maps["Religionen"]
    assert "gleichfoermigespolygon" in maps["Religionen"]
    assert empty_maps == {"Licht", "licht"}


def test_no_python_bridge_and_reserved_alias_regression_is_fixed() -> None:
    source = MOJO_INPUT.read_text(encoding="utf-8") + MOJO_RANGES.read_text(encoding="utf-8")
    for token in ("std.python", "PythonObject", "subprocess", "fork(", "execve("):
        assert token not in source
    modes = (ROOT / "src/reta_mojo/output_modes.mojo").read_text(encoding="utf-8")
    assert "for alias in" not in modes
    assert "for alias_index in range(len(spec.aliases))" in modes
    assert "for character_slice in text.codepoint_slices()" in source
    assert "def _drop_first_codepoint(" in source
    assert "parse_explicit_int_set(_drop_first_codepoint(text))" in source
    assert "parse_explicit_int_set(_tail(text, 1))" not in source
    assert "is_row_range_token as _row_range_is_token" in source
    assert "def is_row_range_token(" in MOJO_INPUT.read_text(encoding="utf-8")


def test_installer_accepts_an_explicit_compiler_target_directory() -> None:
    install_source = (ROOT / "scripts/install.sh").read_text(encoding="utf-8")
    layout_test = (ROOT / "tests/test_install_layout.py").read_text(encoding="utf-8")
    assert 'TARGETDIR=${RETA_TARGET_DIR:-$ROOT/target/bin}' in install_source
    assert 'executable="$TARGETDIR/$name"' in install_source
    assert '"RETA_TARGET_DIR": str(_layout_target_dir(tmp_path))' in layout_test


def test_stage_wiring_contains_native_and_python_parity_checks() -> None:
    stage = (ROOT / "scripts/test_stage12c5w.sh").read_text(encoding="utf-8")
    assert "test_input_semantics.mojo" in stage
    assert "check_input_semantics_parity.py" in stage
    assert "test_input_semantics_complete_source.py" in stage
    launcher = (ROOT / "bin/reta-mojo").read_text(encoding="utf-8")
    assert '"--mojo-input-snapshot"' in launcher
