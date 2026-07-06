"""Native owner for the interactive ``prompt_interaction.py`` controller.

The terminal editor, prompt language, preparation and command execution already
have dedicated native owners.  This module owns the remaining mutable loop
boundary: startup-to-session activation, one-shot command assembly, input-mode
transitions, stored-command deletion and history/previous-command policy.

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
    KIND_EXIT,
    KIND_STORE_NEXT,
    KIND_STORE_PREVIOUS,
    KIND_OUTPUT_STORED,
    KIND_DELETE_STORED,
    KIND_LOG_ON,
    KIND_LOG_OFF,
    KIND_ABC,
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
        "stored_output_dispatch=native-session-output-execution-plan",
        "stored_delete_dispatch=native-session-delete-plan",
        "stored_default=native-empty-enter-placeholder-policy",
        "one_shot=native-token-assembly",
        "terminal=delegated-native-editor",
        "execution=delegated-native-dispatch",
    ]
