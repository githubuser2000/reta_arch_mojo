"""Complete typed owner for ``reta_architecture.table_generation``.

The Python implementation mutates a heterogeneous ``Program`` object while it
loads concat CSV presheaves, applies generated-column morphisms and finally
joins the two Kombi tables.  The native owner makes that orchestration order
explicit in ``TableGenerationPlan`` and returns an owned result instead of
mutating arbitrary attributes.
"""

from std.collections import List
from .csv_table import CsvTable, empty_csv_table
from .generated_aliases import (
    FractionColumnRequest,
    MetaColumnRequest,
    ModalConcept,
)
from .generated_table_columns import (
    GeneratedTableResult,
    apply_native_generated_columns,
)
from .kombi_join import (
    KombiJoinBundle,
    KombiLineSelection,
    KombiSourceBundle,
    bootstrap_combi_join,
    load_kombi_join_source,
    select_kombi_lines,
)
from .kombi_join_columns import (
    KombiColumnRequest,
    apply_kombi_join_columns,
)
from .concat_csv import ConcatCsvBundle, bootstrap_concat_csv


@fieldwise_init
struct TableGenerationPlan(Copyable):
    var selected_columns: List[Int]
    var modal_concepts: List[ModalConcept]
    var meta_requests: List[MetaColumnRequest]
    var fraction_requests: List[FractionColumnRequest]
    var generated_commands: List[String]
    var kombi_requests: List[KombiColumnRequest]
    var displaying_rows: List[Int]
    var param_lines: List[String]
    var language: String
    var output_mode: String
    var requested_last_line: Int


@fieldwise_init
struct TableGenerationResultSnapshot(Copyable):
    var class_name: String
    var has_prim_spalten: Bool
    var gebr_keys: List[String]
    var kombi_rows_len: Int
    var animals_professions_table_len: Int
    var animals_professions_table2_len: Int


@fieldwise_init
struct TableGenerationBundleSnapshot(Copyable):
    var class_name: String
    var csv_sources: List[String]
    var generated_columns_registry: List[String]
    var concat_csv_spec_count: Int
    var concat_csv_sources: List[String]
    var concat_fraction_helpers: List[String]
    var combi_join_implementation: String
    var combi_join_morphisms: List[String]
    var combi_join_role: String
    var generated_morphisms: List[String]
    var table_preparation_dependency: String
    var kombi_csvs: List[String]


@fieldwise_init
struct TableGenerationConcatResult(Copyable):
    var table: CsvTable
    var output_columns: List[Int]
    var generated_names: List[String]
    var prim_spalten: List[Int]
    var gebr_keys: List[String]


@fieldwise_init
struct TableGenerationKombiResult(Copyable):
    var table: CsvTable
    var output_columns: List[Int]
    var generated_names: List[String]
    var galaxy_source: KombiSourceBundle
    var universe_source: KombiSourceBundle
    var galaxy_selections: List[KombiLineSelection]
    var universe_selections: List[KombiLineSelection]
    var galaxy_requests: List[KombiColumnRequest]
    var universe_requests: List[KombiColumnRequest]
    var galaxy_output_columns: List[Int]
    var universe_output_columns: List[Int]


@fieldwise_init
struct TableGenerationResult(Copyable):
    var table: CsvTable
    var output_columns: List[Int]
    var generated_names: List[String]
    var last_line_number: Int
    var prim_spalten: List[Int]
    var gebr_keys: List[String]
    var rows_of_combi: List[KombiLineSelection]
    var kombi_table_kombis: List[KombiColumnRequest]
    var maintable2subtable_relation: List[Int]
    var rows_of_combi2: List[KombiLineSelection]
    var kombi_table_kombis2: List[KombiColumnRequest]
    var maintable2subtable_relation2: List[Int]
    var animals_professions_table: CsvTable
    var animals_professions_table2: CsvTable

    def snapshot(self) -> TableGenerationResultSnapshot:
        return TableGenerationResultSnapshot(
            "TableGenerationResult",
            len(self.prim_spalten) > 0,
            self.gebr_keys.copy(),
            len(self.rows_of_combi),
            len(self.animals_professions_table.rows),
            len(self.animals_professions_table2.rows),
        )


