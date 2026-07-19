"""Native relational join for ``kombi.csv`` and ``kombi-meta.csv``.

The historical implementation exposes two unusual semantics that are preserved
here deliberately:

* relation rows are iterated in CPython ``set`` slot order, serialized in
  ``assets/kombi_relation_order.tsv``;
* with more than one selected column from the same Kombi table, empty relation
  cells remain visible as empty ``|`` segments.  With one selected column an
  empty relation row is skipped because the legacy row equals ``[[\"\"]]``.
"""

from std.algorithm import parallelize
from std.collections import List
from std.collections.string import atol
from .csv_table import (
    CsvTable,
    empty_csv_table,
    read_semicolon_csv,
    read_text_file,
)
from .parallel_execution import ParallelExecutionConfig
from .resource_paths import asset_resource, csv_resource
from .os_line_endings import split_os_lines


@fieldwise_init
struct KombiColumnRequest(Copyable):
    var kind: String
    var column: Int


@fieldwise_init
struct KombiAliasEntry(Copyable):
    var language: String
    var kind: String
    var domain_alias: String
    var parameter_alias: String
    var column: Int


@fieldwise_init
struct KombiAliasCatalog(Copyable):
    var entries: List[KombiAliasEntry]


@fieldwise_init
struct KombiJoinResult(Copyable):
    var table: CsvTable
    var output_columns: List[Int]
    var generated_names: List[String]


def load_kombi_alias_catalog(
    path: String = ""
) raises -> KombiAliasCatalog:
    var source_path = path if path.byte_length() > 0 else asset_resource("kombi_aliases.tsv")
    var text = read_text_file(source_path)
    var lines = split_os_lines(text)
    var entries = List[KombiAliasEntry]()
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0:
            continue
        var fields = line.split("\t")
        if len(fields) != 5:
            continue
        entries.append(
            KombiAliasEntry(
                String(fields[0]),
                String(fields[1]),
                String(fields[2]),
                String(fields[3]),
                atol(String(fields[4])),
            )
        )
    return KombiAliasCatalog(entries^)


def resolve_kombi_alias(
    catalog: KombiAliasCatalog,
    language: String,
    domain_alias: String,
    parameter_alias: String,
) -> KombiColumnRequest:
    for index in range(len(catalog.entries)):
        var entry = catalog.entries[index].copy()
        if (
            entry.language == language
            and entry.domain_alias == domain_alias
            and entry.parameter_alias == parameter_alias
        ):
            return KombiColumnRequest(entry.kind, entry.column)
    return KombiColumnRequest("", -1)


def contains_kombi_request(
    values: List[KombiColumnRequest], wanted: KombiColumnRequest
) -> Bool:
    for index in range(len(values)):
        if values[index].kind == wanted.kind and values[index].column == wanted.column:
            return True
    return False


def append_unique_kombi_request(
    mut values: List[KombiColumnRequest], value: KombiColumnRequest
):
    if (
        value.kind.byte_length() > 0
        and value.column > 0
        and not contains_kombi_request(values, value)
    ):
        values.append(value.copy())


def remove_kombi_requests(
    values: List[KombiColumnRequest], excluded: List[KombiColumnRequest]
) -> List[KombiColumnRequest]:
    var result = List[KombiColumnRequest]()
    for index in range(len(values)):
        if not contains_kombi_request(excluded, values[index]):
            result.append(values[index].copy())
    return result^


def _kind_rank(kind: String) -> Int:
    return 0 if kind == "galaxy" else 1 if kind == "universe" else 2


def sort_kombi_requests(mut values: List[KombiColumnRequest]):
    for index in range(1, len(values)):
        var key = values[index].copy()
        var position = index - 1
        while position >= 0 and (
            _kind_rank(values[position].kind) > _kind_rank(key.kind)
            or (
                _kind_rank(values[position].kind) == _kind_rank(key.kind)
                and values[position].column > key.column
            )
        ):
            values[position + 1] = values[position].copy()
            position -= 1
        values[position + 1] = key.copy()


