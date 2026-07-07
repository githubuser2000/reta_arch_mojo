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


@fieldwise_init
struct PromptExecutionNativeBranchCompletionPlan(Copyable):
    """Pure completion decision after native branch outcome planning.

    Interactive prompt execution and one-shot ``-befehl`` both need the same
    handled/fallback answer after table or mulpri rendering.  Interactive mode
    additionally applies the preplanned session logging mutation.  Keeping this
    shape in the prompt-execution owner prevents the controllers from peeking
    back into outcome internals.
    """

    var handled: Bool
    var fallback_required: Bool
    var session_logging: PromptExecutionSessionLoggingPlan


@fieldwise_init
struct PromptExecutionCompatibilityFallbackPlan(Copyable):
    """Pure compatibility-boundary dispatch plan for prompt branch completion.

    The controller owns the actual Python-reference call.  Prompt execution owns
    the decision that the untouched source spelling must cross that boundary.
    """

    var should_run: Bool
    var source: String


@fieldwise_init
struct PromptExecutionOneShotCompatibilityBoundaryPlan(Copyable):
    """Pure result for a one-shot native probe at compatibility boundaries.

    ``-befehl`` does not execute the Python fallback directly.  It only reports
    whether the native probe must stop so the main controller can enter the
    compatibility path with the untouched source spelling.
    """

    var stop_native_probe: Bool
    var handled_without_fallback: Bool
    var source: String


@fieldwise_init
struct PromptExecutionOneShotLoopControlResultPlan(Copyable):
    """Controller-facing result for bare one-shot loop-control commands.

    Empty input and explicit exit commands are owned before any table, process
    or compatibility probing.  Prompt execution owns the one-shot boolean
    projection so ``_run_native_one_shot`` no longer returns directly from the
    raw prompt-reaction loop-control dispatch flag.
    """

    var handled: Bool
    var stop_native_probe: Bool
    var continue_native_probe: Bool
    var source: String


@fieldwise_init
struct PromptExecutionOneShotPreNativeProbeResultPlan(Copyable):
    """Controller-facing gate between loop control and native branch probing.

    Bare one-shot loop-control commands have already been classified before any
    table, process or local prompt probing runs.  Prompt execution now owns the
    gate that either returns their handled value or continues into the native
    branch probe.
    """

    var handled: Bool
    var stop_native_probe: Bool
    var should_probe_native: Bool
    var result_owner: String
    var source: String


@fieldwise_init
struct PromptExecutionOneShotNativeCompletionResultPlan(Copyable):
    """Controller-facing result after a native one-shot branch completion.

    ``_run_native_one_shot`` uses the regular native branch planner first for
    table and compact numeric commands.  Once that completion plan is known,
    prompt execution owns the boolean projection: a handled completion stops the
    native probe successfully, while an unhandled completion continues into the
    remaining one-shot dispatchers.
    """

    var handled: Bool
    var stop_native_probe: Bool
    var continue_native_probe: Bool
    var source: String


@fieldwise_init
struct PromptExecutionOneShotCompatibilityResultPlan(Copyable):
    """Controller-facing result for the first one-shot compatibility boundary.

    After native table/mulpri probing, ``-befehl`` must either stop the native
    probe so the caller can enter the compatibility path, or continue with the
    remaining native one-shot dispatchers.  This result plan owns that return
    projection instead of leaving the controller to read the raw boundary flag.
    """

    var handled: Bool
    var stop_native_probe: Bool
    var continue_native_probe: Bool
    var source: String




@fieldwise_init
struct PromptExecutionOneShotNativeProbeResultPlan(Copyable):
    """Controller-facing result for the native one-shot branch probe.

    The native table/mulpri/logging branch first yields a completion plan.  If
    that completion is handled, the one-shot probe returns successfully.  If it
    instead requires compatibility, the native probe returns ``False`` so the
    caller can cross the historical Python boundary.  Only declined, non-fallback
    completions continue into local one-shot dispatchers.
    """

    var handled: Bool
    var stop_native_probe: Bool
    var continue_native_probe: Bool
    var fallback_required: Bool
    var result_owner: String
    var source: String




@fieldwise_init
struct PromptExecutionOneShotPostNativeProbeResultPlan(Copyable):
    """Controller-facing gate after the native one-shot branch probe.

    Native table/mulpri probing has already run any owned terminal effects in
    the controller.  Prompt execution now owns the next gate: stop immediately
    when the native/compatibility probe decided the result, or continue into
    local one-shot dispatchers when that probe declined ownership.
    """

    var handled: Bool
    var stop_native_probe: Bool
    var should_probe_local: Bool
    var result_owner: String
    var source: String


