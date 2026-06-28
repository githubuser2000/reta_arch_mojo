"""Native row-filter state machine extracted from row_filtering.py."""

from std.collections import List, Set
from std.collections.string import atol, ord
from .row_ranges import range_to_numbers
from .number_theory import divisors, prime_factors, prime_repeat, moon_number, is_prime_multiple


@fieldwise_init
struct RowFilterConfig(Copyable):
    var highest_main: Int
    var highest_multiple: Int
    var rows_were_set: Bool


def default_row_filter_config(highest: Int = 1024) -> RowFilterConfig:
    return RowFilterConfig(highest, min(highest, 114), True)


def _tail_filter(text: String, start: Int) -> String:
    return String(StringSlice(text)[byte=start:])


def _ends_with(text: String, suffix: String) -> Bool:
    return text.endswith(suffix)


def _full_range(highest: Int) -> Set[Int]:
    var result = Set[Int]()
    for value in range(1, highest + 1):
        result.add(value)
    return result^


def _copy_set(values: Set[Int]) -> Set[Int]:
    var result = Set[Int]()
    for value in values:
        result.add(value)
    return result^


def _intersection(left: Set[Int], right: Set[Int]) -> Set[Int]:
    var result = Set[Int]()
    for value in left:
        if value in right:
            result.add(value)
    return result^


def _difference(left: Set[Int], right: Set[Int]) -> Set[Int]:
    var result = Set[Int]()
    for value in left:
        if value not in right:
            result.add(value)
    return result^


def _union_into(mut target: Set[Int], source: Set[Int]):
    for value in source:
        target.add(value)


def _has_condition(conditions: List[String], wanted: String) -> Bool:
    for index in range(len(conditions)):
        if conditions[index] == wanted:
            return True
    return False


def _has_meaningful_condition(conditions: List[String]) -> Bool:
    for index in range(len(conditions)):
        if conditions[index] != "ka" and conditions[index] != "ka2":
            return True
    return False


def _is_moon(value: Int) -> Bool:
    return len(moon_number(value)[0]) > 0


def _prime_inside_outside(value: Int) -> Tuple[Bool, Bool, Bool]:
    if value == 1:
        return (True, False, True)
    var factors = prime_factors(value)
    var single = len(factors) == 1
    var inside = False
    var outside = False
    for index in range(len(factors)):
        var factor = factors[index]
        if factor >= 4:
            var residue = factor % 6
            if residue == 1:
                inside = True
            if residue == 5:
                outside = True
    return (inside, outside, single)


def _mixed_exponents(value: Int) -> Bool:
    var grouped = prime_repeat(prime_factors(value))
    var has_one = False
    var has_other = False
    for index in range(len(grouped)):
        if grouped[index].second == 1:
            has_one = True
        else:
            has_other = True
    return has_one and has_other


def _counting_groups(highest: Int) -> List[Int]:
    var groups = List[Int]()
    for _ in range(highest + 1):
        groups.append(0)
    var group = 0
    var was_moon = True
    for value in range(1, highest + 1):
        var is_moon = _is_moon(value)
        if was_moon and not is_moon:
            group += 1
        groups[value] = group
        was_moon = is_moon
    return groups^


def _parse_condition_ranges(conditions: List[String], prefix: String, multiples: Bool, maximum: Int) raises -> Tuple[Bool, Set[Int]]:
    var found = False
    var result = Set[Int]()
    for index in range(len(conditions)):
        var condition = conditions[index]
        if condition.startswith(prefix) and condition.byte_length() > prefix.byte_length():
            found = True
            _union_into(result, range_to_numbers(_tail_filter(condition, prefix.byte_length()), multiples, maximum + 1))
    return (found, result^)


def _sorted_ints(values: Set[Int]) -> List[Int]:
    var result = List[Int]()
    for value in values:
        result.append(value)
    for index in range(1, len(result)):
        var key = result[index]
        var pos = index - 1
        while pos >= 0 and result[pos] > key:
            result[pos + 1] = result[pos]
            pos -= 1
        result[pos + 1] = key
    return result^


def _negative_range_values(
    conditions: List[String], prefix: String, multiples: Bool, maximum: Int
) raises -> Set[Int]:
    var result = Set[Int]()
    for index in range(len(conditions)):
        var condition = conditions[index]
        if not condition.startswith(prefix) or condition.byte_length() <= prefix.byte_length():
            continue
        var raw = _tail_filter(condition, prefix.byte_length())
        var pieces = raw.split(",")
        for piece_index in range(len(pieces)):
            var piece = String(pieces[piece_index].strip())
            if piece.startswith("-") and piece.byte_length() > 1:
                _union_into(
                    result,
                    range_to_numbers(_tail_filter(piece, 1), multiples, maximum + 1),
                )
            elif piece.startswith("v-") and piece.byte_length() > 2:
                _union_into(
                    result,
                    range_to_numbers("v" + _tail_filter(piece, 2), multiples, maximum + 1),
                )
    return result^