def _requests_for_kind(
    requests: List[KombiColumnRequest], kind: String
) -> List[KombiColumnRequest]:
    var result = List[KombiColumnRequest]()
    for index in range(len(requests)):
        if requests[index].kind == kind:
            result.append(requests[index].copy())
    return result^


def _relation_rows(
    kind: String,
    number: Int,
    path: String = "",
) raises -> List[Int]:
    var wanted = kind + "\t" + String(number) + "\t"
    var source_path = path if path.byte_length() > 0 else asset_resource("kombi_relation_order.tsv")
    var text = read_text_file(source_path)
    var lines = split_os_lines(text)
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if not line.startswith(wanted):
            continue
        var fields = line.split("\t")
        if len(fields) != 3:
            return List[Int]()
        var values = String(fields[2]).split(",")
        var result = List[Int]()
        for value_index in range(len(values)):
            if String(values[value_index]).byte_length() > 0:
                result.append(atol(String(values[value_index])))
        return result^
    return List[Int]()


def _cell(table: CsvTable, row: Int, column: Int) -> String:
    if row < 0 or row >= len(table.rows):
        return ""
    if column < 0 or column >= len(table.rows[row]):
        return ""
    return table.rows[row][column]


def _is_signed_integer(text: String) -> Bool:
    var stripped = String(text.strip())
    if stripped.byte_length() == 0:
        return False
    var start = 0
    if stripped.startswith("+") or stripped.startswith("-"):
        if stripped.byte_length() == 1:
            return False
        start = 1
    var bytes = stripped.as_bytes()
    for index in range(start, len(bytes)):
        var code = Int(bytes[index])
        if code < 48 or code > 57:
            return False
    return True


def _strip_one_outer_pair(text: String) -> String:
    var stripped = String(text.strip())
    if (
        stripped.byte_length() > 1
        and stripped.startswith("(")
        and stripped.endswith(")")
    ):
        return String(StringSlice(stripped)[byte=1:-1])
    return stripped^


def _remove_current_number_from_expression(expression: String, number: Int) raises -> String:
    var tokens = expression.split("|")
    var kept = List[String]()
    for token_index in range(len(tokens)):
        var original = String(tokens[token_index])
        var value = _strip_one_outer_pair(original)
        var fraction_parts = value.split("/")
        var remove = False
        if len(fraction_parts) == 1 and _is_signed_integer(value):
            remove = abs(atol(value)) == abs(number)
        if not remove:
            # The legacy code strips one outer pair before rebuilding the left
            # expression, even when the token is retained.
            kept.append(value^)
    var result = String()
    for index in range(len(kept)):
        if index > 0:
            result += "|"
        result += kept[index]
    return result^


def _decorate_source_cell(
    source: CsvTable, source_row: Int, column: Int, main_number: Int
) raises -> String:
    var expression = String(_cell(source, source_row, 0).strip())
    var raw_source = _cell(source, source_row, column)
    var raw = String(raw_source.strip())
    var meaningful_trailing_space = raw_source.endswith(" ")
    if expression.byte_length() == 0 or raw.byte_length() == 0:
        return ""
    var separator = "  (" if meaningful_trailing_space else " ("
    var reduced = _remove_current_number_from_expression(expression, main_number)
    if reduced.byte_length() == 0:
        # ``removeOneNumber`` leaves the space after the removed ``)``.
        return " " + raw + separator + expression + ")"
    return "(" + reduced + ") " + raw + separator + expression + ")"


