"""Native composition facade for ``reta_architecture.prompt_execution``.

The historical Python module combines prompt parsing, fraction management,
table command composition and process effects.  Its deterministic native
owners are recorded here in the exact 22-entry top-level surface order.
Terminal I/O belongs solely to the native prompt controller; unproved compound
commands remain an explicit compatibility boundary.
"""

from std.collections import List
from .prompt_language import (
    PromptExpansionResult,
    PromptLanguageCatalog,
    balanced_prompt_split,
    expand_compact_prompt_tokens,
    expand_prompt_replacements,
    prepare_prompt_tokens,
    prompt_vocabulary_alias,
    is_prompt_numeric_shortcut,
)
from .prompt_runtime import (
    KIND_PRIME,
    KIND_MULTIS,
    KIND_PRIME_COMPARE,
    PromptCommand,
    classify_prompt_command_localized,
    command_numbers,
    join_prompt_tokens,
    multis_lines,
    prime_comparison_lines,
    prime_lines,
)
from .prompt_historical_ownership import (
    PROMPT_LOG_DISABLED,
    PROMPT_LOG_ENABLED,
    historical_prompt_companion_effects,
    historical_prompt_execution_supported,
    historical_prompt_logging_update,
    is_prompt_numeric_syntax_token,
)
from .prompt_execution_helpers import (
    PromptExecutionHelpersBundle,
    bootstrap_prompt_execution_helpers,
)
from .prompt_table_execution import (
    PromptTablePlan,
    plan_prompt_table_commands,
)
from .prompt_legacy_echo import compact_prompt_announcement_line


@fieldwise_init
struct PromptExecutionOwner(Copyable):
    var python_name: String
    var owner: String
    var evidence: String


def prompt_execution_owners() -> List[PromptExecutionOwner]:
    """Exact ownership map for every top-level Python execution surface."""
    return [
        PromptExecutionOwner("configure_prompt_execution", "prompt_execution.mojo", "bootstrap_prompt_execution"),
        PromptExecutionOwner("PromptExecutionBundle", "prompt_execution.mojo", "struct PromptExecutionBundle"),
        PromptExecutionOwner("bootstrap_prompt_execution", "prompt_execution.mojo", "def bootstrap_prompt_execution"),
        PromptExecutionOwner("anotherOberesMaximum", "prompt_execution_helpers.mojo", "def anotherOberesMaximum"),
        PromptExecutionOwner("returnOnlyParasAsList", "prompt_execution_helpers.mojo", "def returnOnlyParasAsList"),
        PromptExecutionOwner("grKl", "prompt_execution_helpers.mojo", "def grKl"),
        PromptExecutionOwner("getDictLimtedByKeyList", "prompt_execution_helpers.mojo", "def getDictLimtedByKeyList"),
        PromptExecutionOwner("bruchSpalt", "prompt_fraction_execution.mojo", "def parse_prompt_fraction"),
        PromptExecutionOwner("dictToList", "prompt_execution_helpers.mojo", "def dictToList"),
        PromptExecutionOwner("createRangesForBruchLists", "prompt_fraction_execution.mojo", "def create_prompt_fraction_range"),
        PromptExecutionOwner("vorherVonAusschnittOderZaehlung", "prompt_execution_helpers.mojo", "def vorherVonAusschnittOderZaehlung"),
        PromptExecutionOwner("PromptGrosseAusgabe", "prompt_execution_runtime.mojo", "def render_prompt_table_plan"),
        PromptExecutionOwner("retaCmdAbstraction_n_and_1pron", "prompt_table_execution.mojo", "def plan_prompt_table_commands"),
        PromptExecutionOwner("ifPrintCmdAgain", "prompt_legacy_echo.mojo", "def compact_prompt_announcement_line"),
        PromptExecutionOwner("zeiln1234create", "prompt_table_execution.mojo", "def _base_table_tokens"),
        PromptExecutionOwner("retaExecuteNprint", "native_reta_cli.mojo", "def run_native_reta"),
        PromptExecutionOwner("findEqualNennerZaehler", "prompt_fraction_execution.mojo", "def equal_fraction_axes"),
        PromptExecutionOwner("findNennerZaehlerMakesWholeNum", "prompt_fraction_execution.mojo", "def whole_fraction_axes"),
        PromptExecutionOwner("bruchBereichsManagementAndWbefehl", "prompt_fraction_execution.mojo", "def create_prompt_fraction_range"),
        PromptExecutionOwner("addMoreVals2", "prompt_fraction_execution.mojo", "def add_prompt_fraction_value"),
        PromptExecutionOwner("addMoreVals", "prompt_fraction_execution.mojo", "def add_prompt_fraction_value"),
        PromptExecutionOwner("PromptVonGrosserAusgabeSonderBefehlAusgaben", "prompt_execution.mojo", "def plan_prompt_execution_routing"),
    ]


