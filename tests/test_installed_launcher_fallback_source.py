from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LAUNCHER = ROOT / "bin/reta-mojo"
INSTALL_TEST = ROOT / "tests/test_install_layout.py"


def test_reta_mojo_source_fallback_requires_an_existing_source() -> None:
    source = LAUNCHER.read_text(encoding="utf-8")
    assert "run_source_or_missing()" in source
    assert 'if [ ! -f "$source" ]; then' in source
    assert "Fehlendes Compilerziel: %s" in source
    assert "Keine installierte Mojo-Quelle verfügbar: %s" in source
    assert "exit 127" in source
    for target, module in (
        ("reta-mojo-schema", "schema_main.mojo"),
        ("reta-mojo-architecture", "architecture_main.mojo"),
        ("reta-mojo-tags", "tags_main.mojo"),
        ("reta-mojo-table", "table_main.mojo"),
        ("reta-mojo-native", "main.mojo"),
    ):
        assert f'run_source_or_missing "$ROOT/target/bin/{target}"' in source
        assert f'"$ROOT/src/{module}"' in source


def test_fhs_contract_expects_missing_target_not_missing_source_compilation() -> None:
    source = INSTALL_TEST.read_text(encoding="utf-8")
    assert 'assert csv_info.returncode == 127' in source
    assert 'assert "Fehlendes Compilerziel" in csv_info.stderr' in source
    assert 'assert "Keine installierte Mojo-Quelle verfügbar" in csv_info.stderr' in source
