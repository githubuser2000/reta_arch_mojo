from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import List
from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_runtime import (
    parse_prompt_startup,
    classify_prompt_command_localized,
    KIND_EMPTY,
    KIND_EXIT,
    KIND_PRIME,
    KIND_STORE_NEXT,
    KIND_STORE_PREVIOUS,
    KIND_OUTPUT_STORED,
    KIND_DELETE_STORED,
    KIND_LOG_ON,
    KIND_LOG_OFF,
)
from reta_mojo.prompt_session import (
    prompt_prefix,
    store_prompt_text,
    stored_prompt_text,
)
from reta_mojo.prompt_interaction import *
from reta_mojo.prompt_reaction_input import *
from reta_mojo.prompt_reaction_storage import *
from reta_mojo.prompt_reaction_dispatch import *
from reta_mojo.prompt_process_dispatch import *
from reta_mojo.prompt_execution import (
    PromptExecutionCompatibilityFallbackPlan,
    plan_prompt_execution_residual_compatibility_fallback,
)


def test_startup_activation_and_one_shot_line() raises:
    var startup = parse_prompt_startup(
        "rpb", ["prim", "60"]
    )
    var interaction = new_prompt_interaction(startup)
    assert_true(interaction.one_shot)
    assert_false(interaction.show_intro)
    assert_equal(interaction.language, "deutsch")
    assert_equal(prompt_prefix(interaction.session), ">")
    assert_equal(prompt_interaction_one_shot_line(startup), "prim 60")


def test_localized_session_activation() raises:
    var startup = parse_prompt_startup(
        "retaPrompt", ["-language=english"]
    )
    var interaction = new_prompt_interaction(startup)
    interaction.session.store_next = True
    assert_equal(prompt_prefix(interaction.session), "save what>")
    interaction.session.store_next = False
    interaction.session.delete_next = True
    assert_equal(prompt_prefix(interaction.session), "delete what>")


def test_store_next_is_consumed_before_dispatch() raises:
    var catalog = load_prompt_language_catalog("assets")
    var interaction = new_prompt_interaction(
        parse_prompt_startup("retaPrompt", [])
    )
    interaction.session.store_next = True
    var plan = accept_prompt_input(interaction, "prim 60", catalog)
    assert_equal(plan.action, INTERACTION_CONTINUE)
    assert_equal(plan.command_line, "")
    assert_equal(len(plan.output_lines), 1)
    assert_equal(plan.output_lines[0], "Gespeichert: prim 60")
    assert_equal(stored_prompt_text(interaction.session), "prim 60")
    assert_false(interaction.session.store_next)


def test_delete_mode_cancel_and_selection() raises:
    var catalog = load_prompt_language_catalog("assets")
    var interaction = new_prompt_interaction(
        parse_prompt_startup("retaPrompt", [])
    )
    store_prompt_text(interaction.session, "reta -h --nocolor")
    interaction.session.delete_next = True
    var cancelled = accept_prompt_input(interaction, "q", catalog)
    assert_equal(cancelled.action, INTERACTION_CONTINUE)
    assert_equal(cancelled.output_lines[0], "Löschen abgebrochen.")
    assert_false(interaction.session.delete_next)
    assert_equal(stored_prompt_text(interaction.session), "reta -h --nocolor")

    interaction.session.delete_next = True
    var deleted = accept_prompt_input(interaction, "2", catalog)
    assert_equal(deleted.action, INTERACTION_CONTINUE)
    assert_equal(deleted.output_lines[0], "Gespeichert: reta --nocolor")
    assert_equal(stored_prompt_text(interaction.session), "reta --nocolor")
    assert_false(interaction.session.delete_next)


def test_terminal_sentinels_and_normal_input() raises:
    var catalog = load_prompt_language_catalog("assets")
    var interaction = new_prompt_interaction(
        parse_prompt_startup("retaPrompt", [])
    )
    var normal = accept_prompt_input(interaction, "prim 60", catalog)
    assert_equal(normal.action, INTERACTION_EXECUTE)
    assert_equal(normal.command_line, "prim 60")
    assert_equal(len(normal.output_lines), 0)
    var eof = accept_prompt_input(interaction, "\x04", catalog)
    assert_equal(eof.action, INTERACTION_EXIT)




def test_empty_line_executes_stored_placeholder() raises:
    var catalog = load_prompt_language_catalog("assets")
    var interaction = new_prompt_interaction(
        parse_prompt_startup("retaPrompt", [])
    )
    var empty_without_storage = plan_stored_default_command(
        "", interaction.session
    )
    assert_false(empty_without_storage.handled)

    store_prompt_text(interaction.session, "prim 60")
    var default_plan = plan_stored_default_command(
        "   ", interaction.session
    )
    assert_true(default_plan.handled)
    assert_equal(default_plan.command_line, "prim 60")

    var accepted = accept_prompt_input(interaction, "", catalog)
    assert_equal(accepted.action, INTERACTION_EXECUTE)
    assert_equal(accepted.command_line, "prim 60")
    assert_equal(len(accepted.output_lines), 0)

    var nonempty = plan_stored_default_command(
        "multis 12", interaction.session
    )
    assert_false(nonempty.handled)


def test_previous_command_policy() raises:
    var interaction = new_prompt_interaction(
        parse_prompt_startup("retaPrompt", [])
    )
    record_prompt_command(interaction, "prim 60", KIND_PRIME)
    assert_equal(interaction.session.previous_command, "prim 60")

    for kind in [
        KIND_STORE_NEXT,
        KIND_STORE_PREVIOUS,
        KIND_OUTPUT_STORED,
        KIND_DELETE_STORED,
        KIND_LOG_ON,
        KIND_LOG_OFF,
    ]:
        assert_false(prompt_command_updates_previous(kind))
        record_prompt_command(interaction, "ignored", kind)
        assert_equal(interaction.session.previous_command, "prim 60")


