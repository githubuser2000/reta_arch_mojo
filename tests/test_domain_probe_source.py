from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYTHON_SOURCE = ROOT / "python_reference/reta_domain_probe_py.py"
MOJO_SOURCE = ROOT / "src/domain_probe_main.mojo"
BUILD = ROOT / "scripts/build.sh"
INSTALL_TARGETS = ROOT / "scripts/install_targets.txt"
BUILD_LAYOUT = ROOT / "scripts/check_build_layout.sh"


def test_native_domain_probe_owns_core_reference_commands() -> None:
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
        "reverse",
    ):
        assert f'"{command}"' in source
    assert "bootstrap_reta_schema" in source
    assert "build_parameter_semantics" in source
    assert "canonicalize_pair" in source
    assert "reverse_map_canonical_pairs" in source
    assert "std.python" not in source
    assert "PythonObject" not in source


def test_domain_probe_is_a_regular_installable_compiler_target() -> None:
    build = BUILD.read_text(encoding="utf-8")
    targets = INSTALL_TARGETS.read_text(encoding="utf-8").splitlines()
    assert "build src/domain_probe_main.mojo reta-mojo-domain-probe -I src" in build
    assert "reta-mojo-domain-probe" in targets
    assert (ROOT / "bin/reta-mojo-domain-probe").exists()
    assert "reta-mojo-domain-probe" in BUILD_LAYOUT.read_text(encoding="utf-8")


def test_domain_probe_parity_harness_covers_text_and_json_surfaces() -> None:
    source = (ROOT / "scripts/check_domain_probe_parity.py").read_text(encoding="utf-8")
    assert '("pair", "religionen", "sternpolygon")' in source
    assert '("pair-json", "religionen", "sternpolygon")' in source
    assert '("pairs-json", "religionen")' in source
    assert '("reverse", "4")' in source
