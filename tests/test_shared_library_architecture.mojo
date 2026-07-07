from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.shared_library_architecture import *


def test_shared_library_plan_matches_requested_split() raises:
    var plan = plan_shared_library_architecture()
    assert_true(shared_library_architecture_valid(plan))
    assert_equal(len(plan.libraries), 3)
    assert_equal(plan.core_library, "libreta-core")
    assert_equal(plan.prompt_library, "libreta-prompt")
    assert_equal(plan.prompt_interactive_library, "libreta-prompt-interactive")
    assert_false(plan.rpb_uses_interactive_library)
    assert_equal(plan.thin_starter_count, 6)


def test_rpb_is_one_shot_without_interactive_input_library() raises:
    var starters = load_thin_starter_targets()
    var found = False
    for index in range(len(starters)):
        if starters[index].starter_name == "rpb":
            found = True
            assert_false(starters[index].interactive)
            assert_equal(len(starters[index].libraries), 2)
            assert_equal(starters[index].libraries[0], "libreta-prompt")
            assert_equal(starters[index].libraries[1], "libreta-core")
    assert_true(found)


def test_interactive_prompt_starters_share_interactive_library() raises:
    var starters = load_thin_starter_targets()
    var interactive_count = 0
    for index in range(len(starters)):
        if starters[index].interactive:
            interactive_count += 1
            assert_equal(starters[index].libraries[0], "libreta-prompt-interactive")
            assert_equal(starters[index].libraries[1], "libreta-prompt")
            assert_equal(starters[index].libraries[2], "libreta-core")
    assert_equal(interactive_count, 3)


def test_core_library_is_shared_by_reta_prompts_and_grundstrukhtml() raises:
    var targets = load_shared_library_targets()
    var found_core = False
    for index in range(len(targets)):
        if targets[index].logical_name == "libreta-core":
            found_core = True
            assert_equal(targets[index].elf_name, "libreta-core.so")
            assert_equal(targets[index].dll_name, "libreta-core.dll")
            assert_equal(len(targets[index].consumers), 6)
            assert_equal(targets[index].consumers[0], "reta")
            assert_equal(targets[index].consumers[1], "rp")
            assert_equal(targets[index].consumers[2], "rpl")
            assert_equal(targets[index].consumers[3], "rpe")
            assert_equal(targets[index].consumers[4], "rpb")
            assert_equal(targets[index].consumers[5], "grundStrukHtml")
    assert_true(found_core)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
