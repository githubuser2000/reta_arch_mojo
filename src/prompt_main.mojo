"""Native Mojo controller for retaPrompt, rp, rpl, rpb and rpe.

The public shell launchers pass a profile name as the first private argument.
Prompt profiles, state, dispatch, history policy and arithmetic commands are
native Mojo. Renderer-stable historical shorthand commands also execute natively
through a separate legacy-presentation layer; unowned compound cases cross the
explicit Python compatibility boundary atomically.
"""

from std.sys import argv
from std.collections import List
from std.collections.string import ord
from reta_mojo.prompt_language import (
    PromptExpansionResult,
    PromptLanguageCatalog,
    load_prompt_language_catalog,
    prompt_root_commands,
    prompt_vocabulary_alias,
)
from reta_mojo.prompt_table_execution import (
    PromptTablePlan,
)
from reta_mojo.native_prompt_input import read_native_prompt_line
from reta_mojo.prompt_external_commands import (
    run_math_prompt_arguments_native,
    run_python_prompt_arguments_native,
    run_reta_arguments_native,
    run_reta_prompt_arguments_native,
    run_shell_prompt_arguments_native,
)
from reta_mojo.native_reta_cli import (
    native_reta_tokens_supported,
    run_native_reta,
)
from reta_mojo.prompt_execution_runtime import render_prompt_table_plan
from reta_mojo.prompt_execution import (
    PromptExecutionCompactAnnouncementPlan,
    PromptExecutionHistoricalEffectPlan,
    PromptExecutionNativeBranchPlan,
    plan_prompt_execution_routing,
    plan_prompt_execution_native_branch,
    plan_prompt_execution_native_branch_output,
    plan_prompt_execution_native_branch_outcome,
    plan_prompt_execution_native_branch_completion,
    plan_prompt_execution_compatibility_fallback,
    plan_prompt_execution_one_shot_compatibility_boundary,
    plan_prompt_execution_one_shot_residual_result,
    plan_prompt_execution_residual_compatibility_fallback,
)
from reta_mojo.native_cli_startup import native_cli_startup
from reta_mojo.resource_paths import asset_root, csv_resource, reference_root
from reta_mojo.terminal_geometry import (
    compound_clear_line_count,
    terminal_rows,
)
from reta_mojo.prompt_runtime import (
    PromptProfile,
    PromptCommand,
    PromptStartup,
    classify_prompt_command_localized,
    parse_prompt_startup,
)
from reta_mojo.prompt_session import (
    NativePromptSession,
    prompt_prefix,
    stored_prompt_text,
)
from reta_mojo.prompt_interaction import (
    NativePromptInteraction,
    new_prompt_interaction,
    prompt_interaction_one_shot_line,
)
from reta_mojo.prompt_reaction_input import (
    INTERACTION_EXECUTE,
    INTERACTION_CONTINUE,
    INTERACTION_EXIT,
    accept_prompt_reaction_input,
    record_prompt_session_line,
)
from reta_mojo.prompt_reaction_dispatch import (
    plan_loop_control_dispatch,
    plan_logging_dispatch,
    plan_one_shot_logging_dispatch,
    plan_terminal_clear_dispatch,
    plan_informational_dispatch,
    plan_simple_output_dispatch,
)
from reta_mojo.prompt_reaction_storage import (
    apply_inline_storage_command,
    plan_stored_command_dispatch,
    plan_inline_stored_output_command,
    plan_stored_output_command,
    plan_stored_delete_command,
)

from reta_mojo.prompt_process_dispatch import (
    plan_external_process_dispatch,
    plan_interactive_external_process_execution,
    plan_interactive_external_process_completion,
    plan_interactive_reference_reta_process_execution,
    plan_interactive_external_process_result,
    plan_prompt_compatibility_fallback_process_execution,
    plan_prompt_residual_fallback_process_execution,
    plan_prompt_residual_fallback_process_result,
    plan_one_shot_external_process_execution,
    plan_one_shot_external_process_boundary,
    plan_one_shot_external_process_result,
    plan_prompt_fallback_process_dispatch,
    plan_prompt_fallback_process_execution,
)

def _print_lines(values: List[String]) -> None:
    for index in range(len(values)):
        print(values[index])


def _clear_terminal_native() -> None:
    print("\x1b[2J\x1b[H", end="")


def _print_compound_clear_lines() -> None:
    # Python's table branch uses ``os.get_terminal_size().lines + 1`` blank
    # lines rather than the standalone ANSI clear command.
    for _ in range(compound_clear_line_count(terminal_rows())):
        print()


