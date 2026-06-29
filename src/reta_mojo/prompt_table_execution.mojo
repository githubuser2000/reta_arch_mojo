"""Native planning for integer prompt commands backed by the reta table core.

The historical ``PromptGrosseAusgabe`` function mixes prompt parsing, i18n,
row planning and table execution in one large Python branch.  This module owns
the pure integer ``n`` path for a coherent family of commands.  Fractional
``1/n`` and ambiguous multiple/divisor combinations deliberately remain at the
compatibility boundary until their complete multi-invocation semantics is
ported.
"""

from std.collections import List
from .prompt_language import PromptLanguageCatalog, normalize_prompt_language
from .row_ranges import range_to_numbers


@fieldwise_init
struct PromptTableInvocation(Copyable):
    var tokens: List[String]


@fieldwise_init
struct PromptTablePlan(Copyable):
    var handled: Bool
    var invocations: List[PromptTableInvocation]


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


def _is_unsupported_integer_modifier(canonical: String) -> Bool:
    # These modifiers alter the row expression in ways that depend on the full
    # fraction/divisor management branch.  Falling back is safer than silently
    # approximating it.
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


def _contains(values: List[String], needle: String) -> Bool:
    for index in range(len(values)):
        if values[index] == needle:
            return True
    return False


def _contains_any(values: List[String], candidates: List[String]) -> Bool:
    for index in range(len(candidates)):
        if _contains(values, candidates[index]):
            return True
    return False


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


def plan_prompt_table_commands(
    words: List[String],
    language: String,
    catalog: PromptLanguageCatalog,
) raises -> PromptTablePlan:
    """Translate supported integer prompt commands into native reta argv.

    Multiple supported domain commands on one line produce multiple table
    invocations, matching the historical independent ``if`` branches.
    """
    var canonical_words = List[String]()
    var row_parts = List[String]()
    var passthrough = List[String]()
    var maximum = 0
    var unsupported = False

    for index in range(len(words)):
        var token = words[index]
        var canonical = _canonical_command(catalog, language, token)
        canonical_words.append(canonical)
        if _is_unsupported_integer_modifier(
            canonical
        ) or _is_fraction_expression(token):
            unsupported = True
        if token.startswith("-"):
            passthrough.append(token)
            continue
        if _is_table_command(canonical) or _is_control_command(canonical):
            continue
        try:
            var values = range_to_numbers(token, False, 0)
            if len(values) > 0:
                row_parts.append(token)
                for value in values:
                    maximum = max(maximum, value)
        except:
            pass

    if unsupported or len(row_parts) == 0:
        return PromptTablePlan(False, List[PromptTableInvocation]())

    var has_table_command = False
    for index in range(len(canonical_words)):
        if _is_table_command(canonical_words[index]):
            has_table_command = True
            break
    if not has_table_command:
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
    var base = _base_table_tokens(
        language,
        _join_rows(row_parts),
        maximum,
        counting,
        invert,
    )
    var invocations = List[PromptTableInvocation]()

    if _contains(canonical_words, "mond"):
        _add_invocation(
            invocations,
            base,
            "--Bedeutung=gestirn",
            "3-6",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "richtung") or _contains(
        canonical_words, "r"
    ):
        _add_invocation(
            invocations,
            base,
            "--Primzahlwirkung=Galaxieabsicht",
            "",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "primzahlkreuz"):
        _add_invocation(
            invocations,
            base,
            "--Bedeutung=primzahlkreuz",
            "",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "alles"):
        _add_invocation(
            invocations, base, "--alles", "", suppress_empty, passthrough
        )
    if _contains(canonical_words, "thomas") or _contains(canonical_words, "t"):
        _add_invocation(
            invocations,
            base,
            "--galaxie=thomas",
            "2",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "emotion") or _contains(canonical_words, "E"):
        _add_invocation(
            invocations,
            base,
            "--grundstrukturen=emotion",
            "2,3",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "wirklichkeit") or _contains(
        canonical_words, "W"
    ):
        _add_invocation(
            invocations,
            base,
            "--grundstrukturen=Wirklichkeiten_Wahrheit_Wahrnehmung_(10)",
            "1,2",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "triebe") or _contains(canonical_words, "T"):
        _add_invocation(
            invocations,
            base,
            "--grundstrukturen=trieb,System",
            "1",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "impulse") or _contains(canonical_words, "I"):
        _add_invocation(
            invocations,
            base,
            "--grundstrukturen=Impulse_(5)",
            "1,4",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "bewusstsein") or _contains(
        canonical_words, "B"
    ):
        _add_invocation(
            invocations,
            base,
            "--grundstrukturen=Strukturalien_bzw_Meta-Paradigmen_bzw_Transzendentalien_(15),Geist_(15),Model_of_Hierarchical_Complexity,Biologischer_Baum_(15),Teilchen_anderes_Universum,nachvollziehen_emotional_oder_geistig_durch_Primzahl-Kreuz-Algorithmus_(15)",
            "6",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "geist") or _contains(canonical_words, "G"):
        _add_invocation(
            invocations,
            base,
            "--grundstrukturen=geist",
            "3",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "freiheit") or _contains(
        canonical_words, "gleichheit"
    ):
        _add_invocation(
            invocations,
            base,
            "--planet=freiheit",
            "1-4,8",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "groesse"):
        _add_invocation(
            invocations,
            base,
            "--strukturgroesse=organisation",
            "1-3",
            suppress_empty,
            passthrough,
        )
        _add_invocation(
            invocations,
            base,
            "--strukturgroesse=groesse",
            "1,2",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "kugeln") or _contains(
        canonical_words, "kreise"
    ):
        _add_invocation(
            invocations,
            base,
            "--universum=kreise",
            "1-2",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "netzwerk"):
        _add_invocation(
            invocations,
            base,
            "--universum=netzwerk",
            "1-3",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "komplex"):
        _add_invocation(
            invocations,
            base,
            "--universum=komplex",
            "1",
            suppress_empty,
            passthrough,
        )
    if _contains_any(
        canonical_words, ["absicht", "absichten", "motiv", "motive", "a"]
    ):
        _add_invocation(
            invocations,
            base,
            "--menschliches=motive",
            "1",
            suppress_empty,
            passthrough,
        )
    if _contains(canonical_words, "universum") or _contains(
        canonical_words, "u"
    ):
        var universe_columns = "1"
        if (
            len(distinct_table_commands) <= 2
            and not _contains(canonical_words, "e")
            and not _contains(canonical_words, "ee")
            and not suppress_empty
            and not _has_no_headings_parameter(words, language, catalog)
        ):
            universe_columns = "1,4"
        _add_invocation(
            invocations,
            base,
            "--universum=transzendentalien",
            universe_columns,
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
