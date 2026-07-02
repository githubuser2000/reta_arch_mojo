from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_concat_csv_probe_has_a_dedicated_test_builder() -> None:
    helper = ROOT / "scripts/build_concat_csv_probe.sh"
    text = helper.read_text(encoding="utf-8")
    assert helper.stat().st_mode & 0o111
    assert "tests/concat_csv_probe.mojo" in text
    assert "target/tests/concat_csv_probe" in text


def test_production_builds_do_not_install_or_build_test_probe() -> None:
    regular = (ROOT / "scripts/build.sh").read_text(encoding="utf-8")
    heavy = (ROOT / "scripts/build-heavy.sh").read_text(encoding="utf-8")
    install_targets = (ROOT / "scripts/install_targets.txt").read_text(encoding="utf-8")
    assert "concat_csv_probe" not in regular
    assert "concat_csv_probe" not in heavy
    assert "concat_csv_probe" not in install_targets


def test_stage12c5e_uses_the_dedicated_probe_builder() -> None:
    stage = (ROOT / "scripts/test_stage12c5e.sh").read_text(encoding="utf-8")
    assert "scripts/build_concat_csv_probe.sh" in stage
    assert "scripts/check_concat_csv_parity.py" in stage