def _print_start_help() -> None:
    print("retaPrompt (nativer Mojo-Controller)")
    print("  -vi                 Vi-Eingabemodus")
    print("  -log                History-Protokollierung aktivieren")
    print("  -e                  historisches e-Kommando erzwingen")
    print("  -language=english   englische Befehlsoberfläche")
    print("  -befehl ...         genau einen Promptbefehl ausführen")
    print("  -debug              Diagnosemodus")
    print("  -h, -help           diese Startparameter anzeigen")
    print("")
    print("Profile: retaPrompt, rp, rpl, rpb und rpe")


def _print_prompt_help() -> None:
    print("Wichtige native Promptbefehle:")
    print("  q, :q, exit, quit, ende       Prompt beenden")
    print("  help, hilfe, h                Hilfe anzeigen")
    print("  befehle / kurzbefehle         Befehlsvokabular anzeigen")
    print("  loggen / nichtloggen          History umschalten")
    print("  prim ZAHLENBEREICH            Primfaktorzerlegung")
    print("  multis ZAHLENBEREICH          Faktorpaare")
    print("  multis3 ZAHLENBEREICH         Dreifach-Faktorisierungen")
    print("  modulo ZAHLENBEREICH          Modulo-Tabelle")
    print("  mond/richtung/primzahlkreuz   native Tabellenbefehle")
    print("  alles/thomas/emotion/geist    weitere native Tabellenpfade")
    print("  wirklichkeit/triebe/impulse   weitere native Tabellenpfade")
    print("  bewusstsein/groesse/freiheit  weitere native Tabellenpfade")
    print("  motiv/universum/netzwerk      weitere native Tabellenpfade")
    print("  abc WORT                       Buchstabenwerte")
    print("  reta ...                       vollständige reta-CLI")
    print("  shell ..., python ..., math ...")
    print("")
    print("Kompakte Zahlen- und Ein-Zeichen-Befehle werden nativ expandiert.")
    print("Positive Brüche, historische Bruchbereiche sowie ganzzahlige")
    print("Vielfachen-, Teiler- und Einzelauswahl werden nativ geplant.")
    print("Null-, Negativ- und kollidierende Zahlenbedingungen werden samt")
    print("historischer All-Zeilen-Algebra nativ geplant. Auch wiederholte")
    print("Katalogauswahlen, echte v-n/m-Vielfache und alle 13")
    print("Ausgabeparameter sind nativ; nur unbewiesene Sonderzweige fallen zurück.")
    print("Explizite native Einmalbefehle laufen ohne Python-Kindprozess.")


def _print_commands(
    catalog: PromptLanguageCatalog,
    language: String,
    short_only: Bool,
) -> None:
    var words = prompt_root_commands(catalog, language)
    var first = True
    for index in range(len(words)):
        var word = words[index]
        if short_only and word.byte_length() != 1:
            continue
        if not first:
            print(" ", end="")
        print(word, end="")
        first = False
    print()


def _read_line(
    profile: PromptProfile,
    session: NativePromptSession,
    catalog: PromptLanguageCatalog,
) raises -> String:
    return read_native_prompt_line(
        prompt_prefix(session),
        catalog,
        profile.language,
        profile.vi_mode,
        session.logging_enabled,
        "~/.ReTaPromptHistory",
    )


def _run_fallback(
    profile: PromptProfile,
    line: String,
) raises -> None:
    var fallback_process = plan_prompt_fallback_process_dispatch(profile, line)
    var fallback_execution = plan_prompt_fallback_process_execution(
        fallback_process
    )
    if not fallback_execution.should_execute:
        return
    _ = run_reta_prompt_arguments_native(
        fallback_execution.arguments,
        reference_root(),
    )


def _run_native_reta_prompt_command(tokens: List[String]) raises -> Bool:
    var startup = native_cli_startup(tokens)
    if startup.owned:
        print(startup.output, end="")
        return True
    var csv_path = csv_resource("religion.csv")
    if not native_reta_tokens_supported(tokens, csv_path):
        return False
    print(run_native_reta(tokens, csv_path), end="")
    return True


