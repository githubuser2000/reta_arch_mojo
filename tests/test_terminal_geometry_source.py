from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GEOMETRY = ROOT / "src/reta_mojo/terminal_geometry.mojo"
CONTROLLER = ROOT / "src/prompt_main.mojo"
MOJO_TEST = ROOT / "tests/test_terminal_geometry.mojo"
OWNERSHIP_TEST = ROOT / "tests/test_prompt_historical_ownership.mojo"


def test_terminal_geometry_owns_rows_columns_and_compound_clear_count() -> None:
    source = GEOMETRY.read_text(encoding="utf-8")
    assert "def _ioctl_terminal_dimension(" in source
    assert "def terminal_columns(" in source
    assert "def terminal_rows(" in source
    assert 'getenv("COLUMNS"' in source
    assert 'getenv("LINES"' in source
    assert "def compound_clear_line_count(" in source
    assert "return max(1, rows) + 1" in source


def test_controller_uses_rows_plus_one_helper_only_for_compound_clear() -> None:
    source = CONTROLLER.read_text(encoding="utf-8")
    assert "compound_clear_line_count" in source
    helper = source.split("def _print_compound_clear_lines()", 1)[1].split(
        "def _print_start_help", 1
    )[0]
    assert "compound_clear_line_count(terminal_rows())" in helper
    assert 'print("\\x1b[2J\\x1b[H", end="")' in source
    assert source.count("_print_compound_clear_lines()") == 3


def test_mojo_tests_use_equatable_comparison_without_writable_requirement() -> None:
    source = OWNERSHIP_TEST.read_text(encoding="utf-8")
    assert "assert_true(first == second)" in source
    assert "assert_true(localized == first)" in source
    assert "assert_equal(first, second)" not in source
    assert "assert_equal(localized, first)" not in source


def test_mojo_geometry_test_binds_deterministic_line_counts() -> None:
    source = MOJO_TEST.read_text(encoding="utf-8")
    assert "test_compound_clear_uses_rows_plus_one" in source
    assert "compound_clear_line_count(24), 25" in source
    assert "compound_clear_line_count(0), 2" in source


def test_native_checker_disconnects_all_ttys_and_uses_lines_environment() -> None:
    source = (ROOT / "scripts/check_prompt_compound_clear_native.py").read_text(
        encoding="utf-8"
    )
    assert '"LINES": "3"' in source
    assert "stdin=subprocess.DEVNULL" in source
    assert "stdout=subprocess.PIPE" in source
    assert "stderr=subprocess.PIPE" in source
    assert 'b"\\n" * 4' in source
    assert '("clear", "emotions", "1")' in source
    assert 'standalone != b"\\x1b[2J\\x1b[H"' in source
    assert 'profile="retaPrompt.english"' in source
    assert 'argv.append("-befehl")' in source
