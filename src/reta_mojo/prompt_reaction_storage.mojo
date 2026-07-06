"""Native prompt-reaction storage decision owner.

This module owns prompt storage command classification that is shared by the
physical input edge and by local reaction dispatch: inline ``S``/``s`` storage,
position-independent ``o`` output addition and the empty-enter stored-default
shortcut.  Keeping these pure storage decisions out of both the input owner and
the local dispatch owner avoids a dependency cycle inside the future
``libreta-prompt-reaction`` shared library.
"""

from std.collections import List
from .prompt_language import (
    PromptLanguageCatalog,
    localized_prompt_kind,
)
from .prompt_runtime import (
    PromptCommand,
    join_prompt_tokens,
    KIND_ABC,
    KIND_STORE_NEXT,
    KIND_STORE_PREVIOUS,
    KIND_OUTPUT_STORED,
    KIND_DELETE_STORED,
)
from .prompt_session import (
    NativePromptSession,
    storage_payload,
    store_prompt_text,
    stored_prompt_text,
    stored_prompt_numbered,
    delete_stored_selection,
)


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
struct PromptStoredCommandDispatchPlan(Copyable):
    """Executable plan for single-word ``S``/``s`` storage dispatch."""

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


def plan_stored_default_command(
    line: String,
    session: NativePromptSession,
) -> PromptStoredDefaultPlan:
    """Plan the documented empty-enter shortcut for stored commands.

    The historical prompt displays the stored command as the line-editor
    placeholder; pressing Enter with an empty physical line executes that stored
    placeholder.  Keep this storage lifecycle decision outside the physical
    input owner and outside local dispatch, so both can share one typed storage
    contract.
    """
    if String(line.strip()).byte_length() != 0:
        return PromptStoredDefaultPlan(False, "")
    var stored = stored_prompt_text(session)
    if stored.byte_length() == 0:
        return PromptStoredDefaultPlan(False, "")
    return PromptStoredDefaultPlan(True, stored^)


def _single_output(value: String) -> List[String]:
    var result = List[String]()
    result.append(value)
    return result^


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


def plan_stored_command_dispatch(
    command: PromptCommand,
    mut session: NativePromptSession,
) -> PromptStoredCommandDispatchPlan:
    """Plan single-word store-next/store-previous storage dispatch.

    This is storage lifecycle semantics, not generic local prompt dispatch: the
    plan mutates only prompt storage state and returns exact observable lines for
    the process entry point to print.
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


def plan_stored_output_command(
    command: PromptCommand,
    session: NativePromptSession,
) -> PromptStoredOutputExecutionPlan:
    """Plan classified ``o`` execution as storage lifecycle semantics."""
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
    """Plan position-independent stored-output execution."""
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
    """Plan classified ``l`` deletion as storage lifecycle semantics."""
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


def prompt_reaction_storage_contract_snapshot() -> List[String]:
    """Stable ownership snapshot for shared prompt storage decisions."""
    return [
        "class=PromptReactionStorageBundle",
        "reaction_storage_owner=prompt-reaction-storage-plan",
        "inline_storage=native-position-and-history-policy",
        "storage_output=native-position-independent-addition-policy",
        "stored_default=native-empty-enter-placeholder-policy",
        "stored_command_dispatch=native-session-store-plan",
        "stored_output_dispatch=native-session-output-execution-plan",
        "stored_delete_dispatch=native-session-delete-plan",
    ]
