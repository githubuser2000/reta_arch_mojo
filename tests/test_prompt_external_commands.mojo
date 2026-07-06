from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.prompt_external_commands import (
    reta_child_arguments_native,
    shell_quote,
    shell_split,
)


def _joined(values: List[String]) -> String:
    return "\x1f".join(values)


def test_shell_split_plain_and_quotes() raises:
    assert_equal(
        _joined(shell_split("/bin/printf '%s|%s\\n' 'alpha beta' gamma")),
        "/bin/printf\x1f%s|%s\\n\x1falpha beta\x1fgamma",
    )


def test_shell_split_unicode_and_empty_arguments() raises:
    assert_equal(
        _joined(shell_split("cmd '' \"ä λ\"")),
        "cmd\x1f\x1fä λ",
    )


def test_shell_split_backslashes() raises:
    assert_equal(
        _joined(shell_split("cmd a\\ b \"c\\\"d\" \"x\\qy\"")),
        "cmd\x1fa b\x1fc\"d\x1fx\\qy",
    )


def test_shell_split_rejects_unclosed_quote() raises:
    var failed = False
    try:
        _ = shell_split("cmd 'broken")
    except:
        failed = True
    assert_true(failed)


def test_shell_quote_handles_apostrophe() raises:
    assert_equal(shell_quote("a'b"), "'a'\"'\"'b'")
    assert_equal(shell_quote(""), "''")


def test_reta_child_arguments_drop_historical_entrypoint() raises:
    assert_equal(
        _joined(reta_child_arguments_native(["reta", "-zeilen", "1"])),
        "-zeilen\x1f1",
    )
    assert_equal(
        _joined(reta_child_arguments_native(["/tmp/reta.py", "-spalten"])),
        "-spalten",
    )
    assert_equal(
        _joined(reta_child_arguments_native(["-zeilen", "2"])),
        "-zeilen\x1f2",
    )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
