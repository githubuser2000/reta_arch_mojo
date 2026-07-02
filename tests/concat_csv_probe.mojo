from std.collections import Dict, List
from reta_mojo.concat_csv import *
from reta_mojo.legacy_lib4tables_concat import legacy_concat_snapshot, create_legacy_concat_state, gleichheitFreiheitVergleich, geistEmotionEnergieMaterieTopologie, concatPrimCreativityType


def _fraction_text(value: RationalValue) -> String:
    if value.denominator == 1:
        return String(value.numerator)
    return String(value.numerator) + "/" + String(value.denominator)


def _pair_text(value: RationalPair) -> String:
    return _fraction_text(value.first) + "," + _fraction_text(value.second)


def _sort_strings(mut values: List[String]):
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key


def _group_line(name: String, groups: Dict[Int, List[RationalPair]], maximum: Int) raises:
    var line = name
    for key in range(1, maximum + 1):
        if key not in groups:
            continue
        var pairs = List[String]()
        for index in range(len(groups[key])):
            pairs.append(_pair_text(groups[key][index]))
        _sort_strings(pairs)
        line += "|" + String(key) + "="
        for index in range(len(pairs)):
            if index > 0:
                line += ";"
            line += pairs[index]
    print(line)


def main() raises:
    var bundle = bootstrap_concat_csv()
    print("bundle|" + String(len(bundle.specs)) + "|" + String(len(bundle.csv_sources)) + "|" + String(len(bundle.fraction_helpers)))
    for kind in range(1, 10):
        print("source|" + String(kind) + "|" + concat_csv_filename(kind) + "|" + concat_csv_domain(kind) + "|" + String(concat_csv_is_reciprocal(kind)))
    print("heading|2|" + concat_csv_heading(2, 1, "german"))
    print("heading|5|" + concat_csv_heading(5, 1, "english"))

    var division_pairs: List[RationalPair] = [
        RationalPair(rational(6), rational(2)),
        RationalPair(rational(3, 2), rational(1, 2)),
        RationalPair(rational(6), rational(2)),
    ]
    _group_line("div", group_pairs_by_division(division_pairs), 12)
    var multiplication_pairs: List[RationalPair] = [
        RationalPair(rational(6), rational(2)),
        RationalPair(rational(3, 2), rational(2)),
    ]
    _group_line("mul", group_pairs_by_multiplication(multiplication_pairs), 16)
    var fractions: List[RationalValue] = [rational(2, 3), rational(3, 2)]
    var secondary: List[RationalValue] = [rational(3, 2), rational(1, 2)]
    _group_line("expand0", expand_fraction_pairs(fractions, secondary, 12), 12)
    _group_line("expand1", expand_fraction_pairs(fractions, secondary, 12, True), 12)

    var snapshot = legacy_concat_snapshot()
    var state = create_legacy_concat_state()
    print("facade|" + String(len(snapshot.method_mappings)) + "|" + String(len(snapshot.state_sections)) + "|" + String(len(state.csv_same_keys)))
    print("scalar|4|" + gleichheitFreiheitVergleich(4))
    print("scalar|12|" + geistEmotionEnergieMaterieTopologie(12))
    print("scalar|1|" + concatPrimCreativityType(1))
