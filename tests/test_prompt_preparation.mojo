from std.collections import List
from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_preparation import *


def _bundle(language: String = "deutsch") raises -> PromptPreparationBundle:
    var catalog = load_prompt_language_catalog("assets")
    return bootstrap_prompt_preparation(
        catalog, "assets", language, ["q", ":q", "exit", "quit", "ende"]
    )


def _contains(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def test_legacy_facade_surface_and_snapshot() raises:
    var bundle = _bundle()
    var legacy = bundle.legacy_snapshot()
    assert_equal(
        legacy,
        PromptPreparationLegacySnapshot(
            "PromptPreparationBundle",
            "verdreheWoReTaBefehl",
            "regExReplace",
            "promptVorbereitungGrosseAusgabe",
            0,
            0,
            0,
            0,
            5,
        ),
    )

    var configured = configure_prompt_preparation(
        bundle.catalog,
        bundle.preparation_catalog,
        bundle.language,
        bundle.exit_commands,
    )
    assert_equal(configured.snapshot().cached_parameter_value_domains, 114)

    var rotated = verdreheWoReTaBefehl(
        "prim 60", "reta -h", ["already"]
    )
    assert_true(rotated.rotated)
    assert_equal(rotated.text1, "reta -h")

    var regex_result = regExReplace(
        bundle, ["reta", "r\"spalt\""]
    )
    assert_equal(regex_result.tokens, ["reta", "-spalten"])

    var method_result = bundle.prepare_grosse_ausgabe(
        "reta", 0, 0, 0, "15", List[String](), False
    )
    var function_result = promptVorbereitungGrosseAusgabe(
        bundle, "reta", 0, 0, 0, "15", List[String](), False
    )
    assert_equal(method_result.tokens, function_result.tokens)


def test_snapshot_and_rotation_contract() raises:
    var bundle = _bundle()
    var snapshot = bundle.snapshot()
    assert_equal(snapshot.class_name, "PromptPreparationBundle")
    assert_equal(snapshot.cached_parameter_value_domains, 114)
    assert_equal(snapshot.exit_commands_len, 5)
    assert_equal(snapshot.native_regex_engine, "POSIX-ERE/native")

    var rotated = bundle.rotate_where_reta_command(
        "prim 60", "reta -h", ["already"]
    )
    assert_true(rotated.rotated)
    assert_equal(rotated.text1, "reta -h")
    assert_equal(rotated.text2, "prim 60")
    assert_equal(len(rotated.text3), 2)
    assert_equal(rotated.text3[1], "-h")

    var unchanged = bundle.rotate_where_reta_command(
        "reta -h", "prim 60", ["already"]
    )
    assert_false(unchanged.rotated)


def test_root_and_main_regex_expansion() raises:
    var bundle = _bundle()
    var root = bundle.regex_replace(["r\"pri\""])
    assert_true(root.changed)
    assert_equal(root.tokens[0], "mulpri")
    assert_true(_contains(root.tokens, "prim"))
    assert_true(_contains(root.tokens, "mulpri"))

    var main = bundle.regex_replace(["reta", "r\"spalt\""])
    assert_equal(len(main.tokens), 2)
    assert_equal(main.tokens[0], "reta")
    assert_equal(main.tokens[1], "-spalten")


def test_output_parameter_and_value_regex() raises:
    var bundle = _bundle()
    var widths = bundle.regex_replace(
        ["reta", "-ausgabe", "r\".*breite.*\""]
    )
    assert_equal(len(widths.tokens), 4)
    assert_equal(widths.tokens[2], "--breite")
    assert_equal(widths.tokens[3], "--breiten")

    var art = bundle.regex_replace(
        ["reta", "-ausgabe", "r\"art\"=r\"ht.*\""]
    )
    assert_equal(art.tokens[2], "--art=nichts,html")

    var literal_star = bundle.regex_replace(
        ["reta", "-ausgabe", "--*"]
    )
    assert_equal(literal_star.tokens[2], "--*")

    var plus_main = bundle.regex_replace(["+reta", "-spalten", "--*=motive"])
    assert_true(plus_main.changed)
    assert_equal(plus_main.tokens[0], "+reta")
    assert_true(_contains(plus_main.tokens, "--menschliches=motive"))

    var plus_value = bundle.regex_replace(["+reta", "-spalten", "--menschliches=*"])
    assert_true(plus_value.changed)
    assert_equal(plus_value.tokens[0], "+reta")
    assert_true(_contains(plus_value.tokens, "--menschliches=motive"))


def test_line_and_combination_regex() raises:
    var bundle = _bundle()
    var time_all = bundle.regex_replace(
        ["reta", "-zeilen", "--zeit=*"]
    )
    assert_equal(time_all.tokens[2], "--zeit=gestern,heute,morgen")

    var time_today = bundle.regex_replace(
        ["reta", "-zeilen", "r\"zeit\"=r\"he.*\""]
    )
    assert_equal(time_today.tokens[2], "--zeit=heute")

    var galaxy = bundle.regex_replace(
        ["reta", "-kombination", "r\"gal.*\"=r\"Leb.*\""]
    )
    assert_equal(galaxy.tokens[2], "--galaxie=Lebewesen")


def test_large_preparation_range_modes() raises:
    var bundle = _bundle()
    var normal = bundle.prepare_large_output(
        "reta", 0, 0, 0, "15", List[String](), False
    )
    assert_false(normal.is_pure_reta_command)
    assert_equal(normal.max_number, 15)
    assert_true(normal.compact)
    assert_equal(normal.tokens[0], "-zeilen")
    assert_equal(normal.tokens[1], "--vorhervonausschnitt=3,5,15")

    var count = bundle.prepare_large_output(
        "reta", 0, 0, 0, "range 15-17", List[String](), False
    )
    assert_equal(count.tokens[0], "-zeilen")
    assert_equal(count.tokens[1], "--zaehlung=15-17")
    assert_equal(count.tokens[2], "range")

    var multiples = bundle.prepare_large_output(
        "reta", 0, 0, 0, "v 3-4", List[String](), False
    )
    assert_equal(len(multiples.tokens), 2)
    assert_equal(multiples.tokens[1], "--vielfachevonzahlen=3-4")


def test_large_preparation_divisors_and_existing_sections() raises:
    var bundle = _bundle()
    var divisors = bundle.prepare_large_output(
        "reta", 0, 0, 0, "w 12", List[String](), False
    )
    assert_equal(divisors.max_number, 12)
    assert_equal(divisors.tokens[1], "--vorhervonausschnitt=2,3,4,6,12")

    var existing = bundle.prepare_large_output(
        "reta",
        0,
        0,
        0,
        "reta -zeilen --zeit=heute 3 -ausgabe --art=html",
        List[String](),
        False,
    )
    assert_true(existing.is_pure_reta_command)
    assert_equal(len(existing.tokens), 5)
    assert_equal(existing.tokens[0], "reta")
    assert_equal(existing.tokens[1], "-ausgabe")
    assert_equal(existing.tokens[4], "--vorhervonausschnitt=3")


def test_selective_and_exit_plans() raises:
    var bundle = _bundle()
    var selective = bundle.prepare_large_output(
        "", 0, 6, 0, "60", ["prim"], False
    )
    assert_equal(selective.max_number, 60)
    assert_equal(selective.tokens[0], "60")
    assert_equal(selective.tokens[1], "prim")

    var exiting = bundle.prepare_large_output(
        "", 0, 0, 0, "exit", List[String](), False
    )
    assert_true(exiting.exit_requested)
    assert_equal(len(exiting.tokens), 1)
    assert_equal(exiting.tokens[0], "q")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