@fieldwise_init
struct PromptExecutionOneShotLocalResultPlan(Copyable):
    """Controller-facing result for local one-shot prompt dispatchers.

    Informational, terminal-clear, stateless logging and deterministic helper
    output branches all have the same one-shot result algebra after their
    owner-specific side effects have been printed.  Prompt execution owns that
    boolean projection so ``_run_native_one_shot`` does not directly return
    from each local dispatch branch.
    """

    var handled: Bool
    var continue_native_probe: Bool
    var source: String


@fieldwise_init
struct PromptExecutionOneShotLocalDispatchResultPlan(Copyable):
    """Controller-facing result for the combined local one-shot dispatch chain.

    The controller still performs the small terminal effects for informational,
    terminal-clear, one-shot logging and simple-output branches.  Prompt
    execution owns the precedence and final probe result so those branches no
    longer each form their own controller return island.
    """

    var handled: Bool
    var stop_native_probe: Bool
    var continue_native_probe: Bool
    var dispatch_owner: String
    var source: String


@fieldwise_init
struct PromptExecutionOneShotPostLocalProbeResultPlan(Copyable):
    """Controller-facing gate after local one-shot dispatchers.

    Local one-shot handlers have already performed their small terminal effects in
    the controller.  Prompt execution now owns the gate that either returns from
    those handled local branches or continues into the explicit external-process
    probe.
    """

    var handled: Bool
    var stop_native_probe: Bool
    var should_probe_external: Bool
    var result_owner: String
    var source: String


@fieldwise_init
struct PromptExecutionOneShotResidualResultPlan(Copyable):
    """Controller-facing result for the final one-shot residual boundary.

    The residual compatibility boundary owns whether the native ``-befehl``
    probe must stop.  This result plan owns the final boolean returned by the
    one-shot controller so it no longer returns directly from the raw boundary
    fields.
    """

    var handled: Bool
    var stop_native_probe: Bool
    var source: String


@fieldwise_init
struct PromptExecutionOneShotResidualProbePlan(Copyable):
    """Complete final residual one-shot probe result.

    After native table, local and explicit external dispatchers all decline a
    ``-befehl`` command, prompt execution owns the last compatibility fallback,
    the one-shot boundary around that fallback and the returned probe value as
    one pure projection.  The controller no longer has to assemble the final
    residual fallback and boundary by hand.
    """

    var result: PromptExecutionOneShotResidualResultPlan
    var fallback_required: Bool
    var source: String




@fieldwise_init
struct PromptExecutionOneShotProbePipelineGatePlan(Copyable):
    """Shared controller-facing gate for the one-shot probe pipeline.

    Earlier stages now produce typed phase results, but the controller still had
    to read each phase-specific ``should_probe_*`` field directly.  This shared
    gate normalizes the transitions between loop-control, native branch, local
    dispatch, external process and final residual probing while keeping all
    side-effecting work in the controller.
    """

    var handled: Bool
    var stop_native_probe: Bool
    var continue_pipeline: Bool
    var result_owner: String
    var next_phase: String
    var source: String


@fieldwise_init
struct PromptExecutionOneShotFinalProbeResultPlan(Copyable):
    """Final controller-facing result for the one-shot native probe.

    External process probing may either stop the native ``-befehl`` probe or
    decline it and let the residual compatibility edge decide.  Prompt
    execution now owns that last arbitration, so ``_run_native_one_shot`` no
    longer returns directly from the external-process result or assembles the
    residual probe itself.
    """

    var handled: Bool
    var stop_native_probe: Bool
    var result_owner: String
    var source: String


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


def plan_prompt_execution_native_branch_completion(
    outcome: PromptExecutionNativeBranchOutcomePlan, current_logging_enabled: Bool
) -> PromptExecutionNativeBranchCompletionPlan:
    """Plan controller-visible completion for a native branch outcome."""

    return PromptExecutionNativeBranchCompletionPlan(
        outcome.handled,
        outcome.fallback_required,
        plan_prompt_execution_session_logging_update(
            outcome, current_logging_enabled
        ),
    )


def plan_prompt_execution_compatibility_fallback(
    completion: PromptExecutionNativeBranchCompletionPlan, source: String
) -> PromptExecutionCompatibilityFallbackPlan:
    """Plan whether the prompt line must cross the compatibility boundary."""

    return PromptExecutionCompatibilityFallbackPlan(
        completion.fallback_required, source
    )

