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
from std.python import Python, PythonObject
from reta_mojo.prompt_language import (
    PromptExpansionResult,
    PromptLanguageCatalog,
    balanced_prompt_split,
    expand_compact_prompt_tokens,
    expand_prompt_replacements,
    load_prompt_language_catalog,
    is_prompt_numeric_shortcut,
    prompt_completion_word_pool,
    prompt_root_commands,
    prompt_vocabulary_alias,
    prepare_prompt_tokens,
    normalize_prompt_language,
)
from reta_mojo.prompt_table_execution import (
    PromptTablePlan,
    plan_prompt_table_commands,
)
from reta_mojo.prompt_legacy_echo import (
    compact_prompt_announcement_line,
    legacy_table_echo_tokens,
)
from reta_mojo.native_prompt_input import (
    native_plain_input_requested,
    read_plain_prompt_line,
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
    command_numbers,
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
    print("Null-, Negativ- und kollidierende Zahlenbedingungen werden samt")
    print("historischer All-Zeilen-Algebra nativ geplant. Auch wiederholte")
    print("Katalogauswahlen sind nativ; echte v-n/m-Vielfache mit Zähler")
    print("> 1 und seltene hintere Sonderzweige bleiben am Fallback.")
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


def _python_bridge() raises -> PythonObject:
    """Import the compatibility bridge only when a legacy boundary is used."""
    Python.add_to_path("python_reference")
    return Python.import_module("mojo_bridge")


def _read_line(
    profile: PromptProfile,
    session: NativePromptSession,
    catalog: PromptLanguageCatalog,
) raises -> String:
    var prefix = prompt_prefix(session)
    if native_plain_input_requested():
        return read_plain_prompt_line(
            prefix,
            session.logging_enabled,
            "~/.ReTaPromptHistory",
        )

    # Keep the historical readline/vi/completion behavior on a real TTY until
    # the native line editor has exact key-binding and completion parity.
    var fields = List[String]()
    fields.append(prefix)
    fields.append("1" if session.logging_enabled else "0")
    fields.append("1" if profile.vi_mode else "0")
    fields.append("~/.ReTaPromptHistory")
    fields.append(profile.language)
    var words = prompt_completion_word_pool(catalog, profile.language)
    for index in range(len(words)):
        fields.append(words[index])
    var bridge = _python_bridge()
    return String(py=bridge.read_prompt_line_encoded(_encode_fields(fields)))


def _run_fallback(
    profile: PromptProfile,
    line: String,
) raises -> None:
    var flags = fallback_profile_arguments(profile)
    var encoded = _encode_fields(flags) + "\x1e" + line
    var bridge = _python_bridge()
    bridge.run_reta_prompt_line_encoded(encoded)


def _run_native_table_tokens(
    tokens: List[String],
    historical_echo: Bool = False,
    suppress_command_echo: Bool = False,
    command_echo_newline: Bool = False,
) raises -> Bool:
    if len(tokens) == 0:
        return False
    if not suppress_command_echo:
        var display_tokens = (
            legacy_table_echo_tokens(tokens) if historical_echo else tokens.copy()
        )
        var command_line = String("reta")
        for index in range(len(display_tokens)):
            command_line += " " + display_tokens[index]
        # Rich's ``Syntax`` renderable emits a complete physical line even
        # though the Python helper calls ``Console.print(..., end="")``.
        # Reproduce the observable byte stream, not the helper's internal
        # keyword argument: the command echo always ends before the table.
        _ = command_echo_newline  # retained in the typed plan for compatibility
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


def _run_native_table_plan(
    plan: PromptTablePlan,
    historical_echo: Bool = False,
    suppress_command_echo: Bool = False,
) raises -> Bool:
    if not plan.handled:
        return False
    if len(plan.invocations) == 0:
        return True
    for index in range(len(plan.invocations)):
        if not _run_native_table_tokens(
            plan.invocations[index].tokens,
            historical_echo,
            suppress_command_echo,
            plan.invocations[index].command_echo_newline,
        ):
            return False
    return True


def _uses_historical_prompt_echo(
    raw_tokens: List[String], expansion: PromptExpansionResult
) -> Bool:
    if expansion.compact:
        return True
    return len(raw_tokens) > 0 and raw_tokens[0].byte_length() == 1


def _contains_token(values: List[String], needle: String) -> Bool:
    for index in range(len(values)):
        if values[index] == needle:
            return True
    return False


def _contains_numeric_shortcut(
    values: List[String], language: String, catalog: PromptLanguageCatalog
) -> Bool:
    for index in range(len(values)):
        if is_prompt_numeric_shortcut(catalog, language, values[index]):
            return True
    return False


def _quiet_prompt_echo(
    values: List[String], language: String, catalog: PromptLanguageCatalog
) -> Bool:
    var quiet = prompt_vocabulary_alias(
        catalog,
        language,
        "command",
        "keineEinZeichenZeilenPlusKeineAusgabeWelcherBefehlEsWar",
    )
    return _contains_token(values, quiet)


def _integer_argument_words(values: List[String]) -> List[String]:
    var result = List[String]()
    for index in range(len(values)):
        var token = values[index]
        if "/" in token or token.startswith("-"):
            continue
        try:
            var numbers = command_numbers(
                PromptCommand(KIND_PRIME, "prim " + token, ["prim", token])
            )
            if len(numbers) > 0:
                result.append(token)
        except:
            pass
    return result^


def _has_mulpri(
    values: List[String], language: String, catalog: PromptLanguageCatalog
) -> Bool:
    var mulpri = prompt_vocabulary_alias(
        catalog, language, "command", "mulpri"
    )
    var short = prompt_vocabulary_alias(catalog, language, "command", "p")
    return _contains_token(values, mulpri) or _contains_token(values, short)


def profile_language_is_german(language: String) -> Bool:
    var normalized = language.lower()
    return (
        normalized == ""
        or normalized == "de"
        or normalized == "deutsch"
        or normalized == "german"
    )


def _run_native_mulpri(
    values: List[String], language: String, catalog: PromptLanguageCatalog
) raises -> Bool:
    if not _has_mulpri(values, language, catalog):
        return False
    var arguments = _integer_argument_words(values)
    if len(arguments) == 0:
        return False
    var prime_words = List[String]()
    prime_words.append("prim")
    for index in range(len(arguments)):
        prime_words.append(arguments[index])
    var prime_command = PromptCommand(
        KIND_PRIME, join_prompt_tokens(prime_words), prime_words^
    )
    var numbers = command_numbers(prime_command)
    if len(numbers) > 1:
        var compare_words = List[String]()
        compare_words.append("primfaktorenvergleich")
        for index in range(len(arguments)):
            compare_words.append(arguments[index])
        _print_lines(
            prime_comparison_lines(
                PromptCommand(
                    KIND_PRIME_COMPARE,
                    join_prompt_tokens(compare_words),
                    compare_words^,
                ),
                language,
            )
        )
    _print_lines(prime_lines(prime_command))
    var multi_words = List[String]()
    multi_words.append("multis")
    for index in range(len(arguments)):
        multi_words.append(arguments[index])
    var multi_lines = multis_lines(
        PromptCommand(
            KIND_MULTIS, join_prompt_tokens(multi_words), multi_words^
        )
    )
    for index in range(len(multi_lines)):
        if multi_lines[index].endswith("[]") and index < len(numbers):
            var prime_word = (
                "Primzahl"
                if profile_language_is_german(language)
                else "prime_number"
            )
            print(
                String(numbers[index])
                + ": "
                + String(numbers[index])
                + " ("
                + prime_word
                + ")"
            )
        else:
            print(multi_lines[index])
    return True


def _compact_announcement_tokens(
    prepared_tokens: List[String],
    language: String,
    catalog: PromptLanguageCatalog,
) -> List[String]:
    var result = prepared_tokens.copy()
    if _has_mulpri(prepared_tokens, language, catalog):
        for canonical in ["multis", "prim", "primfaktorenvergleich"]:
            var translated = prompt_vocabulary_alias(
                catalog, language, "command", canonical
            )
            if not _contains_token(result, translated):
                result.append(translated)
    return result^


def _is_prompt_numeric_syntax_token(value: String) -> Bool:
    if value.byte_length() == 0:
        return False
    var bytes = value.as_bytes()
    for index in range(len(bytes)):
        var code = Int(bytes[index])
        if code >= 48 and code <= 57:
            continue
        if (
            code == 32
            or code == 9
            or code == 43
            or code == 44
            or code == 45
            or code == 46
            or code == 47
            or code == 58
            or code == 59
            or code == 91
            or code == 93
            or code == 40
            or code == 41
            or code == 123
            or code == 125
        ):
            continue
        return False
    return True


def _is_pure_numeric_prompt(values: List[String]) -> Bool:
    if len(values) == 0:
        return False
    for index in range(len(values)):
        if not _is_prompt_numeric_syntax_token(values[index]):
            return False
    return True


def _canonical_prompt_command(
    token: String, language: String, catalog: PromptLanguageCatalog
) -> String:
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.vocabulary)):
        var entry = catalog.vocabulary[index].copy()
        if (
            entry.language == normalized
            and entry.domain == "command"
            and entry.translated == token
        ):
            return entry.canonical
    return token


