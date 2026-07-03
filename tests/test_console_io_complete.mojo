from std.collections import List
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.console_io import *


def test_complete_console_bundle_snapshot() raises:
    var bundle = bootstrap_console_io_morphisms("/tmp/reta")
    var snapshot = bundle.snapshot()
    assert_equal(snapshot.class_name, "ConsoleIOMorphismBundle")
    assert_equal(snapshot.stage, 39)
    assert_equal(snapshot.legacy_owner, "libs.center")
    assert_equal(snapshot.repo_root, "/tmp/reta")
    assert_equal(len(snapshot.morphisms), 11)
    assert_equal(len(snapshot.compatibility_names), 9)
    assert_equal(snapshot.morphisms[0], "reta_prompt_help_text")
    assert_equal(snapshot.morphisms[10], "DefaultOrderedDict")


def test_chunks_and_keyed_uniqueness() raises:
    var values: List[String] = ["A", "b", "a", "B", "c"]
    var chunks = chunks_strings(values, 2)
    assert_equal(len(chunks), 3)
    assert_equal(chunks[0], ["A", "b"])
    assert_equal(chunks[2], ["c"])
    var exact = unique_everseen_strings(values)
    assert_equal(exact, ["A", "b", "a", "B", "c"])
    var lowered = unique_everseen_ascii_lower(values)
    assert_equal(lowered, ["A", "b", "c"])


def test_console_effect_planning() raises:
    assert_equal(
        cli_output_text("  eins\n zwei\t drei ", True, True),
        "eins zwei drei",
    )
    assert_equal(cli_output_text("plain", False, True), "plain")
    assert_equal(cli_output_text("hidden", False, False), "")
    assert_equal(debug_pair_output("Wert", "42", True), "Wert: 42")
    assert_equal(debug_pair_output("Wert", "42", False), "")
    assert_equal(debug_value_output("42", True), "42")


def test_ordered_default_dictionary_preserves_insertion() raises:
    var ordered = default_ordered_dict()
    var alpha = ordered.get_or_default("alpha")
    assert_equal(len(alpha), 0)
    alpha.append("1")
    ordered.set("alpha", alpha)
    ordered.set("beta", ["2", "3"])
    ordered.set("alpha", ["4"])
    var snapshot = ordered.snapshot()
    assert_equal(snapshot.keys, ["alpha", "beta"])
    assert_equal(snapshot.values[0], ["4"])
    assert_equal(snapshot.values[1], ["2", "3"])
    assert_true(ordered.contains("alpha"))
    assert_false(ordered.contains("gamma"))


def test_explicit_text_wrap_width_avoids_terminal_dependency() raises:
    var runtime = get_text_wrap_things(123)
    assert_equal(runtime.shell_width, 123)
    assert_false(runtime.has_hyphenator)
    assert_false(runtime.has_dictionary)
    assert_true(runtime.has_fill)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
