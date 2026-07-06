"""Native composition facade for ``reta_architecture.prompt_execution``.

The historical Python module combines prompt parsing, fraction management,
table command composition and process effects.  Its deterministic native
owners are recorded here in the exact 22-entry top-level surface order.
Terminal I/O belongs solely to the native prompt controller; unproved compound
commands remain an explicit compatibility boundary.
"""

from std.collections import List
from .prompt_language import (
    PromptExpansionResult,
    PromptLanguageCatalog,
    balanced_prompt_split,
    expand_compact_prompt_tokens,
    expand_prompt_replacements,
    prepare_prompt_tokens,
    prompt_vocabulary_alias,
    is_prompt_numeric_shortcut,
)
from .prompt_runtime import (
    PromptCommand,
    classify_prompt_command_localized,
    join_prompt_tokens,
)
from .prompt_historical_ownership import (
    is_prompt_numeric_syntax_token,
)
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
        PromptExecutionOwner("PromptVonGrosserAusgabeSonderBefehlAusgaben", "prompt_execution.mojo", "def plan_prompt_execution_routing"),
    ]


@fieldwise_init
struct PromptExecutionRoutingPlan(Copyable):
    """Shared parse/normalisation plan for prompt execution entry points.

    The interactive and one-shot controllers both need the same historical
    front half of ``PromptVonGrosserAusgabeSonderBefehlAusgaben``: raw token
    splitting, compact expansion, replacement normalisation, prepared-token
    selection for visible compact echo, single-command classification and the
    quiet-output flag.  Keeping that pure routing state here reduces the
    process controller to I/O and explicit boundary crossing.
    """

    var raw_tokens: List[String]
    var compact_expansion: PromptExpansionResult
    var normalized_tokens: List[String]
    var normalized_line: String
    var command: PromptCommand
    var prepared_tokens: List[String]
    var historical_echo: Bool
    var numeric_default: Bool
    var planning_tokens_are_prepared: Bool
    var planning_tokens: List[String]
    var quiet_echo: Bool


def prompt_execution_contains_token(values: List[String], needle: String) -> Bool:
    for index in range(len(values)):
        if values[index] == needle:
            return True
    return False


def prompt_execution_uses_historical_echo(
    raw_tokens: List[String], expansion: PromptExpansionResult
) -> Bool:
    if expansion.compact:
        return True
    return len(raw_tokens) > 0 and raw_tokens[0].byte_length() == 1


def prompt_execution_contains_numeric_shortcut(
    values: List[String], language: String, catalog: PromptLanguageCatalog
) -> Bool:
    for index in range(len(values)):
        if is_prompt_numeric_shortcut(catalog, language, values[index]):
            return True
    return False


def prompt_execution_is_pure_numeric_prompt(values: List[String]) -> Bool:
    if len(values) == 0:
        return False
    for index in range(len(values)):
        if not is_prompt_numeric_syntax_token(values[index]):
            return False
    return True


def prompt_execution_quiet_echo(
    values: List[String], language: String, catalog: PromptLanguageCatalog
) -> Bool:
    var quiet = prompt_vocabulary_alias(
        catalog,
        language,
        "command",
        "keineEinZeichenZeilenPlusKeineAusgabeWelcherBefehlEsWar",
    )
    return prompt_execution_contains_token(values, quiet)


def plan_prompt_execution_routing(
    line: String,
    language: String,
    catalog: PromptLanguageCatalog,
    force_e_command: Bool = False,
) raises -> PromptExecutionRoutingPlan:
    """Plan the shared non-I/O front half of prompt command execution."""

    var raw_tokens = balanced_prompt_split(line)
    var compact_expansion = expand_compact_prompt_tokens(
        catalog,
        language,
        raw_tokens,
        False,
        force_e_command,
    )
    var normalized_tokens = expand_prompt_replacements(
        catalog, language, compact_expansion.tokens
    )
    var normalized_line = join_prompt_tokens(normalized_tokens)
    var command = classify_prompt_command_localized(
        normalized_line, language, catalog
    )
    var prepared = prepare_prompt_tokens(
        catalog,
        language,
        raw_tokens,
        False,
        force_e_command,
    )
    var historical_echo = prompt_execution_uses_historical_echo(
        raw_tokens, compact_expansion
    )
    var numeric_default = prompt_execution_is_pure_numeric_prompt(raw_tokens)
    var planning_tokens_are_prepared = (
        historical_echo
        or numeric_default
        or prompt_execution_contains_numeric_shortcut(
            raw_tokens, language, catalog
        )
    )
    var planning_tokens = (
        prepared.tokens.copy()
        if planning_tokens_are_prepared
        else normalized_tokens.copy()
    )
    var quiet_echo = prompt_execution_quiet_echo(
        planning_tokens, language, catalog
    )
    return PromptExecutionRoutingPlan(
        raw_tokens^,
        compact_expansion^,
        normalized_tokens^,
        normalized_line^,
        command^,
        prepared.tokens.copy(),
        historical_echo,
        numeric_default,
        planning_tokens_are_prepared,
        planning_tokens^,
        quiet_echo,
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
