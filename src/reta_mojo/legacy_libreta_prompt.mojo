"""Typed compatibility owner for historical ``libs/LibRetaPrompt.py``.

The Python module has no own functions or classes.  It imports prompt helpers,
bootstraps five architecture bundles at import time and materializes 21 public
list/dict/set aliases.  The native owner replaces that hidden process-global
bootstrap with one explicit value.  Every collection has a deterministic
ordered representation and every helper receives the facade state explicitly.
"""

from std.collections import List
from .completion_runtime import CompletionRuntimeBundle
from .input_semantics import (
    PromptVocabulary,
    PromptVocabularyMapEntry,
    load_prompt_vocabulary,
)
from .legacy_center import BereichToNumbers2, x
from .prompt_language import (
    PromptExpansionResult,
    PromptLanguageCatalog,
    custom_split,
    custom_split2,
    expand_compact_prompt_tokens,
    is15or16command as native_is15or16command,
    isReTaParameter as native_isReTaParameter,
    load_prompt_language_catalog,
)
from .prompt_runtime import (
    PromptProgramViewContract,
    PromptRuntimeContract,
)
from .prompt_runtime_catalog import prompt_runtime_contract
from .prompt_session import (
    NativePromptSession,
    PROMPT_MODE_DELETE_SELECT,
    PROMPT_MODE_DELETE_START,
    PROMPT_MODE_NORMAL,
    PROMPT_MODE_SELECTIVE_OUTPUT,
    PROMPT_MODE_STORE,
    PROMPT_MODE_STORED_OUTPUT,
    PROMPT_MODE_STORED_OUTPUT_WITH_ADDITION,
    new_prompt_session_for_language,
)
from .resource_paths import asset_root
from .row_ranges import is_row_range_token, split_top_level_commas
from .runtime_compat import runtime_compat_prime_cross_strings


@fieldwise_init
struct LegacyPromptArchitectureView(Copyable):
    var owner_modules: List[String]
    var input_catalog_loaded: Bool
    var prompt_language_loaded: Bool


@fieldwise_init
struct LegacyPromptModes(Copyable):
    var normal: Int
    var speichern: Int
    var loeschenStart: Int
    var speicherungAusgaben: Int
    var loeschenSelect: Int
    var speicherungAusgabenMitZusatz: Int
    var AusgabeSelektiv: Int


@fieldwise_init
struct LegacyPromptMapEntry(Copyable, Equatable):
    var key: String
    var value: String

    def __eq__(self, other: Self) -> Bool:
        return self.key == other.key and self.value == other.value


@fieldwise_init
struct LegacyFractionVerification(Copyable):
    var validity: List[Bool]
    var fraction_specs: List[String]
    var fraction_ranges: List[String]
    var integer_specs: List[String]
    var all_valid: Bool


@fieldwise_init
struct LegacyFractionListVerification(Copyable):
    var validity: List[List[Bool]]
    var fraction_specs: List[List[String]]
    var fraction_ranges: List[List[String]]
    var integer_specs: List[List[String]]
    var all_valid: Bool


@fieldwise_init
struct LegacyLibRetaPromptSnapshot(Copyable, Equatable):
    var exported_names_len: Int
    var main_parameters_len: Int
    var columns_len: Int
    var columns_dictionary_keys: Int
    var row_parameters_len: Int
    var output_parameters_len: Int
    var commands_len: Int
    var commands2_len: Int
    var wahl15_len: Int
    var wahl16_len: Int
    var missing_wahl15_len: Int


