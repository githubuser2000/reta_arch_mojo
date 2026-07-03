"""Typed compatibility owner for ``libs/lib4tables_prepare.py``.

The historical Python module mixes four module globals, five module functions,
a mutable ``Prepare`` facade, row filtering, wrapping and output-row
preparation.  The algorithms already have native owners.  This module closes
the legacy boundary by replacing the module globals with explicit state and by
preserving the complete public method surface as typed forwarding methods.
"""

from std.collections import List, Set
from .csv_table import CsvTable
from .table_adapters import (
    PrepareAdapterState,
    FilterOriginalLines as adapter_FilterOriginalLines,
    alxwrap as adapter_alxwrap,
    cellWork as adapter_cellWork,
    chunks as adapter_chunks,
    create_prepare_adapter_state,
    deleteDoublesInSets as adapter_deleteDoublesInSets,
    fromUntil as adapter_fromUntil,
    moonsun as adapter_moonsun,
    parametersCmdWithSomeBereich as adapter_parametersCmdWithSomeBereich,
    prepare4out as adapter_prepare4out,
    prepare4out_LoopBody as adapter_prepare4out_LoopBody,
    prepare4out_Tagging as adapter_prepare4out_Tagging,
    prepare4out_beforeForLoop_SpaltenZeilenBestimmen as adapter_select_display_lines,
    setShellRowsAmount as adapter_setShellRowsAmount,
    setWidth as adapter_setWidth,
    setZaehlungen as adapter_setZaehlungen,
    splitMoreIfNotSmall as adapter_splitMoreIfNotSmall,
    wrapping as adapter_wrapping,
    zeileWhichZaehlung as adapter_zeileWhichZaehlung,
)
from .table_preparation import (
    DisplaySelection,
    ParallelRowPreparationContext,
    PreparedIndexedRow,
    PreparedRowsSerialResult,
)
from .table_wrapping import (
    TextWrapRuntime,
    WRAP_PYHYPHEN,
    refresh_textwrap_runtime,
)
from .tag_schema import TagSchemaBundle


@fieldwise_init
struct LegacyPrepareMethod(Copyable):
    var legacy_name: String
    var native_owner: String
    var native_entry: String


@fieldwise_init
struct LegacyPrepareModuleRuntime(Copyable):
    """Explicit replacement for shellRowsAmount/h_de/dic/fill/wrappingType."""

    var wrapping_runtime: TextWrapRuntime


@fieldwise_init
struct LegacyPrepareSnapshot(Copyable):
    var module_functions: List[LegacyPrepareMethod]
    var prepare_methods: List[LegacyPrepareMethod]
    var state_sections: List[String]
    var shell_rows_amount: Int
    var has_hyphenator: Bool
    var has_dictionary: Bool
    var has_fill: Bool
    var wrapping_type: Int


def _method(name: String, owner: String, entry: String) -> LegacyPrepareMethod:
    return LegacyPrepareMethod(name, owner, entry)


def create_legacy_prepare_module_runtime(
    shell_rows_amount: Int = 0,
    wrapping_type: Int = WRAP_PYHYPHEN,
) -> LegacyPrepareModuleRuntime:
    var runtime = refresh_textwrap_runtime(wrapping_type)
    runtime.shell_rows_amount = shell_rows_amount
    return LegacyPrepareModuleRuntime(runtime^)


def _sync_wrapping_runtime(
    runtime: LegacyPrepareModuleRuntime,
) -> LegacyPrepareModuleRuntime:
    var refreshed = refresh_textwrap_runtime(runtime.wrapping_runtime.wrapping_type)
    refreshed.shell_rows_amount = runtime.wrapping_runtime.shell_rows_amount
    return LegacyPrepareModuleRuntime(refreshed^)


def setShellRowsAmount(
    mut runtime: LegacyPrepareModuleRuntime,
    shell_rows_amount: Int,
) -> None:
    runtime.wrapping_runtime.shell_rows_amount = shell_rows_amount


def chunks(values: List[String], size: Int) -> List[List[String]]:
    return adapter_chunks(values, size)


def splitMoreIfNotSmall(
    values: List[String], target_length: Int
) -> List[String]:
    return adapter_splitMoreIfNotSmall(values, target_length)


def alxwrap(
    runtime: LegacyPrepareModuleRuntime,
    text: String,
    length: Int,
) -> List[String]:
    return adapter_alxwrap(text, length, runtime.wrapping_runtime)


