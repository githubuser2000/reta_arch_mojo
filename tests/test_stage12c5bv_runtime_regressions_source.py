from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MOJO_RENDERER = ROOT / "src/reta_mojo/table_rendering.mojo"
MOJO_RENDER_TEST = ROOT / "tests/test_table_rendering.mojo"
MOJO_ADAPTER_TEST = ROOT / "tests/test_table_adapters.mojo"


def test_python_reference_classifies_one_as_sun_and_four_as_moon() -> None:
    sys.path.insert(0, str(ROOT / "python_reference"))
    from reta_architecture.row_filtering import moonsun, set_zaehlungen

    class Prepare:
        originalLinesRange = range(0, 5)
        gezaehlt = False
        zaehlungen = [0, {}, {}, {}, {}]

    prepare = Prepare()
    set_zaehlungen(prepare, 4)
    values = {1, 2, 3, 4}
    assert moonsun(prepare, True, set(), values, True) == {4}
    assert moonsun(prepare, False, set(), values, True) == {1, 2, 3}


def test_mojo_adapter_test_freezes_the_actual_moon_sun_partition() -> None:
    source = MOJO_ADAPTER_TEST.read_text(encoding="utf-8")
    assert "assert_true(1 not in moons)" in source
    assert "assert_true(4 in moons)" in source
    assert "var suns = moonsun(rows, False)" in source
    assert "assert_true(1 in suns)" in source
    assert "assert_true(4 not in suns)" in source


def test_shell_renderer_accepts_a_test_only_terminal_width_override() -> None:
    source = MOJO_RENDERER.read_text(encoding="utf-8")
    assert "terminal_columns_override: Int = 0" in source
    assert "if terminal_columns_override > 0" in source
    assert "else terminal_columns()" in source


def test_terminal_sensitive_rendering_contracts_use_fixed_eighty_columns() -> None:
    source = MOJO_RENDER_TEST.read_text(encoding="utf-8")
    assert source.count("terminal_columns_override=80") >= 2
    assert "False, [0, 8], 80" in source
    assert "False, [8, 0, 8], 80" in source
