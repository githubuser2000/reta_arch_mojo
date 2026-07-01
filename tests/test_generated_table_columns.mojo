from std.collections import List
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.csv_table import CsvTable, read_semicolon_csv
from reta_mojo.generated_table_columns import *
from reta_mojo.generated_aliases import FractionColumnRequest, MetaColumnRequest, ModalConcept


def _blank_table(row_count: Int, column_count: Int) -> CsvTable:
    var rows = List[List[String]]()
    for _ in range(row_count):
        var row = List[String]()
        for _ in range(column_count):
            row.append("")
        rows.append(row^)
    return CsvTable(rows^, column_count)


def test_multiple_propagation_matches_legacy_plain_rules() raises:
    var table = _blank_table(10, 20)
    table.rows[0][19] = "header"
    table.rows[2][19] = "A"
    table.rows[3][19] = "B"
    table.rows[5][19] = "C"
    var result = propagate_multiples_column(table, 19, 9, "csv")
    assert_equal(result.rows[2][19], "A | ")
    assert_equal(result.rows[3][19], "B | ")
    assert_equal(result.rows[4][19], "A")
    assert_equal(result.rows[5][19], "C | ")
    assert_equal(result.rows[6][19], "A | B")
    assert_equal(result.rows[8][19], "A")
    assert_equal(result.rows[9][19], "B")


def test_love_polygon_morphism() raises:
    var table = _blank_table(2, 10)
    table.rows[0][8] = "Love heading"
    table.rows[0][4] = "size heading"
    table.rows[1][8] = "Agape"
    table.rows[1][4] = "person"
    assert_equal(
        love_polygon_value(table, 1, "german"),
        "Agape der eigenen Strukturgröße (person) auf dich bei gleichförmigen Polygonen",
    )
    assert_equal(
        love_polygon_value(table, 1, "english"),
        "Agape own structure size (person) on you with regular polygons",
    )


def test_real_table_generated_order_and_values() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var base = table.maximum_columns
    var selected: List[Int] = [64]
    var modal = List[ModalConcept]()
    var meta = List[MetaColumnRequest]()
    var fractions = List[FractionColumnRequest]()
    var commands = List[String]()
    var generated = apply_native_generated_columns(
        table, selected, modal, meta, fractions, commands, "german", "csv", 6
    )
    assert_equal(len(generated.generated_names), 4)
    assert_equal(generated.generated_names[0], "concatPrimCreativityType")
    assert_equal(generated.generated_names[1], "concatMondExponzierenLogarithmusTyp:44")
    assert_equal(generated.generated_names[2], "concatMondExponzierenLogarithmusTyp:56")
    assert_equal(generated.generated_names[3], "createSpalteGestirn")
    assert_equal(generated.output_columns, [64, base, base + 1, base + 2, base + 3])
    assert_equal(generated.table.rows[4][base], "3. Mondzahl")
    assert_true(generated.table.rows[4][base + 1].startswith("sich etwas vormachen"))
    assert_true(generated.table.rows[4][base + 2].startswith("seiner eigenen Strukturgröße"))
    assert_equal(
        generated.table.rows[6][base + 3],
        "Sonne (keine Potenzen), und außerdem Planet (2*n), und außerdem wäre eine schwarze Sonne (-3*n), wenn ins Negative durch eine Typ 13 verdreht",
    )


def test_trigger_order_for_multiple_families() raises:
    var table = _blank_table(4, 250)
    var selected: List[Int] = [64, 132, 242, 9]
    var modal = List[ModalConcept]()
    var meta = List[MetaColumnRequest]()
    var fractions = List[FractionColumnRequest]()
    var commands = List[String]()
    var generated = apply_native_generated_columns(
        table, selected, modal, meta, fractions, commands, "english", "csv", 3
    )
    assert_equal(len(generated.generated_names), 7)
    assert_equal(generated.generated_names[0], "concatPrimCreativityType")
    assert_equal(generated.generated_names[1], "concatGleichheitFreiheitDominieren")
    assert_equal(generated.generated_names[2], "concatGeistEmotionEnergieMaterieTopologie")
    assert_equal(generated.generated_names[3], "concatMondExponzierenLogarithmusTyp:44")
    assert_equal(generated.generated_names[4], "concatMondExponzierenLogarithmusTyp:56")
    assert_equal(generated.generated_names[5], "concatLovePolygon")
    assert_equal(generated.generated_names[6], "createSpalteGestirn")


