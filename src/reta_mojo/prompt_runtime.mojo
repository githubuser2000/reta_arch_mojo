"""Native runtime model for retaPrompt and its historical launcher profiles.

The terminal line editor and child-process creation remain operating-system
boundaries. Prompt state, profile selection, command classification, shell-style argv
tokenization, history policy, and the native arithmetic commands are owned by Mojo.
"""

from std.collections import List
from std.collections.string import StringSlice, atol, ord
from .number_theory import prime_factors
from .arithmetic import factor_pairs, factor_triples, modulo_table_lines, prime_repeat_labels
from .row_ranges import range_to_numbers, is_row_range
from .prime_cross_columns import python_int_set_order, python_signed_int_set_order
from .prompt_language import (
    PromptLanguageCatalog,
    balanced_prompt_split,
    localized_prompt_kind,
    normalize_prompt_language,
    python_string_set_order,
)


comptime _STATE_NORMAL = 0
comptime _STATE_SINGLE_QUOTE = 1
comptime _STATE_DOUBLE_QUOTE = 2


def _slice(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def _next_codepoint_end(text: String, start: Int) -> Int:
    """Return the byte offset after the UTF-8 codepoint at ``start``."""
    var bytes = text.as_bytes()
    if start >= len(bytes):
        return start
    var end = start + 1
    while end < len(bytes) and (Int(bytes[end]) & 0xC0) == 0x80:
        end += 1
    return end


def shell_split(text: String) raises -> List[String]:
    """Small POSIX-shlex parser used by the historical ``shell`` command.

    It preserves Unicode, empty quoted arguments, single/double quotes and
    backslash escaping while deliberately performing no variable expansion,
    globbing or shell interpretation, matching ``shlex.split`` + ``Popen(argv)``.
    """
    var result = List[String]()
    var current = String()
    var token_started = False
    var state = _STATE_NORMAL
    var index = 0
    var bytes = text.as_bytes()

    while index < len(bytes):
        var code = Int(bytes[index])
        var end = _next_codepoint_end(text, index)
        var value = _slice(text, index, end)

        if state == _STATE_NORMAL:
            if code == 32 or code == 9 or code == 10 or code == 13:
                if token_started:
                    result.append(current)
                    current = String()
                    token_started = False
                index = end
                continue
            if code == 39:  # '
                state = _STATE_SINGLE_QUOTE
                token_started = True
                index = end
                continue
            if code == 34:  # "
                state = _STATE_DOUBLE_QUOTE
                token_started = True
                index = end
                continue
            if code == 92:  # backslash
                if end >= len(bytes):
                    raise Error("No escaped character")
                var escaped_end = _next_codepoint_end(text, end)
                current += _slice(text, end, escaped_end)
                token_started = True
                index = escaped_end
                continue
            current += value
            token_started = True
            index = end
            continue

        if state == _STATE_SINGLE_QUOTE:
            if code == 39:
                state = _STATE_NORMAL
            else:
                current += value
            index = end
            continue

        # POSIX shlex inside double quotes: backslash only quotes backslash,
        # double quote, dollar, backtick and newline.  Before other characters
        # it remains a literal backslash.
        if code == 34:
            state = _STATE_NORMAL
            index = end
            continue
        if code == 92:
            if end >= len(bytes):
                raise Error("No escaped character")
            var escaped_end = _next_codepoint_end(text, end)
            var escaped_code = Int(bytes[end])
            if escaped_code == 10:
                pass
            elif (
                escaped_code == 34
                or escaped_code == 36
                or escaped_code == 92
                or escaped_code == 96
            ):
                current += _slice(text, end, escaped_end)
            else:
                current += "\\" + _slice(text, end, escaped_end)
            token_started = True
            index = escaped_end
            continue
        current += value
        token_started = True
        index = end

    if state != _STATE_NORMAL:
        raise Error("No closing quotation")
    if token_started:
        result.append(current)
    return result^



comptime KIND_EMPTY = 0
comptime KIND_EXIT = 1
comptime KIND_HELP = 2
comptime KIND_COMMANDS = 3
comptime KIND_SHORT_COMMANDS = 4
comptime KIND_LOG_ON = 5
comptime KIND_LOG_OFF = 6
comptime KIND_CLEAR = 7
comptime KIND_PRIME = 8
comptime KIND_MULTIS = 9
comptime KIND_MODULO = 10
comptime KIND_ABC = 11
comptime KIND_SHELL = 12
comptime KIND_PYTHON = 13
comptime KIND_MATH = 14
comptime KIND_RETA = 15
comptime KIND_PRIME24 = 16
comptime KIND_STORE_NEXT = 17
comptime KIND_STORE_PREVIOUS = 18
comptime KIND_OUTPUT_STORED = 19
comptime KIND_DELETE_STORED = 20
comptime KIND_FALLBACK = 21
comptime KIND_MULTIS3 = 22
comptime KIND_PRIME_COMPARE = 23
comptime KIND_MOON = 24
comptime KIND_DISTANCE = 25
comptime KIND_DISTANCE_PRIME = 26
comptime KIND_DIRECTION = 27


@fieldwise_init
struct PromptProfile(Copyable, Equatable):
    var name: String
    var vi_mode: Bool
    var logging_enabled: Bool
    var force_e_command: Bool
    var one_shot: Bool
    var emacs_output: Bool
    var language: String
    var show_intro: Bool

    def __eq__(self, other: Self) -> Bool:
        return (
            self.name == other.name
            and self.vi_mode == other.vi_mode
            and self.logging_enabled == other.logging_enabled
            and self.force_e_command == other.force_e_command
            and self.one_shot == other.one_shot
            and self.emacs_output == other.emacs_output
            and self.language == other.language
            and self.show_intro == other.show_intro
        )


@fieldwise_init
struct PromptStartup(Copyable):
    var profile: PromptProfile
    var command_tokens: List[String]
    var show_help: Bool
    var debug: Bool
    var diagnostics: List[String]


@fieldwise_init
struct PromptCommand(Copyable):
    var kind: Int
    var raw: String
    var words: List[String]


def profile_from_name(name: String) -> PromptProfile:
    """Return the exact historical defaults of a public prompt launcher."""
    if name == "rp":
        return PromptProfile("rp", True, True, False, False, False, "deutsch", False)
    if name == "rpl":
        return PromptProfile("rpl", True, False, True, False, False, "deutsch", False)
    if name == "rpb":
        return PromptProfile("rpb", True, False, True, True, False, "deutsch", False)
    if name == "rpe":
        return PromptProfile("rpe", True, False, True, True, True, "deutsch", False)
    if name == "retaPrompt.english":
        return PromptProfile(
            "retaPrompt.english", False, False, False, False, False, "english", True
        )
    if name == "retaPrompt":
        return PromptProfile(
            "retaPrompt", False, True, False, False, False, "deutsch", True
        )
    return PromptProfile(name, False, False, False, False, False, "deutsch", True)


def _append_words(text: String, mut result: List[String]) -> None:
    var slices = text.split()
    for index in range(len(slices)):
        var value = String(slices[index].strip())
        if value.byte_length() > 0:
            result.append(value^)


def split_prompt_words(text: String) -> List[String]:
    """Split prompt input while preserving bracketed range expressions."""
    return balanced_prompt_split(text)


def _tail_words(words: List[String], start: Int) -> List[String]:
    var result = List[String]()
    for index in range(start, len(words)):
        result.append(words[index])
    return result^


def parse_prompt_startup(
    profile_name: String,
    arguments: List[String],
) -> PromptStartup:
    var profile = profile_from_name(profile_name)
    var command_tokens = List[String]()
    var diagnostics = List[String]()
    var show_help = False
    var debug = False
    var capture_command = profile.one_shot

    for index in range(len(arguments)):
        var argument = arguments[index]
        if capture_command:
            command_tokens.append(argument)
            continue
        if argument == "-befehl":
            profile.one_shot = True
            capture_command = True
        elif argument == "-vi":
            profile.vi_mode = True
        elif argument == "-log":
            profile.logging_enabled = True
        elif argument == "-e":
            profile.force_e_command = True
        elif argument == "-debug":
            debug = True
        elif argument == "-h" or argument == "-help":
            show_help = True
        elif argument.startswith("-language="):
            profile.language = normalize_prompt_language(
                String(StringSlice(argument)[byte=10:])
            )
        elif argument.startswith("-"):
            diagnostics.append("unbekannter retaPrompt-Startparameter: " + argument)
        else:
            # Historical launchers accept trailing command text only in one-shot
            # mode. Keep interactive startup strict instead of silently losing it.
            diagnostics.append("Positionsargument ohne -befehl: " + argument)

    return PromptStartup(profile^, command_tokens^, show_help, debug, diagnostics^)


def classify_prompt_command(raw: String) -> PromptCommand:
    var text = String(raw.strip())
    var words = split_prompt_words(text)
    if len(words) == 0:
        return PromptCommand(KIND_EMPTY, text^, words^)

    var first = words[0]
    if len(words) == 2:
        var first_is_abc = first == "abc" or first == "abcd"
        var second_is_abc = words[1] == "abc" or words[1] == "abcd"
        if first_is_abc:
            return PromptCommand(KIND_ABC, text^, words^)
        if second_is_abc:
            var normalized = List[String]()
            normalized.append(words[1])
            normalized.append(words[0])
            return PromptCommand(KIND_ABC, text^, normalized^)
    if first == "q" or first == ":q" or first == "exit" or first == "quit" or first == "ende":
        return PromptCommand(KIND_EXIT, text^, words^)
    if first == "h" or first == "help" or first == "hilfe":
        return PromptCommand(KIND_HELP, text^, words^)
    if first == "befehle":
        return PromptCommand(KIND_COMMANDS, text^, words^)
    if first == "kurzbefehle":
        return PromptCommand(KIND_SHORT_COMMANDS, text^, words^)
    if first == "loggen":
        return PromptCommand(KIND_LOG_ON, text^, words^)
    if first == "nichtloggen":
        return PromptCommand(KIND_LOG_OFF, text^, words^)
    if first == "leeren" or first == "clear":
        return PromptCommand(KIND_CLEAR, text^, words^)
    if first == "prim" or first == "primfaktorzerlegung":
        return PromptCommand(KIND_PRIME, text^, words^)
    if first == "prim24" or first == "primfaktorzerlegungModulo24":
        return PromptCommand(KIND_PRIME24, text^, words^)
    if first == "multis":
        return PromptCommand(KIND_MULTIS, text^, words^)
    if first == "multis3":
        return PromptCommand(KIND_MULTIS3, text^, words^)
    if first == "primfaktorenvergleich":
        return PromptCommand(KIND_PRIME_COMPARE, text^, words^)
    if first == "mond":
        return PromptCommand(KIND_MOON, text^, words^)
    if first == "abstand":
        return PromptCommand(KIND_DISTANCE, text^, words^)
    if first == "abstandPrim":
        return PromptCommand(KIND_DISTANCE_PRIME, text^, words^)
    if first == "richtung" or first == "r":
        return PromptCommand(KIND_DIRECTION, text^, words^)
    if first == "modulo":
        return PromptCommand(KIND_MODULO, text^, words^)
    if first == "abc" or first == "abcd":
        return PromptCommand(KIND_ABC, text^, words^)
    if first == "shell":
        return PromptCommand(KIND_SHELL, text^, words^)
    if first == "python":
        return PromptCommand(KIND_PYTHON, text^, words^)
    if first == "math":
        return PromptCommand(KIND_MATH, text^, words^)
    if first == "reta" or first == "+reta":
        return PromptCommand(KIND_RETA, text^, words^)
    if first == "S" or first == "BefehlSpeichernDanach":
        return PromptCommand(KIND_STORE_NEXT, text^, words^)
    if first == "s" or first == "BefehlSpeichernDavor":
        return PromptCommand(KIND_STORE_PREVIOUS, text^, words^)
    if first == "o" or first == "BefehlSpeicherungAusgeben":
        return PromptCommand(KIND_OUTPUT_STORED, text^, words^)
    if first == "l" or first == "BefehlSpeicherungLöschen":
        return PromptCommand(KIND_DELETE_STORED, text^, words^)
    return PromptCommand(KIND_FALLBACK, text^, words^)


def classify_prompt_command_localized(
    raw: String,
    language: String,
    catalog: PromptLanguageCatalog,
) -> PromptCommand:
    """Classify a command through the generated multilingual alias catalog.

    The historical ``abc``/``abcd`` branch is exceptional: with exactly two
    words it accepts the command token in either position.  Normalize that
    case to command-first storage so ``abc_line`` can keep one typed payload
    contract while ``raw`` remains byte-for-byte untouched.
    """
    var text = String(raw.strip())
    var words = split_prompt_words(text)
    if len(words) == 0:
        return PromptCommand(KIND_EMPTY, text^, words^)
    var kind = localized_prompt_kind(catalog, language, words[0])
    if len(words) == 2:
        if kind == KIND_ABC:
            return PromptCommand(KIND_ABC, text^, words^)
        var second_kind = localized_prompt_kind(
            catalog, language, words[1]
        )
        if second_kind == KIND_ABC:
            var normalized = List[String]()
            normalized.append(words[1])
            normalized.append(words[0])
            return PromptCommand(KIND_ABC, text^, normalized^)
    if kind >= 0:
        return PromptCommand(kind, text^, words^)
    # Keep the German hard-coded compatibility path for catalogs generated by
    # older source archives and for exact legacy aliases.
    if normalize_prompt_language(language) == "deutsch":
        return classify_prompt_command(text)
    return PromptCommand(KIND_FALLBACK, text^, words^)


def command_payload(command: PromptCommand) -> String:
    """Return the normalized text after the first command word."""
    if len(command.words) <= 1:
        return ""
    var result = String()
    for index in range(1, len(command.words)):
        if index > 1:
            result += " "
        result += command.words[index]
    return result^


def command_raw_payload(command: PromptCommand) -> String:
    """Return the exact raw text after the first prompt command token."""
    var bytes = command.raw.as_bytes()
    for index in range(len(bytes)):
        if Int(bytes[index]) == 32:
            return _slice(command.raw, index + 1, len(bytes))
    return ""


def command_argument_tail(command: PromptCommand) -> List[String]:
    """Return command words after the command token as an owned argv tail."""
    var result = List[String]()
    for index in range(1, len(command.words)):
        result.append(command.words[index])
    return result^


def command_raw_payload_arguments(command: PromptCommand) -> List[String]:
    """Return the exact raw payload wrapped as one argv element."""
    var result = List[String]()
    result.append(command_raw_payload(command))
    return result^


def command_shell_arguments(command: PromptCommand) raises -> List[String]:
    """Return shell argv parsed from the command's exact raw payload."""
    return shell_split(command_raw_payload(command))


def _sorted_numbers(expression: String) raises -> List[Int]:
    var values = range_to_numbers(expression, False, 0)
    var result = List[Int]()
    for value in values:
        result.append(value)
    for index in range(1, len(result)):
        var key = result[index]
        var previous = index - 1
        while previous >= 0 and result[previous] > key:
            result[previous + 1] = result[previous]
            previous -= 1
        result[previous + 1] = key
    return result^


def _join_words(words: List[String], start: Int) -> String:
    var result = String()
    for index in range(start, len(words)):
        if index > start:
            result += ","
        result += words[index]
    return result^


def command_numbers(command: PromptCommand) raises -> List[Int]:
    if len(command.words) < 2:
        return List[Int]()
    return _sorted_numbers(_join_words(command.words, 1))


def prime_lines(command: PromptCommand, modulo_24: Bool = False) raises -> List[String]:
    var lines = List[String]()
    var numbers = command_numbers(command)
    for number_index in range(len(numbers)):
        var number = numbers[number_index]
        var factors = prime_factors(number)
        if modulo_24:
            for factor_index in range(len(factors)):
                factors[factor_index] %= 24
        var labels = prime_repeat_labels(factors)
        var line = String(number) + ": "
        for label_index in range(len(labels)):
            if label_index > 0:
                line += " "
            line += labels[label_index]
        lines.append(line^)
    return lines^


def multis_lines(command: PromptCommand) raises -> List[String]:
    var lines = List[String]()
    var numbers = command_numbers(command)
    for number_index in range(len(numbers)):
        var number = numbers[number_index]
        var pairs = factor_pairs(number, False)
        var line = String(number) + ": ["
        for pair_index in range(len(pairs)):
            if pair_index > 0:
                line += ", "
            line += "(" + String(pairs[pair_index].first) + ", " + String(pairs[pair_index].second) + ")"
        line += "]"
        lines.append(line^)
    return lines^


def multis3_lines(command: PromptCommand) raises -> List[String]:
    var lines = List[String]()
    var numbers = command_numbers(command)
    for number_index in range(len(numbers)):
        var number = numbers[number_index]
        var triples = factor_triples(number)
        var line = String(number) + ": ["
        for triple_index in range(len(triples)):
            if triple_index > 0:
                line += ", "
            line += (
                "("
                + String(triples[triple_index].first)
                + ", "
                + String(triples[triple_index].second)
                + ", "
                + String(triples[triple_index].third)
                + ")"
            )
        line += "]"
        lines.append(line^)
    return lines^


def modulo_lines(command: PromptCommand) raises -> List[String]:
    return modulo_table_lines(command_numbers(command))


def abc_line(command: PromptCommand) raises -> String:
    if len(command.words) != 2:
        return ""
    var word = command.words[1].lower()
    var result = String()
    for index in range(word.byte_length()):
        var byte = ord(word[byte=index])
        if byte >= 97 and byte <= 122:
            if result.byte_length() > 0:
                result += " "
            result += String(byte - 96)
    return result^




def _is_decimal_prompt(text: String) -> Bool:
    if text.byte_length() == 0:
        return False
    for index in range(text.byte_length()):
        var value = ord(text[byte=index])
        if value < 48 or value > 57:
            return False
    return True


def _ordered_range_values(expression: String) raises -> List[Int]:
    var unordered = range_to_numbers(expression, False, 0)
    var attempts = List[Int]()
    # BereichToNumbers2 ultimately constructs a Python set.  Integer hashes are
    # their values, so insertion attempts followed by CPython table order are
    # sufficient for the visible historical ordering.
    for value in unordered:
        attempts.append(value)
    return python_signed_int_set_order(attempts)


@fieldwise_init
struct _PromptDistanceRange(Copyable):
    var raw: String
    var values: List[Int]
    var hash_value: UInt64


def _distance_contains(values: List[Int], wanted: Int) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _distance_ranges_equal(
    left: _PromptDistanceRange, right: _PromptDistanceRange
) -> Bool:
    if len(left.values) != len(right.values):
        return False
    for index in range(len(left.values)):
        if not _distance_contains(right.values, left.values[index]):
            return False
    return True


def _distance_shuffle_bits(hash_value: UInt64) -> UInt64:
    # CPython 3.13 Objects/setobject.c::_shuffle_bits(). UInt64 arithmetic is
    # intentional: Py_uhash_t overflow is part of the public frozenset hash.
    return (
        (hash_value ^ UInt64(89869747)) ^ (hash_value << UInt64(16))
    ) * UInt64(3644798167)


def _distance_int_hash(value: Int) -> UInt64:
    # PyLong hashes as its integer value except for the C-API error sentinel -1.
    return UInt64(-2 if value == -1 else value)


def _distance_frozenset_hash(values: List[Int]) -> UInt64:
    # Fresh frozensets have no dummy entries.  CPython's null-entry correction
    # therefore reduces to xor-ing the shuffled active hashes plus the size mix.
    var hash_value = UInt64(0)
    for index in range(len(values)):
        hash_value ^= _distance_shuffle_bits(_distance_int_hash(values[index]))
    hash_value ^= UInt64(len(values) + 1) * UInt64(1927868237)
    hash_value ^= (hash_value >> UInt64(11)) ^ (hash_value >> UInt64(25))
    hash_value = hash_value * UInt64(69069) + UInt64(907133923)
    if hash_value == UInt64.MAX:
        return UInt64(590923713)
    return hash_value


def _distance_empty_slots(size: Int) -> List[Int]:
    var result = List[Int]()
    for _ in range(size):
        result.append(-1)
    return result^


def _distance_set_slot(
    slots: List[Int],
    stored: List[_PromptDistanceRange],
    value: _PromptDistanceRange,
) -> Int:
    var mask = len(slots) - 1
    var index = Int(value.hash_value & UInt64(mask))
    var perturb = value.hash_value
    while True:
        var stored_index = slots[index]
        if (
            stored_index == -1
            or _distance_ranges_equal(stored[stored_index], value)
        ):
            return index
        var probes = 9 if index + 9 <= mask else 0
        for offset in range(1, probes + 1):
            stored_index = slots[index + offset]
            if (
                stored_index == -1
                or _distance_ranges_equal(stored[stored_index], value)
            ):
                return index + offset
        perturb >>= UInt64(5)
        index = Int(
            (UInt64(index * 5 + 1) + perturb) & UInt64(mask)
        )


def _distance_set_resize(
    slots: List[Int],
    stored: List[_PromptDistanceRange],
    minimum_used: Int,
) -> List[Int]:
    var new_size = 8
    while new_size <= minimum_used:
        new_size <<= 1
    var resized = _distance_empty_slots(new_size)
    for index in range(len(slots)):
        var stored_index = slots[index]
        if stored_index >= 0:
            var target = _distance_set_slot(
                resized, stored, stored[stored_index]
            )
            resized[target] = stored_index
    return resized^


def _python_distance_range_set_order(
    attempts: List[_PromptDistanceRange],
) -> List[_PromptDistanceRange]:
    """Reproduce ``zahlenBereiche |= {frozenset(...)}`` slot order.

    The singleton-set merge checks its resize threshold before every merge.  It
    is observably different from a set comprehension once five or more ranges
    are supplied, so insertion attempts and duplicate merges are retained.
    """
    var slots = _distance_empty_slots(8)
    var stored = List[_PromptDistanceRange]()
    var fill = 0
    var used = 0
    for attempt_index in range(len(attempts)):
        var value = attempts[attempt_index].copy()
        var mask = len(slots) - 1
        if (fill + 1) * 5 >= mask * 3:
            slots = _distance_set_resize(
                slots, stored, (used + 1) * 2
            )
            fill = used
        var target = _distance_set_slot(slots, stored, value)
        if slots[target] >= 0:
            continue
        stored.append(value.copy())
        slots[target] = len(stored) - 1
        fill += 1
        used += 1

    var result = List[_PromptDistanceRange]()
    for index in range(len(slots)):
        if slots[index] >= 0:
            result.append(stored[slots[index]].copy())
    return result^


def _python_distance_difference_order(
    outer_order: List[_PromptDistanceRange],
) -> List[_PromptDistanceRange]:
    """Reproduce the fresh result set built by ``set_difference``.

    The right-hand operand contains integers while the left-hand set contains
    frozensets, so no logical element is removed.  CPython still inserts every
    left-hand entry into a new set, whose slot order can differ observably from
    the original set.  Unlike singleton ``set_merge``, ordinary ``set.add``
    tests the resize threshold after inserting the new element.
    """
    var slots = _distance_empty_slots(8)
    var stored = List[_PromptDistanceRange]()
    var fill = 0
    var used = 0
    for attempt_index in range(len(outer_order)):
        var value = outer_order[attempt_index].copy()
        var target = _distance_set_slot(slots, stored, value)
        if slots[target] >= 0:
            continue
        stored.append(value.copy())
        slots[target] = len(stored) - 1
        fill += 1
        used += 1
        var mask = len(slots) - 1
        if fill * 5 >= mask * 3:
            var minimum_used = used * 4 if used <= 50000 else used * 2
            slots = _distance_set_resize(slots, stored, minimum_used)
            fill = used

    var result = List[_PromptDistanceRange]()
    for index in range(len(slots)):
        if slots[index] >= 0:
            result.append(stored[slots[index]].copy())
    return result^


def _python_distance_inner_order(
    outer_order: List[_PromptDistanceRange],
) -> List[_PromptDistanceRange]:
    """Select the same ``set_difference`` strategy as CPython 3.13.

    If the outer set is more than four times larger than the integer
    frozenset being subtracted, CPython copies the outer set and discards the
    integer keys.  No integer can equal a frozenset, so this preserves the
    outer slot order.  Otherwise the result is built by ordinary insertions.
    """
    var largest = 0
    for index in range(len(outer_order)):
        if len(outer_order[index].values) > largest:
            largest = len(outer_order[index].values)
    if (len(outer_order) >> 2) > largest:
        var copied = List[_PromptDistanceRange]()
        for index in range(len(outer_order)):
            copied.append(outer_order[index].copy())
        return copied^
    return _python_distance_difference_order(outer_order)


def _distance_range_arguments(
    command: PromptCommand,
) raises -> List[_PromptDistanceRange]:
    var result = List[_PromptDistanceRange]()
    # Prompt preparation stores the complete token stream in a Python set.
    # Reorder and deduplicate before selecting the numeric range tokens.
    var ordered_words = python_string_set_order(command.words)
    for index in range(len(ordered_words)):
        var token = ordered_words[index]
        try:
            if not is_row_range(token):
                continue
            var values = _ordered_range_values(token)
            result.append(
                _PromptDistanceRange(
                    token, values.copy(), _distance_frozenset_hash(values)
                )
            )
        except:
            pass
    return result^

def _prime_factor_python_list(number: Int) -> String:
    var factors = prime_factors(abs(number))
    if len(factors) == 0:
        return "[]"
    var result = String("[")
    var index = 0
    var first = True
    while index < len(factors):
        var prime = factors[index]
        var count = 1
        while index + count < len(factors) and factors[index + count] == prime:
            count += 1
        if not first:
            result += ", "
        if count > 1:
            result += "'" + String(prime) + "^" + String(count) + "'"
        else:
            result += String(prime)
        first = False
        index += count
    return result + "]"


def _distance_message(language: String) -> String:
    if normalize_prompt_language(language) == "deutsch":
        return "der Befehl 'abstand' verlangt mindestens 2 Zahlenangaben, wie 'abstand 7 17-25'"
    return "the command distance' need at least 2 number or number ranges, as 'distance 7 17-25'"


def distance_lines(
    command: PromptCommand,
    prime_distances: Bool = False,
    language: String = "deutsch",
) raises -> List[String]:
    """Native port of all stable ``abstand``/``abstandPrim`` range counts.

    The Python reference stores each expanded range as ``frozenset[int]`` in an
    outer builtin set and then repeatedly overwrites dictionary values while
    retaining first-insertion key order.  This deliberately odd algorithm is
    reproduced exactly, including duplicate ranges and 3+ range commands.
    """
    var lines = List[String]()
    var attempts = _distance_range_arguments(command)
    if len(attempts) < 2:
        if not prime_distances:
            lines.append(_distance_message(language))
        return lines^

    var all_numbers = True
    for index in range(len(attempts)):
        if not _is_decimal_prompt(attempts[index].raw):
            all_numbers = False
            break

    var ranges = _python_distance_range_set_order(attempts)
    var inner_ranges = _python_distance_inner_order(ranges)
    var source_order = List[Int]()
    var source_payloads = List[String]()

    # ``zahlenBereiche - maxMenge(zahlenBereiche)`` cannot remove a
    # frozenset, because the right-hand operand is iterated as integers.  The
    # logical contents therefore stay equal, but CPython creates a fresh set
    # and reinserts the outer entries.  Its independent slot order is visible.
    for target_index in range(len(ranges)):
        var targets = ranges[target_index].copy()
        for source_range_index in range(len(inner_ranges)):
            var sources = inner_ranges[source_range_index].copy()
            if _distance_ranges_equal(targets, sources):
                continue
            for source_index in range(len(sources.values)):
                var source = sources.values[source_index]
                if len(targets.values) <= 1 and not all_numbers:
                    continue
                var payload = String()
                for value_index in range(len(targets.values)):
                    if value_index > 0:
                        payload += ", "
                    var target = targets.values[value_index]
                    var distance = abs(source - target)
                    payload += String(target) + ": "
                    if prime_distances:
                        payload += _prime_factor_python_list(distance)
                    else:
                        payload += String(distance)

                var known_index = -1
                for index in range(len(source_order)):
                    if source_order[index] == source:
                        known_index = index
                        break
                if known_index >= 0:
                    source_payloads[known_index] = payload
                else:
                    source_order.append(source)
                    source_payloads.append(payload)

    for index in range(len(source_order)):
        lines.append(
            String(source_order[index]) + "->: " + source_payloads[index]
        )
    return lines^

def _gcd_prompt(left: Int, right: Int) -> Int:
    var a = abs(left)
    var b = abs(right)
    while b != 0:
        var rest = a % b
        a = b
        b = rest
    return a


def _pad_right_prompt(value: String, width: Int) -> String:
    var result = value
    while result.byte_length() < width:
        result += " "
    return result^


def _commonalities_word(language: String) -> String:
    if normalize_prompt_language(language) == "deutsch":
        return "Gemeinsamkeiten"
    return "commonalities"


def prime_comparison_lines(command: PromptCommand, language: String = "deutsch") raises -> List[String]:
    """Native port of the prompt ``primfaktorenvergleich`` branch."""
    var lines = List[String]()
    var numbers = command_numbers(command)
    if len(numbers) == 0:
        return lines^

    var common = abs(numbers[0])
    for index in range(1, len(numbers)):
        common = _gcd_prompt(common, numbers[index])
    if common == 0:
        common = 1

    var common_factors = prime_factors(common)
    var common_text = String("1")
    if len(common_factors) > 0:
        common_text = String()
        for index in range(len(common_factors)):
            if index > 0:
                common_text += " * "
            common_text += String(common_factors[index])
    lines.append(
        _commonalities_word(language)
        + ": "
        + String(common)
        + " := "
        + common_text
    )

    for index in range(len(numbers)):
        var number = numbers[index]
        var quotient = number // common if common != 0 else number
        var quotient_factors = prime_factors(quotient)
        var factor_text = String("1")
        if len(quotient_factors) > 0:
            factor_text = String()
            for factor_index in range(len(quotient_factors)):
                if factor_index > 0:
                    factor_text += " * "
                factor_text += String(quotient_factors[factor_index])
        lines.append(
            _pad_right_prompt(String(quotient), 5)
            + " := "
            + _pad_right_prompt(String(number), 5)
            + " / "
            + _pad_right_prompt(String(common), 5)
            + " -> "
            + factor_text
        )
    return lines^

def one_shot_command_line(startup: PromptStartup) -> String:
    """Construct the command line supplied by rpb/rpe or explicit -befehl."""
    var line = String()
    for index in range(len(startup.command_tokens)):
        if index > 0:
            line += " "
        line += startup.command_tokens[index]
    return line^


def fallback_profile_arguments(profile: PromptProfile) -> List[String]:
    """Flags used only while an advanced command still crosses to Python."""
    var result = List[String]()
    if profile.vi_mode:
        result.append("-vi")
    if profile.logging_enabled:
        result.append("-log")
    if profile.force_e_command:
        result.append("-e")
    if normalize_prompt_language(profile.language) != "deutsch":
        result.append("-language=" + normalize_prompt_language(profile.language))
    result.append("-befehl")
    return result^


def reta_prompt_fallback_arguments_native(
    profile_arguments: List[String],
    command_arguments: List[String],
) -> List[String]:
    """Merge typed prompt-profile flags and tokenized fallback command argv.

    This is prompt runtime semantics, not process-adapter semantics: callers
    choose the fallback profile and command arguments here, then pass the final
    argv vector to the regular ``retaPrompt.py`` process boundary.
    """
    var arguments = List[String]()
    for index in range(len(profile_arguments)):
        if profile_arguments[index].byte_length() > 0:
            arguments.append(profile_arguments[index])
    for index in range(len(command_arguments)):
        arguments.append(command_arguments[index])
    return arguments^


def emacs_wrapped_command(profile: PromptProfile, line: String) -> String:
    """Apply the historical rpe output additions without mutating argv globally."""
    if not profile.emacs_output:
        return line
    var stripped = String(line.strip())
    if stripped.startswith("reta"):
        return stripped + " -ausgabe --art=emacs --keineueberschriften"
    return (
        "-ausgabe --art=emacs --keineueberschriften " + stripped + " e"
    )


def effective_one_shot_tokens(startup: PromptStartup) -> List[String]:
    var result = List[String]()
    if not startup.profile.emacs_output:
        for index in range(len(startup.command_tokens)):
            result.append(startup.command_tokens[index])
        return result^

    var direct_reta = (
        len(startup.command_tokens) > 0
        and (startup.command_tokens[0] == "reta" or startup.command_tokens[0] == "+reta")
    )
    if not direct_reta:
        result.append("-ausgabe")
        result.append("--art=emacs")
        result.append("--keineueberschriften")
    for index in range(len(startup.command_tokens)):
        result.append(startup.command_tokens[index])
    if direct_reta:
        result.append("-ausgabe")
        result.append("--art=emacs")
        result.append("--keineueberschriften")
    else:
        result.append("e")
    return result^


def join_prompt_tokens(tokens: List[String]) -> String:
    var line = String()
    for index in range(len(tokens)):
        if index > 0:
            line += " "
        line += tokens[index]
    return line^


@fieldwise_init
struct PromptProgramViewContract(Copyable):
    var class_name: String
    var main_parameter_names: List[String]
    var main_parameter_indices: List[Int]
    var para_n_data_matrix_len: Int
    var para_dict_len: Int
    var data_dict_sizes: List[Int]
    var combination_reverse_len: Int
    var combination_reverse2_len: Int
    var simple_command_columns_len: Int
    var max_rows_1024: Int
    var max_rows_114: Int


@fieldwise_init
struct PromptVocabularyContract(Copyable):
    var main_parameters_len: Int
    var row_parameters_len: Int
    var output_parameters_len: Int
    var output_modes_len: Int
    var combination_parameters_len: Int
    var command_values_len: Int
    var commands_len: Int
    var column_dictionary_keys: Int
    var columns_len: Int
    var fraction_allowed_numbers_len: Int
    var main_for_sub_len: Int


@fieldwise_init
struct PromptRuntimeContract(Copyable):
    var language: String
    var program: PromptProgramViewContract
    var vocabulary: PromptVocabularyContract
    var normal_prefix: String
    var store_prefix: String
    var delete_prefix: String
    var wahl15_valid: Bool
    var wahl15_missing_values: List[String]


def prime_command_predicate(num: Int) -> Int:
    """Port ``prompt_runtime._prime_command_predicate`` exactly."""
    if num <= 1:
        return 0
    if num == 2:
        return 1
    if num % 2 == 0:
        return 3
    var divisor = 3
    while divisor * divisor <= num:
        if num % divisor == 0:
            return 3
        divisor += 2
    return 1


def prompt_runtime_contract_snapshot(contract: PromptRuntimeContract) -> List[String]:
    var result = List[String]()
    result.append("language=" + contract.language)
    result.append("program_class=" + contract.program.class_name)
    result.append("main_parameters=" + String(len(contract.program.main_parameter_names)))
    result.append("para_dict=" + String(contract.program.para_dict_len))
    result.append("data_dicts=" + String(len(contract.program.data_dict_sizes)))
    result.append("kombi=" + String(contract.program.combination_reverse_len))
    result.append("kombi2=" + String(contract.program.combination_reverse2_len))
    result.append("simple_columns=" + String(contract.program.simple_command_columns_len))
    result.append("normal_prefix=" + contract.normal_prefix)
    result.append("store_prefix=" + contract.store_prefix)
    result.append("delete_prefix=" + contract.delete_prefix)
    result.append("wahl15_valid=" + ("1" if contract.wahl15_valid else "0"))
    result.append("wahl15_missing=" + String(len(contract.wahl15_missing_values)))
    return result^
