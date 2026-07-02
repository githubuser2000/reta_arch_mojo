from std.collections import List
from reta_mojo.combi_join import *
from reta_mojo.csv_table import CsvTable, table_fingerprint


comptime MOD = 1000000007


def _join_ints(values: List[Int]) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += ","
        result += String(values[index])
    return result^


def _combinations_fingerprint(rows: List[List[Int]]) -> Int:
    var value = 19
    for row_index in range(len(rows)):
        var row = rows[row_index].copy()
        for column_index in range(len(row)):
            value = (value * 263 + abs(row[column_index]) + 1) % MOD
        value = (value * 263 + 263) % MOD
    return value


def _main_table(row_count: Int) -> CsvTable:
    var rows = List[List[String]]()
    rows.append(["h0", "h1"])
    for index in range(1, row_count):
        rows.append([String(index), ""])
    return CsvTable(rows^, 2)


def _selection_rows(values: List[KombiLineSelection]) -> List[List[String]]:
    var rows = List[List[String]]()
    for index in range(len(values)):
        var row = List[String]()
        row.append(String(values[index].main_number))
        for source_index in range(len(values[index].source_rows)):
            row.append(String(values[index].source_rows[source_index]))
        rows.append(row^)
    return rows^


def _relation_rows(values: List[KombiRelationEntry]) -> List[List[String]]:
    var rows = List[List[String]]()
    for index in range(len(values)):
        rows.append(
            [
                String(values[index].appended_column),
                String(values[index].source_column),
            ]
        )
    return rows^


def _prepared_rows(values: List[KombiPreparedGroup]) -> List[List[String]]:
    var rows = List[List[String]]()
    for index in range(len(values)):
        var row = List[String]()
        row.append(String(values[index].main_number))
        row.append(String(len(values[index].source_rows)))
        var fingerprints = List[Int]()
        for source_index in range(len(values[index].source_rows)):
            fingerprints.append(
                table_fingerprint(
                    CsvTable([values[index].source_rows[source_index].copy()], 0)
                )
            )
        # The Python owner may iterate an OrderedSet or the set fallback.  Row
        # order is not semantic, so parity compares the row-fingerprint multiset.
        for sort_index in range(1, len(fingerprints)):
            var value = fingerprints[sort_index]
            var position = sort_index - 1
            while position >= 0 and fingerprints[position] > value:
                fingerprints[position + 1] = fingerprints[position]
                position -= 1
            fingerprints[position + 1] = value
        for fingerprint_index in range(len(fingerprints)):
            row.append(String(fingerprints[fingerprint_index]))
        rows.append(row^)
    return rows^


def _source_records(kind: String) raises:
    var source = load_kombi_join_source(kind)
    print(
        "SOURCE|",
        kind,
        "|",
        len(source.decorated_table.rows),
        "|",
        source.decorated_table.maximum_columns,
        "|",
        len(source.combinations),
        "|",
        table_fingerprint(source.decorated_table),
        "|",
        _combinations_fingerprint(source.combinations),
        sep="",
    )
    var appended = append_kombi_placeholders(
        _main_table(len(source.decorated_table.rows)), source, [1]
    )
    print(
        "APPEND|",
        kind,
        "|",
        len(appended.table.rows),
        "|",
        appended.table.maximum_columns,
        "|",
        table_fingerprint(appended.table),
        "|",
        len(appended.relations),
        "|",
        table_fingerprint(CsvTable(_relation_rows(appended.relations), 2)),
        "|",
        _join_ints(appended.selected_columns),
        sep="",
    )
    var selections = select_kombi_lines(
        ["ka"], [1, 2, 3, 5, 7, 9, 13], source.combinations
    )
    print(
        "SELECT|",
        kind,
        "|",
        len(selections),
        "|",
        table_fingerprint(CsvTable(_selection_rows(selections), 0)),
        sep="",
    )
    var prepared = prepare_kombi_join_tables(selections, source)
    print(
        "PREPARED|",
        kind,
        "|",
        len(prepared),
        "|",
        table_fingerprint(CsvTable(_prepared_rows(prepared), 3)),
        sep="",
    )


def main() raises:
    for token in ["-13", "(+7)", "12/5", "(1/2)"]:
        print(
            "TOKEN|",
            token,
            "|",
            _join_ints(parse_kombi_number_token(token)),
            sep="",
        )
    _source_records("galaxy")
    _source_records("universe")
    print(
        "REMOVE|",
        remove_kombi_number_from_cell(
            "(1|2|3/4) Inhalt (1|2|3/4)", 2
        ),
        sep="",
    )
    print(
        "REMOVE|",
        remove_kombi_number_from_cell("(2) Inhalt (2)", 2),
        sep="",
    )
    var bundle = bootstrap_combi_join()
    var morphisms = String()
    for index in range(len(bundle.morphisms)):
        if index > 0:
            morphisms += ","
        morphisms += bundle.morphisms[index]
    print(
        "BUNDLE|",
        bundle.implementation,
        "|",
        morphisms,
        "|kombi.csv,kombi-meta.csv",
        sep="",
    )
