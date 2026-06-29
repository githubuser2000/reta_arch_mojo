"""Native Stage-10 prompt language and nested-completion runtime.

The multilingual catalog is generated from the Python reference, but all
parsing, command dispatch, bracket-aware tokenization, context transitions,
shortcut expansion and completion filtering in this module are native Mojo.
"""

from std.collections import List
from std.collections.string import atol, ord
from .csv_table import read_text_file
from .row_ranges import is_fraction_or_integer_range


@fieldwise_init
struct PromptCompletionEntry(Copyable):
    var language: String
    var scope: String
    var context: String
    var values: List[String]


@fieldwise_init
struct PromptDispatchAlias(Copyable):
    var language: String
    var token: String
    var kind: Int
    var canonical: String


@fieldwise_init
struct PromptShortcutReplacement(Copyable):
    var language: String
    var token: String
    var replacement: String


@fieldwise_init
struct PromptNumericShortcut(Copyable):
    var language: String
    var family: String
    var key: String
    var description: String


@fieldwise_init
struct PromptVocabularyAlias(Copyable):
    var language: String
    var domain: String
    var canonical: String
    var translated: String


@fieldwise_init
struct PromptLanguageCatalog(Copyable):
    var completions: List[PromptCompletionEntry]
    var dispatch_aliases: List[PromptDispatchAlias]
    var replacements: List[PromptShortcutReplacement]
    var numeric_shortcuts: List[PromptNumericShortcut]
    var vocabulary: List[PromptVocabularyAlias]


def normalize_prompt_language(language: String) -> String:
    var lowered = language.lower()
    if lowered == "" or lowered == "de" or lowered == "deutsch" or lowered == "german":
        return "deutsch"
    if lowered == "en" or lowered == "english" or lowered == "englisch":
        return "english"
    if lowered == "vn" or lowered == "vietnamese" or lowered == "vietnamesisch" or lowered == "tiếngviệt":
        return "vietnamese"
    if lowered == "cn" or lowered == "chinese" or lowered == "chinesisch" or lowered == "中國人":
        return "chinese"
    if lowered == "kr" or lowered == "korean" or lowered == "koreanisch" or lowered == "한국인":
        return "korean"
    return lowered^


def _slice(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])




def _split_values(encoded: String) -> List[String]:
    var result = List[String]()
    var pieces = encoded.split("\x1f")
    for index in range(len(pieces)):
        result.append(String(pieces[index]))
    return result^

def _parse_completion_catalog(path: String) raises -> List[PromptCompletionEntry]:
    var result = List[PromptCompletionEntry]()
    var lines = read_text_file(path).split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0:
            continue
        var fields = line.split("\t")
        if len(fields) != 4:
            continue
        result.append(
            PromptCompletionEntry(
                String(fields[0]), String(fields[1]), String(fields[2]), _split_values(String(fields[3]))
            )
        )
    return result^


def _parse_dispatch_catalog(path: String) raises -> List[PromptDispatchAlias]:
    var result = List[PromptDispatchAlias]()
    var lines = read_text_file(path).split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0:
            continue
        var fields = line.split("\t")
        if len(fields) != 4:
            continue
        result.append(
            PromptDispatchAlias(
                String(fields[0]), String(fields[1]), atol(String(fields[2])), String(fields[3])
            )
        )
    return result^


def _parse_replacement_catalog(path: String) raises -> List[PromptShortcutReplacement]:
    var result = List[PromptShortcutReplacement]()
    var lines = read_text_file(path).split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0:
            continue
        var fields = line.split("\t")
        if len(fields) != 3:
            continue
        result.append(
            PromptShortcutReplacement(String(fields[0]), String(fields[1]), String(fields[2]))
        )
    return result^


def _parse_numeric_catalog(path: String) raises -> List[PromptNumericShortcut]:
    var result = List[PromptNumericShortcut]()
    var lines = read_text_file(path).split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0:
            continue
        var fields = line.split("\t")
        if len(fields) != 4:
            continue
        result.append(
            PromptNumericShortcut(
                String(fields[0]), String(fields[1]), String(fields[2]), String(fields[3])
            )
        )
    return result^


