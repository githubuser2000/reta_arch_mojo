"""Native fraction-expression front end from prompt_execution.py.

This module ports the pure parsing stage used before the historical ``w`` and
fraction-range execution branches.  It intentionally preserves the unusual
legacy representation: alternating text groups and two-number fraction groups.
No Python runtime or regular-expression engine is involved.
"""

from std.collections import List
from std.collections.string import atol, ord


@fieldwise_init
struct _FractionSegment(Copyable):
    var valid: Bool
    var before_numbers: List[String]
    var text: List[String]
    var after_numbers: List[String]
    var plain_numbers: List[String]
    var has_text: Bool


@fieldwise_init
struct PromptFractionParse(Copyable):
    var valid: Bool
    var groups: List[List[String]]


@fieldwise_init
struct PromptFractionRange(Copyable):
    var valid: Bool
    var values: List[Int]
    var suffix: String


def _is_digit(value: Int) -> Bool:
    return value >= 48 and value <= 57


def _all_decimal(values: List[String]) -> Bool:
    if len(values) == 0:
        return False
    for value_index in range(len(values)):
        var value = values[value_index]
        if value.byte_length() == 0:
            return False
        for index in range(value.byte_length()):
            if not _is_digit(ord(value[byte=index])):
                return False
    return True


def _empty_strings() -> List[String]:
    return List[String]()


def _copy_strings(values: List[String]) -> List[String]:
    var result = List[String]()
    for index in range(len(values)):
        result.append(values[index])
    return result^


def _parse_segment(raw: String, is_first: Bool, is_last: Bool) -> _FractionSegment:
    var number_keys = List[Int]()
    var number_values = List[String]()
    var text_keys = List[Int]()
    var text_values = List[String]()
    var was_number = False
    var key = 0

    for index in range(raw.byte_length()):
        var digit = _is_digit(ord(raw[byte=index]))
        var character = String(raw[byte=index])
        if digit:
            if not was_number:
                key += 1
                number_keys.append(key)
                number_values.append(character)
            else:
                number_values[len(number_values) - 1] += character
            was_number = True
        else:
            if was_number:
                key += 1
                text_keys.append(key)
                text_values.append(character)
            elif len(text_keys) == 0 or text_keys[len(text_keys) - 1] != key:
                text_keys.append(key)
                text_values.append(character)
            else:
                text_values[len(text_values) - 1] += character
            was_number = False

    var empty = List[String]()
    if len(number_keys) == 0:
        return _FractionSegment(False, empty^, List[String](), List[String](), List[String](), False)

    var valid = False
    if is_first:
        valid = True
        var zipped = min(len(text_keys), len(number_keys))
        for index in range(zipped):
            if not (number_keys[index] > text_keys[index]):
                valid = False
    elif is_last:
        valid = True
        var zipped = min(len(text_keys), len(number_keys))
        for index in range(zipped):
            if number_keys[index] > text_keys[index]:
                valid = False
    else:
        if len(text_keys) > 0:
            var min_number = number_keys[0]
            var max_number = number_keys[0]
            for index in range(1, len(number_keys)):
                min_number = min(min_number, number_keys[index])
                max_number = max(max_number, number_keys[index])
            valid = True
            for index in range(len(text_keys)):
                if text_keys[index] <= min_number or text_keys[index] >= max_number:
                    valid = False
        else:
            valid = False

    if not valid:
        return _FractionSegment(False, empty^, List[String](), List[String](), List[String](), False)

    if len(text_keys) == 0:
        return _FractionSegment(True, List[String](), List[String](), List[String](), number_values^, False)

    var min_text = text_keys[0]
    var max_text = text_keys[0]
    for index in range(1, len(text_keys)):
        min_text = min(min_text, text_keys[index])
        max_text = max(max_text, text_keys[index])

    var before = List[String]()
    var after = List[String]()
    for index in range(len(number_keys)):
        if number_keys[index] < min_text:
            before.append(number_values[index])
        elif number_keys[index] > max_text:
            after.append(number_values[index])

    if is_last and len(after) > 0:
        return _FractionSegment(False, empty^, List[String](), List[String](), List[String](), False)
    return _FractionSegment(True, before^, text_values^, after^, List[String](), True)


