"""Native planning for prompt commands backed by the reta table core.

This module owns the integer ``n`` path, integer multiple/divisor modifiers,
combined integer divisor/multiple algebra, positive rational ``n/m`` expressions,
stable exclusion forms, reciprocal multiple expansion and fraction/divisor
combinations.  The historical Python function mixes parsing, i18n, range algebra
and table execution; here these concerns are split into typed planning stages.
True ``v n/m`` expansion deliberately corrects a Python-reference crash: the
numerator and denominator axes are expanded independently, but only inside the
real rectangular shape of the selected fraction CSV domain.
"""

from std.collections import List
from .prime_cross_columns import (
    python_divisor_set_order,
    python_int_set_order,
    python_signed_int_set_order,
)
from .prompt_fraction_execution import (
    create_prompt_fraction_range,
    parse_prompt_fraction,
)
from .prompt_historical_ownership import (
    is_classic_integer_prompt_table_family,
    is_fraction_prompt_table_family,
    is_historical_prompt_table_family,
)
from .prompt_language import (
    PromptLanguageCatalog,
    normalize_prompt_language,
    python_string_set_order,
)
from .prompt_property_execution import plan_prompt_property_commands
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
struct _FractionMultipleDomain(Copyable):
    var supported: Bool
    var maximum_numerator: Int
    var maximum_denominator: Int


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
        return (
            "Grundstrukturen" if normalized == "deutsch" else "basic_structures"
        )
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
    return is_historical_prompt_table_family(canonical)


def _only_classic_integer_table_commands(words: List[String]) -> Bool:
    """Return true when every selected table family ignores proper fractions."""
    var found = False
    for index in range(len(words)):
        var canonical = words[index]
        if not _is_table_command(canonical):
            continue
        if not is_classic_integer_prompt_table_family(canonical):
            return False
        found = True
    return found


def _is_fraction_table_command(canonical: String) -> Bool:
    return is_fraction_prompt_table_family(canonical)


def _contains(values: List[String], needle: String) -> Bool:
    for index in range(len(values)):
        if values[index] == needle:
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


def _base_multiple_divisor_tokens(
    language: String,
    row_parts: List[String],
    divisor_rows: List[String],
    counting: Bool,
    invert: Bool,
) -> List[String]:
    """Compose the stable legacy ``vielfache`` + ``teiler`` integer path.

    Python first expands the positive integer inputs into their divisors, keeps
    the original raw row components a second time, and finally appends the
    ``vN`` selectors for the original inputs.  Unlike the pure multiples path,
    the legacy mixed path deliberately omits ``--vielfachevonzahlen``: that option
    would intersect the union and remove the added divisors.  The serialized row
    order therefore matches the historical prompt command exactly.
    """
    var result = List[String]()
    var normalized = normalize_prompt_language(language)
    if normalized != "deutsch":
        result.append("-language=" + normalized)
    var selected = _copy_strings(divisor_rows)
    for index in range(len(row_parts)):
        selected.append("v" + row_parts[index])
    result.append("-zeilen")
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
    invocations.append(PromptTableInvocation(tokens^, command_echo_newline))


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


def _has_positive_true_fraction(pairs: List[_PromptFractionPair]) -> Bool:
    for index in range(len(pairs)):
        var pair = pairs[index].copy()
        if not pair.excluded and pair.numerator != 1:
            return True
    return False


def _positive_reciprocal_multiple_with_excluded_true_fractions(
    pairs: List[_PromptFractionPair],
) -> Bool:
    """Recognize the stable positive-first reciprocal-only legacy branch.

    A leading ``v1/n`` followed only by excluded proper fractions does not
    create proper-fraction CSV invocations in the Python reference.  It keeps
    exactly the bounded reciprocal-multiple axis.  Excluded reciprocals and
    any positive proper fraction remain outside this deliberately narrow
    contract because they reach different output or defect branches.
    """
    var has_positive_reciprocal_multiple = False
    var has_excluded_true_fraction = False
    for index in range(len(pairs)):
        var pair = pairs[index].copy()
        if pair.excluded:
            if pair.numerator == 1:
                return False
            has_excluded_true_fraction = True
        else:
            if pair.numerator != 1 or not pair.multiple:
                return False
            has_positive_reciprocal_multiple = True
    return has_positive_reciprocal_multiple and has_excluded_true_fraction