def plan_prompt_execution_one_shot_compatibility_boundary(
    fallback: PromptExecutionCompatibilityFallbackPlan, handled_when_no_fallback: Bool
) -> PromptExecutionOneShotCompatibilityBoundaryPlan:
    """Plan how ``-befehl`` leaves or continues the native probe.

    Interactive prompt execution can immediately run the compatibility command.
    The one-shot probe has to return a boolean to its caller instead.  Keeping
    that stop/continue answer here prevents the one-shot controller from
    reinterpreting the generic compatibility fallback shape by itself.
    """

    return PromptExecutionOneShotCompatibilityBoundaryPlan(
        fallback.should_run,
        (not fallback.should_run) and handled_when_no_fallback,
        fallback.source,
    )


def plan_prompt_execution_residual_compatibility_fallback(
    source: String
) -> PromptExecutionCompatibilityFallbackPlan:
    """Plan the final unowned-command compatibility boundary.

    Earlier native dispatchers may accept informational, terminal, simple-output
    and external-process commands.  If none of them handles the prompt line, the
    untouched source spelling still belongs to the prompt-execution owner before
    the controller calls the Python reference boundary.
    """

    return PromptExecutionCompatibilityFallbackPlan(True, source)



def plan_prompt_execution_one_shot_loop_control_result(
    loop_control_handled: Bool, source: String
) -> PromptExecutionOneShotLoopControlResultPlan:
    """Plan the one-shot return value after bare loop-control dispatch.

    A handled empty/exit prompt line is already fully owned by the prompt
    reaction layer.  This plan turns that raw dispatch flag into the probe
    result: handled loop-control commands stop successfully, otherwise the
    one-shot controller continues into normal native execution probing.
    """

    if loop_control_handled:
        return PromptExecutionOneShotLoopControlResultPlan(
            True, True, False, source
        )
    return PromptExecutionOneShotLoopControlResultPlan(
        False, False, True, source
    )



def plan_prompt_execution_one_shot_pre_native_probe_result(
    loop_control: PromptExecutionOneShotLoopControlResultPlan,
) -> PromptExecutionOneShotPreNativeProbeResultPlan:
    """Plan the one-shot gate between loop control and native probing.

    This owns the controller decision that previously returned directly from
    ``loop_control_result``.  If loop control did not consume the command, the
    pipeline proceeds to the native table/mulpri branch probe.
    """

    if loop_control.stop_native_probe:
        return PromptExecutionOneShotPreNativeProbeResultPlan(
            loop_control.handled,
            True,
            False,
            "loop_control",
            loop_control.source,
        )
    return PromptExecutionOneShotPreNativeProbeResultPlan(
        False, False, True, "native_branch", loop_control.source
    )



def plan_prompt_execution_one_shot_native_completion_result(
    completion: PromptExecutionNativeBranchCompletionPlan, source: String
) -> PromptExecutionOneShotNativeCompletionResultPlan:
    """Plan the one-shot return value after native branch completion.

    A completed native table/mulpri/logging branch has already performed its
    terminal effects in the controller.  This plan owns the remaining decision:
    return ``True`` for handled branches or continue probing for local one-shot
    dispatchers when the branch declined ownership.
    """

    if completion.handled:
        return PromptExecutionOneShotNativeCompletionResultPlan(
            True, True, False, source
        )
    return PromptExecutionOneShotNativeCompletionResultPlan(
        False, False, True, source
    )


def plan_prompt_execution_one_shot_compatibility_result(
    boundary: PromptExecutionOneShotCompatibilityBoundaryPlan,
) -> PromptExecutionOneShotCompatibilityResultPlan:
    """Plan the first one-shot compatibility-boundary return value.

    A required fallback means the native probe must return ``False`` immediately
    so the main one-shot caller can cross the historical compatibility boundary.
    Otherwise probing may continue with the non-table native dispatchers.
    """

    if boundary.stop_native_probe:
        return PromptExecutionOneShotCompatibilityResultPlan(
            False, True, False, boundary.source
        )
    return PromptExecutionOneShotCompatibilityResultPlan(
        boundary.handled_without_fallback, False, True, boundary.source
    )




