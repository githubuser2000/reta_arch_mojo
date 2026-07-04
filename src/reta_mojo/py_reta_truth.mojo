"""Native semantic witnesses for the historical Py-Reta truth tests.

The Python reference used two small regression modules to pin the final
religion-table columns, the corresponding parameter-matrix entries and the tag
schema.  This owner expresses the same truths through the native schema, CSV
and tag APIs instead of inspecting Python source text.
"""

from std.collections import List
from .csv_table import read_semicolon_csv
from .parameter_semantics import build_parameter_semantics, column_numbers_for_pair
from .resource_paths import csv_resource
from .schema_catalog import bootstrap_reta_schema
from .tag_schema import tags_for_column
from .tag_schema_catalog import bootstrap_tag_schema


@fieldwise_init
struct PyRetaTruthMatrixSnapshot(Copyable, Equatable):
    var grundstrukturen_structure_size: List[Int]
    var size_order_structure_size: List[Int]
    var size_order_organisations: List[Int]


@fieldwise_init
struct PyRetaTruthHeaderSnapshot(Copyable, Equatable):
    var columns: Int
    var column_744: String
    var column_745: String


@fieldwise_init
struct PyRetaTruthTagSnapshot(Copyable, Equatable):
    var column_744_tags: List[Int]
    var column_745_tags: List[Int]


def py_reta_truth_matrix_snapshot() -> PyRetaTruthMatrixSnapshot:
    var semantics = build_parameter_semantics(bootstrap_reta_schema())
    return PyRetaTruthMatrixSnapshot(
        column_numbers_for_pair(
            semantics, "Grundstrukturen", "Strukturgrösse"
        ),
        column_numbers_for_pair(
            semantics, "Größenordnung", "Strukturgrösse"
        ),
        column_numbers_for_pair(
            semantics, "Größenordnung", "Organisationen"
        ),
    )


def py_reta_truth_header_snapshot(
    filename: String = "religion.csv",
) raises -> PyRetaTruthHeaderSnapshot:
    var table = read_semicolon_csv(csv_resource(filename))
    if len(table.rows) == 0:
        return PyRetaTruthHeaderSnapshot(0, "", "")
    var header = table.rows[0].copy()
    var column_744 = header[744].copy() if len(header) > 744 else ""
    var column_745 = header[745].copy() if len(header) > 745 else ""
    return PyRetaTruthHeaderSnapshot(
        len(header), column_744^, column_745^
    )


def py_reta_truth_tag_snapshot() -> PyRetaTruthTagSnapshot:
    var schema = bootstrap_tag_schema()
    return PyRetaTruthTagSnapshot(
        tags_for_column(schema, 744),
        tags_for_column(schema, 745),
    )
