"""Typed native owner for ``reta_architecture.sheaves``.

The native sheaf layer glues the generated schema, explicit table state,
rendered output sections and the HTML reference catalog.  Dynamic Python
mappings are represented as owned typed collections or canonical JSON payloads.
"""

from std.collections import Dict, List
from std.collections.string import atol
from .csv_table import read_text_file
from .parameter_semantics import (
    ParameterSemanticsSheaf,
    ParameterSemanticsSnapshot,
    build_parameter_semantics,
    parameter_semantics_snapshot,
)
from .resource_paths import asset_resource
from .schema import RetaContextSchema
from .table_state import GeneratedColumnSection, TableStateSections
from .os_line_endings import split_os_lines


@fieldwise_init
struct GeneratedColumnsSheafSnapshot(Copyable):
    var generated_spalten_parameter_count: Int
    var generated_spalten_parameter_tags_count: Int


struct GeneratedColumnsSheaf(Copyable):
    var generated_spalten_parameter: Dict[Int, String]
    var generated_spalten_parameter_tags: Dict[Int, String]

    def __init__(out self):
        self.generated_spalten_parameter = Dict[Int, String]()
        self.generated_spalten_parameter_tags = Dict[Int, String]()

    def sync_from_tables(
        mut self, tables: TableStateSections
    ) -> None:
        self.sync_from_generated_section(tables.generated_columns)

    def sync_from_generated_section(
        mut self, section: GeneratedColumnSection
    ) -> None:
        self.generated_spalten_parameter = _copy_int_string_dict_sheaf(
            section.parameters
        )
        self.generated_spalten_parameter_tags = _copy_int_string_dict_sheaf(
            section.tags
        )

    def snapshot(self) -> GeneratedColumnsSheafSnapshot:
        return GeneratedColumnsSheafSnapshot(
            len(self.generated_spalten_parameter),
            len(self.generated_spalten_parameter_tags),
        )


@fieldwise_init
struct SheafOutputSection(Copyable):
    var output_mode: String
    var resulting_table: List[List[String]]
    var finally_display_lines: List[Int]
    var has_finally_display_lines: Bool
    var rows_range: List[Int]
    var has_rows_range: Bool


@fieldwise_init
struct TableOutputSheafSnapshot(Copyable):
    var section_modes: List[String]
    var section_count: Int


struct TableOutputSheaf(Copyable):
    var sections: List[SheafOutputSection]

    def __init__(out self):
        self.sections = List[SheafOutputSection]()

    def sync_from_tables(
        mut self,
        resulting_table: List[List[String]],
        output_mode: String,
        finally_display_lines: List[Int] = List[Int](),
        has_finally_display_lines: Bool = False,
        rows_range: List[Int] = List[Int](),
        has_rows_range: Bool = False,
    ) -> None:
        var section = SheafOutputSection(
            output_mode.copy(),
            _copy_string_table_sheaf(resulting_table),
            finally_display_lines.copy(),
            has_finally_display_lines,
            rows_range.copy(),
            has_rows_range,
        )
        var index = _table_output_section_index(self, output_mode)
        if index < 0:
            self.sections.append(section^)
        else:
            self.sections[index] = section^

    def section(self, output_mode: String) -> SheafOutputSection:
        var index = _table_output_section_index(self, output_mode)
        if index < 0:
            return SheafOutputSection(
                output_mode.copy(),
                List[List[String]](),
                List[Int](),
                False,
                List[Int](),
                False,
            )
        return self.sections[index].copy()

    def snapshot(self) -> TableOutputSheafSnapshot:
        var modes = List[String]()
        for index in range(len(self.sections)):
            modes.append(self.sections[index].output_mode.copy())
        return TableOutputSheafSnapshot(modes^, len(self.sections))


@fieldwise_init
struct HtmlReferenceEntry(Copyable):
    var column_number: Int
    var payload_json: String


@fieldwise_init
struct HtmlReferenceSheafSnapshot(Copyable):
    var reference_size: Int
    var first_column: Int
    var last_column: Int