def filter_original_lines(config: RowFilterConfig, initial: Set[Int], conditions: List[String]) raises -> Set[Int]:
    """Translate historical row-condition markers to concrete row numbers.

    The control flow intentionally follows ``row_filtering.py`` including the
    final rule that removes non-moon rows above the 114-row main-table limit.
    """
    var current = _copy_set(initial)
    if 0 in current:
        current.remove(0)

    var all_requested = _has_condition(conditions, "all")
    var meaningful = _has_meaningful_condition(conditions)
    if all_requested or not meaningful or not config.rows_were_set:
        current = _full_range(config.highest_main)
    else:
        current = Set[Int]()

    # Absolute row ranges: union positives, then explicitly subtract negatives.
    var absolute = _parse_condition_ranges(
        conditions, "_a_", False, config.highest_main
    )
    var has_absolute = absolute[0]
    if has_absolute:
        _union_into(current, absolute[1].copy())
        var excluded = _negative_range_values(
            conditions, "_a_", False, config.highest_main
        )
        current = _difference(current, excluded)
        if _has_condition(conditions, "_w_"):
            var with_divisors = _copy_set(current)
            for value in current:
                var values = divisors(value)
                for index in range(len(values)):
                    if values[index] != 1:
                        with_divisors.add(values[index])
            current = with_divisors^

    # Relative/multiple ranges operate on the short main-table range by default.
    var multiple_ranges = _parse_condition_ranges(
        conditions, "_b_", True, config.highest_multiple
    )
    var has_multiple_ranges = multiple_ranges[0]
    if has_multiple_ranges:
        if len(current) == 0 and not has_absolute and not all_requested:
            current = _full_range(config.highest_multiple)
        if len(multiple_ranges[1]) > 0:
            current = _intersection(current, multiple_ranges[1].copy())
        var excluded = _negative_range_values(
            conditions, "_b_", True, config.highest_main
        )
        current = _difference(current, excluded)

    # Past/present/future relation around row ten.
    var time_values = Set[Int]()
    var has_time = False
    for index in range(len(conditions)):
        if conditions[index] == "=":
            has_time = True
            time_values.add(10)
        elif conditions[index] == "<":
            has_time = True
            for value in range(1, 10):
                time_values.add(value)
        elif conditions[index] == ">":
            has_time = True
            for value in range(11, config.highest_main + 1):
                time_values.add(value)
    if has_time:
        if has_absolute or has_multiple_ranges or all_requested:
            current = _intersection(current, time_values)
        else:
            _union_into(current, time_values)

    # Numbering groups 1-4, 5-9, 10-16, ... determined by moon transitions.
    var counting = _parse_condition_ranges(
        conditions, "_n_", False, config.highest_main
    )
    if counting[0]:
        if len(current) == 0 and not has_absolute and not has_multiple_ranges and not all_requested:
            current = _full_range(config.highest_main)
        var groups = _counting_groups(config.highest_main)
        var wanted_rows = Set[Int]()
        for value in current:
            if groups[value] in counting[1]:
                wanted_rows.add(value)
        current = wanted_rows^

    # Historical implementation restarts from the complete range when a later
    # type condition is the first effective selector.
    if len(current) == 0 and meaningful:
        current = _full_range(config.highest_main)

    var type_filter = Set[Int]()
    var type_requested = (
        _has_condition(conditions, "aussenerste")
        or _has_condition(conditions, "innenerste")
        or _has_condition(conditions, "aussenalle")
        or _has_condition(conditions, "innenalle")
    )
    if type_requested:
        for value in current:
            var prime_type = _prime_inside_outside(value)
            if _has_condition(conditions, "aussenerste") and prime_type[0] and prime_type[2]:
                type_filter.add(value)
            if _has_condition(conditions, "innenerste") and prime_type[1] and prime_type[2]:
                type_filter.add(value)
            if _has_condition(conditions, "aussenalle") and prime_type[0]:
                type_filter.add(value)
            if _has_condition(conditions, "innenalle") and prime_type[1]:
                type_filter.add(value)
        if len(type_filter) > 0:
            current = _intersection(current, type_filter)

    if len(current) == 0 and meaningful:
        current = _full_range(config.highest_main)

    var celestial = Set[Int]()
    var has_celestial = False
    for condition_index in range(len(conditions)):
        var condition = conditions[condition_index]
        if (
            condition == "mond"
            or condition == "sonne"
            or condition == "schwarzesonne"
            or condition == "planet"
            or condition == "SonneMitMondanteil"
        ):
            has_celestial = True
    if has_celestial:
        for value in current:
            for condition_index in range(len(conditions)):
                var condition = conditions[condition_index]
                if condition == "mond" and _is_moon(value):
                    celestial.add(value)
                elif condition == "sonne" and not _is_moon(value):
                    celestial.add(value)
                elif condition == "schwarzesonne" and value % 3 == 0:
                    celestial.add(value)
                elif condition == "planet" and value % 2 == 0:
                    celestial.add(value)
                elif condition == "SonneMitMondanteil" and _mixed_exponents(value):
                    celestial.add(value)
        current = _intersection(current, celestial)

    var prime_multiples = List[Int]()
    var ordinary_multiples = List[Int]()
    for index in range(len(conditions)):
        var condition = conditions[index]
        if condition.byte_length() > 1 and _ends_with(condition, "p"):
            var number = String(StringSlice(condition)[byte=:-1])
            if number.byte_length() > 0:
                prime_multiples.append(atol(number))
        elif condition.byte_length() > 1 and _ends_with(condition, "v"):
            var number = String(StringSlice(condition)[byte=:-1])
            if number.byte_length() > 0:
                ordinary_multiples.append(atol(number))

    if len(prime_multiples) > 0:
        if (
            len(current) == 0
            and not has_multiple_ranges
            and not has_absolute
            and not all_requested
            and not has_celestial
        ):
            current = _full_range(config.highest_main)
        var accepted = Set[Int]()
        for value in current:
            if is_prime_multiple(value, prime_multiples):
                accepted.add(value)
        current = accepted^

    var powers = _parse_condition_ranges(
        conditions, "_^_", False, config.highest_main
    )
    if powers[0]:
        if len(current) == 0 and meaningful:
            current = _full_range(config.highest_main)
        var accepted = Set[Int]()
        var ordered_current = _sorted_ints(current)
        var last_value = config.highest_main
        if len(ordered_current) > 0:
            last_value = ordered_current[len(ordered_current) - 1]
        for base in powers[1]:
            if base <= 0:
                continue
            var value = 1
            while value <= last_value:
                accepted.add(value)
                if base <= 1 or value > last_value // base:
                    break
                value *= base
        var without_one = _intersection(current, accepted)
        if 1 in without_one:
            without_one.remove(1)
        current = without_one^

    if len(ordinary_multiples) > 0:
        var accepted = Set[Int]()
        for value in current:
            for index in range(len(ordinary_multiples)):
                if ordinary_multiples[index] != 0 and value % ordinary_multiples[index] == 0:
                    accepted.add(value)
        current = accepted^

    # Main table has ordinary sun rows only through highest_multiple; powers
    # (moon rows) above it remain selectable.
    var capped = Set[Int]()
    for value in current:
        if value <= config.highest_multiple or _is_moon(value):
            capped.add(value)
    current = capped^

    if _has_condition(conditions, "_i_"):
        var neighbours = Set[Int]()
        for value in range(1, config.highest_main + 1):
            if value not in current and ((value - 1) in current or (value + 1) in current):
                neighbours.add(value)
        current = neighbours^

    var ordered = _sorted_ints(current)
    var position_map = List[Int]()
    position_map.append(0)
    for index in range(len(ordered)):
        position_map.append(ordered[index])

    var z_ranges = _parse_condition_ranges(
        conditions, "_z_", False, config.highest_main
    )
    if z_ranges[0]:
        var accepted = Set[Int]()
        for position in z_ranges[1]:
            if position > 0 and position < len(position_map):
                accepted.add(position_map[position])
        current = _intersection(current, accepted)

    var y_ranges = _parse_condition_ranges(
        conditions, "_y_", True, config.highest_main
    )
    if y_ranges[0]:
        var accepted = Set[Int]()
        for position in y_ranges[1]:
            if position > 0 and position < len(position_map):
                accepted.add(position_map[position])
        current = _intersection(current, accepted)
    return current^


def sorted_row_numbers(values: Set[Int]) -> List[Int]:
    return _sorted_ints(values)


def counting_groups(highest: Int) -> List[Int]:
    """Public deterministic row-numbering groups used by table renderers."""
    return _counting_groups(highest)