@fieldwise_init
struct LegacyLibRetaPromptBundle(Copyable):
    """Explicit replacement for all import-time globals of LibRetaPrompt."""

    var resource_root: String
    var architecture: LegacyPromptArchitectureView
    var promptModes: LegacyPromptModes
    var promptRuntime: PromptRuntimeContract
    var completionRuntime: CompletionRuntimeBundle
    var promptLanguage: PromptLanguageCatalog
    var promptSession: NativePromptSession
    var retaProgram: PromptProgramViewContract
    var promptVocabulary: PromptVocabulary
    var mainParas: List[String]
    var spalten: List[String]
    var eigsN: List[String]
    var eigsR: List[String]
    var spaltenDict: List[PromptVocabularyMapEntry]
    var zeilenTypen: List[String]
    var zeilenZeit: List[String]
    var zeilenTypenB: List[String]
    var ausgabeParas: List[String]
    var kombiMainParas: List[String]
    var zeilenParas: List[String]
    var hauptForNeben: List[String]
    var notParameterValues: List[String]
    var hauptForNebenSet: List[String]
    var ausgabeArt: List[String]
    var gebrochenErlaubteZahlen: List[Int]
    var missingWahl15Values: List[String]
    var befehle: List[String]
    var befehle2: List[String]
    var wahl15: List[LegacyPromptMapEntry]
    var wahl16: List[LegacyPromptMapEntry]

    def snapshot(self) -> LegacyLibRetaPromptSnapshot:
        return LegacyLibRetaPromptSnapshot(
            len(legacy_libreta_prompt_exported_names()),
            len(self.mainParas),
            len(self.spalten),
            len(self.spaltenDict),
            len(self.zeilenParas),
            len(self.ausgabeParas),
            len(self.befehle),
            len(self.befehle2),
            len(self.wahl15),
            len(self.wahl16),
            len(self.missingWahl15Values),
        )


def _copy_strings(values: List[String]) -> List[String]:
    var result = List[String]()
    for index in range(len(values)):
        result.append(values[index])
    return result^


def _copy_ints(values: List[Int]) -> List[Int]:
    var result = List[Int]()
    for index in range(len(values)):
        result.append(values[index])
    return result^


def _copy_map_entries(
    values: List[PromptVocabularyMapEntry],
) -> List[PromptVocabularyMapEntry]:
    var result = List[PromptVocabularyMapEntry]()
    for index in range(len(values)):
        result.append(values[index].copy())
    return result^


def _numeric_shortcuts(
    catalog: PromptLanguageCatalog,
    language: String,
    family: String,
) -> List[LegacyPromptMapEntry]:
    var result = List[LegacyPromptMapEntry]()
    for index in range(len(catalog.numeric_shortcuts)):
        var entry = catalog.numeric_shortcuts[index].copy()
        if entry.language == language and entry.family == family:
            result.append(LegacyPromptMapEntry(entry.key, entry.description))
    return result^


def legacy_prompt_modes() -> LegacyPromptModes:
    return LegacyPromptModes(
        PROMPT_MODE_NORMAL,
        PROMPT_MODE_STORE,
        PROMPT_MODE_DELETE_START,
        PROMPT_MODE_STORED_OUTPUT,
        PROMPT_MODE_DELETE_SELECT,
        PROMPT_MODE_STORED_OUTPUT_WITH_ADDITION,
        PROMPT_MODE_SELECTIVE_OUTPUT,
    )


