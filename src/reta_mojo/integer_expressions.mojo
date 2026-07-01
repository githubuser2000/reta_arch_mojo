"""Safe native subset of Reta's historical Python integer expressions.

The Python reference accepts bracketed expressions through ``eval`` and then
converts the result to ``set[int]``.  The native runtime must preserve the
advertised arithmetic/list-comprehension surface without executing arbitrary
Python code.  This module therefore implements a deliberately finite grammar:

* integer literals and one bound comprehension variable;
* parentheses and unary ``+``/``-``;
* ``+``, ``-``, ``*``, ``//``, ``%`` and non-negative ``**``;
* list/set/tuple displays containing integer expressions;
* one-variable comprehensions over ``range(stop)``, ``range(start, stop)`` or
  ``range(start, stop, step)``.

Function calls other than ``range`` and all attribute/index/import syntax are
rejected.  Invalid or non-integer expressions are reported as ``valid=False``
so the compatibility launcher can fall back atomically instead of silently
selecting the wrong rows.
"""

from std.collections import List, Set
from std.collections.string import ord


@fieldwise_init
struct IntegerExpressionResult(Copyable):
    var valid: Bool
    var value: Int


@fieldwise_init
struct IntegerCollectionResult(Copyable):
    var valid: Bool
    var values: Set[Int]


