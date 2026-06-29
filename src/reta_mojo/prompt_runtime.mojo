"""Native runtime model for retaPrompt and its historical launcher profiles.

The terminal line editor and child-process creation remain operating-system
boundaries. Prompt state, profile selection, command classification, history
policy, and the native arithmetic commands are owned by Mojo.
"""

from std.collections import List
from std.collections.string import atol, ord
from .number_theory import prime_factors
from .arithmetic import factor_pairs, factor_triples, modulo_table_lines, prime_repeat_labels, has_digit
from .row_ranges import range_to_numbers
from .prime_cross_columns import python_int_set_order
from .prompt_language import (
    PromptLanguageCatalog,
    balanced_prompt_split,
    localized_prompt_kind,
    normalize_prompt_language,
)


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
    if first == "reta":
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
    """Classify a command through the generated multilingual alias catalog."""
    var text = String(raw.strip())
    var words = split_prompt_words(text)
    if len(words) == 0:
        return PromptCommand(KIND_EMPTY, text^, words^)
    var kind = localized_prompt_kind(catalog, language, words[0])
    if kind >= 0:
        return PromptCommand(kind, text^, words^)
    # Keep the German hard-coded compatibility path for catalogs generated by
    # older source archives and for exact legacy aliases.
    if normalize_prompt_language(language) == "deutsch":
        return classify_prompt_command(text)
    return PromptCommand(KIND_FALLBACK, text^, words^)


def command_payload(command: PromptCommand) -> String:
    """Return the raw text after the first command word."""
    if len(command.words) <= 1:
        return ""
    var result = String()
    for index in range(1, len(command.words)):
        if index > 1:
            result += " "
        result += command.words[index]
    return result^


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
        var pairs = factor_pairs(number)
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
    return python_int_set_order(attempts)


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
    """Native two-range form of ``abstand`` and ``abstandPrim``.

    The legacy implementation uses dictionaries that overwrite for three or
    more independent ranges.  Those ambiguous multi-range forms remain at the
    compatibility boundary; the normal two-range form is exact and native.
    """
    var lines = List[String]()
    if len(command.words) != 3:
        if not prime_distances:
            lines.append(_distance_message(language))
        return lines^
    var left_text = command.words[1]
    var right_text = command.words[2]
    var left = _ordered_range_values(left_text)
    var right = _ordered_range_values(right_text)
    if len(left) == 0 or len(right) == 0:
        if not prime_distances:
            lines.append(_distance_message(language))
        return lines^
    var all_numbers = _is_decimal_prompt(left_text) and _is_decimal_prompt(right_text)

    for direction in range(2):
        var sources = left.copy() if direction == 0 else right.copy()
        var targets = right.copy() if direction == 0 else left.copy()
        if len(targets) <= 1 and not all_numbers:
            continue
        for source_index in range(len(sources)):
            var line = String(sources[source_index]) + "->: "
            for target_index in range(len(targets)):
                if target_index > 0:
                    line += ", "
                var distance = abs(sources[source_index] - targets[target_index])
                line += String(targets[target_index]) + ": "
                if prime_distances:
                    line += _prime_factor_python_list(distance)
                else:
                    line += String(distance)
            lines.append(line^)
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
        and startup.command_tokens[0] == "reta"
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
struct NativePromptSession(Copyable):
    var logging_enabled: Bool
    var stored_tokens: List[String]
    var previous_command: String
    var store_next: Bool
    var delete_next: Bool


def new_prompt_session(logging_enabled: Bool) -> NativePromptSession:
    return NativePromptSession(
        logging_enabled,
        List[String](),
        "",
        False,
        False,
    )


def prompt_prefix(session: NativePromptSession) -> String:
    if session.store_next:
        return "speichern> "
    if session.delete_next:
        return "loeschen> "
    return "> "


def _append_nonempty_words(text: String, mut target: List[String]) -> None:
    var words = split_prompt_words(text)
    for index in range(len(words)):
        if words[index].byte_length() > 0:
            target.append(words[index])


def store_prompt_text(mut session: NativePromptSession, text: String) -> None:
    _append_nonempty_words(text, session.stored_tokens)
    session.store_next = False


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


def delete_stored_selection(
    mut session: NativePromptSession,
    selection: String,
) raises -> None:
    var cleaned = String(selection.strip())
    if cleaned.byte_length() == 0:
        session.delete_next = False
        return

    var keep = List[String]()
    if has_digit(cleaned):
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
