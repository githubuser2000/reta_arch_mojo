"""Typed native compatibility owner for historical ``retaPrompt.py``.

The Python module is a thin import-time facade around prompt interaction,
session, preparation and execution owners.  This module replaces its mutable
module globals with one explicit value and keeps the historical public function
names as typed adapters.  Process I/O remains owned by ``prompt_main.mojo``;
there is no Python object, callback or child-process adapter in this compatibility layer.
"""

from std.collections import List
from .legacy_libreta_prompt import (
    LegacyLibRetaPromptBundle,
    bootstrap_legacy_libreta_prompt,
)
from .legacy_reta_prompt_catalog import (
    legacy_reta_prompt_exported_count,
    legacy_reta_prompt_exported_names,
)
from .prompt_runtime import PromptStartup, parse_prompt_startup
from .prompt_interaction import (
    NativePromptInteraction,
    PromptInteractionInputPlan,
    accept_prompt_input,
    new_prompt_interaction,
    prompt_interaction_contract_snapshot,
)
from .prompt_process_dispatch import prompt_process_dispatch_contract_snapshot
from .prompt_session import (
    NativePromptSession,
    PromptDeleteResult,
    PromptLoopSetup,
    PromptStoreResult,
    apply_storage_output,
    build_prompt_loop_setup,
    delete_stored_selection_result,
    new_prompt_session_for_language,
    store_prompt_text,
    stored_prompt_text,
)


@fieldwise_init
struct LegacyRetaPromptSnapshot(Copyable, Equatable):
    var exported_names_len: Int
    var commands_len: Int
    var commands2_len: Int
    var exit_commands_len: Int
    var language: String
    var logging_enabled: Bool
    var prompt_mode2: Int
    var additional_tokens_len: Int
    var native_controller: Bool


@fieldwise_init
struct LegacyRetaPromptBundle(Copyable):
    """Explicit replacement for the mutable globals of ``retaPrompt.py``."""

    var libretaPrompt: LegacyLibRetaPromptBundle
    var startup: PromptStartup
    var promptInteraction: NativePromptInteraction
    var befehle: List[String]
    var befehle2: List[String]
    var befehleBeenden: List[String]
    var infoLog: Bool
    var sprachenWahl: String
    var promptMode2: Int
    var textDazu0: List[String]

    def snapshot(self) -> LegacyRetaPromptSnapshot:
        return LegacyRetaPromptSnapshot(
            legacy_reta_prompt_exported_count(),
            len(self.befehle),
            len(self.befehle2),
            len(self.befehleBeenden),
            self.sprachenWahl,
            self.infoLog,
            self.promptMode2,
            len(self.textDazu0),
            True,
        )


def _copy_strings(values: List[String]) -> List[String]:
    var result = List[String]()
    for index in range(len(values)):
        result.append(values[index])
    return result^


def _exit_commands(language: String) -> List[String]:
    if language == "deutsch":
        return [":q", "ende", "exit", "q", "quit"]
    return [":q", "end", "exit", "q", "quit"]


def _sync_from_controller(mut facade: LegacyRetaPromptBundle) -> None:
    facade.infoLog = facade.promptInteraction.session.logging_enabled
    facade.sprachenWahl = facade.promptInteraction.language
    facade.promptMode2 = facade.promptInteraction.session.prompt_mode2


def bootstrap_legacy_reta_prompt(
    profile_name: String = "retaPrompt",
    arguments: List[String] = List[String](),
) raises -> LegacyRetaPromptBundle:
    var startup = parse_prompt_startup(profile_name, arguments)
    var libreta = bootstrap_legacy_libreta_prompt()
    var interaction = new_prompt_interaction(startup)
    var commands = _copy_strings(libreta.befehle)
    var commands2 = _copy_strings(libreta.befehle2)
    var exit_commands = _exit_commands(startup.profile.language)
    var logging_enabled = startup.profile.logging_enabled
    var language = startup.profile.language
    var prompt_mode2 = interaction.session.prompt_mode2
    return LegacyRetaPromptBundle(
        libreta^,
        startup^,
        interaction^,
        commands^,
        commands2^,
        exit_commands^,
        logging_enabled,
        language^,
        prompt_mode2,
        List[String](),
    )