@fieldwise_init
struct PromptExecutionRoutingPlan(Copyable):
    """Shared parse/normalisation plan for prompt execution entry points.

    The interactive and one-shot controllers both need the same historical
    front half of ``PromptVonGrosserAusgabeSonderBefehlAusgaben``: raw token
    splitting, compact expansion, replacement normalisation, prepared-token
    selection for visible compact echo, single-command classification and the
    quiet-output flag.  Keeping that pure routing state here reduces the
    process controller to I/O and explicit boundary crossing.
    """

    var raw_tokens: List[String]
    var compact_expansion: PromptExpansionResult
    var normalized_tokens: List[String]
    var normalized_line: String
    var command: PromptCommand
    var prepared_tokens: List[String]
    var historical_echo: Bool
    var numeric_default: Bool
    var planning_tokens_are_prepared: Bool
    var planning_tokens: List[String]
    var quiet_echo: Bool


def prompt_execution_contains_token(values: List[String], needle: String) -> Bool:
    for index in range(len(values)):
        if values[index] == needle:
            return True
    return False


def prompt_execution_uses_historical_echo(
    raw_tokens: List[String], expansion: PromptExpansionResult
) -> Bool:
    if expansion.compact:
        return True
    return len(raw_tokens) > 0 and raw_tokens[0].byte_length() == 1


def prompt_execution_contains_numeric_shortcut(
    values: List[String], language: String, catalog: PromptLanguageCatalog
) -> Bool:
    for index in range(len(values)):
        if is_prompt_numeric_shortcut(catalog, language, values[index]):
            return True
    return False


def prompt_execution_is_pure_numeric_prompt(values: List[String]) -> Bool:
    if len(values) == 0:
        return False
    for index in range(len(values)):
        if not is_prompt_numeric_syntax_token(values[index]):
            return False
    return True


def prompt_execution_quiet_echo(
    values: List[String], language: String, catalog: PromptLanguageCatalog
) -> Bool:
    var quiet = prompt_vocabulary_alias(
        catalog,
        language,
        "command",
        "keineEinZeichenZeilenPlusKeineAusgabeWelcherBefehlEsWar",
    )
    return prompt_execution_contains_token(values, quiet)




@fieldwise_init
struct PromptExecutionTableOwnershipPlan(Copyable):
    """Atomic native ownership decision for table and mulpri prompt branches.

    Both interactive and one-shot prompt execution must answer the same question
    before any output is emitted: does the normalized command line belong fully
    to native table/mulpri execution, or must the untouched source spelling cross
    the explicit compatibility boundary?  Keeping this pure decision here avoids
    duplicated controller-side ownership algebra.
    """

    var table_plan: PromptTablePlan
    var mulpri_candidate: Bool
    var table_candidate: Bool
    var owns_mulpri: Bool
    var owns_table: Bool
    var fallback_required: Bool
    var integer_arguments: List[String]


@fieldwise_init
struct PromptExecutionCompactAnnouncementPlan(Copyable):
    """Pure visible compact-command announcement plan.

    The prompt controller owns only terminal I/O.  The decision whether a
    compact prompt prints the historical Rich-style command echo, the
    mulpri/p companion-token enrichment and the final byte string all belong
    to the prompt-execution owner.
    """

    var should_print: Bool
    var line: String
    var visible_tokens: List[String]


@fieldwise_init
struct PromptExecutionHistoricalEffectPlan(Copyable):
    """Pure side-effect ordering plan around table and mulpri execution.

    The controller still performs terminal output and session mutation, but the
    historical membership rules for companion informational effects and the
    post-command logging transition belong to prompt execution.  This keeps the
    interactive and one-shot controllers from duplicating PromptGrosseAusgabe's
    side-effect algebra.
    """

    var show_short_commands: Bool
    var show_commands: Bool
    var show_help: Bool
    var clear_before_table: Bool
    var enable_logging: Bool
    var disable_logging: Bool