def _is_prompt_table_canonical(value: String) -> Bool:
    return (
        value == "mond"
        or value == "richtung"
        or value == "r"
        or value == "primzahlkreuz"
        or value == "alles"
        or value == "thomas"
        or value == "t"
        or value == "emotion"
        or value == "E"
        or value == "wirklichkeit"
        or value == "W"
        or value == "triebe"
        or value == "T"
        or value == "impulse"
        or value == "I"
        or value == "bewusstsein"
        or value == "B"
        or value == "geist"
        or value == "G"
        or value == "freiheit"
        or value == "gleichheit"
        or value == "groesse"
        or value == "kugeln"
        or value == "kreise"
        or value == "netzwerk"
        or value == "komplex"
        or value == "absicht"
        or value == "absichten"
        or value == "motiv"
        or value == "motive"
        or value == "a"
        or value == "universum"
        or value == "u"
    )


def _historical_prompt_control_supported(canonical: String) -> Bool:
    return (
        canonical == "mulpri"
        or canonical == "p"
        or canonical == "range"
        or canonical == "R"
        or canonical == "invertieren"
        or canonical == "e"
        or canonical == "ee"
        or canonical == "vielfache"
        or canonical == "v"
        or canonical == "teiler"
        or canonical == "w"
        or canonical == "einzeln"
        or canonical
        == "keineEinZeichenZeilenPlusKeineAusgabeWelcherBefehlEsWar"
    )