def _parse_vocabulary_catalog(path: String) raises -> List[PromptVocabularyAlias]:
    var result = List[PromptVocabularyAlias]()
    var lines = read_text_file(path).split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0:
            continue
        var fields = line.split("\t")
        if len(fields) != 4:
            continue
        result.append(
            PromptVocabularyAlias(
                String(fields[0]), String(fields[1]), String(fields[2]), String(fields[3])
            )
        )
    return result^


def load_prompt_language_catalog(asset_root: String) raises -> PromptLanguageCatalog:
    var separator = ""
    if not asset_root.endswith("/"):
        separator = "/"
    var prefix = asset_root + separator
    return PromptLanguageCatalog(
        _parse_completion_catalog(prefix + "prompt_nested_completion.tsv"),
        _parse_dispatch_catalog(prefix + "prompt_command_aliases.tsv"),
        _parse_replacement_catalog(prefix + "prompt_shortcut_replacements.tsv"),
        _parse_numeric_catalog(prefix + "prompt_numeric_shortcuts.tsv"),
        _parse_vocabulary_catalog(prefix + "prompt_vocabulary.tsv"),
    )


def balanced_prompt_split(text: String) -> List[String]:
    """Split on ASCII whitespace outside (), [] and {}.

    This is the native counterpart of ``prompt_language.custom_split``.  The
    reference deliberately treats mismatched closing delimiters permissively;
    only the nesting depth matters for subsequent whitespace.
    """
    var result = List[String]()
    var bytes = text.as_bytes()
    var depth = 0
    var start = 0
    var index = 0
    while index < len(bytes):
        var code = Int(bytes[index])
        if code == 40 or code == 91 or code == 123:
            depth += 1
        elif code == 41 or code == 93 or code == 125:
            if depth > 0:
                depth -= 1
        elif depth == 0 and (code == 32 or code == 9 or code == 10 or code == 13):
            result.append(_slice(text, start, index))
            start = index + 1
        index += 1
    if start < len(bytes):
        result.append(_slice(text, start, len(bytes)))
    return result^


def balanced_prompt_split_delimiter(text: String, delimiter: String) -> List[String]:
    """Split on one ASCII delimiter outside (), [] and {}."""
    var result = List[String]()
    if delimiter.byte_length() == 0:
        result.append(text)
        return result^
    var delimiter_code = Int(delimiter.as_bytes()[0])
    var bytes = text.as_bytes()
    var depth = 0
    var start = 0
    var index = 0
    while index < len(bytes):
        var code = Int(bytes[index])
        if code == 40 or code == 91 or code == 123:
            depth += 1
        elif code == 41 or code == 93 or code == 125:
            if depth > 0:
                depth -= 1
        elif depth == 0 and code == delimiter_code:
            result.append(_slice(text, start, index))
            start = index + 1
        index += 1
    if start < len(bytes):
        result.append(_slice(text, start, len(bytes)))
    return result^


def localized_prompt_kind(
    catalog: PromptLanguageCatalog,
    language: String,
    alias_value: String,
) -> Int:
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.dispatch_aliases)):
        var entry = catalog.dispatch_aliases[index].copy()
        if entry.language == normalized and entry.token == alias_value:
            return entry.kind
    return -1


def localized_prompt_canonical(
    catalog: PromptLanguageCatalog,
    language: String,
    alias_value: String,
) -> String:
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.dispatch_aliases)):
        var entry = catalog.dispatch_aliases[index].copy()
        if entry.language == normalized and entry.token == alias_value:
            return entry.canonical
    return ""


def expand_prompt_shortcut(
    catalog: PromptLanguageCatalog,
    language: String,
    alias_value: String,
) -> String:
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.replacements)):
        var entry = catalog.replacements[index].copy()
        if entry.language == normalized and entry.token == alias_value:
            return entry.replacement
    return alias_value


