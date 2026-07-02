"""Native compatibility owner for historical ``libs/tableHandling.py``.

The Python module is a pure re-export facade over table state, wrapping,
output syntax, number theory and console helpers.  Mojo replaces the mutable
module globals with one explicit typed runtime while preserving every public
name as an owned function or snapshot entry.
"""

from std.collections import List
from .legacy_lib4tables import (
    NichtsSyntax,
    OutputSyntax,
    bbCodeSyntax,
    couldBePrimeNumberPrimzahlkreuz,
    csvSyntax,
    divisorGenerator,
    emacsSyntax,
    htmlSyntax,
    isPrimMultiple,
    markdownSyntax,
    moonNumber,
    primCreativity,
    primFak,
    primMultiple,
    primRepeat,
)
from .output_modes import (
    OutputModeSpec,
    OutputRuntimeState,
    default_output_runtime_state,
)
from .runtime_compat import RuntimeCompatTextWrapRuntime, cliout, getTextWrapThings
from .table_state import TableStateSections, create_table_state
from .table_wrapping import (
    TextWrapRuntimeState,
    get_shell_rows_amount,
    set_shell_rows_amount,
    textwrap_runtime,
)


@fieldwise_init
struct LegacyTableHandlingRuntime(Copyable):
    var table_state: TableStateSections
    var wrapping_state: TextWrapRuntimeState
    var output_state: OutputRuntimeState
    var info_log: Bool
    var output_enabled: Bool


@fieldwise_init
struct LegacyTableHandlingSnapshot(Copyable):
    var exported_names: List[String]
    var native_owners: List[String]
    var output_modes: List[String]
    var shell_rows_amount: Int
    var info_log: Bool
    var output_enabled: Bool


def bootstrap_table_handling(
    highest_row: Int = -1,
    text_width: Int = 21,
    info_log: Bool = False,
    output_enabled: Bool = True,
) -> LegacyTableHandlingRuntime:
    var output_state = default_output_runtime_state()
    output_state.text_width = text_width
    return LegacyTableHandlingRuntime(
        create_table_state(highest_row),
        textwrap_runtime(),
        output_state^,
        info_log,
        output_enabled,
    )


def setShellRowsAmount(
    mut runtime: LegacyTableHandlingRuntime, value: Int
) -> None:
    runtime.wrapping_state.set_shell_rows_amount(value)


def shellRowsAmount(runtime: LegacyTableHandlingRuntime) -> Int:
    return runtime.wrapping_state.get_shell_rows_amount()


def table_handling_cliout(
    runtime: LegacyTableHandlingRuntime,
    text: String,
    color: Bool = False,
) -> String:
    return cliout(text, color, "", runtime.output_enabled)


def table_handling_text_wrap_things(
    max_len: Int = 0,
) -> RuntimeCompatTextWrapRuntime:
    return getTextWrapThings(max_len)


def table_handling_snapshot(
    runtime: LegacyTableHandlingRuntime
) -> LegacyTableHandlingSnapshot:
    return LegacyTableHandlingSnapshot(
        [
            "BreakoutException",
            "OUTPUT_SEMANTICS",
            "TableRuntimeBundle",
            "Tables",
            "bootstrap_table_runtime",
            "OutputSyntax",
            "NichtsSyntax",
            "csvSyntax",
            "emacsSyntax",
            "markdownSyntax",
            "bbCodeSyntax",
            "htmlSyntax",
            "moonNumber",
            "primFak",
            "divisorGenerator",
            "primRepeat",
            "primCreativity",
            "primMultiple",
            "isPrimMultiple",
            "couldBePrimeNumberPrimzahlkreuz",
            "setShellRowsAmount",
            "shellRowsAmount",
            "cliout",
            "getTextWrapThings",
            "i18n",
            "infoLog",
            "output",
        ],
        [
            "table_state.mojo",
            "table_wrapping.mojo",
            "output_modes.mojo",
            "legacy_lib4tables.mojo",
            "runtime_compat.mojo",
        ],
        ["shell", "nichts", "csv", "emacs", "markdown", "bbcode", "html"],
        shellRowsAmount(runtime),
        runtime.info_log,
        runtime.output_enabled,
    )
