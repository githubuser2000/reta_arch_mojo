from std.collections import List
from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.prompt_runtime import *
from reta_mojo.prompt_catalog import prompt_completion_words


def test_historical_prompt_profiles() raises:
    var reta_prompt = profile_from_name("retaPrompt")
    assert_true(reta_prompt.logging_enabled)
    assert_false(reta_prompt.vi_mode)
    assert_true(reta_prompt.show_intro)

    var rp = profile_from_name("rp")
    assert_true(rp.vi_mode)
    assert_true(rp.logging_enabled)
    assert_false(rp.force_e_command)

    var rpl = profile_from_name("rpl")
    assert_true(rpl.vi_mode)
    assert_false(rpl.logging_enabled)
    assert_true(rpl.force_e_command)


def test_one_shot_profiles() raises:
    var rpb = profile_from_name("rpb")
    assert_true(rpb.one_shot)
    assert_true(rpb.force_e_command)
    assert_false(rpb.emacs_output)

    var rpe = profile_from_name("rpe")
    assert_true(rpe.one_shot)
    assert_true(rpe.emacs_output)


def test_startup_flags_override_profile() raises:
    var startup = parse_prompt_startup(
        "retaPrompt", ["-vi", "-e", "-language=english", "-befehl", "prim", "60"]
    )
    assert_true(startup.profile.vi_mode)
    assert_true(startup.profile.force_e_command)
    assert_equal(startup.profile.language, "english")
    assert_true(startup.profile.one_shot)
    assert_equal(len(startup.command_tokens), 2)
    assert_equal(startup.command_tokens[0], "prim")


def test_unknown_start_argument_is_diagnosed() raises:
    var startup = parse_prompt_startup("rp", ["-unbekannt"])
    assert_equal(len(startup.diagnostics), 1)


def test_command_classification() raises:
    assert_equal(classify_prompt_command("q").kind, KIND_EXIT)
    assert_equal(classify_prompt_command("hilfe").kind, KIND_HELP)
    assert_equal(classify_prompt_command("prim 60").kind, KIND_PRIME)
    assert_equal(classify_prompt_command("prim24 29").kind, KIND_PRIME24)
    assert_equal(classify_prompt_command("multis3 36").kind, KIND_MULTIS3)
    assert_equal(classify_prompt_command("reta -h").kind, KIND_RETA)
    assert_equal(classify_prompt_command("primfaktorenvergleich 12 18").kind, KIND_PRIME_COMPARE)
    assert_equal(classify_prompt_command("mond 1-3").kind, KIND_MOON)
    assert_equal(classify_prompt_command("abstand 7 17-19").kind, KIND_DISTANCE)
    assert_equal(classify_prompt_command("abstandPrim 7 17-19").kind, KIND_DISTANCE_PRIME)
    assert_equal(classify_prompt_command("richtung 1-2").kind, KIND_DIRECTION)
    assert_equal(classify_prompt_command("r 1-2").kind, KIND_DIRECTION)
    assert_equal(classify_prompt_command("a 2").kind, KIND_FALLBACK)


def test_prime_prompt_lines() raises:
    var command = classify_prompt_command("prim 60,29")
    var lines = prime_lines(command)
    assert_equal(len(lines), 2)
    assert_equal(lines[0], "29: 29")
    assert_equal(lines[1], "60: 2^2 3 5")


def test_prime24_prompt_lines() raises:
    var command = classify_prompt_command("prim24 29")
    var lines = prime_lines(command, True)
    assert_equal(len(lines), 1)
    assert_equal(lines[0], "29: 5")


def test_multis_prompt_lines() raises:
    var lines = multis_lines(classify_prompt_command("multis 12"))
    assert_equal(len(lines), 1)
    assert_equal(lines[0], "12: [(6, 2), (4, 3)]")


def test_multis3_prompt_lines() raises:
    var lines = multis3_lines(classify_prompt_command("multis3 36"))
    assert_equal(len(lines), 1)
    assert_equal(lines[0], "36: [(2, 2, 9), (2, 3, 6), (3, 3, 4)]")


def test_modulo_prompt_lines() raises:
    var lines = modulo_lines(classify_prompt_command("modulo 5"))
    assert_equal(len(lines), 24)
    assert_equal(lines[0], "5 % 2 = 1 Gegenteil, 1 Gegenteil")


def test_abc_prompt_command() raises:
    assert_equal(abc_line(classify_prompt_command("abc Abz")), "1 2 26")


