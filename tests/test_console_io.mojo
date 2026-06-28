from std.collections import List
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.console_io import *


def test_chunking_preserves_order() raises:
    var values: List[String] = ["a", "b", "c", "d", "e"]
    var chunks = chunks_strings(values, 2)
    assert_equal(len(chunks), 3)
    assert_equal(chunks[0][0], "a")
    assert_equal(chunks[1][1], "d")
    assert_equal(chunks[2][0], "e")


def test_ordered_unique_strings() raises:
    var values: List[String] = ["a", "b", "a", "c", "b"]
    var unique = unique_everseen_strings(values)
    assert_equal(len(unique), 3)
    assert_equal(unique[0], "a")
    assert_equal(unique[1], "b")
    assert_equal(unique[2], "c")


def test_console_text_and_flags() raises:
    assert_equal(normalize_colored_cli_text("  eins\n zwei\t drei "), "eins zwei drei")
    assert_equal(debug_pair_text("Wert", "42"), "Wert: 42")
    var context = default_console_context()
    assert_true(should_emit(context))
    assert_false(should_emit_debug(context))
    context.info_log = True
    assert_true(should_emit_debug(context))
    context.output_enabled = False
    assert_false(should_emit(context))
    assert_false(should_emit_debug(context))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