def _positive_first_reciprocal_collision_with_true_fraction(
    pairs: List[_PromptFractionPair],
) -> Bool:
    """Recognize one proven positive-first reciprocal subtraction class.

    ``v1/a,-1/b,c/d`` (with c > 1) is decomposed into an independently
    bounded reciprocal axis and one proper-fraction CSV rectangle.  The frozen
    Python reference crashes while indexing this combination, but both native
    projections are already deterministic.  Excluded proper fractions, a
    non-reciprocal first component, or more than one positive reciprocal remain
    outside this deliberately narrow correction contract.
    """
    if len(pairs) < 3:
        return False
    var first = pairs[0].copy()
    if first.excluded or first.numerator != 1 or not first.multiple:
        return False
    var positive_reciprocals = 0
    var excluded_reciprocals = 0
    var positive_true_fractions = 0
    for index in range(len(pairs)):
        var pair = pairs[index].copy()
        if not pair.multiple:
            return False
        if pair.numerator == 1:
            if pair.excluded:
                excluded_reciprocals += 1
            else:
                positive_reciprocals += 1
        else:
            if pair.excluded:
                return False
            positive_true_fractions += 1
    return (
        positive_reciprocals == 1
        and excluded_reciprocals > 0
        and positive_true_fractions > 0
    )


def _fraction_pairs_for_axis(
    pairs: List[_PromptFractionPair], reciprocal: Bool
) -> List[_PromptFractionPair]:
    var result = List[_PromptFractionPair]()
    for index in range(len(pairs)):
        var pair = pairs[index].copy()
        if reciprocal and pair.numerator == 1:
            result.append(pair.copy())
        elif not reciprocal and pair.numerator != 1:
            result.append(pair.copy())
    return result^


def _fraction_multiple_mode(pairs: List[_PromptFractionPair]) -> Bool:
    for index in range(len(pairs)):
        if pairs[index].multiple:
            return True
    return False


def _has_true_fraction(pairs: List[_PromptFractionPair]) -> Bool:
    for index in range(len(pairs)):
        if pairs[index].numerator != 1:
            return True
    return False


def _fraction_multiple_is_reference_empty(
    pairs: List[_PromptFractionPair], multiple_mode: Bool
) -> Bool:
    """Recognize the reference's order-sensitive negative-first no-op branch.

    Once a true n/m fraction is present, the historical prompt emits no reta
    invocation when the first parsed multiple component is excluded.  The same
    components in positive-first order can instead produce output or reach the
    documented IndexError branch, so this contract deliberately preserves the
    parsed pair order rather than reducing it to unordered sign sets.
    """
    return (
        multiple_mode
        and _has_true_fraction(pairs)
        and len(pairs) > 0
        and pairs[0].excluded
    )


def _fraction_multiple_domain(
    canonical_words: List[String],
) -> _FractionMultipleDomain:
    """Return the single real CSV rectangle selected by a true n/m prompt.

    Fraction CSV columns start at numerator 2.  Consequently seven physical
    emotion columns represent numerators 2..8, while nineteen Universe columns
    represent 2..20.  Rows are denominator coordinates starting at one.
    Owning several fraction domains at once would require different expansions
    for the same prompt pair, so that still falls back atomically.
    """
    var count = 0
    var maximum_numerator = 0
    var maximum_denominator = 0
    if _contains(canonical_words, "emotion") or _contains(canonical_words, "E"):
        count += 1
        maximum_numerator = 8
        maximum_denominator = 7
    if _contains(canonical_words, "groesse"):
        count += 1
        maximum_numerator = 17
        maximum_denominator = 16
    if _contains_any(
        canonical_words, ["absicht", "absichten", "motiv", "motive", "a"]
    ):
        count += 1
        maximum_numerator = 22
        maximum_denominator = 21
    if _contains(canonical_words, "universum") or _contains(canonical_words, "u"):
        count += 1
        maximum_numerator = 20
        maximum_denominator = 21
    return _FractionMultipleDomain(
        count == 1, maximum_numerator, maximum_denominator
    )


def _fraction_multiple_supported(
    pairs: List[_PromptFractionPair],
    canonical_words: List[String],
    multiple_mode: Bool,
) -> Bool:
    if not multiple_mode or not _has_true_fraction(pairs):
        return True
    var domain = _fraction_multiple_domain(canonical_words)
    if not domain.supported:
        return False
    if _positive_reciprocal_multiple_with_excluded_true_fractions(pairs):
        return True
    if _positive_first_reciprocal_collision_with_true_fraction(pairs):
        return True
    if not _has_positive_true_fraction(pairs):
        return False
    # Reciprocal 1/n multiples and true n/m multiples deliberately use different
    # bounds.  They are split below: reciprocal rows use the historical 1024
    # ceiling, while proper fractions expand only inside this domain rectangle.
    # Negative reciprocal components retain their frozen Python behavior until
    # their subtraction algebra receives a separate explicit contract.
    for index in range(len(pairs)):
        var pair = pairs[index].copy()
        if pair.numerator == 1 and pair.excluded:
            return False
    return True