def _run_native_table_plan(
    plan: PromptTablePlan,
    historical_echo: Bool = False,
    suppress_command_echo: Bool = False,
) raises -> Bool:
    var execution = render_prompt_table_plan(
        plan,
        csv_resource("religion.csv"),
        historical_echo,
        suppress_command_echo,
    )
    if not execution.handled:
        return False
    for index in range(len(execution.invocations)):
        var invocation = execution.invocations[index].copy()
        if invocation.command_echo.byte_length() > 0:
            # Rich's historical Syntax renderable always occupied a complete
            # physical line, independently of the old ``end`` keyword.
            print(invocation.command_echo)
        print(invocation.table_output, end="")
    return True


def _print_compact_announcement(
    announcement: PromptExecutionCompactAnnouncementPlan
) -> None:
    if announcement.should_print:
        # The Python Rich renderer produces one complete physical line here.
        # Keep that byte-level contract explicit instead of inferring it from
        # Rich's internal ``Console.print(..., end="")`` call.
        print(announcement.line, end="")


def _print_prompt_execution_effects(
    effects: PromptExecutionHistoricalEffectPlan,
    catalog: PromptLanguageCatalog,
    language: String,
) -> None:
    if effects.show_short_commands:
        _print_commands(catalog, language, True)
    if effects.show_commands:
        _print_commands(catalog, language, False)
    if effects.show_help:
        _print_prompt_help()
    if effects.clear_before_table:
        _print_compound_clear_lines()


def _execute_owned_prompt_branch(
    branch: PromptExecutionNativeBranchPlan,
    catalog: PromptLanguageCatalog,
    language: String,
) raises -> Bool:
    _print_compact_announcement(branch.announcement)
    _print_prompt_execution_effects(branch.historical_effects, catalog, language)
    var handled_table = _run_native_table_plan(
        branch.ownership.table_plan, branch.historical_echo, branch.quiet_echo
    )
    if branch.mulpri_render.handled:
        _print_lines(branch.mulpri_render.output_lines)
    var output = plan_prompt_execution_native_branch_output(
        branch, handled_table
    )
    return output.handled