def _slice(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def _tail(text: String, start: Int) -> String:
    return String(StringSlice(text)[byte=start:])


def _is_space(value: Int) -> Bool:
    return value == 9 or value == 10 or value == 13 or value == 32


def _is_digit(value: Int) -> Bool:
    return value >= 48 and value <= 57


def _is_identifier_start(value: Int) -> Bool:
    return (
        (value >= 65 and value <= 90)
        or (value >= 97 and value <= 122)
        or value == 95
    )


def _is_identifier_continue(value: Int) -> Bool:
    return _is_identifier_start(value) or _is_digit(value)




def _bounded(value: Int) raises -> Int:
    # The reference has arbitrary-precision integers.  The native row and
    # column domains are much smaller, so ownership is deliberately limited
    # to intermediates within ±10^9.  This guarantees that the next primitive
    # operation cannot overflow Mojo Int; larger calculations fall back
    # atomically to Python instead of wrapping.
    if value < -1000000000 or value > 1000000000:
        raise Error("integer expression outside native bound")
    return value


def _bounded_add(left: Int, right: Int) raises -> Int:
    return _bounded(left + right)


def _bounded_sub(left: Int, right: Int) raises -> Int:
    return _bounded(left - right)


def _bounded_mul(left: Int, right: Int) raises -> Int:
    return _bounded(left * right)


def _bounded_negate(value: Int) raises -> Int:
    return _bounded(-value)


def _python_floor_div(left: Int, right: Int) raises -> Int:
    if right == 0:
        raise Error("integer division by zero")
    var quotient = left // right
    var remainder = left - quotient * right
    # Mojo integer division truncates toward zero.  Python floors toward
    # negative infinity when the remainder and divisor have opposite signs.
    if remainder != 0 and ((remainder < 0) != (right < 0)):
        quotient -= 1
    return quotient


def _python_mod(left: Int, right: Int) raises -> Int:
    if right == 0:
        raise Error("integer modulo by zero")
    var quotient = _python_floor_div(left, right)
    return _bounded_sub(left, _bounded_mul(quotient, right))


def _integer_power(base: Int, exponent: Int) raises -> Int:
    if exponent < 0:
        # Python would return a float, which the historical set[int] contract
        # rejects after evaluation.
        raise Error("negative exponent is not an integer result")
    var result = 1
    var factor = base
    var remaining = exponent
    while remaining > 0:
        if remaining % 2 == 1:
            result = _bounded_mul(result, factor)
        remaining //= 2
        if remaining > 0:
            factor = _bounded_mul(factor, factor)
    return result


struct _IntegerExpressionParser(Copyable):
    var text: String
    var position: Int
    var variable_name: String
    var variable_value: Int
    var has_variable: Bool

    def __init__(
        out self,
        text: String,
        variable_name: String = "",
        variable_value: Int = 0,
        has_variable: Bool = False,
    ):
        self.text = text
        self.position = 0
        self.variable_name = variable_name
        self.variable_value = variable_value
        self.has_variable = has_variable

    def _skip_spaces(mut self):
        while (
            self.position < self.text.byte_length()
            and _is_space(ord(self.text[byte=self.position]))
        ):
            self.position += 1

    def _consume(mut self, token: String) -> Bool:
        self._skip_spaces()
        if _tail(self.text, self.position).startswith(token):
            self.position += token.byte_length()
            return True
        return False

    def _parse_identifier(mut self) raises -> String:
        self._skip_spaces()
        if (
            self.position >= self.text.byte_length()
            or not _is_identifier_start(ord(self.text[byte=self.position]))
        ):
            raise Error("expected identifier")
        var start = self.position
        self.position += 1
        while (
            self.position < self.text.byte_length()
            and _is_identifier_continue(ord(self.text[byte=self.position]))
        ):
            self.position += 1
        return _slice(self.text, start, self.position)

    def _parse_primary(mut self) raises -> Int:
        self._skip_spaces()
        if self.position >= self.text.byte_length():
            raise Error("expected integer expression")

        if self._consume("("):
            var value = self._parse_additive()
            if not self._consume(")"):
                raise Error("missing closing parenthesis")
            return value

        var current = ord(self.text[byte=self.position])
        if _is_digit(current):
            var value = 0
            while (
                self.position < self.text.byte_length()
                and _is_digit(ord(self.text[byte=self.position]))
            ):
                var digit = ord(self.text[byte=self.position]) - 48
                if value > (1000000000 - digit) // 10:
                    raise Error("integer literal outside native bound")
                value = value * 10 + digit
                self.position += 1
            return value

        if _is_identifier_start(current):
            var name = self._parse_identifier()
            if self.has_variable and name == self.variable_name:
                return self.variable_value
            raise Error("unknown integer identifier")

        raise Error("unsupported integer expression")

    def _parse_unary(mut self) raises -> Int:
        if self._consume("+"):
            return self._parse_unary()
        if self._consume("-"):
            return _bounded_negate(self._parse_unary())
        return self._parse_power()

    def _parse_power(mut self) raises -> Int:
        var left = self._parse_primary()
        if self._consume("**"):
            var right = self._parse_unary()
            return _integer_power(left, right)
        return left

    def _parse_multiplicative(mut self) raises -> Int:
        var value = self._parse_unary()
        while True:
            if self._consume("//"):
                value = _python_floor_div(value, self._parse_unary())
            elif self._consume("*"):
                # ``**`` is consumed in _parse_power before this level.
                value = _bounded_mul(value, self._parse_unary())
            elif self._consume("%"):
                value = _python_mod(value, self._parse_unary())
            else:
                break
        return value

    def _parse_additive(mut self) raises -> Int:
        var value = self._parse_multiplicative()
        while True:
            if self._consume("+"):
                value = _bounded_add(value, self._parse_multiplicative())
            elif self._consume("-"):
                value = _bounded_sub(value, self._parse_multiplicative())
            else:
                break
        return value

    def parse(mut self) raises -> Int:
        var value = self._parse_additive()
        self._skip_spaces()
        if self.position != self.text.byte_length():
            raise Error("trailing integer-expression syntax")
        return value


def evaluate_integer_expression(
    text: String,
    variable_name: String = "",
    variable_value: Int = 0,
    has_variable: Bool = False,
) -> IntegerExpressionResult:
    try:
        var parser = _IntegerExpressionParser(
            text, variable_name, variable_value, has_variable
        )
        return IntegerExpressionResult(True, parser.parse())
    except:
        return IntegerExpressionResult(False, 0)


def _split_top_level(text: String, separator: Int) -> List[String]:
    var parts = List[String]()
    var depth = 0
    var start = 0
    for index in range(text.byte_length()):
        var value = ord(text[byte=index])
        if value == 40 or value == 91 or value == 123:
            depth += 1
        elif value == 41 or value == 93 or value == 125:
            depth -= 1
            if depth < 0:
                return List[String]()
        elif value == separator and depth == 0:
            parts.append(_slice(text, start, index))
            start = index + 1
    if depth != 0:
        return List[String]()
    parts.append(_slice(text, start, text.byte_length()))
    return parts^


def _find_top_level_marker(text: String, marker: String) -> Int:
    var depth = 0
    var index = 0
    while index + marker.byte_length() <= text.byte_length():
        var value = ord(text[byte=index])
        if value == 40 or value == 91 or value == 123:
            depth += 1
        elif value == 41 or value == 93 or value == 125:
            depth -= 1
            if depth < 0:
                return -1
        if depth == 0 and _tail(text, index).startswith(marker):
            return index
        index += 1
    return -1


def _valid_identifier(text: String) -> Bool:
    var stripped = String(text.strip())
    if stripped.byte_length() == 0:
        return False
    if not _is_identifier_start(ord(stripped[byte=0])):
        return False
    for index in range(1, stripped.byte_length()):
        if not _is_identifier_continue(ord(stripped[byte=index])):
            return False
    return True


def _python_range_values(arguments: List[Int]) -> IntegerCollectionResult:
    var invalid = Set[Int]()
    if len(arguments) < 1 or len(arguments) > 3:
        return IntegerCollectionResult(False, invalid^)

    var start = 0
    var stop = arguments[0]
    var step = 1
    if len(arguments) >= 2:
        start = arguments[0]
        stop = arguments[1]
    if len(arguments) == 3:
        step = arguments[2]
    if step == 0:
        return IntegerCollectionResult(False, Set[Int]())

    var values = Set[Int]()
    var current = start
    if step > 0:
        while current < stop:
            values.add(current)
            if step >= stop - current:
                break
            current += step
    else:
        while current > stop:
            values.add(current)
            if -step >= current - stop:
                break
            current += step
    return IntegerCollectionResult(True, values^)


def _parse_range_call(text: String) -> Tuple[Bool, List[Int]]:
    var stripped = String(text.strip())
    if not stripped.startswith("range") or not stripped.endswith(")"):
        return False, List[Int]()
    var open_position = 5
    while (
        open_position < stripped.byte_length()
        and _is_space(ord(stripped[byte=open_position]))
    ):
        open_position += 1
    if (
        open_position >= stripped.byte_length()
        or ord(stripped[byte=open_position]) != 40
    ):
        return False, List[Int]()
    var body = _slice(
        stripped, open_position + 1, stripped.byte_length() - 1
    )
    var raw_arguments = _split_top_level(body, 44)
    if len(raw_arguments) == 0:
        return False, List[Int]()
    var arguments = List[Int]()
    for index in range(len(raw_arguments)):
        var raw = String(raw_arguments[index].strip())
        if raw.byte_length() == 0:
            return False, List[Int]()
        var evaluated = evaluate_integer_expression(raw)
        if not evaluated.valid:
            return False, List[Int]()
        arguments.append(evaluated.value)
    return True, arguments^


def _parse_comprehension(body: String) -> IntegerCollectionResult:
    var invalid = Set[Int]()
    var for_position = _find_top_level_marker(body, " for ")
    if for_position < 0:
        return IntegerCollectionResult(False, invalid^)
    var expression = String(_slice(body, 0, for_position).strip())
    var binding = _tail(body, for_position + 5)
    var in_position = _find_top_level_marker(binding, " in ")
    if in_position < 0:
        return IntegerCollectionResult(False, Set[Int]())
    var variable = String(_slice(binding, 0, in_position).strip())
    var iterable = String(_tail(binding, in_position + 4).strip())
    if expression.byte_length() == 0 or not _valid_identifier(variable):
        return IntegerCollectionResult(False, Set[Int]())

    var parsed_range = _parse_range_call(iterable)
    if not parsed_range[0]:
        return IntegerCollectionResult(False, Set[Int]())
    var range_values = _python_range_values(parsed_range[1])
    if not range_values.valid:
        return IntegerCollectionResult(False, Set[Int]())

    var values = Set[Int]()
    # Set iteration order is irrelevant because the historical result is
    # converted to a set before row selection.
    for variable_value in range_values.values:
        var evaluated = evaluate_integer_expression(
            expression, variable, variable_value, True
        )
        if not evaluated.valid:
            return IntegerCollectionResult(False, Set[Int]())
        values.add(evaluated.value)
    return IntegerCollectionResult(True, values^)


def parse_integer_collection(raw_text: String) -> IntegerCollectionResult:
    """Parse a safe Python-like integer collection or comprehension."""
    var text = String(raw_text.strip())
    var invalid = Set[Int]()
    if text.byte_length() < 2:
        return IntegerCollectionResult(False, invalid^)

    var first = ord(text[byte=0])
    var last = ord(text[byte=text.byte_length() - 1])
    var matched = (
        (first == 40 and last == 41)
        or (first == 91 and last == 93)
        or (first == 123 and last == 125)
    )
    if not matched:
        return IntegerCollectionResult(False, Set[Int]())

    var body = String(_slice(text, 1, text.byte_length() - 1).strip())
    if body.byte_length() == 0:
        return IntegerCollectionResult(True, Set[Int]())

    if _find_top_level_marker(body, " for ") >= 0:
        return _parse_comprehension(body)

    var elements = _split_top_level(body, 44)
    if len(elements) == 0:
        return IntegerCollectionResult(False, Set[Int]())

    # The historical parser rewrites outer parentheses to brackets before
    # evaluation.  Therefore even ``(1)`` behaves like ``[1]`` rather than a
    # scalar Python expression.

    var values = Set[Int]()
    for index in range(len(elements)):
        var element = String(elements[index].strip())
        if element.byte_length() == 0:
            if index == len(elements) - 1:
                continue
            return IntegerCollectionResult(False, Set[Int]())
        var evaluated = evaluate_integer_expression(element)
        if not evaluated.valid:
            return IntegerCollectionResult(False, Set[Int]())
        values.add(evaluated.value)
    return IntegerCollectionResult(True, values^)
