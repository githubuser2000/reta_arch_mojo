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


# ---------------------------------------------------------------------------
# Complete state factory/snapshot surface
# ---------------------------------------------------------------------------

@fieldwise_init
struct GeneratedColumnSectionSnapshot(Copyable):
    var class_name: String
    var parameters_len: Int
    var tags_len: Int
    var parameters_type: String
    var tags_type: String


@fieldwise_init
struct TableDisplayStateSnapshot(Copyable):
    var class_name: String
    var no_headings: Bool
    var no_empty_contents: Bool
    var star_column: Bool
    var religion_numbers_len: Int


@fieldwise_init
struct TableStateSectionsSnapshot(Copyable):
    var class_name: String
    var highest_main: Int
    var highest_multiple: Int
    var display: TableDisplayStateSnapshot
    var generated_columns: GeneratedColumnSectionSnapshot
    var row_display_to_original_len: Int
    var generated_rows_factory: String


@fieldwise_init
struct TableStateBundleSnapshot(Copyable):
    var class_name: String
    var sections: List[String]
    var architecture_owner: String
    var legacy_owner: String


@fieldwise_init
struct TableStateBundle(Copyable):
    """Typed factory replacing Python's dynamic OrderedDict/OrderedSet callables."""

    var ordered_dict_factory_name: String
    var ordered_set_factory_name: String

    def create_sections(self, highest_row: Int = -1) -> TableStateSections:
        return create_table_state(highest_row)

    def snapshot(self) -> TableStateBundleSnapshot:
        return TableStateBundleSnapshot(
            "TableStateBundle",
            state_section_names(),
            "reta_architecture.table_state",
            "reta_architecture.table_runtime.Tables",
        )


def generated_column_section_snapshot(
    section: GeneratedColumnSection,
) -> GeneratedColumnSectionSnapshot:
    return GeneratedColumnSectionSnapshot(
        "GeneratedColumnSection",
        len(section.parameters),
        len(section.tags),
        "Dict",
        "Dict",
    )


def table_display_state_snapshot(
    state: TableDisplayState,
) -> TableDisplayStateSnapshot:
    return TableDisplayStateSnapshot(
        "TableDisplayState",
        state.no_headings,
        state.no_empty_contents,
        state.star_column,
        len(state.religion_numbers),
    )


def table_state_sections_snapshot(
    state: TableStateSections,
) -> TableStateSectionsSnapshot:
    return TableStateSectionsSnapshot(
        "TableStateSections",
        state.highest_rows[1024],
        state.highest_rows[114],
        table_display_state_snapshot(state.display),
        generated_column_section_snapshot(state.generated_columns),
        len(state.row_display_to_original),
        "Set",
    )


def new_generated_rows(_state: TableStateSections) -> Set[Int]:
    return Set[Int]()


def bootstrap_table_state() -> TableStateBundle:
    return TableStateBundle("Dict", "Set")
