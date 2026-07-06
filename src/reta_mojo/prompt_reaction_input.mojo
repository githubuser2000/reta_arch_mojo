"""Native prompt-reaction owner for physical input and history policy.

This module owns the pre-dispatch input edge of the interactive prompt:
terminal sentinel handling, store-next/delete-next continuations, empty-line
stored-default execution and previous-command recording.  It depends only on
prompt language/runtime/session/reaction-dispatch helpers and deliberately does
not depend on the reta core or the OS process adapter.  It is preparation for
future ``libreta-prompt-reaction`` extraction.
"""

from std.collections import List
from .prompt_language import (
    PromptLanguageCatalog,
    balanced_prompt_split,
)
from .prompt_runtime import (
    classify_prompt_command_localized,
    KIND_EXIT,
    KIND_STORE_NEXT,
    KIND_STORE_PREVIOUS,
    KIND_OUTPUT_STORED,
    KIND_DELETE_STORED,
    KIND_LOG_ON,
    KIND_LOG_OFF,
)
from .prompt_session import (
    NativePromptSession,
    store_prompt_text,
    stored_prompt_text,
    delete_stored_selection,
)
from .prompt_reaction_dispatch import (
    plan_inline_storage_command,
    plan_inline_storage_output_command,
    plan_stored_default_command,
)


comptime INTERACTION_EXECUTE = 0
comptime INTERACTION_CONTINUE = 1
comptime INTERACTION_EXIT = 2


@fieldwise_init
struct PromptInteractionInputPlan(Copyable):
    """Result of accepting one physical input line at the reaction boundary."""

    var action: Int
    var command_line: String
    var output_lines: List[String]


def _single_output(value: String) -> List[String]:
    var result = List[String]()
    result.append(value)
    return result^


def accept_prompt_reaction_input(
    mut session: NativePromptSession,
    language: String,
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

    if session.store_next:
        store_prompt_text(session, line)
        return PromptInteractionInputPlan(
            INTERACTION_CONTINUE,
            "",
            _single_output("Gespeichert: " + stored_prompt_text(session)),
        )

    if session.delete_next:
        var cancel = classify_prompt_command_localized(
            line, language, catalog
        )
        if cancel.kind == KIND_EXIT:
            session.delete_next = False
            return PromptInteractionInputPlan(
                INTERACTION_CONTINUE,
                "",
                _single_output("Löschen abgebrochen."),
            )
        delete_stored_selection(session, line)
        return PromptInteractionInputPlan(
            INTERACTION_CONTINUE,
            "",
            _single_output("Gespeichert: " + stored_prompt_text(session)),
        )

    var stored_default = plan_stored_default_command(
        line, session
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
    reports ``KIND_FALLBACK`` even though the reaction owner has already
    consumed the line as storage.  Re-plan the pure storage decision here so a
    handled suffix or middle alias cannot become the next ``s`` payload.
    """
    var tokens = balanced_prompt_split(line)
    if plan_inline_storage_command(tokens, language, catalog).handled:
        return False
    if plan_inline_storage_output_command(tokens, language, catalog).handled:
        return False
    return prompt_command_updates_previous(kind)


def record_prompt_session_command(
    mut session: NativePromptSession,
    line: String,
    kind: Int,
) -> None:
    if prompt_command_updates_previous(kind):
        session.previous_command = line


def record_prompt_session_line(
    mut session: NativePromptSession,
    line: String,
    kind: Int,
    language: String,
    catalog: PromptLanguageCatalog,
) raises -> None:
    """Record one executed line after compound reaction ownership checks."""
    if prompt_line_updates_previous(line, kind, language, catalog):
        session.previous_command = line


def prompt_reaction_input_contract_snapshot() -> List[String]:
    """Stable ownership snapshot for physical prompt input reaction."""

    return [
        "class=PromptReactionInputBundle",
        "reaction_input_owner=prompt-reaction-physical-input-plan",
        "input=native-typed-plan",
        "store=native-next-and-previous",
        "delete=native-selection-and-cancel",
        "stored_default=native-empty-enter-placeholder-policy",
        "history=native-previous-command-policy",
        "terminal_sentinels=native-exit-plan",
    ]