def _copy_fraction_pairs(
    pairs: List[_PromptFractionPair],
) -> List[_PromptFractionPair]:
    var result = List[_PromptFractionPair]()
    for index in range(len(pairs)):
        result.append(pairs[index].copy())
    return result^


def _expand_true_fraction_multiples(
    pairs: List[_PromptFractionPair], domain: _FractionMultipleDomain
) -> List[_PromptFractionPair]:
    """Expand both axes independently and clip to the physical CSV rectangle."""
    var result = List[_PromptFractionPair]()
    for index in range(len(pairs)):
        var pair = pairs[index].copy()
        var numerator = pair.numerator
        while numerator <= domain.maximum_numerator:
            var denominator = pair.denominator
            while denominator <= domain.maximum_denominator:
                _append_unique_fraction_pair(
                    result,
                    numerator,
                    denominator,
                    pair.excluded,
                    False,
                )
                denominator += pair.denominator
            numerator += pair.numerator
    return result^


def _fraction_exclusions_supported(
    pairs: List[_PromptFractionPair], multiple_mode: Bool
) -> Bool:
    # Row polarity cancellation and empty-positive selectors are represented
    # by the native CLI planner.  All parsed exclusion combinations are now
    # safe here; true n/m multiple expansion is guarded separately.
    return True


def _merge_expanded_reciprocal_multiple_rows(
    seed_rows: List[String],
    pairs: List[_PromptFractionPair],
    upper_exclusive: Int,
) raises -> List[String]:
    """Merge a bounded 1/n-multiple axis into existing reciprocal projections."""
    var attempts = List[Int]()
    var exclusions = List[Int]()
    for index in range(len(seed_rows)):
        if seed_rows[index].byte_length() > 0:
            attempts.append(Int(seed_rows[index]))
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


