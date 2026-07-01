from std.collections import List
from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_line_editor import *


def test_utf8_cursor_and_editing() raises:
    var state = new_prompt_editor_state(0, False)
    editor_insert(state, "münd")
    assert_equal(state.text, "münd")
    assert_equal(utf8_display_width(state.text), 4)
    editor_move_left(state)
    editor_move_left(state)
    editor_backspace(state)
    assert_equal(state.text, "mnd")
    assert_equal(state.cursor, 1)
    editor_insert(state, "ü")
    assert_equal(state.text, "münd")
    editor_move_home(state)
    editor_delete(state)
    assert_equal(state.text, "ünd")
    editor_move_end(state)
    editor_kill_before_cursor(state)
    assert_equal(state.text, "")


def test_word_movement_and_kills() raises:
    var state = new_prompt_editor_state(0, False)
    editor_set_text(state, "reta -ausgabe --art=html")
    editor_move_word_left(state)
    assert_equal(String(StringSlice(state.text)[byte=state.cursor:]), "--art=html")
    editor_delete_previous_word(state)
    assert_equal(state.text, "reta --art=html")
    editor_move_home(state)
    editor_move_word_right(state)
    assert_equal(state.cursor, 5)
    editor_kill_after_cursor(state)
    assert_equal(state.text, "reta ")


def test_history_round_trip() raises:
    var history = List[String]()
    history.append("prim 12")
    history.append("mond 3")
    var state = new_prompt_editor_state(len(history), False)
    editor_set_text(state, "current")
    assert_true(editor_history_previous(state, history))
    assert_equal(state.text, "mond 3")
    assert_true(editor_history_previous(state, history))
    assert_equal(state.text, "prim 12")
    assert_false(editor_history_previous(state, history))
    assert_true(editor_history_next(state, history))
    assert_equal(state.text, "mond 3")
    assert_true(editor_history_next(state, history))
    assert_equal(state.text, "current")


def test_completion_replaces_root_and_nested_fragments() raises:
    var catalog = load_prompt_language_catalog("assets")
    var root = new_prompt_editor_state(0, False)
    editor_set_text(root, "primfaktorenver")
    var root_result = editor_complete(root, catalog, "deutsch")
    assert_true(root_result.unique)
    assert_equal(root.text, "primfaktorenvergleich ")

    var nested = new_prompt_editor_state(0, False)
    editor_set_text(nested, "reta -ausgabe --art=bb")
    var nested_result = editor_complete(nested, catalog, "deutsch")
    assert_true(nested_result.unique)
    assert_equal(nested.text, "reta -ausgabe --art=bbcode ")

    var common = new_prompt_editor_state(0, False)
    editor_set_text(common, "pri")
    var common_result = editor_complete(common, catalog, "deutsch")
    assert_false(common_result.changed)
    assert_false(common_result.unique)
    assert_equal(common.text, "pri")
    assert_true(len(common_result.candidates) > 1)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
