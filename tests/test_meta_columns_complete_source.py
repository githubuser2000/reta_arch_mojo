from __future__ import annotations

import ast
import hashlib
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
PYTHON_OWNER = ROOT / "python_reference/reta_architecture/meta_columns.py"
MOJO_OWNER = ROOT / "src/reta_mojo/meta_columns.mojo"
PRIME_OWNER = ROOT / "src/reta_mojo/prime_effect_columns.mojo"
GENERATOR = ROOT / "scripts/generate_meta_columns_catalog.py"
CATALOG = ROOT / "assets/meta_columns_catalog.tsv"

PUBLIC_FUNCTIONS = {
    "bootstrap_meta_columns",
    "spalteMetaKontretTheorieAbstrakt_etc_1",
    "spalteMetaKonkretAbstrakt_isGanzZahlig",
    "spalteMetaKontretTheorieAbstrakt_etc",
    "spalteMetaKonkretTheorieAbstrakt_SetHtmlParameters",
    "spalteMetaKonkretTheorieAbstrakt_mainPart",
    "spalteMetaKonkretTheorieAbstrakt_VorwortBehandlungWieVorwortMeta",
    "spalteMetaKonkretTheorieAbstrakt_mainPart_InsertingText",
    "getAllBrueche",
    "readOneCSVAndReturn",
    "findAllBruecheAndTheirCombinations",
    "spalteMetaKonkretTheorieAbstrakt_getGebrRatUnivStrukturalie",
    "spalteMetaKonkretAbstrakt_UeberschriftenUndTags",
    "spalteFuerGegenInnenAussenSeitlichPrim",
}


def _catalog_rows() -> list[list[str]]:
    return [
        line.split("\t")
        for line in CATALOG.read_text(encoding="utf-8").splitlines()
        if line and not line.startswith("#")
    ]


def test_python_public_surface_has_a_typed_native_entry() -> None:
    tree = ast.parse(PYTHON_OWNER.read_text(encoding="utf-8"))
    functions = {
        node.name
        for node in tree.body
        if isinstance(node, ast.FunctionDef) and not node.name.startswith("_")
    }
    assert functions == PUBLIC_FUNCTIONS
    source = MOJO_OWNER.read_text(encoding="utf-8")
    for name in PUBLIC_FUNCTIONS:
        assert f'def {name}(' in source or (
            name == "spalteFuerGegenInnenAussenSeitlichPrim"
            and f'def {name}(' in source
        )
        assert f'MetaColumnsSurfaceEntry("{name}"' in source
    assert "PythonObject" not in source
    assert "std.python" not in source
    assert "subprocess" not in source
    assert "generate_prime_effect_columns" in source
    assert "struct MetaColumnsSnapshot" in source
    assert "def meta_columns_snapshot(" in source
    assert "def generate_prime_effect_columns(" in PRIME_OWNER.read_text(
        encoding="utf-8"
    )


def test_meta_fraction_catalog_is_exactly_reproducible() -> None:
    before = CATALOG.read_bytes()
    subprocess.run(
        [str(GENERATOR)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        env={**os.environ, "PYTHONHASHSEED": "0"},
    )
    assert CATALOG.read_bytes() == before


def test_meta_fraction_catalog_counts_and_source_hashes() -> None:
    rows = _catalog_rows()
    sources = [row for row in rows if row[0] == "source"]
    fractions = [row for row in rows if row[0] == "fraction"]
    combinations = [row for row in rows if row[0] == "combination"]
    assert len(sources) == 2
    assert len(fractions) == 87
    assert len(combinations) == 884
    assert sum(row[1] == "universe" for row in fractions) == 47
    assert sum(row[1] == "galaxy" for row in fractions) == 40
    expected_counts = {
        ("UniUni", "stern", "mul"): 80,
        ("UniUni", "stern", "div"): 0,
        ("UniUni", "gleichf", "mul"): 96,
        ("UniUni", "gleichf", "div"): 49,
        ("UniGal", "stern", "mul"): 78,
        ("UniGal", "stern", "div"): 0,
        ("UniGal", "gleichf", "mul"): 87,
        ("UniGal", "gleichf", "div"): 54,
        ("GalUni", "stern", "mul"): 78,
        ("GalUni", "stern", "div"): 0,
        ("GalUni", "gleichf", "mul"): 87,
        ("GalUni", "gleichf", "div"): 45,
        ("GalGal", "stern", "mul"): 90,
        ("GalGal", "stern", "div"): 0,
        ("GalGal", "gleichf", "mul"): 90,
        ("GalGal", "gleichf", "div"): 50,
    }
    for key, expected in expected_counts.items():
        assert sum(tuple(row[1:4]) == key for row in combinations) == expected
    for _, domain, filename, digest, count in sources:
        path = ROOT / "python_reference/csv" / filename
        assert hashlib.sha256(path.read_bytes()).hexdigest() == digest
        assert int(count) == sum(row[1] == domain for row in fractions)


def test_meta_columns_are_marked_fully_native_in_matrix_source() -> None:
    source = (ROOT / "tools/generate_porting_matrix.py").read_text(
        encoding="utf-8"
    )
    assert '"reta_architecture/meta_columns.py": ("nativ"' in source
    assert "meta_columns_catalog.tsv" in source
