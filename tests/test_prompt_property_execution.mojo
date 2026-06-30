from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.prompt_property_execution import *


def _integer_base(rows: String) -> List[String]:
    return [
        "-zeilen",
        "--vorhervonausschnitt=" + rows,
        "--oberesmaximum=1025",
        "-spalten",
    ]


def _reciprocal_base(rows: String) -> List[String]:
    return ["-zeilen", "--vorhervonausschnitt=" + rows, "-spalten"]


def _tokens(plan: PromptPropertyPlan, invocation: Int = 0) -> String:
    return "|".join(plan.invocations[invocation].tokens)


def test_eign_uses_complete_prompt_set_order() raises:
    var plan = plan_prompt_property_commands(
        ["EIGNgut", "EIGNehrlich", "2", "--art=csv", "--nocolor"],
        "deutsch",
        True,
        _integer_base("2"),
        False,
        List[String](),
        False,
        False,
        False,
        ["--art=csv", "--nocolor"],
    )
    assert_true(plan.recognized)
    assert_equal(len(plan.invocations), 1)
    assert_equal("|".join(plan.n_values), "ehrlich|gut")
    assert_true("--konzept=ehrlich,gut" in _tokens(plan))
    assert_true("--art=csv|--nocolor" in _tokens(plan))


def test_eign_ignores_proper_fraction_only_axis() raises:
    var plan = plan_prompt_property_commands(
        ["EIGNgut", "2/3"],
        "deutsch",
        False,
        List[String](),
        False,
        List[String](),
        False,
        False,
        False,
        List[String](),
    )
    assert_true(plan.recognized)
    assert_equal(len(plan.invocations), 0)


def test_eigr_integer_contract_keeps_second_row_section() raises:
    var plan = plan_prompt_property_commands(
        ["EIGRwerte", "2", "--art=csv", "--nocolor"],
        "deutsch",
        True,
        _integer_base("2"),
        False,
        List[String](),
        False,
        False,
        False,
        ["--art=csv", "--nocolor"],
    )
    assert_true(plan.recognized)
    assert_equal(len(plan.invocations), 1)
    assert_true("--vorhervonausschnitt=0" in _tokens(plan))
    assert_true("--konzept2=werte" in _tokens(plan))
    assert_true(
        "--art=csv|--nocolor|-zeilen|--vorhervonausschnitt=2|--oberesmaximum=1025"
        in _tokens(plan)
    )


def test_eigr_reciprocal_contract_uses_reciprocal_rows() raises:
    var plan = plan_prompt_property_commands(
        ["EIGRwerte", "1/2"],
        "deutsch",
        False,
        List[String](),
        True,
        _reciprocal_base("2"),
        False,
        False,
        False,
        List[String](),
    )
    assert_true(plan.recognized)
    assert_equal(len(plan.invocations), 1)
    assert_true("--vorhervonausschnitt=2" in _tokens(plan))
    assert_true("--konzept2=werte" in _tokens(plan))
    assert_true(_tokens(plan).split("|-zeilen|").__len__() == 1)


def test_eigr_mixed_rows_preserve_both_sections() raises:
    var plan = plan_prompt_property_commands(
        ["EIGRwerte", "2", "1/3"],
        "deutsch",
        True,
        _integer_base("2"),
        True,
        _reciprocal_base("3"),
        False,
        True,
        True,
        ["--art=markdown"],
    )
    assert_equal(len(plan.invocations), 1)
    assert_true(
        "--vorhervonausschnitt=3|-spalten|--konzept2=werte" in _tokens(plan)
    )
    assert_true("--keineleereninhalte" in _tokens(plan))
    assert_true(
        "-zeilen|--vorhervonausschnitt=2|--oberesmaximum=1025" in _tokens(plan)
    )


def test_bare_property_prefixes_stay_on_compatibility_boundary() raises:
    var eign = plan_prompt_property_commands(
        ["EIGN", "2"],
        "deutsch",
        True,
        _integer_base("2"),
        False,
        List[String](),
        False,
        False,
        False,
        List[String](),
    )
    var eigr = plan_prompt_property_commands(
        ["EIGR", "2"],
        "deutsch",
        True,
        _integer_base("2"),
        False,
        List[String](),
        False,
        False,
        False,
        List[String](),
    )
    assert_false(eign.recognized)
    assert_false(eigr.recognized)
    assert_equal(len(eign.invocations), 0)
    assert_equal(len(eigr.invocations), 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