@fieldwise_init
struct TableGenerationBundle(Copyable):
    var concat_csv: ConcatCsvBundle
    var combi_join: KombiJoinBundle
    var csv_sources: List[String]
    var generated_morphisms: List[String]
    var table_preparation_dependency: String
    var kombi_csvs: List[String]

    def _concat_csv_inputs(
        self, table: CsvTable, plan: TableGenerationPlan, last_line: Int
    ) raises -> TableGenerationConcatResult:
        var concat_commands = List[String]()
        if _contains_string(plan.generated_commands, "PrimCSV"):
            concat_commands.append("PrimCSV")
        var result = apply_native_generated_columns(
            table,
            List[Int](),
            List[ModalConcept](),
            List[MetaColumnRequest](),
            plan.fraction_requests,
            concat_commands,
            plan.language,
            plan.output_mode,
            last_line,
        )
        var prim_spalten = List[Int]()
        for index in range(len(result.generated_names)):
            if result.generated_names[index] == "PrimCSV":
                prim_spalten.append(result.output_columns[index])
        return TableGenerationConcatResult(
            result.table.copy(),
            result.output_columns.copy(),
            result.generated_names.copy(),
            prim_spalten^,
            _fraction_result_keys(plan.fraction_requests),
        )

    def _set_last_line_number(
        self, table: CsvTable, requested_last_line: Int
    ) -> Int:
        return capture_last_line_number(table, requested_last_line)

    def _apply_generated_column_morphisms(
        self, table: CsvTable, plan: TableGenerationPlan, last_line: Int
    ) raises -> GeneratedTableResult:
        return apply_native_generated_columns(
            table,
            plan.selected_columns,
            plan.modal_concepts,
            plan.meta_requests,
            List[FractionColumnRequest](),
            _without_prim_csv(plan.generated_commands),
            plan.language,
            plan.output_mode,
            last_line,
        )

    def _read_kombi_tables(
        self, table: CsvTable, plan: TableGenerationPlan, last_line: Int
    ) raises -> TableGenerationKombiResult:
        var galaxy_source = _empty_kombi_source("galaxy")
        var universe_source = _empty_kombi_source("universe")
        var galaxy_selections = List[KombiLineSelection]()
        var universe_selections = List[KombiLineSelection]()
        if _contains_kombi_kind(plan.kombi_requests, "galaxy"):
            galaxy_source = load_kombi_join_source("galaxy")
            galaxy_selections = select_kombi_lines(
                plan.param_lines,
                plan.displaying_rows,
                galaxy_source.combinations,
            )
        if _contains_kombi_kind(plan.kombi_requests, "universe"):
            universe_source = load_kombi_join_source("universe")
            universe_selections = select_kombi_lines(
                plan.param_lines,
                plan.displaying_rows,
                universe_source.combinations,
            )
        var joined = apply_kombi_join_columns(
            table,
            plan.kombi_requests,
            last_line,
            plan.output_mode,
        )
        var galaxy_requests = _kombi_requests_for_kind(
            plan.kombi_requests, "galaxy"
        )
        var universe_requests = _kombi_requests_for_kind(
            plan.kombi_requests, "universe"
        )
        var galaxy_output_columns = List[Int]()
        var universe_output_columns = List[Int]()
        for index in range(len(joined.generated_names)):
            if joined.generated_names[index].startswith("KombiJoin:galaxy,"):
                galaxy_output_columns.append(joined.output_columns[index])
            elif joined.generated_names[index].startswith("KombiJoin:universe,"):
                universe_output_columns.append(joined.output_columns[index])
        return TableGenerationKombiResult(
            joined.table.copy(),
            joined.output_columns.copy(),
            joined.generated_names.copy(),
            galaxy_source.copy(),
            universe_source.copy(),
            galaxy_selections^,
            universe_selections^,
            galaxy_requests^,
            universe_requests^,
            galaxy_output_columns^,
            universe_output_columns^,
        )

    def build_for_program(
        self, table: CsvTable, plan: TableGenerationPlan
    ) raises -> TableGenerationResult:
        # Python glues the concat CSV presheaves before table preparation
        # captures the requested last line.  Concat inputs therefore cover the
        # physical source table, while later generated morphisms honour the
        # requested/clamped line boundary.
        var concat_last_line = capture_last_line_number(table, -1)
        var concat_result = self._concat_csv_inputs(
            table, plan, concat_last_line
        )
        var last_line = self._set_last_line_number(
            concat_result.table, plan.requested_last_line
        )
        var generated_result = self._apply_generated_column_morphisms(
            concat_result.table, plan, last_line
        )
        var kombi_result = self._read_kombi_tables(
            generated_result.table, plan, last_line
        )
        var output_columns = List[Int]()
        _append_unique_ints(output_columns, plan.selected_columns)
        _append_unique_ints(output_columns, concat_result.output_columns)
        _append_unique_ints(output_columns, generated_result.output_columns)
        _append_unique_ints(output_columns, kombi_result.output_columns)
        var generated_names = concat_result.generated_names.copy()
        _append_strings(generated_names, generated_result.generated_names)
        _append_strings(generated_names, kombi_result.generated_names)
        return TableGenerationResult(
            kombi_result.table.copy(),
            output_columns^,
            generated_names^,
            last_line,
            concat_result.prim_spalten.copy(),
            concat_result.gebr_keys.copy(),
            kombi_result.galaxy_selections.copy(),
            kombi_result.galaxy_requests.copy(),
            kombi_result.galaxy_output_columns.copy(),
            kombi_result.universe_selections.copy(),
            kombi_result.universe_requests.copy(),
            kombi_result.universe_output_columns.copy(),
            kombi_result.galaxy_source.decorated_table.copy(),
            kombi_result.universe_source.decorated_table.copy(),
        )

    def snapshot(self) -> TableGenerationBundleSnapshot:
        return TableGenerationBundleSnapshot(
            "TableGenerationBundle",
            self.csv_sources.copy(),
            self.generated_morphisms.copy(),
            len(self.concat_csv.specs),
            self.concat_csv.csv_sources.copy(),
            self.concat_csv.fraction_helpers.copy(),
            self.combi_join.implementation.copy(),
            self.combi_join.morphisms.copy(),
            self.combi_join.role.copy(),
            self.generated_morphisms.copy(),
            self.table_preparation_dependency.copy(),
            self.kombi_csvs.copy(),
        )


