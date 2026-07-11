"""Native prompt-session ownership for the historical ``prompt_session.py``.

The Python source combines three concerns: mutable prompt text state, command
storage/history policy and the prompt-toolkit terminal adapter.  The terminal
adapter is already replaced by ``prompt_terminal_input.mojo``.  This module
owns the remaining state machine and exposes explicit plans for the native
editor instead of retaining Python objects or callbacks.
"""

from std.collections import List
from std.collections.string import ord
from .row_ranges import range_to_numbers, is_row_range
from .prompt_prefix_catalog import prompt_prefix_contract
from .prompt_language import (
    PromptLanguageCatalog,
    balanced_prompt_split,
    prompt_root_commands,
    expand_compact_prompt_tokens,
    expand_prompt_replacements,
)
from .prompt_runtime import (
    PromptCommand,
    PromptStartup,
    classify_prompt_command_localized,
    split_prompt_words,
    join_prompt_tokens,
    KIND_EMPTY,
    KIND_LOG_ON,
    KIND_LOG_OFF,
)


comptime PROMPT_MODE_NORMAL = 0
comptime PROMPT_MODE_STORE = 1
comptime PROMPT_MODE_DELETE_START = 2
comptime PROMPT_MODE_STORED_OUTPUT = 3
comptime PROMPT_MODE_DELETE_SELECT = 4
comptime PROMPT_MODE_STORED_OUTPUT_WITH_ADDITION = 5
comptime PROMPT_MODE_SELECTIVE_OUTPUT = 6


@fieldwise_init
struct PromptTextState(Copyable):
    var text: String
    var placeholder: String
    var tokens: List[String]
    var command_words: List[String]
    var extra_tokens: List[String]
    var previous_command: String


@fieldwise_init
struct PromptLoopSetup(Copyable):
    var exit_commands: List[String]
    var logging_enabled: Bool
    var prompt_mode: Int
    var prompt_mode2: Int
    var normal_prefix: String
    var store_prefix: String
    var delete_prefix: String
    var only_one_command: List[String]
    var force_e_command: Bool
    var additional_tokens: List[String]


@fieldwise_init
struct PromptStoreResult(Copyable):
    var stored_text: String
    var prompt_mode2: Int
    var prepared_tokens: List[String]


@fieldwise_init
struct PromptDeleteResult(Copyable):
    var stored_text: String
    var remaining_selection: String


@fieldwise_init
struct NativePromptSession(Copyable):
    var logging_enabled: Bool
    var stored_tokens: List[String]
    var previous_command: String
    var store_next: Bool
    var delete_next: Bool
    var prompt_mode: Int
    var prompt_mode2: Int
    var normal_prefix: String
    var store_prefix: String
    var delete_prefix: String


def _plain_prompt_words(text: String) -> List[String]:
    var result = List[String]()
    var slices = text.split()
    for index in range(len(slices)):
        var word = String(slices[index].strip())
        if word.byte_length() > 0:
            result.append(word^)
    return result^


def _copy_words(values: List[String]) -> List[String]:
    var result = List[String]()
    for index in range(len(values)):
        result.append(values[index])
    return result^


def _append_unique(value: String, mut values: List[String]) -> None:
    for index in range(len(values)):
        if values[index] == value:
            return
    values.append(value)


def _contains(values: List[String], value: String) -> Bool:
    for index in range(len(values)):
        if values[index] == value:
            return True
    return False


def new_prompt_text_state(text: String = "") -> PromptTextState:
    var state = PromptTextState(
        "", "", List[String](), List[String](), List[String](), ""
    )
    set_prompt_text(state, text)
    return state^


def set_prompt_text(mut state: PromptTextState, text: String) -> None:
    var cleaned = String(text.strip())
    state.text = cleaned
    if cleaned.startswith("reta"):
        state.tokens = _plain_prompt_words(cleaned)
        state.command_words = _plain_prompt_words(cleaned)
    else:
        state.tokens = balanced_prompt_split(cleaned)
        state.command_words = balanced_prompt_split(cleaned)


def set_prompt_tokens(mut state: PromptTextState, values: List[String]) -> None:
    state.tokens = List[String]()
    state.command_words = List[String]()
    for index in range(len(values)):
        var cleaned = String(values[index].strip())
        if cleaned.byte_length() == 0:
            continue
        state.tokens.append(cleaned)
        var words = balanced_prompt_split(cleaned)
        for word_index in range(len(words)):
            state.command_words.append(words[word_index])
    state.text = join_prompt_tokens(state.tokens)


def set_prompt_extra(mut state: PromptTextState, values: List[String]) -> None:
    state.extra_tokens = _copy_words(values)