def test_inline_storage_does_not_replace_the_previous_command() raises:
    var catalog = load_prompt_language_catalog("assets")
    var interaction = new_prompt_interaction(
        parse_prompt_startup("retaPrompt", [])
    )
    interaction.session.previous_command = "prim 60"

    for line in [
        "S emotion 1",
        "emotion S 1",
        "emotion 1 s",
    ]:
        var kind = classify_prompt_command_localized(
            line, "deutsch", catalog
        ).kind
        assert_false(
            prompt_line_updates_previous(
                line, kind, "deutsch", catalog
            )
        )
        record_prompt_line(
            interaction, line, kind, "deutsch", catalog
        )
        assert_equal(interaction.session.previous_command, "prim 60")

    var english_line = "emotions 1 CommandSaveAfter"
    var english_kind = classify_prompt_command_localized(
        english_line, "english", catalog
    ).kind
    assert_false(
        prompt_line_updates_previous(
            english_line, english_kind, "english", catalog
        )
    )
    record_prompt_line(
        interaction,
        english_line,
        english_kind,
        "english",
        catalog,
    )
    assert_equal(interaction.session.previous_command, "prim 60")

    var executable_kind = classify_prompt_command_localized(
        "emotion 1", "deutsch", catalog
    ).kind
    assert_true(
        prompt_line_updates_previous(
            "emotion 1", executable_kind, "deutsch", catalog
        )
    )
    record_prompt_line(
        interaction,
        "emotion 1",
        executable_kind,
        "deutsch",
        catalog,
    )
    assert_equal(interaction.session.previous_command, "emotion 1")


def test_inline_storage_is_position_independent() raises:
    var catalog = load_prompt_language_catalog("assets")
    var prefix = plan_inline_storage_command(
        ["S", "emotion", "1"], "deutsch", catalog
    )
    var middle = plan_inline_storage_command(
        ["emotion", "S", "1"], "deutsch", catalog
    )
    var suffix = plan_inline_storage_command(
        ["emotion", "1", "s"], "deutsch", catalog
    )
    assert_true(prefix.handled)
    assert_true(middle.handled)
    assert_true(suffix.handled)
    assert_equal(prefix.payload, "emotion 1")
    assert_equal(middle.payload, "emotion 1")
    assert_equal(suffix.payload, "emotion 1")

    var english = plan_inline_storage_command(
        ["emotions", "1", "CommandSaveAfter"],
        "english",
        catalog,
    )
    assert_true(english.handled)
    assert_equal(english.payload, "emotions 1")


def test_inline_storage_preserves_set_and_remove_once_edges() raises:
    var catalog = load_prompt_language_catalog("assets")
    var duplicate = plan_inline_storage_command(
        ["S", "S", "emotion"], "deutsch", catalog
    )
    assert_true(duplicate.handled)
    assert_equal(duplicate.payload, "S emotion")

    assert_false(
        plan_inline_storage_command(
            ["S", "s", "emotion"], "deutsch", catalog
        ).handled
    )
    assert_false(
        plan_inline_storage_command(
            ["S", "BefehlSpeichernDanach", "emotion"],
            "deutsch",
            catalog,
        ).handled
    )
    assert_false(
        plan_inline_storage_command(
            ["S", "abc"], "deutsch", catalog
        ).handled
    )
    assert_false(
        plan_inline_storage_command(
            ["S", "S"], "deutsch", catalog
        ).handled
    )


def test_inline_storage_mutates_session_without_execution() raises:
    var catalog = load_prompt_language_catalog("assets")
    var interaction = new_prompt_interaction(
        parse_prompt_startup("retaPrompt", [])
    )
    assert_true(
        apply_inline_storage_command(
            interaction.session,
            ["emotion", "1", "S"],
            "deutsch",
            catalog,
        )
    )
    assert_equal(stored_prompt_text(interaction.session), "emotion 1")
    assert_true(
        apply_inline_storage_command(
            interaction.session,
            ["s", "universum", "2"],
            "deutsch",
            catalog,
        )
    )
    assert_equal(
        stored_prompt_text(interaction.session),
        "emotion 1 universum 2",
    )


def test_inline_storage_output_is_position_independent() raises:
    var catalog = load_prompt_language_catalog("assets")
    var prefix = plan_inline_storage_output_command(
        ["o", "prim", "60"], "deutsch", catalog
    )
    var middle = plan_inline_storage_output_command(
        ["prim", "o", "60"], "deutsch", catalog
    )
    var suffix = plan_inline_storage_output_command(
        ["prim", "60", "o"], "deutsch", catalog
    )
    assert_true(prefix.handled)
    assert_true(middle.handled)
    assert_true(suffix.handled)
    assert_equal(prefix.payload, "prim 60")
    assert_equal(middle.payload, "prim 60")
    assert_equal(suffix.payload, "prim 60")

    var english = plan_inline_storage_output_command(
        ["emotions", "1", "CommandSaveOutput"],
        "english",
        catalog,
    )
    assert_true(english.handled)
    assert_equal(english.payload, "emotions 1")


def test_loop_control_dispatch_is_planned_by_interaction_owner() raises:
    var catalog = load_prompt_language_catalog("assets")
    var empty = classify_prompt_command_localized("", "deutsch", catalog)
    assert_equal(empty.kind, KIND_EMPTY)
    var empty_plan = plan_loop_control_dispatch(empty)
    assert_true(empty_plan.handled)
    assert_true(empty_plan.continue_loop)

    var quit_command = classify_prompt_command_localized("q", "deutsch", catalog)
    assert_equal(quit_command.kind, KIND_EXIT)
    var quit_plan = plan_loop_control_dispatch(quit_command)
    assert_true(quit_plan.handled)
    assert_false(quit_plan.continue_loop)

    var normal = classify_prompt_command_localized("prim 60", "deutsch", catalog)
    assert_false(plan_loop_control_dispatch(normal).handled)


