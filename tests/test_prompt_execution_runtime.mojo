from std.collections import List
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.prompt_execution_runtime import *
from reta_mojo.prompt_table_execution import (
    PromptTableInvocation,
    PromptTablePlan,
)


def test_command_echo_is_typed_and_has_no_terminal_effect() raises:
    var tokens: List[String] = ["-zeilen", "--alles"]
    assert_equal(
        prompt_table_command_echo(tokens),
        "reta -zeilen --alles",
    )
    assert_equal(
        prompt_table_command_echo(List[String]()),
        "",
    )


def test_empty_handled_plan_is_a_successful_noop() raises:
    var result = render_prompt_table_plan(
        PromptTablePlan(True, List[PromptTableInvocation]()),
        "unused.csv",
    )
    assert_true(result.handled)
    assert_equal(len(result.invocations), 0)


def test_unhandled_or_invalid_plan_is_rejected_transactionally() raises:
    var unhandled = render_prompt_table_plan(
        PromptTablePlan(False, List[PromptTableInvocation]()),
        "unused.csv",
    )
    assert_false(unhandled.handled)

    var invocations = List[PromptTableInvocation]()
    invocations.append(
        PromptTableInvocation(List[String](), False)
    )
    var invalid = render_prompt_table_plan(
        PromptTablePlan(True, invocations^),
        "unused.csv",
    )
    assert_false(invalid.handled)
    assert_equal(len(invalid.invocations), 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
