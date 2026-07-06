"""Native owner for the interactive ``prompt_interaction.py`` controller.

The terminal editor, prompt language, preparation and command execution already
have dedicated native owners.  This module owns the remaining mutable loop
boundary: startup-to-session activation, one-shot command assembly, input-mode
transitions, stored-command deletion and
history/previous-command policy.

It deliberately returns typed plans instead of printing or executing commands.
``prompt_main.mojo`` remains the thin process entry point and performs the
observable I/O requested by these plans.
"""

from std.collections import List
from .prompt_language import (
    PromptLanguageCatalog,
    balanced_prompt_split,
    localized_prompt_kind,
)
from .prompt_runtime import (
    PromptStartup,
    PromptCommand,
    classify_prompt_command_localized,
    effective_one_shot_tokens,
    join_prompt_tokens,
    KIND_EMPTY,
    KIND_EXIT,
    KIND_STORE_NEXT,
    KIND_STORE_PREVIOUS,
    KIND_OUTPUT_STORED,
    KIND_DELETE_STORED,
    KIND_HELP,
    KIND_COMMANDS,
    KIND_SHORT_COMMANDS,
    KIND_LOG_ON,
    KIND_LOG_OFF,
    KIND_CLEAR,
    KIND_PRIME,
    KIND_MULTIS,
    KIND_MULTIS3,
    KIND_MODULO,
    KIND_PRIME_COMPARE,
    KIND_DISTANCE,
    KIND_DISTANCE_PRIME,
    KIND_ABC,
    KIND_PRIME24,
    prime_lines,
    multis_lines,
    multis3_lines,
    modulo_lines,
    prime_comparison_lines,
    distance_lines,
    abc_line,
)
from .prompt_session import (
    NativePromptSession,
    new_prompt_session_for_language,
    store_prompt_text,
    stored_prompt_text,
    storage_payload,
    stored_prompt_numbered,
    delete_stored_selection,
)

from .prompt_reaction_dispatch import (
    PromptLoopControlDispatchPlan,
    PromptStoredCommandDispatchPlan,
    PromptLoggingDispatchPlan,
    PromptOneShotLoggingDispatchPlan,
    PromptTerminalClearDispatchPlan,
    PromptInformationalDispatchPlan,
    PromptSimpleOutputDispatchPlan,
    PromptStoredDefaultPlan,
    PromptInlineStoragePlan,
    PromptStorageOutputPlan,
    PromptStoredOutputExecutionPlan,
    PromptStoredDeletePlan,
    apply_inline_storage_command,
    plan_inline_storage_command,
    plan_inline_storage_output_command,
    plan_loop_control_dispatch,
    plan_stored_command_dispatch,
    plan_logging_dispatch,
    plan_one_shot_logging_dispatch,
    plan_terminal_clear_dispatch,
    plan_informational_dispatch,
    plan_simple_output_dispatch,
    plan_inline_stored_output_command,
    plan_stored_output_command,
    plan_stored_delete_command,
    plan_stored_default_command,
    prompt_reaction_dispatch_contract_snapshot,
)




comptime INTERACTION_EXECUTE = 0
comptime INTERACTION_CONTINUE = 1
comptime INTERACTION_EXIT = 2



@fieldwise_init
struct PromptInteractionInputPlan(Copyable):
    """Result of accepting one physical input line at the controller boundary."""

    var action: Int
    var command_line: String
    var output_lines: List[String]


@fieldwise_init
struct NativePromptInteraction(Copyable):
    """Mutable state formerly spread across ``retaPrompt.py`` globals."""

    var session: NativePromptSession
    var language: String
    var one_shot: Bool
    var show_intro: Bool





def _single_output(value: String) -> List[String]:
    var result = List[String]()
    result.append(value)
    return result^


def new_prompt_interaction(startup: PromptStartup) -> NativePromptInteraction:
    return NativePromptInteraction(
        new_prompt_session_for_language(
            startup.profile.logging_enabled,
            startup.profile.language,
        ),
        startup.profile.language,
        startup.profile.one_shot,
        startup.profile.show_intro,
    )


def prompt_interaction_one_shot_line(startup: PromptStartup) -> String:
    return join_prompt_tokens(effective_one_shot_tokens(startup))


