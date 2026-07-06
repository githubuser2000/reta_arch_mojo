from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import List
from reta_mojo.prompt_execution import *
from reta_mojo.prompt_language import (
    PromptLanguageCatalog,
    load_prompt_language_catalog,
)
from reta_mojo.prompt_runtime import KIND_HELP


def _catalog() raises -> PromptLanguageCatalog:
    return load_prompt_language_catalog("assets")


def _has_token(values: List[String], needle: String) -> Bool:
    for index in range(len(values)):
        if values[index] == needle:
            return True
    return False


def test_bundle_maps_large_python_owner_to_native_components() raises:
    var bundle = bootstrap_prompt_execution()
    assert_true(prompt_execution_bundle_valid(bundle))
    assert_equal(bundle.command_runner_owner, "prompt_execution_runtime.mojo")
    assert_equal(
        bundle.fraction_manager_owner, "prompt_fraction_execution.mojo"
    )
    assert_equal(bundle.reta_executor_owner, "native_reta_cli.mojo")
    assert_equal(bundle.ownership_count, 22)


def test_snapshot_matches_python_architecture_surface() raises:
    var snapshot = bootstrap_prompt_execution().snapshot()
    assert_equal(snapshot.class_name, "PromptExecutionBundle")
    assert_equal(snapshot.command_runner, "PromptGrosseAusgabe")
    assert_equal(
        snapshot.fraction_manager, "bruchBereichsManagementAndWbefehl"
    )
    assert_equal(snapshot.reta_executor, "retaExecuteNprint")
    assert_equal(snapshot.i18n_prompt, "type")
    assert_equal(
        prompt_execution_snapshot_json(snapshot),
        '{"class":"PromptExecutionBundle","command_runner":"PromptGrosseAusgabe","fraction_manager":"bruchBereichsManagementAndWbefehl","reta_executor":"retaExecuteNprint","i18n_prompt":"type"}',
    )


def test_prompt_execution_routing_plan_expands_compact_numeric_defaults() raises:
    var plan = plan_prompt_execution_routing("15", "deutsch", _catalog())
    assert_equal(len(plan.raw_tokens), 1)
    assert_equal(plan.raw_tokens[0], "15")
    assert_true(plan.compact_expansion.compact)
    assert_true(plan.historical_echo)
    assert_true(plan.numeric_default)
    assert_true(plan.planning_tokens_are_prepared)
    assert_true(plan.quiet_echo)
    assert_true(_has_token(plan.planning_tokens, "mulpri"))
    assert_true(
        _has_token(
            plan.planning_tokens,
            "keineEinZeichenZeilenPlusKeineAusgabeWelcherBefehlEsWar",
        )
    )


def test_prompt_execution_routing_plan_keeps_table_text_unprepared() raises:
    var plan = plan_prompt_execution_routing(
        "mond 1-3 --art=csv", "deutsch", _catalog()
    )
    assert_false(plan.compact_expansion.compact)
    assert_false(plan.historical_echo)
    assert_false(plan.numeric_default)
    assert_false(plan.planning_tokens_are_prepared)
    assert_false(plan.quiet_echo)
    assert_equal(plan.normalized_line, "mond 1-3 --art=csv")
    assert_equal(len(plan.planning_tokens), 3)
    assert_equal(plan.planning_tokens[0], "mond")
    assert_equal(plan.planning_tokens[1], "1-3")
    assert_equal(plan.planning_tokens[2], "--art=csv")


def test_prompt_execution_routing_plan_classifies_short_help() raises:
    var plan = plan_prompt_execution_routing("h", "deutsch", _catalog())
    assert_true(plan.historical_echo)
    assert_equal(plan.command.kind, KIND_HELP)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
