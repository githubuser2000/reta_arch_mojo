from std.testing import assert_equal, assert_true, TestSuite
from std.collections import List
from reta_mojo.native_reta_cli import *


def test_plan_resolves_rows_columns_and_output() raises:
    var plan = build_native_reta_plan(
        ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--religionen=sternpolygon", "-ausgabe", "--art=csv"],
        746,
        1024,
    )
    assert_equal(plan.output_mode, "csv")
    assert_equal(plan.positive_rows, ["_a_1-3"])
    assert_equal(plan.columns, [0, 6, 36])


def test_row_polarity_cancellation_matches_python_all_rows() raises:
    var cancelled = build_native_reta_plan(
        ["-zeilen", "--vorhervonausschnitt=2,-2"], 746, 1024
    )
    assert_equal(len(cancelled.positive_rows), 0)
    assert_equal(len(cancelled.negative_rows), 0)

    var partial = build_native_reta_plan(
        ["-zeilen", "--vorhervonausschnitt=2,-3"], 746, 1024
    )
    assert_equal(partial.positive_rows, ["_a_2"])
    assert_equal(partial.negative_rows, ["_a_3"])

    var empty_positive = build_native_reta_plan(
        ["-zeilen", "--vorhervonausschnitt=,-4"], 746, 1024
    )
    assert_equal(len(empty_positive.positive_rows), 0)
    assert_equal(empty_positive.negative_rows, ["_a_4"])


def test_embedded_absolute_multiple_selector_uses_full_row_ceiling() raises:
    var embedded = build_native_reta_plan(
        ["-zeilen", "--vorhervonausschnitt=2,v12"], 746, 1024
    )
    assert_true(
        has_absolute_multiple_row_selector(
            embedded.positive_rows, embedded.negative_rows
        )
    )

    var dedicated = build_native_reta_plan(
        ["-zeilen", "--vielfachevonzahlen=12"], 746, 1024
    )
    assert_true(
        not has_absolute_multiple_row_selector(
            dedicated.positive_rows, dedicated.negative_rows
        )
    )


def test_absolute_multiple_selector_raises_runtime_table_ceiling() raises:
    assert_equal(
        effective_runtime_highest(
            ["-zeilen", "--vorhervonausschnitt=2,v6,v10"], 1024
        ),
        1027,
    )
    assert_equal(
        effective_runtime_highest(
            ["-zeilen", "--vorhervonausschnitt=2-4,v2-4"], 1024
        ),
        1029,
    )
    assert_equal(
        effective_runtime_highest(
            ["-zeilen", "--vorhervonausschnitt=24,v24"], 1024
        ),
        1024,
    )


def test_generated_only_selection_does_not_add_physical_default() raises:
    var plan = build_native_reta_plan(
        ["-spalten", "--bedeutung=primzahlkreuz"],
        746,
        1024,
    )
    assert_equal(len(plan.columns), 0)
    assert_equal(plan.generated_commands, ["primzahlkreuzprocontra"])


def test_modal_alias_resolves_concept_pair() raises:
    var plan = build_native_reta_plan(
        ["-spalten", "--grundstrukturen=liebe"],
        746,
        1024,
    )
    assert_equal(plan.columns, [8, 9, 28, 208, 221, 330, 580])
    assert_equal(len(plan.modal_concepts), 1)
    assert_equal(plan.modal_concepts[0].first, 121)
    assert_equal(plan.modal_concepts[0].second, 122)


def test_prime_effect_alias_becomes_generated_command() raises:
    var plan = build_native_reta_plan(
        ["-spalten", "--primzahlwirkung=absicht"],
        746,
        1024,
    )
    assert_equal(len(plan.columns), 0)
    assert_equal(plan.generated_commands, ["prime_effect:10"])