def parse_prompt_fraction(text: String) -> PromptFractionParse:
    """Port of ``bruchSpalt`` with the same alternating group contract."""
    var raw_parts = text.split("/")
    var groups = List[List[String]]()
    if len(raw_parts) < 2:
        return PromptFractionParse(False, groups^)

    var segments = List[_FractionSegment]()
    for index in range(len(raw_parts)):
        var segment = _parse_segment(
            String(raw_parts[index]), index == 0, index == len(raw_parts) - 1
        )
        if not segment.valid:
            return PromptFractionParse(False, List[List[String]]())
        segments.append(segment^)

    for boundary in range(len(segments) - 1):
        var left = segments[boundary].copy()
        var right = segments[boundary + 1].copy()
        var before = _copy_strings(left.text) if left.has_text else List[String]()
        var numerator = _copy_strings(left.after_numbers) if left.has_text else _copy_strings(left.plain_numbers)
        var denominator = _copy_strings(right.before_numbers) if right.has_text else _copy_strings(right.plain_numbers)
        var pair = List[String]()
        for index in range(len(numerator)):
            pair.append(numerator[index])
        for index in range(len(denominator)):
            pair.append(denominator[index])
        groups.append(before^)
        groups.append(pair^)
    var tail = _copy_strings(segments[len(segments) - 1].text) if segments[len(segments) - 1].has_text else List[String]()
    groups.append(tail^)
    return PromptFractionParse(True, groups^)


def _append_text(values: List[String], mut result: String) -> None:
    for index in range(len(values)):
        result += values[index]


def create_prompt_fraction_range(groups: List[List[String]]) raises -> PromptFractionRange:
    """Port of ``createRangesForBruchLists`` without Python ``range`` objects."""
    var values = List[Int]()
    if len(groups) == 3 and len(groups[0]) == 0 and len(groups[1]) == 2 and len(groups[2]) == 0 and _all_decimal(groups[1]):
        values.append(atol(groups[1][0]))
        return PromptFractionRange(True, values^, groups[1][1])

    var original = List[Int]()
    var n1 = List[Int]()
    var n2 = List[Int]()
    var suffix = String()
    var flag = 0

    for index in range(len(groups)):
        if flag == -1 or flag > 3:
            return PromptFractionRange(False, List[Int](), "")
        if flag == 3:
            suffix += String(n2[len(n2) - 2]) + "-" + String(n2[len(n2) - 1])
            values = List[Int]()
            for number in range(n1[len(n1) - 2], n1[len(n1) - 1] + 1):
                values.append(number)
            original = _copy_ints(values)
            flag = -1

        var group = groups[index].copy()
        if len(group) == 2 and _all_decimal(group):
            var before_minus = index > 0 and len(groups[index - 1]) == 1 and groups[index - 1][0] == "-" and flag == 2
            var after_minus = index + 1 < len(groups) and len(groups[index + 1]) == 1 and groups[index + 1][0] == "-" and flag == 0
            if before_minus or after_minus:
                n1.append(atol(group[0]))
                n2.append(atol(group[1]))
                flag += 1
            else:
                suffix += group[1]
                if len(values) > 0 and index > 0 and len(groups[index - 1]) == 1 and groups[index - 1][0] == "+":
                    var shifted = List[Int]()
                    for value_index in range(len(original)):
                        shifted.append(original[value_index] + atol(group[0]))
                        shifted.append(original[value_index] - atol(group[0]))
                    values = shifted^
                elif len(values) == 0:
                    values.append(atol(group[0]))
                    original = _copy_ints(values)
        elif len(group) == 1 and group[0] == "-" and flag > 0:
            flag += 1
        else:
            flag = 0
            _append_text(group, suffix)

    return PromptFractionRange(True, values^, suffix^)


def _copy_ints(values: List[Int]) -> List[Int]:
    var result = List[Int]()
    for index in range(len(values)):
        result.append(values[index])
    return result^