def _joined_cell_for_request(
    source: CsvTable,
    request: KombiColumnRequest,
    selected_in_kind: Int,
    main_number: Int,
    preserve_trailing_space: Bool,
    output_mode: String,
) raises -> String:
    var relation_rows = _relation_rows(request.kind, main_number)
    var pieces = List[String]()
    var started = False
    for relation_index in range(len(relation_rows)):
        var value = _decorate_source_cell(
            source, relation_rows[relation_index], request.column, main_number
        )
        # Exact legacy cell assignment: leading empty relation cells keep the
        # destination equal to [""] and are replaced by the first non-empty
        # value.  Once content exists, later empty values remain as separators.
        if not started:
            if value.byte_length() == 0:
                continue
            pieces.append(value^)
            started = True
        elif selected_in_kind == 1 and value.byte_length() == 0:
            continue
        else:
            pieces.append(value^)
    if output_mode == "html":
        var html_result = String("<ul>")
        for index in range(len(pieces)):
            if pieces[index].byte_length() > 0:
                html_result += "<li>" + pieces[index] + "</li>"
        html_result += "</ul>"
        return html_result^
    if output_mode == "bbcode":
        var bbcode_result = String("[list]")
        for index in range(len(pieces)):
            if pieces[index].byte_length() > 0:
                bbcode_result += "[*]" + pieces[index]
        bbcode_result += "[/list]"
        return bbcode_result^

    var result = String()
    for index in range(len(pieces)):
        if index > 0:
            result += " | "
        result += pieces[index]
    # Main-table normalization strips leading whitespace, while the legacy
    # post-prepare removal can introduce one meaningful leading space.
    if result.startswith(" "):
        result = "@@RETA_COMBI_LEADING_SPACE@@" + String(StringSlice(result)[byte=1:])
    if (
        preserve_trailing_space
        or result.find(";") >= 0
        or result.find("\"") >= 0
        or result.find("\n") >= 0
        or result.find("\r") >= 0
    ) and result.endswith(" "):
        result = String(StringSlice(result)[byte=:-1]) + "@@RETA_COMBI_TRAILING_SPACE@@"
    return result^


def _append_column(table: CsvTable, values: List[String]) -> CsvTable:
    var rows = List[List[String]]()
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        row.append(values[row_index] if row_index < len(values) else "")
        rows.append(row^)
    return CsvTable(rows^, table.maximum_columns + 1)


def _source_path(kind: String) -> String:
    return (
        csv_resource("kombi.csv")
        if kind == "galaxy"
        else csv_resource("kombi-meta.csv")
    )


def _load_kombi_source_by_kind_index(
    kind_index: Int
) raises -> CsvTable:
    var kind = "galaxy" if kind_index == 0 else "universe"
    return read_semicolon_csv(_source_path(kind))


def apply_kombi_join_columns(
    table: CsvTable,
    requests: List[KombiColumnRequest],
    last_row: Int,
    output_mode: String = "shell",
) raises -> KombiJoinResult:
    var ordered = requests.copy()
    sort_kombi_requests(ordered)
    var result = table.copy()
    var output_columns = List[Int]()
    var generated_names = List[String]()
    var emitted = 0
    for kind_index in range(2):
        var kind = "galaxy" if kind_index == 0 else "universe"
        var selected = _requests_for_kind(ordered, kind)
        if len(selected) == 0:
            continue
        var source = read_semicolon_csv(_source_path(kind))
        for request_index in range(len(selected)):
            var request = selected[request_index].copy()
            var values = List[String]()
            for row_index in range(len(table.rows)):
                if row_index == 0:
                    var heading_prefix = String(_cell(source, 0, 0).strip())
                    var heading_source = _cell(source, 0, request.column)
                    var heading = String(heading_source.strip())
                    if heading_prefix.byte_length() > 0 and heading.byte_length() > 0:
                        var heading_separator = (
                            "  (" if heading_source.endswith(" ") else " ("
                        )
                        heading = (
                            "("
                            + heading_prefix
                            + ") "
                            + heading
                            + heading_separator
                            + heading_prefix
                            + ")"
                        )
                    values.append(heading^)
                elif row_index <= last_row:
                    values.append(
                        _joined_cell_for_request(
                            source,
                            request,
                            len(selected),
                            row_index,
                            emitted + 1 < len(ordered),
                            output_mode,
                        )
                    )
                else:
                    values.append("")
            var new_index = result.maximum_columns
            result = _append_column(result, values)
            output_columns.append(new_index)
            generated_names.append(
                "KombiJoin:" + request.kind + "," + String(request.column)
            )
            emitted += 1
    return KombiJoinResult(result^, output_columns^, generated_names^)


