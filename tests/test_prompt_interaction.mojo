from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_runtime import (
    parse_prompt_startup,
    classify_prompt_command_localized,
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
    var snapshot = prompt_interaction_contract_snapshot()
    assert_equal(len(snapshot), 18)
    assert_equal(snapshot[0], "class=PromptInteractionBundle")
    assert_equal(
        snapshot[6],
        "inline_storage=native-position-and-history-policy",
    )
    assert_equal(
        snapshot[7],
        "storage_output=native-position-independent-addition-policy",
    )
    assert_equal(
        snapshot[8],
        "stored_command_dispatch=native-session-store-plan",
    )
    assert_equal(
        snapshot[9],
        "logging_dispatch=native-session-logging-plan",
    )
    assert_equal(
        snapshot[10],
        "terminal_clear_dispatch=native-terminal-clear-plan",
    )
    assert_equal(
        snapshot[11],
        "informational_dispatch=native-prompt-information-plan",
    )
    assert_equal(
        snapshot[12],
        "stored_output_dispatch=native-session-output-execution-plan",
    )
    assert_equal(
        snapshot[13],
        "stored_delete_dispatch=native-session-delete-plan",
    )
    assert_equal(
        snapshot[14],
        "stored_default=native-empty-enter-placeholder-policy",
    )
    assert_equal(snapshot[17], "execution=delegated-native-dispatch")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
