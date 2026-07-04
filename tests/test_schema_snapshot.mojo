from std.testing import assert_equal, assert_true, TestSuite

from reta_mojo.csv_table import read_text_file
from reta_mojo.resource_paths import asset_resource
from reta_mojo.schema_catalog import bootstrap_reta_schema
from reta_mojo.schema_snapshot import schema_snapshot_json


def test_native_schema_snapshot_matches_python_reference() raises:
    var snapshot = schema_snapshot_json(bootstrap_reta_schema())
    var reference = read_text_file(
        asset_resource("schema_snapshot_reference.json")
    )
    assert_equal(snapshot, reference)
    assert_true(snapshot.startswith('{"languages":'))
    assert_true(snapshot.find('"para_n_data_matrix_size":431') >= 0)
    assert_true(snapshot.find('"kombi_para_n_data_matrix_size":12') >= 0)
    assert_true(snapshot.find('"kombi_para_n_data_matrix2_size":14') >= 0)
    assert_true(snapshot.find('"compat:legacy_monolith":"i18n.words_legacy_monolith"') >= 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
