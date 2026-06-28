from __future__ import annotations

import csv
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]


def _header(name: str) -> list[str]:
    with (REPO / "csv" / name).open("r", encoding="utf-8-sig", newline="") as handle:
        return next(csv.reader(handle, delimiter=";"))


def test_religion_csv_has_py_reta_truth_tail_columns() -> None:
    for name in ["religion.csv", "cn-religion.csv", "en-religion.csv", "kr-religion.csv", "vn-religion.csv"]:
        header = _header(name)
        assert len(header) == 746
        assert header[744] == "Neues M (13) Kontinuum"
        assert header[745] == "alternative Größenordnungen"


def test_architecture_matrix_selects_py_reta_truth_columns() -> None:
    matrix = (REPO / "i18n" / "words_matrix.py").read_text(encoding="utf-8")
    assert "{4, 21, 54, 197, 425, 745}" in matrix
    assert "{30, 82, 425, 745}" in matrix
    assert "{493, 744}" in matrix
    assert "{4, 21, 54, 197, 425}" not in matrix
    assert "{30, 82, 425}" not in matrix
    assert "{493}" not in matrix


def test_tag_schema_knows_new_truth_columns() -> None:
    tag_schema = (REPO / "reta_architecture" / "tag_schema.py").read_text(encoding="utf-8")
    assert "744," in tag_schema
    assert "745," in tag_schema