@fieldwise_init
struct PromptExecutionMulpriRenderPlan(Copyable):
    """Pure render-line plan for the historical mulpri/p prompt branch.

    The prompt controller should not know how `mulpri` expands into prime,
    multis and prime-factor-comparison presentation.  It only prints the lines
    planned here.
    """

    var handled: Bool
    var output_lines: List[String]


@fieldwise_init
struct PromptExecutionNativeBranchPlan(Copyable):
    """Complete pure plan for the owned table/mulpri prompt branch.

    Interactive prompt execution and one-shot ``-befehl`` share the same
    ownership, compact-announcement, historical side-effect and table-render
    flag decisions.  This value keeps those decisions in the prompt-execution
    owner so the two controllers only perform I/O and session mutation.
    """

    var should_try_native: Bool
    var fallback_required: Bool
    var ownership: PromptExecutionTableOwnershipPlan
    var announcement: PromptExecutionCompactAnnouncementPlan
    var historical_effects: PromptExecutionHistoricalEffectPlan
    var mulpri_render: PromptExecutionMulpriRenderPlan
    var planning_tokens: List[String]
    var historical_echo: Bool
    var quiet_echo: Bool


@fieldwise_init
struct PromptExecutionNativeBranchOutcomePlan(Copyable):
    """Pure post-I/O outcome for a planned native branch.

    The controller observes whether table/mulpri output actually ran, but the
    follow-up logging transition and compatibility fallback decision still
    belong to prompt execution.
    """

    var handled: Bool
    var fallback_required: Bool
    var enable_logging: Bool
    var disable_logging: Bool


@fieldwise_init
struct PromptExecutionNativeBranchOutputPlan(Copyable):
    """Pure output-completion result for a planned native branch.

    The controller still performs table rendering and prints preplanned mulpri
    lines, but the final handled algebra belongs to prompt execution rather
    than being recomputed by both prompt entry points.
    """

    var handled: Bool
    var table_handled: Bool
    var mulpri_handled: Bool


@fieldwise_init
struct PromptExecutionSessionLoggingPlan(Copyable):
    """Pure session logging mutation value after native branch output.

    The prompt session remains controller state.  The decision whether the
    session must change and which boolean value it should receive is owned by
    prompt execution.
    """

    var update: Bool
    var enabled: Bool


def prompt_execution_integer_argument_words(values: List[String]) -> List[String]:
    var result = List[String]()
    for index in range(len(values)):
        var token = values[index]
        if "/" in token or token.startswith("-"):
            continue
        try:
            var numbers = command_numbers(
                PromptCommand(KIND_PRIME, "prim " + token, ["prim", token])
            )
            if len(numbers) > 0:
                result.append(token)
        except:
            pass
    return result^


def prompt_execution_has_mulpri(
    values: List[String], language: String, catalog: PromptLanguageCatalog
) -> Bool:
    var mulpri = prompt_vocabulary_alias(catalog, language, "command", "mulpri")
    var short = prompt_vocabulary_alias(catalog, language, "command", "p")
    return prompt_execution_contains_token(
        values, mulpri
    ) or prompt_execution_contains_token(values, short)


def prompt_execution_language_is_german(language: String) -> Bool:
    var normalized = language.lower()
    return (
        normalized == ""
        or normalized == "de"
        or normalized == "deutsch"
        or normalized == "german"
    )