def test_meta_aliases_resolve_in_python_set_order() raises:
    var plan = build_native_reta_plan(
        [
            "-spalten",
            "--universummetakonkret=meta,konkret,theorie,praxis",
        ],
        746,
        1024,
    )
    assert_equal(len(plan.columns), 0)
    assert_equal(len(plan.meta_requests), 4)
    assert_equal(plan.meta_requests[0].metavariable, 3)
    assert_equal(plan.meta_requests[0].side, 1)
    assert_equal(plan.meta_requests[1].metavariable, 2)
    assert_equal(plan.meta_requests[1].side, 0)


def test_fraction_alias_resolves_one_typed_request() raises:
    var plan = build_native_reta_plan(
        ["-spalten", "--gebrochenuniversum=2"], 746, 1024
    )
    assert_equal(len(plan.columns), 0)
    assert_equal(len(plan.fraction_requests), 1)
    assert_equal(plan.fraction_requests[0].domain, "universe")
    assert_equal(plan.fraction_requests[0].denominator, 2)


def test_kombi_aliases_resolve_and_sort() raises:
    var plan = build_native_reta_plan(
        [
            "-kombination",
            "--universum=transzendenz,tiere",
            "--galaxie=berufe,tiere",
        ],
        746,
        1024,
    )
    assert_equal(len(plan.columns), 0)
    assert_equal(len(plan.kombi_requests), 4)
    assert_equal(plan.kombi_requests[0].kind, "galaxy")
    assert_equal(plan.kombi_requests[0].column, 1)
    assert_equal(plan.kombi_requests[1].column, 2)
    assert_equal(plan.kombi_requests[2].kind, "universe")
    assert_equal(plan.kombi_requests[2].column, 1)
    assert_equal(plan.kombi_requests[3].column, 5)



def test_explicit_column_range_filters_semantic_output_positions() raises:
    var plan = build_native_reta_plan(
        [
            "-spalten",
            "--Bedeutung=gestirn",
            "-ausgabe",
            "--spaltenreihenfolgeundnurdiese=3-6",
        ],
        746,
        1024,
    )
    assert_equal(plan.columns, [64, 154])
    assert_equal(plan.explicit_positions, [2, 3, 4, 5])


def test_explicit_column_range_without_semantic_selection_is_physical() raises:
    var plan = build_native_reta_plan(
        ["-ausgabe", "--spaltenreihenfolgeundnurdiese=3-6"], 746, 1024
    )
    assert_equal(plan.columns, [2, 3, 4, 5])
    assert_equal(len(plan.explicit_positions), 0)


def test_out_of_range_explicit_position_selects_no_generated_column() raises:
    var plan = build_native_reta_plan(
        [
            "-spalten",
            "--strukturgroesse=organisation",
            "-ausgabe",
            "--spaltenreihenfolgeundnurdiese=99",
        ],
        746,
        1024,
    )
    assert_true(plan.explicit_order_requested)
    assert_equal(plan.explicit_positions, [98])


def test_output_stream_flags_are_owned() raises:
    var plain = build_native_reta_plan(
        ["-ausgabe", "--justtext"], 746, 1024
    )
    assert_true(not plain.color_rows)
    assert_true(not plain.one_table)

    for option in ["onetable", "endlessscreen", "endless", "dontwrap"]:
        var plan = build_native_reta_plan(
            ["-ausgabe", "--" + option], 746, 1024
        )
        assert_true(plan.one_table)



def test_prompt_fast_path_accepts_owned_raw_reta_subset() raises:
    assert_true(
        native_reta_tokens_supported(
            [
                "-zeilen",
                "--vorhervonausschnitt=1-2",
                "-spalten",
                "--religionen=sternpolygon",
                "--breite=0",
                "-ausgabe",
                "--nocolor",
            ],
            "python_reference/csv/religion.csv",
        )
    )


def test_prompt_fast_path_accepts_language_and_known_output_mode() raises:
    assert_true(
        native_reta_tokens_supported(
            [
                "-zeilen",
                "--range=1",
                "-columns",
                "--religions=starpolygon",
                "-output",
                "--type=csv",
                "-language=english",
            ],
            "python_reference/csv/religion.csv",
        )
    )


