"""Native Mojo controller for retaPrompt, rp, rpl, rpb and rpe.

The public shell launchers pass a profile name as the first private argument.
Prompt profiles, state, dispatch, history policy and arithmetic commands are
native Mojo. Advanced historical shorthand commands cross the explicit Python
compatibility boundary until their translation layer is ported.
"""

from std.sys import argv
from std.collections import List
from std.python import Python, PythonObject
from reta_mojo.prompt_language import (
    PromptExpansionResult,
    PromptLanguageCatalog,
    balanced_prompt_split,
    expand_compact_prompt_tokens,
    expand_prompt_replacements,
    load_prompt_language_catalog,
    prompt_completion_word_pool,
    prompt_root_commands,
)
from reta_mojo.prompt_table_execution import (
    PromptTablePlan,
    plan_prompt_table_commands,
)
from reta_mojo.native_reta_cli import (
    native_reta_tokens_supported,
    run_native_reta,
)
from reta_mojo.prompt_runtime import (
    KIND_EMPTY,
    KIND_EXIT,
    KIND_HELP,
    KIND_COMMANDS,
    KIND_SHORT_COMMANDS,
    KIND_LOG_ON,
    KIND_LOG_OFF,
    KIND_CLEAR,
    KIND_PRIME,
    KIND_MULTIS,
    KIND_MULTIS3,
    KIND_PRIME_COMPARE,
    KIND_DISTANCE,
    KIND_DISTANCE_PRIME,
    KIND_MODULO,
    KIND_ABC,
    KIND_SHELL,
    KIND_PYTHON,
    KIND_MATH,
    KIND_RETA,
    KIND_PRIME24,
    KIND_STORE_NEXT,
    KIND_STORE_PREVIOUS,
    KIND_OUTPUT_STORED,
    KIND_DELETE_STORED,
    PromptProfile,
    PromptCommand,
    PromptStartup,
    classify_prompt_command_localized,
    parse_prompt_startup,
    fallback_profile_arguments,
    effective_one_shot_tokens,
    join_prompt_tokens,
    prime_lines,
    multis_lines,
    multis3_lines,
    modulo_lines,
    prime_comparison_lines,
    distance_lines,
    abc_line,
    NativePromptSession,
    new_prompt_session,
    prompt_prefix,
    store_prompt_text,
    stored_prompt_text,
    storage_payload,
    stored_prompt_numbered,
    delete_stored_selection,
)


def _print_lines(values: List[String]) -> None:
    for index in range(len(values)):
        print(values[index])


def _clear_terminal_native() -> None:
    print("\x1b[2J\x1b[H", end="")


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
    print("Stabile Bruchausschlüsse, Bruchteiler und Reziprok-Vielfache")
    print("werden ebenfalls nativ geplant; kollidierende Legacy-Algebra und")
    print("echte v-n/m-Vielfache bleiben an der Kompatibilitätsgrenze.")
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


def _encode_fields(values: List[String]) -> String:
    var encoded = String()
    for index in range(len(values)):
        if index > 0:
            encoded += "\x1f"
        encoded += values[index]
    return encoded^


def _read_line(
    bridge: PythonObject,
    profile: PromptProfile,
    session: NativePromptSession,
    catalog: PromptLanguageCatalog,
) raises -> String:
    var fields = List[String]()
    fields.append(prompt_prefix(session))
    fields.append("1" if session.logging_enabled else "0")
    fields.append("1" if profile.vi_mode else "0")
    fields.append("~/.ReTaPromptHistory")
    fields.append(profile.language)
    var words = prompt_completion_word_pool(catalog, profile.language)
    for index in range(len(words)):
        fields.append(words[index])
    return String(py=bridge.read_prompt_line_encoded(_encode_fields(fields)))


def _run_fallback(
    bridge: PythonObject,
    profile: PromptProfile,
    line: String,
) raises -> None:
    var flags = fallback_profile_arguments(profile)
    var encoded = _encode_fields(flags) + "\x1e" + line
    bridge.run_reta_prompt_line_encoded(encoded)


