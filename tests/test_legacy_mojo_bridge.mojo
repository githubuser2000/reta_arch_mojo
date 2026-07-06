from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.legacy_mojo_bridge import (
    LegacyMojoBridgeBundle,
    NativePromptReadlineConfiguration,
    _close_prompt_completion_process,
    _configure_prompt_readline,
    _prompt_completion_process,
    bootstrap_legacy_mojo_bridge,
    legacy_mojo_bridge_owner_snapshot,
)
from reta_mojo.legacy_mojo_bridge_catalog import (
    legacy_mojo_bridge_public_names,
)


def test_exact_surface_and_native_owners() raises:
    var bridge = bootstrap_legacy_mojo_bridge()
    var snapshot = bridge.snapshot()
    assert_equal(snapshot.public_names, 15)
    assert_equal(snapshot.functions, 19)
    assert_false(snapshot.embedded_python)
    assert_true(snapshot.native_prompt_input)
    assert_true(snapshot.native_html_pipeline)
    assert_true(snapshot.explicit_child_boundary)
    assert_equal(legacy_mojo_bridge_public_names()[0], "REFERENCE_ROOT")
    assert_equal(
        legacy_mojo_bridge_public_names()[14], "generate_html_document"
    )


def test_encoded_argument_and_readline_configuration_are_typed() raises:
    var config = _configure_prompt_readline(
        True,
        "~/.history",
        "deutsch",
        ["reta", "prim"],
    )
    assert_true(config.vi_mode)
    assert_true(config.native_editor)
    assert_equal(config.history_file, "~/.history")
    assert_equal(config.completion_words, ["reta", "prim"])
    assert_false(_prompt_completion_process("deutsch"))
    _close_prompt_completion_process()


def test_owner_snapshot_has_no_embedded_interpreter() raises:
    var owners = legacy_mojo_bridge_owner_snapshot()
    assert_equal(len(owners), 11)
    assert_equal(owners[0], "module=mojo_bridge.py")
    assert_equal(owners[7], "embedded_python=none")
    assert_equal(owners[9], "reta_line_bridge=native-argv-owner")
    assert_equal(owners[10], "prompt_line_bridge=payload-owner")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
