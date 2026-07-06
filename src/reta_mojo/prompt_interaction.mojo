"""Native owner for the interactive ``prompt_interaction.py`` controller.

The terminal editor, prompt language, preparation and command execution already
have dedicated native owners.  This module owns the remaining mutable loop
boundary: startup-to-session activation, one-shot command assembly, input-mode
transitions, stored-command deletion, fallback child argv planning and
history/previous-command policy.

It deliberately returns typed plans instead of printing or executing commands.
``prompt_main.mojo`` remains the thin process entry point and performs the
observable I/O requested by these plans.
"""

from std.collections import List
from std.collections.string import StringSlice
from .prompt_external_commands import shell_split
from .prompt_language import (
    PromptLanguageCatalog,
    balanced_prompt_split,
    localized_prompt_kind,
)
from .prompt_runtime import (
    PromptStartup,
    PromptProfile,
    PromptCommand,
    classify_prompt_command_localized,
    effective_one_shot_tokens,
    join_prompt_tokens,
    fallback_profile_arguments,
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
    KIND_SHELL,
    KIND_PYTHON,
    KIND_MATH,
    KIND_RETA,
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



@fieldwise_init
struct PromptLoopControlDispatchPlan(Copyable):
    """Executable plan for bare prompt loop control commands."""

    var handled: Bool
    var continue_loop: Bool



@fieldwise_init
struct PromptStoredCommandDispatchPlan(Copyable):
    """Executable plan for single-word ``S``/``s`` storage dispatch."""

    var handled: Bool
    var output_lines: List[String]


@fieldwise_init
struct PromptLoggingDispatchPlan(Copyable):
    """Executable plan for single-word prompt logging dispatch."""

    var handled: Bool
    var output_lines: List[String]


@fieldwise_init
struct PromptOneShotLoggingDispatchPlan(Copyable):
    """Stateless one-shot plan for logging commands."""

    var handled: Bool
    var output_lines: List[String]


@fieldwise_init
struct PromptTerminalClearDispatchPlan(Copyable):
    """Executable plan for standalone prompt terminal clear dispatch."""

    var handled: Bool
    var clear_terminal: Bool
    var output_lines: List[String]


@fieldwise_init
struct PromptInformationalDispatchPlan(Copyable):
    """Executable plan for standalone prompt information commands."""

    var handled: Bool
    var show_help: Bool
    var show_commands: Bool
    var show_short_commands: Bool


@fieldwise_init
struct PromptSimpleOutputDispatchPlan(Copyable):
    """Executable plan for deterministic prompt output commands."""

    var handled: Bool
    var output_lines: List[String]


@fieldwise_init
struct PromptExternalProcessDispatchPlan(Copyable):
    """Executable plan for prompt commands that cross a process boundary."""

    var handled: Bool
    var payload: String
    var arguments: List[String]
    var run_shell: Bool
    var run_python: Bool
    var run_math: Bool
    var run_reta: Bool


@fieldwise_init
struct PromptFallbackProcessDispatchPlan(Copyable):
    """Executable argv plan for the atomic Python prompt fallback child."""

    var handled: Bool
    var run_reta_prompt: Bool
    var profile_arguments: List[String]
    var command_arguments: List[String]


@fieldwise_init
struct PromptStoredDefaultPlan(Copyable):
    """Empty-line execution of the stored prompt placeholder."""

    var handled: Bool
    var command_line: String


@fieldwise_init
struct PromptInlineStoragePlan(Copyable):
    """Position-independent compound ``S``/``s`` storage decision."""

    var handled: Bool
    var payload: String


@fieldwise_init
struct PromptStorageOutputPlan(Copyable):
    """Position-independent stored-command output/addition decision."""

    var handled: Bool
    var payload: String


@fieldwise_init
struct PromptStoredOutputExecutionPlan(Copyable):
    """Executable plan for ``o``/stored-command output dispatch."""

    var handled: Bool
    var command_line: String
    var output_lines: List[String]


@fieldwise_init
struct PromptStoredDeletePlan(Copyable):
    """Executable plan for ``l``/stored-command deletion dispatch."""

    var handled: Bool
    var output_lines: List[String]


def _token_list_contains(values: List[String], token: String) -> Bool:
    for index in range(len(values)):
        if values[index] == token:
            return True
    return False


def plan_inline_storage_command(
    tokens: List[String],
    language: String,
    catalog: PromptLanguageCatalog,
) -> PromptInlineStoragePlan:
    """Mirror the historical set-based compound storage branch.

    Exactly one distinct save-after/save-before alias must occur together with
    at least one non-storage token.  The alias may stand anywhere.  As in the
    Python ``for token in save_all: storage_text.remove(token)`` loop, only the
    first occurrence of the selected alias is removed; duplicate occurrences
    remain part of the stored payload.  Any ``abc``/``abcd`` token disables the
    storage branch so the exceptional two-word alphabet command keeps priority.
    """
    var selected = ""
    var ambiguous = False
    var has_non_storage = False
    var has_abc = False

    for index in range(len(tokens)):
        var token = tokens[index]
        var kind = localized_prompt_kind(catalog, language, token)
        if kind == KIND_ABC:
            has_abc = True
        if kind == KIND_STORE_NEXT or kind == KIND_STORE_PREVIOUS:
            if selected.byte_length() == 0:
                selected = token
            elif selected != token:
                ambiguous = True
        else:
            has_non_storage = True

    if (
        has_abc
        or ambiguous
        or selected.byte_length() == 0
        or not has_non_storage
    ):
        return PromptInlineStoragePlan(False, "")

    var payload_tokens = List[String]()
    var removed = False
    for index in range(len(tokens)):
        if not removed and tokens[index] == selected:
            removed = True
            continue
        payload_tokens.append(tokens[index])
    return PromptInlineStoragePlan(
        True, join_prompt_tokens(payload_tokens)
    )


def apply_inline_storage_command(
    mut session: NativePromptSession,
    tokens: List[String],
    language: String,
    catalog: PromptLanguageCatalog,
) -> Bool:
    """Store a wholly-owned compound storage command without executing it."""
    var plan = plan_inline_storage_command(tokens, language, catalog)
    if not plan.handled:
        return False
    store_prompt_text(session, plan.payload)
    return True


def plan_inline_storage_output_command(
    tokens: List[String],
    language: String,
    catalog: PromptLanguageCatalog,
) -> PromptStorageOutputPlan:
    """Plan ``o``/``BefehlSpeicherungAusgeben`` at any word position.

    The Python controller recognizes a single output alias as a prompt mode and
    also recognizes a mixed command when more than one distinct non-output token
    accompanies that alias.  The latter Python path currently leaks
    ``text_state.liste`` as a list into a string concatenation; the native owner
    keeps the same trigger boundary but carries the addition as typed text.
    Exactly one selected output alias is removed from the payload, matching the
    prefix ``storage_payload`` contract already used by ``prompt_main.mojo``.
    """
    var selected = ""
    var ambiguous = False
    var has_abc = False
    var distinct_payload_tokens = List[String]()

    for index in range(len(tokens)):
        var token = tokens[index]
        var kind = localized_prompt_kind(catalog, language, token)
        if kind == KIND_ABC:
            has_abc = True
        if kind == KIND_OUTPUT_STORED:
            if selected.byte_length() == 0:
                selected = token
            elif selected != token:
                ambiguous = True
        else:
            if not _token_list_contains(distinct_payload_tokens, token):
                distinct_payload_tokens.append(token)

    if has_abc or ambiguous or selected.byte_length() == 0:
        return PromptStorageOutputPlan(False, "")
    if len(tokens) == 1:
        return PromptStorageOutputPlan(True, "")
    if len(distinct_payload_tokens) <= 1:
        return PromptStorageOutputPlan(False, "")

    var payload_tokens = List[String]()
    var removed = False
    for index in range(len(tokens)):
        if not removed and tokens[index] == selected:
            removed = True
            continue
        payload_tokens.append(tokens[index])
    return PromptStorageOutputPlan(
        True, join_prompt_tokens(payload_tokens)
    )


def _single_output(value: String) -> List[String]:
    var result = List[String]()
    result.append(value)
    return result^


def _plan_stored_output_payload(
    stored: String,
    addition: String,
) -> PromptStoredOutputExecutionPlan:
    if stored.byte_length() == 0:
        return PromptStoredOutputExecutionPlan(
            True, "", _single_output("Kein Befehl gespeichert.")
        )
    var command_line = stored
    if addition.byte_length() > 0:
        command_line += " " + addition
    return PromptStoredOutputExecutionPlan(
        True, command_line^, List[String]()
    )


def plan_loop_control_dispatch(
    command: PromptCommand,
) -> PromptLoopControlDispatchPlan:
    """Plan empty-line and exit prompt controls in the interaction owner.

    Empty commands are successful no-ops and keep the interactive loop alive.
    Exit commands are successful controls too, but the interactive caller must
    terminate the loop.  One-shot execution can use the same typed plan and
    only needs the handled flag to avoid falling through to compatibility.
    """
    if command.kind == KIND_EMPTY:
        return PromptLoopControlDispatchPlan(True, True)
    if command.kind == KIND_EXIT:
        return PromptLoopControlDispatchPlan(True, False)
    return PromptLoopControlDispatchPlan(False, True)


def plan_stored_command_dispatch(
    command: PromptCommand,
    mut session: NativePromptSession,
) -> PromptStoredCommandDispatchPlan:
    """Plan single-word store-next/store-previous commands in the interaction owner.

    Compound storage with payload is handled by ``apply_inline_storage_command``
    before command classification.  The remaining historical prefix commands
    are exactly the bare save-next and save-previous controls.  Moving these
    state transitions out of ``prompt_main.mojo`` keeps all prompt store
    lifecycle mutations in one typed owner.
    """
    if command.kind == KIND_STORE_NEXT and len(command.words) == 1:
        session.store_next = True
        return PromptStoredCommandDispatchPlan(
            True, _single_output("Der nächste Befehl wird gespeichert.")
        )
    if command.kind == KIND_STORE_PREVIOUS and len(command.words) == 1:
        var payload = session.previous_command
        if payload.byte_length() > 0:
            store_prompt_text(session, payload)
            return PromptStoredCommandDispatchPlan(
                True, _single_output("Gespeichert: " + stored_prompt_text(session))
            )
        return PromptStoredCommandDispatchPlan(True, List[String]())
    return PromptStoredCommandDispatchPlan(False, List[String]())


def _logging_output_lines(command: PromptCommand) -> List[String]:
    if command.kind == KIND_LOG_ON and len(command.words) == 1:
        return _single_output("Logging ist eingeschaltet.")
    if command.kind == KIND_LOG_OFF and len(command.words) == 1:
        return _single_output("Logging ist ausgeschaltet.")
    return List[String]()


def plan_logging_dispatch(
    command: PromptCommand,
    mut session: NativePromptSession,
) -> PromptLoggingDispatchPlan:
    """Plan single-word prompt logging commands in the interaction owner.

    Historical table companion logging remains in ``prompt_historical_ownership``
    because it composes with table plans.  Bare ``loggen``/``nichtloggen`` is a
    prompt-session mutation, so keep it beside the other interactive lifecycle
    state instead of open-coding it in the process controller.
    """
    var output_lines = _logging_output_lines(command)
    if len(output_lines) == 0:
        return PromptLoggingDispatchPlan(False, List[String]())
    if command.kind == KIND_LOG_ON:
        session.logging_enabled = True
    elif command.kind == KIND_LOG_OFF:
        session.logging_enabled = False
    return PromptLoggingDispatchPlan(True, output_lines^)


def plan_one_shot_logging_dispatch(
    command: PromptCommand,
) -> PromptOneShotLoggingDispatchPlan:
    """Plan one-shot logging commands without process-controller branches.

    A one-shot prompt has no durable interactive session to mutate, but the
    historical observable result is still the localized logging message.  Keep
    that classification beside the session logging owner so ``prompt_main.mojo``
    only prints the returned lines.
    """
    var output_lines = _logging_output_lines(command)
    if len(output_lines) == 0:
        return PromptOneShotLoggingDispatchPlan(False, List[String]())
    return PromptOneShotLoggingDispatchPlan(True, output_lines^)


def plan_terminal_clear_dispatch(
    command: PromptCommand,
) -> PromptTerminalClearDispatchPlan:
    """Plan standalone ANSI terminal clear in the interaction owner.

    Compound ``leeren``/``clear`` inside historical table commands is already
    owned by ``prompt_historical_ownership`` because it emits rows+1 blank
    lines before the table.  Bare clear is a prompt-controller terminal effect;
    return an explicit effect flag so the process entry point only performs the
    I/O requested by this typed plan.
    """
    if command.kind == KIND_CLEAR:
        return PromptTerminalClearDispatchPlan(True, True, List[String]())
    return PromptTerminalClearDispatchPlan(False, False, List[String]())


def plan_informational_dispatch(
    command: PromptCommand,
) -> PromptInformationalDispatchPlan:
    """Plan standalone prompt information commands in the interaction owner.

    Historical table companion effects stay in ``prompt_historical_ownership``
    because they compose with table planning.  Bare ``hilfe``/``befehle``/
    ``kurzbefehle`` is a prompt-controller decision, so expose exact rendering
    flags instead of open-coding the command-kind branch in the process entry
    point.
    """
    if command.kind == KIND_HELP:
        return PromptInformationalDispatchPlan(True, True, False, False)
    if command.kind == KIND_COMMANDS:
        return PromptInformationalDispatchPlan(True, False, True, False)
    if command.kind == KIND_SHORT_COMMANDS:
        return PromptInformationalDispatchPlan(True, False, False, True)
    return PromptInformationalDispatchPlan(False, False, False, False)


def _maybe_single_output(value: String) -> List[String]:
    if value.byte_length() == 0:
        return List[String]()
    return _single_output(value)


def plan_simple_output_dispatch(
    command: PromptCommand, language: String
) raises -> PromptSimpleOutputDispatchPlan:
    """Plan deterministic bare prompt output commands in the interaction owner.

    These branches used to be repeated in both the interactive loop and the
    one-shot path.  They do not need process-controller state: the runtime
    owner computes exact output lines, and the process entry point only prints
    the typed plan.  Shell/Python/math/reta execution stays outside because it
    is an operating-system or full CLI boundary.
    """
    if command.kind == KIND_PRIME:
        return PromptSimpleOutputDispatchPlan(True, prime_lines(command))
    if command.kind == KIND_PRIME24:
        return PromptSimpleOutputDispatchPlan(True, prime_lines(command, True))
    if command.kind == KIND_MULTIS:
        return PromptSimpleOutputDispatchPlan(True, multis_lines(command))
    if command.kind == KIND_MULTIS3:
        return PromptSimpleOutputDispatchPlan(True, multis3_lines(command))
    if command.kind == KIND_MODULO:
        return PromptSimpleOutputDispatchPlan(True, modulo_lines(command))
    if command.kind == KIND_PRIME_COMPARE:
        return PromptSimpleOutputDispatchPlan(
            True, prime_comparison_lines(command, language)
        )
    if command.kind == KIND_DISTANCE:
        return PromptSimpleOutputDispatchPlan(
            True, distance_lines(command, False, language)
        )
    if command.kind == KIND_DISTANCE_PRIME:
        return PromptSimpleOutputDispatchPlan(
            True, distance_lines(command, True, language)
        )
    if command.kind == KIND_ABC:
        return PromptSimpleOutputDispatchPlan(
            True, _maybe_single_output(abc_line(command))
        )
    return PromptSimpleOutputDispatchPlan(False, List[String]())


def _prompt_command_arguments(command: PromptCommand) -> List[String]:
    var result = List[String]()
    for index in range(1, len(command.words)):
        result.append(command.words[index])
    return result^


def _prompt_raw_slice(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def _prompt_command_payload(command: PromptCommand) -> String:
    """Return the exact raw text after the first prompt command token."""
    var bytes = command.raw.as_bytes()
    for index in range(len(bytes)):
        if Int(bytes[index]) == 32:
            return _prompt_raw_slice(command.raw, index + 1, len(bytes))
    return ""


def plan_external_process_dispatch(
    command: PromptCommand,
) -> PromptExternalProcessDispatchPlan:
    """Plan prompt commands that intentionally cross a process boundary.

    The process entry point still owns the actual shell/Python/math/reta I/O,
    but command-kind routing now lives beside the other interaction dispatch
    decisions.  One-shot execution can use the same plan and accept only the
    natively supported reta subset before falling back atomically.
    """
    if command.kind == KIND_SHELL:
        return PromptExternalProcessDispatchPlan(
            True,
            _prompt_command_payload(command),
            List[String](),
            True,
            False,
            False,
            False,
        )
    if command.kind == KIND_PYTHON:
        return PromptExternalProcessDispatchPlan(
            True,
            _prompt_command_payload(command),
            List[String](),
            False,
            True,
            False,
            False,
        )
    if command.kind == KIND_MATH:
        return PromptExternalProcessDispatchPlan(
            True,
            _prompt_command_payload(command),
            List[String](),
            False,
            False,
            True,
            False,
        )
    if command.kind == KIND_RETA:
        return PromptExternalProcessDispatchPlan(
            True,
            "",
            _prompt_command_arguments(command),
            False,
            False,
            False,
            True,
        )
    return PromptExternalProcessDispatchPlan(
        False,
        "",
        List[String](),
        False,
        False,
        False,
        False,
    )


def plan_prompt_fallback_process_dispatch(
    profile: PromptProfile,
    line: String,
) raises -> PromptFallbackProcessDispatchPlan:
    """Plan an unowned prompt command as explicit retaPrompt.py argv.

    The controller still preserves the original line for historical echo and
    atomic fallback decisions, but the interaction owner now owns conversion to
    the child-process argument vector.  The process adapter only receives argv.
    """
    return PromptFallbackProcessDispatchPlan(
        True, True, fallback_profile_arguments(profile), shell_split(line)
    )


def plan_stored_output_command(
    command: PromptCommand,
    session: NativePromptSession,
) -> PromptStoredOutputExecutionPlan:
    """Plan classified ``o`` execution without process-controller state logic.

    The process entry point still prints and dispatches, but the interaction
    owner now decides whether a stored command exists and which exact command
    line must be executed when an addition follows the output alias.
    """
    if command.kind != KIND_OUTPUT_STORED:
        return PromptStoredOutputExecutionPlan(
            False, "", List[String]()
        )
    return _plan_stored_output_payload(
        stored_prompt_text(session),
        storage_payload(command),
    )


def plan_inline_stored_output_command(
    tokens: List[String],
    session: NativePromptSession,
    language: String,
    catalog: PromptLanguageCatalog,
) -> PromptStoredOutputExecutionPlan:
    """Plan position-independent stored-output execution.

    This consumes the already-owned inline ``o`` boundary and returns either a
    printable no-storage line or the exact command line that should be executed
    with the stored prompt as prefix.
    """
    var inline_output = plan_inline_storage_output_command(
        tokens, language, catalog
    )
    if not inline_output.handled:
        return PromptStoredOutputExecutionPlan(
            False, "", List[String]()
        )
    return _plan_stored_output_payload(
        stored_prompt_text(session),
        inline_output.payload,
    )




def plan_stored_delete_command(
    command: PromptCommand,
    mut session: NativePromptSession,
) raises -> PromptStoredDeletePlan:
    """Plan classified ``l`` deletion without process-controller state logic.

    A command with a payload deletes immediately and reports the remaining
    stored command text.  A bare delete command either prints the empty-storage
    diagnostic or shows the numbered prompt store and switches the session into
    selection mode.  ``accept_prompt_input`` already owns that subsequent
    selection lifecycle; this function moves the initial dispatch decision into
    the same interaction owner.
    """
    if command.kind != KIND_DELETE_STORED:
        return PromptStoredDeletePlan(False, List[String]())
    var selection = storage_payload(command)
    if selection.byte_length() > 0:
        delete_stored_selection(session, selection)
        return PromptStoredDeletePlan(
            True, _single_output("Gespeichert: " + stored_prompt_text(session))
        )
    var numbered = stored_prompt_numbered(session)
    if len(numbered) == 0:
        return PromptStoredDeletePlan(
            True, _single_output("Kein Befehl gespeichert.")
        )
    session.delete_next = True
    return PromptStoredDeletePlan(True, numbered^)


def plan_stored_default_command(
    line: String,
    session: NativePromptSession,
) -> PromptStoredDefaultPlan:
    """Plan the documented empty-enter shortcut for stored commands.

    The historical prompt displays the stored command as the line-editor
    placeholder; pressing Enter with an empty physical line executes that stored
    placeholder.  Keep this lifecycle decision in the interaction owner so the
    process controller receives an executable command line instead of treating
    the blank as a no-op.
    """
    if String(line.strip()).byte_length() != 0:
        return PromptStoredDefaultPlan(False, "")
    var stored = stored_prompt_text(session)
    if stored.byte_length() == 0:
        return PromptStoredDefaultPlan(False, "")
    return PromptStoredDefaultPlan(True, stored^)


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
    """Stable ownership snapshot used by source archives and release gates."""

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
        "external_process_dispatch=native-prompt-process-edge-plan",
        "external_reta_arguments=native-prompt-reta-argv-plan",
        "external_process_payload=native-prompt-process-payload-plan",
        "external_process_flags=native-prompt-process-effect-flags",
        "external_process_kind=eliminated-from-external-process-plan",
        "external_reta_child=native-prompt-reta-child-argv",
        "external_raw_line=eliminated-from-external-process-plan",
        "fallback_process_dispatch=native-interaction-argv-plan",
        "fallback_process_handled=native-explicit-fallback-effect-flag",
        "fallback_process_flags=native-explicit-fallback-run-flag",
        "stored_output_dispatch=native-session-output-execution-plan",
        "stored_delete_dispatch=native-session-delete-plan",
        "stored_default=native-empty-enter-placeholder-policy",
        "one_shot=native-token-assembly",
        "terminal=delegated-native-editor",
        "execution=delegated-native-dispatch",
    ]