def test_prompt_fast_path_accepts_positive_width_renderers() raises:
    for output_mode in ["shell", "html", "bbcode"]:
        assert_true(
            native_reta_tokens_supported(
                [
                    "-zeilen",
                    "--vorhervonausschnitt=1-2",
                    "-spalten",
                    "--religionen=sternpolygon",
                    "-ausgabe",
                    "--art=" + output_mode,
                    "--breite=40",
                ],
                "python_reference/csv/religion.csv",
            )
        )


def test_prompt_fast_path_accepts_owned_output_stream_flags() raises:
    var base = List[String]()
    for token in [
        "-zeilen",
        "--vorhervonausschnitt=1-2",
        "-spalten",
        "--religionen=sternpolygon",
        "-ausgabe",
        "--art=shell",
        "--breite=12",
        "--nocolor",
    ]:
        base.append(String(token))
    for option in [
        "onetable", "endlessscreen", "endless", "dontwrap", "justtext"
    ]:
        var tokens = base.copy()
        tokens.append("--" + option)
        assert_true(
            native_reta_tokens_supported(
                tokens, "python_reference/csv/religion.csv"
            )
        )


def test_no_blank_contents_is_typed_and_owned() raises:
    for option in ["keineleereninhalte", "noblankcontents"]:
        var plan = build_native_reta_plan(
            ["-ausgabe", "--" + option], 746, 1024
        )
        assert_true(plan.no_blank_contents)
        assert_true(
            native_reta_tokens_supported(
                [
                    "-zeilen",
                    "--vorhervonausschnitt=1-20",
                    "-spalten",
                    "--Menschliches=manipulation",
                    "-ausgabe",
                    "--art=emacs",
                    "--" + option,
                ],
                "python_reference/csv/religion.csv",
            )
        )


def test_prompt_fast_path_accepts_markup_onetable() raises:
    for output_mode in ["html", "bbcode"]:
        assert_true(
            native_reta_tokens_supported(
                [
                    "-zeilen",
                    "--vorhervonausschnitt=1-2",
                    "-spalten",
                    "--religionen=sternpolygon",
                    "-ausgabe",
                    "--art=" + output_mode,
                    "--onetable",
                ],
                "python_reference/csv/religion.csv",
            )
        )


def test_width_keeps_legacy_minimum_and_zero_lock() raises:
    var narrow = build_native_reta_plan(
        ["-ausgabe", "--breite=12"], 746, 1024
    )
    assert_equal(narrow.width, 21)

    var wider = build_native_reta_plan(
        ["-ausgabe", "--breite=40"], 746, 1024
    )
    assert_equal(wider.width, 40)

    var zero_locked = build_native_reta_plan(
        ["-ausgabe", "--breite=0", "--breite=80"], 746, 1024
    )
    assert_equal(zero_locked.width, 0)


def test_prompt_fast_path_rejects_unknown_row_operator() raises:
    assert_true(
        not native_reta_tokens_supported(
            ["-zeilen", "--nichtportiert=1"],
            "python_reference/csv/religion.csv",
        )
    )


def test_prompt_fast_path_rejects_unknown_main_section() raises:
    assert_true(
        not native_reta_tokens_supported(
            ["-foo", "--bar=baz"],
            "python_reference/csv/religion.csv",
        )
    )


def test_prompt_fast_path_rejects_valueless_column_option() raises:
    assert_true(
        not native_reta_tokens_supported(
            ["-spalten", "--nichtportiert"],
            "python_reference/csv/religion.csv",
        )
    )


def test_prompt_fast_path_rejects_missing_required_row_value() raises:
    assert_true(
        not native_reta_tokens_supported(
            ["-zeilen", "--vorhervonausschnitt"],
            "python_reference/csv/religion.csv",
        )
    )

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