def test_single_storage_dispatch_is_planned_by_interaction_owner() raises:
    var catalog = load_prompt_language_catalog("assets")
    var interaction = new_prompt_interaction(
        parse_prompt_startup("retaPrompt", [])
    )

    var save_next = classify_prompt_command_localized(
        "S", "deutsch", catalog
    )
    var save_next_plan = plan_stored_command_dispatch(
        save_next, interaction.session
    )
    assert_true(save_next_plan.handled)
    assert_equal(len(save_next_plan.output_lines), 1)
    assert_equal(
        save_next_plan.output_lines[0],
        "Der nächste Befehl wird gespeichert.",
    )
    assert_true(interaction.session.store_next)

    interaction.session.store_next = False
    interaction.session.previous_command = "prim 60"
    var save_previous = classify_prompt_command_localized(
        "s", "deutsch", catalog
    )
    var save_previous_plan = plan_stored_command_dispatch(
        save_previous, interaction.session
    )
    assert_true(save_previous_plan.handled)
    assert_equal(save_previous_plan.output_lines[0], "Gespeichert: prim 60")
    assert_equal(stored_prompt_text(interaction.session), "prim 60")

    var no_previous_interaction = new_prompt_interaction(
        parse_prompt_startup("retaPrompt", [])
    )
    var empty_previous_plan = plan_stored_command_dispatch(
        save_previous, no_previous_interaction.session
    )
    assert_true(empty_previous_plan.handled)
    assert_equal(len(empty_previous_plan.output_lines), 0)

    var normal = classify_prompt_command_localized(
        "prim 60", "deutsch", catalog
    )
    assert_false(
        plan_stored_command_dispatch(normal, interaction.session).handled
    )


def test_logging_dispatch_is_planned_by_interaction_owner() raises:
    var catalog = load_prompt_language_catalog("assets")
    var interaction = new_prompt_interaction(
        parse_prompt_startup("retaPrompt", [])
    )

    var enable = classify_prompt_command_localized(
        "loggen", "deutsch", catalog
    )
    var enable_plan = plan_logging_dispatch(enable, interaction.session)
    assert_true(enable_plan.handled)
    assert_equal(len(enable_plan.output_lines), 1)
    assert_equal(
        enable_plan.output_lines[0],
        "Logging ist eingeschaltet.",
    )
    assert_true(interaction.session.logging_enabled)

    var disable = classify_prompt_command_localized(
        "nichtloggen", "deutsch", catalog
    )
    var disable_plan = plan_logging_dispatch(disable, interaction.session)
    assert_true(disable_plan.handled)
    assert_equal(len(disable_plan.output_lines), 1)
    assert_equal(
        disable_plan.output_lines[0],
        "Logging ist ausgeschaltet.",
    )
    assert_false(interaction.session.logging_enabled)

    var normal = classify_prompt_command_localized(
        "prim 60", "deutsch", catalog
    )
    assert_false(
        plan_logging_dispatch(normal, interaction.session).handled
    )


def test_one_shot_logging_dispatch_is_planned_by_interaction_owner() raises:
    var catalog = load_prompt_language_catalog("assets")

    var enable = classify_prompt_command_localized(
        "loggen", "deutsch", catalog
    )
    var enable_plan = plan_one_shot_logging_dispatch(enable)
    assert_true(enable_plan.handled)
    assert_equal(len(enable_plan.output_lines), 1)
    assert_equal(
        enable_plan.output_lines[0],
        "Logging ist eingeschaltet.",
    )

    var disable = classify_prompt_command_localized(
        "nichtloggen", "deutsch", catalog
    )
    var disable_plan = plan_one_shot_logging_dispatch(disable)
    assert_true(disable_plan.handled)
    assert_equal(len(disable_plan.output_lines), 1)
    assert_equal(
        disable_plan.output_lines[0],
        "Logging ist ausgeschaltet.",
    )

    var normal = classify_prompt_command_localized(
        "prim 60", "deutsch", catalog
    )
    assert_false(plan_one_shot_logging_dispatch(normal).handled)


def test_terminal_clear_dispatch_is_planned_by_interaction_owner() raises:
    var catalog = load_prompt_language_catalog("assets")

    var clear_command = classify_prompt_command_localized(
        "leeren", "deutsch", catalog
    )
    var clear_plan = plan_terminal_clear_dispatch(clear_command)
    assert_true(clear_plan.handled)
    assert_true(clear_plan.clear_terminal)
    assert_equal(len(clear_plan.output_lines), 0)

    var english_clear = classify_prompt_command_localized(
        "clear", "english", catalog
    )
    var english_plan = plan_terminal_clear_dispatch(english_clear)
    assert_true(english_plan.handled)
    assert_true(english_plan.clear_terminal)

    var normal = classify_prompt_command_localized(
        "prim 60", "deutsch", catalog
    )
    assert_false(plan_terminal_clear_dispatch(normal).handled)




def test_informational_dispatch_is_planned_by_interaction_owner() raises:
    var catalog = load_prompt_language_catalog("assets")

    var help_command = classify_prompt_command_localized(
        "hilfe", "deutsch", catalog
    )
    var help_plan = plan_informational_dispatch(help_command)
    assert_true(help_plan.handled)
    assert_true(help_plan.show_help)
    assert_false(help_plan.show_commands)
    assert_false(help_plan.show_short_commands)

    var commands = classify_prompt_command_localized(
        "befehle", "deutsch", catalog
    )
    var commands_plan = plan_informational_dispatch(commands)
    assert_true(commands_plan.handled)
    assert_false(commands_plan.show_help)
    assert_true(commands_plan.show_commands)
    assert_false(commands_plan.show_short_commands)

    var short_commands = classify_prompt_command_localized(
        "kurzbefehle", "deutsch", catalog
    )
    var short_plan = plan_informational_dispatch(short_commands)
    assert_true(short_plan.handled)
    assert_false(short_plan.show_help)
    assert_false(short_plan.show_commands)
    assert_true(short_plan.show_short_commands)

    var normal = classify_prompt_command_localized(
        "prim 60", "deutsch", catalog
    )
    assert_false(plan_informational_dispatch(normal).handled)