def _contains_string(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _contains_int(values: List[Int], wanted: Int) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _append_unique_ints(mut target: List[Int], source: List[Int]) -> None:
    for index in range(len(source)):
        if not _contains_int(target, source[index]):
            target.append(source[index])


def _append_strings(mut target: List[String], source: List[String]) -> None:
    for index in range(len(source)):
        target.append(source[index])


def _without_prim_csv(commands: List[String]) -> List[String]:
    var result = List[String]()
    for index in range(len(commands)):
        if commands[index] != "PrimCSV":
            result.append(commands[index])
    return result^



def _kombi_requests_for_kind(
    requests: List[KombiColumnRequest], kind: String
) -> List[KombiColumnRequest]:
    var result = List[KombiColumnRequest]()
    for index in range(len(requests)):
        if requests[index].kind == kind:
            result.append(requests[index].copy())
    return result^

def _contains_kombi_kind(
    requests: List[KombiColumnRequest], kind: String
) -> Bool:
    for index in range(len(requests)):
        if requests[index].kind == kind:
            return True
    return False


def _append_unique_string(mut values: List[String], value: String) -> None:
    if not _contains_string(values, value):
        values.append(value)


def _fraction_result_keys(
    requests: List[FractionColumnRequest]
) -> List[String]:
    var result = List[String]()
    for index in range(len(requests)):
        var domain = requests[index].domain
        if domain == "galaxy":
            _append_unique_string(result, "Gal")
            _append_unique_string(result, "Gal2")
        elif domain == "universe":
            _append_unique_string(result, "Uni")
            _append_unique_string(result, "Uni2")
        elif domain == "emotion":
            _append_unique_string(result, "Emo")
            _append_unique_string(result, "Emo2")
        elif domain == "size":
            _append_unique_string(result, "Groe")
            _append_unique_string(result, "Groe2")
    return result^


def _empty_kombi_source(kind: String) -> KombiSourceBundle:
    return KombiSourceBundle(
        kind,
        "",
        empty_csv_table(),
        List[List[Int]](),
    )


def capture_last_line_number(
    table: CsvTable, requested_last_line: Int
) -> Int:
    var physical_last = len(table.rows) - 1
    if physical_last < 0:
        return 0
    if requested_last_line < 0:
        return physical_last
    return min(requested_last_line, physical_last)


def default_table_generation_plan() -> TableGenerationPlan:
    return TableGenerationPlan(
        List[Int](),
        List[ModalConcept](),
        List[MetaColumnRequest](),
        List[FractionColumnRequest](),
        List[String](),
        List[KombiColumnRequest](),
        List[Int](),
        List[String](),
        "german",
        "shell",
        -1,
    )


def bootstrap_table_generation() -> TableGenerationBundle:
    return TableGenerationBundle(
        bootstrap_concat_csv(),
        bootstrap_combi_join(),
        ["prim", "gebrGal", "gebroUni", "gebrEmo", "gebrGroe"],
        [
            "concatVervielfacheZeile",
            "concatModallogik",
            "concatPrimCreativityType",
            "concatGleichheitFreiheitDominieren",
            "concatGeistEmotionEnergieMaterieTopologie",
            "concatMondExponzierenLogarithmusTyp",
            "concat1RowPrimUniverse2",
            "concat1PrimzahlkreuzProContra",
            "concatLovePolygon",
            "spalteFuerGegenInnenAussenSeitlichPrim",
            "spalteMetaKontretTheorieAbstrakt_etc_1",
            "createSpalteGestirn",
        ],
        "capture_last_line_number",
        ["kombi.csv", "kombi-meta.csv"],
    )