def _historical_prompt_parameter_supported(
    token: String, language: String, catalog: PromptLanguageCatalog
) -> Bool:
    if token == "-ausgabe" or token == "-output":
        return True
    if not token.startswith("--"):
        return False
    var name = String(token[byte=2:])
    if "=" in name:
        name = String(name.split("=")[0])
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.vocabulary)):
        var entry = catalog.vocabulary[index].copy()
        if (
            entry.language == normalized
            and entry.domain == "output"
            and entry.translated == name
        ):
            return (
                entry.canonical == "keineueberschriften"
                or entry.canonical == "keineleereninhalte"
                or entry.canonical == "keinenummerierung"
                or entry.canonical == "nocolor"
                or entry.canonical == "breite"
                or entry.canonical == "art"
                or entry.canonical == "spaltenreihenfolgeundnurdiese"
            )
    return False


def _historical_prompt_execution_supported(
    raw_tokens: List[String],
    planning_tokens: List[String],
    language: String,
    catalog: PromptLanguageCatalog,
) -> Bool:
    # Number-only compact defaults compose the same typed table and mulpri
    # branches as lettered shorthand.  They are accepted only when every
    # expanded token below is explicitly owned.
    for index in range(len(planning_tokens)):
        var token = planning_tokens[index]
        # Only pure numeric/rational/range syntax is data.  Every other token
        # must be owned explicitly; otherwise a localized storage/shell/session
        # command could be silently dropped while its table sibling runs.
        if _is_prompt_numeric_syntax_token(token):
            continue
        if _historical_prompt_parameter_supported(token, language, catalog):
            continue
        var canonical = _canonical_prompt_command(token, language, catalog)
        if _historical_prompt_control_supported(canonical):
            continue
        if not _is_prompt_table_canonical(canonical):
            return False
        if not (
            canonical == "richtung"
            or canonical == "r"
            or canonical == "bewusstsein"
            or canonical == "B"
            or canonical == "emotion"
            or canonical == "E"
            or canonical == "triebe"
            or canonical == "T"
            or canonical == "wirklichkeit"
            or canonical == "W"
            or canonical == "universum"
            or canonical == "u"
            or canonical == "thomas"
            or canonical == "t"
            or canonical == "impulse"
            or canonical == "I"
            or canonical == "geist"
            or canonical == "G"
            or canonical == "groesse"
            or canonical == "absicht"
            or canonical == "absichten"
            or canonical == "motiv"
            or canonical == "motive"
            or canonical == "a"
        ):
            return False
    return True