def prompt_text_all_tokens(state: PromptTextState) -> List[String]:
    var result = _copy_words(state.tokens)
    for index in range(len(state.extra_tokens)):
        result.append(state.extra_tokens[index])
    return result^


def prompt_text_unique_tokens(state: PromptTextState) -> List[String]:
    var result = List[String]()
    var values = prompt_text_all_tokens(state)
    for index in range(len(values)):
        _append_unique(values[index], result)
    return result^


def prompt_text_has(state: PromptTextState, candidates: List[String]) -> Bool:
    for index in range(len(candidates)):
        if _contains(state.tokens, candidates[index]):
            return True
    return False


def prompt_text_has_without_abc(
    state: PromptTextState,
    candidates: List[String],
    abc_command: String,
    abcd_command: String,
) -> Bool:
    return (
        prompt_text_has(state, candidates)
        and not _contains(state.tokens, abc_command)
        and not _contains(state.tokens, abcd_command)
    )


def build_prompt_loop_setup(
    startup: PromptStartup,
    exit_commands: List[String],
    store_prefix: String = "was speichern>",
    delete_prefix: String = "was löschen>",
) -> PromptLoopSetup:
    return PromptLoopSetup(
        _copy_words(exit_commands),
        startup.profile.logging_enabled,
        PROMPT_MODE_NORMAL,
        PROMPT_MODE_NORMAL,
        ">",
        store_prefix,
        delete_prefix,
        _copy_words(startup.command_tokens),
        startup.profile.force_e_command,
        List[String](),
    )


def prompt_mode_prefix(setup: PromptLoopSetup, mode: Int) -> String:
    if mode == PROMPT_MODE_STORE:
        return setup.store_prefix
    if mode == PROMPT_MODE_DELETE_SELECT:
        return setup.delete_prefix
    return setup.normal_prefix


def new_prompt_session(
    logging_enabled: Bool,
    normal_prefix: String = ">",
    store_prefix: String = "was speichern>",
    delete_prefix: String = "was löschen>",
) -> NativePromptSession:
    return NativePromptSession(
        logging_enabled,
        List[String](),
        "",
        False,
        False,
        PROMPT_MODE_NORMAL,
        PROMPT_MODE_NORMAL,
        normal_prefix,
        store_prefix,
        delete_prefix,
    )


def new_prompt_session_for_language(
    logging_enabled: Bool,
    language: String,
) -> NativePromptSession:
    var prefixes = prompt_prefix_contract(language)
    return new_prompt_session(
        logging_enabled,
        prefixes.normal,
        prefixes.store,
        prefixes.delete,
    )


def prompt_prefix(session: NativePromptSession) -> String:
    if session.store_next:
        return session.store_prefix
    if session.delete_next:
        return session.delete_prefix
    return session.normal_prefix


def _append_nonempty_words(text: String, mut target: List[String]) -> None:
    var words = split_prompt_words(text)
    for index in range(len(words)):
        if words[index].byte_length() > 0:
            target.append(words[index])


def store_prompt_text(mut session: NativePromptSession, text: String) -> None:
    _append_nonempty_words(text, session.stored_tokens)
    session.store_next = False
    session.prompt_mode = PROMPT_MODE_NORMAL


def stored_prompt_text(session: NativePromptSession) -> String:
    return join_prompt_tokens(session.stored_tokens)


def storage_payload(command: PromptCommand) -> String:
    if len(command.words) <= 1:
        return ""
    var words = List[String]()
    for index in range(1, len(command.words)):
        words.append(command.words[index])
    return join_prompt_tokens(words)


def stored_prompt_numbered(session: NativePromptSession) -> List[String]:
    var result = List[String]()
    for index in range(len(session.stored_tokens)):
        result.append(String(index + 1) + ": " + session.stored_tokens[index])
    return result^


def _is_ascii_decimal(text: String) -> Bool:
    if text.byte_length() == 0:
        return False
    for index in range(text.byte_length()):
        var code = ord(text[byte=index])
        if code < 48 or code > 57:
            return False
    return True


def _selection_is_existing_token(session: NativePromptSession, value: String) -> Bool:
    for index in range(len(session.stored_tokens)):
        if session.stored_tokens[index] == value:
            return True
    return False



