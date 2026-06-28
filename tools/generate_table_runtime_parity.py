#!/usr/bin/env python3
"""Generate Mojo parity tests from Python table-state/wrapping/output semantics."""
from __future__ import annotations

import json
import sys
from pathlib import Path
from types import SimpleNamespace

ROOT = Path(__file__).resolve().parents[1]
PYREF = ROOT / "python_reference"
sys.path.insert(0, str(PYREF))

from reta_architecture.output_semantics import bootstrap_output_semantics  # noqa: E402
from reta_architecture.table_state import bootstrap_table_state  # noqa: E402
from reta_architecture.table_wrapping import (  # noqa: E402
    split_more_if_not_small,
    width_for_row,
)


def q(value: object) -> str:
    return json.dumps(str(value), ensure_ascii=False)


def mojo_string_list(values: list[str] | tuple[str, ...]) -> str:
    return "[" + ", ".join(q(value) for value in values) + "]"


def mojo_int_list(values: list[int]) -> str:
    return "[" + ", ".join(str(value) for value in values) + "]"


def main() -> None:
    split_cases = [
        (["ab", "cd"], 2),
        (["abcde", "xy"], 2),
        (["äöü漢字", "xy"], 2),
        (["abcdef"], 4),
        ([""], 3),
    ]
    width_cases = [
        (80, 3, [10, 20, 30], 21, 1, 0),
        (80, 3, [10, 20, 30], 21, 3, 0),
        (80, 5, [10, 20, 30], 21, 1, 2),
        (0, 3, [10, 20, 30], 21, 1, 0),
        (80, 3, [], 21, 1, 0),
        (120, 6, [7, 8, 9], 44, 2, 3),
    ]

    lines = [
        '"""Generated parity tests from the Python table architecture."""',
        "",
        "from std.collections import List",
        "from std.testing import assert_equal, TestSuite",
        "from reta_mojo.table_state import create_table_state",
        "from reta_mojo.table_wrapping import split_more_if_not_small, width_for_row",
        "from reta_mojo.output_modes import default_output_runtime_state, apply_output_mode",
        "",
        "",
        "def test_generated_split_more_parity() raises:",
    ]
    for index, (values, width) in enumerate(split_cases):
        expected = list(split_more_if_not_small(values, width))
        lines.extend(
            [
                f"    var source_{index}: List[String] = {mojo_string_list(values)}",
                f"    var result_{index} = split_more_if_not_small(source_{index}, {width})",
                f"    var expected_{index}: List[String] = {mojo_string_list(expected)}",
                f"    assert_equal(len(result_{index}), len(expected_{index}))",
                f"    for value_index in range(len(expected_{index})):",
                f"        assert_equal(result_{index}[value_index], expected_{index}[value_index])",
            ]
        )

    lines.extend(["", "", "def test_generated_width_for_row_parity() raises:"])
    for index, (shell, rows, widths, text_width, row, combi) in enumerate(width_cases):
        prepare = SimpleNamespace(
            shellRowsAmount=shell,
            rowsAsNumbers=list(range(rows)),
            breiten=widths,
            textwidth=text_width,
        )
        expected = width_for_row(prepare, row, combi)
        lines.extend(
            [
                f"    var widths_{index}: List[Int] = {mojo_int_list(widths)}",
                f"    assert_equal(width_for_row({shell}, {rows}, widths_{index}, {text_width}, {row}, {combi}), {expected})",
            ]
        )

    default_snapshot = bootstrap_table_state().create_sections().snapshot()
    explicit_snapshot = bootstrap_table_state().create_sections(42).snapshot()
    lines.extend(
        [
            "",
            "",
            "def test_generated_table_state_parity() raises:",
            "    var default_state = create_table_state()",
            f"    assert_equal(default_state.highest_rows[1024], {default_snapshot['highest_rows'][1024]})",
            f"    assert_equal(default_state.highest_rows[114], {default_snapshot['highest_rows'][114]})",
            "    var explicit_state = create_table_state(42)",
            f"    assert_equal(explicit_state.highest_rows[1024], {explicit_snapshot['highest_rows'][1024]})",
            f"    assert_equal(explicit_state.highest_rows[114], {explicit_snapshot['highest_rows'][114]})",
        ]
    )

    semantics = bootstrap_output_semantics(PYREF)
    lines.extend(["", "", "def test_generated_output_mode_application_parity() raises:"])
    for mode in sorted(semantics.mode_specs):
        spec = semantics.mode_specs[mode]
        application = SimpleNamespace(
            canonical_name=spec.canonical_name,
            syntax_class_name=spec.syntax_class.__name__,
            force_one_table=spec.force_one_table,
            force_zero_width=spec.force_zero_width,
            marks_html_or_bbcode=spec.marks_html_or_bbcode,
        )
        lines.extend(
            [
                f"    var state_{mode} = apply_output_mode(default_output_runtime_state(), {q(mode)})",
                f"    assert_equal(state_{mode}.canonical_name, {q(application.canonical_name)})",
                f"    assert_equal(state_{mode}.syntax_class_name, {q(application.syntax_class_name)})",
                f"    assert_equal(state_{mode}.one_table, {str(application.force_one_table)})",
                f"    assert_equal(state_{mode}.text_width, {0 if application.force_zero_width else 21})",
                f"    assert_equal(state_{mode}.marks_html_or_bbcode, {str(application.marks_html_or_bbcode)})",
            ]
        )

    lines.extend(
        [
            "",
            "",
            "def main() raises:",
            "    TestSuite.discover_tests[__functions_in_module()]().run()",
            "",
        ]
    )
    target = ROOT / "tests/test_generated_table_runtime_parity.mojo"
    target.write_text("\n".join(lines), encoding="utf-8")
    print(f"Generated {target}")


if __name__ == "__main__":
    main()
