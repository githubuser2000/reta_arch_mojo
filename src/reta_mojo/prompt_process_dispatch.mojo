"""Native prompt-execution owner for explicit process dispatch plans.

``prompt_interaction`` owns input/session lifecycle.  This module owns the
execution-facing plan for prompt commands that intentionally cross an external
process boundary: ``shell``, ``python``, ``math``, ``reta`` and the atomic
``retaPrompt.py`` fallback.  It builds typed argv plans from runtime prompt
commands; the OS adapter then only executes already-built argv vectors.

This keeps the future shared-library split explicit:

* prompt-runtime builds command payloads and argv fragments;
* prompt-execution chooses the external effect and assembles dispatch plans;
* process adapters perform child-process execution only.
"""

from std.collections import List
from .prompt_runtime import (
    PromptProfile,
    PromptCommand,
    fallback_profile_arguments,
    reta_prompt_fallback_arguments_native,
    shell_split,
    command_argument_tail,
    command_raw_payload_arguments,
    command_shell_arguments,
    KIND_SHELL,
    KIND_PYTHON,
    KIND_MATH,
    KIND_RETA,
)


@fieldwise_init
struct PromptExternalProcessDispatchPlan(Copyable):
    """Executable plan for prompt commands that cross a process boundary."""

    var handled: Bool
    var arguments: List[String]
    var run_shell: Bool
    var run_python: Bool
    var run_math: Bool
    var run_reta: Bool


@fieldwise_init
struct PromptFallbackProcessDispatchPlan(Copyable):
    """Executable argv plan for the atomic Python prompt fallback child."""

    var handled: Bool
    var run_reta_prompt: Bool
    var arguments: List[String]


@fieldwise_init
struct PromptFallbackProcessExecutionPlan(Copyable):
    """Controller-facing execution boundary for the prompt fallback child.

    The fallback argv builder already lives in this owner.  This small plan also
    owns the last boolean gate that decides whether the controller should invoke
    the ``retaPrompt.py`` compatibility child.  The controller then only checks a
    single execution flag and passes through the owned argv vector.
    """

    var should_execute: Bool
    var arguments: List[String]


@fieldwise_init
struct PromptInteractiveExternalExecutionPlan(Copyable):
    """Controller-facing execution gate for interactive external commands.

    The dispatch owner already decides which process boundary is requested.
    This execution plan owns the next pure boolean projection so the controller
    no longer reads the raw dispatch flags directly before invoking the OS
    adapter.  Real child-process I/O still stays outside this pure owner.
    """

    var should_run_shell: Bool
    var should_run_python: Bool
    var should_run_math: Bool
    var should_run_reta: Bool
    var arguments: List[String]


@fieldwise_init
struct PromptOneShotExternalExecutionPlan(Copyable):
    """Controller-facing one-shot native child probe for direct reta.

    One-shot prompt execution must not run shell/python/math children in the
    native probe.  The only external command that may finish natively is direct
    ``reta`` when the native child accepts the argv vector.  This plan owns that
    pure projection so ``prompt_main.mojo`` no longer reads ``run_reta`` or the
    dispatch argv directly.
    """

    var should_try_reta_native: Bool
    var arguments: List[String]


@fieldwise_init
struct PromptInteractiveExternalCompletionPlan(Copyable):
    """Pure completion plan after interactive external-process dispatch.

    The controller still performs the shell/python/math/reta child-process I/O.
    This owner decides the post-dispatch completion algebra: all handled
    external commands finish the prompt command, while direct ``reta`` commands
    only need the reference child when the native reta child declined the argv.
    """

    var handled: Bool
    var run_reference_reta: Bool
    var reta_native_handled: Bool


@fieldwise_init
struct PromptOneShotExternalBoundaryPlan(Copyable):
    """Pure one-shot result after an explicit external-process command.

    Interactive prompt execution may directly run shell/python/math/reta child
    processes.  ``-befehl`` deliberately keeps shell/python/math and unowned
    reta invocations at the compatibility boundary; only a proven native reta
    child can finish the native probe.
    """

    var stop_native_probe: Bool
    var handled_without_boundary: Bool
    var reta_native_handled: Bool


def plan_external_process_dispatch(
    command: PromptCommand,
) raises -> PromptExternalProcessDispatchPlan:
    """Plan prompt commands that intentionally cross a process boundary.

    The prompt-runtime owner builds command-specific argv fragments; this
    prompt-execution owner chooses which external process effect is requested.
    The process adapter receives only the already-built argv vector.
    """
    if command.kind == KIND_SHELL:
        return PromptExternalProcessDispatchPlan(
            True,
            command_shell_arguments(command),
            True,
            False,
            False,
            False,
        )
    if command.kind == KIND_PYTHON:
        return PromptExternalProcessDispatchPlan(
            True,
            command_raw_payload_arguments(command),
            False,
            True,
            False,
            False,
        )
    if command.kind == KIND_MATH:
        return PromptExternalProcessDispatchPlan(
            True,
            command_raw_payload_arguments(command),
            False,
            False,
            True,
            False,
        )
    if command.kind == KIND_RETA:
        return PromptExternalProcessDispatchPlan(
            True,
            command_argument_tail(command),
            False,
            False,
            False,
            True,
        )
    return PromptExternalProcessDispatchPlan(
        False,
        List[String](),
        False,
        False,
        False,
        False,
    )