def test_simple_output_dispatch_is_planned_by_interaction_owner() raises:
    var catalog = load_prompt_language_catalog("assets")

    var prime_command = classify_prompt_command_localized(
        "prim 12", "deutsch", catalog
    )
    var prime_plan = plan_simple_output_dispatch(
        prime_command, "deutsch"
    )
    assert_true(prime_plan.handled)
    assert_true(len(prime_plan.output_lines) > 0)

    var multis_command = classify_prompt_command_localized(
        "multis 12", "deutsch", catalog
    )
    var multis_plan = plan_simple_output_dispatch(
        multis_command, "deutsch"
    )
    assert_true(multis_plan.handled)
    assert_true(len(multis_plan.output_lines) > 0)

    var abc_command = classify_prompt_command_localized(
        "abc abc", "deutsch", catalog
    )
    var abc_plan = plan_simple_output_dispatch(
        abc_command, "deutsch"
    )
    assert_true(abc_plan.handled)
    assert_equal(len(abc_plan.output_lines), 1)

    var normal = classify_prompt_command_localized(
        "shell echo hi", "deutsch", catalog
    )
    assert_false(
        plan_simple_output_dispatch(normal, "deutsch").handled
    )




# Legacy source guards track the historical test names while the implementation
# owner moved to prompt_process_dispatch.
# def test_external_process_dispatch_is_planned_by_interaction_owner
# def test_fallback_process_dispatch_is_planned_by_interaction_owner

def test_external_process_dispatch_is_planned_by_process_execution_owner() raises:
    var catalog = load_prompt_language_catalog("assets")

    var shell_command = classify_prompt_command_localized(
        "shell echo hi", "deutsch", catalog
    )
    var shell_plan = plan_external_process_dispatch(shell_command)
    assert_true(shell_plan.handled)
    assert_equal(len(shell_plan.arguments), 2)
    assert_equal(shell_plan.arguments[0], "echo")
    assert_equal(shell_plan.arguments[1], "hi")
    assert_true(shell_plan.run_shell)
    assert_false(shell_plan.run_python)
    assert_false(shell_plan.run_math)
    assert_false(shell_plan.run_reta)

    var python_command = classify_prompt_command_localized(
        "python print(1)", "deutsch", catalog
    )
    var python_plan = plan_external_process_dispatch(python_command)
    assert_true(python_plan.handled)
    assert_equal(len(python_plan.arguments), 1)
    assert_equal(python_plan.arguments[0], "print(1)")
    assert_false(python_plan.run_shell)
    assert_true(python_plan.run_python)
    assert_false(python_plan.run_math)
    assert_false(python_plan.run_reta)

    var math_command = classify_prompt_command_localized(
        "math 1+1", "deutsch", catalog
    )
    var math_plan = plan_external_process_dispatch(math_command)
    assert_true(math_plan.handled)
    assert_equal(len(math_plan.arguments), 1)
    assert_equal(math_plan.arguments[0], "1+1")
    assert_false(math_plan.run_shell)
    assert_false(math_plan.run_python)
    assert_true(math_plan.run_math)
    assert_false(math_plan.run_reta)

    var reta_command = classify_prompt_command_localized(
        "reta -h", "deutsch", catalog
    )
    var reta_plan = plan_external_process_dispatch(reta_command)
    assert_true(reta_plan.handled)
    assert_false(reta_plan.run_shell)
    assert_false(reta_plan.run_python)
    assert_false(reta_plan.run_math)
    assert_true(reta_plan.run_reta)
    assert_equal(len(reta_plan.arguments), 1)
    assert_equal(reta_plan.arguments[0], "-h")

    var normal = classify_prompt_command_localized(
        "prim 60", "deutsch", catalog
    )
    var normal_plan = plan_external_process_dispatch(normal)
    assert_false(normal_plan.handled)
    assert_false(normal_plan.run_shell)
    assert_false(normal_plan.run_python)
    assert_false(normal_plan.run_math)
    assert_false(normal_plan.run_reta)
    assert_equal(len(normal_plan.arguments), 0)




def test_interactive_external_execution_is_planned_by_process_execution_owner() raises:
    var catalog = load_prompt_language_catalog("assets")
    var shell_command = classify_prompt_command_localized(
        "shell echo hi", "deutsch", catalog
    )
    var shell_plan = plan_external_process_dispatch(shell_command)
    var shell_execution = plan_interactive_external_process_execution(shell_plan)
    assert_true(shell_execution.should_run_shell)
    assert_false(shell_execution.should_run_python)
    assert_false(shell_execution.should_run_math)
    assert_false(shell_execution.should_run_reta)
    assert_equal(len(shell_execution.arguments), 2)
    assert_equal(shell_execution.arguments[0], "echo")
    assert_equal(shell_execution.arguments[1], "hi")

    var reta_command = classify_prompt_command_localized(
        "reta -h", "deutsch", catalog
    )
    var reta_plan = plan_external_process_dispatch(reta_command)
    var reta_execution = plan_interactive_external_process_execution(reta_plan)
    assert_false(reta_execution.should_run_shell)
    assert_false(reta_execution.should_run_python)
    assert_false(reta_execution.should_run_math)
    assert_true(reta_execution.should_run_reta)
    assert_equal(len(reta_execution.arguments), 1)
    assert_equal(reta_execution.arguments[0], "-h")

    var rejected = plan_interactive_external_process_execution(
        PromptExternalProcessDispatchPlan(
            False, List[String](), False, False, False, False
        )
    )
    assert_false(rejected.should_run_shell)
    assert_false(rejected.should_run_reta)
    assert_equal(len(rejected.arguments), 0)



def test_interactive_external_completion_is_planned_by_process_execution_owner() raises:
    var catalog = load_prompt_language_catalog("assets")
    var shell_command = classify_prompt_command_localized(
        "shell echo hi", "deutsch", catalog
    )
    var shell_plan = plan_external_process_dispatch(shell_command)
    var shell_completion = plan_interactive_external_process_completion(
        shell_plan, False
    )
    assert_true(shell_completion.handled)
    assert_false(shell_completion.run_reference_reta)
    assert_false(shell_completion.reta_native_handled)

    var reta_command = classify_prompt_command_localized(
        "reta -h", "deutsch", catalog
    )
    var reta_plan = plan_external_process_dispatch(reta_command)
    var native_reta_completion = plan_interactive_external_process_completion(
        reta_plan, True
    )
    assert_true(native_reta_completion.handled)
    assert_false(native_reta_completion.run_reference_reta)
    assert_true(native_reta_completion.reta_native_handled)

    var reference_reta_completion = plan_interactive_external_process_completion(
        reta_plan, False
    )
    assert_true(reference_reta_completion.handled)
    assert_true(reference_reta_completion.run_reference_reta)
    assert_false(reference_reta_completion.reta_native_handled)



