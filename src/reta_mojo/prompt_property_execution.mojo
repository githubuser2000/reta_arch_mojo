"""Native planning for EIGN/EIGR prompt property selectors.

The historical prompt turns the complete command token set back into a list
before extracting ``EIGN`` and ``EIGR`` suffixes.  That observable CPython set
order is preserved here.  ``EIGR`` has an additional legacy quirk: its column
selection is emitted before a second ``-zeilen`` section containing ordinary
integer rows.  The Python prompt currently crashes while deep-copying state
before it can execute this argv, but the generated argv is explicit and works
through the regular reta CLI.
"""

from std.collections import List
from .prompt_language import normalize_prompt_language, python_string_set_order


@fieldwise_init
struct PromptPropertyInvocation(Copyable):
    var tokens: List[String]


@fieldwise_init
struct PromptPropertyPlan(Copyable):
    var recognized: Bool
    var invocations: List[PromptPropertyInvocation]
    var n_values: List[String]
    var reciprocal_values: List[String]


def _contains_prefix(words: List[String], prefix: String) -> Bool:
    for index in range(len(words)):
        var token = words[index]
        if token.startswith(prefix) and token.byte_length() > 4:
            return True
    return False


def _ordered_property_values(
    ordered_words: List[String], prefix: String
) -> List[String]:
    """Extract property suffixes from a CPython-ordered complete token set."""
    var result = List[String]()
    for index in range(len(ordered_words)):
        var token = ordered_words[index]
        if token.startswith(prefix) and token.byte_length() > 4:
            result.append(String(token[byte=4:]))
    return result^


def _copy_strings(values: List[String]) -> List[String]:
    var result = List[String]()
    for index in range(len(values)):
        result.append(values[index])
    return result^


def _join(values: List[String]) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += ","
        result += values[index]
    return result^


def _base_without_maximum(
    language: String, rows: String, counting: Bool, invert: Bool
) -> List[String]:
    var result = List[String]()
    var normalized = normalize_prompt_language(language)
    if normalized != "deutsch":
        result.append("-language=" + normalized)
    result.append("-zeilen")
    result.append(
        ("--zaehlung=" if counting else "--vorhervonausschnitt=") + rows
    )
    if invert:
        result.append("--invertieren")
    result.append("-spalten")
    return result^


def _append_tail(
    mut tokens: List[String],
    column_option: String,
    suppress_empty: Bool,
    passthrough: List[String],
) -> None:
    tokens.append(column_option)
    tokens.append("--breite=0")
    tokens.append("-ausgabe")
    if suppress_empty:
        tokens.append("--keineleereninhalte")
    for index in range(len(passthrough)):
        tokens.append(passthrough[index])


def _row_options_from_base(base: List[String]) -> List[String]:
    var result = List[String]()
    var in_rows = False
    for index in range(len(base)):
        var token = base[index]
        if token == "-zeilen" or token == "-lines" or token == "-rows":
            in_rows = True
            continue
        if token == "-spalten" or token == "-columns":
            break
        if in_rows and token != "--invertieren" and token != "--invert":
            result.append(token)
    return result^


def plan_prompt_property_commands(
    words: List[String],
    language: String,
    has_integer: Bool,
    integer_base: List[String],
    has_reciprocal: Bool,
    reciprocal_base: List[String],
    counting: Bool,
    invert: Bool,
    suppress_empty: Bool,
    passthrough: List[String],
) -> PromptPropertyPlan:
    """Build native EIGN/EIGR table argv fragments.

    EIGN uses only the ordinary integer/whole-number axis.  EIGR combines the
    reciprocal axis with ordinary integers by retaining the reference's second
    ``-zeilen`` section.  Proper fractions alone intentionally produce no table.
    """
    var has_n = _contains_prefix(words, "EIGN")
    var has_r = _contains_prefix(words, "EIGR")
    var ordered_words = python_string_set_order(words)
    var n_values = _ordered_property_values(ordered_words, "EIGN")
    var reciprocal_values = _ordered_property_values(ordered_words, "EIGR")
    var invocations = List[PromptPropertyInvocation]()

    if has_integer and len(n_values) > 0:
        var tokens = _copy_strings(integer_base)
        _append_tail(
            tokens,
            "--konzept=" + _join(n_values),
            suppress_empty,
            passthrough,
        )
        invocations.append(PromptPropertyInvocation(tokens^))

    if len(reciprocal_values) > 0 and (has_integer or has_reciprocal):
        var tokens = _copy_strings(
            reciprocal_base
        ) if has_reciprocal else _base_without_maximum(
            language, "0", counting, invert
        )
        _append_tail(
            tokens,
            "--konzept2=" + _join(reciprocal_values),
            suppress_empty,
            passthrough,
        )
        if has_integer:
            tokens.append("-zeilen")
            var row_options = _row_options_from_base(integer_base)
            for index in range(len(row_options)):
                tokens.append(row_options[index])
        invocations.append(PromptPropertyInvocation(tokens^))

    return PromptPropertyPlan(
        has_n or has_r,
        invocations^,
        n_values^,
        reciprocal_values^,
    )