def plan_prompt_execution_one_shot_native_probe_result(
    completion: PromptExecutionNativeBranchCompletionPlan, source: String
) -> PromptExecutionOneShotNativeProbeResultPlan:
    """Plan the combined native-branch probe result for one-shot mode.

    This owner replaces the controller's hand-built sequence of native
    completion, compatibility fallback, compatibility boundary and boundary
    result.  It keeps the same stop/continue algebra visible while letting
    ``_run_native_one_shot`` consume one pure value before local dispatch.
    """

    var completion_result = plan_prompt_execution_one_shot_native_completion_result(
        completion, source
    )
    if completion_result.stop_native_probe:
        return PromptExecutionOneShotNativeProbeResultPlan(
            completion_result.handled,
            True,
            False,
            False,
            "native_completion",
            completion_result.source,
        )

    var fallback = plan_prompt_execution_compatibility_fallback(
        completion, source
    )
    var boundary = plan_prompt_execution_one_shot_compatibility_boundary(
        fallback, False
    )
    var compatibility_result = plan_prompt_execution_one_shot_compatibility_result(
        boundary
    )
    if compatibility_result.stop_native_probe:
        return PromptExecutionOneShotNativeProbeResultPlan(
            compatibility_result.handled,
            True,
            False,
            fallback.should_run,
            "compatibility_boundary",
            compatibility_result.source,
        )
    return PromptExecutionOneShotNativeProbeResultPlan(
        compatibility_result.handled,
        False,
        True,
        fallback.should_run,
        "local_dispatch",
        compatibility_result.source,
    )


def plan_prompt_execution_one_shot_post_native_probe_result(
    native_probe: PromptExecutionOneShotNativeProbeResultPlan,
) -> PromptExecutionOneShotPostNativeProbeResultPlan:
    """Plan the one-shot gate between native probing and local dispatch.

    This owns the controller decision that previously returned directly from
    ``native_probe_result``.  If native probing did not finish or require
    fallback, the pipeline proceeds to informational, terminal and simple-output
    local dispatchers.
    """

    if native_probe.stop_native_probe:
        return PromptExecutionOneShotPostNativeProbeResultPlan(
            native_probe.handled,
            True,
            False,
            native_probe.result_owner,
            native_probe.source,
        )
    return PromptExecutionOneShotPostNativeProbeResultPlan(
        False, False, True, "local_dispatch", native_probe.source
    )






def plan_prompt_execution_one_shot_local_result(
    local_handled: Bool, source: String
) -> PromptExecutionOneShotLocalResultPlan:
    """Plan the one-shot return value after a local native dispatcher.

    Local dispatchers may already have performed their small terminal effect in
    the controller.  This owner turns their handled flag into the probe result:
    handled local commands stop successfully, declined local commands let the
    remaining native probe continue.
    """

    return PromptExecutionOneShotLocalResultPlan(
        local_handled, not local_handled, source
    )


def plan_prompt_execution_one_shot_local_dispatch_result(
    info_handled: Bool,
    terminal_clear_handled: Bool,
    logging_handled: Bool,
    simple_output_handled: Bool,
    source: String,
) -> PromptExecutionOneShotLocalDispatchResultPlan:
    """Plan the combined local one-shot dispatch result and precedence.

    The historical controller tries local one-shot handlers in a fixed order:
    informational help/command output, terminal clearing, one-shot logging and
    finally deterministic simple output.  This owner records that precedence and
    returns a single probe decision for the controller.
    """

    if info_handled:
        return PromptExecutionOneShotLocalDispatchResultPlan(
            True, True, False, "informational", source
        )
    if terminal_clear_handled:
        return PromptExecutionOneShotLocalDispatchResultPlan(
            True, True, False, "terminal_clear", source
        )
    if logging_handled:
        return PromptExecutionOneShotLocalDispatchResultPlan(
            True, True, False, "one_shot_logging", source
        )
    if simple_output_handled:
        return PromptExecutionOneShotLocalDispatchResultPlan(
            True, True, False, "simple_output", source
        )
    return PromptExecutionOneShotLocalDispatchResultPlan(
        False, False, True, "none", source
    )


def plan_prompt_execution_one_shot_post_local_probe_result(
    local_dispatch: PromptExecutionOneShotLocalDispatchResultPlan,
) -> PromptExecutionOneShotPostLocalProbeResultPlan:
    """Plan the one-shot gate after local dispatchers.

    This owns the controller decision that previously returned immediately from
    ``local_dispatch_result``.  If no local branch handled the line, the pipeline
    continues to the external process owner.
    """

    if local_dispatch.stop_native_probe:
        return PromptExecutionOneShotPostLocalProbeResultPlan(
            local_dispatch.handled,
            True,
            False,
            "local_dispatch",
            local_dispatch.source,
        )
    return PromptExecutionOneShotPostLocalProbeResultPlan(
        False, False, True, "external_process", local_dispatch.source
    )