def is_prompt_numeric_shortcut(
    catalog: PromptLanguageCatalog,
    language: String,
    text: String,
) -> Bool:
    var normalized = normalize_prompt_language(language)
    if text == "15_" or text == "16_" or text == "16_15_":
        return True
    var family: String
    var key: String
    if text.startswith("16_15_"):
        family = "15"
        key = _slice(text, 6, text.byte_length())
    elif text.startswith("15_"):
        family = "15"
        key = _slice(text, 3, text.byte_length())
    elif text.startswith("16_"):
        family = "16"
        key = _slice(text, 3, text.byte_length())
    else:
        return False
    for index in range(len(catalog.numeric_shortcuts)):
        var entry = catalog.numeric_shortcuts[index].copy()
        if entry.language == normalized and entry.family == family and entry.key == key:
            return True
    return False


def _contains_string(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _append_unique(mut values: List[String], value: String) -> None:
    if not _contains_string(values, value):
        values.append(value)


def _catalog_values(
    catalog: PromptLanguageCatalog,
    language: String,
    scope: String,
    context: String,
) -> List[String]:
    var result = List[String]()
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.completions)):
        var entry = catalog.completions[index].copy()
        if entry.language == normalized and entry.scope == scope and entry.context == context:
            for value_index in range(len(entry.values)):
                _append_unique(result, entry.values[value_index])
    return result^


@fieldwise_init
struct PromptFuzzyCandidate(Copyable):
    var value: String
    var start: Int
    var length: Int
    var order: Int


def _fuzzy_match(value: String, query: String) -> PromptFuzzyCandidate:
    var candidate = value.lower()
    var wanted = query.lower()
    if wanted.byte_length() == 0:
        return PromptFuzzyCandidate(value, 0, 0, 0)
    var candidate_bytes = candidate.as_bytes()
    var wanted_bytes = wanted.as_bytes()
    var best_start = -1
    var best_length = 0
    for start in range(len(candidate_bytes)):
        if Int(candidate_bytes[start]) != Int(wanted_bytes[0]):
            continue
        var candidate_index = start
        var wanted_index = 0
        while candidate_index < len(candidate_bytes) and wanted_index < len(wanted_bytes):
            if Int(candidate_bytes[candidate_index]) == Int(wanted_bytes[wanted_index]):
                wanted_index += 1
            candidate_index += 1
        if wanted_index == len(wanted_bytes):
            var matched_length = candidate_index - start
            if best_start < 0 or start < best_start or (start == best_start and matched_length < best_length):
                best_start = start
                best_length = matched_length
    return PromptFuzzyCandidate(value, best_start, best_length, 0)


def _filter_prefix(values: List[String], prefix: String) -> List[String]:
    """Apply prompt-toolkit's fuzzy ordering: leftmost, then shortest match."""
    var matches = List[PromptFuzzyCandidate]()
    for index in range(len(values)):
        var fuzzy_result = _fuzzy_match(values[index], prefix)
        if fuzzy_result.start >= 0:
            fuzzy_result.order = index
            matches.append(fuzzy_result^)
    for index in range(1, len(matches)):
        var key = matches[index].copy()
        var previous = index - 1
        while previous >= 0:
            var item = matches[previous].copy()
            var after = (
                item.start > key.start
                or (item.start == key.start and item.length > key.length)
            )
            if not after:
                break
            matches[previous + 1] = item.copy()
            previous -= 1
        matches[previous + 1] = key^
    var result = List[String]()
    for index in range(len(matches)):
        _append_unique(result, matches[index].value)
    return result^


def _last_nonempty(values: List[String]) -> String:
    var index = len(values) - 1
    while index >= 0:
        if values[index].byte_length() > 0:
            return values[index]
        index -= 1
    return ""


def _main_context(catalog: PromptLanguageCatalog, language: String, words: List[String]) -> String:
    var mains = _catalog_values(catalog, language, "main", "*")
    var active = String()
    for word_index in range(len(words)):
        for main_index in range(len(mains)):
            if words[word_index] == mains[main_index]:
                active = words[word_index]
                break
    return active^


