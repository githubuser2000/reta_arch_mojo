"""Native inspection surface for the complete Kombi join owner."""

from std.sys import argv
from reta_mojo.combi_join import (
    bootstrap_combi_join,
    load_kombi_join_source,
)
from reta_mojo.csv_table import table_fingerprint


def _usage() -> None:
    print("reta-mojo-combi-join [--summary|--source galaxy|universe]")


def main() raises:
    var args = argv()
    if len(args) == 1 or String(args[1]) == "--summary":
        var bundle = bootstrap_combi_join()
        print("implementation=" + bundle.implementation)
        print("morphisms=" + String(len(bundle.morphisms)))
        print("csv_sources=" + String(len(bundle.csv_sources)))
        print("ordered_dict_runtime=0")
        print("selection_order=canonical")
        print("output_relation_order=preserved")
        return
    if String(args[1]) == "--source" and len(args) == 3:
        var kind = String(args[2])
        var source = load_kombi_join_source(kind)
        print("kind=" + kind)
        print("rows=" + String(len(source.decorated_table.rows)))
        print("columns=" + String(source.decorated_table.maximum_columns))
        print("combinations=" + String(len(source.combinations)))
        print("fingerprint=" + String(table_fingerprint(source.decorated_table)))
        return
    _usage()
    raise Error("invalid Kombi join arguments")
