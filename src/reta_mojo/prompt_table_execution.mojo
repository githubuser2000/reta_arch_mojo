"""Native planning for prompt commands backed by the reta table core.

This module owns the integer ``n`` path, integer multiple/divisor modifiers and
positive rational ``n/m`` expressions, stable exclusion forms, reciprocal
multiple expansion and fraction/divisor combinations.  The historical Python
function mixes parsing, i18n, range algebra and table execution; here these
concerns are split into typed planning stages.  True ``v n/m`` expansion remains
at the compatibility boundary because the Python reference itself crashes for
that form.
"""

from std.collections import List
from .number_theory import divisors
from .prime_cross_columns import python_int_set_order, python_signed_int_set_order
from .prompt_fraction_execution import (
    create_prompt_fraction_range,
    parse_prompt_fraction,
)
from .prompt_language import (
    PromptLanguageCatalog,
    normalize_prompt_language,
    python_string_set_order,
)
from .row_ranges import is_row_range, range_to_numbers, split_top_level_commas


@fieldwise_init
struct PromptTableInvocation(Copyable):
    var tokens: List[String]
    var command_echo_newline: Bool


@fieldwise_init
struct PromptTablePlan(Copyable):
    var handled: Bool
    var invocations: List[PromptTableInvocation]


@fieldwise_init
struct _PromptFractionPair(Copyable):
    var numerator: Int
    var denominator: Int
    var excluded: Bool
    var multiple: Bool


@fieldwise_init
struct _PromptNumericSelection(Copyable):
    var found: Bool
    var family: String
    var value: String


def _lookup_numeric_shortcut(
    catalog: PromptLanguageCatalog,
    language: String,
    family: String,
    key: String,
) -> _PromptNumericSelection:
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.numeric_shortcuts)):
        var entry = catalog.numeric_shortcuts[index].copy()
        if (
            entry.language == normalized
            and entry.family == family
            and entry.key == key
        ):
            return _PromptNumericSelection(True, family, entry.description)
    return _PromptNumericSelection(False, "", "")


def _numeric_shortcut_selection(
    catalog: PromptLanguageCatalog,
    language: String,
    token: String,
) -> _PromptNumericSelection:
    if token == "15_":
        return _lookup_numeric_shortcut(catalog, language, "15", "15")
    if token.startswith("15_"):
        return _lookup_numeric_shortcut(
            catalog, language, "15", String(token[byte=3:])
        )
    if token == "16_15" or token == "16_15_":
        return _lookup_numeric_shortcut(catalog, language, "15", "15")
    if token.startswith("16_15_"):
        return _lookup_numeric_shortcut(
            catalog, language, "15", String(token[byte=6:])
        )
    if token == "16_":
        return _lookup_numeric_shortcut(catalog, language, "16", "16")
    if token.startswith("16_"):
        return _lookup_numeric_shortcut(
            catalog, language, "16", String(token[byte=3:])
        )
    return _PromptNumericSelection(False, "", "")


def _numeric_parameter_name(language: String, family: String) -> String:
    var normalized = normalize_prompt_language(language)
    if family == "15":
        return "Grundstrukturen" if normalized == "deutsch" else "basic_structures"
    return "Multiversum" if normalized == "deutsch" else "multiverse"


def _canonical_command(
    catalog: PromptLanguageCatalog,
    language: String,
    token: String,
) -> String:
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.vocabulary)):
        var entry = catalog.vocabulary[index].copy()
        if (
            entry.language == normalized
            and entry.domain == "command"
            and entry.translated == token
        ):
            return entry.canonical
    return token


def _is_fraction_expression(token: String) -> Bool:
    return "/" in token


def _is_modifier_command(canonical: String) -> Bool:
    return (
        canonical == "vielfache"
        or canonical == "v"
        or canonical == "teiler"
        or canonical == "w"
        or canonical == "einzeln"
    )


def _is_control_command(canonical: String) -> Bool:
    return (
        canonical == "range"
        or canonical == "R"
        or canonical == "invertieren"
        or canonical == "e"
        or canonical == "ee"
        or canonical
        == "keineEinZeichenZeilenPlusKeineAusgabeWelcherBefehlEsWar"
        or _is_modifier_command(canonical)
    )


def _is_table_command(canonical: String) -> Bool:
    return (
        canonical == "mond"
        or canonical == "richtung"
        or canonical == "r"
        or canonical == "primzahlkreuz"
        or canonical == "alles"
        or canonical == "thomas"
        or canonical == "t"
        or canonical == "emotion"
        or canonical == "E"
        or canonical == "wirklichkeit"
        or canonical == "W"
        or canonical == "triebe"
        or canonical == "T"
        or canonical == "impulse"
        or canonical == "I"
        or canonical == "bewusstsein"
        or canonical == "B"
        or canonical == "geist"
        or canonical == "G"
        or canonical == "freiheit"
        or canonical == "gleichheit"
        or canonical == "groesse"
        or canonical == "kugeln"
        or canonical == "kreise"
        or canonical == "netzwerk"
        or canonical == "komplex"
        or canonical == "absicht"
        or canonical == "absichten"
        or canonical == "motiv"
        or canonical == "motive"
        or canonical == "a"
        or canonical == "universum"
        or canonical == "u"
    )


