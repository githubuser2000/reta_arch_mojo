from std.collections import List
from reta_mojo.parallel_execution import (
    factor_pairs_in_processes,
    factor_pairs_serial,
    filter_numbers_in_processes,
    filter_numbers_serial,
    make_parallel_config,
    moon_numbers_in_processes,
    moon_numbers_serial,
    prime_factors_in_processes,
    prime_factors_serial,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var checks = 0
    var config = make_parallel_config("processes", 2, 2, 1, "fork", "unit")
    var numbers: List[Int] = [49, 6, 18, 8, 12, 25, 27, 30, 6]

    var moon_reference = moon_numbers_serial(numbers)
    var moon = moon_numbers_in_processes(numbers, config)
    assert_true(
        moon.stats.mode == "threads",
        "moon legacy process alias uses threads",
    )
    checks += 1
    assert_true(moon.stats.chunks == 5, "moon chunks")
    checks += 1
    assert_true(len(moon.values) == len(moon_reference), "moon count")
    checks += 1
    for index in range(len(moon.values)):
        assert_true(moon.values[index].number == moon_reference[index].number, "moon order")
        checks += 1
        assert_true(
            len(moon.values[index].bases) == len(moon_reference[index].bases),
            "moon base count",
        )
        checks += 1
        for base_index in range(len(moon.values[index].bases)):
            assert_true(
                moon.values[index].bases[base_index]
                == moon_reference[index].bases[base_index],
                "moon base value",
            )
            checks += 1
        assert_true(
            len(moon.values[index].exponent_markers)
            == len(moon_reference[index].exponent_markers),
            "moon marker count",
        )
        checks += 1
        for marker_index in range(len(moon.values[index].exponent_markers)):
            assert_true(
                moon.values[index].exponent_markers[marker_index]
                == moon_reference[index].exponent_markers[marker_index],
                "moon marker value",
            )
            checks += 1
    assert_true(
        moon.values[0].number == 6
        and moon.values[len(moon.values) - 1].number == 49,
        "moon Python number ordering",
    )
    checks += 1

    var factors_reference = prime_factors_serial(numbers)
    var factors = prime_factors_in_processes(numbers, config)
    assert_true(
        factors.stats.mode == "threads",
        "factor legacy process alias uses threads",
    )
    checks += 1
    assert_true(len(factors.values) == len(factors_reference), "factor count")
    checks += 1
    for index in range(len(factors.values)):
        assert_true(
            factors.values[index].number == factors_reference[index].number,
            "factor number order",
        )
        checks += 1
        assert_true(
            len(factors.values[index].values)
            == len(factors_reference[index].values),
            "factor value count",
        )
        checks += 1
        for factor_index in range(len(factors.values[index].values)):
            assert_true(
                factors.values[index].values[factor_index]
                == factors_reference[index].values[factor_index],
                "factor value",
            )
            checks += 1
    assert_true(
        factors.values[0].number == 6
        and factors.values[len(factors.values) - 1].number == 49,
        "factor Python number ordering",
    )
    checks += 1

    var criteria: List[Int] = [2, 5]
    var filtered_reference = filter_numbers_serial(
        numbers, "ordinary_multiples", criteria, 0, True
    )
    var filtered = filter_numbers_in_processes(
        numbers, "ordinary_multiples", criteria, 0, True, config
    )
    assert_true(
        filtered.stats.mode == "threads",
        "filter legacy process alias uses threads",
    )
    checks += 1
    assert_true(len(filtered.values) == len(filtered_reference), "filter count")
    checks += 1
    for index in range(len(filtered.values)):
        assert_true(filtered.values[index] == filtered_reference[index], "filter parity")
        checks += 1
    assert_true(
        filtered.values[0] == 6
        and filtered.values[len(filtered.values) - 1] == 30,
        "filter sorted unique representation",
    )
    checks += 1

    var pairs_reference = factor_pairs_serial(numbers, True)
    var pairs = factor_pairs_in_processes(numbers, True, config)
    assert_true(
        pairs.stats.mode == "threads",
        "pair legacy process alias uses threads",
    )
    checks += 1
    assert_true(len(pairs.values) == len(pairs_reference), "pair count")
    checks += 1
    for index in range(len(pairs.values)):
        assert_true(
            pairs.values[index].number == pairs_reference[index].number,
            "pair number order",
        )
        checks += 1
        assert_true(
            len(pairs.values[index].pairs) == len(pairs_reference[index].pairs),
            "pair count parity",
        )
        checks += 1
        for pair_index in range(len(pairs.values[index].pairs)):
            assert_true(
                pairs.values[index].pairs[pair_index].first
                == pairs_reference[index].pairs[pair_index].first,
                "pair first value",
            )
            checks += 1
            assert_true(
                pairs.values[index].pairs[pair_index].second
                == pairs_reference[index].pairs[pair_index].second,
                "pair second value",
            )
            checks += 1
    assert_true(
        pairs.values[0].number == 6
        and pairs.values[len(pairs.values) - 1].number == 49,
        "pair Python number ordering",
    )
    checks += 1

    print("parallel number process tests:", checks, "/", checks)
