from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.prompt_execution import *


def test_bundle_maps_large_python_owner_to_native_components() raises:
    var bundle = bootstrap_prompt_execution()
    assert_true(prompt_execution_bundle_valid(bundle))
    assert_equal(bundle.command_runner_owner, "prompt_execution_runtime.mojo")
    assert_equal(
        bundle.fraction_manager_owner, "prompt_fraction_execution.mojo"
    )
    assert_equal(bundle.reta_executor_owner, "native_reta_cli.mojo")
    assert_equal(bundle.ownership_count, 22)


def test_snapshot_matches_python_architecture_surface() raises:
    var snapshot = bootstrap_prompt_execution().snapshot()
    assert_equal(snapshot.class_name, "PromptExecutionBundle")
    assert_equal(snapshot.command_runner, "PromptGrosseAusgabe")
    assert_equal(
        snapshot.fraction_manager, "bruchBereichsManagementAndWbefehl"
    )
    assert_equal(snapshot.reta_executor, "retaExecuteNprint")
    assert_equal(snapshot.i18n_prompt, "type")
    assert_equal(
        prompt_execution_snapshot_json(snapshot),
        '{"class":"PromptExecutionBundle","command_runner":"PromptGrosseAusgabe","fraction_manager":"bruchBereichsManagementAndWbefehl","reta_executor":"retaExecuteNprint","i18n_prompt":"type"}',
    )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
