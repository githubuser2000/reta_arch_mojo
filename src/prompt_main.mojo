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
    balanced_prompt_split,
    expand_compact_prompt_tokens,
    expand_prompt_replacements,
    load_prompt_language_catalog,
    is_prompt_numeric_shortcut,
    prompt_root_commands,
    prompt_vocabulary_alias,
    prepare_prompt_tokens,
)
from reta_mojo.prompt_table_execution import (
    PromptTablePlan,
    plan_prompt_table_commands,
)
from reta_mojo.prompt_legacy_echo import compact_prompt_announcement_line
from reta_mojo.native_prompt_input import read_native_prompt_line
from reta_mojo.prompt_external_commands import (
    run_math_prompt_line_native,
    run_python_prompt_line_native,
    run_reta_line_native,
    run_reta_prompt_fallback_native,
    run_shell_prompt_line_native,
)
from reta_mojo.native_reta_cli import (
    native_reta_tokens_supported,
    run_native_reta,
)
from reta_mojo.prompt_execution_runtime import render_prompt_table_plan
from reta_mojo.prompt_historical_ownership import (
    PROMPT_LOG_DISABLED,
    PROMPT_LOG_ENABLED,
    historical_prompt_companion_effects,
    historical_prompt_execution_supported,
    historical_prompt_logging_update,
    is_prompt_numeric_syntax_token,
)
from reta_mojo.native_cli_startup import native_cli_startup
from reta_mojo.resource_paths import asset_root, csv_resource, reference_root
from reta_mojo.terminal_geometry import (
    compound_clear_line_count,
    terminal_rows,
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
    join_prompt_tokens,
    prime_lines,
    command_numbers,
    multis_lines,
    multis3_lines,
    modulo_lines,
    prime_comparison_lines,
    distance_lines,
    abc_line,
)
from reta_mojo.prompt_session import (
    NativePromptSession,
    prompt_prefix,
    store_prompt_text,
    stored_prompt_text,
    storage_payload,
    stored_prompt_numbered,
    delete_stored_selection,
)
from reta_mojo.prompt_interaction import (
    INTERACTION_EXECUTE,
    INTERACTION_CONTINUE,
    INTERACTION_EXIT,
    NativePromptInteraction,
    new_prompt_interaction,
    prompt_interaction_one_shot_line,
    accept_prompt_input,
    record_prompt_command,
    apply_inline_storage_command,
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
    _ = run_reta_prompt_fallback_native(
        fallback_profile_arguments(profile), line, reference_root()
    )


def _run_native_reta_prompt_command(command: PromptCommand) raises -> Bool:
    if command.kind != KIND_RETA or len(command.words) < 1:
        return False
    var tokens = List[String]()
    for index in range(1, len(command.words)):
        tokens.append(command.words[index])
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
    var mulpri = prompt_vocabulary_alias(catalog, language, "command", "mulpri")
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
            var prime_word = "Primzahl" if profile_language_is_german(
                language
            ) else "prime_number"
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


def _is_pure_numeric_prompt(values: List[String]) -> Bool:
    if len(values) == 0:
        return False
    for index in range(len(values)):
        if not is_prompt_numeric_syntax_token(values[index]):
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
            compact_prompt_announcement_line(visible_tokens, source, language),
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
    if apply_inline_storage_command(
        session, raw_tokens, profile.language, catalog
    ):
        print("Gespeichert:", stored_prompt_text(session))
        return True
    if command.kind == KIND_EMPTY:
        return True
    if command.kind == KIND_EXIT:
        return False
    if command.kind == KIND_STORE_NEXT and len(command.words) == 1:
        session.store_next = True
        print("Der nächste Befehl wird gespeichert.")
        return True
    if command.kind == KIND_STORE_PREVIOUS and len(command.words) == 1:
        var payload = session.previous_command
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
    var planning_tokens_are_prepared = (
        historical_echo
        or numeric_default
        or _contains_numeric_shortcut(
            raw_tokens, profile.language, catalog
        )
    )
    var planning_tokens = (
        prepared.tokens.copy()
        if planning_tokens_are_prepared
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
        planning_tokens,
        profile.language,
        catalog,
        planning_tokens_are_prepared,
    )
    var mulpri_candidate = (
        _has_mulpri(planning_tokens, profile.language, catalog)
        and len(_integer_argument_words(planning_tokens)) > 0
    )
    var table_candidate = table_plan.handled
    var owns_mulpri = mulpri_candidate
    var owns_table = table_candidate
    if (historical_echo or numeric_default) and (owns_table or owns_mulpri):
        if not historical_prompt_execution_supported(
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
        var companion_effects = historical_prompt_companion_effects(
            planning_tokens, profile.language, catalog
        )
        if companion_effects.show_short_commands:
            _print_commands(catalog, profile.language, True)
        if companion_effects.show_commands:
            _print_commands(catalog, profile.language, False)
        if companion_effects.show_help:
            _print_prompt_help()
        if companion_effects.clear_before_table:
            _print_compound_clear_lines()
        var handled_table = _run_native_table_plan(
            table_plan, historical_echo, quiet_echo
        )
        var handled_mulpri = _run_native_mulpri(
            planning_tokens, profile.language, catalog
        )
        if handled_table or handled_mulpri:
            var logging_update = historical_prompt_logging_update(
                planning_tokens, profile.language, catalog
            )
            if logging_update == PROMPT_LOG_ENABLED:
                session.logging_enabled = True
            elif logging_update == PROMPT_LOG_DISABLED:
                session.logging_enabled = False
            return True

    if (table_candidate or mulpri_candidate) and not (
        owns_table or owns_mulpri
    ):
        _run_fallback(profile, line)
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
    if command.kind == KIND_CLEAR:
        _clear_terminal_native()
        return True

    if command.kind == KIND_LOG_ON:
        session.logging_enabled = True
        print("Logging ist eingeschaltet.")
        return True
    if command.kind == KIND_LOG_OFF:
        session.logging_enabled = False
        print("Logging ist ausgeschaltet.")
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
        _ = run_shell_prompt_line_native(command.raw)
        return True
    if command.kind == KIND_PYTHON:
        _ = run_python_prompt_line_native(command.raw)
        return True
    if command.kind == KIND_MATH:
        _ = run_math_prompt_line_native(command.raw)
        return True
    if command.kind == KIND_RETA:
        if _run_native_reta_prompt_command(command):
            return True
        _ = run_reta_line_native(command.raw)
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
    var planning_tokens_are_prepared = (
        historical_echo
        or numeric_default
        or _contains_numeric_shortcut(
            raw_tokens, profile.language, catalog
        )
    )
    var planning_tokens = (
        prepared.tokens.copy()
        if planning_tokens_are_prepared
        else normalized_tokens.copy()
    )
    var quiet_echo = _quiet_prompt_echo(
        planning_tokens, profile.language, catalog
    )
    var table_plan = plan_prompt_table_commands(
        planning_tokens,
        profile.language,
        catalog,
        planning_tokens_are_prepared,
    )
    var mulpri_candidate = (
        _has_mulpri(planning_tokens, profile.language, catalog)
        and len(_integer_argument_words(planning_tokens)) > 0
    )
    var table_candidate = table_plan.handled
    var owns_mulpri = mulpri_candidate
    var owns_table = table_candidate
    if (historical_echo or numeric_default) and (owns_table or owns_mulpri):
        if not historical_prompt_execution_supported(
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
        var companion_effects = historical_prompt_companion_effects(
            planning_tokens, profile.language, catalog
        )
        if companion_effects.show_short_commands:
            _print_commands(catalog, profile.language, True)
        if companion_effects.show_commands:
            _print_commands(catalog, profile.language, False)
        if companion_effects.show_help:
            _print_prompt_help()
        if companion_effects.clear_before_table:
            _print_compound_clear_lines()
        var handled_table = _run_native_table_plan(
            table_plan, historical_echo, quiet_echo
        )
        var handled_mulpri = _run_native_mulpri(
            planning_tokens, profile.language, catalog
        )
        if handled_table or handled_mulpri:
            return True

    if (table_candidate or mulpri_candidate) and not (
        owns_table or owns_mulpri
    ):
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
    if command.kind == KIND_CLEAR:
        _clear_terminal_native()
        return True

    if command.kind == KIND_LOG_ON:
        print("Logging ist eingeschaltet.")
        return True
    if command.kind == KIND_LOG_OFF:
        print("Logging ist ausgeschaltet.")
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
        var input_plan = accept_prompt_input(
            interaction, physical_line, prompt_catalog
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
        record_prompt_command(interaction, line, executed.kind)