def _run_command(
    profile: PromptProfile,
    line: String,
    mut session: NativePromptSession,
    catalog: PromptLanguageCatalog,
) raises -> Bool:
    """Run one command and return false when the loop should terminate."""
    var routing = plan_prompt_execution_routing(
        line, profile.language, catalog, profile.force_e_command
    )
    var raw_tokens = routing.raw_tokens.copy()
    var command = routing.command.copy()
    if apply_inline_storage_command(
        session, raw_tokens, profile.language, catalog
    ):
        print("Gespeichert:", stored_prompt_text(session))
        return True
    var inline_output = plan_inline_stored_output_command(
        raw_tokens, session, profile.language, catalog
    )
    if inline_output.handled:
        _print_lines(inline_output.output_lines)
        if inline_output.command_line.byte_length() == 0:
            return True
        return _run_command(profile, inline_output.command_line, session, catalog)
    var loop_control = plan_loop_control_dispatch(command)
    if loop_control.handled:
        return loop_control.continue_loop
    var stored_dispatch = plan_stored_command_dispatch(command, session)
    if stored_dispatch.handled:
        _print_lines(stored_dispatch.output_lines)
        return True
    var logging_dispatch = plan_logging_dispatch(command, session)
    if logging_dispatch.handled:
        _print_lines(logging_dispatch.output_lines)
        return True
    var stored_output = plan_stored_output_command(command, session)
    if stored_output.handled:
        _print_lines(stored_output.output_lines)
        if stored_output.command_line.byte_length() == 0:
            return True
        return _run_command(profile, stored_output.command_line, session, catalog)
    var stored_delete = plan_stored_delete_command(command, session)
    if stored_delete.handled:
        _print_lines(stored_delete.output_lines)
        return True
    # The historical PromptGrosseAusgabe branch treats domain words as an
    # unordered command set.  Plan these table-backed commands before the
    # single-command dispatch so localized aliases and mixed command lines can
    # remain native as one or more invocations.
    var native_branch = plan_prompt_execution_native_branch(
        routing, line, profile.language, catalog
    )
    var native_handled = False
    if native_branch.should_try_native:
        native_handled = _execute_owned_prompt_branch(
            native_branch, catalog, profile.language
        )
    var outcome = plan_prompt_execution_native_branch_outcome(
        native_branch, native_handled
    )
    var completion = plan_prompt_execution_native_branch_completion(
        outcome, session.logging_enabled
    )
    if completion.handled:
        if completion.session_logging.update:
            session.logging_enabled = completion.session_logging.enabled
        return True
    var compatibility_fallback = plan_prompt_execution_compatibility_fallback(
        completion, line
    )
    # Previous source guards still document the older controller shape:
    # if compatibility_fallback.should_run:
    # _run_fallback(profile, compatibility_fallback.source)
    var compatibility_execution = plan_prompt_compatibility_fallback_process_execution(
        profile, compatibility_fallback
    )
    if compatibility_execution.should_execute:
        _ = run_reta_prompt_arguments_native(
            compatibility_execution.arguments, reference_root()
        )
        return True

    var info_dispatch = plan_informational_dispatch(command)
    if info_dispatch.handled:
        if info_dispatch.show_help:
            _print_prompt_help()
        if info_dispatch.show_commands:
            _print_commands(catalog, profile.language, False)
        if info_dispatch.show_short_commands:
            _print_commands(catalog, profile.language, True)
        return True
    var terminal_clear = plan_terminal_clear_dispatch(command)
    if terminal_clear.handled:
        _print_lines(terminal_clear.output_lines)
        if terminal_clear.clear_terminal:
            _clear_terminal_native()
        return True

    var simple_output = plan_simple_output_dispatch(command, profile.language)
    if simple_output.handled:
        _print_lines(simple_output.output_lines)
        return True

    var external_process = plan_external_process_dispatch(command)
    if external_process.handled:
        var external_execution = plan_interactive_external_process_execution(
            external_process
        )
        var reta_native_handled = False
        if external_execution.should_run_shell:
            _ = run_shell_prompt_arguments_native(external_execution.arguments)
        if external_execution.should_run_python:
            _ = run_python_prompt_arguments_native(external_execution.arguments)
        if external_execution.should_run_math:
            _ = run_math_prompt_arguments_native(external_execution.arguments)
        if external_execution.should_run_reta:
            reta_native_handled = _run_native_reta_prompt_command(
                external_execution.arguments
            )
        var external_completion = plan_interactive_external_process_completion(
            external_process, reta_native_handled
        )
        var reference_reta_execution = plan_interactive_reference_reta_process_execution(
            external_completion, external_execution
        )
        if reference_reta_execution.should_run_reference_reta:
            _ = run_reta_arguments_native(
                reference_reta_execution.arguments, reference_root()
            )
        # Previous completion-owner stage returned directly here:
        # return external_completion.handled
        var external_result = plan_interactive_external_process_result(
            external_completion, reference_reta_execution
        )
        return external_result.handled

    # Preserve the untouched source spelling at the compatibility boundary.
    # Native parsing already owns routing, but an unported operation must still
    # observe the Python reference's exact compact-command announcement and
    # later set normalisation.
    var residual_fallback = plan_prompt_execution_residual_compatibility_fallback(line)
    var residual_execution = plan_prompt_residual_fallback_process_execution(
        profile, residual_fallback
    )
    if residual_execution.should_execute:
        _ = run_reta_prompt_arguments_native(
            residual_execution.arguments, reference_root()
        )
    var residual_result = plan_prompt_residual_fallback_process_result(
        residual_execution
    )
    return residual_result.handled