def test_rpe_wraps_non_reta_command() raises:
    var startup = parse_prompt_startup("rpe", ["prim", "60"])
    var tokens = effective_one_shot_tokens(startup)
    assert_equal(len(tokens), 6)
    assert_equal(tokens[0], "-ausgabe")
    assert_equal(tokens[1], "--art=emacs")
    assert_equal(tokens[3], "prim")
    assert_equal(tokens[5], "e")


def test_rpe_appends_output_to_direct_reta() raises:
    var startup = parse_prompt_startup("rpe", ["reta", "-h"])
    var tokens = effective_one_shot_tokens(startup)
    assert_equal(len(tokens), 5)
    assert_equal(tokens[0], "reta")
    assert_equal(tokens[2], "-ausgabe")
    assert_equal(tokens[4], "--keineueberschriften")


def test_completion_catalog_snapshot() raises:
    var words = prompt_completion_words()
    assert_equal(len(words), 388)
    assert_equal(words[0], "absicht")
    assert_equal(words[len(words) - 1], "16_")


def test_native_prompt_storage_state() raises:
    var session = new_prompt_session(True)
    assert_equal(prompt_prefix(session), "> ")
    session.store_next = True
    assert_equal(prompt_prefix(session), "speichern> ")
    store_prompt_text(session, "prim 60")
    assert_false(session.store_next)
    assert_equal(stored_prompt_text(session), "prim 60")
    var numbered = stored_prompt_numbered(session)
    assert_equal(len(numbered), 2)
    assert_equal(numbered[0], "1: prim")
    assert_equal(numbered[1], "2: 60")


def test_native_prompt_storage_deletion_by_index() raises:
    var session = new_prompt_session(False)
    store_prompt_text(session, "reta -h --nocolor")
    delete_stored_selection(session, "2")
    assert_equal(stored_prompt_text(session), "reta --nocolor")


def test_native_prompt_storage_deletion_by_token() raises:
    var session = new_prompt_session(False)
    store_prompt_text(session, "prim 60 e")
    delete_stored_selection(session, "e")
    assert_equal(stored_prompt_text(session), "prim 60")


def test_storage_commands_classify_natively() raises:
    assert_equal(classify_prompt_command("S").kind, KIND_STORE_NEXT)
    assert_equal(classify_prompt_command("s").kind, KIND_STORE_PREVIOUS)
    assert_equal(classify_prompt_command("o").kind, KIND_OUTPUT_STORED)
    assert_equal(classify_prompt_command("l").kind, KIND_DELETE_STORED)



def test_prime_comparison_prompt_lines() raises:
    var lines = prime_comparison_lines(classify_prompt_command("primfaktorenvergleich 12 18"))
    assert_equal(len(lines), 3)
    assert_equal(lines[0], "Gemeinsamkeiten: 6 := 2 * 3")
    assert_equal(lines[1], "2     := 12    / 6     -> 2")
    assert_equal(lines[2], "3     := 18    / 6     -> 3")
    var english = prime_comparison_lines(classify_prompt_command("primfaktorenvergleich 12 18"), "english")
    assert_equal(english[0], "commonalities: 6 := 2 * 3")


def test_distance_prompt_lines() raises:
    var simple = distance_lines(classify_prompt_command("abstand 7 17-19"))
    assert_equal(len(simple), 1)
    assert_equal(simple[0], "7->: 17: 10, 18: 11, 19: 12")
    var both = distance_lines(classify_prompt_command("abstand 7 17"))
    assert_equal(len(both), 2)
    assert_equal(both[0], "7->: 17: 10")
    assert_equal(both[1], "17->: 7: 10")


def test_prime_distance_prompt_lines() raises:
    var lines = distance_lines(classify_prompt_command("abstandPrim 7 17-19"), True)
    assert_equal(len(lines), 1)
    assert_equal(lines[0], "7->: 17: [2, 5], 18: [11], 19: ['2^2', 3]")


def test_distance_prompt_multiple_ranges() raises:
    var lines = distance_lines(
        classify_prompt_command("abstand 1-2 5-6 10-11")
    )
    assert_equal(len(lines), 6)
    assert_equal(lines[0], "1->: 10: 9, 11: 10")
    assert_equal(lines[1], "2->: 10: 8, 11: 9")
    assert_equal(lines[2], "10->: 1: 9, 2: 8")
    assert_equal(lines[3], "11->: 1: 10, 2: 9")
    assert_equal(lines[4], "5->: 1: 4, 2: 3")
    assert_equal(lines[5], "6->: 1: 5, 2: 4")


