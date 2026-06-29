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
    PromptLanguageCatalog,
    balanced_prompt_split,
    expand_compact_prompt_tokens,
    expand_prompt_replacements,
    load_prompt_language_catalog,
    prompt_completion_word_pool,
    prompt_root_commands,
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
    PromptStartup,
    classify_prompt_command,
    classify_prompt_command_localized,
    parse_prompt_startup,
    fallback_profile_arguments,
    effective_one_shot_tokens,
    join_prompt_tokens,
    prime_lines,
    multis_lines,
    multis3_lines,
    modulo_lines,
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
    print("  abc WORT                       Buchstabenwerte")
    print("  reta ...                       vollständige reta-CLI")
    print("  shell ..., python ..., math ...")
    print("")
    print("Kompakte Zahlen- und Ein-Zeichen-Befehle werden nativ expandiert.")
    print("Noch nicht portierte fachliche Operationen nutzen danach die isolierte")
    print("Python-Kompatibilitätsgrenze.")


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
        bridge.clear_terminal()
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
        bridge.run_reta_line(command.raw)
        return True

    # Preserve the untouched source spelling at the compatibility boundary.
    # Native parsing already owns routing, but an unported operation must still
    # observe the Python reference's exact compact-command announcement and
    # later set normalisation.
    _run_fallback(bridge, profile, line)
    return True


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

    Python.add_to_path("python_reference")
    var bridge = Python.import_module("mojo_bridge")
    var session = new_prompt_session(startup.profile.logging_enabled)

    if startup.profile.show_intro and not startup.profile.one_shot:
        print("retaPrompt: nativer Mojo-Controller; Hilfe mit 'hilfe', Ende mit 'q'.")

    if startup.profile.one_shot:
        var line = _one_shot_line(startup)
        if line.byte_length() == 0:
            raise Error("-befehl benötigt einen Promptbefehl")
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
            var cancel = classify_prompt_command_localized(line, startup.profile.language, prompt_catalog)
            if cancel.kind == KIND_EXIT:
                session.delete_next = False
                print("Löschen abgebrochen.")
            else:
                delete_stored_selection(session, line)
                print("Gespeichert:", stored_prompt_text(session))
            continue
        if not _run_command(bridge, startup.profile, line, session, prompt_catalog):
            break
        var executed = classify_prompt_command_localized(line, startup.profile.language, prompt_catalog)
        if (
            executed.kind != KIND_STORE_NEXT
            and executed.kind != KIND_STORE_PREVIOUS
            and executed.kind != KIND_OUTPUT_STORED
            and executed.kind != KIND_DELETE_STORED
            and executed.kind != KIND_LOG_ON
            and executed.kind != KIND_LOG_OFF
        ):
            session.previous_command = line
