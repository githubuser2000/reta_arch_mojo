from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACKAGE_ROOT = ROOT / "src/reta_mojo"
RELATIVE_IMPORT = re.compile(
    r"^from\s+\.([A-Za-z_][A-Za-z0-9_]*)\s+import\b", re.MULTILINE
)


def test_all_relative_reta_mojo_imports_resolve_to_source_modules() -> None:
    modules = {path.stem for path in PACKAGE_ROOT.glob("*.mojo")}
    missing: list[tuple[str, str]] = []
    for source_path in sorted(PACKAGE_ROOT.glob("*.mojo")):
        source = source_path.read_text(encoding="utf-8")
        for module_name in RELATIVE_IMPORT.findall(source):
            if module_name not in modules:
                missing.append((source_path.name, module_name))
    assert missing == []


def test_table_generation_uses_canonical_combi_join_module_name() -> None:
    source = (PACKAGE_ROOT / "table_generation.mojo").read_text(encoding="utf-8")
    assert "from .combi_join import (" in source
    assert "from .kombi_join import (" not in source