@fieldwise_init
struct Prepare(Copyable):
    """Complete typed facade for the historical mutable Prepare instance."""

    var state: PrepareAdapterState

    def setZaehlungen(mut self, num: Int = 0) -> None:
        adapter_setZaehlungen(self.state, num)

    def breitenn(self) -> Bool:
        return self.state.widths_enabled

    def set_breitenn(mut self, value: Bool) -> None:
        self.state.widths_enabled = value

    def nummeriere(self) -> Bool:
        return self.state.numbering

    def set_nummeriere(mut self, value: Bool) -> None:
        self.state.numbering = value

    def textWidth(self) -> Int:
        return self.state.text_width

    def set_textWidth(mut self, value: Int) -> None:
        self.state.text_width = value

    def wrapping(self, text: String, length: Int) -> List[String]:
        return adapter_wrapping(self.state, text, length)

    def setWidth(self, row_to_display: Int, combi_rows: Int = 0) -> Int:
        return adapter_setWidth(self.state, row_to_display, combi_rows)

    def parametersCmdWithSomeBereich(
        self,
        ranges: String,
        symbol: String,
        negative_prefix: String,
        ignore_negative: Bool = False,
    ) raises -> Set[String]:
        return adapter_parametersCmdWithSomeBereich(
            ranges, symbol, negative_prefix, ignore_negative
        )

    def deleteDoublesInSets(
        self, first: Set[Int], second: Set[Int]
    ) -> Tuple[Set[Int], Set[Int]]:
        return adapter_deleteDoublesInSets(first, second)

    def fromUntil(self, values: List[Int]) -> Tuple[Int, Int]:
        return adapter_fromUntil(values)

    def zeileWhichZaehlung(mut self, row: Int) -> Int:
        return adapter_zeileWhichZaehlung(self.state, row)

    def moonsun(self, moon_not_sun: Bool, values: Set[Int]) -> Set[Int]:
        return adapter_moonsun(values, moon_not_sun)

    def FilterOriginalLines(
        self, initial: Set[Int], conditions: List[String]
    ) raises -> Set[Int]:
        return adapter_FilterOriginalLines(self.state, initial, conditions)

    def prepare4out(
        self,
        row_indexes: List[Int],
        rows: List[List[String]],
        context: ParallelRowPreparationContext,
    ) -> PreparedRowsSerialResult:
        return adapter_prepare4out(row_indexes, rows, context)

    def prepare4out_beforeForLoop_SpaltenZeilenBestimmen(
        self,
        table: CsvTable,
        positive_conditions: List[String],
        negative_conditions: List[String],
    ) raises -> DisplaySelection:
        return adapter_select_display_lines(
            self.state, table, positive_conditions, negative_conditions
        )

    def prepare4out_LoopBody(
        self,
        row_index: Int,
        line: List[String],
        context: ParallelRowPreparationContext,
    ) -> PreparedIndexedRow:
        return adapter_prepare4out_LoopBody(row_index, line, context)

    def prepare4out_Tagging(
        self,
        schema: TagSchemaBundle,
        source_column: Int,
        kombi_csv_number: Int = -1,
    ) -> List[Int]:
        return adapter_prepare4out_Tagging(
            schema, source_column, kombi_csv_number
        )

    def cellWork(self, cell: String, width: Int) -> List[String]:
        return adapter_cellWork(self.state, cell, width)


def create_legacy_prepare(
    highest_main: Int = 1024,
    highest_multiple: Int = 163,
    shell_rows_amount: Int = 0,
) -> Prepare:
    return Prepare(
        create_prepare_adapter_state(
            highest_main, highest_multiple, shell_rows_amount
        )
    )


def legacy_prepare_snapshot(
    runtime: LegacyPrepareModuleRuntime,
) -> LegacyPrepareSnapshot:
    return LegacyPrepareSnapshot(
        [
            _method("_sync_wrapping_runtime", "table_wrapping.mojo", "refresh_textwrap_runtime"),
            _method("setShellRowsAmount", "legacy_lib4tables_prepare.mojo", "explicit module runtime"),
            _method("chunks", "table_adapters.mojo", "chunks"),
            _method("splitMoreIfNotSmall", "table_wrapping.mojo", "split_more_if_not_small"),
            _method("alxwrap", "table_wrapping.mojo", "alxwrap"),
        ],
        [
            _method("setZaehlungen", "row_filtering.mojo", "counting_groups"),
            _method("breitenn", "table_adapters.mojo", "widths_enabled getter"),
            _method("breitenn", "table_adapters.mojo", "widths_enabled setter"),
            _method("nummeriere", "table_adapters.mojo", "numbering getter"),
            _method("nummeriere", "table_adapters.mojo", "numbering setter"),
            _method("textWidth", "table_adapters.mojo", "text_width getter"),
            _method("textWidth", "table_adapters.mojo", "text_width setter"),
            _method("wrapping", "table_wrapping.mojo", "wrap_cell_text"),
            _method("setWidth", "table_wrapping.mojo", "width_for_row"),
            _method("parametersCmdWithSomeBereich", "table_adapters.mojo", "parametersCmdWithSomeBereich"),
            _method("deleteDoublesInSets", "table_adapters.mojo", "deleteDoublesInSets"),
            _method("fromUntil", "table_adapters.mojo", "fromUntil"),
            _method("zeileWhichZaehlung", "table_adapters.mojo", "zeileWhichZaehlung"),
            _method("moonsun", "number_theory.mojo", "moon_number"),
            _method("FilterOriginalLines", "row_filtering.mojo", "filter_original_lines"),
            _method("prepare4out", "table_preparation.mojo", "prepare_rows_serial"),
            _method("prepare4out_beforeForLoop_SpaltenZeilenBestimmen", "table_preparation.mojo", "select_display_lines"),
            _method("prepare4out_LoopBody", "table_preparation.mojo", "prepare_indexed_row"),
            _method("prepare4out_Tagging", "tag_schema.mojo", "tags_for_column"),
            _method("cellWork", "table_preparation.mojo", "prepare_cell_fragments"),
        ],
        [
            "tables",
            "hoechsteZeile",
            "originalLinesRange",
            "shellRowsAmount",
            "zaehlungen",
            "religionNumbers",
            "gezaehlt",
            "ifZeilenSetted",
            "breiten",
            "nummerierung",
            "textwidth",
        ],
        runtime.wrapping_runtime.shell_rows_amount,
        runtime.wrapping_runtime.has_hyphenator,
        runtime.wrapping_runtime.has_dictionary,
        runtime.wrapping_runtime.has_fill,
        runtime.wrapping_runtime.wrapping_type,
    )
