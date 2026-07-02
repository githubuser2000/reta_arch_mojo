from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_runtime import (
    parse_prompt_startup,
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


def test_contract_snapshot() raises:
    var snapshot = prompt_interaction_contract_snapshot()
    assert_equal(len(snapshot), 9)
    assert_equal(snapshot[0], "class=PromptInteractionBundle")
    assert_equal(snapshot[8], "execution=delegated-native-dispatch")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
