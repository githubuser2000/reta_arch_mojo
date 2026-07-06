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
    assert_equal(len(snapshot), 11)
    assert_equal(snapshot[0], "class=PromptInteractionBundle")
    assert_equal(
        snapshot[6],
        "inline_storage=native-position-and-history-policy",
    )
    assert_equal(
        snapshot[7],
        "storage_output=native-position-independent-addition-policy",
    )
    assert_equal(snapshot[10], "execution=delegated-native-dispatch")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
