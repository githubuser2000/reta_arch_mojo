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
from .prompt_language import PromptLanguageCatalog, localized_prompt_kind
from .prompt_runtime import (
    PromptStartup,
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
struct PromptInlineStoragePlan(Copyable):
    """Position-independent compound ``S``/``s`` storage decision."""

    var handled: Bool
    var payload: String


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


def record_prompt_command(
    mut interaction: NativePromptInteraction,
    line: String,
    kind: Int,
) -> None:
    if prompt_command_updates_previous(kind):
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
        "one_shot=native-token-assembly",
        "terminal=delegated-native-editor",
        "execution=delegated-native-dispatch",
    ]
