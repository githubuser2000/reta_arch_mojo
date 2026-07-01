from std.collections import List
from std.testing import assert_equal, TestSuite
from reta_mojo.completion_runtime import bootstrap_completion_runtime
from reta_mojo.completion_nested import *


def _contains(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def test_bundle_snapshot_and_situations() raises:
    var bundle = bootstrap_nested_completion_morphisms()
    assert_equal(bundle.legacy_owner, "libs.nestedAlx")
    assert_equal(bundle.activated_stage, 41)
    var snapshot = nested_completion_snapshot(bundle)
    assert_equal(snapshot.class_name, "NestedCompletionMorphismBundle")
    assert_equal(snapshot.capsule, "InputPromptCapsule")
    assert_equal(snapshot.category, "ActivatedNestedCompletionCategory")
    assert_equal(snapshot.functor, "NestedCompletionActivationFunctor")
    assert_equal(
        snapshot.natural_transformation,
        "NestedCompleterToArchitectureTransformation",
    )
    assert_equal(len(snapshot.morphisms), 11)
    assert_equal(len(snapshot.compatibility_names), 3)
    assert_equal(len(snapshot.situations), 15)
    assert_equal(CompletionSituation.reta_begin().name(), "retaAnfang")
    assert_equal(CompletionSituation.output_value().name(), "ausgabeValPara")


def test_deutsch_context_transitions() raises:
    var runtime = bootstrap_completion_runtime("assets", "deutsch")
    var completer = ArchitectureNestedCompleter(runtime)
    var root = completer.candidates("prim")
    assert_equal(root[0], "prim")
    assert_equal(_contains(root, "primzahlkreuz"), True)

    var mains = completer.candidates("reta ")
    assert_equal(_contains(mains, "-zeilen"), True)
    assert_equal(_contains(mains, "-ausgabe"), True)

    var output = completer.candidates("reta -ausgabe ")
    assert_equal(_contains(output, "--art="), True)
    assert_equal(_contains(output, "--breite="), True)

    var values = completer.candidates("reta -ausgabe --art=h")
    assert_equal(values[0], "html")
    assert_equal(_contains(values, "shell"), True)

    var comma = completer.candidates("reta -zeilen --typ=sonne,mo")
    assert_equal(comma[0], "mond")
    assert_equal(_contains(comma, "-mond"), True)

    var second_term = completer.candidates("prim foo")
    assert_equal(len(second_term), 1)
    assert_equal(second_term[0], "primfaktorzerlegungModulo24")


def test_english_fuzzy_order_and_completion_objects() raises:
    var runtime = bootstrap_completion_runtime("assets", "english")
    var bundle = bootstrap_nested_completion_morphisms()
    var completer = create_nested_completer(bundle, runtime)
    var values = completer.candidates("reta -output --type=h")
    assert_equal(values[0], "html")
    assert_equal(values[1], "shell")
    assert_equal(values[2], "nothing")

    var completions = completer.get_completions("reta -output --type=h")
    assert_equal(len(completions), 3)
    assert_equal(completions[0].text, "html")
    assert_equal(completions[0].start_position, -1)

    var same = ArchitectureNestedCompleter(runtime)
    assert_equal(completer.same_runtime(same), True)


    var close = completer.candidates("reta -lines --primes=p")
    assert_equal(len(close), 2)
    assert_equal(close[0], "primenumbers")
    assert_equal(close[1], "primzahlen")


def test_fragment_and_catalog_adapter() raises:
    assert_equal(nested_completion_fragment("reta -output --type=sh"), "sh")
    assert_equal(nested_completion_fragment("reta -lines "), "-lines")
    var runtime = bootstrap_completion_runtime("assets", "english")
    var from_runtime = nested_completion_candidates(runtime, "reta ")
    var from_catalog = nested_completion_candidates_from_catalog(
        runtime.catalog, "english", "reta "
    )
    assert_equal(len(from_runtime), len(from_catalog))
    for index in range(len(from_runtime)):
        assert_equal(from_runtime[index], from_catalog[index])



def test_difflib_compatible_close_matching() raises:
    assert_equal(nested_sequence_match_count("primemultiples", "primes"), 6)
    assert_equal(nested_sequence_match_count("primzahlen", "primes"), 5)
    var possibilities = List[String]()
    possibilities.append("primemultiples")
    possibilities.append("primenumbers")
    possibilities.append("primzahlen")
    possibilities.append("type")
    possibilities.append("time")
    var matches = nested_close_matches("primes", possibilities)
    assert_equal(matches[0], "primenumbers")
    assert_equal(matches[1], "primzahlen")
    assert_equal(matches[2], "time")

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