def accept_prompt_input(
    mut interaction: NativePromptInteraction,
    line: String,
    catalog: PromptLanguageCatalog,
) raises -> PromptInteractionInputPlan:
    """Apply pre-dispatch session modes to one physical input line.

    Normal input is returned as ``INTERACTION_EXECUTE``.  Store/delete modes are
    completed here and return ``INTERACTION_CONTINUE`` with the exact lines that
    the process entry point must print.  Ctrl-C/Ctrl-D become an explicit exit
    plan, matching the old controller loop without leaking terminal sentinels
    into command classification.
    """

    if line == "\x04" or line == "\x03":
        return PromptInteractionInputPlan(
            INTERACTION_EXIT, "", List[String]()
        )

    if interaction.session.store_next:
        store_prompt_text(interaction.session, line)
        return PromptInteractionInputPlan(
            INTERACTION_CONTINUE,
            "",
            _single_output("Gespeichert: " + stored_prompt_text(interaction.session)),
        )

    if interaction.session.delete_next:
        var cancel = classify_prompt_command_localized(
            line, interaction.language, catalog
        )
        if cancel.kind == KIND_EXIT:
            interaction.session.delete_next = False
            return PromptInteractionInputPlan(
                INTERACTION_CONTINUE,
                "",
                _single_output("Löschen abgebrochen."),
            )
        delete_stored_selection(interaction.session, line)
        return PromptInteractionInputPlan(
            INTERACTION_CONTINUE,
            "",
            _single_output("Gespeichert: " + stored_prompt_text(interaction.session)),
        )

    var stored_default = plan_stored_default_command(
        line, interaction.session
    )
    if stored_default.handled:
        return PromptInteractionInputPlan(
            INTERACTION_EXECUTE, stored_default.command_line, List[String]()
        )

    return PromptInteractionInputPlan(
        INTERACTION_EXECUTE, line, List[String]()
    )


def prompt_command_updates_previous(kind: Int) -> Bool:
    """Return whether a dispatched command becomes the previous command."""

    return (
        kind != KIND_STORE_NEXT
        and kind != KIND_STORE_PREVIOUS
        and kind != KIND_OUTPUT_STORED
        and kind != KIND_DELETE_STORED
        and kind != KIND_LOG_ON
        and kind != KIND_LOG_OFF
    )


def prompt_line_updates_previous(
    line: String,
    kind: Int,
    language: String,
    catalog: PromptLanguageCatalog,
) raises -> Bool:
    """Apply previous-command policy to the complete physical prompt line.

    A compound ``S``/``s`` command can place its storage alias after the first
    word.  In that case the ordinary single-command classifier necessarily
    reports ``KIND_FALLBACK`` even though the interaction owner has already
    consumed the line as storage.  Re-plan the pure storage decision here so a
    handled suffix or middle alias cannot become the next ``s`` payload.
    """
    var tokens = balanced_prompt_split(line)
    if plan_inline_storage_command(tokens, language, catalog).handled:
        return False
    if plan_inline_storage_output_command(tokens, language, catalog).handled:
        return False
    return prompt_command_updates_previous(kind)


def record_prompt_command(
    mut interaction: NativePromptInteraction,
    line: String,
    kind: Int,
) -> None:
    if prompt_command_updates_previous(kind):
        interaction.session.previous_command = line


def record_prompt_line(
    mut interaction: NativePromptInteraction,
    line: String,
    kind: Int,
    language: String,
    catalog: PromptLanguageCatalog,
) raises -> None:
    """Record one executed line after compound interaction ownership checks."""
    if prompt_line_updates_previous(line, kind, language, catalog):
        interaction.session.previous_command = line


def prompt_interaction_contract_snapshot() -> List[String]:
    """Stable ownership snapshot for the prompt-reaction controller.

    Process-dispatch details intentionally live in
    ``prompt_process_dispatch_contract_snapshot``.  The interaction owner is the
    future prompt-reaction boundary: session lifecycle, storage, history,
    line acceptance and deterministic local effects only.
    """

    return [
        "class=PromptInteractionBundle",
        "startup=native-profile-to-session",
        "input=native-typed-plan",
        "store=native-next-and-previous",
        "delete=native-selection-and-cancel",
        "history=native-previous-command-policy",
        "inline_storage=native-position-and-history-policy",
        "storage_output=native-position-independent-addition-policy",
        "loop_control=native-empty-exit-loop-plan",
        "stored_command_dispatch=native-session-store-plan",
        "logging_dispatch=native-session-logging-plan",
        "one_shot_logging_dispatch=native-stateless-logging-plan",
        "terminal_clear_dispatch=native-terminal-clear-plan",
        "informational_dispatch=native-prompt-information-plan",
        "simple_output_dispatch=native-deterministic-prompt-output-plan",
        "stored_output_dispatch=native-session-output-execution-plan",
        "stored_delete_dispatch=native-session-delete-plan",
        "stored_default=native-empty-enter-placeholder-policy",
        "one_shot=native-token-assembly",
        "terminal=delegated-native-editor",
        "execution=delegated-native-dispatch",
    ]
