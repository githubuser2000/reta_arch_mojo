"""Complete typed owner for ``reta_architecture.table_runtime``.

Python's ``Tables`` object is the mutable gluing section between state,
preparation, combination joins, generated columns and output.  The native
owner keeps that mutability explicit in one value.  Component boundaries are
owned values rather than lazy Python class imports, while every observable
property synchronizes the relevant state sections.
"""

from std.collections import List, Set

from .combi_join import KombiJoinBundle, bootstrap_combi_join
from .csv_table import CsvTable
from .generated_columns import celestial_value
from .legacy_lib4tables_prepare import Prepare, create_legacy_prepare
from .legacy_lib4tables_concat import LegacyConcatState, create_legacy_concat_state
from .output_modes import OutputModeSpec, output_mode_spec
from .table_output import TableOutput, bootstrap_table_output
from .table_state import (
    TableStateBundle,
    TableStateBundleSnapshot,
    TableStateSections,
    TableStateSectionsSnapshot,
    bootstrap_table_state,
    table_state_sections_snapshot,
)
from .table_wrapping import clamp_column_width, clamp_table_width
from .tag_schema import TAG_GALAXIE, TAG_STERN_POLYGON, TAG_UNIVERSUM


@fieldwise_init
struct BreakoutException(Copyable, Writable):
    """Typed marker for the historical control-flow exception boundary."""

    var message: String

    def write_to[W: Writer](self, mut writer: W):
        writer.write(self.message)


@fieldwise_init
struct RuntimeComponentClass(Copyable):
    var class_name: String
    var native_owner: String


def _get_text_wrap_things(shell_rows_amount: Int = 0) -> Tuple[Int, Bool, Bool, Bool]:
    return (shell_rows_amount, False, False, False)


def _prepare_class() -> RuntimeComponentClass:
    return RuntimeComponentClass("Prepare", "legacy_lib4tables_prepare.mojo")


def _concat_class() -> RuntimeComponentClass:
    return RuntimeComponentClass("Concat", "legacy_lib4tables_concat.mojo")


@fieldwise_init
struct GestirnColumnResult(Copyable):
    var table: CsvTable
    var rows_as_numbers: Set[Int]
    var generated_source_column: Int
    var appended_table_column: Int
    var generated_output_column: Int
    var generated_parameter: String
    var tags: List[Int]
    var applied: Bool


@fieldwise_init
struct Maintable(Copyable):
    var generated_columns_owner: String

    def createSpalteGestirn(
        self,
        table: CsvTable,
        rows_as_numbers: Set[Int],
        language: String = "german",
    ) -> GestirnColumnResult:
        return create_spalte_gestirn(table, rows_as_numbers, language)


@fieldwise_init
struct TablesRuntimeSnapshot(Copyable):
    var class_name: String
    var output_mode: String
    var no_headings: Bool
    var no_empty_contents: Bool
    var star_column: Bool
    var highest_main: Int
    var highest_multiple: Int
    var generated_parameters_len: Int
    var generated_tags_len: Int
    var generated_rows_len: Int
    var religion_numbers_len: Int
    var vanilla_column_count: Int
    var width_count: Int
    var numbering: Bool
    var text_height: Int
    var text_width: Int
    var rows_were_set: Bool
    var prime_multiples: Bool


