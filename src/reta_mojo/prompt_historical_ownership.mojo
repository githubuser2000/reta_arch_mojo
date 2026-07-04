"""Pure ownership predicate for historical compact prompt table commands.

The large prompt controller expands one-character commands before planning
native table invocations.  This module decides whether every expanded token is
owned by the typed planner.  It contains no terminal, filesystem, environment
or child-process effects, so the decision can be compiled and tested without
instantiating an external boundary.
"""

from std.collections import List
from .prompt_language import PromptLanguageCatalog, normalize_prompt_language


def is_prompt_numeric_syntax_token(value: String) -> Bool:
    """Return whether a token consists only of historical numeric syntax."""
    if value.byte_length() == 0:
        return False
    var bytes = value.as_bytes()
    for index in range(len(bytes)):
        var code = Int(bytes[index])
        if code >= 48 and code <= 57:
            continue
        if (
            code == 32
            or code == 9
            or code == 43
            or code == 44
            or code == 45
            or code == 46
            or code == 47
            or code == 58
            or code == 59
            or code == 91
            or code == 93
            or code == 40
            or code == 41
            or code == 123
            or code == 125
        ):
            continue
        return False
    return True


def historical_prompt_table_families() -> List[String]:
    """Return every canonical table word accepted by the native planner.

    Short canonical spellings remain explicit because the generated catalog
    preserves them as independent historical prompt tokens.
    """
    return [
        "mond",
        "richtung",
        "r",
        "primzahlkreuz",
        "alles",
        "thomas",
        "t",
        "emotion",
        "E",
        "wirklichkeit",
        "W",
        "triebe",
        "T",
        "impulse",
        "I",
        "bewusstsein",
        "B",
        "geist",
        "G",
        "freiheit",
        "gleichheit",
        "groesse",
        "kugeln",
        "kreise",
        "netzwerk",
        "komplex",
        "absicht",
        "absichten",
        "motiv",
        "motive",
        "a",
        "universum",
        "u",
    ]


def _contains_string(values: List[String], needle: String) -> Bool:
    for index in range(len(values)):
        if values[index] == needle:
            return True
    return False


def is_historical_prompt_table_family(canonical: String) -> Bool:
    return _contains_string(historical_prompt_table_families(), canonical)


def is_classic_integer_prompt_table_family(canonical: String) -> Bool:
    return (
        canonical == "mond"
        or canonical == "richtung"
        or canonical == "r"
        or canonical == "primzahlkreuz"
        or canonical == "alles"
        or canonical == "thomas"
        or canonical == "t"
    )


def is_fraction_prompt_table_family(canonical: String) -> Bool:
    return (
        is_historical_prompt_table_family(canonical)
        and not is_classic_integer_prompt_table_family(canonical)
    )


def canonical_prompt_command(
    token: String, language: String, catalog: PromptLanguageCatalog
) -> String:
    """Resolve one localized command token to its generated canonical name."""
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


def historical_prompt_control_supported(canonical: String) -> Bool:
    return (
        canonical == "mulpri"
        or canonical == "p"
        or canonical == "range"
        or canonical == "R"
        or canonical == "invertieren"
        or canonical == "e"
        or canonical == "ee"
        or canonical == "vielfache"
        or canonical == "v"
        or canonical == "teiler"
        or canonical == "w"
        or canonical == "einzeln"
        or canonical
        == "keineEinZeichenZeilenPlusKeineAusgabeWelcherBefehlEsWar"
    )


def historical_prompt_parameter_supported(
    token: String, language: String, catalog: PromptLanguageCatalog
) -> Bool:
    if token == "-ausgabe" or token == "-output":
        return True
    if not token.startswith("--"):
        return False
    var name = String(token[byte=2:])
    if "=" in name:
        name = String(name.split("=")[0])
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.vocabulary)):
        var entry = catalog.vocabulary[index].copy()
        if (
            entry.language == normalized
            and entry.domain == "output"
            and entry.translated == name
        ):
            return (
                entry.canonical == "keineueberschriften"
                or entry.canonical == "keineleereninhalte"
                or entry.canonical == "keinenummerierung"
                or entry.canonical == "nocolor"
                or entry.canonical == "breite"
                or entry.canonical == "art"
                or entry.canonical == "spaltenreihenfolgeundnurdiese"
            )
    return False


def historical_prompt_execution_supported(
    raw_tokens: List[String],
    planning_tokens: List[String],
    language: String,
    catalog: PromptLanguageCatalog,
) -> Bool:
    """Prove that a historical compact compound is wholly native.

    The old controller treated domain words as an unordered set.  Partial
    execution is forbidden: every non-data token must be a supported output
    parameter, control word or table family before any native invocation may
    emit output.  All families returned by ``historical_prompt_table_families``
    are already implemented by ``prompt_table_execution.mojo``; the previous
    smaller allow-list was therefore an unnecessary fallback boundary.
    """
    _ = raw_tokens
    for index in range(len(planning_tokens)):
        var token = planning_tokens[index]
        if is_prompt_numeric_syntax_token(token):
            continue
        if historical_prompt_parameter_supported(token, language, catalog):
            continue
        var canonical = canonical_prompt_command(token, language, catalog)
        if historical_prompt_control_supported(canonical):
            continue
        if not is_historical_prompt_table_family(canonical):
            return False
    return True
