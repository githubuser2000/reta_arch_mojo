from std.collections import List
from std.testing import assert_equal, assert_false, TestSuite
from reta_mojo.prompt_language import (
    expand_compact_prompt_tokens,
    expand_prompt_replacements,
    load_prompt_language_catalog,
    prepare_prompt_tokens,
    PromptLanguageCatalog,
)


def _catalog() raises -> PromptLanguageCatalog:
    return load_prompt_language_catalog("assets")


def test_python_unicode_payload_bypasses_compact_scanner() raises:
    var catalog = _catalog()
    var tokens = List[String]()
    tokens.append("python")
    tokens.append("print(\"ä λ\")")
    var expanded = expand_compact_prompt_tokens(
        catalog, "deutsch", tokens
    )
    assert_false(expanded.compact)
    assert_equal("\x1f".join(expanded.tokens), "python\x1fprint(\"ä λ\")")


def test_shell_payload_keeps_quotes_before_planning_set() raises:
    var catalog = _catalog()
    var tokens = List[String]()
    tokens.append("shell")
    tokens.append("/bin/printf")
    tokens.append("'%s\\n'")
    tokens.append("'alpha beta'")
    var expanded = expand_compact_prompt_tokens(
        catalog, "english", tokens
    )
    assert_false(expanded.compact)
    var replaced = expand_prompt_replacements(
        catalog, "english", expanded.tokens
    )
    assert_equal(
        "\x1f".join(replaced),
        "shell\x1f/bin/printf\x1f'%s\\n'\x1f'alpha beta'",
    )


def test_math_payload_keeps_order_before_planning_set() raises:
    var catalog = _catalog()
    var tokens = List[String]()
    for value in ["math", "sum([1,", "2,", "3])", "*", "7"]:
        tokens.append(String(value))
    var expanded = expand_compact_prompt_tokens(
        catalog, "korean", tokens
    )
    var replaced = expand_prompt_replacements(
        catalog, "korean", expanded.tokens
    )
    assert_equal(
        "\x1f".join(replaced),
        "math\x1fsum([1,\x1f2,\x1f3])\x1f*\x1f7",
    )


def test_historical_preparation_set_order_is_unchanged() raises:
    var catalog = _catalog()
    var tokens = List[String]()
    for value in ["shell", "echo", "hi"]:
        tokens.append(String(value))
    var prepared = prepare_prompt_tokens(catalog, "deutsch", tokens)
    assert_equal("\x1f".join(prepared.tokens), "hi\x1fshell\x1fecho")


def test_raw_replacements_leave_unicode_untouched() raises:
    var catalog = _catalog()
    var tokens = List[String]()
    tokens.append("python")
    tokens.append("print(\"übersetzt?\")")
    var replaced = expand_prompt_replacements(
        catalog, "vietnamese", tokens
    )
    assert_equal(
        "\x1f".join(replaced), "python\x1fprint(\"übersetzt?\")"
    )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
