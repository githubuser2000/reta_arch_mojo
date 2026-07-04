"""Native typed core of ``reta_architecture.program_workflow``.

The historical Python bundle still owns the fully heterogeneous ``Program``
object.  This module takes ownership of the deterministic workflow contract and
its pure/file-boundary operations: CSV path normalization, output-kind
selection, religion-cell decoding, threaded religion-table loading, optional
language-specific motive-column replacement, runtime-flag reset, kombi-branch
planning and the ordered orchestration graph.
"""

from std.collections import List, Set
from std.collections.string import atol

from .csv_table import CsvTable, read_semicolon_csv, read_text_file
from .parallel_execution import (
    IndexedStringRow,
    ParallelExecutionConfig,
    ParallelOperationStats,
    decode_religion_cell,
    decode_religion_rows_threaded,
    parallel_config_from_environment,
)
from .resource_paths import asset_resource, csv_resource
from .parameter_runtime import ParameterRuntimePlan, build_parameter_runtime_plan
from .column_selection import ColumnSelectionBundle, bootstrap_column_selection
from .row_filtering import RowFilterConfig
from .table_preparation import DisplaySelection, select_display_lines
from .table_generation import (
    TableGenerationPlan,
    TableGenerationResult,
    bootstrap_table_generation,
)


@fieldwise_init
struct ProgramWorkflowCatalogEntry(Copyable):
    var kind: String
    var ordinal: Int
    var name: String
    var value: String
    var extra: String


@fieldwise_init
struct ProgramWorkflowCatalog(Copyable):
    var entries: List[ProgramWorkflowCatalogEntry]


@fieldwise_init
struct ProgramWorkflowCsvNames(Copyable):
    var religion: String
    var kombi13: String
    var kombi15: String
    var motives_kr: String
    var motives_cn: String
    var motives_vn: String


def default_program_workflow_csv_names() -> ProgramWorkflowCsvNames:
    return ProgramWorkflowCsvNames(
        "religion.csv",
        "kombi.csv",
        "kombi-meta.csv",
        "kr-thomas-decodedDekodiert-in-motives-purposesAbsichten.csv",
        "cn-thomas-decodedDekodiert-in-motives-purposesAbsichten.csv",
        "vn-thomas-decodedDekodiert-in-motives-purposesAbsichten.csv",
    )


@fieldwise_init
struct ProgramWorkflowFlags(Copyable):
    var html_or_bbcode: Bool
    var width_was_set: Bool
    var no_empty_contents: Bool
    var table_no_empty_contents: Bool
    var text_width: Int


@fieldwise_init
struct ProgramWorkflowReligionTable(Copyable):
    var table: CsvTable
    var rows_len: Int
    var output_kind: String
    var stats: ParallelOperationStats


@fieldwise_init
struct KombiWorkflowPlan(Copyable):
    var valid: Bool
    var csv_number: Int
    var row_source: String
    var reli_table_len_until_now: Int


@fieldwise_init
struct ProgramWorkflowI18n(Copyable):
    var art_parameter: String
    var bbcode_value: String
    var html_value: String
    var language: String


def default_program_workflow_i18n() -> ProgramWorkflowI18n:
    return ProgramWorkflowI18n("art", "bbcode", "html", "de")


@fieldwise_init
struct ProgramWorkflowParameterReadResult(Copyable):
    var runtime: ParameterRuntimePlan
    var param_lines: List[String]
    var param_lines_not: List[String]
    var explicit_order_requested: Bool
    var explicit_positions: List[Int]


@fieldwise_init
struct ProgramWorkflowBeginResult(Copyable):
    var religion: ProgramWorkflowReligionTable
    var flags: ProgramWorkflowFlags
    var parameters: ProgramWorkflowParameterReadResult
    var display_selection: DisplaySelection
    var column_selection: ColumnSelectionBundle
    var generation: TableGenerationResult