def bootstrap_legacy_libreta_prompt() raises -> LegacyLibRetaPromptBundle:
    """Build the German historical import-time module as one owned value.

    ``LibRetaPrompt.py`` imports ``i18n.words_runtime`` directly and therefore
    has no runtime language argument.  Keeping the native facade fixed to the
    same catalog avoids a mixed-language object graph.
    """
    var root = asset_root()
    var prompt_language = load_prompt_language_catalog(root)
    var completion_runtime = CompletionRuntimeBundle(
        prompt_language.copy(), "deutsch"
    )
    var prompt_runtime = prompt_runtime_contract("deutsch")
    var prompt_session = new_prompt_session_for_language(False, "deutsch")
    var vocabulary = load_prompt_vocabulary()
    var normalized = prompt_runtime.language
    var wahl15 = _numeric_shortcuts(
        prompt_language, normalized, "15"
    )
    var wahl16 = _numeric_shortcuts(
        prompt_language, normalized, "16"
    )
    return LegacyLibRetaPromptBundle(
        root^,
        LegacyPromptArchitectureView(
            [
                "input_semantics.mojo",
                "prompt_runtime.mojo",
                "completion_runtime.mojo",
                "prompt_language.mojo",
                "prompt_session.mojo",
            ],
            True,
            True,
        ),
        legacy_prompt_modes(),
        prompt_runtime.copy(),
        completion_runtime^,
        prompt_language^,
        prompt_session^,
        prompt_runtime.program.copy(),
        vocabulary.copy(),
        _copy_strings(vocabulary.main_parameters),
        _copy_strings(vocabulary.spalten),
        _copy_strings(vocabulary.eigs_n),
        _copy_strings(vocabulary.eigs_r),
        _copy_map_entries(vocabulary.spalten_dict),
        _copy_strings(vocabulary.zeilen_typen),
        _copy_strings(vocabulary.zeilen_zeit),
        _copy_strings(vocabulary.zeilen_typen_b),
        _copy_strings(vocabulary.ausgabe_paras),
        _copy_strings(vocabulary.kombi_main_paras),
        _copy_strings(vocabulary.zeilen_paras),
        _copy_strings(vocabulary.haupt_for_neben),
        _copy_strings(vocabulary.not_parameter_values),
        _copy_strings(vocabulary.haupt_for_neben_set),
        _copy_strings(vocabulary.ausgabe_art),
        _copy_ints(vocabulary.gebrochen_erlaubte_zahlen),
        _copy_strings(prompt_runtime.wahl15_missing_values),
        _copy_strings(vocabulary.befehle),
        _copy_strings(vocabulary.befehle2),
        wahl15^,
        wahl16^,
    )


def Primzahlkreuz_pro_contra_strs() -> List[String]:
    return runtime_compat_prime_cross_strings()


def isReTaParameter(
    facade: LegacyLibRetaPromptBundle,
    text: String,
) raises -> Bool:
    return native_isReTaParameter(
        facade.promptLanguage, facade.promptRuntime.language, text
    )


def is15or16command(
    facade: LegacyLibRetaPromptBundle,
    text: String,
) -> Bool:
    return native_is15or16command(
        facade.promptLanguage, facade.promptRuntime.language, text
    )


def stextFromKleinKleinKleinBefehl(
    facade: LegacyLibRetaPromptBundle,
    prompt_mode: Int,
    stext: List[String],
    text_dazu: List[String] = List[String](),
) raises -> PromptExpansionResult:
    # ``textDazu`` is an internal scratch list in the Python function.  Its
    # externally observable result is the compact flag plus the token list.
    _ = text_dazu
    return expand_compact_prompt_tokens(
        facade.promptLanguage,
        facade.promptRuntime.language,
        stext,
        prompt_mode == PROMPT_MODE_SELECTIVE_OUTPUT,
        False,
    )


def verkuerze_dict(
    entries: List[LegacyPromptMapEntry],
) -> List[LegacyPromptMapEntry]:
    """Keep the first key for every distinct value, preserving insertion order."""
    var result = List[LegacyPromptMapEntry]()
    for index in range(len(entries)):
        var duplicate = False
        for result_index in range(len(result)):
            if result[result_index].value == entries[index].value:
                duplicate = True
                break
        if not duplicate:
            result.append(entries[index].copy())
    return result^


def _all_true(values: List[Bool]) -> Bool:
    for index in range(len(values)):
        if not values[index]:
            return False
    return True


