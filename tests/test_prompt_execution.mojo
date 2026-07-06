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

def _has_substring(values: List[String], needle: String) -> Bool:
    for index in range(len(values)):
        if needle in values[index]:
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



def test_prompt_execution_table_ownership_plans_table_branch() raises:
    var catalog = _catalog()
    var routing = plan_prompt_execution_routing(
        "r mond 2 --art=csv --nocolor", "deutsch", catalog
    )
    var ownership = plan_prompt_execution_table_ownership(
        routing, "deutsch", catalog
    )
    assert_true(ownership.table_candidate)
    assert_true(ownership.owns_table)
    assert_false(ownership.fallback_required)
    assert_true(ownership.table_plan.handled)


def test_prompt_execution_table_ownership_plans_numeric_mulpri() raises:
    var catalog = _catalog()
    var routing = plan_prompt_execution_routing("15", "deutsch", catalog)
    var ownership = plan_prompt_execution_table_ownership(
        routing, "deutsch", catalog
    )
    assert_true(ownership.mulpri_candidate)
    assert_true(ownership.owns_mulpri)
    assert_false(ownership.fallback_required)
    assert_true(len(ownership.integer_arguments) >= 1)


def test_prompt_execution_compact_announcement_tokens_add_mulpri_companions() raises:
    var catalog = _catalog()
    var routing = plan_prompt_execution_routing("15", "deutsch", catalog)
    var visible = prompt_execution_compact_announcement_tokens(
        routing.prepared_tokens, "deutsch", catalog
    )
    assert_true(_has_token(visible, "multis"))
    assert_true(_has_token(visible, "prim"))
    assert_true(_has_token(visible, "primfaktorenvergleich"))


def test_prompt_execution_compact_announcement_plan_owns_line() raises:
    var catalog = _catalog()
    var routing = plan_prompt_execution_routing("a1", "deutsch", catalog)
    var announcement = plan_prompt_execution_compact_announcement(
        routing, "a1", "deutsch", catalog
    )
    assert_true(announcement.should_print)
    assert_true(_has_token(announcement.visible_tokens, "absicht"))
    assert_true(_has_token(announcement.visible_tokens, "1"))
    assert_true("ergibt sich aus 'a1'" in announcement.line)
    assert_true(announcement.line.endswith("\n"))


def test_prompt_execution_compact_announcement_plan_respects_quiet() raises:
    var catalog = _catalog()
    var visible_routing = plan_prompt_execution_routing("a1", "deutsch", catalog)
    var quiet_routing = plan_prompt_execution_routing("15", "deutsch", catalog)
    var visible = plan_prompt_execution_compact_announcement(
        visible_routing, "a1", "deutsch", catalog
    )
    var hidden = plan_prompt_execution_compact_announcement(
        quiet_routing, "15", "deutsch", catalog
    )
    assert_true(visible.should_print)
    assert_true(quiet_routing.quiet_echo)
    assert_false(hidden.should_print)
    assert_equal(hidden.line, "")
    assert_equal(len(hidden.visible_tokens), 0)



def test_prompt_execution_historical_effect_plan_owns_companions_and_logging() raises:
    var catalog = _catalog()
    var routing = plan_prompt_execution_routing(
        "mond 2 kurzbefehle befehle h leeren loggen --art=csv",
        "deutsch",
        catalog,
    )
    var effects = plan_prompt_execution_historical_effects(
        routing, "deutsch", catalog
    )
    assert_true(effects.show_short_commands)
    assert_true(effects.show_commands)
    assert_true(effects.show_help)
    assert_true(effects.clear_before_table)
    assert_true(effects.enable_logging)
    assert_false(effects.disable_logging)


def test_prompt_execution_historical_effect_plan_keeps_disable_logging() raises:
    var catalog = _catalog()
    var routing = plan_prompt_execution_routing(
        "mond 2 nichtloggen --art=csv", "deutsch", catalog
    )
    var effects = plan_prompt_execution_historical_effects(
        routing, "deutsch", catalog
    )
    assert_false(effects.enable_logging)
    assert_true(effects.disable_logging)



def test_prompt_execution_mulpri_render_plan_owns_prime_and_multis_lines() raises:
    var catalog = _catalog()
    # A prime number exercises both native prime-factor output and an
    # additional multis line.  Composite 15 only prints factor pairs and is
    # not a stable proof that the prime path was reached.
    var routing = plan_prompt_execution_routing("p 17", "deutsch", catalog)
    var plan = plan_prompt_execution_mulpri_render(
        routing.planning_tokens, "deutsch", catalog
    )
    assert_true(plan.handled)
    assert_true(len(plan.output_lines) > 0)
    assert_true(_has_substring(plan.output_lines, "17"))
    assert_true(len(plan.output_lines) >= 2)


def test_prompt_execution_mulpri_render_plan_rejects_non_mulpri() raises:
    var catalog = _catalog()
    var routing = plan_prompt_execution_routing("mond 2", "deutsch", catalog)
    var plan = plan_prompt_execution_mulpri_render(
        routing.planning_tokens, "deutsch", catalog
    )
    assert_false(plan.handled)
    assert_equal(len(plan.output_lines), 0)


def test_prompt_execution_native_branch_outcome_owns_logging_transition() raises:
    var catalog = _catalog()
    var routing = plan_prompt_execution_routing(
        "mond 2 loggen --art=csv", "deutsch", catalog
    )
    var branch = plan_prompt_execution_native_branch(
        routing, "mond 2 loggen --art=csv", "deutsch", catalog
    )
    var outcome = plan_prompt_execution_native_branch_outcome(branch, True)
    assert_true(outcome.handled)
    assert_true(outcome.enable_logging)
    assert_false(outcome.disable_logging)
    assert_false(outcome.fallback_required)



def test_prompt_execution_native_branch_outcome_owns_untried_fallback() raises:
    var catalog = _catalog()
    var routing = plan_prompt_execution_routing(
        "richtung shell echo 2", "deutsch", catalog
    )
    var branch = plan_prompt_execution_native_branch(
        routing, "richtung shell echo 2", "deutsch", catalog
    )
    var outcome = plan_prompt_execution_native_branch_outcome(branch, False)
    assert_false(branch.should_try_native)
    assert_true(outcome.fallback_required)
    assert_false(outcome.handled)
    assert_false(outcome.enable_logging)
    assert_false(outcome.disable_logging)

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