def _is_fraction_table_command(canonical: String) -> Bool:
    return (
        canonical == "emotion"
        or canonical == "E"
        or canonical == "wirklichkeit"
        or canonical == "W"
        or canonical == "triebe"
        or canonical == "T"
        or canonical == "impulse"
        or canonical == "I"
        or canonical == "bewusstsein"
        or canonical == "B"
        or canonical == "geist"
        or canonical == "G"
        or canonical == "freiheit"
        or canonical == "gleichheit"
        or canonical == "groesse"
        or canonical == "kugeln"
        or canonical == "kreise"
        or canonical == "netzwerk"
        or canonical == "komplex"
        or canonical == "absicht"
        or canonical == "absichten"
        or canonical == "motiv"
        or canonical == "motive"
        or canonical == "a"
        or canonical == "universum"
        or canonical == "u"
    )


def _contains(values: List[String], needle: String) -> Bool:
    for index in range(len(values)):
        if values[index] == needle:
            return True
    return False


def _has_duplicate_strings(values: List[String]) -> Bool:
    for index in range(len(values)):
        for other in range(index + 1, len(values)):
            if values[index] == values[other]:
                return True
    return False


def _contains_int(values: List[Int], needle: Int) -> Bool:
    for index in range(len(values)):
        if values[index] == needle:
            return True
    return False


def _contains_any(values: List[String], candidates: List[String]) -> Bool:
    for index in range(len(candidates)):
        if _contains(values, candidates[index]):
            return True
    return False


def _append_unique_string(mut values: List[String], value: String) -> None:
    if not _contains(values, value):
        values.append(value)


def _append_unique_int(mut values: List[Int], value: Int) -> None:
    if not _contains_int(values, value):
        values.append(value)


def _sort_ints(mut values: List[Int]) -> None:
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key


def _has_no_headings_parameter(
    words: List[String],
    language: String,
    catalog: PromptLanguageCatalog,
) -> Bool:
    var normalized = normalize_prompt_language(language)
    for word_index in range(len(words)):
        var token = words[word_index]
        if not token.startswith("--"):
            continue
        var name = token[byte=2:]
        for entry_index in range(len(catalog.vocabulary)):
            var entry = catalog.vocabulary[entry_index].copy()
            if (
                entry.language == normalized
                and entry.domain == "output"
                and entry.canonical == "keineueberschriften"
                and entry.translated == name
            ):
                return True
    return False


def _join_rows(values: List[String]) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += ","
        result += values[index]
    return result^


def _copy_strings(values: List[String]) -> List[String]:
    var result = List[String]()
    for index in range(len(values)):
        result.append(values[index])
    return result^


def _base_table_tokens(
    language: String,
    rows: String,
    maximum: Int,
    counting: Bool,
    invert: Bool,
) -> List[String]:
    var result = List[String]()
    var normalized = normalize_prompt_language(language)
    if normalized != "deutsch":
        result.append("-language=" + normalized)
    result.append("-zeilen")
    if counting:
        result.append("--zaehlung=" + rows)
    else:
        result.append("--vorhervonausschnitt=" + rows)
    result.append("--oberesmaximum=" + String(maximum + 1))
    if invert:
        result.append("--invertieren")
    result.append("-spalten")
    return result^


def _base_table_tokens_without_maximum(
    language: String,
    rows: String,
    counting: Bool,
    invert: Bool,
) -> List[String]:
    var result = List[String]()
    var normalized = normalize_prompt_language(language)
    if normalized != "deutsch":
        result.append("-language=" + normalized)
    result.append("-zeilen")
    if counting:
        result.append("--zaehlung=" + rows)
    else:
        result.append("--vorhervonausschnitt=" + rows)
    if invert:
        result.append("--invertieren")
    result.append("-spalten")
    return result^


def _base_multiple_tokens(
    language: String,
    row_parts: List[String],
    counting: Bool,
    invert: Bool,
) -> List[String]:
    var result = List[String]()
    var normalized = normalize_prompt_language(language)
    if normalized != "deutsch":
        result.append("-language=" + normalized)
    var rows = _join_rows(row_parts)
    var selected = _copy_strings(row_parts)
    for index in range(len(row_parts)):
        selected.append("v" + row_parts[index])
    result.append("-zeilen")
    result.append("--vielfachevonzahlen=" + rows)
    if counting:
        result.append("--zaehlung=" + _join_rows(selected))
    else:
        result.append("--vorhervonausschnitt=" + _join_rows(selected))
    if invert:
        result.append("--invertieren")
    result.append("-spalten")
    return result^