def _kombi_values_for_request(
    table: CsvTable,
    source: CsvTable,
    request: KombiColumnRequest,
    selected_in_kind: Int,
    last_row: Int,
    emitted_index: Int,
    total_requests: Int,
    output_mode: String,
) raises -> List[String]:
    var values = List[String]()
    for row_index in range(len(table.rows)):
        if row_index == 0:
            var heading_prefix = String(_cell(source, 0, 0).strip())
            var heading_source = _cell(source, 0, request.column)
            var heading = String(heading_source.strip())
            if (
                heading_prefix.byte_length() > 0
                and heading.byte_length() > 0
            ):
                var heading_separator = (
                    "  (" if heading_source.endswith(" ") else " ("
                )
                heading = (
                    "("
                    + heading_prefix
                    + ") "
                    + heading
                    + heading_separator
                    + heading_prefix
                    + ")"
                )
            values.append(heading^)
        elif row_index <= last_row:
            values.append(
                _joined_cell_for_request(
                    source,
                    request,
                    selected_in_kind,
                    row_index,
                    emitted_index + 1 < total_requests,
                    output_mode,
                )
            )
        else:
            values.append("")
    return values^


def _kombi_values_for_request_parallel(
    table: CsvTable,
    source: CsvTable,
    request: KombiColumnRequest,
    selected_in_kind: Int,
    last_row: Int,
    emitted_index: Int,
    total_requests: Int,
    output_mode: String,
    config: ParallelExecutionConfig,
) raises -> List[String]:
    """Use private row chunks when only one Kombi request is active."""
    var stop = min(last_row, len(table.rows) - 1)
    var row_count = max(0, stop)
    if not config.should_use_threads(row_count):
        return _kombi_values_for_request(
            table,
            source,
            request,
            selected_in_kind,
            last_row,
            emitted_index,
            total_requests,
            output_mode,
        )
    var chunks = (row_count + config.chunk_size - 1) // config.chunk_size
    if chunks <= 1:
        return _kombi_values_for_request(
            table,
            source,
            request,
            selected_in_kind,
            last_row,
            emitted_index,
            total_requests,
            output_mode,
        )
    var chunk_results = List[List[String]]()
    var errors = List[String]()
    for _ in range(chunks):
        chunk_results.append(List[String]())
        errors.append(String())

    @parameter
    def worker(chunk_index: Int):
        var start_row = 1 + chunk_index * config.chunk_size
        var end_row = min(stop + 1, start_row + config.chunk_size)
        var values = List[String]()
        try:
            for row_index in range(start_row, end_row):
                values.append(
                    _joined_cell_for_request(
                        source,
                        request,
                        selected_in_kind,
                        row_index,
                        emitted_index + 1 < total_requests,
                        output_mode,
                    )
                )
            chunk_results[chunk_index] = values^
        except error:
            errors[chunk_index] = String(error)

    parallelize[worker](
        chunks, min(config.resolved_workers(), chunks)
    )
    for chunk_index in range(chunks):
        if errors[chunk_index].byte_length() > 0:
            raise Error("Kombi row chunk failed: " + errors[chunk_index])

    var values = List[String]()
    var heading_prefix = String(_cell(source, 0, 0).strip())
    var heading_source = _cell(source, 0, request.column)
    var heading = String(heading_source.strip())
    if heading_prefix.byte_length() > 0 and heading.byte_length() > 0:
        var heading_separator = (
            "  (" if heading_source.endswith(" ") else " ("
        )
        heading = (
            "("
            + heading_prefix
            + ") "
            + heading
            + heading_separator
            + heading_prefix
            + ")"
        )
    values.append(heading^)
    for chunk_index in range(chunks):
        for value in chunk_results[chunk_index]:
            values.append(value)
    for _ in range(stop + 1, len(table.rows)):
        values.append("")
    return values^


