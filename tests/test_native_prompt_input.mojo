from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.native_prompt_input import (
    append_prompt_history,
    expanded_history_path,
)


def test_literal_path_is_unchanged() raises:
    assert_equal(expanded_history_path("/tmp/history"), "/tmp/history")


def test_empty_history_line_is_ignored() raises:
    assert_false(append_prompt_history("/tmp/reta-empty-history", "   "))


def test_history_append_retains_duplicates() raises:
    var path = "/tmp/reta-native-prompt-history"
    # Truncate with the portable Mojo file API.
    var reset = open(path, "w")
    reset.write_all("".as_bytes())
    assert_true(append_prompt_history(path, "prim 12"))
    assert_true(append_prompt_history(path, "prim 12"))
    var file = open(path, "r")
    assert_equal(file.read(), "prim 12\nprim 12\n")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
