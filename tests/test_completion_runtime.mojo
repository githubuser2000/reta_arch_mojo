from std.testing import assert_equal, TestSuite
from reta_mojo.completion_runtime import *


def _contains(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def test_deutsch_runtime_sections_and_shortcuts() raises:
    var runtime = bootstrap_completion_runtime("assets", "deutsch")
    assert_equal(runtime.language, "deutsch")
    assert_equal(_contains(runtime.root_commands, "reta"), True)
    assert_equal(_contains(runtime.main_parameters, "-zeilen"), True)
    assert_equal(_contains(runtime.parameters("-ausgabe"), "--art="), True)
    assert_equal(
        _contains(runtime.value_options("-ausgabe", "art"), "html"), True
    )
    var commands = runtime.start_commands(True)
    assert_equal(_contains(commands, "15_"), True)
    assert_equal(_contains(commands, "16_"), True)
    assert_equal(
        completion_runtime_order_index(runtime, runtime.root_commands[0]), 0
    )


def test_english_runtime_snapshot() raises:
    var runtime = bootstrap_completion_runtime("assets", "english")
    var snapshot = runtime.snapshot()
    assert_equal(snapshot.class_name, "CompletionRuntimeBundle")
    assert_equal(snapshot.language, "english")
    assert_equal(snapshot.root_commands_len > 0, True)
    assert_equal(snapshot.main_parameters_len, 7)
    assert_equal(snapshot.completion_sections_len > 0, True)
    assert_equal(len(snapshot.start_commands_with_numeric_shortcuts), 10)
    assert_equal(len(snapshot.value_contexts) > 0, True)


def test_language_normalization_and_fallback_values() raises:
    var runtime = bootstrap_completion_runtime("assets", "en")
    assert_equal(runtime.language, "english")
    var direct = runtime.value_options("-output", "type")
    assert_equal(_contains(direct, "shell"), True)
    var unknown = runtime.value_options("-output", "unknown")
    assert_equal(len(unknown), 0)
    assert_equal(runtime.has_value_context("-output", "type"), True)
    assert_equal(runtime.has_value_context("-output", "unknown"), False)
    assert_equal(_contains(runtime.value_parameter_names("-output"), "type"), True)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