@fieldwise_init
struct ProgramWorkflowExecutionResult(Copyable):
    var begin: ProgramWorkflowBeginResult
    var first_kombi: KombiWorkflowPlan
    var second_kombi: KombiWorkflowPlan
    var final_table: CsvTable
    var final_display_lines: List[Int]
    var selected_columns: List[Int]
    var output_mode: String
    var render_owner: String
    var orchestration_steps: List[String]


@fieldwise_init
struct ProgramWorkflowSnapshot(Copyable):
    var class_name: String
    var repo_root: String
    var main_csv: String
    var kombi_csvs: List[String]
    var orchestration_steps: List[String]
    var fields: Int
    var methods: Int
    var self_calls: Int
    var bootstrap_functions: Int


@fieldwise_init
struct ProgramWorkflowBundle(Copyable):
    var repo_root: String
    var i18n: ProgramWorkflowI18n
    var csv_names: ProgramWorkflowCsvNames
    var gebrochen_spalten_maximum_plus1: Int
    var catalog: ProgramWorkflowCatalog

    def _csv_path(self, csv_file_name: String) -> String:
        return program_workflow_csv_path(csv_file_name)

    def _decode_religion_cell(
        self, cell: String, output_kind: String
    ) raises -> String:
        return decode_religion_cell(cell, output_kind)

    def _requested_religion_output_kind(
        self, argv: List[String]
    ) -> String:
        return requested_religion_output_kind(
            argv,
            self.i18n.art_parameter,
            self.i18n.bbcode_value,
            self.i18n.html_value,
        )

    def _load_religion_table(
        self,
        argv: List[String],
        highest_row: Int,
        config: ParallelExecutionConfig = parallel_config_from_environment(),
    ) raises -> ProgramWorkflowReligionTable:
        return load_program_workflow_religion_table(
            self.csv_names.religion,
            self._requested_religion_output_kind(argv),
            highest_row,
            config,
        )

    def _apply_language_specific_motive_column(
        self, table: CsvTable, language: String = ""
    ) raises -> CsvTable:
        var active_language = language if language.byte_length() > 0 else self.i18n.language
        return apply_language_specific_motive_column(
            table, self.csv_names, active_language
        )

    def _reset_runtime_flags(self, text_width: Int = 21) -> ProgramWorkflowFlags:
        return reset_program_workflow_flags(text_width)

    def _read_positive_and_negative_parameters(
        self,
        argv: List[String],
        maximum_columns: Int,
        maximum_rows: Int,
    ) raises -> ProgramWorkflowParameterReadResult:
        var runtime = build_parameter_runtime_plan(
            argv, maximum_columns, maximum_rows
        )
        return ProgramWorkflowParameterReadResult(
            runtime.copy(),
            runtime.positive_rows.copy(),
            runtime.negative_rows.copy(),
            runtime.explicit_order_requested,
            runtime.explicit_positions.copy(),
        )

    def bring_all_important_begin_things(
        self,
        argv: List[String],
        maximum_columns: Int,
        maximum_rows: Int,
        highest_row: Int,
        language: String = "",
        config: ParallelExecutionConfig = parallel_config_from_environment(),
    ) raises -> ProgramWorkflowBeginResult:
        var loaded = self._load_religion_table(argv, highest_row, config)
        var table = self._apply_language_specific_motive_column(
            loaded.table, language
        )
        loaded.table = table.copy()
        var parameters = self._read_positive_and_negative_parameters(
            argv,
            maximum_columns if maximum_columns > 0 else table.maximum_columns,
            maximum_rows,
        )
        var filter_config = RowFilterConfig(
            parameters.runtime.highest,
            min(parameters.runtime.highest, 163),
            len(parameters.param_lines) > 0 or len(parameters.param_lines_not) > 0,
        )
        var selection = select_display_lines(
            filter_config,
            table,
            parameters.param_lines,
            parameters.param_lines_not,
        )
        var generation_plan = table_generation_plan_from_runtime(
            parameters.runtime,
            _sorted_workflow_rows(selection.rows),
            language if language.byte_length() > 0 else self.i18n.language,
        )
        var generation = bootstrap_table_generation().build_for_program(
            table, generation_plan
        )
        return ProgramWorkflowBeginResult(
            loaded^,
            self._reset_runtime_flags(parameters.runtime.width),
            parameters^,
            selection^,
            bootstrap_column_selection(),
            generation^,
        )

    def combi_table_workflow(
        self,
        csv_file_name: String,
        new_table_columns: Int,
        rows_of_combi: Int,
        rows_of_combi2: Int,
    ) -> KombiWorkflowPlan:
        return plan_kombi_workflow(
            csv_file_name,
            self.csv_names,
            new_table_columns,
            rows_of_combi,
            rows_of_combi2,
        )

    def workflow_everything(
        self,
        argv: List[String],
        maximum_columns: Int,
        maximum_rows: Int,
        highest_row: Int,
        language: String = "",
        config: ParallelExecutionConfig = parallel_config_from_environment(),
    ) raises -> ProgramWorkflowExecutionResult:
        var begin = self.bring_all_important_begin_things(
            argv,
            maximum_columns,
            maximum_rows,
            highest_row,
            language,
            config,
        )
        var columns = begin.generation.table.maximum_columns
        var first = self.combi_table_workflow(
            self.csv_names.kombi13,
            columns,
            len(begin.generation.rows_of_combi),
            len(begin.generation.rows_of_combi2),
        )
        var second = self.combi_table_workflow(
            self.csv_names.kombi15,
            columns,
            len(begin.generation.rows_of_combi),
            len(begin.generation.rows_of_combi2),
        )
        return ProgramWorkflowExecutionResult(
            begin.copy(),
            first^,
            second^,
            begin.generation.table.copy(),
            _sorted_workflow_rows(begin.display_selection.rows),
            begin.generation.output_columns.copy(),
            begin.parameters.runtime.output_mode.copy(),
            "TableOutput",
            program_workflow_steps(self.catalog),
        )

    def snapshot(self) -> ProgramWorkflowSnapshot:
        return program_workflow_snapshot(self)