def _delete_stored_selection_impl(
    mut session: NativePromptSession,
    selection: String,
) raises -> String:
    var cleaned = String(selection.strip())
    if cleaned.byte_length() == 0:
        session.delete_next = False
        session.prompt_mode = PROMPT_MODE_NORMAL
        return ""

    var use_position_deletion = False
    if is_row_range(cleaned):
        use_position_deletion = (
            not _selection_is_existing_token(session, cleaned)
            or not _is_ascii_decimal(cleaned)
        )

    var keep = List[String]()
    if use_position_deletion:
        var positions = range_to_numbers(cleaned, False, 0)
        for index in range(len(session.stored_tokens)):
            if (index + 1) not in positions:
                keep.append(session.stored_tokens[index])
    else:
        var selected = split_prompt_words(cleaned)
        for index in range(len(session.stored_tokens)):
            var remove = False
            for selected_index in range(len(selected)):
                if session.stored_tokens[index] == selected[selected_index]:
                    remove = True
                    break
            if not remove:
                keep.append(session.stored_tokens[index])
    session.stored_tokens = keep^
    session.delete_next = False
    session.prompt_mode = PROMPT_MODE_NORMAL
    return cleaned if use_position_deletion else ""


def delete_stored_selection(
    mut session: NativePromptSession,
    selection: String,
) raises -> None:
    _ = _delete_stored_selection_impl(session, selection)


def delete_stored_selection_result(
    mut session: NativePromptSession,
    selection: String,
) raises -> PromptDeleteResult:
    var remaining = _delete_stored_selection_impl(session, selection)
    return PromptDeleteResult(stored_prompt_text(session), remaining^)


def history_should_append(
    line: String,
    catalog: PromptLanguageCatalog,
    language: String,
) -> Bool:
    """Mirror ToggleHistory: skip blanks and both logging toggle commands."""
    if line.strip().byte_length() == 0:
        return False
    var command = classify_prompt_command_localized(line, language, catalog)
    return command.kind != KIND_EMPTY and command.kind != KIND_LOG_ON and command.kind != KIND_LOG_OFF


def apply_storage_output(
    pending_output: String,
    prompt_mode: Int,
    stored_text: String,
    current_text: String = "",
) -> String:
    if prompt_mode == PROMPT_MODE_STORED_OUTPUT:
        return String(stored_text.strip())
    if prompt_mode == PROMPT_MODE_STORED_OUTPUT_WITH_ADDITION:
        var left = String(stored_text.strip())
        var right = String(pending_output.strip())
        if left.byte_length() == 0:
            return right^
        if right.byte_length() == 0:
            return left^
        return left + " " + right
    return current_text


def combine_stored_prompt(
    placeholder: String,
    text: String,
) -> String:
    """Combine stored/current text while retaining at most one leading reta."""
    var left = split_prompt_words(String(placeholder.strip()))
    var right = split_prompt_words(String(text.strip()))
    var result = List[String]()
    var has_reta = False
    if len(left) > 0 and (left[0] == "reta" or left[0] == "+reta"):
        has_reta = True
    if len(right) > 0 and (right[0] == "reta" or right[0] == "+reta"):
        has_reta = True
    if has_reta:
        result.append("reta")
    for index in range(len(left)):
        if not (index == 0 and (left[index] == "reta" or left[index] == "+reta")):
            result.append(left[index])
    for index in range(len(right)):
        if not (index == 0 and (right[index] == "reta" or right[index] == "+reta")):
            result.append(right[index])
    return join_prompt_tokens(result)


def combine_stored_prompt_localized(
    catalog: PromptLanguageCatalog,
    language: String,
    placeholder: String,
    text: String,
) raises -> String:
    """Port the non-``reta`` branch of ``PromptSessionBundle.store_prompt``."""
    var direct = combine_stored_prompt(placeholder, text)
    if direct.startswith("reta"):
        return direct^

    var root_commands = prompt_root_commands(catalog, language)
    var source = split_prompt_words(String(placeholder.strip()))
    var current = split_prompt_words(String(text.strip()))
    for index in range(len(current)):
        source.append(current[index])

    var ordinary = List[String]()
    var long_commands = List[String]()
    for index in range(len(source)):
        var token = source[index]
        if token.byte_length() > 1 and _contains(root_commands, token):
            long_commands.append(token)
        else:
            ordinary.append(token)

    var expanded = expand_compact_prompt_tokens(
        catalog, language, ordinary, True, False
    )
    var normalized = expand_prompt_replacements(
        catalog, language, expanded.tokens
    )
    for index in range(len(long_commands)):
        normalized.append(long_commands[index])
    return join_prompt_tokens(normalized)


def prompt_session_contract_snapshot() -> List[String]:
    var result = List[String]()
    result.append("class=PromptSessionBundle")
    result.append("text_state=PromptTextState")
    result.append("runtime=PromptRuntimeBundle")
    result.append("completion=CompletionRuntimeBundle")
    result.append("language=PromptLanguageBundle")
    result.append("history=~/.ReTa_arch_mojo_prompt_history")
    result.append("terminal=native-posix-editor")
    return result^
