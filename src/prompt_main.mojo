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
    PromptExecutionRoutingPlan,
    plan_prompt_execution_routing,
    plan_prompt_execution_table_ownership,
    plan_prompt_execution_compact_announcement,
    plan_prompt_execution_historical_effects,
    plan_prompt_execution_mulpri_render,
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
    plan_prompt_fallback_process_dispatch,
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
    if not fallback_process.handled:
        return
    if not fallback_process.run_reta_prompt:
        return
    _ = run_reta_prompt_arguments_native(
        fallback_process.arguments,
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


def _run_native_mulpri(
    values: List[String], language: String, catalog: PromptLanguageCatalog
) raises -> Bool:
    var plan = plan_prompt_execution_mulpri_render(values, language, catalog)
    if not plan.handled:
        return False
    _print_lines(plan.output_lines)
    return True


def _print_compact_announcement_if_needed(
    routing: PromptExecutionRoutingPlan,
    source: String,
    language: String,
    catalog: PromptLanguageCatalog,
) -> None:
    var announcement = plan_prompt_execution_compact_announcement(
        routing, source, language, catalog
    )
    if announcement.should_print:
        # The Python Rich renderer produces one complete physical line here.
        # Keep that byte-level contract explicit instead of inferring it from
        # Rich's internal ``Console.print(..., end="")`` call.
        print(announcement.line, end="")


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
    var historical_echo = routing.historical_echo
    var planning_tokens = routing.planning_tokens.copy()
    var quiet_echo = routing.quiet_echo

    # The historical PromptGrosseAusgabe branch treats domain words as an
    # unordered command set.  Plan these table-backed commands before the
    # single-command dispatch so localized aliases and mixed command lines can
    # remain native as one or more invocations.
    var ownership = plan_prompt_execution_table_ownership(
        routing, profile.language, catalog
    )
    if ownership.owns_table or ownership.owns_mulpri:
        _print_compact_announcement_if_needed(
            routing, line, profile.language, catalog
        )
        var historical_effects = plan_prompt_execution_historical_effects(
            routing, profile.language, catalog
        )
        if historical_effects.show_short_commands:
            _print_commands(catalog, profile.language, True)
        if historical_effects.show_commands:
            _print_commands(catalog, profile.language, False)
        if historical_effects.show_help:
            _print_prompt_help()
        if historical_effects.clear_before_table:
            _print_compound_clear_lines()
        var handled_table = _run_native_table_plan(
            ownership.table_plan, historical_echo, quiet_echo
        )
        var handled_mulpri = _run_native_mulpri(
            planning_tokens, profile.language, catalog
        )
        if handled_table or handled_mulpri:
            if historical_effects.enable_logging:
                session.logging_enabled = True
            elif historical_effects.disable_logging:
                session.logging_enabled = False
            return True

    if ownership.fallback_required:
        _run_fallback(profile, line)
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
        if external_process.run_shell:
            _ = run_shell_prompt_arguments_native(external_process.arguments)
            return True
        if external_process.run_python:
            _ = run_python_prompt_arguments_native(external_process.arguments)
            return True
        if external_process.run_math:
            _ = run_math_prompt_arguments_native(external_process.arguments)
            return True
        if external_process.run_reta:
            if _run_native_reta_prompt_command(external_process.arguments):
                return True
            _ = run_reta_arguments_native(
                external_process.arguments, reference_root()
            )
            return True

    # Preserve the untouched source spelling at the compatibility boundary.
    # Native parsing already owns routing, but an unported operation must still
    # observe the Python reference's exact compact-command announcement and
    # later set normalisation.
    _run_fallback(profile, line)
    return True


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
    var historical_echo = routing.historical_echo
    var planning_tokens = routing.planning_tokens.copy()
    var quiet_echo = routing.quiet_echo
    var ownership = plan_prompt_execution_table_ownership(
        routing, profile.language, catalog
    )
    if ownership.owns_table or ownership.owns_mulpri:
        _print_compact_announcement_if_needed(
            routing, line, profile.language, catalog
        )
        var historical_effects = plan_prompt_execution_historical_effects(
            routing, profile.language, catalog
        )
        if historical_effects.show_short_commands:
            _print_commands(catalog, profile.language, True)
        if historical_effects.show_commands:
            _print_commands(catalog, profile.language, False)
        if historical_effects.show_help:
            _print_prompt_help()
        if historical_effects.clear_before_table:
            _print_compound_clear_lines()
        var handled_table = _run_native_table_plan(
            ownership.table_plan, historical_echo, quiet_echo
        )
        var handled_mulpri = _run_native_mulpri(
            planning_tokens, profile.language, catalog
        )
        if handled_table or handled_mulpri:
            return True

    if ownership.fallback_required:
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
        if external_process.run_reta:
            if _run_native_reta_prompt_command(external_process.arguments):
                return True
        return False
    return False


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