def plan_prompt_execution_mulpri_render(
    values: List[String], language: String, catalog: PromptLanguageCatalog
) raises -> PromptExecutionMulpriRenderPlan:
    """Plan the complete native mulpri/p output without terminal effects."""

    if not prompt_execution_has_mulpri(values, language, catalog):
        return PromptExecutionMulpriRenderPlan(False, List[String]())
    var arguments = prompt_execution_integer_argument_words(values)
    if len(arguments) == 0:
        return PromptExecutionMulpriRenderPlan(False, List[String]())
    var output = List[String]()
    var prime_words = List[String]()
    prime_words.append("prim")
    for index in range(len(arguments)):
        prime_words.append(arguments[index])
    var prime_command = PromptCommand(
        KIND_PRIME, join_prompt_tokens(prime_words), prime_words^
    )
    var numbers = command_numbers(prime_command)
    if len(numbers) > 1:
        var compare_words = List[String]()
        compare_words.append("primfaktorenvergleich")
        for index in range(len(arguments)):
            compare_words.append(arguments[index])
        var compare_lines = prime_comparison_lines(
            PromptCommand(
                KIND_PRIME_COMPARE,
                join_prompt_tokens(compare_words),
                compare_words^,
            ),
            language,
        )
        for index in range(len(compare_lines)):
            output.append(compare_lines[index])
    var prime_output = prime_lines(prime_command)
    for index in range(len(prime_output)):
        output.append(prime_output[index])
    var multi_words = List[String]()
    multi_words.append("multis")
    for index in range(len(arguments)):
        multi_words.append(arguments[index])
    var multi_output = multis_lines(
        PromptCommand(
            KIND_MULTIS, join_prompt_tokens(multi_words), multi_words^
        )
    )
    for index in range(len(multi_output)):
        if ("[]" in multi_output[index]) and index < len(numbers):
            var prime_word = "Primzahl" if prompt_execution_language_is_german(
                language
            ) else "prime_number"
            output.append(
                String(numbers[index])
                + ": "
                + String(numbers[index])
                + " ("
                + prime_word
                + ")"
            )
        else:
            output.append(multi_output[index])
    return PromptExecutionMulpriRenderPlan(True, output^)



def prompt_execution_compact_announcement_tokens(
    prepared_tokens: List[String],
    language: String,
    catalog: PromptLanguageCatalog,
) -> List[String]:
    var result = prepared_tokens.copy()
    if prompt_execution_has_mulpri(prepared_tokens, language, catalog):
        for canonical in ["multis", "prim", "primfaktorenvergleich"]:
            var translated = prompt_vocabulary_alias(
                catalog, language, "command", canonical
            )
            if not prompt_execution_contains_token(result, translated):
                result.append(translated)
    return result^



def plan_prompt_execution_compact_announcement(
    routing: PromptExecutionRoutingPlan,
    source: String,
    language: String,
    catalog: PromptLanguageCatalog,
) -> PromptExecutionCompactAnnouncementPlan:
    """Plan the historical compact-command visible announcement line."""

    if not routing.compact_expansion.compact or routing.quiet_echo:
        return PromptExecutionCompactAnnouncementPlan(
            False, "", List[String]()
        )
    var visible_tokens = prompt_execution_compact_announcement_tokens(
        routing.prepared_tokens, language, catalog
    )
    return PromptExecutionCompactAnnouncementPlan(
        True,
        compact_prompt_announcement_line(visible_tokens, source, language),
        visible_tokens^,
    )

def plan_prompt_execution_historical_effects(
    routing: PromptExecutionRoutingPlan,
    language: String,
    catalog: PromptLanguageCatalog,
) -> PromptExecutionHistoricalEffectPlan:
    """Plan companion informational effects and logging transitions."""

    var planning_tokens = routing.planning_tokens.copy()
    var companion = historical_prompt_companion_effects(
        planning_tokens, language, catalog
    )
    var logging_update = historical_prompt_logging_update(
        planning_tokens, language, catalog
    )
    return PromptExecutionHistoricalEffectPlan(
        companion.show_short_commands,
        companion.show_commands,
        companion.show_help,
        companion.clear_before_table,
        logging_update == PROMPT_LOG_ENABLED,
        logging_update == PROMPT_LOG_DISABLED,
    )