def _run_native_table_tokens(tokens: List[String]) raises -> Bool:
    if len(tokens) == 0:
        return False
    var command_line = String("reta")
    for index in range(len(tokens)):
        command_line += " " + tokens[index]
    print(command_line)
    print(
        run_native_reta(tokens, "python_reference/csv/religion.csv"),
        end="",
    )
    return True


def _run_native_reta_prompt_command(command: PromptCommand) raises -> Bool:
    if command.kind != KIND_RETA or len(command.words) < 1:
        return False
    var tokens = List[String]()
    for index in range(1, len(command.words)):
        tokens.append(command.words[index])
    var csv_path = String("python_reference/csv/religion.csv")
    if not native_reta_tokens_supported(tokens, csv_path):
        return False
    print(run_native_reta(tokens, csv_path), end="")
    return True


def _run_native_table_plan(plan: PromptTablePlan) raises -> Bool:
    if not plan.handled:
        return False
    if len(plan.invocations) == 0:
        return True
    for index in range(len(plan.invocations)):
        if not _run_native_table_tokens(plan.invocations[index].tokens):
            return False
    return True


def _uses_historical_compact_echo(
    raw_tokens: List[String], expansion: PromptExpansionResult
) -> Bool:
    """Return true when Python owns the visibly echoed shorthand spelling."""
    if expansion.compact:
        return True
    if len(raw_tokens) == 0:
        return False
    # One-letter vocabulary replacements such as ``a 2`` are not marked as
    # compact. Their historical echoed reta command still differs from the
    # canonical native spelling, so retain the source form at the boundary.
    return raw_tokens[0].byte_length() == 1


