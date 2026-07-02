from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_split_i18n_has_typed_native_owner() -> None:
    source = (ROOT / "src/reta_mojo/split_i18n.mojo").read_text(encoding="utf-8")
    assert "struct SplitI18nProxy" in source
    assert "default_split_i18n_module_names" in source
    assert "source_index = len(proxy.source_modules) - 1" in source
    assert "from std.python import" not in source


def test_split_i18n_porting_matrix_is_native() -> None:
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(line for line in matrix.splitlines() if "`reta_architecture/split_i18n.py`" in line)
    assert "| nativ |" in row
    assert "split_i18n.mojo" in row
