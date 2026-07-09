"""Native owner for ``reta_architecture/prompt_preparation.py``.

The module owns the prompt morphism between raw interactive text and the
normalized token stream consumed by the native execution planner.  Immutable
parameter/value domains are generated from the Python reference; rotation,
compact expansion, row-range rewriting, regex/wildcard expansion and exit
planning execute in Mojo without Python callbacks.
"""

from std.collections import List
from std.collections.string import atol, ord
from .prompt_language import (
    PromptLanguageCatalog,
    balanced_prompt_split,
    normalize_prompt_language,
    prepare_prompt_tokens,
    python_string_set_order,
    prompt_vocabulary_alias,
)
from .prompt_preparation_catalog import (
    PromptPreparationCatalog,
    load_prompt_preparation_catalog,
)
from .prompt_regex import PromptRegexResult, regex_replace
from .prime_cross_columns import python_divisor_set_order
from .row_ranges import is_row_range, range_to_numbers

comptime PROMPT_MODE_NORMAL = 0
comptime PROMPT_MODE_SELECTIVE_OUTPUT = 6




@fieldwise_init
struct PromptRotationResult(Copyable):
    var text1: String
    var text2: String
    var text3: List[String]
    var rotated: Bool


@fieldwise_init
struct PromptPreparationResult(Copyable):
    var is_pure_reta_command: Bool
    var fractions: List[String]
    var numeric_argument_text: String
    var chains: List[String]
    var max_number: Int
    var tokens: List[String]
    var numeric_arguments: List[String]
    var compact: Bool
    var exit_requested: Bool


@fieldwise_init
struct PromptPreparationSnapshot(Copyable):
    var class_name: String
    var cached_parameter_value_domains: Int
    var exit_commands_len: Int
    var native_regex_engine: String


@fieldwise_init
struct PromptPreparationLegacySnapshot(Copyable, Equatable, Writable):
    """Observable snapshot of the historical Python facade.

    Python populated four mutable parameter/value caches lazily.  The native
    owner replaces them with one immutable generated catalog, so the legacy
    cache counters remain zero while the productive domain count is exposed by
    ``snapshot`` above.
    """

    var class_name: String
    var command_rotator: String
    var regex_rewriter: String
    var output_preparer: String
    var cached_zeilen: Int
    var cached_spalten: Int
    var cached_ausgabe: Int
    var cached_kombination: Int
    var beenden_commands_len: Int

    def __eq__(self, other: Self) -> Bool:
        return (
            self.class_name == other.class_name
            and self.command_rotator == other.command_rotator
            and self.regex_rewriter == other.regex_rewriter
            and self.output_preparer == other.output_preparer
            and self.cached_zeilen == other.cached_zeilen
            and self.cached_spalten == other.cached_spalten
            and self.cached_ausgabe == other.cached_ausgabe
            and self.cached_kombination == other.cached_kombination
            and self.beenden_commands_len == other.beenden_commands_len
        )

    def write_to[W: Writer](self, mut writer: W):
        writer.write(
            "PromptPreparationLegacySnapshot(",
            self.class_name,
            ", ",
            self.command_rotator,
            ", ",
            self.regex_rewriter,
            ", ",
            self.output_preparer,
            ", ",
            self.cached_zeilen,
            ", ",
            self.cached_spalten,
            ", ",
            self.cached_ausgabe,
            ", ",
            self.cached_kombination,
            ", ",
            self.beenden_commands_len,
            ")",
        )