def load_program_workflow_catalog(
    path: String = "",
) raises -> ProgramWorkflowCatalog:
    var source_path = (
        path if path.byte_length() > 0 else asset_resource("program_workflow.tsv")
    )
    var entries = List[ProgramWorkflowCatalogEntry]()
    var lines = read_text_file(source_path).split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0 or line.startswith("#"):
            continue
        var fields = line.split("\t")
        if len(fields) != 5:
            raise Error("invalid program workflow row " + String(line_index + 1))
        entries.append(
            ProgramWorkflowCatalogEntry(
                String(fields[0]),
                atol(String(fields[1])),
                String(fields[2]),
                String(fields[3]),
                String(fields[4]),
            )
        )
    return ProgramWorkflowCatalog(entries^)


def program_workflow_entries_for_kind(
    catalog: ProgramWorkflowCatalog, kind: String
) -> List[ProgramWorkflowCatalogEntry]:
    var result = List[ProgramWorkflowCatalogEntry]()
    for index in range(len(catalog.entries)):
        var entry = catalog.entries[index].copy()
        if entry.kind == kind:
            result.append(entry^)
    return result^


def program_workflow_entry_exists(
    catalog: ProgramWorkflowCatalog, kind: String, name: String
) -> Bool:
    for index in range(len(catalog.entries)):
        if (
            catalog.entries[index].kind == kind
            and catalog.entries[index].name == name
        ):
            return True
    return False


def _program_workflow_count(catalog: ProgramWorkflowCatalog, kind: String) -> Int:
    var count = 0
    for index in range(len(catalog.entries)):
        if catalog.entries[index].kind == kind:
            count += 1
    return count


def _program_workflow_ordinals_valid(
    catalog: ProgramWorkflowCatalog, kind: String
) -> Bool:
    var next_ordinal = 0
    for index in range(len(catalog.entries)):
        var entry = catalog.entries[index].copy()
        if entry.kind != kind:
            continue
        if entry.ordinal != next_ordinal:
            return False
        next_ordinal += 1
    return True