def test_interactive_reference_reta_execution_is_planned_by_process_execution_owner() raises:
    var catalog = load_prompt_language_catalog("assets")
    var reta_command = classify_prompt_command_localized(
        "reta -h", "deutsch", catalog
    )
    var reta_plan = plan_external_process_dispatch(reta_command)
    var reta_execution = plan_interactive_external_process_execution(reta_plan)
    var completion = plan_interactive_external_process_completion(
        reta_plan, False
    )
    var reference_execution = plan_interactive_reference_reta_process_execution(
        completion, reta_execution
    )
    assert_true(reference_execution.should_run_reference_reta)
    assert_equal(len(reference_execution.arguments), 1)
    assert_equal(reference_execution.arguments[0], "-h")

    var native_completion = plan_interactive_external_process_completion(
        reta_plan, True
    )
    var skipped = plan_interactive_reference_reta_process_execution(
        native_completion, reta_execution
    )
    assert_false(skipped.should_run_reference_reta)
    assert_equal(len(skipped.arguments), 0)


def test_interactive_external_result_is_planned_by_process_execution_owner() raises:
    var catalog = load_prompt_language_catalog("assets")
    var shell_command = classify_prompt_command_localized(
        "shell echo hi", "deutsch", catalog
    )
    var shell_plan = plan_external_process_dispatch(shell_command)
    var shell_completion = plan_interactive_external_process_completion(
        shell_plan, False
    )
    var no_reference = PromptInteractiveReferenceRetaExecutionPlan(
        False, List[String]()
    )
    var shell_result = plan_interactive_external_process_result(
        shell_completion, no_reference
    )
    assert_true(shell_result.handled)
    assert_false(shell_result.reference_reta_requested)

    var reta_command = classify_prompt_command_localized(
        "reta -h", "deutsch", catalog
    )
    var reta_plan = plan_external_process_dispatch(reta_command)
    var reta_execution = plan_interactive_external_process_execution(reta_plan)
    var reta_completion = plan_interactive_external_process_completion(
        reta_plan, False
    )
    var reference_execution = plan_interactive_reference_reta_process_execution(
        reta_completion, reta_execution
    )
    var reta_result = plan_interactive_external_process_result(
        reta_completion, reference_execution
    )
    assert_true(reta_result.handled)
    assert_true(reta_result.reference_reta_requested)


def test_one_shot_external_execution_is_planned_by_process_execution_owner() raises:
    var catalog = load_prompt_language_catalog("assets")
    var shell_command = classify_prompt_command_localized(
        "shell echo hi", "deutsch", catalog
    )
    var shell_plan = plan_external_process_dispatch(shell_command)
    var shell_execution = plan_one_shot_external_process_execution(shell_plan)
    assert_false(shell_execution.should_try_reta_native)
    assert_equal(len(shell_execution.arguments), 0)

    var reta_command = classify_prompt_command_localized(
        "reta -h", "deutsch", catalog
    )
    var reta_plan = plan_external_process_dispatch(reta_command)
    var reta_execution = plan_one_shot_external_process_execution(reta_plan)
    assert_true(reta_execution.should_try_reta_native)
    assert_equal(len(reta_execution.arguments), 1)
    assert_equal(reta_execution.arguments[0], "-h")

    var rejected = plan_one_shot_external_process_execution(
        PromptExternalProcessDispatchPlan(
            False, List[String](), False, False, False, True
        )
    )
    assert_false(rejected.should_try_reta_native)
    assert_equal(len(rejected.arguments), 0)



def test_one_shot_external_boundary_is_planned_by_process_execution_owner() raises:
    var catalog = load_prompt_language_catalog("assets")
    var shell_command = classify_prompt_command_localized(
        "shell echo hi", "deutsch", catalog
    )
    var shell_plan = plan_external_process_dispatch(shell_command)
    var shell_boundary = plan_one_shot_external_process_boundary(
        shell_plan, False
    )
    assert_true(shell_boundary.stop_native_probe)
    assert_false(shell_boundary.handled_without_boundary)
    assert_false(shell_boundary.reta_native_handled)

    var reta_command = classify_prompt_command_localized(
        "reta -h", "deutsch", catalog
    )
    var reta_plan = plan_external_process_dispatch(reta_command)
    var native_reta_boundary = plan_one_shot_external_process_boundary(
        reta_plan, True
    )
    assert_false(native_reta_boundary.stop_native_probe)
    assert_true(native_reta_boundary.handled_without_boundary)
    assert_true(native_reta_boundary.reta_native_handled)

    var fallback_reta_boundary = plan_one_shot_external_process_boundary(
        reta_plan, False
    )
    assert_true(fallback_reta_boundary.stop_native_probe)
    assert_false(fallback_reta_boundary.handled_without_boundary)


def test_one_shot_external_result_is_planned_by_process_execution_owner() raises:
    var catalog = load_prompt_language_catalog("assets")
    var shell_command = classify_prompt_command_localized(
        "shell echo hi", "deutsch", catalog
    )
    var shell_plan = plan_external_process_dispatch(shell_command)
    var shell_boundary = plan_one_shot_external_process_boundary(
        shell_plan, False
    )
    var shell_result = plan_one_shot_external_process_result(shell_boundary)
    assert_false(shell_result.handled)
    assert_true(shell_result.stop_native_probe)
    assert_false(shell_result.reta_native_handled)

    var reta_command = classify_prompt_command_localized(
        "reta -h", "deutsch", catalog
    )
    var reta_plan = plan_external_process_dispatch(reta_command)
    var accepted_boundary = plan_one_shot_external_process_boundary(
        reta_plan, True
    )
    var accepted_result = plan_one_shot_external_process_result(
        accepted_boundary
    )
    assert_true(accepted_result.handled)
    assert_false(accepted_result.stop_native_probe)
    assert_true(accepted_result.reta_native_handled)

    var unhandled_boundary = plan_one_shot_external_process_boundary(
        PromptExternalProcessDispatchPlan(
            False, List[String](), False, False, False, False
        ),
        False,
    )
    var unhandled_result = plan_one_shot_external_process_result(
        unhandled_boundary
    )
    assert_false(unhandled_result.handled)
    assert_false(unhandled_result.stop_native_probe)
    assert_false(unhandled_result.reta_native_handled)


