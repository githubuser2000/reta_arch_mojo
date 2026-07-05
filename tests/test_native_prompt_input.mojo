from std.testing import assert_equal, assert_false, assert_true, TestSuite
from std.os import getenv
from reta_mojo.native_prompt_input import (
    append_prompt_history,
    expanded_history_path,
    load_prompt_history,
)


def _sandbox_path(name: String) -> String:
    var root = String(getenv("RETA_TEST_SANDBOX", "/tmp"))
    root = String(root.strip())
    if root.byte_length() == 0:
        root = "/tmp"
    if root.endswith("/"):
        return root + name
    return root + "/" + name


def test_literal_path_is_unchanged() raises:
    assert_equal(expanded_history_path("/tmp/history"), "/tmp/history")


def test_empty_history_line_is_ignored() raises:
    assert_false(append_prompt_history(_sandbox_path("reta-empty-history"), "   "))


def test_history_append_retains_duplicates() raises:
    var path = _sandbox_path("reta-native-prompt-history")
    # Truncate with the portable Mojo file API.
    var reset = open(path, "w")
    reset.write_all("".as_bytes())
    assert_true(append_prompt_history(path, "prim 12"))
    assert_true(append_prompt_history(path, "prim 12"))
    var file = open(path, "r")
    assert_equal(file.read(), "prim 12\nprim 12\n")


def test_history_load_preserves_order_and_duplicates() raises:
    var path = _sandbox_path("reta-native-prompt-history-load")
    var reset = open(path, "w")
    reset.write_all("prim 12\nmond 3\nmond 3\n".as_bytes())
    var values = load_prompt_history(path)
    assert_equal(len(values), 3)
    assert_equal(values[0], "prim 12")
    assert_equal(values[1], "mond 3")
    assert_equal(values[2], "mond 3")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