def _print_compact_announcement_if_needed(
    expansion: PromptExpansionResult,
    prepared_tokens: List[String],
    source: String,
    language: String,
    catalog: PromptLanguageCatalog,
    quiet: Bool,
) -> None:
    if expansion.compact and not quiet:
        var visible_tokens = _compact_announcement_tokens(
            prepared_tokens, language, catalog
        )
        # The Python Rich renderer produces one complete physical line here.
        # Keep that byte-level contract explicit instead of inferring it from
        # Rich's internal ``Console.print(..., end="")`` call.
        print(
            compact_prompt_announcement_line(
                visible_tokens, source, language
            ),
            end="",
        )


def _run_command(
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
        return _run_command(profile, stored, session, catalog)
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

    var historical_echo = _uses_historical_prompt_echo(
        raw_tokens, compact_expansion
    )
    var prepared = prepare_prompt_tokens(
        catalog,
        profile.language,
        raw_tokens,
        False,
        profile.force_e_command,
    )
    var numeric_default = _is_pure_numeric_prompt(raw_tokens)
    var planning_tokens = (
        prepared.tokens.copy()
        if historical_echo
        or numeric_default
        or _contains_numeric_shortcut(raw_tokens, profile.language, catalog)
        else normalized_tokens.copy()
    )
    var quiet_echo = _quiet_prompt_echo(
        planning_tokens, profile.language, catalog
    )

    # The historical PromptGrosseAusgabe branch treats domain words as an
    # unordered command set.  Plan these table-backed commands before the
    # single-command dispatch so localized aliases and mixed command lines can
    # remain native as one or more invocations.
    var table_plan = plan_prompt_table_commands(
        planning_tokens, profile.language, catalog
    )
    var owns_mulpri = _has_mulpri(
        planning_tokens, profile.language, catalog
    ) and len(_integer_argument_words(planning_tokens)) > 0
    var owns_table = table_plan.handled
    if (historical_echo or numeric_default) and (owns_table or owns_mulpri):
        if not _historical_prompt_execution_supported(
            raw_tokens, planning_tokens, profile.language, catalog
        ):
            owns_table = False
            owns_mulpri = False
    # Never execute one branch of a compound historical command while another
    # branch still belongs to the compatibility boundary.
    if table_plan.handled and not owns_table:
        owns_mulpri = False
    if owns_table or owns_mulpri:
        _print_compact_announcement_if_needed(
            compact_expansion,
            prepared.tokens,
            line,
            profile.language,
            catalog,
            quiet_echo,
        )
        var handled_table = _run_native_table_plan(
            table_plan, historical_echo, quiet_echo
        )
        var handled_mulpri = _run_native_mulpri(
            planning_tokens, profile.language, catalog
        )
        if handled_table or handled_mulpri:
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
        _print_lines(distance_lines(command, False, profile.language))
        return True
    if command.kind == KIND_DISTANCE_PRIME:
        _print_lines(distance_lines(command, True, profile.language))
        return True
    if command.kind == KIND_ABC:
        var line_out = abc_line(command)
        if line_out.byte_length() > 0:
            print(line_out)
        return True
    if command.kind == KIND_SHELL:
        var bridge = _python_bridge()
        bridge.run_shell_prompt_line(command.raw)
        return True
    if command.kind == KIND_PYTHON:
        var bridge = _python_bridge()
        bridge.run_python_prompt_line(command.raw)
        return True
    if command.kind == KIND_MATH:
        var bridge = _python_bridge()
        bridge.run_math_prompt_line(command.raw)
        return True
    if command.kind == KIND_RETA:
        if _run_native_reta_prompt_command(command):
            return True
        var bridge = _python_bridge()
        bridge.run_reta_line(command.raw)
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

    var historical_echo = _uses_historical_prompt_echo(
        raw_tokens, compact_expansion
    )
    var prepared = prepare_prompt_tokens(
        catalog,
        profile.language,
        raw_tokens,
        False,
        profile.force_e_command,
    )
    var numeric_default = _is_pure_numeric_prompt(raw_tokens)
    var planning_tokens = (
        prepared.tokens.copy()
        if historical_echo
        or numeric_default
        or _contains_numeric_shortcut(raw_tokens, profile.language, catalog)
        else normalized_tokens.copy()
    )
    var quiet_echo = _quiet_prompt_echo(
        planning_tokens, profile.language, catalog
    )
    var table_plan = plan_prompt_table_commands(
        planning_tokens, profile.language, catalog
    )
    var owns_mulpri = _has_mulpri(
        planning_tokens, profile.language, catalog
    ) and len(_integer_argument_words(planning_tokens)) > 0
    var owns_table = table_plan.handled
    if (historical_echo or numeric_default) and (owns_table or owns_mulpri):
        if not _historical_prompt_execution_supported(
            raw_tokens, planning_tokens, profile.language, catalog
        ):
            owns_table = False
            owns_mulpri = False
    # Never execute one branch of a compound historical command while another
    # branch still belongs to the compatibility boundary.
    if table_plan.handled and not owns_table:
        owns_mulpri = False
    if owns_table or owns_mulpri:
        _print_compact_announcement_if_needed(
            compact_expansion,
            prepared.tokens,
            line,
            profile.language,
            catalog,
            quiet_echo,
        )
        var handled_table = _run_native_table_plan(
            table_plan, historical_echo, quiet_echo
        )
        var handled_mulpri = _run_native_mulpri(
            planning_tokens, profile.language, catalog
        )
        if handled_table or handled_mulpri:
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
        _print_lines(distance_lines(command, False, profile.language))
        return True
    if command.kind == KIND_DISTANCE_PRIME:
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

    var session = new_prompt_session(startup.profile.logging_enabled)

    if startup.profile.show_intro and not startup.profile.one_shot:
        print(
            "retaPrompt: nativer Mojo-Controller; Hilfe mit 'hilfe', Ende mit"
            " 'q'."
        )

    if startup.profile.one_shot:
        var line = _one_shot_line(startup)
        _ = _run_command(startup.profile, line, session, prompt_catalog)
        return

    while True:
        var line = _read_line(startup.profile, session, prompt_catalog)
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
            startup.profile, line, session, prompt_catalog
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
