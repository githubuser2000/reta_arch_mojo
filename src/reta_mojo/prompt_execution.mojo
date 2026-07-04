"""Native composition facade for ``reta_architecture.prompt_execution``.

The historical Python module combines prompt parsing, fraction management,
table command composition and process effects.  Its deterministic native
owners are recorded here in the exact 22-entry top-level surface order.
Terminal I/O belongs solely to the native prompt controller; unproved compound
commands remain an explicit compatibility boundary.
"""

from std.collections import List
from .prompt_execution_helpers import (
    PromptExecutionHelpersBundle,
    bootstrap_prompt_execution_helpers,
)


@fieldwise_init
struct PromptExecutionOwner(Copyable):
    var python_name: String
    var owner: String
    var evidence: String


def prompt_execution_owners() -> List[PromptExecutionOwner]:
    """Exact ownership map for every top-level Python execution surface."""
    return [
        PromptExecutionOwner("configure_prompt_execution", "prompt_execution.mojo", "bootstrap_prompt_execution"),
        PromptExecutionOwner("PromptExecutionBundle", "prompt_execution.mojo", "struct PromptExecutionBundle"),
        PromptExecutionOwner("bootstrap_prompt_execution", "prompt_execution.mojo", "def bootstrap_prompt_execution"),
        PromptExecutionOwner("anotherOberesMaximum", "prompt_execution_helpers.mojo", "def anotherOberesMaximum"),
        PromptExecutionOwner("returnOnlyParasAsList", "prompt_execution_helpers.mojo", "def returnOnlyParasAsList"),
        PromptExecutionOwner("grKl", "prompt_execution_helpers.mojo", "def grKl"),
        PromptExecutionOwner("getDictLimtedByKeyList", "prompt_execution_helpers.mojo", "def getDictLimtedByKeyList"),
        PromptExecutionOwner("bruchSpalt", "prompt_fraction_execution.mojo", "def parse_prompt_fraction"),
        PromptExecutionOwner("dictToList", "prompt_execution_helpers.mojo", "def dictToList"),
        PromptExecutionOwner("createRangesForBruchLists", "prompt_fraction_execution.mojo", "def create_prompt_fraction_range"),
        PromptExecutionOwner("vorherVonAusschnittOderZaehlung", "prompt_execution_helpers.mojo", "def vorherVonAusschnittOderZaehlung"),
        PromptExecutionOwner("PromptGrosseAusgabe", "prompt_execution_runtime.mojo", "def render_prompt_table_plan"),
        PromptExecutionOwner("retaCmdAbstraction_n_and_1pron", "prompt_table_execution.mojo", "def plan_prompt_table_commands"),
        PromptExecutionOwner("ifPrintCmdAgain", "prompt_legacy_echo.mojo", "def compact_prompt_announcement_line"),
        PromptExecutionOwner("zeiln1234create", "prompt_table_execution.mojo", "def _base_table_tokens"),
        PromptExecutionOwner("retaExecuteNprint", "native_reta_cli.mojo", "def run_native_reta"),
        PromptExecutionOwner("findEqualNennerZaehler", "prompt_fraction_execution.mojo", "def equal_fraction_axes"),
        PromptExecutionOwner("findNennerZaehlerMakesWholeNum", "prompt_fraction_execution.mojo", "def whole_fraction_axes"),
        PromptExecutionOwner("bruchBereichsManagementAndWbefehl", "prompt_fraction_execution.mojo", "def create_prompt_fraction_range"),
        PromptExecutionOwner("addMoreVals2", "prompt_fraction_execution.mojo", "def add_prompt_fraction_value"),
        PromptExecutionOwner("addMoreVals", "prompt_fraction_execution.mojo", "def add_prompt_fraction_value"),
        PromptExecutionOwner("PromptVonGrosserAusgabeSonderBefehlAusgaben", "prompt_main.mojo", "def _run_command"),
    ]


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
    var ownership_count: Int

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
        "prompt_execution_runtime.mojo",
        "bruchBereichsManagementAndWbefehl",
        "prompt_fraction_execution.mojo",
        "retaExecuteNprint",
        "native_reta_cli.mojo",
        "type",
        bootstrap_prompt_execution_helpers(),
        len(prompt_execution_owners()),
    )


def prompt_execution_bundle_valid(bundle: PromptExecutionBundle) -> Bool:
    return (
        bundle.command_runner == "PromptGrosseAusgabe"
        and bundle.command_runner_owner == "prompt_execution_runtime.mojo"
        and bundle.fraction_manager
        == "bruchBereichsManagementAndWbefehl"
        and bundle.fraction_manager_owner
        == "prompt_fraction_execution.mojo"
        and bundle.reta_executor == "retaExecuteNprint"
        and bundle.reta_executor_owner == "native_reta_cli.mojo"
        and bundle.i18n_prompt == "type"
        and bundle.helpers.source_owner
        == "reta_architecture.prompt_execution"
        and bundle.ownership_count == 22
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