def _parameter_name(token: String) -> String:
    var stripped = token
    if stripped.startswith("--"):
        stripped = _slice(stripped, 2, stripped.byte_length())
    var equals = stripped.find("=")
    if equals >= 0:
        stripped = _slice(stripped, 0, equals)
    return stripped^


def _current_fragment(token: String) -> String:
    var equals = token.find("=")
    if equals < 0:
        return token
    var value = _slice(token, equals + 1, token.byte_length())
    var pieces = value.split(",")
    if len(pieces) == 0:
        return ""
    return String(pieces[len(pieces) - 1])


def prompt_completion_candidates(
    catalog: PromptLanguageCatalog,
    language: String,
    text_before_cursor: String,
) -> List[String]:
    """Resolve nested completion candidates for a prompt prefix.

    The state machine covers root commands, ``reta`` main parameters, nested
    line/column/output/combination parameters and comma-separated values.
    Returned values are unprefixed replacement tokens, matching readline and
    prompt-toolkit completion semantics.
    """
    var text = String(text_before_cursor.lstrip())
    var ends_with_space = (
        text.endswith(" ") or text.endswith("\t") or text.endswith("\n") or text.endswith("\r")
    )
    var words = balanced_prompt_split(text)
    if len(words) == 0:
        return _catalog_values(catalog, language, "root", "*")

    var first = _last_nonempty(words)
    if words[0] != "reta":
        if len(words) == 1 and not ends_with_space:
            return _filter_prefix(_catalog_values(catalog, language, "root", "*"), first)
        return _catalog_values(catalog, language, "root", "*")

    if len(words) == 1:
        if ends_with_space:
            return _catalog_values(catalog, language, "main", "*")
        return _filter_prefix(_catalog_values(catalog, language, "root", "*"), words[0])

    var active_main = _main_context(catalog, language, words)
    var current = words[len(words) - 1]
    if ends_with_space:
        current = ""

    var mains = _catalog_values(catalog, language, "main", "*")
    if active_main.byte_length() == 0:
        return _filter_prefix(mains, current)

    # A newly typed main parameter always changes the completion section.
    for index in range(len(mains)):
        if current == mains[index]:
            if ends_with_space:
                return _catalog_values(catalog, language, "parameter", current)
            return _filter_prefix(mains, current)

    if current.startswith("-") and not current.startswith("--"):
        return _filter_prefix(mains, current)

    var parameters = _catalog_values(catalog, language, "parameter", active_main)
    if current.find("=") < 0:
        return _filter_prefix(parameters, current)

    var name = _parameter_name(current)
    var context = active_main + "|" + name
    var values = _catalog_values(catalog, language, "value", context)
    if len(values) == 0:
        values = _catalog_values(catalog, language, "value", active_main + "|*")
    return _filter_prefix(values, _current_fragment(current))


def prompt_root_commands(
    catalog: PromptLanguageCatalog,
    language: String,
) -> List[String]:
    return _catalog_values(catalog, language, "root", "*")


def prompt_completion_word_pool(
    catalog: PromptLanguageCatalog,
    language: String,
) -> List[String]:
    """Return a deduplicated interactive word pool for the OS readline seam."""
    var result = List[String]()
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.completions)):
        var entry = catalog.completions[index].copy()
        if entry.language == normalized:
            for value_index in range(len(entry.values)):
                if entry.values[value_index].byte_length() > 0:
                    _append_unique(result, entry.values[value_index])
    return result^



def prompt_vocabulary_alias(
    catalog: PromptLanguageCatalog,
    language: String,
    domain: String,
    canonical: String,
) -> String:
    """Return one translated prompt vocabulary item.

    The generated vocabulary preserves the Python i18n dictionary's effective
    values for every supported language.  Missing entries deliberately fall
    back to the canonical spelling, matching the reference's use of identity
    aliases for many commands.
    """
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.vocabulary)):
        var entry = catalog.vocabulary[index].copy()
        if (
            entry.language == normalized
            and entry.domain == domain
            and entry.canonical == canonical
        ):
            return entry.translated
    return canonical