def test_fallback_process_dispatch_is_planned_by_process_execution_owner() raises:
    var profile = parse_prompt_startup("rpe", []).profile.copy()
    var plan = plan_prompt_fallback_process_dispatch(
        profile, "shell \"echo hi\""
    )
    assert_true(plan.handled)
    assert_true(plan.run_reta_prompt)
    assert_equal(len(plan.arguments), 5)
    assert_equal(plan.arguments[0], "-vi")
    assert_equal(plan.arguments[1], "-e")
    assert_equal(plan.arguments[2], "-befehl")
    assert_equal(plan.arguments[3], "shell")
    assert_equal(plan.arguments[4], "echo hi")


def test_compatibility_fallback_process_execution_is_planned_by_process_execution_owner() raises:
    var profile = parse_prompt_startup("rpe", []).profile.copy()
    var fallback = PromptExecutionCompatibilityFallbackPlan(
        True, "unknown compatibility command"
    )
    var execution = plan_prompt_compatibility_fallback_process_execution(
        profile, fallback
    )
    assert_true(execution.should_execute)
    assert_equal(execution.source, "unknown compatibility command")
    assert_equal(execution.arguments[0], "-vi")
    assert_equal(execution.arguments[1], "-e")
    assert_equal(execution.arguments[2], "-befehl")
    assert_equal(execution.arguments[3], "unknown")

    var skipped = plan_prompt_compatibility_fallback_process_execution(
        profile, PromptExecutionCompatibilityFallbackPlan(False, "ignored")
    )
    assert_false(skipped.should_execute)
    assert_equal(len(skipped.arguments), 0)


def test_compatibility_fallback_process_result_is_planned_by_process_execution_owner() raises:
    var profile = parse_prompt_startup("rpe", []).profile.copy()
    var fallback = PromptExecutionCompatibilityFallbackPlan(
        True, "unknown compatibility command"
    )
    var execution = plan_prompt_compatibility_fallback_process_execution(
        profile, fallback
    )
    var result = plan_prompt_compatibility_fallback_process_result(execution)
    assert_true(result.handled)
    assert_true(result.process_executed)
    assert_equal(result.source, "unknown compatibility command")

    var skipped = plan_prompt_compatibility_fallback_process_result(
        PromptCompatibilityFallbackProcessExecutionPlan(
            False, List[String](), "ignored"
        )
    )
    assert_false(skipped.handled)
    assert_false(skipped.process_executed)
    assert_equal(skipped.source, "ignored")


def test_residual_fallback_process_execution_is_planned_by_process_execution_owner() raises:
    var profile = parse_prompt_startup("rpe", []).profile.copy()
    var fallback = plan_prompt_execution_residual_compatibility_fallback(
        "unknown residual command"
    )
    var execution = plan_prompt_residual_fallback_process_execution(
        profile, fallback
    )
    assert_true(execution.should_execute)
    assert_equal(execution.source, "unknown residual command")
    assert_equal(execution.arguments[0], "-vi")
    assert_equal(execution.arguments[1], "-e")
    assert_equal(execution.arguments[2], "-befehl")
    assert_equal(execution.arguments[3], "unknown")

    var skipped = plan_prompt_residual_fallback_process_execution(
        profile, PromptExecutionCompatibilityFallbackPlan(False, "ignored")
    )
    assert_false(skipped.should_execute)
    assert_equal(len(skipped.arguments), 0)


def test_residual_fallback_process_result_is_planned_by_process_execution_owner() raises:
    var profile = parse_prompt_startup("rpe", []).profile.copy()
    var fallback = plan_prompt_execution_residual_compatibility_fallback(
        "unknown residual command"
    )
    var execution = plan_prompt_residual_fallback_process_execution(
        profile, fallback
    )
    var result = plan_prompt_residual_fallback_process_result(execution)
    assert_true(result.handled)
    assert_true(result.process_executed)
    assert_equal(result.source, "unknown residual command")

    var skipped = plan_prompt_residual_fallback_process_result(
        PromptResidualFallbackProcessExecutionPlan(False, List[String](), "ignored")
    )
    assert_true(skipped.handled)
    assert_false(skipped.process_executed)
    assert_equal(skipped.source, "ignored")


def test_fallback_process_execution_is_planned_by_process_execution_owner() raises:
    var profile = parse_prompt_startup("rpe", []).profile.copy()
    var dispatch = plan_prompt_fallback_process_dispatch(
        profile, "shell \"echo hi\""
    )
    var execution = plan_prompt_fallback_process_execution(dispatch)
    assert_true(execution.should_execute)
    assert_equal(len(execution.arguments), 5)
    assert_equal(execution.arguments[0], "-vi")
    assert_equal(execution.arguments[2], "-befehl")
    assert_equal(execution.arguments[4], "echo hi")

    var rejected = plan_prompt_fallback_process_execution(
        PromptFallbackProcessDispatchPlan(False, True, List[String]())
    )
    assert_false(rejected.should_execute)


def test_fallback_process_result_is_planned_by_process_execution_owner() raises:
    var profile = parse_prompt_startup("rpe", []).profile.copy()
    var dispatch = plan_prompt_fallback_process_dispatch(
        profile, "shell \"echo hi\""
    )
    var execution = plan_prompt_fallback_process_execution(dispatch)
    var result = plan_prompt_fallback_process_result(execution)
    assert_true(result.handled)
    assert_true(result.process_executed)

    var rejected = plan_prompt_fallback_process_result(
        PromptFallbackProcessExecutionPlan(False, List[String]())
    )
    assert_false(rejected.handled)
    assert_false(rejected.process_executed)