@fieldwise_init
struct Tables(Copyable):
    """Owned native replacement for the mutable Python ``Tables`` section."""

    var state: TableStateSections
    var getPrepare: Prepare
    var getConcat: LegacyConcatState
    var getCombis: KombiJoinBundle
    var getOut: TableOutput
    var getMainTable: Maintable
    var text_state: List[String]
    var rows_of_combi: Set[Int]
    var fractional_universe: Set[Int]
    var prime_multiples: Bool
    var vanilla_column_count: Int

    def keineUeberschriften(self) -> Bool:
        return self.state.display.no_headings

    def set_keineUeberschriften(mut self, value: Bool):
        self.state.display.no_headings = value
        self.getOut.config.no_headings = value

    def keineleereninhalte(self) -> Bool:
        return self.state.display.no_empty_contents

    def set_keineleereninhalte(mut self, value: Bool):
        self.state.display.no_empty_contents = value
        self.getOut.config.no_blank_contents = value

    def spaltegGestirn(self) -> Bool:
        return self.state.display.star_column

    def set_spaltegGestirn(mut self, value: Bool):
        self.state.display.star_column = value

    def tableStateSnapshot(self) -> TableStateSectionsSnapshot:
        return table_state_sections_snapshot(self.state.copy())

    def outputModeName(self) -> String:
        return self.getOut.config.output_mode.copy()

    def NichtsOutputYes(self) -> Bool:
        return self.outputModeName() == "nichts"

    def markdownOutputYes(self) -> Bool:
        return self.outputModeName() == "markdown"

    def bbcodeOutputYes(self) -> Bool:
        return self.outputModeName() == "bbcode"

    def htmlOutputYes(self) -> Bool:
        return self.outputModeName() == "html"

    def outType(self) -> OutputModeSpec:
        return output_mode_spec(self.outputModeName())

    def set_outType(mut self, value: String) raises:
        self.getOut.set_out_type(value)

    def hoechsteZeile(self, key: Int = 1024) -> Int:
        # Dict indexing raises when a key is absent.  The runtime state factory
        # always installs both historical keys, but this public non-raising
        # accessor must remain valid even for a manually reconstructed state.
        if key == 114:
            return self.state.highest_rows.get(114, 163)
        return self.state.highest_rows.get(1024, 1024)

    def set_hoechsteZeile(mut self, value: Int):
        self.state.highest_rows[1024] = value
        self.state.highest_rows[114] = value
        self.getPrepare.state.row_filter.highest_main = value
        self.getPrepare.state.row_filter.highest_multiple = value

    def generRows(self) -> Set[Int]:
        var result = Set[Int]()
        for value in self.state.generated_rows:
            result.add(value)
        return result^

    def set_generRows(mut self, values: Set[Int]):
        var result = Set[Int]()
        for value in values:
            result.add(value)
        self.state.generated_rows = result^

    def ifPrimMultis(self) -> Bool:
        return self.prime_multiples

    def set_ifPrimMultis(mut self, value: Bool):
        self.prime_multiples = value

    def SpaltenVanillaAmount(self) -> Int:
        return self.vanilla_column_count

    def set_SpaltenVanillaAmount(mut self, value: Int):
        self.vanilla_column_count = max(0, value)

    def ifZeilenSetted(self) -> Bool:
        return self.getPrepare.state.rows_were_set

    def set_ifZeilenSetted(mut self, value: Bool):
        self.getPrepare.state.rows_were_set = value

    def gebrUnivSet(self) -> Set[Int]:
        var result = Set[Int]()
        for value in self.fractional_universe:
            result.add(value)
        return result^

    def breitenn(self) -> List[Int]:
        return self.getOut.config.widths.copy()

    def set_breitenn(mut self, values: List[Int]):
        var clamped = List[Int]()
        for index in range(len(values)):
            clamped.append(
                clamp_column_width(
                    values[index], self.getPrepare.state.shell_rows_amount
                )
            )
        self.getPrepare.state.widths = clamped.copy()
        self.getPrepare.state.widths_enabled = len(clamped) > 0
        self.getOut.config.widths = clamped^

    def nummeriere(self) -> Bool:
        return self.getOut.config.number_rows

    def set_nummeriere(mut self, value: Bool):
        self.getOut.config.number_rows = value
        self.getPrepare.state.numbering = value

    def textHeight(self) -> Int:
        return self.getOut.config.text_height

    def set_textHeight(mut self, value: Int):
        self.getOut.config.text_height = value

    def textWidth(self) -> Int:
        return self.getOut.config.text_width

    def set_textWidth(mut self, value: Int):
        var allows_zero = (
            self.bbcodeOutputYes()
            or self.htmlOutputYes()
            or self.getOut.config.one_table
        )
        var clamped = clamp_table_width(
            value,
            self.getPrepare.state.shell_rows_amount,
            allows_zero,
        )
        self.getPrepare.state.text_width = clamped
        self.getOut.config.text_width = clamped

    def createSpalteGestirn(
        mut self,
        table: CsvTable,
        rows_as_numbers: Set[Int],
        language: String = "german",
    ) -> GestirnColumnResult:
        var result = self.getMainTable.createSpalteGestirn(
            table, rows_as_numbers, language
        )
        if result.applied:
            var metadata_index = (
                len(self.state.generated_columns.parameters)
                + self.vanilla_column_count
            )
            self.state.generated_columns.parameters[metadata_index] = (
                result.generated_parameter
            )
            self.state.generated_columns.tags[result.generated_output_column] = (
                "sternPolygon|universum|galaxie"
            )
            self.state.display.star_column = True
        return result^

    @staticmethod
    def fillBoth(
        first: List[String], second: List[String]
    ) -> Tuple[List[String], List[String]]:
        return fillBoth(first, second)

    def tableReducedInLinesByTypeSet(
        self, table: CsvTable, lines_allowed: Set[Int]
    ) -> CsvTable:
        return table_reduced_in_lines_by_type_set(table, lines_allowed)

    def snapshot(self) -> TablesRuntimeSnapshot:
        return TablesRuntimeSnapshot(
            "Tables",
            self.outputModeName(),
            self.keineUeberschriften(),
            self.keineleereninhalte(),
            self.spaltegGestirn(),
            self.hoechsteZeile(1024),
            self.hoechsteZeile(114),
            len(self.state.generated_columns.parameters),
            len(self.state.generated_columns.tags),
            len(self.state.generated_rows),
            len(self.state.display.religion_numbers),
            self.vanilla_column_count,
            len(self.getOut.config.widths),
            self.nummeriere(),
            self.textHeight(),
            self.textWidth(),
            self.ifZeilenSetted(),
            self.ifPrimMultis(),
        )