def prompt_short_command_letters(
    catalog: PromptLanguageCatalog,
    language: String,
) -> List[String]:
    var result = List[String]()
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.vocabulary)):
        var entry = catalog.vocabulary[index].copy()
        if (
            entry.language == normalized
            and entry.domain == "command"
            and entry.canonical.byte_length() == 1
        ):
            _append_unique(result, entry.translated)
    return result^


@fieldwise_init
struct PromptExpansionResult(Copyable):
    var compact: Bool
    var tokens: List[String]


def _empty_int_slots(size: Int) -> List[Int]:
    var slots = List[Int]()
    for _ in range(size):
        slots.append(-1)
    return slots^


@fieldwise_init
struct _PromptSipState(Copyable):
    var v0: UInt64
    var v1: UInt64
    var v2: UInt64
    var v3: UInt64


def _prompt_rotl64(value: UInt64, amount: Int) -> UInt64:
    return (value << UInt64(amount)) | (value >> UInt64(64 - amount))


def _prompt_sip_round(state: _PromptSipState) -> _PromptSipState:
    var v0 = state.v0 + state.v1
    var v1 = _prompt_rotl64(state.v1, 13) ^ v0
    v0 = _prompt_rotl64(v0, 32)
    var v2 = state.v2 + state.v3
    var v3 = _prompt_rotl64(state.v3, 16) ^ v2
    v0 += v3
    v3 = _prompt_rotl64(v3, 21) ^ v0
    v2 += v1
    v1 = _prompt_rotl64(v1, 17) ^ v2
    v2 = _prompt_rotl64(v2, 32)
    return _PromptSipState(v0, v1, v2, v3)


def _prompt_siphash13_seed_zero(text: String) -> UInt64:
    # CPython 3.13 string hashing under PYTHONHASHSEED=0.  The historical
    # compact parser routes command letters through two builtin-set objects,
    # making this order observable in the expanded command stream.
    var state = _PromptSipState(
        UInt64(0x736f6d6570736575),
        UInt64(0x646f72616e646f6d),
        UInt64(0x6c7967656e657261),
        UInt64(0x7465646279746573),
    )
    var bytes = text.as_bytes()
    var cursor = 0
    while cursor + 8 <= len(bytes):
        var word = UInt64(0)
        for offset in range(8):
            word |= UInt64(bytes[cursor + offset]) << UInt64(offset * 8)
        state.v3 ^= word
        state = _prompt_sip_round(state)
        state.v0 ^= word
        cursor += 8

    var tail = UInt64(len(bytes)) << UInt64(56)
    var offset = 0
    while cursor + offset < len(bytes):
        tail |= UInt64(bytes[cursor + offset]) << UInt64(offset * 8)
        offset += 1
    state.v3 ^= tail
    state = _prompt_sip_round(state)
    state.v0 ^= tail
    state.v2 ^= UInt64(0xff)
    state = _prompt_sip_round(state)
    state = _prompt_sip_round(state)
    state = _prompt_sip_round(state)
    return state.v0 ^ state.v1 ^ state.v2 ^ state.v3


def _prompt_string_set_slot(
    slots: List[Int], values: List[String], value: String
) -> Int:
    var hash_value = _prompt_siphash13_seed_zero(value)
    var mask = len(slots) - 1
    var index = Int(hash_value & UInt64(mask))
    var perturb = hash_value
    while True:
        if slots[index] == -1 or values[slots[index]] == value:
            return index
        var probes = 9 if index + 9 <= mask else 0
        for offset in range(1, probes + 1):
            if (
                slots[index + offset] == -1
                or values[slots[index + offset]] == value
            ):
                return index + offset
        perturb >>= UInt64(5)
        index = Int((UInt64(index * 5 + 1) + perturb) & UInt64(mask))


