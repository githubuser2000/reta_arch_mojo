from __future__ import annotations

import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "sanitize_mojo_runpath", ROOT / "tools" / "sanitize_mojo_runpath.py"
)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def test_absolute_compiler_path_is_removed_but_origin_is_preserved() -> None:
    old = "/home/alex/project/.venv/lib/python3.14/site-packages/modular/lib:$ORIGIN/../lib/mojo"
    assert MODULE.portable_runpath(old) == "$ORIGIN/../lib/mojo"


def test_origin_component_is_added_once() -> None:
    assert MODULE.portable_runpath("/tmp/modular/lib") == "$ORIGIN/../lib/mojo"
    assert MODULE.portable_runpath("$ORIGIN/../lib/mojo:$ORIGIN/../lib/mojo") == "$ORIGIN/../lib/mojo"


def test_library_layout_uses_its_own_relative_component() -> None:
    old = "/opt/modular/lib:$ORIGIN/../mojo"
    assert MODULE.portable_runpath(old, "$ORIGIN/../mojo") == "$ORIGIN/../mojo"
