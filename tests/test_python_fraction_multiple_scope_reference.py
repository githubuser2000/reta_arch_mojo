from __future__ import annotations

import contextlib
import io
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYTHON_REFERENCE = ROOT / "python_reference"
if str(PYTHON_REFERENCE) not in sys.path:
    sys.path.insert(0, str(PYTHON_REFERENCE))

from reta_architecture import prompt_execution as reference  # noqa: E402


class _Tables:
    hoechsteZeile = {1024: 1024}


class _Program:
    tables = _Tables()


def _parse(words: list[str]):
    with contextlib.redirect_stdout(io.StringIO()):
        return reference.bruchBereichsManagementAndWbefehl("", list(words), [])


def test_compact_v_prefix_belongs_to_its_comma_component() -> None:
    first = _parse(["universum", "v1/4,1/8"])
    second = _parse(["universum", "1/4,v1/8"])
    assert first[0] == "v4,8,"
    assert second[0] == "4,v8,"


def test_standalone_v_and_vielfache_are_position_independent(monkeypatch) -> None:
    monkeypatch.setattr(reference, "retaProgram", _Program())
    variants = (
        ["universum", "v", "1/4,-1/8,2/3"],
        ["v", "universum", "1/4,-1/8,2/3"],
        ["universum", "1/4,-1/8,2/3", "v"],
        ["universum", "vielfache", "1/4,-1/8,2/3"],
    )
    reciprocals = [_parse(list(words))[0] for words in variants]
    assert len(set(reciprocals)) == 1
    values = {int(value) for value in reciprocals[0].split(",") if value}
    assert values == {value for value in range(4, 1024, 4) if value % 8 != 0}