def _run_command(
    bridge: PythonObject,
    profile: PromptProfile,
    line: String,
    mut session: NativePromptSession,
    catalog: PromptLanguageCatalog,
) raises -> Bool:
    """Run one command and return false when the loop should terminate."""
    var raw_tokens = balanced_prompt_split(line)
    var compact_expansion = expand_compact_prompt_tokens(
        catalog,
        profile.language,
        raw_tokens,
        False,
        profile.force_e_command,
    )
    var normalized_tokens = expand_prompt_replacements(
        catalog, profile.language, compact_expansion.tokens
    )
    var normalized_line = join_prompt_tokens(normalized_tokens)
    var command = classify_prompt_command_localized(
        normalized_line, profile.language, catalog
    )
    if command.kind == KIND_EMPTY:
        return True
    if command.kind == KIND_EXIT:
        return False
    if command.kind == KIND_HELP:
        _print_prompt_help()
        return True
    if command.kind == KIND_COMMANDS:
        _print_commands(catalog, profile.language, False)
        return True
    if command.kind == KIND_SHORT_COMMANDS:
        _print_commands(catalog, profile.language, True)
        return True
    if command.kind == KIND_LOG_ON:
        session.logging_enabled = True
        print("Logging ist eingeschaltet.")
        return True
    if command.kind == KIND_LOG_OFF:
        session.logging_enabled = False
        print("Logging ist ausgeschaltet.")
        return True
    if command.kind == KIND_STORE_NEXT:
        var payload = storage_payload(command)
        if payload.byte_length() == 0:
            session.store_next = True
            print("Der nächste Befehl wird gespeichert.")
        else:
            store_prompt_text(session, payload)
            print("Gespeichert:", stored_prompt_text(session))
        return True
    if command.kind == KIND_STORE_PREVIOUS:
        var payload = storage_payload(command)
        if payload.byte_length() == 0:
            payload = session.previous_command
        if payload.byte_length() > 0:
            store_prompt_text(session, payload)
            print("Gespeichert:", stored_prompt_text(session))
        return True
    if command.kind == KIND_OUTPUT_STORED:
        var stored = stored_prompt_text(session)
        var addition = storage_payload(command)
        if stored.byte_length() == 0:
            print("Kein Befehl gespeichert.")
            return True
        if addition.byte_length() > 0:
            stored += " " + addition
        return _run_command(bridge, profile, stored, session, catalog)
    if command.kind == KIND_DELETE_STORED:
        var selection = storage_payload(command)
        if selection.byte_length() > 0:
            delete_stored_selection(session, selection)
            print("Gespeichert:", stored_prompt_text(session))
        else:
            var numbered = stored_prompt_numbered(session)
            if len(numbered) == 0:
                print("Kein Befehl gespeichert.")
            else:
                _print_lines(numbered)
                session.delete_next = True
        return True
    if command.kind == KIND_CLEAR:
        _clear_terminal_native()
        return True
    if _uses_historical_compact_echo(raw_tokens, compact_expansion):
        _run_fallback(bridge, profile, line)
        return True

    # The historical PromptGrosseAusgabe branch treats domain words as an
    # unordered command set.  Plan these table-backed commands before the
    # single-command dispatch so localized aliases and mixed command lines can
    # remain native as one or more invocations.
    var table_plan = plan_prompt_table_commands(
        normalized_tokens, profile.language, catalog
    )
    if _run_native_table_plan(table_plan):
        return True

    if command.kind == KIND_PRIME:
        _print_lines(prime_lines(command))
        return True
    if command.kind == KIND_PRIME24:
        _print_lines(prime_lines(command, True))
        return True
    if command.kind == KIND_MULTIS:
        _print_lines(multis_lines(command))
        return True
    if command.kind == KIND_MULTIS3:
        _print_lines(multis3_lines(command))
        return True
    if command.kind == KIND_MODULO:
        _print_lines(modulo_lines(command))
        return True
    if command.kind == KIND_PRIME_COMPARE:
        _print_lines(prime_comparison_lines(command, profile.language))
        return True
    if command.kind == KIND_DISTANCE:
        if len(command.words) == 3:
            _print_lines(distance_lines(command, False, profile.language))
            return True
    if command.kind == KIND_DISTANCE_PRIME:
        if len(command.words) == 3:
            _print_lines(distance_lines(command, True, profile.language))
            return True
    if command.kind == KIND_ABC:
        var line_out = abc_line(command)
        if line_out.byte_length() > 0:
            print(line_out)
        return True
    if command.kind == KIND_SHELL:
        bridge.run_shell_prompt_line(command.raw)
        return True
    if command.kind == KIND_PYTHON:
        bridge.run_python_prompt_line(command.raw)
        return True
    if command.kind == KIND_MATH:
        bridge.run_math_prompt_line(command.raw)
        return True
    if command.kind == KIND_RETA:
        if _run_native_reta_prompt_command(command):
            return True
        bridge.run_reta_line(command.raw)
        return True

    # Preserve the untouched source spelling at the compatibility boundary.
    # Native parsing already owns routing, but an unported operation must still
    # observe the Python reference's exact compact-command announcement and
    # later set normalisation.
    _run_fallback(bridge, profile, line)
    return True


def _run_native_one_shot(
    profile: PromptProfile,
    line: String,
    catalog: PromptLanguageCatalog,
) raises -> Bool:
    """Handle a fully owned one-shot command before importing Python.

    Compact commands whose historical echo spelling is not yet typed, storage
    operations and genuinely unported branches return ``False`` and enter the
    explicit compatibility path in ``main``.
    """
    var raw_tokens = balanced_prompt_split(line)
    var compact_expansion = expand_compact_prompt_tokens(
        catalog,
        profile.language,
        raw_tokens,
        False,
        profile.force_e_command,
    )
    var normalized_tokens = expand_prompt_replacements(
        catalog, profile.language, compact_expansion.tokens
    )
    var normalized_line = join_prompt_tokens(normalized_tokens)
    var command = classify_prompt_command_localized(
        normalized_line, profile.language, catalog
    )

    if command.kind == KIND_EMPTY or command.kind == KIND_EXIT:
        return True
    if command.kind == KIND_HELP:
        _print_prompt_help()
        return True
    if command.kind == KIND_COMMANDS:
        _print_commands(catalog, profile.language, False)
        return True
    if command.kind == KIND_SHORT_COMMANDS:
        _print_commands(catalog, profile.language, True)
        return True
    if command.kind == KIND_LOG_ON:
        print("Logging ist eingeschaltet.")
        return True
    if command.kind == KIND_LOG_OFF:
        print("Logging ist ausgeschaltet.")
        return True
    if command.kind == KIND_CLEAR:
        _clear_terminal_native()
        return True
    if _uses_historical_compact_echo(raw_tokens, compact_expansion):
        return False

    var table_plan = plan_prompt_table_commands(
        normalized_tokens, profile.language, catalog
    )
    if _run_native_table_plan(table_plan):
        return True

    if command.kind == KIND_PRIME:
        _print_lines(prime_lines(command))
        return True
    if command.kind == KIND_PRIME24:
        _print_lines(prime_lines(command, True))
        return True
    if command.kind == KIND_MULTIS:
        _print_lines(multis_lines(command))
        return True
    if command.kind == KIND_MULTIS3:
        _print_lines(multis3_lines(command))
        return True
    if command.kind == KIND_MODULO:
        _print_lines(modulo_lines(command))
        return True
    if command.kind == KIND_PRIME_COMPARE:
        _print_lines(prime_comparison_lines(command, profile.language))
        return True
    if command.kind == KIND_DISTANCE and len(command.words) == 3:
        _print_lines(distance_lines(command, False, profile.language))
        return True
    if command.kind == KIND_DISTANCE_PRIME and len(command.words) == 3:
        _print_lines(distance_lines(command, True, profile.language))
        return True
    if command.kind == KIND_ABC:
        var line_out = abc_line(command)
        if line_out.byte_length() > 0:
            print(line_out)
        return True
    if _run_native_reta_prompt_command(command):
        return True
    return False