struct PromptPreparationBundle(Copyable):
    var catalog: PromptLanguageCatalog
    var preparation_catalog: PromptPreparationCatalog
    var language: String
    var exit_commands: List[String]

    def __init__(
        out self,
        catalog: PromptLanguageCatalog,
        preparation_catalog: PromptPreparationCatalog,
        language: String,
        exit_commands: List[String],
    ):
        self.catalog = catalog.copy()
        self.preparation_catalog = preparation_catalog.copy()
        self.language = normalize_prompt_language(language)
        self.exit_commands = exit_commands.copy()

    def snapshot(self) -> PromptPreparationSnapshot:
        var count = 0
        for index in range(len(self.preparation_catalog.domains)):
            if self.preparation_catalog.domains[index].language == self.language:
                count += 1
        return PromptPreparationSnapshot(
            "PromptPreparationBundle",
            count,
            len(self.exit_commands),
            "POSIX-ERE/native",
        )

    def legacy_snapshot(self) -> PromptPreparationLegacySnapshot:
        return PromptPreparationLegacySnapshot(
            "PromptPreparationBundle",
            "verdreheWoReTaBefehl",
            "regExReplace",
            "promptVorbereitungGrosseAusgabe",
            0,
            0,
            0,
            0,
            len(self.exit_commands),
        )

    def rotate_where_reta_command(
        self,
        text1: String,
        text2: String,
        text3: List[String],
        prompt_mode: Int = PROMPT_MODE_NORMAL,
    ) -> PromptRotationResult:
        return rotate_where_reta_command(text1, text2, text3, prompt_mode)

    def regex_replace(self, tokens: List[String]) raises -> PromptRegexResult:
        return regex_replace(
            self.catalog,
            self.preparation_catalog,
            self.language,
            tokens,
        )

    def prepare_large_output(
        self,
        placeholder: String,
        prompt_mode: Int,
        prompt_mode2: Int,
        prompt_mode_last: Int,
        text: String,
        additional_tokens: List[String],
        force_e: Bool = False,
    ) raises -> PromptPreparationResult:
        return prepare_large_prompt_output(
            self.catalog,
            self.preparation_catalog,
            self.language,
            self.exit_commands,
            placeholder,
            prompt_mode,
            prompt_mode2,
            prompt_mode_last,
            text,
            additional_tokens,
            force_e,
        )

    def prepare_grosse_ausgabe(
        self,
        placeholder: String,
        prompt_mode: Int,
        prompt_mode2: Int,
        prompt_mode_last: Int,
        text: String,
        additional_tokens: List[String],
        force_e: Bool = False,
    ) raises -> PromptPreparationResult:
        return self.prepare_large_output(
            placeholder,
            prompt_mode,
            prompt_mode2,
            prompt_mode_last,
            text,
            additional_tokens,
            force_e,
        )