def _append_table_tail(
    mut tokens: List[String],
    column_option: String,
    selected_columns: String,
    suppress_empty: Bool,
    passthrough: List[String],
) -> None:
    tokens.append(column_option)
    tokens.append("--breite=0")
    tokens.append("-ausgabe")
    if selected_columns.byte_length() > 0:
        tokens.append("--spaltenreihenfolgeundnurdiese=" + selected_columns)
    if suppress_empty:
        tokens.append("--keineleereninhalte")
    for index in range(len(passthrough)):
        tokens.append(passthrough[index])


def _add_invocation(
    mut invocations: List[PromptTableInvocation],
    base: List[String],
    column_option: String,
    selected_columns: String,
    suppress_empty: Bool,
    passthrough: List[String],
    command_echo_newline: Bool = False,
) -> None:
    var tokens = _copy_strings(base)
    _append_table_tail(
        tokens,
        column_option,
        selected_columns,
        suppress_empty,
        passthrough,
    )
    invocations.append(
        PromptTableInvocation(tokens^, command_echo_newline)
    )


def _add_axis_family(
    mut invocations: List[PromptTableInvocation],
    has_integer: Bool,
    integer_base: List[String],
    integer_option: String,
    integer_columns: String,
    has_reciprocal: Bool,
    reciprocal_base: List[String],
    reciprocal_option: String,
    reciprocal_columns: String,
    suppress_empty: Bool,
    passthrough: List[String],
) -> None:
    if has_integer:
        _add_invocation(
            invocations,
            integer_base,
            integer_option,
            integer_columns,
            suppress_empty,
            passthrough,
        )
    if has_reciprocal:
        _add_invocation(
            invocations,
            reciprocal_base,
            reciprocal_option,
            reciprocal_columns,
            suppress_empty,
            passthrough,
        )


def _append_unique_fraction_pair(
    mut pairs: List[_PromptFractionPair],
    numerator: Int,
    denominator: Int,
    excluded: Bool,
    multiple: Bool,
) -> None:
    for index in range(len(pairs)):
        var pair = pairs[index].copy()
        if (
            pair.numerator == numerator
            and pair.denominator == denominator
            and pair.excluded == excluded
            and pair.multiple == multiple
        ):
            return
    pairs.append(
        _PromptFractionPair(numerator, denominator, excluded, multiple)
    )


def _parse_direct_fraction_axes(
    part: String,
    mut pairs: List[_PromptFractionPair],
    excluded: Bool,
    multiple: Bool,
) raises -> Bool:
    var axes = part.split("/")
    if len(axes) != 2:
        return False
    var numerator_text = String(axes[0])
    var denominator_text = String(axes[1])
    if numerator_text.byte_length() == 0 or denominator_text.byte_length() == 0:
        return False
    try:
        var numerators = range_to_numbers(numerator_text, False, 0)
        var denominators = range_to_numbers(denominator_text, False, 0)
        if len(numerators) == 0 or len(denominators) == 0:
            return False
        for numerator in numerators:
            if numerator <= 0:
                return False
            for denominator in denominators:
                if denominator <= 0:
                    return False
                _append_unique_fraction_pair(
                    pairs, numerator, denominator, excluded, multiple
                )
    except:
        return False
    return True


def _parse_legacy_fraction_expression(
    part: String,
    mut pairs: List[_PromptFractionPair],
    excluded: Bool,
    multiple: Bool,
) raises -> Bool:
    var parsed = parse_prompt_fraction(part)
    if not parsed.valid:
        return False
    var ranged = create_prompt_fraction_range(parsed.groups)
    if not ranged.valid or len(ranged.values) == 0:
        return False
    var appended = False
    try:
        var denominators = range_to_numbers(ranged.suffix, False, 0)
        for numerator_index in range(len(ranged.values)):
            var numerator = ranged.values[numerator_index]
            if numerator <= 0:
                continue
            for denominator in denominators:
                if denominator <= 0:
                    continue
                _append_unique_fraction_pair(
                    pairs, numerator, denominator, excluded, multiple
                )
                appended = True
    except:
        return False
    return appended


def _parse_fraction_token(
    token: String,
    mut pairs: List[_PromptFractionPair],
) raises -> Bool:
    var comma_parts = token.split(",")
    for part_index in range(len(comma_parts)):
        var part = String(comma_parts[part_index])
        var excluded = False
        var multiple = False
        if part.startswith("v"):
            multiple = True
            part = String(part[byte=1:])
        if part.startswith("-"):
            excluded = True
            part = String(part[byte=1:])
        if part.byte_length() == 0:
            return False
        if _parse_direct_fraction_axes(part, pairs, excluded, multiple):
            continue
        if not _parse_legacy_fraction_expression(
            part, pairs, excluded, multiple
        ):
            return False
    return True