def test_prime_distance_prompt_multiple_ranges() raises:
    var lines = distance_lines(
        classify_prompt_command("abstandPrim 1-2 5-6 10-11"), True
    )
    assert_equal(len(lines), 6)
    assert_equal(lines[0], "1->: 10: ['3^2'], 11: [2, 5]")
    assert_equal(lines[1], "2->: 10: ['2^3'], 11: ['3^2']")
    assert_equal(lines[2], "10->: 1: ['3^2'], 2: ['2^3']")
    assert_equal(lines[3], "11->: 1: [2, 5], 2: ['3^2']")
    assert_equal(lines[4], "5->: 1: ['2^2'], 2: [3]")
    assert_equal(lines[5], "6->: 1: [5], 2: ['2^2']")


def test_distance_prompt_duplicate_ranges() raises:
    var lines = distance_lines(
        classify_prompt_command("abstand 1-2 1-2 5-6")
    )
    assert_equal(len(lines), 4)
    assert_equal(lines[0], "1->: 5: 4, 6: 5")
    assert_equal(lines[3], "6->: 1: 5, 2: 4")


def test_distance_prompt_mixed_cardinality_order() raises:
    var lines = distance_lines(
        classify_prompt_command("abstand 1-3 5 8-9")
    )
    assert_equal(len(lines), 6)
    assert_equal(lines[0], "5->: 1: 4, 2: 3, 3: 2")
    assert_equal(lines[1], "1->: 8: 7, 9: 8")
    assert_equal(lines[2], "2->: 8: 6, 9: 7")
    assert_equal(lines[3], "3->: 8: 5, 9: 6")
    assert_equal(lines[4], "8->: 1: 7, 2: 6, 3: 5")
    assert_equal(lines[5], "9->: 1: 8, 2: 7, 3: 6")


def test_distance_prompt_three_scalars() raises:
    var lines = distance_lines(classify_prompt_command("abstand 1 5 10"))
    assert_equal(len(lines), 3)
    assert_equal(lines[0], "10->: 1: 9")
    assert_equal(lines[1], "1->: 10: 9")
    assert_equal(lines[2], "5->: 1: 4")


def test_distance_prompt_outer_set_resize_order() raises:
    var lines = distance_lines(
        classify_prompt_command("abstand 1 2 3 4 5 6")
    )
    assert_equal(len(lines), 6)
    assert_equal(lines[0], "2->: 4: 2")
    assert_equal(lines[1], "1->: 4: 3")
    assert_equal(lines[2], "6->: 4: 2")
    assert_equal(lines[3], "5->: 4: 1")
    assert_equal(lines[4], "4->: 5: 1")
    assert_equal(lines[5], "3->: 4: 1")


def test_distance_prompt_large_range_difference_order() raises:
    var lines = distance_lines(
        classify_prompt_command("abstand 1-25 30 31 32 33")
    )
    assert_equal(len(lines), 4)
    assert_true(lines[0].startswith("33->: 1: 32, 2: 31"))
    assert_true(lines[1].startswith("32->: 1: 31, 2: 30"))
    assert_true(lines[2].startswith("30->: 1: 29, 2: 28"))
    assert_true(lines[3].startswith("31->: 1: 30, 2: 29"))


def test_distance_prompt_difference_copy_strategy() raises:
    var lines = distance_lines(
        classify_prompt_command("abstand 1 2 3 4 5 6 7 8 9")
    )
    assert_equal(len(lines), 9)
    assert_equal(lines[0], "9->: 4: 5")
    assert_equal(lines[1], "8->: 4: 4")
    assert_equal(lines[2], "7->: 4: 3")
    assert_equal(lines[3], "3->: 4: 1")
    assert_equal(lines[4], "1->: 4: 3")
    assert_equal(lines[5], "6->: 4: 2")
    assert_equal(lines[6], "5->: 4: 1")
    assert_equal(lines[7], "4->: 5: 1")
    assert_equal(lines[8], "2->: 4: 2")


def test_distance_prompt_missing_second_range() raises:
    var normal = distance_lines(classify_prompt_command("abstand 1"))
    assert_equal(len(normal), 1)
    assert_equal(
        normal[0],
        "der Befehl 'abstand' verlangt mindestens 2 Zahlenangaben, wie 'abstand 7 17-25'",
    )
    var prime = distance_lines(
        classify_prompt_command("abstandPrim 1"), True
    )
    assert_equal(len(prime), 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