def _one_shot_line(startup: PromptStartup) -> String:
    return join_prompt_tokens(effective_one_shot_tokens(startup))


def main() raises:
    var args = argv()
    if len(args) < 2:
        raise Error("interner Fehler: Promptprofil fehlt")

    var profile_name = String(args[1])
    var startup_args = List[String]()
    for index in range(2, len(args)):
        startup_args.append(String(args[index]))
    var startup = parse_prompt_startup(profile_name, startup_args)
    var prompt_catalog = load_prompt_language_catalog("assets")

    for index in range(len(startup.diagnostics)):
        print("Hinweis:", startup.diagnostics[index])
    if startup.show_help:
        _print_start_help()
        return

    if startup.profile.one_shot:
        var line = _one_shot_line(startup)
        if line.byte_length() == 0:
            raise Error("-befehl benötigt einen Promptbefehl")
        if _run_native_one_shot(startup.profile, line, prompt_catalog):
            return

    Python.add_to_path("python_reference")
    var bridge = Python.import_module("mojo_bridge")
    var session = new_prompt_session(startup.profile.logging_enabled)

    if startup.profile.show_intro and not startup.profile.one_shot:
        print(
            "retaPrompt: nativer Mojo-Controller; Hilfe mit 'hilfe', Ende mit"
            " 'q'."
        )

    if startup.profile.one_shot:
        var line = _one_shot_line(startup)
        _ = _run_command(bridge, startup.profile, line, session, prompt_catalog)
        return

    while True:
        var line = _read_line(bridge, startup.profile, session, prompt_catalog)
        if line == "\x04" or line == "\x03":
            break
        if session.store_next:
            store_prompt_text(session, line)
            print("Gespeichert:", stored_prompt_text(session))
            continue
        if session.delete_next:
            var cancel = classify_prompt_command_localized(
                line, startup.profile.language, prompt_catalog
            )
            if cancel.kind == KIND_EXIT:
                session.delete_next = False
                print("Löschen abgebrochen.")
            else:
                delete_stored_selection(session, line)
                print("Gespeichert:", stored_prompt_text(session))
            continue
        if not _run_command(
            bridge, startup.profile, line, session, prompt_catalog
        ):
            break
        var executed = classify_prompt_command_localized(
            line, startup.profile.language, prompt_catalog
        )
        if (
            executed.kind != KIND_STORE_NEXT
            and executed.kind != KIND_STORE_PREVIOUS
            and executed.kind != KIND_OUTPUT_STORED
            and executed.kind != KIND_DELETE_STORED
            and executed.kind != KIND_LOG_ON
            and executed.kind != KIND_LOG_OFF
        ):
            session.previous_command = line