def plan_interactive_external_process_execution(
    dispatch: PromptExternalProcessDispatchPlan,
) -> PromptInteractiveExternalExecutionPlan:
    """Plan the interactive child-process adapter call.

    This keeps the effect-selection projection in the process-dispatch owner.
    The controller may still execute shell/python/math/reta children, but it
    consumes one execution-boundary value instead of inspecting the dispatch
    shape itself.
    """

    if not dispatch.handled:
        return PromptInteractiveExternalExecutionPlan(
            False, False, False, False, List[String]()
        )
    return PromptInteractiveExternalExecutionPlan(
        dispatch.run_shell,
        dispatch.run_python,
        dispatch.run_math,
        dispatch.run_reta,
        dispatch.arguments.copy(),
    )


def plan_one_shot_external_process_execution(
    dispatch: PromptExternalProcessDispatchPlan,
) -> PromptOneShotExternalExecutionPlan:
    """Plan the only external native attempt allowed in one-shot mode.

    Shell, Python and math intentionally stay at the historical compatibility
    boundary for ``-befehl``.  Direct ``reta`` may try the native child once; the
    later one-shot boundary plan decides whether that accepted argv completes the
    native probe or returns to compatibility.
    """

    if dispatch.handled and dispatch.run_reta:
        return PromptOneShotExternalExecutionPlan(
            True, dispatch.arguments.copy()
        )
    return PromptOneShotExternalExecutionPlan(False, List[String]())


def plan_interactive_external_process_completion(
    dispatch: PromptExternalProcessDispatchPlan, reta_native_handled: Bool
) -> PromptInteractiveExternalCompletionPlan:
    """Plan post-I/O completion for interactive external process commands.

    Shell, Python and math are complete once their child process has been
    launched.  Direct ``reta`` first tries the native child; if that declined the
    argv, the controller must run the reference reta child and still finish the
    prompt command.
    """

    if not dispatch.handled:
        return PromptInteractiveExternalCompletionPlan(False, False, False)
    if dispatch.run_reta:
        return PromptInteractiveExternalCompletionPlan(
            True, not reta_native_handled, reta_native_handled
        )
    return PromptInteractiveExternalCompletionPlan(True, False, False)


def plan_one_shot_external_process_boundary(
    dispatch: PromptExternalProcessDispatchPlan, reta_native_handled: Bool
) -> PromptOneShotExternalBoundaryPlan:
    """Plan how ``-befehl`` exits after explicit process dispatch.

    Shell, Python and math commands intentionally cross the historical prompt
    compatibility path in one-shot mode.  Direct ``reta`` commands may complete
    natively only when the native reta child accepted the argv vector.
    """

    if not dispatch.handled:
        return PromptOneShotExternalBoundaryPlan(False, False, False)
    if dispatch.run_reta and reta_native_handled:
        return PromptOneShotExternalBoundaryPlan(False, True, True)
    return PromptOneShotExternalBoundaryPlan(True, False, reta_native_handled)


def plan_prompt_fallback_process_dispatch(
    profile: PromptProfile,
    line: String,
) raises -> PromptFallbackProcessDispatchPlan:
    """Plan an unowned prompt command as explicit retaPrompt.py argv.

    The controller still preserves the original line for historical echo and
    atomic fallback decisions, but the prompt-execution owner now owns
    conversion to the child-process argument vector.  The process adapter only
    receives argv.
    """
    return PromptFallbackProcessDispatchPlan(
        True,
        True,
        reta_prompt_fallback_arguments_native(
            fallback_profile_arguments(profile), shell_split(line)
        ),
    )


def plan_prompt_fallback_process_execution(
    dispatch: PromptFallbackProcessDispatchPlan,
) -> PromptFallbackProcessExecutionPlan:
    """Plan the actual fallback child-process execution gate.

    The compatibility child may only run when the fallback dispatch itself is
    handled and explicitly targets ``retaPrompt.py``.  Keeping this conjunction
    in the process-dispatch owner removes the remaining fallback boolean algebra
    from ``prompt_main.mojo``.
    """
    return PromptFallbackProcessExecutionPlan(
        dispatch.handled and dispatch.run_reta_prompt,
        dispatch.arguments.copy(),
    )


def prompt_process_dispatch_contract_snapshot() -> List[String]:
    """Stable ownership snapshot for process-facing prompt execution."""
    return [
        "class=PromptProcessDispatchBundle",
        "external_dispatch_owner=prompt-execution-process-plan",
        "external_process_dispatch=native-prompt-process-edge-plan",
        "external_reta_arguments=native-prompt-reta-argv-plan",
        "external_process_arguments=native-prompt-process-argv-plan",
        "external_process_flags=native-prompt-process-effect-flags",
        "external_process_kind=eliminated-from-external-process-plan",
        "interactive_external_execution=native-prompt-process-execution-boundary",
        "interactive_external_completion=native-prompt-process-completion-boundary",
        "one_shot_external_execution=native-prompt-process-one-shot-execution-boundary",
        "one_shot_external_boundary=native-prompt-process-probe-boundary",
        "external_reta_child=native-prompt-reta-child-argv",
        "external_raw_line=eliminated-from-external-process-plan",
        "external_shell_arguments=native-prompt-shell-argv-plan",
        "external_python_math_arguments=native-prompt-python-math-argv-plan",
        "external_command_arguments=runtime-owned-command-argv-builders",
        "fallback_process_dispatch=native-interaction-argv-plan",
        "fallback_process_execution=native-prompt-fallback-execution-boundary",
        "fallback_process_handled=native-explicit-fallback-effect-flag",
        "fallback_process_flags=native-explicit-fallback-run-flag",
        "fallback_process_arguments=native-merged-fallback-argv",
        "fallback_runtime_arguments=runtime-owned-argv-builder",
        "fallback_shell_split=runtime-owned-argv-tokenizer",
        "process_adapter=argv-execution-only",
    ]