def _has_matching_exclusion(
    pairs: List[_PromptFractionPair], positive: _PromptFractionPair
) -> Bool:
    for index in range(len(pairs)):
        var candidate = pairs[index].copy()
        if (
            candidate.excluded
            and candidate.numerator == positive.numerator
            and candidate.denominator == positive.denominator
        ):
            return True
    return False


def _has_positive_fraction(pairs: List[_PromptFractionPair]) -> Bool:
    for index in range(len(pairs)):
        if not pairs[index].excluded:
            return True
    return False


def _fraction_multiple_mode(pairs: List[_PromptFractionPair]) -> Bool:
    for index in range(len(pairs)):
        if pairs[index].multiple:
            return True
    return False


def _fraction_multiple_supported(pairs: List[_PromptFractionPair]) -> Bool:
    # The legacy implementation is stable for reciprocal 1/n multiples.  It
    # raises IndexError for true n/m or n/1 multiple expansion, so those remain
    # behind the compatibility boundary until a reference contract exists.
    for index in range(len(pairs)):
        if pairs[index].numerator != 1:
            return False
    return True


def _fraction_exclusions_supported(
    pairs: List[_PromptFractionPair], multiple_mode: Bool
) -> Bool:
    # Row polarity cancellation and empty-positive selectors are represented
    # by the native CLI planner.  All parsed exclusion combinations are now
    # safe here; true n/m multiple expansion is guarded separately.
    return True


def _expanded_reciprocal_multiple_rows(
    pairs: List[_PromptFractionPair], upper_exclusive: Int
) -> List[String]:
    var attempts = List[Int]()
    var exclusions = List[Int]()
    for index in range(len(pairs)):
        var pair = pairs[index].copy()
        if pair.numerator != 1 or pair.denominator <= 0:
            continue
        var value = pair.denominator
        while value < upper_exclusive:
            if pair.excluded:
                _append_unique_int(exclusions, value)
            else:
                attempts.append(value)
            value += pair.denominator

    # CPython iterates the positive set after subtraction.  Integer hashes are
    # identities, so reproducing its slot order and then filtering exclusions
    # preserves cases such as v1/4,-1/8 (4,516,12,524,...).
    var ordered = python_int_set_order(attempts)
    var result = List[String]()
    for index in range(len(ordered)):
        if not _contains_int(exclusions, ordered[index]):
            result.append(String(ordered[index]))
    return result^

def _append_fraction_invocations(
    mut invocations: List[PromptTableInvocation],
    pairs: List[_PromptFractionPair],
    language: String,
    counting: Bool,
    invert: Bool,
    option_prefix: String,
    selected_columns: String,
    suppress_empty: Bool,
    passthrough: List[String],
) -> None:
    var numerators = List[Int]()
    for pair_index in range(len(pairs)):
        var pair = pairs[pair_index].copy()
        if not pair.excluded and pair.numerator != 1:
            _append_unique_int(numerators, pair.numerator)
    # Positive numerator groups retain the Stage-10c observed ascending order.
    _sort_ints(numerators)
    for numerator_index in range(len(numerators)):
        var numerator = numerators[numerator_index]
        var denominator_attempts = List[String]()
        for other_index in range(len(pairs)):
            var other = pairs[other_index].copy()
            if other.numerator == numerator:
                denominator_attempts.append(
                    ("-" if other.excluded else "")
                    + String(other.denominator)
                )
        # The legacy numerator buckets store denominator spellings as strings,
        # not integers.  This matters for collisions such as {"2", "-2"}.
        var denominator_rows = python_string_set_order(denominator_attempts)
        var base = _base_table_tokens_without_maximum(
            language,
            _join_rows(denominator_rows),
            counting,
            invert,
        )
        _add_invocation(
            invocations,
            base,
            option_prefix + String(numerator),
            selected_columns,
            suppress_empty,
            passthrough,
        )


def _append_universe_equal_axis(
    mut invocations: List[PromptTableInvocation],
    pairs: List[_PromptFractionPair],
    language: String,
    counting: Bool,
    invert: Bool,
    suppress_empty: Bool,
    passthrough: List[String],
) -> None:
    var equal_rows = List[String]()
    for index in range(len(pairs)):
        var pair = pairs[index].copy()
        if (
            not pair.excluded
            and not _has_matching_exclusion(pairs, pair)
            and pair.numerator == pair.denominator
            and pair.numerator != 1
        ):
            _append_unique_string(equal_rows, String(pair.numerator))
    if len(equal_rows) == 0:
        return
    var base = _base_table_tokens_without_maximum(
        language,
        _join_rows(equal_rows),
        counting,
        invert,
    )
    _add_invocation(
        invocations,
        base,
        "--universum=verhaeltnisgleicherzahl",
        "1",
        suppress_empty,
        passthrough,
    )

