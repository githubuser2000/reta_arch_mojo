from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYTHON_SOURCE = ROOT / "python_reference/reta_domain_probe_py.py"
MOJO_SOURCE = ROOT / "src/domain_probe_main.mojo"
BUILD = ROOT / "scripts/build.sh"
INSTALL_TARGETS = ROOT / "scripts/install_targets.txt"
BUILD_LAYOUT = ROOT / "scripts/check_build_layout.sh"


def test_native_domain_probe_owns_parameter_column_and_html_commands() -> None:
    tree = ast.parse(PYTHON_SOURCE.read_text(encoding="utf-8"))
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    assert any(isinstance(node, ast.FunctionDef) and node.name == "main" for node in tree.body)
    for command in (
        "mains",
        "params",
        "pairs",
        "pairs-json",
        "main-columns",
        "main-json",
        "pair",
        "pair-json",
        "column",
        "column-json",
        "reverse",
        "html-json",
        "html-all-json",
        "pair-html-json",
        "schema-json",
        "architecture-json",
    ):
        assert f'"{command}"' in source
    assert "bootstrap_reta_schema" in source
    assert "build_parameter_semantics" in source
    assert "canonicalize_pair" in source
    assert "reverse_map_canonical_pairs" in source
    assert "exact_meta_for_column" in source
    assert "load_html_reference_sheaf" in source
    assert "schema_snapshot_json" in source
    assert "std.python" not in source
    assert "PythonObject" not in source
    assert source.count('print("{\'column_number\': ", end="")') == 1


def test_domain_probe_is_a_regular_installable_compiler_target() -> None:
    build = BUILD.read_text(encoding="utf-8")
    targets = INSTALL_TARGETS.read_text(encoding="utf-8").splitlines()
    assert "build src/domain_probe_main.mojo reta-mojo-domain-probe -I src" in build
    assert "reta-mojo-domain-probe" in targets
    assert (ROOT / "tools/wrappers/reta-mojo-domain-probe").exists()
    assert "reta-mojo-domain-probe" in BUILD_LAYOUT.read_text(encoding="utf-8")


def test_domain_probe_parity_harness_covers_text_and_json_surfaces() -> None:
    source = (ROOT / "scripts/check_domain_probe_parity.py").read_text(encoding="utf-8")
    assert '("params", "religionen")' in source
    assert '("pairs", "religionen")' in source
    assert '("main-json", "religionen")' in source
    assert '("pair", "religionen", "sternpolygon")' in source
    assert '("pair-json", "religionen", "sternpolygon")' in source
    assert '("pairs-json", "religionen")' in source
    assert '("reverse", "4")' in source
    assert '("column", "4")' in source
    assert '("column-json", "4")' in source
    assert '("html-json", "4")' in source
    assert '("html-all-json",)' in source
    assert '("pair-html-json", "religionen", "sternpolygon")' in source
    assert '("schema-json",)' in source
    assert '("architecture-json",)' in source
    assert '("mains",)' in source
    assert 'if case == ("architecture-json",):' in source
    assert 'ASSET_DIR / "snapshot-json.json"' in source


def test_domain_parity_normalizes_python_cache_state() -> None:
    parity = (ROOT / "scripts/check_domain_probe_parity.py").read_text(encoding="utf-8")
    assert '"PYTHONDONTWRITEBYTECODE": "1"' in parity
    assert 'tools/generate_architecture_probe_assets.py' in parity