def _expanded_reciprocal_multiple_rows(
    pairs: List[_PromptFractionPair], upper_exclusive: Int
) raises -> List[String]:
    return _merge_expanded_reciprocal_multiple_rows(
        List[String](), pairs, upper_exclusive
    )


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
                    ("-" if other.excluded else "") + String(other.denominator)
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
    var has_property_command = False
    var has_fraction = False
    var saw_ignored_negative_integer = False
    var saw_integer_component_exclusion = False

    for index in range(len(words)):
        var token = words[index]
        if token.startswith("EIGN") and token.byte_length() > 4:
            has_property_command = True
            canonical_words.append("__property_n")
            continue
        if token.startswith("EIGR") and token.byte_length() > 4:
            has_property_command = True
            canonical_words.append("__property_r")
            continue
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
            var mixed_integer_parts = List[String]()
            var mixed_parts = split_top_level_commas(token)
            for mixed_index in range(len(mixed_parts)):
                var mixed_part = String(mixed_parts[mixed_index])
                if mixed_part.byte_length() == 0:
                    unsupported = True
                    continue
                if _is_fraction_expression(mixed_part):
                    if not _parse_fraction_token(mixed_part, fraction_pairs):
                        unsupported = True
                else:
                    mixed_integer_parts.append(mixed_part)

            # The reference accepts a fraction and ordinary row selectors in
            # one comma token (for example ``mond 1/2,3``).  Fractions feed the
            # rational axes while the integer components retain the ordinary
            # set/subtraction algebra and source-component order.
            if len(mixed_integer_parts) > 0:
                var integer_expression = _join_rows(mixed_integer_parts)
                try:
                    if not is_row_range(integer_expression):
                        unsupported = True
                    else:
                        for mixed_index in range(len(mixed_integer_parts)):
                            var part = mixed_integer_parts[mixed_index]
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
                        var values = range_to_numbers(
                            integer_expression, False, 0
                        )
                        for value in values:
                            row_values.append(value)
                            maximum = max(maximum, value)
                except:
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
        len(numeric15_values) > 0
        or len(numeric16_values) > 0
        or has_property_command
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
    # Integer inputs have a stable combined legacy contract: divisors are
    # selected first and the original values are then expanded as multiples.
    # Reciprocal ``1/n`` multiples are stable up to row 1023.  True ``v n/m``
    # instead uses the physical rectangle of exactly one selected fraction CSV.
    # Negative-first true-fraction historical branches are observable no-ops
    # rather than fallbacks: prompt_main retains the compact announcement,
    # while the typed plan deliberately contains no reta invocation.
    if has_fraction and _fraction_multiple_is_reference_empty(
        fraction_pairs, multiple_mode
    ):
        return PromptTablePlan(True, List[PromptTableInvocation]())
    if (
        has_fraction
        and multiple_mode
        and not _fraction_multiple_supported(
            fraction_pairs, canonical_words, multiple_mode
        )
    ):
        unsupported = True
    if has_fraction and not _fraction_exclusions_supported(
        fraction_pairs, multiple_mode
    ):
        unsupported = True
    # Repeated catalog aliases remain in the echoed command, but both Python
    # and the native generated-column registry deduplicate their semantic
    # column request.  They therefore no longer require an atomic fallback.
    if unsupported:
        return PromptTablePlan(False, List[PromptTableInvocation]())

    var true_fraction_multiple_mode = (
        has_fraction and multiple_mode and _has_true_fraction(fraction_pairs)
    )
    var reciprocal_multiple_pairs = _fraction_pairs_for_axis(
        fraction_pairs, True
    )
    var true_fraction_pairs = _fraction_pairs_for_axis(fraction_pairs, False)
    var effective_fraction_pairs = _copy_fraction_pairs(fraction_pairs)
    if true_fraction_multiple_mode:
        effective_fraction_pairs = _expand_true_fraction_multiples(
            true_fraction_pairs, _fraction_multiple_domain(canonical_words)
        )

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
    var has_positive_fraction = _has_positive_fraction(effective_fraction_pairs)
    for index in range(len(effective_fraction_pairs)):
        var pair = effective_fraction_pairs[index].copy()
        if pair.excluded:
            continue
        var exact_exclusion = _has_matching_exclusion(
            effective_fraction_pairs, pair
        )
        # Exact literal n/m cancellation is represented on that numerator's
        # proper-fraction axis.  Only 1/n has no such axis, so its reciprocal
        # promotion must remain and cancel there instead.
        if not exact_exclusion and pair.numerator % pair.denominator == 0:
            _append_unique_string(
                whole_rows, String(pair.numerator // pair.denominator)
            )
        if (
            not exact_exclusion or pair.numerator == 1
        ) and pair.denominator % pair.numerator == 0:
            _append_unique_string(
                reciprocal_rows, String(pair.denominator // pair.numerator)
            )

    if multiple_mode and has_fraction and not true_fraction_multiple_mode:
        reciprocal_rows = _expanded_reciprocal_multiple_rows(
            fraction_pairs, 1024
        )
    elif (
        multiple_mode
        and true_fraction_multiple_mode
        and len(reciprocal_multiple_pairs) > 0
    ):
        reciprocal_rows = _merge_expanded_reciprocal_multiple_rows(
            reciprocal_rows, reciprocal_multiple_pairs, 1024
        )
    elif has_positive_fraction:
        # Legacy subtraction only promotes explicit -1/n axes into the
        # reciprocal row selection.  Equivalent forms such as -2/4 stay in
        # their proper-fraction numerator group.
        var reciprocal_attempts = List[Int]()
        for index in range(len(reciprocal_rows)):
            reciprocal_attempts.append(Int(reciprocal_rows[index]))
        for index in range(len(effective_fraction_pairs)):
            var pair = effective_fraction_pairs[index].copy()
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

    # A divisor request containing only positive literal 1/n fractions carries
    # an empty integer-side component into the historical reciprocal selector.
    # It is observable as a trailing comma ("2," or "2,3,") even though the
    # selected row set is unchanged.  Mixed proper fractions or exclusions do
    # not retain that empty component.
    if divisor_mode and not multiple_mode and len(effective_fraction_pairs) > 0:
        var pure_positive_reciprocals = True
        for pair_index in range(len(effective_fraction_pairs)):
            var pair = effective_fraction_pairs[pair_index].copy()
            if pair.excluded or pair.numerator != 1:
                pure_positive_reciprocals = False
        if pure_positive_reciprocals and len(reciprocal_rows) > 0:
            reciprocal_rows.append("")

    var normal_rows = _copy_strings(row_parts)
    for index in range(len(whole_rows)):
        normal_rows.append(whole_rows[index])
        maximum = max(maximum, Int(whole_rows[index]))

    if divisor_mode and not zero_default_mode:
        var divisor_rows = List[String]()
        var resolved_divisor_values = List[Int]()
        for value_index in range(len(row_values)):
            if not _contains_int(excluded_row_values, row_values[value_index]):
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
        var ordered_divisors = python_divisor_set_order(resolved_divisor_values)
        for divisor_index in range(len(ordered_divisors)):
            divisor_rows.append(String(ordered_divisors[divisor_index]))

        # A pure zero selector contributes no teiler invocation at all.  Zero
        # is retained only alongside a real positive value or an exclusion,
        # exactly as in the reference prompt's raw component set.
        if len(resolved_divisor_values) > 0 or saw_integer_component_exclusion:
            for index in range(len(row_parts)):
                divisor_rows.append(row_parts[index])
        # Reduced n/m integers are added after the historical w/teiler
        # expansion and are not themselves expanded into their divisors.
        for index in range(len(whole_rows)):
            divisor_rows.append(whole_rows[index])
        normal_rows = divisor_rows^

    var has_integer = len(normal_rows) > 0
    var has_reciprocal = len(reciprocal_rows) > 0
    if (
        not has_integer
        and not has_reciprocal
        and len(effective_fraction_pairs) == 0
    ):
        if (
            len(numeric15_values) > 0
            or len(numeric16_values) > 0
            or has_property_command
            or saw_ignored_negative_integer
            or (divisor_mode and len(row_parts) > 0)
        ):
            return PromptTablePlan(True, List[PromptTableInvocation]())
        return PromptTablePlan(False, List[PromptTableInvocation]())

    # Python chooses the wider Universe column pair only when at most two
    # recognized prompt commands are present.  This count includes modifiers,
    # not merely table families.  A compact ``v1/n`` token is normalized by the
    # legacy preparation layer into the semantic ``vielfache`` command, so add
    # one implicit command when the native fraction parser observed that prefix.
    var distinct_prompt_commands = List[String]()
    for index in range(len(canonical_words)):
        var canonical = canonical_words[index]
        if (
            _is_table_command(canonical) or _is_control_command(canonical)
        ) and not _contains(distinct_prompt_commands, canonical):
            distinct_prompt_commands.append(canonical)
    if (
        _fraction_multiple_mode(fraction_pairs)
        and not _contains(canonical_words, "vielfache")
        and not _contains(canonical_words, "v")
    ):
        distinct_prompt_commands.append("__fraction_multiple")

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
        elif true_fraction_multiple_mode:
            # The expanded whole-number projections are already materialized;
            # feeding them into --vielfachevonzahlen would expand them a second
            # time and no longer describe the corrected fraction-grid contract.
            integer_base = _base_table_tokens(
                language,
                _join_rows(normal_rows),
                maximum,
                counting,
                invert,
            )
        elif multiple_mode and divisor_mode:
            integer_base = _base_multiple_divisor_tokens(
                language, row_parts, normal_rows, counting, invert
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
        # Reciprocal axes already carry their fully materialized row selector.
        # In particular, ``vielfache 1/n`` enumerates every matching row below
        # 1024, so the Python prompt emits no separate maximum token.
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
        _contains(canonical_words, "thomas") or _contains(canonical_words, "t")
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
            effective_fraction_pairs,
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
            effective_fraction_pairs,
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
            effective_fraction_pairs,
            language,
            counting,
            invert,
            "--gebrochen-rational_Galaxie_n/m=",
            "2",
            suppress_empty,
            passthrough,
        )
    if has_property_command:
        var property_plan = plan_prompt_property_commands(
            words,
            language,
            has_integer,
            integer_base,
            has_reciprocal,
            reciprocal_base,
            counting,
            invert,
            suppress_empty,
            passthrough,
        )
        for property_index in range(len(property_plan.invocations)):
            var property_invocation = property_plan.invocations[
                property_index
            ].copy()
            invocations.append(
                PromptTableInvocation(
                    _copy_strings(property_invocation.tokens),
                    False,
                )
            )

    if _contains(canonical_words, "universum") or _contains(
        canonical_words, "u"
    ):
        var universe_columns = "1"
        var reciprocal_universe_columns = "1"
        if (
            len(distinct_prompt_commands) <= 2
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
            "--Universum=transzendentalien",
            universe_columns,
            has_reciprocal,
            reciprocal_base,
            "--Universum=transzendentaliereziproke",
            reciprocal_universe_columns,
            suppress_empty,
            passthrough,
        )
        _append_fraction_invocations(
            invocations,
            effective_fraction_pairs,
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
            effective_fraction_pairs,
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

    var classic_fraction_noop = (
        has_fraction
        and has_positive_fraction
        and len(invocations) == 0
        and len(numeric15_values) == 0
        and len(numeric16_values) == 0
        and not has_property_command
        and _only_classic_integer_table_commands(canonical_words)
    )
    return PromptTablePlan(
        len(invocations) > 0
        or (has_fraction and not has_positive_fraction)
        or has_property_command
        or classic_fraction_noop,
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