def newSession(
    facade: LegacyRetaPromptBundle,
    history: Bool = False,
) -> NativePromptSession:
    return new_prompt_session_for_language(history, facade.sprachenWahl)


def speichern(
    mut facade: LegacyRetaPromptBundle,
    text: String,
) -> PromptStoreResult:
    store_prompt_text(facade.promptInteraction.session, text)
    _sync_from_controller(facade)
    return PromptStoreResult(
        stored_prompt_text(facade.promptInteraction.session),
        facade.promptMode2,
        facade.promptInteraction.session.stored_tokens.copy(),
    )


def PromptAllesVorGroesserSchleife(
    facade: LegacyRetaPromptBundle,
) -> PromptLoopSetup:
    return build_prompt_loop_setup(facade.startup, facade.befehleBeenden)


def PromptLoescheVorSpeicherungBefehle(
    mut facade: LegacyRetaPromptBundle,
    selection: String,
) raises -> PromptDeleteResult:
    var result = delete_stored_selection_result(
        facade.promptInteraction.session, selection
    )
    _sync_from_controller(facade)
    return result^


def promptSpeicherungB(
    pending_output: String,
    prompt_mode: Int,
    stored_text: String,
    current_text: String = "",
) -> String:
    return apply_storage_output(
        pending_output, prompt_mode, stored_text, current_text
    )


def promptSpeicherungA(
    mut facade: LegacyRetaPromptBundle,
    text: String,
) -> PromptStoreResult:
    return speichern(facade, text)


def promptInput(
    mut facade: LegacyRetaPromptBundle,
    line: String,
) raises -> PromptInteractionInputPlan:
    var result = accept_prompt_input(
        facade.promptInteraction,
        line,
        facade.libretaPrompt.promptLanguage,
    )
    _sync_from_controller(facade)
    return result^


def _legacy_prompt_scope_snapshot() -> List[String]:
    """Historical retaPrompt.py scope with reaction and process contracts.

    The native prompt-reaction owner no longer carries process-dispatch
    details.  Keep the compatibility facade's old observable PromptScope shape
    by composing the reaction contract with the prompt-execution process
    contract in the historical order.
    """
    var interaction = prompt_interaction_contract_snapshot()
    var process = prompt_process_dispatch_contract_snapshot()
    var result = List[String]()
    for index in range(15):
        result.append(interaction[index].copy())
    # Detailed external/fallback process markers, excluding the process bundle
    # class marker, the owner marker and the adapter implementation marker.
    for index in range(2, len(process) - 1):
        result.append(process[index].copy())
    result.append(process[1].copy())
    for index in range(15, len(interaction)):
        result.append(interaction[index].copy())
    return result^


def PromptScope(
    facade: LegacyRetaPromptBundle,
) -> List[String]:
    _ = facade
    return _legacy_prompt_scope_snapshot()


def start(
    mut facade: LegacyRetaPromptBundle,
    language: String = "deutsch",
) -> String:
    facade.startup.profile.language = language
    facade.promptInteraction.language = language
    facade.promptInteraction.session = new_prompt_session_for_language(
        facade.infoLog, language
    )
    facade.befehleBeenden = _exit_commands(language)
    _sync_from_controller(facade)
    return facade.sprachenWahl


def legacy_reta_prompt_owner_snapshot() -> List[String]:
    return [
        "module=retaPrompt.py",
        "surface=generated-exact-public-names",
        "globals=explicit-LegacyRetaPromptBundle",
        "session=prompt_session.mojo",
        "interaction=prompt_interaction.mojo",
        "preparation=prompt_preparation.mojo",
        "execution=prompt_execution.mojo+prompt_main.mojo",
        "parallel=parallel_execution.mojo",
        "terminal=prompt_terminal_input.mojo",
        "python_runtime=none",
    ]