def program_workflow_catalog_valid(catalog: ProgramWorkflowCatalog) -> Bool:
    if (
        _program_workflow_count(catalog, "field") != 4
        or _program_workflow_count(catalog, "method") != 11
        or _program_workflow_count(catalog, "self_call") != 10
        or _program_workflow_count(catalog, "step") != 12
        or _program_workflow_count(catalog, "bootstrap") != 1
    ):
        return False
    for kind in ["field", "method", "self_call", "step", "bootstrap"]:
        if not _program_workflow_ordinals_valid(catalog, kind):
            return False
    for index in range(len(catalog.entries)):
        var entry = catalog.entries[index].copy()
        if entry.kind == "self_call":
            if (
                not program_workflow_entry_exists(catalog, "method", entry.name)
                or not program_workflow_entry_exists(catalog, "method", entry.value)
            ):
                return False
        elif (
            entry.kind != "field"
            and entry.kind != "method"
            and entry.kind != "step"
            and entry.kind != "bootstrap"
        ):
            return False
    return True


def program_workflow_basename(path: String) -> String:
    var pieces = path.split("/")
    if len(pieces) == 0:
        return path.copy()
    return String(pieces[len(pieces) - 1])


def program_workflow_csv_path(csv_file_name: String) -> String:
    return csv_resource(program_workflow_basename(csv_file_name))


def requested_religion_output_kind(
    argv: List[String],
    art_parameter: String,
    bbcode_value: String,
    html_value: String,
) -> String:
    var prefix = "--" + art_parameter + "="
    var bbcode_argument = prefix + bbcode_value
    var html_argument = prefix + html_value
    # Python checks membership in priority order, not argv order.  Therefore
    # bbcode wins whenever both output flags are present.
    for index in range(len(argv)):
        if argv[index] == bbcode_argument:
            return "bbcode"
    for index in range(len(argv)):
        if argv[index] == html_argument:
            return "html"
    return "plain"


def reset_program_workflow_flags(text_width: Int = 21) -> ProgramWorkflowFlags:
    return ProgramWorkflowFlags(False, False, False, False, text_width)


def _indexed_rows(table: CsvTable) -> List[IndexedStringRow]:
    var result = List[IndexedStringRow]()
    for row_index in range(len(table.rows)):
        result.append(IndexedStringRow(row_index, table.rows[row_index].copy()))
    return result^


def _decoded_rows(result_rows: List[IndexedStringRow]) -> List[List[String]]:
    var result = List[List[String]]()
    for index in range(len(result_rows)):
        result.append(result_rows[index].cells.copy())
    return result^


def load_program_workflow_religion_table(
    csv_file_name: String,
    output_kind: String,
    highest_row: Int,
    config: ParallelExecutionConfig = parallel_config_from_environment(),
) raises -> ProgramWorkflowReligionTable:
    var raw_table = read_semicolon_csv(program_workflow_csv_path(csv_file_name))
    var decoded = decode_religion_rows_threaded(
        _indexed_rows(raw_table), output_kind, config
    )
    var rows = _decoded_rows(decoded.rows)
    var rows_len = len(rows[0]) if len(rows) > 0 else 0
    if rows_len > 0:
        var required_rows = max(0, highest_row + 1)
        while len(rows) < required_rows:
            var empty_row = List[String]()
            for _ in range(rows_len):
                empty_row.append(String())
            rows.append(empty_row^)
    return ProgramWorkflowReligionTable(
        CsvTable(rows^, raw_table.maximum_columns),
        rows_len,
        output_kind,
        decoded.stats.copy(),
    )


def motive_csv_for_language(
    csv_names: ProgramWorkflowCsvNames, language: String
) -> String:
    if language == "kr":
        return csv_names.motives_kr.copy()
    if language == "cn":
        return csv_names.motives_cn.copy()
    if language == "vn":
        return csv_names.motives_vn.copy()
    return String()