def plan_prompt_execution_one_shot_residual_result(
    boundary: PromptExecutionOneShotCompatibilityBoundaryPlan,
) -> PromptExecutionOneShotResidualResultPlan:
    """Plan the final one-shot residual return value.

    This is the final projection in ``_run_native_one_shot`` after all native
    dispatchers declined a command.  The controller can now consume one result
    value instead of interpreting ``stop_native_probe`` and
    ``handled_without_fallback`` directly.
    """

    if boundary.stop_native_probe:
        return PromptExecutionOneShotResidualResultPlan(
            False, True, boundary.source
        )
    return PromptExecutionOneShotResidualResultPlan(
        boundary.handled_without_fallback, False, boundary.source
    )


def plan_prompt_execution_one_shot_residual_probe(
    source: String,
) -> PromptExecutionOneShotResidualProbePlan:
    """Plan the complete final one-shot residual compatibility probe.

    This combines the residual compatibility fallback, the final one-shot
    compatibility boundary and its returned result.  It keeps the final
    ``-befehl`` compatibility edge inside prompt execution, leaving the
    controller with one value to consume.
    """

    var fallback = plan_prompt_execution_residual_compatibility_fallback(source)
    var boundary = plan_prompt_execution_one_shot_compatibility_boundary(
        fallback, True
    )
    var result = plan_prompt_execution_one_shot_residual_result(boundary)
    return PromptExecutionOneShotResidualProbePlan(
        result^, fallback.should_run, fallback.source
    )


def plan_prompt_execution_one_shot_final_probe_result(
    external_handled: Bool, external_continue_native_probe: Bool, source: String
) -> PromptExecutionOneShotFinalProbeResultPlan:
    """Plan the final arbitration after one-shot external process probing.

    If the external process owner already stopped the native probe, the
    controller should return its handled value.  Otherwise prompt execution
    constructs and consumes the residual compatibility probe internally, keeping
    the final ``-befehl`` return edge in one owner.
    """

    if not external_continue_native_probe:
        return PromptExecutionOneShotFinalProbeResultPlan(
            external_handled, True, "external_process", source
        )

    var residual_probe = plan_prompt_execution_one_shot_residual_probe(source)
    return PromptExecutionOneShotFinalProbeResultPlan(
        residual_probe.result.handled,
        residual_probe.result.stop_native_probe,
        "residual_probe",
        residual_probe.source,
    )



def plan_prompt_execution_one_shot_pipeline_pre_native_gate(
    pre_native: PromptExecutionOneShotPreNativeProbeResultPlan,
) -> PromptExecutionOneShotProbePipelineGatePlan:
    """Normalize the loop-control/pre-native one-shot pipeline transition."""

    if pre_native.stop_native_probe:
        return PromptExecutionOneShotProbePipelineGatePlan(
            pre_native.handled,
            True,
            False,
            pre_native.result_owner,
            "return",
            pre_native.source,
        )
    return PromptExecutionOneShotProbePipelineGatePlan(
        False, False, True, pre_native.result_owner, "native_branch", pre_native.source
    )


def plan_prompt_execution_one_shot_pipeline_post_native_gate(
    post_native: PromptExecutionOneShotPostNativeProbeResultPlan,
) -> PromptExecutionOneShotProbePipelineGatePlan:
    """Normalize the native-branch/local-dispatch one-shot transition."""

    if post_native.stop_native_probe:
        return PromptExecutionOneShotProbePipelineGatePlan(
            post_native.handled,
            True,
            False,
            post_native.result_owner,
            "return",
            post_native.source,
        )
    return PromptExecutionOneShotProbePipelineGatePlan(
        False, False, True, post_native.result_owner, "local_dispatch", post_native.source
    )


def plan_prompt_execution_one_shot_pipeline_post_local_gate(
    post_local: PromptExecutionOneShotPostLocalProbeResultPlan,
) -> PromptExecutionOneShotProbePipelineGatePlan:
    """Normalize the local-dispatch/external-process one-shot transition."""

    if post_local.stop_native_probe:
        return PromptExecutionOneShotProbePipelineGatePlan(
            post_local.handled,
            True,
            False,
            post_local.result_owner,
            "return",
            post_local.source,
        )
    return PromptExecutionOneShotProbePipelineGatePlan(
        False, False, True, post_local.result_owner, "external_process", post_local.source
    )


def plan_prompt_execution_one_shot_pipeline_final_gate(
    final_probe: PromptExecutionOneShotFinalProbeResultPlan,
) -> PromptExecutionOneShotProbePipelineGatePlan:
    """Normalize the terminal one-shot probe result as a pipeline gate."""

    return PromptExecutionOneShotProbePipelineGatePlan(
        final_probe.handled,
        final_probe.stop_native_probe,
        False,
        final_probe.result_owner,
        "return",
        final_probe.source,
    )


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