def _run_native_one_shot(
    profile: PromptProfile,
    line: String,
    catalog: PromptLanguageCatalog,
) raises -> Bool:
    """Handle a fully owned one-shot command before importing Python.

    Renderer-stable compact commands use typed historical presentation while
    storage operations, renderer-sensitive compounds and genuinely unported
    branches return ``False`` and enter the compatibility path in ``main``.
    """
    var routing = plan_prompt_execution_routing(
        line, profile.language, catalog, profile.force_e_command
    )
    var command = routing.command.copy()

    var loop_control = plan_loop_control_dispatch(command)
    if loop_control.handled:
        return True
    var native_branch = plan_prompt_execution_native_branch(
        routing, line, profile.language, catalog
    )
    var native_handled = False
    if native_branch.should_try_native:
        native_handled = _execute_owned_prompt_branch(
            native_branch, catalog, profile.language
        )
    var outcome = plan_prompt_execution_native_branch_outcome(
        native_branch, native_handled
    )
    var completion = plan_prompt_execution_native_branch_completion(
        outcome, False
    )
    if completion.handled:
        return True
    var compatibility_fallback = plan_prompt_execution_compatibility_fallback(
        completion, line
    )
    var compatibility_boundary = plan_prompt_execution_one_shot_compatibility_boundary(
        compatibility_fallback, False
    )
    if compatibility_boundary.stop_native_probe:
        return False

    var info_dispatch = plan_informational_dispatch(command)
    if info_dispatch.handled:
        if info_dispatch.show_help:
            _print_prompt_help()
        if info_dispatch.show_commands:
            _print_commands(catalog, profile.language, False)
        if info_dispatch.show_short_commands:
            _print_commands(catalog, profile.language, True)
        return True
    var terminal_clear = plan_terminal_clear_dispatch(command)
    if terminal_clear.handled:
        _print_lines(terminal_clear.output_lines)
        if terminal_clear.clear_terminal:
            _clear_terminal_native()
        return True

    var one_shot_logging = plan_one_shot_logging_dispatch(command)
    if one_shot_logging.handled:
        _print_lines(one_shot_logging.output_lines)
        return True

    var simple_output = plan_simple_output_dispatch(command, profile.language)
    if simple_output.handled:
        _print_lines(simple_output.output_lines)
        return True

    var external_process = plan_external_process_dispatch(command)
    if external_process.handled:
        var one_shot_external_execution = plan_one_shot_external_process_execution(
            external_process
        )
        var reta_native_handled = False
        if one_shot_external_execution.should_try_reta_native:
            reta_native_handled = _run_native_reta_prompt_command(
                one_shot_external_execution.arguments
            )
        var external_boundary = plan_one_shot_external_process_boundary(
            external_process, reta_native_handled
        )
        # Previous one-shot boundary stage returned directly here:
        # if external_boundary.stop_native_probe:
        #     return False
        # return external_boundary.handled_without_boundary
        var external_result = plan_one_shot_external_process_result(
            external_boundary
        )
        return external_result.handled

    # Preserve the untouched one-shot source at the same residual compatibility
    # boundary as the interactive controller.  The main one-shot caller remains
    # responsible for entering the compatibility path after this native probe
    # returns False.
    var one_shot_residual_fallback = plan_prompt_execution_residual_compatibility_fallback(
        line
    )
    var one_shot_residual_boundary = plan_prompt_execution_one_shot_compatibility_boundary(
        one_shot_residual_fallback, True
    )
    # Previous one-shot residual stage returned directly from the boundary:
    # if one_shot_residual_boundary.stop_native_probe:
    #     return False
    # return one_shot_residual_boundary.handled_without_fallback
    var one_shot_residual_result = plan_prompt_execution_one_shot_residual_result(
        one_shot_residual_boundary
    )
    return one_shot_residual_result.handled


def main() raises:
    var args = argv()
    if len(args) < 2:
        raise Error("interner Fehler: Promptprofil fehlt")

    var profile_name = String(args[1])
    var startup_args = List[String]()
    for index in range(2, len(args)):
        startup_args.append(String(args[index]))
    var startup = parse_prompt_startup(profile_name, startup_args)
    var prompt_catalog = load_prompt_language_catalog(asset_root())

    for index in range(len(startup.diagnostics)):
        print("Hinweis:", startup.diagnostics[index])
    if startup.show_help:
        _print_start_help()
        return

    if startup.profile.one_shot:
        var line = prompt_interaction_one_shot_line(startup)
        if line.byte_length() == 0:
            raise Error("-befehl benötigt einen Promptbefehl")
        if _run_native_one_shot(startup.profile, line, prompt_catalog):
            return

    var interaction = new_prompt_interaction(startup)

    if interaction.show_intro and not interaction.one_shot:
        print(
            "retaPrompt: nativer Mojo-Controller; Hilfe mit 'hilfe', Ende mit"
            " 'q'."
        )

    if interaction.one_shot:
        var line = prompt_interaction_one_shot_line(startup)
        _ = _run_command(
            startup.profile, line, interaction.session, prompt_catalog
        )
        return

    while True:
        var physical_line = _read_line(
            startup.profile, interaction.session, prompt_catalog
        )
        var input_plan = accept_prompt_reaction_input(
            interaction.session,
            interaction.language, physical_line, prompt_catalog
        )
        _print_lines(input_plan.output_lines)
        if input_plan.action == INTERACTION_EXIT:
            break
        if input_plan.action == INTERACTION_CONTINUE:
            continue
        if input_plan.action != INTERACTION_EXECUTE:
            raise Error("unbekannter Prompt-Interaktionsplan")

        var line = input_plan.command_line
        if not _run_command(
            startup.profile, line, interaction.session, prompt_catalog
        ):
            break
        var executed = classify_prompt_command_localized(
            line, startup.profile.language, prompt_catalog
        )
        record_prompt_session_line(
            interaction.session,
            line,
            executed.kind,
            startup.profile.language,
            prompt_catalog,
        )
