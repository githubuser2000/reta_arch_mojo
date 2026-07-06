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
    join_prompt_tokens,
    KIND_ABC,
    KIND_STORE_NEXT,
    KIND_STORE_PREVIOUS,
    KIND_OUTPUT_STORED,
)
from .prompt_session import (
    NativePromptSession,
    stored_prompt_text,
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


def prompt_reaction_storage_contract_snapshot() -> List[String]:
    """Stable ownership snapshot for shared prompt storage decisions."""
    return [
        "class=PromptReactionStorageBundle",
        "reaction_storage_owner=prompt-reaction-storage-plan",
        "inline_storage=native-position-and-history-policy",
        "storage_output=native-position-independent-addition-policy",
        "stored_default=native-empty-enter-placeholder-policy",
    ]