def _prompt_string_set_resize(
    slots: List[Int], values: List[String], minimum_used: Int
) -> List[Int]:
    var new_size = 8
    while new_size <= minimum_used:
        new_size <<= 1
    var resized = _empty_int_slots(new_size)
    for index in range(len(slots)):
        var value_index = slots[index]
        if value_index >= 0:
            var target = _prompt_string_set_slot(
                resized, values, values[value_index]
            )
            resized[target] = value_index
    return resized^


def _python_string_set_order(values: List[String]) -> List[String]:
    # Plain ``set(iterable)`` inserts first and resizes afterwards with
    # ``used * 4`` for small sets.  This differs from the set-merge path used
    # by the old prime-cross fallback and becomes visible from five tokens on.
    var slots = _empty_int_slots(8)
    var fill = 0
    var used = 0
    for value_index in range(len(values)):
        var target = _prompt_string_set_slot(slots, values, values[value_index])
        if slots[target] >= 0:
            continue
        slots[target] = value_index
        fill += 1
        used += 1
        var mask = len(slots) - 1
        if fill * 5 >= mask * 3:
            slots = _prompt_string_set_resize(slots, values, used * 4)
            fill = used

    var result = List[String]()
    for index in range(len(slots)):
        if slots[index] >= 0:
            result.append(values[slots[index]])
    return result^


def _prompt_characters(text: String) -> List[String]:
    var result = List[String]()
    # All historical compact command letters are single-byte ASCII aliases in
    # every shipped language.  Values outside that alphabet fail validation.
    for index in range(text.byte_length()):
        result.append(_slice(text, index, index + 1))
    return result^


def _python_short_letter_intersection(
    prefix: String,
    short_letters: List[String],
) -> List[String]:
    # ``set(prefix) & short_command_letters`` first iterates the smaller input
    # set and then inserts matches into a fresh result set.  Running the native
    # set-order emulation twice reproduces that second observable reordering.
    var first_order = _python_string_set_order(_prompt_characters(prefix))
    var matches = List[String]()
    for index in range(len(first_order)):
        if _contains_string(short_letters, first_order[index]):
            matches.append(first_order[index])
    return _python_string_set_order(matches)


def _trim_commas(text: String) -> String:
    var start = 0
    var end = text.byte_length()
    while start < end and ord(text[byte=start]) == 44:
        start += 1
    while end > start and ord(text[byte=end - 1]) == 44:
        end -= 1
    return _slice(text, start, end)


def _is_digit(value: Int) -> Bool:
    return value >= 48 and value <= 57


def _matching_outer_brackets(text: String) -> Bool:
    if text.byte_length() < 2:
        return False
    var first = ord(text[byte=0])
    var last = ord(text[byte=text.byte_length() - 1])
    return (
        (first == 40 and last == 41)
        or (first == 91 and last == 93)
        or (first == 123 and last == 125)
    )


def _valid_bracket_number_block(text: String) raises -> Bool:
    if not _matching_outer_brackets(text):
        return False
    var body = _slice(text, 1, text.byte_length() - 1)
    var normalized = String()
    var previous_separator = False
    for index in range(body.byte_length()):
        var code = ord(body[byte=index])
        var separator = code == 32 or code == 9 or code == 10 or code == 13
        if separator:
            if not previous_separator and normalized.byte_length() > 0:
                normalized += ","
            previous_separator = True
        else:
            normalized += _slice(body, index, index + 1)
            previous_separator = code == 44
    if normalized.endswith(","):
        normalized = _slice(normalized, 0, normalized.byte_length() - 1)
    if normalized.byte_length() == 0:
        return True
    return is_fraction_or_integer_range(normalized)


def _valid_compact_number_suffix(text: String) raises -> Bool:
    if _matching_outer_brackets(text):
        return _valid_bracket_number_block(text)
    return is_fraction_or_integer_range(text)


def _unique_non_control_token_count(
    tokens: List[String], first_control: String, second_control: String
) -> Int:
    var unique = List[String]()
    for index in range(len(tokens)):
        var token = tokens[index]
        if token == first_control or token == second_control:
            continue
        _append_unique(unique, token)
    return len(unique)