def plan_prompt_table_commands(
    words: List[String],
    language: String,
    catalog: PromptLanguageCatalog,
) raises -> PromptTablePlan:
    """Translate supported prompt table commands into native reta argv.

    Multiple domain commands produce multiple invocations, matching the
    historical independent ``if`` branches.  Simple positive rational ranges
    are decomposed into integer, reciprocal and proper-fraction axes.
    """
    var canonical_words = List[String]()
    var row_part_attempts = List[String]()
    var row_values = List[Int]()
    var excluded_row_values = List[Int]()
    var fraction_pairs = List[_PromptFractionPair]()
    var numeric15_values = List[String]()
    var numeric16_values = List[String]()
    var passthrough = List[String]()
    var maximum = 0
    var unsupported = False
    var has_fraction = False
    var saw_ignored_negative_integer = False
    var saw_integer_component_exclusion = False

    for index in range(len(words)):
        var token = words[index]
        var canonical = _canonical_command(catalog, language, token)
        canonical_words.append(canonical)
        var numeric = _numeric_shortcut_selection(catalog, language, token)
        if numeric.found:
            if numeric.family == "15":
                numeric15_values.append(numeric.value)
                canonical_words.append("__numeric15")
            else:
                numeric16_values.append(numeric.value)
                canonical_words.append("__numeric16")
            continue
        if _is_fraction_expression(token):
            has_fraction = True
            if not _parse_fraction_token(token, fraction_pairs):
                unsupported = True
            continue
        if _is_table_command(canonical) or _is_control_command(canonical):
            continue
        try:
            if is_row_range(token):
                # A standalone token beginning with '-' is interpreted by the
                # legacy prompt as a CLI-like parameter and contributes no row
                # selection at all.  In-token exclusions (2,-2) remain rows.
                if token.startswith("-"):
                    saw_ignored_negative_integer = True
                    continue
                var token_parts = split_top_level_commas(token)
                for part_index in range(len(token_parts)):
                    var part = String(token_parts[part_index])
                    if part.byte_length() == 0:
                        continue
                    row_part_attempts.append(part)
                    if part.startswith("-") and part.byte_length() > 1:
                        saw_integer_component_exclusion = True
                        try:
                            var excluded_values = range_to_numbers(
                                String(part[byte=1:]), False, 0
                            )
                            for excluded_value in excluded_values:
                                _append_unique_int(
                                    excluded_row_values, excluded_value
                                )
                        except:
                            pass
                var values = range_to_numbers(token, False, 0)
                for value in values:
                    row_values.append(value)
                    maximum = max(maximum, value)
                continue
        except:
            pass
        if token.startswith("-"):
            passthrough.append(token)

    # The Python prompt stores raw range components in a set.  Reproduce its
    # deterministic seed-zero order globally across all numeric tokens.
    var row_parts = python_string_set_order(row_part_attempts)

    var has_table_command = (
        len(numeric15_values) > 0 or len(numeric16_values) > 0
    )
    for index in range(len(canonical_words)):
        if _is_table_command(canonical_words[index]):
            has_table_command = True
    if not has_table_command:
        return PromptTablePlan(False, List[PromptTableInvocation]())

    var multiple_mode = (
        _contains(canonical_words, "vielfache")
        or _contains(canonical_words, "v")
        or _fraction_multiple_mode(fraction_pairs)
    )
    var divisor_mode = _contains(canonical_words, "teiler") or _contains(
        canonical_words, "w"
    )
    var single_mode = _contains(canonical_words, "einzeln")
    if single_mode:
        multiple_mode = False
    if multiple_mode and divisor_mode:
        unsupported = True
    if has_fraction and multiple_mode and not _fraction_multiple_supported(
        fraction_pairs
    ):
        unsupported = True
    if has_fraction and not _fraction_exclusions_supported(
        fraction_pairs, multiple_mode
    ):
        unsupported = True
    # Duplicate generated selections expose a legacy column-instance width
    # distinction that the current native table model intentionally does not
    # collapse or approximate.  Keep the whole command on the compatibility
    # boundary until duplicate column instances are represented explicitly.
    if _has_duplicate_strings(numeric15_values) or _has_duplicate_strings(
        numeric16_values
    ):
        unsupported = True
    if unsupported:
        return PromptTablePlan(False, List[PromptTableInvocation]())

    # The pure compact numeric default for zero is a peculiar stable legacy
    # branch: ``teiler`` contributes no divisor expansion, ``absicht`` emits no
    # second table, and the Thomas table omits ``--oberesmaximum`` entirely.
    var zero_default_mode = (
        len(row_parts) == 1
        and row_parts[0] == "0"
        and len(row_values) == 0
        and divisor_mode
        and _contains(canonical_words, "thomas")
        and _contains(canonical_words, "absicht")
        and _contains(canonical_words, "mulpri")
        and _contains(
            canonical_words,
            "keineEinZeichenZeilenPlusKeineAusgabeWelcherBefehlEsWar",
        )
    )

    var whole_rows = List[String]()
    var reciprocal_rows = List[String]()
    var has_positive_fraction = _has_positive_fraction(fraction_pairs)
    for index in range(len(fraction_pairs)):
        var pair = fraction_pairs[index].copy()
        if pair.excluded:
            continue
        var exact_exclusion = _has_matching_exclusion(fraction_pairs, pair)
        # Exact literal n/m cancellation is represented on that numerator's
        # proper-fraction axis.  Only 1/n has no such axis, so its reciprocal
        # promotion must remain and cancel there instead.
        if not exact_exclusion and pair.numerator % pair.denominator == 0:
            _append_unique_string(
                whole_rows, String(pair.numerator // pair.denominator)
            )
        if (not exact_exclusion or pair.numerator == 1) and pair.denominator % pair.numerator == 0:
            _append_unique_string(
                reciprocal_rows, String(pair.denominator // pair.numerator)
            )

    if multiple_mode and has_fraction:
        reciprocal_rows = _expanded_reciprocal_multiple_rows(
            fraction_pairs, 1024
        )
    elif has_positive_fraction:
        # Legacy subtraction only promotes explicit -1/n axes into the
        # reciprocal row selection.  Equivalent forms such as -2/4 stay in
        # their proper-fraction numerator group.
        var reciprocal_attempts = List[Int]()
        for index in range(len(reciprocal_rows)):
            reciprocal_attempts.append(Int(reciprocal_rows[index]))
        for index in range(len(fraction_pairs)):
            var pair = fraction_pairs[index].copy()
            if pair.excluded and pair.numerator == 1:
                reciprocal_attempts.append(-pair.denominator)
        var had_positive_reciprocal = len(reciprocal_rows) > 0
        var reciprocal_order = python_signed_int_set_order(reciprocal_attempts)
        reciprocal_rows = List[String]()
        for index in range(len(reciprocal_order)):
            reciprocal_rows.append(String(reciprocal_order[index]))
        # A selector containing only exclusions is serialized with an explicit
        # empty positive side (",-4"), which means all rows except 4.
        if not had_positive_reciprocal and len(reciprocal_rows) > 0:
            reciprocal_rows[0] = "," + reciprocal_rows[0]

    var normal_rows = _copy_strings(row_parts)
    for index in range(len(whole_rows)):
        normal_rows.append(whole_rows[index])
        maximum = max(maximum, Int(whole_rows[index]))

    if divisor_mode and not zero_default_mode:
        var divisor_rows = List[String]()
        var resolved_divisor_values = List[Int]()
        for value_index in range(len(row_values)):
            if not _contains_int(
                excluded_row_values, row_values[value_index]
            ):
                resolved_divisor_values.append(row_values[value_index])

        # The legacy teiler branch subtracts explicit negative components
        # before calculating divisors.  If subtraction empties the positive
        # side, it serializes an empty component first (",-2,2"), preserving
        # the downstream all-rows-minus-exclusions interpretation.
        if (
            len(resolved_divisor_values) == 0
            and saw_integer_component_exclusion
            and len(row_parts) > 0
        ):
            divisor_rows.append("")
        for value_index in range(len(resolved_divisor_values)):
            var values = divisors(resolved_divisor_values[value_index])
            for divisor_index in range(len(values)):
                if values[divisor_index] != 1:
                    divisor_rows.append(String(values[divisor_index]))

        # A pure zero selector contributes no teiler invocation at all.  Zero
        # is retained only alongside a real positive value or an exclusion,
        # exactly as in the reference prompt's raw component set.
        if (
            len(resolved_divisor_values) > 0
            or saw_integer_component_exclusion
        ):
            for index in range(len(row_parts)):
                divisor_rows.append(row_parts[index])
        # Reduced n/m integers are added after the historical w/teiler
        # expansion and are not themselves expanded into their divisors.
        for index in range(len(whole_rows)):
            divisor_rows.append(whole_rows[index])
        normal_rows = divisor_rows^

    var has_integer = len(normal_rows) > 0
    var has_reciprocal = len(reciprocal_rows) > 0
    if not has_integer and not has_reciprocal and len(fraction_pairs) == 0:
        if (
            len(numeric15_values) > 0
            or len(numeric16_values) > 0
            or saw_ignored_negative_integer
            or (divisor_mode and len(row_parts) > 0)
        ):
            return PromptTablePlan(True, List[PromptTableInvocation]())
        return PromptTablePlan(False, List[PromptTableInvocation]())

    var distinct_table_commands = List[String]()
    for index in range(len(canonical_words)):
        var canonical = canonical_words[index]
        if _is_table_command(canonical) and not _contains(
            distinct_table_commands, canonical
        ):
            distinct_table_commands.append(canonical)

    var counting = _contains(canonical_words, "range") or _contains(
        canonical_words, "R"
    )
    var invert = _contains(canonical_words, "invertieren")
    var suppress_empty = _contains(
        canonical_words,
        "keineEinZeichenZeilenPlusKeineAusgabeWelcherBefehlEsWar",
    )
    var minimum_maximum = 1024
    if _contains(canonical_words, "primzahlkreuz"):
        minimum_maximum = 1028
    maximum = max(minimum_maximum, maximum)

    var integer_base = List[String]()
    if has_integer:
        if zero_default_mode:
            integer_base = _base_table_tokens_without_maximum(
                language, _join_rows(normal_rows), counting, invert
            )
        elif multiple_mode:
            integer_base = _base_multiple_tokens(
                language, row_parts, counting, invert
            )
        else:
            integer_base = _base_table_tokens(
                language,
                _join_rows(normal_rows),
                maximum,
                counting,
                invert,
            )
    var reciprocal_base = List[String]()
    if has_reciprocal:
        if multiple_mode and has_fraction:
            reciprocal_base = _base_table_tokens(
                language,
                _join_rows(reciprocal_rows),
                1024,
                counting,
                invert,
            )
        else:
            reciprocal_base = _base_table_tokens_without_maximum(
                language,
                _join_rows(reciprocal_rows),
                counting,
                invert,
            )
    var invocations = List[PromptTableInvocation]()

    if _contains(canonical_words, "mond") and has_integer:
        _add_invocation(
            invocations,
            integer_base,
            "--Bedeutung=gestirn",
            "3-6",
            suppress_empty,
            passthrough,
        )
    if (
        _contains(canonical_words, "richtung")
        or _contains(canonical_words, "r")
    ) and has_integer:
        _add_invocation(
            invocations,
            integer_base,
            "--Primzahlwirkung=Galaxieabsicht",
            "",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "primzahlkreuz") and has_integer:
        _add_invocation(
            invocations,
            integer_base,
            "--Bedeutung=primzahlkreuz",
            "",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "alles") and has_integer:
        _add_invocation(
            invocations,
            integer_base,
            "--alles",
            "",
            suppress_empty,
            passthrough,
        )
    if (
        _contains(canonical_words, "thomas")
        or _contains(canonical_words, "t")
    ) and has_integer:
        _add_invocation(
            invocations,
            integer_base,
            "--galaxie=thomas",
            "2",
            suppress_empty,
            passthrough,
        )

    if _contains(canonical_words, "emotion") or _contains(canonical_words, "E"):
        _add_axis_family(
            invocations,
            has_integer,
            integer_base,
            "--grundstrukturen=emotion",
            "2,3",
            has_reciprocal,
            reciprocal_base,
            "--grundstrukturen=emotion",
            "4,5",
            suppress_empty,
            passthrough,
        )
        _append_fraction_invocations(
            invocations,
            fraction_pairs,
            language,
            counting,
            invert,
            "--gebrochen-rational_Gefuehle_n/m=",
            "2",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "wirklichkeit") or _contains(
        canonical_words, "W"
    ):
        _add_axis_family(
            invocations,
            has_integer,
            integer_base,
            "--grundstrukturen=Wirklichkeiten_Wahrheit_Wahrnehmung_(10)",
            "1,2",
            has_reciprocal,
            reciprocal_base,
            "--grundstrukturen=Wirklichkeiten_Wahrheit_Wahrnehmung_(10)",
            "5",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "triebe") or _contains(canonical_words, "T"):
        _add_axis_family(
            invocations,
            has_integer,
            integer_base,
            "--grundstrukturen=trieb,System",
            "1",
            has_reciprocal,
            reciprocal_base,
            "--grundstrukturen=trieb,System",
            "2",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "impulse") or _contains(canonical_words, "I"):
        _add_axis_family(
            invocations,
            has_integer,
            integer_base,
            "--grundstrukturen=Impulse_(5)",
            "1,4",
            has_reciprocal,
            reciprocal_base,
            "--grundstrukturen=Impulse_(5)",
            "3",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "bewusstsein") or _contains(
        canonical_words, "B"
    ):
        _add_axis_family(
            invocations,
            has_integer,
            integer_base,
            "--grundstrukturen=Strukturalien_bzw_Meta-Paradigmen_bzw_Transzendentalien_(15),Geist_(15),Model_of_Hierarchical_Complexity,Biologischer_Baum_(15),Teilchen_anderes_Universum,nachvollziehen_emotional_oder_geistig_durch_Primzahl-Kreuz-Algorithmus_(15)",
            "6",
            has_reciprocal,
            reciprocal_base,
            "--grundstrukturen=Strukturalien_bzw_Meta-Paradigmen_bzw_Transzendentalien_(15),Geist_(15),Model_of_Hierarchical_Complexity,Biologischer_Baum_(15),Teilchen_anderes_Universum,nachvollziehen_emotional_oder_geistig_durch_Primzahl-Kreuz-Algorithmus_(15)",
            "7",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "geist") or _contains(canonical_words, "G"):
        _add_axis_family(
            invocations,
            has_integer,
            integer_base,
            "--grundstrukturen=geist",
            "3",
            has_reciprocal,
            reciprocal_base,
            "--grundstrukturen=geist",
            "4",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "freiheit") or _contains(
        canonical_words, "gleichheit"
    ):
        _add_axis_family(
            invocations,
            has_integer,
            integer_base,
            "--planet=freiheit",
            "1-4,8",
            has_reciprocal,
            reciprocal_base,
            "--planet=freiheit",
            "5-7",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "groesse"):
        _add_axis_family(
            invocations,
            has_integer,
            integer_base,
            "--strukturgroesse=organisation",
            "1-3",
            has_reciprocal,
            reciprocal_base,
            "--strukturgroesse=organisation",
            "99",
            suppress_empty,
            passthrough,
        )
        _add_axis_family(
            invocations,
            has_integer,
            integer_base,
            "--strukturgroesse=groesse",
            "1,2",
            has_reciprocal,
            reciprocal_base,
            "--strukturgroesse=groesse",
            "4",
            suppress_empty,
            passthrough,
        )
        _append_fraction_invocations(
            invocations,
            fraction_pairs,
            language,
            counting,
            invert,
            "--gebrochen-rational_Strukturgroesse_n/m=",
            "2",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "kugeln") or _contains(
        canonical_words, "kreise"
    ):
        _add_axis_family(
            invocations,
            has_integer,
            integer_base,
            "--universum=kreise",
            "1-2",
            has_reciprocal,
            reciprocal_base,
            "--universum=kreise",
            "99",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "netzwerk"):
        _add_axis_family(
            invocations,
            has_integer,
            integer_base,
            "--universum=netzwerk",
            "1-3",
            has_reciprocal,
            reciprocal_base,
            "--universum=netzwerk",
            "99",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "komplex"):
        _add_axis_family(
            invocations,
            has_integer,
            integer_base,
            "--universum=komplex",
            "1",
            has_reciprocal,
            reciprocal_base,
            "--universum=komplex",
            "3",
            suppress_empty,
            passthrough,
        )
    if not zero_default_mode and _contains_any(
        canonical_words, ["absicht", "absichten", "motiv", "motive", "a"]
    ):
        _add_axis_family(
            invocations,
            has_integer,
            integer_base,
            "--menschliches=motive",
            "1",
            has_reciprocal,
            reciprocal_base,
            "--menschliches=motive",
            "3",
            suppress_empty,
            passthrough,
        )
        _append_fraction_invocations(
            invocations,
            fraction_pairs,
            language,
            counting,
            invert,
            "--gebrochen-rational_Galaxie_n/m=",
            "2",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "universum") or _contains(
        canonical_words, "u"
    ):
        var universe_columns = "1"
        var reciprocal_universe_columns = "1"
        if (
            len(distinct_table_commands) <= 2
            and not _contains(canonical_words, "e")
            and not _contains(canonical_words, "ee")
            and not suppress_empty
            and not _has_no_headings_parameter(words, language, catalog)
        ):
            universe_columns = "1,4"
            reciprocal_universe_columns = "1,2"
        _add_axis_family(
            invocations,
            has_integer,
            integer_base,
            "--universum=transzendentalien",
            universe_columns,
            has_reciprocal,
            reciprocal_base,
            "--universum=transzendentaliereziproke",
            reciprocal_universe_columns,
            suppress_empty,
            passthrough,
        )
        _append_fraction_invocations(
            invocations,
            fraction_pairs,
            language,
            counting,
            invert,
            "--gebrochen-rational_Universum_n/m=",
            "2",
            suppress_empty,
            passthrough,
        )
        _append_universe_equal_axis(
            invocations,
            fraction_pairs,
            language,
            counting,
            invert,
            suppress_empty,
            passthrough,
        )

    # The legacy execution order is Multiversum (16) before Grundstrukturen
    # (15), independent of the source-token order.  Values inside each family
    # retain the CPython set order supplied by prompt preparation.
    if len(numeric16_values) > 0 and has_integer:
        _add_invocation(
            invocations,
            integer_base,
            "--"
            + _numeric_parameter_name(language, "16")
            + "="
            + _join_rows(numeric16_values),
            "",
            suppress_empty,
            passthrough,
            True,
        )
    if len(numeric15_values) > 0 and has_integer:
        _add_invocation(
            invocations,
            integer_base,
            "--"
            + _numeric_parameter_name(language, "15")
            + "="
            + _join_rows(numeric15_values),
            "",
            suppress_empty,
            passthrough,
            True,
        )

    return PromptTablePlan(
        len(invocations) > 0 or (has_fraction and not has_positive_fraction),
        invocations^,
    )


def serialize_prompt_table_plan(plan: PromptTablePlan) -> String:
    if not plan.handled:
        return "FALLBACK"
    var result = String()
    for invocation_index in range(len(plan.invocations)):
        if invocation_index > 0:
            result += "\x1e"
        var tokens = plan.invocations[invocation_index].tokens.copy()
        for token_index in range(len(tokens)):
            if token_index > 0:
                result += "\x1f"
            result += tokens[token_index]
    return result^
