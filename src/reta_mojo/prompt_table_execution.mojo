"""Native planning for prompt commands backed by the reta table core.

This module owns the integer ``n`` path, integer multiple/divisor modifiers and
simple positive rational ``n/m`` expressions.  The historical Python function
mixes parsing, i18n, range algebra and table execution; here these concerns are
split into typed planning stages.  Ambiguous arithmetic fraction expressions
and fraction+multiple/divisor combinations deliberately remain at the
compatibility boundary until their complete legacy set algebra is ported.
"""

from std.collections import List
from .number_theory import divisors
from .prompt_fraction_execution import (
    create_prompt_fraction_range,
    parse_prompt_fraction,
)
from .prompt_language import PromptLanguageCatalog, normalize_prompt_language
from .row_ranges import range_to_numbers


@fieldwise_init
struct PromptTableInvocation(Copyable):
    var tokens: List[String]


@fieldwise_init
struct PromptTablePlan(Copyable):
    var handled: Bool
    var invocations: List[PromptTableInvocation]


@fieldwise_init
struct _PromptFractionPair(Copyable):
    var numerator: Int
    var denominator: Int


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
) -> None:
    var tokens = _copy_strings(base)
    _append_table_tail(
        tokens,
        column_option,
        selected_columns,
        suppress_empty,
        passthrough,
    )
    invocations.append(PromptTableInvocation(tokens^))


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
    mut pairs: List[_PromptFractionPair], numerator: Int, denominator: Int
) -> None:
    for index in range(len(pairs)):
        var pair = pairs[index].copy()
        if pair.numerator == numerator and pair.denominator == denominator:
            return
    pairs.append(_PromptFractionPair(numerator, denominator))


def _parse_direct_fraction_axes(
    part: String, mut pairs: List[_PromptFractionPair]
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
                _append_unique_fraction_pair(pairs, numerator, denominator)
    except:
        return False
    return True


def _parse_legacy_fraction_expression(
    part: String, mut pairs: List[_PromptFractionPair]
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
                _append_unique_fraction_pair(pairs, numerator, denominator)
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
        # Exclusion and fraction-multiple prefixes require the still-unported
        # subtraction algebra; never reinterpret them as positive ranges.
        if part.startswith("-") or part.startswith("v"):
            return False
        if _parse_direct_fraction_axes(part, pairs):
            continue
        if not _parse_legacy_fraction_expression(part, pairs):
            return False
    return True


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
        if pair.numerator != 1:
            _append_unique_int(numerators, pair.numerator)
    # The Python reference groups through frozenset-backed keys.  Its stable
    # observable order for positive prompt axes is ascending, including the
    # historical +offset syntax (for example 4/5+2/2 -> 2, 6).
    _sort_ints(numerators)
    for numerator_index in range(len(numerators)):
        var numerator = numerators[numerator_index]
        var denominator_rows = List[String]()
        for other_index in range(len(pairs)):
            var other = pairs[other_index].copy()
            if other.numerator == numerator:
                _append_unique_string(denominator_rows, String(other.denominator))
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
        if pair.numerator == pair.denominator and pair.numerator != 1:
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
    var row_parts = List[String]()
    var row_values = List[Int]()
    var fraction_pairs = List[_PromptFractionPair]()
    var passthrough = List[String]()
    var maximum = 0
    var unsupported = False
    var has_fraction = False

    for index in range(len(words)):
        var token = words[index]
        var canonical = _canonical_command(catalog, language, token)
        canonical_words.append(canonical)
        if token.startswith("-"):
            passthrough.append(token)
            continue
        if _is_table_command(canonical) or _is_control_command(canonical):
            continue
        if _is_fraction_expression(token):
            has_fraction = True
            if not _parse_fraction_token(token, fraction_pairs):
                unsupported = True
            continue
        try:
            var values = range_to_numbers(token, False, 0)
            if len(values) > 0:
                row_parts.append(token)
                for value in values:
                    row_values.append(value)
                    maximum = max(maximum, value)
        except:
            pass

    var has_table_command = False
    var has_non_fraction_table_command = False
    for index in range(len(canonical_words)):
        if _is_table_command(canonical_words[index]):
            has_table_command = True
            if not _is_fraction_table_command(canonical_words[index]):
                has_non_fraction_table_command = True
    if not has_table_command:
        return PromptTablePlan(False, List[PromptTableInvocation]())

    var multiple_mode = _contains(canonical_words, "vielfache") or _contains(
        canonical_words, "v"
    )
    var divisor_mode = _contains(canonical_words, "teiler") or _contains(
        canonical_words, "w"
    )
    var single_mode = _contains(canonical_words, "einzeln")
    if single_mode:
        multiple_mode = False
    if multiple_mode and divisor_mode:
        unsupported = True
    if has_fraction and (multiple_mode or divisor_mode or has_non_fraction_table_command):
        unsupported = True
    if unsupported:
        return PromptTablePlan(False, List[PromptTableInvocation]())

    var whole_rows = List[String]()
    var reciprocal_rows = List[String]()
    for index in range(len(fraction_pairs)):
        var pair = fraction_pairs[index].copy()
        if pair.numerator % pair.denominator == 0:
            _append_unique_string(
                whole_rows, String(pair.numerator // pair.denominator)
            )
        if pair.denominator % pair.numerator == 0:
            _append_unique_string(
                reciprocal_rows, String(pair.denominator // pair.numerator)
            )

    var normal_rows = _copy_strings(row_parts)
    for index in range(len(whole_rows)):
        normal_rows.append(whole_rows[index])
        maximum = max(maximum, Int(whole_rows[index]))

    if divisor_mode:
        var divisor_rows = List[String]()
        for value_index in range(len(row_values)):
            var values = divisors(row_values[value_index])
            for divisor_index in range(len(values)):
                if values[divisor_index] != 1:
                    divisor_rows.append(String(values[divisor_index]))
        for index in range(len(row_parts)):
            divisor_rows.append(row_parts[index])
        normal_rows = divisor_rows^

    var has_integer = len(normal_rows) > 0
    var has_reciprocal = len(reciprocal_rows) > 0
    if not has_integer and not has_reciprocal and len(fraction_pairs) == 0:
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
        if multiple_mode:
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
    if _contains_any(
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

    return PromptTablePlan(len(invocations) > 0, invocations^)


def serialize_prompt_table_plan(plan: PromptTablePlan) -> String:
    if not plan.handled:
        return "FALLBACK"
    var result = String()
    for invocation_index in range(len(plan.invocations)):
        if invocation_index > 0:
            result += "\x1e"
        var tokens = plan.invocations[invocation_index].tokens
        for token_index in range(len(tokens)):
            if token_index > 0:
                result += "\x1f"
            result += tokens[token_index]
    return result^
