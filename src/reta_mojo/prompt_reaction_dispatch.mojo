"""Native prompt-reaction dispatch plans for local interactive effects.

This module owns prompt-reaction effects that do not need the reta core and do
not cross the OS process boundary: stored command output and
removal, logging toggles, terminal clear flags, informational flags and small
prompt-only numeric/helper output.  It is the planned source boundary for the
future ``libreta-prompt-reaction`` shared library.
"""

from std.collections import List
from .prompt_language import (
    PromptLanguageCatalog,
)
from .prompt_runtime import (
    PromptCommand,
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
    storage_payload,
    store_prompt_text,
    stored_prompt_text,
    stored_prompt_numbered,
    delete_stored_selection,
)
from .prompt_reaction_storage import (
    plan_inline_storage_command,
    plan_inline_storage_output_command,
)


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


def prompt_reaction_dispatch_contract_snapshot() -> List[String]:
    """Stable ownership snapshot for prompt-reaction local dispatch."""
    return [
        "class=PromptReactionDispatchBundle",
        "reaction_dispatch_owner=prompt-reaction-local-plan",
            "loop_control=native-empty-exit-loop-plan",
        "stored_command_dispatch=native-session-store-plan",
        "logging_dispatch=native-session-logging-plan",
        "one_shot_logging_dispatch=native-stateless-logging-plan",
        "terminal_clear_dispatch=native-terminal-clear-plan",
        "informational_dispatch=native-prompt-information-plan",
        "simple_output_dispatch=native-deterministic-prompt-output-plan",
        "stored_output_dispatch=native-session-output-execution-plan",
        "stored_delete_dispatch=native-session-delete-plan",
    ]
