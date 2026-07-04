"""Native execution owner for planned historical prompt table commands.

``prompt_table_execution.mojo`` converts the large legacy
``PromptGrosseAusgabe`` branch into typed invocations.  This module owns the
remaining deterministic execution step: command-echo construction and native
``reta`` rendering.  Terminal output itself stays in ``prompt_main.mojo`` so
library callers can inspect a complete result before emitting any side effect.
"""

from std.collections import List
from .native_reta_cli import run_native_reta
from .prompt_legacy_echo import legacy_table_echo_tokens
from .prompt_table_execution import PromptTablePlan


@fieldwise_init
struct PromptRenderedInvocation(Copyable):
    var command_echo: String
    var table_output: String
    var command_echo_newline: Bool


@fieldwise_init
struct PromptTableExecutionResult(Copyable):
    var handled: Bool
    var invocations: List[PromptRenderedInvocation]


def prompt_table_command_echo(
    tokens: List[String], historical_echo: Bool = False
) -> String:
    if len(tokens) == 0:
        return String()
    var display_tokens = (
        legacy_table_echo_tokens(tokens)
        if historical_echo
        else tokens.copy()
    )
    var command_line = String("reta")
    for index in range(len(display_tokens)):
        command_line += " " + display_tokens[index]
    return command_line^


def render_prompt_table_plan(
    plan: PromptTablePlan,
    csv_path: String,
    historical_echo: Bool = False,
    suppress_command_echo: Bool = False,
) raises -> PromptTableExecutionResult:
    """Render a complete typed plan transactionally without terminal I/O.

    The historical implementation printed each invocation immediately.  A
    typed result is stronger: an invalid empty invocation cannot leave a
    half-emitted compound command, and ``prompt_main`` remains the sole owner
    of observable console effects.
    """
    var rendered = List[PromptRenderedInvocation]()
    if not plan.handled:
        return PromptTableExecutionResult(False, rendered^)
    for index in range(len(plan.invocations)):
        var invocation = plan.invocations[index].copy()
        if len(invocation.tokens) == 0:
            return PromptTableExecutionResult(
                False, List[PromptRenderedInvocation]()
            )
        var tokens = invocation.tokens.copy()
        var command_echo_newline = invocation.command_echo_newline
        var command_echo = String()
        if not suppress_command_echo:
            command_echo = prompt_table_command_echo(
                tokens.copy(), historical_echo
            )
        rendered.append(
            PromptRenderedInvocation(
                command_echo^,
                run_native_reta(tokens^, csv_path),
                command_echo_newline,
            )
        )
    return PromptTableExecutionResult(True, rendered^)
