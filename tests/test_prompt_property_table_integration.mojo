from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_runtime import split_prompt_words
from reta_mojo.prompt_table_execution import (
    PromptTablePlan,
    plan_prompt_table_commands,
)


def _require(condition: Bool, message: String) raises:
    if not condition:
        raise Error(message)


def _plan(text: String) raises -> PromptTablePlan:
    var catalog = load_prompt_language_catalog("assets")
    return plan_prompt_table_commands(
        split_prompt_words(text), "deutsch", catalog
    )


def _tokens(plan: PromptTablePlan, invocation: Int = 0) -> String:
    return "|".join(plan.invocations[invocation].tokens)


def _check_eign() raises -> Int:
    var checks = 0
    var plan = _plan("EIGNgut EIGNehrlich 2 --art=csv --nocolor")
    _require(plan.handled, "EIGN command was not handled")
    checks += 1
    _require(len(plan.invocations) == 1, "EIGN invocation count")
    checks += 1
    _require("--vorhervonausschnitt=2" in _tokens(plan), "EIGN row")
    checks += 1
    _require("--konzept=ehrlich,gut" in _tokens(plan), "EIGN set order")
    checks += 1

    var reduced = _plan("EIGNgut 4/2")
    _require(reduced.handled, "reduced EIGN command was not handled")
    checks += 1
    _require(len(reduced.invocations) == 1, "reduced EIGN invocation")
    checks += 1
    _require(
        "--vorhervonausschnitt=2" in _tokens(reduced),
        "reduced EIGN row",
    )
    checks += 1

    var proper = _plan("EIGNgut 2/3")
    _require(proper.handled, "proper-fraction EIGN command was not handled")
    checks += 1
    _require(len(proper.invocations) == 0, "proper-fraction EIGN emitted table")
    checks += 1
    return checks


def _check_eigr() raises -> Int:
    var checks = 0
    var integer = _plan("EIGRwerte 2 --art=csv --nocolor")
    _require(integer.handled, "integer EIGR command was not handled")
    checks += 1
    _require(len(integer.invocations) == 1, "integer EIGR invocation")
    checks += 1
    _require("--vorhervonausschnitt=0" in _tokens(integer), "EIGR base row")
    checks += 1
    _require("--konzept2=werte" in _tokens(integer), "EIGR column")
    checks += 1
    _require(
        "-zeilen|--vorhervonausschnitt=2|--oberesmaximum=1025"
        in _tokens(integer),
        "EIGR second row section",
    )
    checks += 1

    var reciprocal = _plan("EIGRwerte 1/2")
    _require(reciprocal.handled, "reciprocal EIGR command was not handled")
    checks += 1
    _require(len(reciprocal.invocations) == 1, "reciprocal EIGR invocation")
    checks += 1
    _require(
        "--vorhervonausschnitt=2" in _tokens(reciprocal),
        "reciprocal EIGR row",
    )
    checks += 1

    var mixed = _plan("EIGRwerte 2 1/3")
    _require(mixed.handled, "mixed EIGR command was not handled")
    checks += 1
    _require(len(mixed.invocations) == 1, "mixed EIGR invocation")
    checks += 1
    _require(
        "--vorhervonausschnitt=3" in _tokens(mixed), "mixed reciprocal row"
    )
    checks += 1
    _require(
        "-zeilen|--vorhervonausschnitt=2" in _tokens(mixed),
        "mixed integer row",
    )
    checks += 1

    var proper = _plan("EIGRwerte 2/3")
    _require(proper.handled, "proper-fraction EIGR command was not handled")
    checks += 1
    _require(len(proper.invocations) == 0, "proper-fraction EIGR emitted table")
    checks += 1
    return checks


def _check_catalog() raises -> Int:
    var catalog = load_prompt_language_catalog("assets")
    var count = 0
    for entry_index in range(len(catalog.completions)):
        var entry = catalog.completions[entry_index].copy()
        if entry.language != "deutsch" or entry.scope != "root":
            continue
        for value_index in range(len(entry.values)):
            var value = entry.values[value_index]
            if not (value.startswith("EIGN") or value.startswith("EIGR")):
                continue
            var plan = plan_prompt_table_commands(
                [value, "2"], "deutsch", catalog
            )
            _require(plan.handled, "catalog property command was not handled")
            _require(len(plan.invocations) == 1, "catalog property invocation")
            if value.startswith("EIGN"):
                _require("--konzept=" in _tokens(plan), "catalog EIGN column")
            else:
                _require("--konzept2=" in _tokens(plan), "catalog EIGR column")
            count += 1
    _require(count == 165, "unexpected EIGN/EIGR catalog count")
    return count


def main() raises:
    var contract_checks = _check_eign() + _check_eigr()
    var catalog_checks = _check_catalog()
    print(
        "native property planner integration:",
        contract_checks,
        "contract checks and",
        catalog_checks,
        "catalog commands passed",
    )