def _rotate_compact_number_to_end(token: String) -> String:
    var reverse_offset = 0
    for offset in range(token.byte_length()):
        var code = ord(token[byte=token.byte_length() - 1 - offset])
        if _is_digit(code) or code == 41 or code == 93 or code == 125:
            reverse_offset = offset
            break
    if reverse_offset > 0:
        return (
            _slice(token, token.byte_length() - reverse_offset, token.byte_length())
            + _slice(token, 0, token.byte_length() - reverse_offset)
        )
    return token


def _compact_number_start(token: String) -> Int:
    for index in range(token.byte_length()):
        var code = ord(token[byte=index])
        if _is_digit(code) or code == 40 or code == 91 or code == 123:
            if index > 0 and ord(token[byte=index - 1]) == 45:
                return index - 1
            return index
    return -1


def expand_compact_prompt_tokens(
    catalog: PromptLanguageCatalog,
    language: String,
    input_tokens: List[String],
    selective_output: Bool = False,
    force_e: Bool = False,
) raises -> PromptExpansionResult:
    """Port ``stextFromKleinKleinKleinBefehl`` without a Python runtime.

    The result intentionally precedes the later one-character replacement
    phase, just like the historical function.  CPython's fixed-seed set order
    is reproduced because it changes visible command ordering for inputs such
    as ``ap15``.
    """
    if len(input_tokens) == 0:
        return PromptExpansionResult(False, List[String]())

    var joined = String()
    for index in range(len(input_tokens)):
        if index > 0:
            joined += " "
        joined += input_tokens[index]
    var split_tokens = balanced_prompt_split(joined)
    var result = List[String]()
    var compact = False
    var roots = _catalog_values(catalog, language, "root", "*")
    var short_letters = prompt_short_command_letters(catalog, language)
    var e_alias = prompt_vocabulary_alias(catalog, language, "command", "e")
    var quiet_alias = prompt_vocabulary_alias(
        catalog,
        language,
        "command",
        "keineEinZeichenZeilenPlusKeineAusgabeWelcherBefehlEsWar",
    )
    var pure_single = (
        _unique_non_control_token_count(input_tokens, e_alias, quiet_alias) == 1
    )
    var first_input = input_tokens[0]

    for token_index in range(len(split_tokens)):
        var original = _trim_commas(split_tokens[token_index])
        var additions = List[String]()
        if (
            not is_prompt_numeric_shortcut(catalog, language, original)
            and not _contains_string(roots, original)
            and first_input != "reta"
        ):
            var rotated = _rotate_compact_number_to_end(original)
            var number_start = _compact_number_start(rotated)
            if number_start >= 0:
                var suffix = _slice(rotated, number_start, rotated.byte_length())
                if _valid_compact_number_suffix(suffix):
                    var letters = List[String]()
                    if not _matching_outer_brackets(rotated):
                        letters = _python_short_letter_intersection(
                            _slice(rotated, 0, number_start), short_letters
                        )
                    var prefix_length = number_start
                    var valid_prefix = (
                        len(letters) == prefix_length and len(letters) > 0
                    )
                    if pure_single and len(letters) == 0:
                        valid_prefix = True
                    if valid_prefix:
                        compact = True
                        if number_start == len(letters):
                            var p_alias = prompt_vocabulary_alias(
                                catalog, language, "command", "p"
                            )
                            var mulpri_alias = prompt_vocabulary_alias(
                                catalog, language, "command", "mulpri"
                            )
                            for letter_index in range(len(letters)):
                                if letters[letter_index] == p_alias:
                                    additions.append(mulpri_alias)
                                else:
                                    additions.append(letters[letter_index])
                            additions.append(suffix)
                        if (
                            pure_single
                            and len(letters) == 0
                            and not selective_output
                        ):
                            for canonical in [
                                "mulpri",
                                "a",
                                "t",
                                "w",
                                "keineEinZeichenZeilenPlusKeineAusgabeWelcherBefehlEsWar",
                            ]:
                                additions.append(
                                    prompt_vocabulary_alias(
                                        catalog, language, "command", canonical
                                    )
                                )
                            var has_fraction = False
                            for source_index in range(len(input_tokens)):
                                if input_tokens[source_index].find("/") >= 0:
                                    has_fraction = True
                            if has_fraction:
                                for canonical in ["u", "B", "G", "E", "groesse"]:
                                    additions.append(
                                        prompt_vocabulary_alias(
                                            catalog, language, "command", canonical
                                        )
                                    )
                            if force_e:
                                additions.append(
                                    "-"
                                    + prompt_vocabulary_alias(
                                        catalog, language, "main", "ausgabe"
                                    )
                                )
                                additions.append(
                                    "--"
                                    + prompt_vocabulary_alias(
                                        catalog,
                                        language,
                                        "output",
                                        "keineueberschriften",
                                    )
                                )
        else:
            var ee_alias = prompt_vocabulary_alias(
                catalog, language, "command", "ee"
            )
            if original == ee_alias:
                additions.append(
                    "-"
                    + prompt_vocabulary_alias(
                        catalog, language, "main", "ausgabe"
                    )
                )
                additions.append(
                    "--"
                    + prompt_vocabulary_alias(
                        catalog, language, "output", "keineueberschriften"
                    )
                )
            else:
                additions.append(original)

        if len(additions) == 0:
            additions.append(original)
        for addition_index in range(len(additions)):
            var value = additions[addition_index]
            if (
                value.byte_length() > 1
                and ord(value[byte=0]) == 40
                and ord(value[byte=value.byte_length() - 1]) == 41
            ):
                value = (
                    "[" + _slice(value, 1, value.byte_length() - 1) + "]"
                )
            result.append(value)

    var shell_alias = prompt_vocabulary_alias(
        catalog, language, "command", "shell"
    )
    var python_alias = prompt_vocabulary_alias(
        catalog, language, "command", "python"
    )
    if (
        first_input == "reta"
        or first_input == shell_alias
        or first_input == python_alias
    ):
        var unchanged = List[String]()
        for index in range(len(input_tokens)):
            unchanged.append(input_tokens[index])
        return PromptExpansionResult(compact, unchanged^)
    return PromptExpansionResult(compact, result^)


