"""Generated Unicode ``str.isdigit`` ranges for Python-reference parity.

Generated from ``assets/unicode_digit_ranges.tsv``.  The frozen snapshot has
83 ranges and 808 codepoints; regenerate it deliberately with
``tools/generate_unicode_digits.py --refresh-from-python``.
"""

from std.collections import List
from .types import IntPair


comptime UNICODE_DIGIT_RANGE_COUNT = 83
comptime UNICODE_DIGIT_CODEPOINT_COUNT = 808


def unicode_digit_ranges() -> List[IntPair]:
    return [
        IntPair(48, 57),
        IntPair(178, 179),
        IntPair(185, 185),
        IntPair(1632, 1641),
        IntPair(1776, 1785),
        IntPair(1984, 1993),
        IntPair(2406, 2415),
        IntPair(2534, 2543),
        IntPair(2662, 2671),
        IntPair(2790, 2799),
        IntPair(2918, 2927),
        IntPair(3046, 3055),
        IntPair(3174, 3183),
        IntPair(3302, 3311),
        IntPair(3430, 3439),
        IntPair(3558, 3567),
        IntPair(3664, 3673),
        IntPair(3792, 3801),
        IntPair(3872, 3881),
        IntPair(4160, 4169),
        IntPair(4240, 4249),
        IntPair(4969, 4977),
        IntPair(6112, 6121),
        IntPair(6160, 6169),
        IntPair(6470, 6479),
        IntPair(6608, 6618),
        IntPair(6784, 6793),
        IntPair(6800, 6809),
        IntPair(6992, 7001),
        IntPair(7088, 7097),
        IntPair(7232, 7241),
        IntPair(7248, 7257),
        IntPair(8304, 8304),
        IntPair(8308, 8313),
        IntPair(8320, 8329),
        IntPair(9312, 9320),
        IntPair(9332, 9340),
        IntPair(9352, 9360),
        IntPair(9450, 9450),
        IntPair(9461, 9469),
        IntPair(9471, 9471),
        IntPair(10102, 10110),
        IntPair(10112, 10120),
        IntPair(10122, 10130),
        IntPair(42528, 42537),
        IntPair(43216, 43225),
        IntPair(43264, 43273),
        IntPair(43472, 43481),
        IntPair(43504, 43513),
        IntPair(43600, 43609),
        IntPair(44016, 44025),
        IntPair(65296, 65305),
        IntPair(66720, 66729),
        IntPair(68160, 68163),
        IntPair(68912, 68921),
        IntPair(69216, 69224),
        IntPair(69714, 69722),
        IntPair(69734, 69743),
        IntPair(69872, 69881),
        IntPair(69942, 69951),
        IntPair(70096, 70105),
        IntPair(70384, 70393),
        IntPair(70736, 70745),
        IntPair(70864, 70873),
        IntPair(71248, 71257),
        IntPair(71360, 71369),
        IntPair(71472, 71481),
        IntPair(71904, 71913),
        IntPair(72016, 72025),
        IntPair(72784, 72793),
        IntPair(73040, 73049),
        IntPair(73120, 73129),
        IntPair(73552, 73561),
        IntPair(92768, 92777),
        IntPair(92864, 92873),
        IntPair(93008, 93017),
        IntPair(120782, 120831),
        IntPair(123200, 123209),
        IntPair(123632, 123641),
        IntPair(124144, 124153),
        IntPair(125264, 125273),
        IntPair(127232, 127242),
        IntPair(130032, 130041),
    ]


def is_unicode_digit_codepoint(value: Int) -> Bool:
    var ranges = unicode_digit_ranges()
    for index in range(len(ranges)):
        if value >= ranges[index].first and value <= ranges[index].second:
            return True
    return False


def has_unicode_digit(text: String) -> Bool:
    for codepoint in text.codepoints():
        if is_unicode_digit_codepoint(Int(codepoint)):
            return True
    return False
