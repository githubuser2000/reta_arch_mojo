"""Native Mojo implementation of Reta's row-range language.

This module replaces Python's eval-based set parser with a finite native
integer-expression grammar.  Documented calculations and one-variable
``range`` comprehensions remain compatible, while arbitrary executable Python
syntax is rejected and left to the atomic reference fallback.
"""

from std.collections import List, Set
from std.collections.string import atol, ord
from .integer_expressions import parse_integer_collection


@fieldwise_init
struct ParsedIntSet(Copyable):
    var valid: Bool
    var values: Set[Int]


struct RowRangeSyntax(Copyable):
    var multiple_prefix: String

    def __init__(out self, var multiple_prefix: String = "v"):
        self.multiple_prefix = multiple_prefix^

    def split_comma_list(self, text: String) -> List[String]:
        return split_top_level_commas(text)

    def compact_comma_list(self, text: String) -> String:
        var parts = split_top_level_commas(text)
        var result = String()
        for index in range(len(parts)):
            if parts[index].byte_length() == 0:
                continue
            if result.byte_length() != 0:
                result += ","
            result += parts[index]
        return result^

    def is_integer_range_token(self, text: String) -> Bool:
        return is_integer_range_token(text, self.multiple_prefix)

    def is_fraction_range_token(self, text: String) -> Bool:
        return is_fraction_range_token(text, self.multiple_prefix)


