from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.html_class_extractor import *


def test_extracts_duplicate_classes_data_and_unicode_text() raises:
    var html = (
        '<table><tr class="head">'
        + '<td class="z_0 r_7 alpha" data-x="1" class="alpha beta">'
        + '<b>Größe</b>  中文 \n Việt'
        + '</td><td title="plain">Second</td></tr></table>'
    )
    var cells = extract_header_cells(html)
    assert_equal(len(cells), 2)
    assert_equal(cells[0].column_number, 7)
    assert_true(cells[0].row_number_present)
    assert_equal(cells[0].row_number, 0)
    assert_equal(cells[0].class_attributes[0], "z_0 r_7 alpha")
    assert_equal(cells[0].class_attributes[1], "alpha beta")
    assert_equal(cells[0].all_classes[3], "beta")
    assert_equal(cells[0].text, "Größe 中文 Việt")
    assert_equal(cells[1].column_number, 1)
    assert_equal(cells[1].text, "Second")


def test_compact_json_matches_python_field_order() raises:
    var cells = extract_header_cells(
        '<tr><td class="z_2 r_3 a" data-x="v">A &amp; B</td></tr>'
    )
    var line = html_class_cell_json(cells[0])
    assert_true(line.startswith('{"column_number":3,"row_number":2,"tag":"td"'))
    assert_true('"data_attributes":{"data-x":"v"}' in line)
    assert_true('"attributes":[["class","z_2 r_3 a"],["data-x","v"]]' in line)
    assert_true(line.endswith('"html":"<td class=\\"z_2 r_3 a\\" data-x=\\"v\\">A &amp; B</td>"}]}'))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