def apply_language_specific_motive_column(
    table: CsvTable,
    csv_names: ProgramWorkflowCsvNames,
    language: String,
) raises -> CsvTable:
    var filename = motive_csv_for_language(csv_names, language)
    if filename.byte_length() == 0 or filename == "de":
        return table.copy()
    var motives = read_semicolon_csv(program_workflow_csv_path(filename))
    var result = table.copy()
    var count = min(len(result.rows), len(motives.rows))
    for row_index in range(count):
        if len(result.rows[row_index]) <= 10 or len(motives.rows[row_index]) == 0:
            continue
        var row = result.rows[row_index].copy()
        row[10] = motives.rows[row_index][0].copy()
        result.rows[row_index] = row^
    return result^


def plan_kombi_workflow(
    csv_file_name: String,
    csv_names: ProgramWorkflowCsvNames,
    new_table_columns: Int,
    rows_of_combi: Int,
    rows_of_combi2: Int,
) -> KombiWorkflowPlan:
    if csv_file_name == csv_names.kombi13:
        return KombiWorkflowPlan(
            True,
            0,
            "rowsOfcombi",
            new_table_columns - rows_of_combi - rows_of_combi2,
        )
    if csv_file_name == csv_names.kombi15:
        return KombiWorkflowPlan(
            True,
            1,
            "rowsOfcombi2",
            new_table_columns - rows_of_combi2,
        )
    return KombiWorkflowPlan(False, -1, "", -1)


def program_workflow_steps(
    catalog: ProgramWorkflowCatalog,
) -> List[String]:
    var entries = program_workflow_entries_for_kind(catalog, "step")
    var result = List[String]()
    for index in range(len(entries)):
        result.append(entries[index].name.copy())
    return result^


def _sorted_workflow_rows(values: Set[Int]) -> List[Int]:
    var result = List[Int]()
    for value in values:
        result.append(value)
    for index in range(1, len(result)):
        var value = result[index]
        var position = index - 1
        while position >= 0 and result[position] > value:
            result[position + 1] = result[position]
            position -= 1
        result[position + 1] = value
    return result^


def table_generation_plan_from_runtime(
    runtime: ParameterRuntimePlan,
    displaying_rows: List[Int],
    language: String,
) -> TableGenerationPlan:
    return TableGenerationPlan(
        runtime.columns.copy(),
        runtime.modal_concepts.copy(),
        runtime.meta_requests.copy(),
        runtime.fraction_requests.copy(),
        runtime.generated_commands.copy(),
        runtime.kombi_requests.copy(),
        displaying_rows.copy(),
        runtime.positive_rows.copy(),
        language,
        runtime.output_mode.copy(),
        runtime.highest,
    )


def program_workflow_snapshot(
    bundle: ProgramWorkflowBundle,
) -> ProgramWorkflowSnapshot:
    return ProgramWorkflowSnapshot(
        "ProgramWorkflowBundle",
        bundle.repo_root.copy(),
        bundle.csv_names.religion.copy(),
        [bundle.csv_names.kombi13.copy(), bundle.csv_names.kombi15.copy()],
        program_workflow_steps(bundle.catalog),
        _program_workflow_count(bundle.catalog, "field"),
        _program_workflow_count(bundle.catalog, "method"),
        _program_workflow_count(bundle.catalog, "self_call"),
        _program_workflow_count(bundle.catalog, "bootstrap"),
    )


def bootstrap_program_workflow(
    repo_root: String,
    csv_names: ProgramWorkflowCsvNames,
    gebrochen_spalten_maximum_plus1: Int,
    catalog_path: String = "",
) raises -> ProgramWorkflowBundle:
    return ProgramWorkflowBundle(
        repo_root,
        default_program_workflow_i18n(),
        csv_names.copy(),
        gebrochen_spalten_maximum_plus1,
        load_program_workflow_catalog(catalog_path),
    )


def configure_program_workflow(
    repo_root: String,
    i18n: ProgramWorkflowI18n,
    csv_names: ProgramWorkflowCsvNames,
    gebrochen_spalten_maximum_plus1: Int,
    catalog_path: String = "",
) raises -> ProgramWorkflowBundle:
    return ProgramWorkflowBundle(
        repo_root,
        i18n.copy(),
        csv_names.copy(),
        gebrochen_spalten_maximum_plus1,
        load_program_workflow_catalog(catalog_path),
    )