def _slice(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def _tail(text: String, start: Int) -> String:
    return String(StringSlice(text)[byte=start:])


def _without_last(text: String) -> String:
    return String(StringSlice(text)[byte=:-1])


def _is_digit_code(value: Int) -> Bool:
    return value >= 48 and value <= 57


def _is_decimal(text: String) -> Bool:
    if text.byte_length() == 0:
        return False
    for index in range(text.byte_length()):
        if not _is_digit_code(ord(text[byte=index])):
            return False
    return True


def _is_signed_integer(text: String) -> Bool:
    if text.byte_length() == 0:
        return False
    if ord(text[byte=0]) == 45:
        if text.byte_length() == 1:
            return False
        return _is_decimal(_tail(text, 1))
    return _is_decimal(text)


def split_top_level_commas(text: String) -> List[String]:
    """Split commas except those inside (), [] or {}."""
    var parts = List[String]()
    var depth = 0
    var start = 0
    for index in range(text.byte_length()):
        var byte = ord(text[byte=index])
        if byte == 40 or byte == 91 or byte == 123:
            depth += 1
        elif byte == 41 or byte == 93 or byte == 125:
            if depth > 0:
                depth -= 1
        elif byte == 44 and depth == 0:
            parts.append(_slice(text, start, index))
            start = index + 1
    parts.append(_slice(text, start, text.byte_length()))
    return parts^


def parse_explicit_int_set(raw_text: String) raises -> ParsedIntSet:
    """Parse the safe integer subset of the historical eval-based syntax."""
    var parsed = parse_integer_collection(raw_text)
    return ParsedIntSet(parsed.valid, parsed.values.copy())


def _consume_digits(text: String, position: Int) -> Int:
    var cursor = position
    var begin = cursor
    while cursor < text.byte_length() and _is_digit_code(ord(text[byte=cursor])):
        cursor += 1
    if cursor == begin:
        return -1
    return cursor


def _consume_fraction(text: String, position: Int) -> Int:
    var current = _consume_digits(text, position)
    if current < 0 or current >= text.byte_length() or ord(text[byte=current]) != 47:
        return -1
    return _consume_digits(text, current + 1)


def _is_range_token(text: String, multiple_prefix: String, fractions: Bool) -> Bool:
    if text.byte_length() == 0:
        return False
    var position = 0
    if multiple_prefix.byte_length() > 0 and text.startswith(multiple_prefix):
        position = multiple_prefix.byte_length()
    if position < text.byte_length() and ord(text[byte=position]) == 45:
        position += 1

    if fractions:
        position = _consume_fraction(text, position)
    else:
        position = _consume_digits(text, position)
    if position < 0:
        return False

    if position < text.byte_length() and ord(text[byte=position]) == 45:
        position += 1
        if fractions:
            position = _consume_fraction(text, position)
        else:
            position = _consume_digits(text, position)
        if position < 0:
            return False

    while position < text.byte_length() and ord(text[byte=position]) == 43:
        position += 1
        if fractions:
            position = _consume_fraction(text, position)
        else:
            position = _consume_digits(text, position)
        if position < 0:
            return False
    return position == text.byte_length()


def is_integer_range_token(text: String, multiple_prefix: String = "v") -> Bool:
    return _is_range_token(text, multiple_prefix, False)


def is_fraction_range_token(text: String, multiple_prefix: String = "v") -> Bool:
    return _is_range_token(text, multiple_prefix, True)


def is_row_range_token(text: String, multiple_prefix: String = "v") raises -> Bool:
    if is_integer_range_token(text, multiple_prefix):
        return True
    var direct = parse_explicit_int_set(text)
    if direct.valid:
        return True
    if text.byte_length() > 0:
        return parse_explicit_int_set(_tail(text, 1)).valid
    return False


def is_fraction_or_integer_range(text: String, multiple_prefix: String = "v") raises -> Bool:
    var parts = split_top_level_commas(text)
    for index in range(len(parts)):
        if not is_fraction_range_token(parts[index], multiple_prefix) and not is_row_range_token(parts[index], multiple_prefix):
            return False
    return True


def is_fraction_range(text: String, multiple_prefix: String = "v") -> Bool:
    var parts = split_top_level_commas(text)
    var any_at_all = False
    for index in range(len(parts)):
        if parts[index].byte_length() > 0:
            any_at_all = True
    for index in range(len(parts)):
        if not is_fraction_range_token(parts[index], multiple_prefix):
            if not (parts[index].byte_length() == 0 and any_at_all):
                return False
    return True


def is_row_range(text: String, multiple_prefix: String = "v") raises -> Bool:
    var parts = split_top_level_commas(text)
    var any_at_all = False
    for index in range(len(parts)):
        if parts[index].byte_length() > 0:
            any_at_all = True
    for index in range(len(parts)):
        if not is_row_range_token(parts[index], multiple_prefix):
            if not (parts[index].byte_length() == 0 and any_at_all):
                return False
    return True


def _set_add_all(mut target: Set[Int], source: Set[Int]):
    for value in source:
        target.add(value)


def add_non_multiple_values(start: Int, end: Int, around: List[Int], max_value: Int, mut target: Set[Int]):
    for number in range(start, end + 1):
        for index in range(len(around)):
            var plus = number + around[index]
            if plus < max_value:
                target.add(plus)
            var minus = number - around[index]
            if minus > 0 and minus < max_value:
                target.add(minus)


def _all_multiples_below(start: Int, multiplier: Int, around: List[Int], max_value: Int) -> Bool:
    for index in range(len(around)):
        if start * multiplier >= max_value - around[index]:
            return False
    return True


def add_multiple_values(start: Int, end: Int, around: List[Int], max_value: Int, mut target: Set[Int]):
    var multiplier = 0
    var nonzero_around = False
    for index in range(len(around)):
        if around[index] != 0:
            nonzero_around = True
            break

    if len(around) == 0 or not nonzero_around:
        while _all_multiples_below(start, multiplier, around, max_value):
            multiplier += 1
            for number in range(start, end + 1):
                var value = number * multiplier
                if value <= max_value:
                    target.add(value)
    else:
        while _all_multiples_below(start, multiplier, around, max_value):
            multiplier += 1
            for number in range(start, end + 1):
                for index in range(len(around)):
                    var plus = number * multiplier + around[index]
                    if plus <= max_value:
                        target.add(plus)
                    var minus = number * multiplier - around[index]
                    if minus > 0 and minus < max_value:
                        target.add(minus)


def add_range_couple_values(range_couple: List[String], max_value: Int, mut target: Set[Int], multiples: Bool) raises:
    if len(range_couple) != 2 or not _is_decimal(range_couple[0]) or range_couple[0] == "0":
        return

    var around = List[Int]()
    var end_text = range_couple[1]
    var plus_parts = end_text.split("+")
    if len(plus_parts) < 2:
        around.append(0)
    else:
        var valid = True
        var numbers = List[Int]()
        for index in range(len(plus_parts)):
            var token = String(plus_parts[index])
            if _is_decimal(token):
                numbers.append(atol(token))
            else:
                valid = False
        if valid and len(numbers) > 0:
            end_text = String(numbers[0])
            for index in range(1, len(numbers)):
                around.append(numbers[index])

    var start = atol(range_couple[0])
    var end = atol(end_text)
    if multiples:
        add_multiple_values(start, end, around, max_value, target)
    else:
        add_non_multiple_values(start, end, around, max_value, target)


def add_single_range_segment(raw_segment: String, mut include: Set[Int], mut exclude: Set[Int], max_value: Int, multiples: Bool) raises:
    var segment = raw_segment
    var use_exclude = False
    var valid_target = True
    if segment.byte_length() > 1 and ord(segment[byte=0]) == 45:
        segment = _tail(segment, 1)
        use_exclude = True
    elif segment.byte_length() == 0 or ord(segment[byte=0]) == 45:
        valid_target = False
    if not valid_target:
        return

    var plus_slices = segment.split("+")
    var plus_parts = List[String]()
    for index in range(len(plus_slices)):
        plus_parts.append(String(plus_slices[index]))
    if _is_decimal(segment):
        var scalar = segment.copy()
        segment = scalar + "-" + scalar
    elif len(plus_parts) > 0 and _is_decimal(plus_parts[0]):
        segment = plus_parts[0] + "-" + plus_parts[0]
        for index in range(1, len(plus_parts)):
            segment += "+" + plus_parts[index]

    var range_couple_slices = segment.split("-")
    var range_couple = List[String]()
    for index in range(len(range_couple_slices)):
        range_couple.append(String(range_couple_slices[index]))
    if use_exclude:
        add_range_couple_values(range_couple, max_value, exclude, multiples)
    else:
        add_range_couple_values(range_couple, max_value, include, multiples)


def range_to_numbers(
    raw_text: String,
    multiples: Bool = False,
    max_value: Int = 1028,
    allow_less_equal_zero: Bool = False,
    multiple_prefix: String = "v",
) raises -> Set[Int]:
    """Expand a Reta row-range expression to a finite set of row numbers."""
    var syntax = RowRangeSyntax(multiple_prefix)
    var ranges_text = syntax.compact_comma_list(raw_text)
    if not is_row_range(ranges_text, syntax.multiple_prefix):
        return Set[Int]()

    var unbounded = not multiples and max_value == 0
    var effective_max = Int.MAX if unbounded else max_value
    var segments = syntax.split_comma_list(ranges_text)
    var include = Set[Int]()
    var exclude = Set[Int]()

    for index in range(len(segments)):
        var segment = segments[index]
        if segment.byte_length() > 1 and ord(segment[byte=0]) == 45:
            var generated = parse_explicit_int_set(_tail(segment, 1))
            if generated.valid:
                _set_add_all(exclude, generated.values)
                continue
        elif segment.byte_length() > 0 and ord(segment[byte=0]) != 45:
            var generated = parse_explicit_int_set(segment)
            if generated.valid:
                _set_add_all(include, generated.values)
                continue

        var segment_multiples = False
        if segment.byte_length() > 0 and segment.startswith(syntax.multiple_prefix):
            segment = _tail(segment, syntax.multiple_prefix.byte_length())
            segment_multiples = True

        var bounded_max = effective_max
        if (multiples or segment_multiples) and unbounded:
            bounded_max = 1028
        add_single_range_segment(segment, include, exclude, bounded_max, multiples or segment_multiples)

    var result = Set[Int]()
    for value in include:
        if value not in exclude and (allow_less_equal_zero or value > 0):
            result.add(value)
    return result^


# Historical aliases.
def BereichToNumbers2(
    text: String,
    multiples: Bool = False,
    max_value: Int = 1028,
    allow_less_equal_zero: Bool = False,
) raises -> Set[Int]:
    return range_to_numbers(text, multiples, max_value, allow_less_equal_zero)