def _contains(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _join(values: List[String], separator: String) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += separator
        result += values[index]
    return result^


def configure_prompt_preparation(
    catalog: PromptLanguageCatalog,
    preparation_catalog: PromptPreparationCatalog,
    language: String,
    exit_commands: List[String],
) -> PromptPreparationBundle:
    """Explicit replacement for the Python module-global configuration."""
    return PromptPreparationBundle(
        catalog, preparation_catalog, language, exit_commands
    )


def bootstrap_prompt_preparation(
    catalog: PromptLanguageCatalog,
    asset_root: String,
    language: String,
    exit_commands: List[String],
) raises -> PromptPreparationBundle:
    var separator = "" if asset_root.endswith("/") else "/"
    return PromptPreparationBundle(
        catalog,
        load_prompt_preparation_catalog(
            asset_root + separator + "prompt_preparation_domains.tsv"
        ),
        language,
        exit_commands,
    )


def rotate_where_reta_command(
    text1: String,
    text2: String,
    text3: List[String],
    prompt_mode: Int = PROMPT_MODE_NORMAL,
) -> PromptRotationResult:
    # ``prompt_mode`` remains part of the historical callable contract even
    # though the Python implementation never branches on it.
    if prompt_mode < 0:
        pass
    if (
        text2.startswith("reta")
        and not text1.startswith("reta")
        and len(text3) > 0
    ):
        return PromptRotationResult(
            text2, text1, balanced_prompt_split(text2), True
        )
    return PromptRotationResult(text1, text2, text3.copy(), False)


def verdreheWoReTaBefehl(
    text1: String,
    text2: String,
    text3: List[String],
    prompt_mode: Int = PROMPT_MODE_NORMAL,
) -> PromptRotationResult:
    return rotate_where_reta_command(text1, text2, text3, prompt_mode)


def regExReplace(
    bundle: PromptPreparationBundle,
    tokens: List[String],
) raises -> PromptRegexResult:
    return bundle.regex_replace(tokens)


def promptVorbereitungGrosseAusgabe(
    bundle: PromptPreparationBundle,
    placeholder: String,
    prompt_mode: Int,
    prompt_mode2: Int,
    prompt_mode_last: Int,
    text: String,
    additional_tokens: List[String],
    force_e: Bool = False,
) raises -> PromptPreparationResult:
    return bundle.prepare_grosse_ausgabe(
        placeholder,
        prompt_mode,
        prompt_mode2,
        prompt_mode_last,
        text,
        additional_tokens,
        force_e,
    )


def _is_decimal(text: String) -> Bool:
    if text.byte_length() == 0:
        return False
    for index in range(text.byte_length()):
        var code = ord(text[byte=index])
        if code < 48 or code > 57:
            return False
    return True


def _remove_all(mut tokens: List[String], value: String) -> None:
    var kept = List[String]()
    for index in range(len(tokens)):
        if tokens[index] != value:
            kept.append(tokens[index])
    tokens = kept^


def _contains_any(tokens: List[String], first: String, second: String) -> Bool:
    return _contains(tokens, first) or _contains(tokens, second)


def _without_old_line_section(
    tokens: List[String], line_main_token: String, joined_range: String
) -> List[String]:
    var result = List[String]()
    var inside_line_section = False
    for index in range(len(tokens)):
        var token = tokens[index]
        if token.byte_length() > 1 and token.startswith("-") and not token.startswith("--"):
            inside_line_section = token == line_main_token
            if inside_line_section:
                continue
        if inside_line_section:
            continue
        if token != joined_range:
            result.append(token)
    return result^


def _divisor_range_text(range_text: String) raises -> String:
    var source = range_to_numbers(range_text, False, 0)
    var numbers = List[Int]()
    for value in source:
        numbers.append(value)
    var ordered = python_divisor_set_order(numbers)
    var strings = List[String]()
    for index in range(len(ordered)):
        strings.append(String(ordered[index]))
    return _join(strings, ",")


def _has_exit_command(tokens: List[String], exits: List[String]) -> Bool:
    for index in range(len(tokens)):
        if _contains(exits, tokens[index]):
            return True
    return False


def prepare_large_prompt_output(
    catalog: PromptLanguageCatalog,
    preparation_catalog: PromptPreparationCatalog,
    language: String,
    exit_commands: List[String],
    placeholder: String,
    prompt_mode: Int,
    prompt_mode2: Int,
    prompt_mode_last: Int,
    text: String,
    additional_tokens: List[String],
    force_e: Bool = False,
) raises -> PromptPreparationResult:
    var initial_tokens = balanced_prompt_split(text)
    var prepared = prepare_prompt_tokens(
        catalog,
        language,
        initial_tokens,
        prompt_mode2 == PROMPT_MODE_SELECTIVE_OUTPUT,
        force_e,
    )
    var tokens = prepared.tokens.copy()
    var max_number = 1024
    var saw_decimal = False
    for index in range(len(tokens)):
        if _is_decimal(tokens[index]):
            var value = atol(tokens[index])
            if not saw_decimal or value > max_number:
                max_number = value
            saw_decimal = True
    if saw_decimal and max_number < 0:
        max_number = 1024

    if (
        prompt_mode2 == PROMPT_MODE_SELECTIVE_OUTPUT
        and prompt_mode_last == PROMPT_MODE_NORMAL
    ):
        var combined = additional_tokens.copy()
        for index in range(len(tokens)):
            combined.append(tokens[index])
        tokens = combined^

    var row_tokens = List[String]()
    for index in range(len(tokens)):
        if is_row_range(tokens[index]):
            row_tokens.append(tokens[index])
    var joined_range = _join(row_tokens, ",")

    if (
        prompt_mode == PROMPT_MODE_NORMAL
        and placeholder.byte_length() > 1
        and placeholder.startswith("reta")
        and len(row_tokens) > 0
    ):
        var line_main = prompt_vocabulary_alias(
            catalog, language, "main", "zeilen"
        )
        var line_main_token = "-" + line_main
        tokens = _without_old_line_section(
            tokens, line_main_token, joined_range
        )

        var divisor_short = prompt_vocabulary_alias(
            catalog, language, "command", "w"
        )
        var divisor_long = prompt_vocabulary_alias(
            catalog, language, "command", "teiler"
        )
        if _contains_any(tokens, divisor_short, divisor_long):
            joined_range = _divisor_range_text(joined_range)
            _remove_all(tokens, divisor_short)
            _remove_all(tokens, divisor_long)

        var multiple_short = prompt_vocabulary_alias(
            catalog, language, "command", "v"
        )
        var multiple_long = prompt_vocabulary_alias(
            catalog, language, "command", "vielfache"
        )
        tokens.append(line_main_token)
        if _contains_any(tokens, multiple_short, multiple_long):
            var parameter = prompt_vocabulary_alias(
                catalog, language, "line", "vielfachevonzahlen"
            )
            tokens.append("--" + parameter + "=" + joined_range)
            _remove_all(tokens, multiple_short)
            _remove_all(tokens, multiple_long)
        else:
            var range_short = prompt_vocabulary_alias(
                catalog, language, "command", "range"
            )
            var range_long = prompt_vocabulary_alias(
                catalog, language, "command", "R"
            )
            var canonical = "vorhervonausschnitt"
            if _contains_any(tokens, range_short, range_long):
                canonical = "zaehlung"
            var parameter = prompt_vocabulary_alias(
                catalog, language, "line", canonical
            )
            tokens.append("--" + parameter + "=" + joined_range)
    
    var pure_reta = len(tokens) > 0 and (tokens[0] == "reta" or tokens[0] == "+reta")
    if not pure_reta:
        tokens = python_string_set_order(tokens)
    var exit_requested = _has_exit_command(tokens, exit_commands)
    if exit_requested and len(exit_commands) > 0:
        var exit_only = List[String]()
        exit_only.append(exit_commands[0])
        tokens = exit_only^

    var regex_result = regex_replace(
        catalog, preparation_catalog, language, tokens
    )
    return PromptPreparationResult(
        pure_reta,
        List[String](),
        "",
        List[String](),
        max_number,
        regex_result.tokens.copy(),
        List[String](),
        prepared.compact,
        exit_requested,
    )
