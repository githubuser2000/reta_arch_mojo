from std.collections import List
from std.testing import assert_equal, TestSuite
from reta_mojo.completion_word import *


def test_bundle_and_sample_match_stage_40_contract() raises:
    var bundle = bootstrap_word_completion_morphisms()
    assert_equal(bundle.legacy_owner, "libs.word_completerAlx")
    assert_equal(bundle.activated_stage, 40)
    var sample = sample_word_completions()
    assert_equal(len(sample), 2)
    assert_equal(sample[0], "reta")
    assert_equal(sample[1], "religion")

    var snapshot = word_completion_snapshot(bundle)
    assert_equal(snapshot.class_name, "WordCompletionMorphismBundle")
    assert_equal(snapshot.capsule, "InputPromptCapsule")
    assert_equal(snapshot.category, "ActivatedWordCompletionCategory")
    assert_equal(snapshot.functor, "WordCompletionActivationFunctor")
    assert_equal(
        snapshot.natural_transformation,
        "WordCompleterToArchitectureTransformation",
    )
    assert_equal(len(snapshot.morphisms), 6)
    assert_equal(len(snapshot.compatibility_names), 2)
    assert_equal(snapshot.sample_texts[1], "religion")

    var completer = create_word_completer(bundle, ["reta", "religion", "alpha"])
    var object_results = completer.get_completions("re")
    assert_equal(len(object_results), 2)
    assert_equal(object_results[0].text, "reta")
    var equal_words = ArchitectureWordCompleter(["reta", "religion", "alpha"])
    assert_equal(completer.same_words(equal_words), True)
    completer.replace_words(["beta", "theta"])
    var refreshed = completer.get_completions("th")
    assert_equal(len(refreshed), 1)
    assert_equal(refreshed[0].text, "theta")


def test_word_before_cursor_modes_and_utf8() raises:
    assert_equal(word_before_cursor("alpha beta"), "beta")
    assert_equal(word_before_cursor("alpha beta", 8), "be")
    assert_equal(word_before_cursor("alpha-beta"), "beta")
    assert_equal(word_before_cursor("alpha-beta", -1, True), "alpha-beta")
    assert_equal(word_before_cursor("reta --größe"), "e")
    assert_equal(word_before_cursor("reta --größe", -1, True), "--größe")
    assert_equal(word_before_cursor("reta --größe", -1, False, True), "reta --größe")
    # The standalone Python helper gives sentence mode precedence.  The
    # owning ArchitectureWordCompleter constructor rejects both flags.
    assert_equal(word_before_cursor("alpha beta", -1, True, True), "alpha beta")
    assert_equal(word_before_cursor("eins\u00A0zwei", -1, True), "zwei")

    var rejected = False
    try:
        _ = ArchitectureWordCompleter(["alpha"], False, [], True, True)
    except:
        rejected = True
    assert_equal(rejected, True)


def test_match_semantics_preserve_python_slice_behaviour() raises:
    assert_equal(word_completion_matches("reta", "re"), True)
    assert_equal(word_completion_matches("reta", "RE", True), True)
    assert_equal(word_completion_matches("reta", "reta-extra"), True)
    assert_equal(word_completion_matches("beta", "et", False, True), True)
    assert_equal(word_completion_matches("alpha", "et", False, True), False)
    assert_equal(word_completion_matches("reta", "x"), False)

    # A custom native pattern can restrict the document externally and use the
    # same completion core through the explicit prefix adapter.
    var patterned = iter_word_completions_from_prefix(
        ["reta", "religion", "alpha"], "rel"
    )
    assert_equal(len(patterned), 1)
    assert_equal(patterned[0].text, "religion")
    assert_equal(patterned[0].start_position, -3)


def test_completions_keep_order_unicode_start_and_decorations() raises:
    var decorations = List[WordCompletionDecoration]()
    decorations.append(WordCompletionDecoration("religion", "Religion", "meta"))
    var completions = iter_word_completions(
        ["reta", "religion", "alpha"], "re", -1, False, False, False, False, decorations
    )
    assert_equal(len(completions), 2)
    assert_equal(completions[0].text, "reta")
    assert_equal(completions[0].start_position, -2)
    assert_equal(completions[0].display, "reta")
    assert_equal(completions[1].display, "Religion")
    assert_equal(completions[1].display_meta, "meta")

    var unicode = iter_word_completions(["größe", "grün", "öße", "öko"], "grö")
    assert_equal(len(unicode), 2)
    assert_equal(unicode[0].text, "öße")
    assert_equal(unicode[1].text, "öko")
    assert_equal(unicode[0].start_position, -1)


def test_middle_and_sentence_completion() raises:
    var middle = iter_word_completions(
        ["alpha", "beta", "theta"], "et", -1, False, False, False, True
    )
    assert_equal(len(middle), 2)
    assert_equal(middle[0].text, "beta")
    assert_equal(middle[1].text, "theta")

    var sentence = iter_word_completions(
        ["reta --hilfe", "reta --version"], "reta --h", -1, False, False, True
    )
    assert_equal(len(sentence), 1)
    assert_equal(sentence[0].text, "reta --hilfe")
    assert_equal(sentence[0].start_position, -8)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
