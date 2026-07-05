from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_runtime import split_prompt_words
from reta_mojo.prompt_table_execution import PromptTablePlan, plan_prompt_table_commands


def _plan(text: String) raises -> PromptTablePlan:
    var catalog = load_prompt_language_catalog("assets")
    return plan_prompt_table_commands(
        split_prompt_words(text), "deutsch", catalog
    )


def _tokens(plan: PromptTablePlan) -> String:
    return "|".join(plan.invocations[0].tokens)


def test_explicit_output_column_order_replaces_internal_default() raises:
    var plan = _plan(
        "richtung 2 --nocolor --justtext --art=csv --onetable "
        "--spaltenreihenfolgeundnurdiese=0,1 --endlessscreen --endless "
        "--dontwrap --breite=40 --breiten=5,7 --keineleereninhalte "
        "--keinenummerierung --keineueberschriften"
    )
    assert_true(plan.handled)
    assert_equal(len(plan.invocations), 1)
    assert_equal(
        _tokens(plan),
        "-zeilen|--vorhervonausschnitt=2|--oberesmaximum=1025|-spalten|"
        "--Primzahlwirkung=Galaxieabsicht|--breite=0|-ausgabe|"
        "--nocolor|--keineleereninhalte|--endlessscreen|"
        "--keinenummerierung|--breite=40|--dontwrap|--art=csv|"
        "--endless|--justtext|--onetable|--keineueberschriften|"
        "--spaltenreihenfolgeundnurdiese=0,1|--breiten=5,7",
    )


def test_component_local_reciprocal_tail_matches_python_integer_set() raises:
    var plan = _plan("universum v1/4,-1/8")
    assert_true(plan.handled)
    assert_equal(len(plan.invocations), 1)
    var tokens = _tokens(plan)
    assert_true("--vorhervonausschnitt=512,4,516,520,12,524" in tokens)
    assert_true(",492,1004,496,1008,500,1012,504,508" in tokens)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