def apply_kombi_join_columns_parallel(
    table: CsvTable,
    requests: List[KombiColumnRequest],
    last_row: Int,
    config: ParallelExecutionConfig,
    output_mode: String = "shell",
) raises -> KombiJoinResult:
    """Load both Kombi sources and build request columns in private slots."""
    var ordered = requests.copy()
    sort_kombi_requests(ordered)
    var selected_counts = List[Int]()
    var sources = List[CsvTable]()
    for _ in range(2):
        selected_counts.append(0)
        sources.append(empty_csv_table())
    for request_index in range(len(ordered)):
        if ordered[request_index].kind == "galaxy":
            selected_counts[0] += 1
        elif ordered[request_index].kind == "universe":
            selected_counts[1] += 1

    var load_kinds = List[Int]()
    for kind_index in range(2):
        if selected_counts[kind_index] > 0:
            load_kinds.append(kind_index)
    var load_errors = List[String]()
    for _ in range(len(load_kinds)):
        load_errors.append(String())

    @parameter
    def load_worker(index: Int):
        var kind_index = load_kinds[index]
        try:
            sources[kind_index] = _load_kombi_source_by_kind_index(
                kind_index
            )
        except error:
            load_errors[index] = String(error)

    if (
        len(load_kinds) > 1
        and config.enabled_by_mode()
        and config.resolved_workers() > 1
    ):
        parallelize[load_worker](
            len(load_kinds),
            min(config.resolved_workers(), len(load_kinds)),
        )
    else:
        for index in range(len(load_kinds)):
            var kind_index = load_kinds[index]
            try:
                sources[kind_index] = _load_kombi_source_by_kind_index(
                    kind_index
                )
            except error:
                load_errors[index] = String(error)
    for index in range(len(load_errors)):
        if load_errors[index].byte_length() > 0:
            raise Error("Kombi source load failed: " + load_errors[index])

    var job_requests = List[KombiColumnRequest]()
    var job_kind_indexes = List[Int]()
    for kind_index in range(2):
        var kind = "galaxy" if kind_index == 0 else "universe"
        for request_index in range(len(ordered)):
            if ordered[request_index].kind == kind:
                job_requests.append(ordered[request_index].copy())
                job_kind_indexes.append(kind_index)

    var columns = List[List[String]]()
    var errors = List[String]()
    for _ in range(len(job_requests)):
        columns.append(List[String]())
        errors.append(String())

    @parameter
    def column_worker(index: Int):
        var kind_index = job_kind_indexes[index]
        try:
            columns[index] = _kombi_values_for_request(
                table,
                sources[kind_index],
                job_requests[index],
                selected_counts[kind_index],
                last_row,
                index,
                len(job_requests),
                output_mode,
            )
        except error:
            errors[index] = String(error)

    var work = len(job_requests) * max(
        1, min(last_row, len(table.rows) - 1) + 1
    )
    if len(job_requests) > 1 and config.should_use_threads(work):
        parallelize[column_worker](
            len(job_requests),
            min(config.resolved_workers(), len(job_requests)),
        )
    elif len(job_requests) == 1 and config.should_use_threads(work):
        var kind_index = job_kind_indexes[0]
        try:
            columns[0] = _kombi_values_for_request_parallel(
                table,
                sources[kind_index],
                job_requests[0],
                selected_counts[kind_index],
                last_row,
                0,
                1,
                output_mode,
                config,
            )
        except error:
            errors[0] = String(error)
    else:
        for index in range(len(job_requests)):
            var kind_index = job_kind_indexes[index]
            try:
                columns[index] = _kombi_values_for_request(
                    table,
                    sources[kind_index],
                    job_requests[index],
                    selected_counts[kind_index],
                    last_row,
                    index,
                    len(job_requests),
                    output_mode,
                )
            except error:
                errors[index] = String(error)
    for index in range(len(errors)):
        if errors[index].byte_length() > 0:
            raise Error("Kombi column failed: " + errors[index])

    var result = table.copy()
    var output_columns = List[Int]()
    var generated_names = List[String]()
    for index in range(len(job_requests)):
        var new_index = result.maximum_columns
        result = _append_column(result, columns[index])
        output_columns.append(new_index)
        generated_names.append(
            "KombiJoin:"
            + job_requests[index].kind
            + ","
            + String(job_requests[index].column)
        )
    return KombiJoinResult(result^, output_columns^, generated_names^)