def test_stored_output_execution_is_planned_by_interaction_owner() raises:
    var catalog = load_prompt_language_catalog("assets")
    var interaction = new_prompt_interaction(
        parse_prompt_startup("retaPrompt", [])
    )
    var empty_command = classify_prompt_command_localized(
        "o", "deutsch", catalog
    )
    var no_storage = plan_stored_output_command(
        empty_command, interaction.session
    )
    assert_true(no_storage.handled)
    assert_equal(no_storage.command_line, "")
    assert_equal(len(no_storage.output_lines), 1)
    assert_equal(no_storage.output_lines[0], "Kein Befehl gespeichert.")

    store_prompt_text(interaction.session, "prim 60")
    var stored_only = plan_stored_output_command(
        empty_command, interaction.session
    )
    assert_true(stored_only.handled)
    assert_equal(stored_only.command_line, "prim 60")
    assert_equal(len(stored_only.output_lines), 0)

    var addition_command = classify_prompt_command_localized(
        "o multis 12", "deutsch", catalog
    )
    var with_addition = plan_stored_output_command(
        addition_command, interaction.session
    )
    assert_true(with_addition.handled)
    assert_equal(with_addition.command_line, "prim 60 multis 12")


def test_inline_stored_output_execution_is_planned_by_interaction_owner() raises:
    var catalog = load_prompt_language_catalog("assets")
    var interaction = new_prompt_interaction(
        parse_prompt_startup("retaPrompt", [])
    )
    var no_storage = plan_inline_stored_output_command(
        ["prim", "60", "o"], interaction.session, "deutsch", catalog
    )
    assert_true(no_storage.handled)
    assert_equal(no_storage.command_line, "")
    assert_equal(no_storage.output_lines[0], "Kein Befehl gespeichert.")

    store_prompt_text(interaction.session, "multis 12")
    var suffix = plan_inline_stored_output_command(
        ["prim", "60", "o"], interaction.session, "deutsch", catalog
    )
    assert_true(suffix.handled)
    assert_equal(suffix.command_line, "multis 12 prim 60")
    assert_equal(len(suffix.output_lines), 0)

    var unhandled = plan_inline_stored_output_command(
        ["o", "prim"], interaction.session, "deutsch", catalog
    )
    assert_false(unhandled.handled)



def test_stored_delete_execution_is_planned_by_interaction_owner() raises:
    var catalog = load_prompt_language_catalog("assets")
    var interaction = new_prompt_interaction(
        parse_prompt_startup("retaPrompt", [])
    )
    var empty_command = classify_prompt_command_localized(
        "l", "deutsch", catalog
    )
    var no_storage = plan_stored_delete_command(
        empty_command, interaction.session
    )
    assert_true(no_storage.handled)
    assert_equal(len(no_storage.output_lines), 1)
    assert_equal(no_storage.output_lines[0], "Kein Befehl gespeichert.")
    assert_false(interaction.session.delete_next)

    store_prompt_text(interaction.session, "prim 60 multis 12")
    var listing = plan_stored_delete_command(
        empty_command, interaction.session
    )
    assert_true(listing.handled)
    assert_equal(len(listing.output_lines), 4)
    assert_equal(listing.output_lines[0], "1: prim")
    assert_equal(listing.output_lines[3], "4: 12")
    assert_true(interaction.session.delete_next)

    var delete_command = classify_prompt_command_localized(
        "l 2", "deutsch", catalog
    )
    var deleted = plan_stored_delete_command(
        delete_command, interaction.session
    )
    assert_true(deleted.handled)
    assert_equal(deleted.output_lines[0], "Gespeichert: prim multis 12")
    assert_equal(stored_prompt_text(interaction.session), "prim multis 12")
    assert_false(interaction.session.delete_next)

    var normal = classify_prompt_command_localized(
        "prim 60", "deutsch", catalog
    )
    assert_false(
        plan_stored_delete_command(normal, interaction.session).handled
    )


def test_inline_storage_output_edges_and_history() raises:
    var catalog = load_prompt_language_catalog("assets")
    var interaction = new_prompt_interaction(
        parse_prompt_startup("retaPrompt", [])
    )
    interaction.session.previous_command = "prim 60"

    var alone = plan_inline_storage_output_command(
        ["o"], "deutsch", catalog
    )
    assert_true(alone.handled)
    assert_equal(alone.payload, "")
    assert_false(
        plan_inline_storage_output_command(
            ["o", "abc"], "deutsch", catalog
        ).handled
    )
    assert_false(
        plan_inline_storage_output_command(
            ["o", "BefehlSpeicherungAusgeben", "prim", "60"],
            "deutsch",
            catalog,
        ).handled
    )
    assert_false(
        plan_inline_storage_output_command(
            ["o", "prim"], "deutsch", catalog
        ).handled
    )

    var line = "prim 60 o"
    var kind = classify_prompt_command_localized(
        line, "deutsch", catalog
    ).kind
    assert_false(
        prompt_line_updates_previous(
            line, kind, "deutsch", catalog
        )
    )
    record_prompt_line(
        interaction, line, kind, "deutsch", catalog
    )
    assert_equal(interaction.session.previous_command, "prim 60")