def expand_prompt_replacements(
    catalog: PromptLanguageCatalog,
    language: String,
    tokens: List[String],
) -> List[String]:
    var result = List[String]()
    if len(tokens) == 0:
        return result^
    var shell_alias = prompt_vocabulary_alias(
        catalog, language, "command", "shell"
    )
    var python_alias = prompt_vocabulary_alias(
        catalog, language, "command", "python"
    )
    var distance_alias = prompt_vocabulary_alias(
        catalog, language, "command", "abstand"
    )
    if (
        tokens[0] == "reta"
        or tokens[0] == shell_alias
        or tokens[0] == python_alias
        or tokens[0] == distance_alias
    ):
        for index in range(len(tokens)):
            result.append(tokens[index])
        return result^
    for index in range(len(tokens)):
        result.append(expand_prompt_shortcut(catalog, language, tokens[index]))
    return result^



def prepare_prompt_tokens(
    catalog: PromptLanguageCatalog,
    language: String,
    input_tokens: List[String],
    selective_output: Bool = False,
    force_e: Bool = False,
) raises -> PromptExpansionResult:
    """Port the deterministic front half of prompt preparation.

    This composes compact-command expansion, one-character replacement and the
    historically visible builtin-set normalisation.  Regex expansion and
    operation-specific execution remain separate later stages.
    """
    var expanded = expand_compact_prompt_tokens(
        catalog, language, input_tokens, selective_output, force_e
    )
    var replaced = expand_prompt_replacements(catalog, language, expanded.tokens)
    if len(replaced) > 0 and replaced[0] == "reta":
        return PromptExpansionResult(expanded.compact, replaced^)
    return PromptExpansionResult(
        expanded.compact, _python_string_set_order(replaced)
    )