struct HtmlReferenceSheaf(Copyable):
    var reference_map: List[HtmlReferenceEntry]

    def __init__(out self):
        self.reference_map = List[HtmlReferenceEntry]()

    @staticmethod
    def from_jsonl(path: String = "") raises -> Self:
        return load_html_reference_sheaf(path)

    def html_meta_for_column(self, column_number: Int) -> String:
        for index in range(len(self.reference_map)):
            if self.reference_map[index].column_number == column_number:
                return self.reference_map[index].payload_json.copy()
        return "{}"

    def snapshot(self) -> HtmlReferenceSheafSnapshot:
        if len(self.reference_map) == 0:
            return HtmlReferenceSheafSnapshot(0, -1, -1)
        return HtmlReferenceSheafSnapshot(
            len(self.reference_map),
            self.reference_map[0].column_number,
            self.reference_map[len(self.reference_map) - 1].column_number,
        )


@fieldwise_init
struct SheafBundleSnapshot(Copyable):
    var parameter_semantics: ParameterSemanticsSnapshot
    var generated_columns: GeneratedColumnsSheafSnapshot
    var table_output: TableOutputSheafSnapshot
    var html_reference_size: Int


@fieldwise_init
struct SheafBundle(Copyable):
    var parameter_semantics: ParameterSemanticsSheaf
    var generated_columns: GeneratedColumnsSheaf
    var table_output: TableOutputSheaf
    var html_reference: HtmlReferenceSheaf

    @staticmethod
    def from_repo(
        repo_root: String,
        schema: RetaContextSchema,
        html_reference_path: String = "",
    ) raises -> Self:
        # repo_root is intentionally accepted to preserve the Python public
        # surface. Portable native assets are resolved by resource_paths.
        _ = repo_root
        return Self(
            build_parameter_semantics(schema),
            GeneratedColumnsSheaf(),
            TableOutputSheaf(),
            load_html_reference_sheaf(html_reference_path),
        )

    def snapshot(self) -> SheafBundleSnapshot:
        return SheafBundleSnapshot(
            parameter_semantics_snapshot(self.parameter_semantics),
            self.generated_columns.snapshot(),
            self.table_output.snapshot(),
            len(self.html_reference.reference_map),
        )


def _copy_int_string_dict_sheaf(
    source: Dict[Int, String]
) -> Dict[Int, String]:
    var result = Dict[Int, String]()
    for item in source.items():
        result[item.key] = item.value
    return result^


def _copy_string_table_sheaf(
    source: List[List[String]]
) -> List[List[String]]:
    var result = List[List[String]]()
    for row_index in range(len(source)):
        var row = List[String]()
        for column_index in range(len(source[row_index])):
            row.append(source[row_index][column_index])
        result.append(row^)
    return result^


def _table_output_section_index(
    sheaf: TableOutputSheaf, output_mode: String
) -> Int:
    for index in range(len(sheaf.sections)):
        if sheaf.sections[index].output_mode == output_mode:
            return index
    return -1


def load_html_reference_sheaf(
    path: String = "",
) raises -> HtmlReferenceSheaf:
    var source_path = (
        path
        if path.byte_length() > 0
        else asset_resource("html_reference_sheaf.tsv")
    )
    var result = HtmlReferenceSheaf()
    var lines = split_os_lines(read_text_file(source_path))
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0 or line.startswith("#"):
            continue
        var fields = line.split("\t")
        if len(fields) != 2:
            # Invalid JSONL rows are ignored by Python. The generated native
            # catalog is stricter because corruption is a build artifact error.
            raise Error(
                "invalid HTML reference sheaf row " + String(line_index + 1)
            )
        result.reference_map.append(
            HtmlReferenceEntry(
                atol(String(fields[0])),
                String(fields[1]),
            )
        )
    return result^


def html_reference_size(sheaf: HtmlReferenceSheaf) -> Int:
    return len(sheaf.reference_map)


def bootstrap_sheaves(
    schema: RetaContextSchema,
    repo_root: String = "",
    html_reference_path: String = "",
) raises -> SheafBundle:
    return SheafBundle.from_repo(
        repo_root, schema, html_reference_path
    )
