"""Native composition facade for ``reta_architecture.prompt_execution``.

The historical Python module is large because it combines prompt parsing,
fraction management, table command composition and process effects.  The
individual deterministic owners already live in native modules.  This facade
freezes their public bundle and snapshot while the final interactive effect
loop remains an explicit migration boundary.
"""

from .prompt_execution_helpers import (
    PromptExecutionHelpersBundle,
    bootstrap_prompt_execution_helpers,
)


@fieldwise_init
struct PromptExecutionSnapshot(Copyable, Equatable):
    var class_name: String
    var command_runner: String
    var fraction_manager: String
    var reta_executor: String
    var i18n_prompt: String


@fieldwise_init
struct PromptExecutionBundle(Copyable):
    var command_runner: String
    var command_runner_owner: String
    var fraction_manager: String
    var fraction_manager_owner: String
    var reta_executor: String
    var reta_executor_owner: String
    var i18n_prompt: String
    var helpers: PromptExecutionHelpersBundle

    def snapshot(self) -> PromptExecutionSnapshot:
        return PromptExecutionSnapshot(
            "PromptExecutionBundle",
            self.command_runner.copy(),
            self.fraction_manager.copy(),
            self.reta_executor.copy(),
            self.i18n_prompt.copy(),
        )


def bootstrap_prompt_execution() -> PromptExecutionBundle:
    return PromptExecutionBundle(
        "PromptGrosseAusgabe",
        "prompt_table_execution.mojo",
        "bruchBereichsManagementAndWbefehl",
        "prompt_fraction_execution.mojo",
        "retaExecuteNprint",
        "native_reta_cli.mojo",
        "type",
        bootstrap_prompt_execution_helpers(),
    )


def prompt_execution_bundle_valid(bundle: PromptExecutionBundle) -> Bool:
    return (
        bundle.command_runner == "PromptGrosseAusgabe"
        and bundle.command_runner_owner == "prompt_table_execution.mojo"
        and bundle.fraction_manager
        == "bruchBereichsManagementAndWbefehl"
        and bundle.fraction_manager_owner
        == "prompt_fraction_execution.mojo"
        and bundle.reta_executor == "retaExecuteNprint"
        and bundle.reta_executor_owner == "native_reta_cli.mojo"
        and bundle.i18n_prompt == "type"
        and bundle.helpers.source_owner
        == "reta_architecture.prompt_execution"
    )


def prompt_execution_snapshot_json(
    snapshot: PromptExecutionSnapshot
) -> String:
    return (
        '{"class":"' + snapshot.class_name
        + '","command_runner":"' + snapshot.command_runner
        + '","fraction_manager":"' + snapshot.fraction_manager
        + '","reta_executor":"' + snapshot.reta_executor
        + '","i18n_prompt":"' + snapshot.i18n_prompt + '"}'
    )