def test_prime_cross_command_appends_two_deterministic_columns() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var base = table.maximum_columns
    var selected = List[Int]()
    var modal = List[ModalConcept]()
    var meta = List[MetaColumnRequest]()
    var fractions = List[FractionColumnRequest]()
    var commands: List[String] = ["primzahlkreuzprocontra"]
    var generated = apply_native_generated_columns(
        table, selected, modal, meta, fractions, commands, "german", "csv", 30
    )
    assert_equal(len(generated.generated_names), 2)
    assert_equal(generated.output_columns, [base, base + 1])
    assert_equal(
        generated.table.rows[21][base],
        "pro 7, pro 9 |  Darin kann sich die 21 am Besten hineinversetzen.",
    )
    assert_true(
        generated.table.rows[1][base + 1].startswith(
            "pro dieser Zahl sind: 19, 3"
        )
    )


def test_prim_csv_command_appends_legacy_described_prime_column() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var base = table.maximum_columns
    var selected = List[Int]()
    var modal = List[ModalConcept]()
    var meta = List[MetaColumnRequest]()
    var fractions = List[FractionColumnRequest]()
    var commands: List[String] = ["PrimCSV"]
    var generated = apply_native_generated_columns(
        table, selected, modal, meta, fractions, commands, "german", "csv", 3
    )
    assert_equal(generated.generated_names, ["PrimCSV"])
    assert_equal(generated.output_columns, [base])
    assert_equal(
        generated.table.rows[0][base],
        "Primzahlvielfache, nicht generiert",
    )
    assert_equal(generated.table.rows[1][base], "|")
    assert_true(generated.table.rows[2][base].startswith("| die Absicht (1)"))
    assert_true(generated.table.rows[2][base].endswith(" |"))


def test_prim_csv_html_empty_row_uses_empty_list() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var selected = List[Int]()
    var modal = List[ModalConcept]()
    var meta = List[MetaColumnRequest]()
    var fractions = List[FractionColumnRequest]()
    var commands: List[String] = ["PrimCSV"]
    var generated = apply_native_generated_columns(
        table, selected, modal, meta, fractions, commands, "english", "html", 2
    )
    var base = table.maximum_columns
    assert_equal(generated.table.rows[0][base], "prime multiples, not generated")
    assert_equal(generated.table.rows[1][base], "<ul></ul>")
    assert_true(generated.table.rows[2][base].startswith("<ul><li>"))
    assert_true(generated.table.rows[2][base].endswith("</li></ul>"))


def test_prim_csv_precedes_fractional_concat_columns() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var base = table.maximum_columns
    var selected = List[Int]()
    var modal = List[ModalConcept]()
    var meta = List[MetaColumnRequest]()
    var fractions: List[FractionColumnRequest] = [
        FractionColumnRequest("universe", 2)
    ]
    var commands: List[String] = ["PrimCSV"]
    var generated = apply_native_generated_columns(
        table, selected, modal, meta, fractions, commands, "german", "csv", 3
    )
    assert_equal(len(generated.generated_names), 3)
    assert_equal(generated.generated_names[0], "PrimCSV")
    assert_equal(
        generated.generated_names[1],
        "readConcatCsv:universe,2,0",
    )
    assert_equal(
        generated.generated_names[2],
        "readConcatCsv:universe,2,1",
    )
    assert_equal(generated.output_columns, [base, base + 1, base + 2])
    assert_equal(
        generated.table.rows[0][base],
        "Primzahlvielfache, nicht generiert",
    )
    assert_true("n/2" in generated.table.rows[0][base + 1])
    assert_true("2/n" in generated.table.rows[0][base + 2])


def test_moon_without_factors_keeps_markup_container() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    assert_equal(
        moon_relation_value(table, 1, 44, "html", "german"),
        "<ul>kein Mond</ul>",
    )
    assert_equal(
        moon_relation_value(table, 1, 56, "bbcode", "english"),
        "[list]no moon[/list]",
    )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
