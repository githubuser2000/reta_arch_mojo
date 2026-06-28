"""Typed mutable sections extracted from reta_architecture.table_state."""

from std.collections import Dict, List, Set


@fieldwise_init
struct GeneratedColumnSection(Copyable):
    """Generated-column metadata represented as stable textual payloads.

    Python stores ``Any`` values here. The native runtime owns the keys and
    serializes dynamic metadata at the compatibility boundary until the
    generated-column value types themselves are ported.
    """
    var parameters: Dict[Int, String]
    var tags: Dict[Int, String]


@fieldwise_init
struct TableDisplayState(Copyable):
    var no_headings: Bool
    var no_empty_contents: Bool
    var star_column: Bool
    var religion_numbers: List[Int]


@fieldwise_init
struct TableStateSections(Copyable):
    var highest_rows: Dict[Int, Int]
    var display: TableDisplayState
    var generated_columns: GeneratedColumnSection
    var row_display_to_original: Dict[Int, Int]
    var generated_rows: Set[Int]


def create_table_state(highest_row: Int = -1) -> TableStateSections:
    var highest_rows = Dict[Int, Int]()
    if highest_row < 0:
        highest_rows[1024] = 1024
        highest_rows[114] = 163
    else:
        highest_rows[1024] = highest_row
        highest_rows[114] = highest_row
    return TableStateSections(
        highest_rows^,
        TableDisplayState(False, False, False, List[Int]()),
        GeneratedColumnSection(Dict[Int, String](), Dict[Int, String]()),
        Dict[Int, Int](),
        Set[Int](),
    )


def set_highest_row(mut state: TableStateSections, value: Int) -> None:
    state.highest_rows[1024] = value
    state.highest_rows[114] = value


def generated_parameter_count(state: TableStateSections) -> Int:
    return len(state.generated_columns.parameters)


def generated_tag_count(state: TableStateSections) -> Int:
    return len(state.generated_columns.tags)


def state_section_names() -> List[String]:
    return [
        "highest_rows",
        "display",
        "generated_columns",
        "row_display_to_original",
        "generated_rows",
    ]