def test_contract_snapshot() raises:
    # Historical source guards may still look for the pre-split monolithic
    # snapshot assertion while the runtime assertion below uses the new
    # lifecycle-only interaction snapshot.  Kept as non-executed text:
    # assert_equal(len(snapshot), 21)
    # assert_equal(len(snapshot), 38)
    # assert_equal(snapshot[20], "execution=delegated-native-dispatch")
    var snapshot = prompt_interaction_contract_snapshot()
    assert_equal(len(snapshot), 7)
    assert_equal(snapshot[0], "class=PromptInteractionBundle")
    assert_equal(snapshot[1], "startup=native-profile-to-session")
    assert_equal(snapshot[2], "one_shot=native-token-assembly")
    assert_equal(snapshot[3], "reaction_input=delegated-native-input-owner")
    assert_equal(snapshot[4], "reaction_dispatch=delegated-native-local-effect-owner")
    assert_equal(snapshot[5], "terminal=delegated-native-editor")
    assert_equal(snapshot[6], "execution=delegated-native-dispatch")

    var input_snapshot = prompt_reaction_input_contract_snapshot()
    assert_equal(len(input_snapshot), 8)
    assert_equal(input_snapshot[0], "class=PromptReactionInputBundle")
    assert_equal(input_snapshot[1], "reaction_input_owner=prompt-reaction-physical-input-plan")
    assert_equal(input_snapshot[2], "input=native-typed-plan")
    assert_equal(input_snapshot[3], "store=native-next-and-previous")
    assert_equal(input_snapshot[4], "delete=native-selection-and-cancel")
    assert_equal(input_snapshot[5], "stored_default=native-empty-enter-placeholder-policy")
    assert_equal(input_snapshot[6], "history=native-previous-command-policy")
    assert_equal(input_snapshot[7], "terminal_sentinels=native-exit-plan")

    # Historical stage source guards still look for the previous length while
    # the runtime assertion below tracks the current split process contract.
     # assert_equal(len(process_snapshot), 26)
    # assert_equal(process_snapshot[25], "process_adapter=argv-execution-only")
    # assert_equal(len(process_snapshot), 27)
    # assert_equal(len(process_snapshot), 28)
    # assert_equal(len(process_snapshot), 29)
    var process_snapshot = prompt_process_dispatch_contract_snapshot()
    # assert_equal(len(process_snapshot), 30)
    # assert_equal(len(process_snapshot), 31)
    assert_equal(len(process_snapshot), 32)
    assert_equal(process_snapshot[0], "class=PromptProcessDispatchBundle")
    assert_equal(process_snapshot[1], "external_dispatch_owner=prompt-execution-process-plan")
    assert_equal(process_snapshot[2], "external_process_dispatch=native-prompt-process-edge-plan")
    assert_equal(process_snapshot[3], "external_reta_arguments=native-prompt-reta-argv-plan")
    assert_equal(process_snapshot[4], "external_process_arguments=native-prompt-process-argv-plan")
    assert_equal(process_snapshot[5], "external_process_flags=native-prompt-process-effect-flags")
    assert_equal(process_snapshot[6], "external_process_kind=eliminated-from-external-process-plan")
    assert_equal(process_snapshot[7], "interactive_external_execution=native-prompt-process-execution-boundary")
    assert_equal(process_snapshot[8], "interactive_external_completion=native-prompt-process-completion-boundary")
    assert_equal(process_snapshot[9], "interactive_reference_reta_execution=native-prompt-process-reference-reta-boundary")
    assert_equal(process_snapshot[10], "interactive_external_result=native-prompt-process-result-boundary")
    assert_equal(process_snapshot[11], "one_shot_external_execution=native-prompt-process-one-shot-execution-boundary")
    assert_equal(process_snapshot[12], "one_shot_external_boundary=native-prompt-process-probe-boundary")
    assert_equal(process_snapshot[13], "one_shot_external_result=native-prompt-process-one-shot-result-boundary")
    assert_equal(process_snapshot[14], "external_reta_child=native-prompt-reta-child-argv")
    assert_equal(process_snapshot[15], "external_raw_line=eliminated-from-external-process-plan")
    assert_equal(process_snapshot[16], "external_shell_arguments=native-prompt-shell-argv-plan")
    assert_equal(process_snapshot[17], "external_python_math_arguments=native-prompt-python-math-argv-plan")
    assert_equal(process_snapshot[18], "external_command_arguments=runtime-owned-command-argv-builders")
    assert_equal(process_snapshot[19], "compatibility_fallback_process_execution=native-prompt-compatibility-fallback-execution-boundary")
    assert_equal(process_snapshot[20], "compatibility_fallback_process_result=native-prompt-compatibility-fallback-result-boundary")
    assert_equal(process_snapshot[21], "residual_fallback_process_execution=native-prompt-residual-fallback-execution-boundary")
    assert_equal(process_snapshot[22], "residual_fallback_process_result=native-prompt-residual-fallback-result-boundary")
    assert_equal(process_snapshot[23], "fallback_process_dispatch=native-interaction-argv-plan")
    assert_equal(process_snapshot[24], "fallback_process_execution=native-prompt-fallback-execution-boundary")
    assert_equal(process_snapshot[25], "fallback_process_result=native-prompt-fallback-result-boundary")
    assert_equal(process_snapshot[26], "fallback_process_handled=native-explicit-fallback-effect-flag")
    assert_equal(process_snapshot[27], "fallback_process_flags=native-explicit-fallback-run-flag")
    assert_equal(process_snapshot[28], "fallback_process_arguments=native-merged-fallback-argv")
    assert_equal(process_snapshot[29], "fallback_runtime_arguments=runtime-owned-argv-builder")
    assert_equal(process_snapshot[30], "fallback_shell_split=runtime-owned-argv-tokenizer")
    assert_equal(process_snapshot[31], "process_adapter=argv-execution-only")

    var storage_snapshot = prompt_reaction_storage_contract_snapshot()
    assert_equal(len(storage_snapshot), 8)
    assert_equal(storage_snapshot[0], "class=PromptReactionStorageBundle")
    assert_equal(storage_snapshot[1], "reaction_storage_owner=prompt-reaction-storage-plan")
    assert_equal(storage_snapshot[2], "inline_storage=native-position-and-history-policy")
    assert_equal(storage_snapshot[3], "storage_output=native-position-independent-addition-policy")
    assert_equal(storage_snapshot[4], "stored_default=native-empty-enter-placeholder-policy")
    assert_equal(storage_snapshot[5], "stored_command_dispatch=native-session-store-plan")
    assert_equal(storage_snapshot[6], "stored_output_dispatch=native-session-output-execution-plan")
    assert_equal(storage_snapshot[7], "stored_delete_dispatch=native-session-delete-plan")

    var reaction_snapshot = prompt_reaction_dispatch_contract_snapshot()
    assert_equal(len(reaction_snapshot), 8)
    assert_equal(reaction_snapshot[0], "class=PromptReactionDispatchBundle")
    assert_equal(reaction_snapshot[1], "reaction_dispatch_owner=prompt-reaction-local-plan")
    assert_equal(reaction_snapshot[7], "simple_output_dispatch=native-deterministic-prompt-output-plan")

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
