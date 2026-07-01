from std.collections import List
from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_runtime import parse_prompt_startup
from reta_mojo.prompt_session import *


def test_prompt_text_state_splitting() raises:
    var plain = new_prompt_text_state("  p5   (1 2)  ")
    assert_equal(plain.text, "p5   (1 2)")
    # Python custom_split keeps empty fields between repeated spaces.
    assert_equal(len(plain.tokens), 4)
    assert_equal(plain.tokens[0], "p5")
    assert_equal(plain.tokens[1], "")
    assert_equal(plain.tokens[2], "")
    assert_equal(plain.tokens[3], "(1 2)")

    var reta = new_prompt_text_state(" reta -zeilen --zeit=heute ")
    assert_equal(len(reta.tokens), 3)
    assert_equal(reta.tokens[0], "reta")
    assert_equal(reta.tokens[2], "--zeit=heute")


def test_prompt_text_state_extra_and_membership() raises:
    var state = new_prompt_text_state("prim 60")
    set_prompt_extra(state, ["e", "prim"])
    var all_tokens = prompt_text_all_tokens(state)
    assert_equal(len(all_tokens), 4)
    var unique = prompt_text_unique_tokens(state)
    assert_equal(len(unique), 3)
    assert_true(prompt_text_has(state, ["prim"]))
    assert_true(prompt_text_has_without_abc(state, ["prim"], "abc", "abcd"))
    set_prompt_text(state, "prim abc")
    assert_false(prompt_text_has_without_abc(state, ["prim"], "abc", "abcd"))


def test_loop_setup_snapshot_contract() raises:
    var startup = parse_prompt_startup(
        "retaPrompt", ["-vi", "-e", "-befehl", "prim", "60"]
    )
    var setup = build_prompt_loop_setup(startup, ["q", "exit"])
    assert_true(setup.logging_enabled)
    assert_true(setup.force_e_command)
    assert_equal(len(setup.only_one_command), 2)
    assert_equal(prompt_mode_prefix(setup, PROMPT_MODE_NORMAL), ">")
    assert_equal(prompt_mode_prefix(setup, PROMPT_MODE_STORE), "was speichern>")
    assert_equal(prompt_mode_prefix(setup, PROMPT_MODE_DELETE_SELECT), "was löschen>")


def test_session_storage_and_prefixes() raises:
    var session = new_prompt_session(True)
    assert_equal(prompt_prefix(session), ">")
    session.store_next = True
    assert_equal(prompt_prefix(session), "was speichern>")
    store_prompt_text(session, "prim 60")
    assert_equal(stored_prompt_text(session), "prim 60")
    assert_false(session.store_next)
    session.delete_next = True
    assert_equal(prompt_prefix(session), "was löschen>")
    var numbered = stored_prompt_numbered(session)
    assert_equal(numbered[0], "1: prim")
    assert_equal(numbered[1], "2: 60")


def test_storage_deletion_python_decimal_rule() raises:
    var session = new_prompt_session(False)
    store_prompt_text(session, "reta 2 --nocolor")
    # Python deletes the token value "2" because it exists literally.
    delete_stored_selection(session, "2")
    assert_equal(stored_prompt_text(session), "reta --nocolor")

    var by_position = new_prompt_session(False)
    store_prompt_text(by_position, "reta -h --nocolor")
    delete_stored_selection(by_position, "2")
    assert_equal(stored_prompt_text(by_position), "reta --nocolor")


def test_storage_deletion_ranges_and_tokens() raises:
    var session = new_prompt_session(False)
    store_prompt_text(session, "a b c d e")
    delete_stored_selection(session, "2-4")
    assert_equal(stored_prompt_text(session), "a e")
    store_prompt_text(session, "x y x")
    delete_stored_selection(session, "x")
    assert_equal(stored_prompt_text(session), "a e y")


def test_history_toggle_commands_are_not_recorded() raises:
    var catalog = load_prompt_language_catalog("assets")
    assert_false(history_should_append("", catalog, "deutsch"))
    assert_false(history_should_append("loggen", catalog, "deutsch"))
    assert_false(history_should_append("nichtloggen", catalog, "deutsch"))
    assert_false(history_should_append("logging_yes", catalog, "english"))
    assert_false(history_should_append("logging_no", catalog, "english"))
    assert_true(history_should_append("prim 60", catalog, "deutsch"))
    assert_true(history_should_append("prime 60", catalog, "english"))


def test_storage_output_and_combination() raises:
    assert_equal(
        apply_storage_output("ignored", PROMPT_MODE_STORED_OUTPUT, "reta -h", "current"),
        "reta -h",
    )
    assert_equal(
        apply_storage_output(
            "--nocolor", PROMPT_MODE_STORED_OUTPUT_WITH_ADDITION, "reta -h", "current"
        ),
        "reta -h --nocolor",
    )
    assert_equal(combine_stored_prompt("reta -h", "reta --nocolor"), "reta -h --nocolor")
    assert_equal(combine_stored_prompt("prim", "60"), "prim 60")


def test_localized_prompt_prefixes() raises:
    var session = new_prompt_session_for_language(False, "english")
    assert_equal(prompt_prefix(session), ">")
    session.store_next = True
    assert_equal(prompt_prefix(session), "save what>")
    session.store_next = False
    session.delete_next = True
    assert_equal(prompt_prefix(session), "delete what>")


def test_contract_snapshot() raises:
    var snapshot = prompt_session_contract_snapshot()
    assert_equal(len(snapshot), 7)
    assert_equal(snapshot[0], "class=PromptSessionBundle")
    assert_equal(snapshot[6], "terminal=native-posix-editor")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