def plan_prompt_execution_native_branch(
    routing: PromptExecutionRoutingPlan,
    source: String,
    language: String,
    catalog: PromptLanguageCatalog,
) raises -> PromptExecutionNativeBranchPlan:
    """Plan the whole owned table/mulpri branch without terminal effects."""

    var ownership = plan_prompt_execution_table_ownership(
        routing, language, catalog
    )
    var should_try_native = ownership.owns_table or ownership.owns_mulpri
    var announcement = PromptExecutionCompactAnnouncementPlan(
        False, "", List[String]()
    )
    var effects = PromptExecutionHistoricalEffectPlan(
        False, False, False, False, False, False
    )
    var mulpri_render = PromptExecutionMulpriRenderPlan(False, List[String]())
    if should_try_native:
        announcement = plan_prompt_execution_compact_announcement(
            routing, source, language, catalog
        )
        effects = plan_prompt_execution_historical_effects(
            routing, language, catalog
        )
        mulpri_render = plan_prompt_execution_mulpri_render(
            routing.planning_tokens, language, catalog
        )
    return PromptExecutionNativeBranchPlan(
        should_try_native,
        ownership.fallback_required,
        ownership^,
        announcement^,
        effects^,
        mulpri_render^,
        routing.planning_tokens.copy(),
        routing.historical_echo,
        routing.quiet_echo,
    )


def plan_prompt_execution_native_branch_output(
    branch: PromptExecutionNativeBranchPlan, table_handled: Bool
) -> PromptExecutionNativeBranchOutputPlan:
    """Plan the final handled result after branch render effects.

    Table rendering reports its own success after I/O.  Mulpri rendering was
    already planned in the branch; the owner merges both signals into one
    explicit result for the controller.
    """

    var mulpri_handled = branch.mulpri_render.handled
    return PromptExecutionNativeBranchOutputPlan(
        table_handled or mulpri_handled,
        table_handled,
        mulpri_handled,
    )


def plan_prompt_execution_session_logging_update(
    outcome: PromptExecutionNativeBranchOutcomePlan, current_enabled: Bool
) -> PromptExecutionSessionLoggingPlan:
    """Plan a prompt-session logging mutation from a native branch outcome."""

    if outcome.enable_logging:
        return PromptExecutionSessionLoggingPlan(True, True)
    if outcome.disable_logging:
        return PromptExecutionSessionLoggingPlan(True, False)
    return PromptExecutionSessionLoggingPlan(False, current_enabled)


def plan_prompt_execution_native_branch_outcome(
    branch: PromptExecutionNativeBranchPlan, native_handled: Bool
) -> PromptExecutionNativeBranchOutcomePlan:
    """Plan post branch control flow after optional native output.

    A rejected compound candidate must cross the compatibility boundary even
    when the controller never attempted native rendering.  A successfully
    printed owned branch may still apply the historical logging transition.
    """

    return PromptExecutionNativeBranchOutcomePlan(
        native_handled,
        branch.fallback_required,
        native_handled and branch.historical_effects.enable_logging,
        native_handled and branch.historical_effects.disable_logging,
    )


def plan_prompt_execution_table_ownership(
    routing: PromptExecutionRoutingPlan,
    language: String,
    catalog: PromptLanguageCatalog,
) raises -> PromptExecutionTableOwnershipPlan:
    """Plan whether table/mulpri execution may run natively as one atom."""

    var planning_tokens = routing.planning_tokens.copy()
    var table_plan = plan_prompt_table_commands(
        planning_tokens,
        language,
        catalog,
        routing.planning_tokens_are_prepared,
    )
    var integer_arguments = prompt_execution_integer_argument_words(planning_tokens)
    var mulpri_candidate = (
        prompt_execution_has_mulpri(planning_tokens, language, catalog)
        and len(integer_arguments) > 0
    )
    var table_candidate = table_plan.handled
    var owns_mulpri = mulpri_candidate
    var owns_table = table_candidate
    var raw_tokens = routing.raw_tokens.copy()
    if (routing.historical_echo or routing.numeric_default) and (
        owns_table or owns_mulpri
    ):
        if not historical_prompt_execution_supported(
            raw_tokens, planning_tokens, language, catalog
        ):
            owns_table = False
            owns_mulpri = False
    # Never execute one branch of a compound historical command while another
    # branch still belongs to the compatibility boundary.
    if table_plan.handled and not owns_table:
        owns_mulpri = False
    var fallback_required = (table_candidate or mulpri_candidate) and not (
        owns_table or owns_mulpri
    )
    return PromptExecutionTableOwnershipPlan(
        table_plan^,
        mulpri_candidate,
        table_candidate,
        owns_mulpri,
        owns_table,
        fallback_required,
        integer_arguments^,
    )


