from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.legacy_reta_prompt import *
from reta_mojo.prompt_interaction import (
    INTERACTION_CONTINUE,
    prompt_interaction_contract_snapshot,
)
from reta_mojo.prompt_session import (
    PROMPT_MODE_STORED_OUTPUT,
    PROMPT_MODE_STORED_OUTPUT_WITH_ADDITION,
)


def test_complete_public_surface_and_bootstrap() raises:
    var facade = bootstrap_legacy_reta_prompt()
    var snapshot = facade.snapshot()
    assert_equal(snapshot.exported_names_len, 55)
    assert_equal(snapshot.commands_len, 386)
    assert_equal(snapshot.commands2_len, 385)
    assert_equal(snapshot.exit_commands_len, 5)
    assert_equal(snapshot.language, "deutsch")
    assert_true(snapshot.logging_enabled)
    assert_true(snapshot.native_controller)
    var names = legacy_reta_prompt_exported_names()
    assert_equal(names[0], "os")
    assert_equal(names[27], "prompt_parallel_config")
    assert_equal(names[54], "start")


def test_historical_storage_adapters_use_native_session() raises:
    var facade = bootstrap_legacy_reta_prompt()
    var stored = speichern(facade, "prim 60")
    assert_equal(stored.stored_text, "prim 60")
    assert_equal(stored.prepared_tokens, ["prim", "60"])
    var deleted = PromptLoescheVorSpeicherungBefehle(facade, "2")
    assert_equal(deleted.stored_text, "prim")
    assert_equal(
        promptSpeicherungB(
            "ignored", PROMPT_MODE_STORED_OUTPUT, "reta -h"
        ),
        "reta -h",
    )
    assert_equal(
        promptSpeicherungB(
            "--nocolor",
            PROMPT_MODE_STORED_OUTPUT_WITH_ADDITION,
            "reta -h",
        ),
        "reta -h --nocolor",
    )


def test_historical_input_and_start_delegate_to_native_controller() raises:
    var facade = bootstrap_legacy_reta_prompt()
    facade.promptInteraction.session.store_next = True
    var plan = promptInput(facade, "reta -h")
    assert_equal(plan.action, INTERACTION_CONTINUE)
    assert_equal(
        facade.promptInteraction.session.stored_tokens,
        ["reta", "-h"],
    )
    assert_equal(start(facade, "english"), "english")
    assert_equal(facade.befehleBeenden[1], "end")
    assert_false(facade.promptInteraction.session.store_next)
    var scope = PromptScope(facade)
    var interaction_scope = prompt_interaction_contract_snapshot()
    assert_equal(len(scope), len(interaction_scope))
    assert_equal(scope[0], "class=PromptInteractionBundle")
    assert_equal(
        scope[7],
        "storage_output=native-position-independent-addition-policy",
    )
    assert_equal(scope[len(scope) - 1], "execution=delegated-native-dispatch")


def test_loop_setup_and_new_session_are_typed() raises:
    var facade = bootstrap_legacy_reta_prompt("rpb", ["prim", "60"])
    var setup = PromptAllesVorGroesserSchleife(facade)
    assert_true(setup.force_e_command)
    assert_equal(setup.only_one_command, ["prim", "60"])
    var session = newSession(facade, False)
    assert_equal(session.normal_prefix, ">")
    assert_false(session.logging_enabled)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
