"""Native owner for the interactive ``prompt_interaction.py`` controller.

The terminal editor, prompt language, preparation and command execution already
have dedicated native owners.  This module owns the startup-to-session lifecycle
and one-shot command assembly.  Physical input reaction, local prompt reaction
dispatch and external process execution plans are now split into dedicated
native owners so the future prompt-reaction library can stay independent from
``libreta_core_mojo``.

It deliberately returns typed plans instead of printing or executing commands.
``prompt_main.mojo`` remains the thin process entry point and performs the
observable I/O requested by these plans.
"""

from std.collections import List
from .prompt_language import PromptLanguageCatalog
from .prompt_runtime import (
    PromptStartup,
    effective_one_shot_tokens,
    join_prompt_tokens,
)
from .prompt_session import (
    NativePromptSession,
    new_prompt_session_for_language,
)
from .prompt_reaction_input import (
    INTERACTION_EXECUTE,
    INTERACTION_CONTINUE,
    INTERACTION_EXIT,
    PromptInteractionInputPlan,
    accept_prompt_reaction_input,
    prompt_command_updates_previous,
    prompt_line_updates_previous,
    record_prompt_session_command,
    record_prompt_session_line,
    prompt_reaction_input_contract_snapshot,
)


@fieldwise_init
struct NativePromptInteraction(Copyable):
    """Mutable state formerly spread across ``retaPrompt.py`` globals."""

    var session: NativePromptSession
    var language: String
    var one_shot: Bool
    var show_intro: Bool


def new_prompt_interaction(startup: PromptStartup) -> NativePromptInteraction:
    return NativePromptInteraction(
        new_prompt_session_for_language(
            startup.profile.logging_enabled,
            startup.profile.language,
        ),
        startup.profile.language,
        startup.profile.one_shot,
        startup.profile.show_intro,
    )


def prompt_interaction_one_shot_line(startup: PromptStartup) -> String:
    return join_prompt_tokens(effective_one_shot_tokens(startup))


def accept_prompt_input(
    mut interaction: NativePromptInteraction,
    line: String,
    catalog: PromptLanguageCatalog,
) raises -> PromptInteractionInputPlan:
    """Compatibility wrapper for the physical reaction-input owner."""
    return accept_prompt_reaction_input(
        interaction.session,
        interaction.language,
        line,
        catalog,
    )


def record_prompt_command(
    mut interaction: NativePromptInteraction,
    line: String,
    kind: Int,
) -> None:
    record_prompt_session_command(interaction.session, line, kind)


def record_prompt_line(
    mut interaction: NativePromptInteraction,
    line: String,
    kind: Int,
    language: String,
    catalog: PromptLanguageCatalog,
) raises -> None:
    """Record one executed line after compound reaction ownership checks."""
    record_prompt_session_line(interaction.session, line, kind, language, catalog)


def prompt_interaction_contract_snapshot() -> List[String]:
    """Stable ownership snapshot for the prompt controller lifecycle.

    Physical input reaction lives in ``prompt_reaction_input_contract_snapshot``.
    Local dispatch plans live in ``prompt_reaction_dispatch_contract_snapshot``.
    Process-dispatch details live in ``prompt_process_dispatch_contract_snapshot``.
    The interaction owner is now only the lightweight lifecycle shell around
    those future library boundaries.
    """

    return [
        "class=PromptInteractionBundle",
        "startup=native-profile-to-session",
        "one_shot=native-token-assembly",
        "reaction_input=delegated-native-input-owner",
        "reaction_dispatch=delegated-native-local-effect-owner",
        "terminal=delegated-native-editor",
        "execution=delegated-native-dispatch",
    ]