@fieldwise_init
struct TableRuntimeBundleSnapshot(Copyable):
    var class_name: String
    var table_class: String
    var owns_legacy_tables: Bool
    var legacy_facade: String
    var state_sections: TableStateBundleSnapshot
    var component_morphisms: List[String]


@fieldwise_init
struct TableRuntimeBundle(Copyable):
    var table_class_name: String
    var output_mode: String
    var table_state: TableStateBundle

    def create_tables(
        self,
        highest_row: Int = -1,
        text_state: List[String] = List[String](),
        shell_rows_amount: Int = 0,
    ) raises -> Tables:
        return create_tables(
            highest_row,
            text_state,
            shell_rows_amount,
            self.output_mode,
            self.table_state.copy(),
        )

    def snapshot(self) -> TableRuntimeBundleSnapshot:
        return TableRuntimeBundleSnapshot(
            "TableRuntimeBundle",
            self.table_class_name,
            True,
            "libs/tableHandling.py",
            self.table_state.snapshot(),
            [
                "Prepare",
                "Concat",
                "KombiJoin",
                "TableOutput",
                "GeneratedColumns",
            ],
        )


def fillBoth(
    first: List[String], second: List[String]
) -> Tuple[List[String], List[String]]:
    var left = first.copy()
    var right = second.copy()
    while len(left) < len(right):
        left.append("")
    while len(right) < len(left):
        right.append("")
    return (left^, right^)


def table_reduced_in_lines_by_type_set(
    table: CsvTable, lines_allowed: Set[Int]
) -> CsvTable:
    var rows = List[List[String]]()
    for index in range(len(table.rows)):
        if index in lines_allowed:
            rows.append(table.rows[index].copy())
    return CsvTable(rows^, table.maximum_columns)


def create_spalte_gestirn(
    table: CsvTable,
    rows_as_numbers: Set[Int],
    language: String = "german",
) -> GestirnColumnResult:
    var copied_rows = Set[Int]()
    for value in rows_as_numbers:
        copied_rows.add(value)
    if 64 not in copied_rows or len(table.rows) == 0:
        return GestirnColumnResult(
            table.copy(),
            copied_rows^,
            64,
            -1,
            -1,
            "",
            List[Int](),
            False,
        )

    var appended_table_column = table.maximum_columns
    var generated_output_column = len(copied_rows)
    var rows = List[List[String]]()
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        row.append(celestial_value(row_index, language))
        rows.append(row^)
    copied_rows.add(appended_table_column)
    return GestirnColumnResult(
        CsvTable(rows^, appended_table_column + 1),
        copied_rows^,
        64,
        appended_table_column,
        generated_output_column,
        celestial_value(0, language),
        [TAG_STERN_POLYGON, TAG_UNIVERSUM, TAG_GALAXIE],
        True,
    )


def create_tables(
    highest_row: Int = -1,
    text_state: List[String] = List[String](),
    shell_rows_amount: Int = 0,
    output_mode: String = "shell",
    table_state: TableStateBundle = bootstrap_table_state(),
) raises -> Tables:
    var state = table_state.create_sections(highest_row)
    var highest_main = state.highest_rows[1024]
    var highest_multiple = state.highest_rows[114]
    var prepare = create_legacy_prepare(
        highest_main, highest_multiple, shell_rows_amount
    )
    prepare.state.numbering = True
    var output = bootstrap_table_output().create_default()
    output.text_state = text_state.copy()
    output.set_out_type(output_mode)
    output.set_nummeriere(True)
    output.set_text_height(0)
    output.set_text_width(21)
    return Tables(
        state^,
        prepare^,
        create_legacy_concat_state(),
        bootstrap_combi_join(),
        output^,
        Maintable("GeneratedColumns"),
        text_state.copy(),
        Set[Int](),
        Set[Int](),
        False,
        0,
    )


def bootstrap_table_runtime(
    output_mode: String = "shell",
    table_state: TableStateBundle = bootstrap_table_state(),
) -> TableRuntimeBundle:
    return TableRuntimeBundle("Tables", output_mode, table_state.copy())
