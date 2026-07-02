from std.collections import List
from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.i18n_words import *


def test_language_aliases() raises:
    assert_equal(canonical_i18n_language(""), "deutsch")
    assert_equal(canonical_i18n_language("german"), "deutsch")
    assert_equal(canonical_i18n_language("EN"), "english")
    assert_equal(canonical_i18n_language("tiếngviệt"), "vietnamese")
    assert_equal(canonical_i18n_language("中國人"), "chinese")
    assert_equal(canonical_i18n_language("한국인"), "korean")
    assert_equal(canonical_i18n_language("unknown"), "deutsch")


def test_escape_roundtrip() raises:
    var original = "a\\b\tc\nd\re\x1ff"
    assert_equal(decode_i18n_field(encode_i18n_field(original)), original)
    assert_equal(decode_i18n_field("literal\\\\n"), "literal\\n")


def test_german_snapshot() raises:
    var catalog = load_i18n_words_catalog("deutsch")
    var snapshot = i18n_words_snapshot(catalog)
    assert_equal(snapshot.language, "deutsch")
    assert_equal(snapshot.rows, 6927)
    assert_equal(snapshot.roots, 246)
    assert_equal(snapshot.bootstrap_rows, 2)
    assert_equal(snapshot.context_rows, 1503)
    assert_equal(snapshot.matrix_rows, 4764)
    assert_equal(snapshot.runtime_rows, 579)
    assert_equal(snapshot.facade_rows, 79)


def test_foreign_snapshot_and_effective_namespace() raises:
    var catalog = load_i18n_words_catalog("english")
    var snapshot = i18n_words_snapshot(catalog)
    assert_equal(snapshot.rows, 6935)
    assert_equal(snapshot.roots, 254)
    assert_equal(
        i18n_words_value(
            catalog, "i18n.words_context", "sprachenParameterWort"
        ),
        "-language=",
    )
    assert_equal(
        i18n_words_value(
            catalog, "i18n.words_context", "ParametersMain.religionen[0]"
        ),
        "religions",
    )
    assert_equal(
        i18n_words_int(
            catalog, "i18n.words_matrix", "paraNdataMatrix[0][2][0]"
        ),
        10,
    )


def test_container_and_reference_contract() raises:
    var catalog = load_i18n_words_catalog("deutsch")
    var matrix = i18n_words_node(
        catalog, "i18n.words_matrix", "paraNdataMatrix"
    )
    assert_equal(matrix.kind, "list")
    assert_equal(matrix.value, "431")
    var reference = i18n_words_node(
        catalog, "i18n.words_matrix", "paraNdataMatrix[0][0]"
    )
    assert_equal(reference.kind, "ref")
    assert_equal(
        reference.value,
        "i18n.words_context:ParametersMain.wichtigste",
    )
    assert_true(
        i18n_words_has_node(
            catalog, "i18n.words_runtime", "tableHandling.into"
        )
    )
    assert_false(
        i18n_words_has_node(catalog, "i18n.words_runtime", "missing")
    )


def test_runtime_behaviors() raises:
    var de = load_i18n_words_catalog("deutsch")
    var en = load_i18n_words_catalog("english")
    assert_equal(classify_i18n_relation(de, 0), "ja")
    assert_equal(classify_i18n_relation(de, 4), "entfernt ähnlich")
    assert_equal(classify_i18n_relation(en, 1), "opposite")
    assert_equal(classify_i18n_relation(en, 3), "distant opposite")
    assert_equal(classify_i18n_relation(en, 9), "")

    var values = List[String]()
    values.append("a")
    values.append("b")
    values.append("a")
    values.append("c")
    values.append("b")
    values.append("b")
    var duplicates = duplicate_i18n_strings(values)
    assert_equal(len(duplicates), 2)
    assert_equal(duplicates[0], "a")
    assert_equal(duplicates[1], "b")


def test_catalog_rendering_is_lossless() raises:
    var catalog = load_i18n_words_catalog("deutsch")
    var rendered = render_i18n_words_catalog(catalog)
    assert_true(rendered.startswith("i18n.words_bootstrap\talxp\tfunction"))
    assert_true(rendered.endswith("__behavior__.classify[4]\tstr\tentfernt ähnlich\n"))
    assert_equal(len(rendered.split("\n")) - 1, 6927)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