def plan_prompt_execution_routing(
    line: String,
    language: String,
    catalog: PromptLanguageCatalog,
    force_e_command: Bool = False,
) raises -> PromptExecutionRoutingPlan:
    """Plan the shared non-I/O front half of prompt command execution."""

    var raw_tokens = balanced_prompt_split(line)
    var compact_expansion = expand_compact_prompt_tokens(
        catalog,
        language,
        raw_tokens,
        False,
        force_e_command,
    )
    var normalized_tokens = expand_prompt_replacements(
        catalog, language, compact_expansion.tokens
    )
    var normalized_line = join_prompt_tokens(normalized_tokens)
    var command = classify_prompt_command_localized(
        normalized_line, language, catalog
    )
    var prepared = prepare_prompt_tokens(
        catalog,
        language,
        raw_tokens,
        False,
        force_e_command,
    )
    var historical_echo = prompt_execution_uses_historical_echo(
        raw_tokens, compact_expansion
    )
    var numeric_default = prompt_execution_is_pure_numeric_prompt(raw_tokens)
    var planning_tokens_are_prepared = (
        historical_echo
        or numeric_default
        or prompt_execution_contains_numeric_shortcut(
            raw_tokens, language, catalog
        )
    )
    var planning_tokens = (
        prepared.tokens.copy()
        if planning_tokens_are_prepared
        else normalized_tokens.copy()
    )
    var quiet_echo = prompt_execution_quiet_echo(
        planning_tokens, language, catalog
    )
    return PromptExecutionRoutingPlan(
        raw_tokens^,
        compact_expansion^,
        normalized_tokens^,
        normalized_line^,
        command^,
        prepared.tokens.copy(),
        historical_echo,
        numeric_default,
        planning_tokens_are_prepared,
        planning_tokens^,
        quiet_echo,
    )


@fieldwise_init
struct PromptExecutionSnapshot(Copyable, Equatable):
    var class_name: String
    var command_runner: String
    var fraction_manager: String
    var reta_executor: String
    var i18n_prompt: String


@fieldwise_init
struct PromptExecutionBundle(Copyable):
    var command_runner: String
    var command_runner_owner: String
    var fraction_manager: String
    var fraction_manager_owner: String
    var reta_executor: String
    var reta_executor_owner: String
    var i18n_prompt: String
    var helpers: PromptExecutionHelpersBundle
    var ownership_count: Int

    def snapshot(self) -> PromptExecutionSnapshot:
        return PromptExecutionSnapshot(
            "PromptExecutionBundle",
            self.command_runner.copy(),
            self.fraction_manager.copy(),
            self.reta_executor.copy(),
            self.i18n_prompt.copy(),
        )


def bootstrap_prompt_execution() -> PromptExecutionBundle:
    return PromptExecutionBundle(
        "PromptGrosseAusgabe",
        "prompt_execution_runtime.mojo",
        "bruchBereichsManagementAndWbefehl",
        "prompt_fraction_execution.mojo",
        "retaExecuteNprint",
        "native_reta_cli.mojo",
        "type",
        bootstrap_prompt_execution_helpers(),
        len(prompt_execution_owners()),
    )


def prompt_execution_bundle_valid(bundle: PromptExecutionBundle) -> Bool:
    return (
        bundle.command_runner == "PromptGrosseAusgabe"
        and bundle.command_runner_owner == "prompt_execution_runtime.mojo"
        and bundle.fraction_manager
        == "bruchBereichsManagementAndWbefehl"
        and bundle.fraction_manager_owner
        == "prompt_fraction_execution.mojo"
        and bundle.reta_executor == "retaExecuteNprint"
        and bundle.reta_executor_owner == "native_reta_cli.mojo"
        and bundle.i18n_prompt == "type"
        and bundle.helpers.source_owner
        == "reta_architecture.prompt_execution"
        and bundle.ownership_count == 22
    )


def prompt_execution_snapshot_json(
    snapshot: PromptExecutionSnapshot
) -> String:
    return (
        '{"class":"' + snapshot.class_name
        + '","command_runner":"' + snapshot.command_runner
        + '","fraction_manager":"' + snapshot.fraction_manager
        + '","reta_executor":"' + snapshot.reta_executor
        + '","i18n_prompt":"' + snapshot.i18n_prompt + '"}'
    )