@fieldwise_init
struct PromptWholeFractionValues(Copyable):
    var whole: List[String]
    var reciprocal_whole: List[String]


@fieldwise_init
struct PromptAddedFractionValues(Copyable):
    var has_integer: Bool
    var reciprocal_integers: List[String]
    var all_tokens: List[String]
    var integer_tokens: List[String]


def _gcd(left: Int, right: Int) -> Int:
    var a = abs(left)
    var b = abs(right)
    while b != 0:
        var rest = a % b
        a = b
        b = rest
    return a


def _contains_string(values: List[String], needle: String) -> Bool:
    for index in range(len(values)):
        if values[index] == needle:
            return True
    return False


def equal_fraction_axes(
    numerators: List[Int], denominators: List[Int]
) -> List[String]:
    """Port of ``findEqualNennerZaehler`` for already parsed ranges."""
    var result = List[String]()
    for denominator_index in range(len(denominators)):
        var denominator = denominators[denominator_index]
        for numerator_index in range(len(numerators)):
            if denominator == numerators[numerator_index] and denominator != 0 and denominator != 1:
                var text = String(denominator)
                if not _contains_string(result, text):
                    result.append(text^)
    return result^


def whole_fraction_axes(
    numerators: List[Int], denominators: List[Int]
) -> PromptWholeFractionValues:
    """Port of ``findNennerZaehlerMakesWholeNum`` without Fraction objects."""
    var whole = List[String]()
    var reciprocal = List[String]()
    for denominator_index in range(len(denominators)):
        var denominator = denominators[denominator_index]
        for numerator_index in range(len(numerators)):
            var numerator = numerators[numerator_index]
            if numerator == 0 or denominator == 0:
                continue
            if denominator % numerator == 0:
                whole.append(String(denominator // numerator))
            if numerator % denominator == 0:
                reciprocal.append(String(numerator // denominator))
    return PromptWholeFractionValues(whole^, reciprocal^)


def add_prompt_fraction_value(
    has_integer: Bool,
    numerator: Int,
    denominator: Int,
    reciprocal_integers: List[String],
    all_tokens: List[String],
    integer_tokens: List[String],
) -> PromptAddedFractionValues:
    """Typed equivalent of the historical ``addMoreVals`` helper."""
    var has_value = has_integer
    var reciprocals = _copy_strings(reciprocal_integers)
    var all_values = _copy_strings(all_tokens)
    var integers = _copy_strings(integer_tokens)
    if denominator == 0:
        return PromptAddedFractionValues(has_value, reciprocals^, all_values^, integers^)

    var divisor = _gcd(numerator, denominator)
    if divisor == 0:
        return PromptAddedFractionValues(has_value, reciprocals^, all_values^, integers^)
    var n = numerator // divisor
    var d = denominator // divisor
    if d < 0:
        n = -n
        d = -d

    if d != 0 and n % d == 0:
        var integer = String(n // d)
        all_values.append(integer)
        integers.append(integer^)
        has_value = True
    if n != 0 and d % n == 0:
        var reciprocal = String(d // n)
        all_values.append("1/" + reciprocal)
        reciprocals.append(reciprocal^)
    return PromptAddedFractionValues(has_value, reciprocals^, all_values^, integers^)


def serialize_prompt_fraction(parse: PromptFractionParse) -> String:
    """Stable test/probe representation: groups separated by ASCII RS/US."""
    if not parse.valid:
        return "INVALID"
    var output = String()
    for group_index in range(len(parse.groups)):
        if group_index > 0:
            output += "\x1e"
        for value_index in range(len(parse.groups[group_index])):
            if value_index > 0:
                output += "\x1f"
            output += parse.groups[group_index][value_index]
    return output^


def serialize_prompt_fraction_range(result: PromptFractionRange) -> String:
    if not result.valid:
        return "INVALID"
    var output = String()
    for index in range(len(result.values)):
        if index > 0:
            output += ","
        output += String(result.values[index])
    return output + "\t" + result.suffix