def verifyBruchNganzZahlBetweenCommas(
    validity: List[Bool],
    fraction_spec: String,
    fraction_specs: List[String],
    fraction_range: String,
    fraction_ranges: List[String],
    candidate: String,
    integer_specs: List[String],
) raises -> LegacyFractionVerification:
    var result_validity = validity.copy()
    var result_fraction_specs = fraction_specs.copy()
    var result_fraction_ranges = fraction_ranges.copy()
    var result_integer_specs = integer_specs.copy()
    var is_fraction_side = is_row_range_token(fraction_spec)
    var is_integer_side = is_row_range_token(candidate)
    if is_fraction_side != is_integer_side:
        result_validity.append(True)
        if is_fraction_side:
            result_fraction_ranges.append(fraction_range)
            result_fraction_specs.append(fraction_spec)
        elif is_integer_side:
            result_integer_specs.append(candidate)
    else:
        result_validity.append(False)
    return LegacyFractionVerification(
        result_validity^,
        result_fraction_specs^,
        result_fraction_ranges^,
        result_integer_specs^,
        _all_true(result_validity),
    )


def verifyBruchNganzZahlCommaList(
    validity: List[Bool],
    fraction_spec: String,
    fraction_specs: List[String],
    fraction_range: String,
    fraction_ranges: List[String],
    comma_list: String,
    integer_specs: List[String],
) raises -> LegacyFractionListVerification:
    var all_validities = List[List[Bool]]()
    var all_fraction_specs = List[List[String]]()
    var all_fraction_ranges = List[List[String]]()
    var all_integer_specs = List[List[String]]()
    var aggregate_validity = validity.copy()
    var aggregate_fraction_specs = fraction_specs.copy()
    var aggregate_fraction_ranges = fraction_ranges.copy()
    var aggregate_integer_specs = integer_specs.copy()
    var pieces = split_top_level_commas(comma_list)
    for index in range(len(pieces)):
        var verified = verifyBruchNganzZahlBetweenCommas(
            aggregate_validity,
            fraction_spec,
            aggregate_fraction_specs,
            fraction_range,
            aggregate_fraction_ranges,
            pieces[index],
            aggregate_integer_specs,
        )
        aggregate_validity = verified.validity.copy()
        aggregate_fraction_specs = verified.fraction_specs.copy()
        aggregate_fraction_ranges = verified.fraction_ranges.copy()
        aggregate_integer_specs = verified.integer_specs.copy()
        all_validities.append(aggregate_validity.copy())
        all_fraction_specs.append(aggregate_fraction_specs.copy())
        all_fraction_ranges.append(aggregate_fraction_ranges.copy())
        all_integer_specs.append(aggregate_integer_specs.copy())
    return LegacyFractionListVerification(
        all_validities^,
        all_fraction_specs^,
        all_fraction_ranges^,
        all_integer_specs^,
        _all_true(aggregate_validity),
    )


def legacy_libreta_prompt_exported_names() -> List[String]:
    """Names materialized or re-exported by the Python compatibility module."""
    return [
        "Path",
        "BereichToNumbers2",
        "Primzahlkreuz_pro_contra_strs",
        "i18n",
        "x",
        "RetaArchitecture",
        "PromptModus",
        "bootstrap_completion_runtime",
        "bootstrap_prompt_language",
        "bootstrap_prompt_runtime",
        "bootstrap_prompt_session",
        "custom_split",
        "custom_split2",
        "is15or16command",
        "isReTaParameter",
        "stextFromKleinKleinKleinBefehl",
        "verifyBruchNganzZahlBetweenCommas",
        "verifyBruchNganzZahlCommaList",
        "verkuerze_dict",
        "REPO_ROOT",
        "_ARCHITECTURE",
        "promptRuntime",
        "completionRuntime",
        "promptLanguage",
        "promptSession",
        "retaProgram",
        "promptVocabulary",
        "mainParas",
        "spalten",
        "eigsN",
        "eigsR",
        "spaltenDict",
        "zeilenTypen",
        "zeilenZeit",
        "zeilenTypenB",
        "ausgabeParas",
        "kombiMainParas",
        "zeilenParas",
        "hauptForNeben",
        "notParameterValues",
        "hauptForNebenSet",
        "ausgabeArt",
        "gebrochenErlaubteZahlen",
        "missingWahl15Values",
        "befehle",
        "befehle2",
        "wahl15",
        "wahl16",
    ]
