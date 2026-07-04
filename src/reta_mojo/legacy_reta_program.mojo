"""Native compatibility owner for the historical top-level ``reta.py`` API.

The legacy Python module exposed one mutable ``Program`` object.  This module
replaces that implicit object graph with an explicit typed state.  Arguments
that the native table kernel proves are supported execute directly in Mojo;
remaining legacy-only vectors cross the already documented child-process
boundary without embedding CPython.
"""

from std.collections import List

from .legacy_reta_program_catalog import (
    legacy_reta_program_public_names,
    legacy_reta_program_method_definitions,
)
from .native_reta_cli import native_reta_tokens_supported, run_native_reta
from .native_cli_controls import normalize_native_cli_controls
from .native_cli_startup import native_cli_startup
from .output_modes import canonicalize_output_mode
from .parallel_execution import (
    ParallelExecutionConfig,
    extract_parallel_config_from_argv,
    parallel_config_from_environment,
)
from .parameter_runtime import (
    AppliedUpperLimit,
    ParameterRuntimePlan,
    ParameterRuntimeWidthResult,
    UpperLimitArgument,
    apply_upper_limit_argument,
    apply_width_parameter,
    parameters_to_commands_and_numbers,
    produce_all_spalten_numbers,
    upper_limit_from_arguments,
    upper_limit_values_for_argument,
)
from .program_workflow import (
    KombiWorkflowPlan,
    ProgramWorkflowBeginResult,
    ProgramWorkflowBundle,
    bootstrap_program_workflow,
    default_program_workflow_csv_names,
)
from .prompt_external_commands import run_reta_arguments_native
from .resource_paths import csv_resource


@fieldwise_init
struct LegacyRetaProgramSnapshot(Copyable):
    var exported_names_len: Int
    var method_definitions_len: Int
    var argv_len: Int
    var output_mode: String
    var width: Int
    var highest: Int
    var invert_alles: Bool
    var run_alles: Bool
    var info_log: Bool
    var result_ready: Bool
    var compatibility_required: Bool
    var python_runtime_embedded: Bool


@fieldwise_init
struct LegacyRetaProgramRunResult(Copyable):
    var native: Bool
    var compatibility_required: Bool
    var output: String
    var child_status: Int


@fieldwise_init
struct LegacyRetaProgram(Copyable):
    var argv: List[String]
    var maximum_columns: Int
    var maximum_rows: Int
    var parallel_config: ParallelExecutionConfig
    var runtime: ParameterRuntimePlan
    var workflow: ProgramWorkflowBundle
    var invert_alles: Bool
    var run_alles: Bool
    var info_log: Bool
    var result_ready: Bool
    var compatibility_required: Bool
    var result: LegacyRetaProgramRunResult

    def snapshot(self) -> LegacyRetaProgramSnapshot:
        return LegacyRetaProgramSnapshot(
            len(legacy_reta_program_public_names()),
            len(legacy_reta_program_method_definitions()),
            len(self.argv),
            self.runtime.output_mode.copy(),
            self.runtime.width,
            self.runtime.highest,
            self.invert_alles,
            self.run_alles,
            self.info_log,
            self.result_ready,
            self.compatibility_required,
            False,
        )


def _empty_program_result() -> LegacyRetaProgramRunResult:
    return LegacyRetaProgramRunResult(False, False, String(), 0)


def render_color(
    tag_name: String,
    value: String,
    options: String = "",
    parent: String = "",
    context: String = "",
) -> String:
    _ = options
    _ = parent
    _ = context
    return '<span style="color:' + tag_name + ';">' + value + '</span>'


def bootstrap_legacy_reta_program_with_parallel_config(
    arguments: List[String],
    inherited_parallel_config: ParallelExecutionConfig,
    maximum_columns: Int = 746,
    maximum_rows: Int = 1024,
    run_alles: Bool = False,
    repo_root: String = ".",
) raises -> LegacyRetaProgram:
    var parallel = extract_parallel_config_from_argv(
        arguments, inherited_parallel_config
    )
    var controls = normalize_native_cli_controls(parallel.argv)
    var runtime = parameters_to_commands_and_numbers(
        parallel.argv, maximum_columns, maximum_rows
    )
    var workflow = bootstrap_program_workflow(
        repo_root, default_program_workflow_csv_names(), 1025
    )
    var program = LegacyRetaProgram(
        parallel.argv.copy(),
        maximum_columns,
        maximum_rows,
        parallel.config.copy(),
        runtime^,
        workflow^,
        False,
        run_alles,
        controls.debug,
        False,
        False,
        _empty_program_result(),
    )
    if run_alles:
        program.result = workflowEverything(program)
        program.result_ready = True
        program.compatibility_required = program.result.compatibility_required
    return program^


def bootstrap_legacy_reta_program(
    arguments: List[String] = List[String](),
    maximum_columns: Int = 746,
    maximum_rows: Int = 1024,
    run_alles: Bool = False,
    repo_root: String = ".",
) raises -> LegacyRetaProgram:
    return bootstrap_legacy_reta_program_with_parallel_config(
        arguments,
        parallel_config_from_environment(),
        maximum_columns,
        maximum_rows,
        run_alles,
        repo_root,
    )


def produceAllSpaltenNumbers(
    program: LegacyRetaProgram, negative_prefix: String = ""
) raises -> List[Int]:
    if negative_prefix.byte_length() > 0:
        return List[Int]()
    return produce_all_spalten_numbers(
        program.argv, program.maximum_columns, program.maximum_rows
    )


def breiteBreitenSysArgvPara(
    mut program: LegacyRetaProgram,
    command: String,
    negative_prefix: String = "",
) raises -> Bool:
    var result = apply_width_parameter(
        command,
        negative_prefix,
        program.maximum_columns,
        program.maximum_rows,
    )
    if result.handled:
        program.runtime.width = result.width
        program.runtime.widths = result.widths.copy()
    return result.handled


def apply_output_mode(
    mut program: LegacyRetaProgram, output_type: String
) -> Bool:
    var canonical = canonicalize_output_mode(output_type)
    if canonical.byte_length() == 0:
        return False
    program.runtime.output_mode = canonical
    return True


def storeParamtersForColumns(
    mut program: LegacyRetaProgram,
) raises -> ParameterRuntimePlan:
    program.runtime = parameters_to_commands_and_numbers(
        program.argv, program.maximum_columns, program.maximum_rows
    )
    return program.runtime.copy()


def parametersToCommandsAndNumbers(
    mut program: LegacyRetaProgram,
    arguments: List[String],
    negative_prefix: String = "",
) raises -> ParameterRuntimePlan:
    _ = negative_prefix
    var effective = arguments.copy()
    program.argv = effective.copy()
    program.runtime = parameters_to_commands_and_numbers(
        effective, program.maximum_columns, program.maximum_rows
    )
    return program.runtime.copy()


def helpPage(language: String = "german") raises -> String:
    var tokens = List[String]()
    if language == "english":
        tokens.append("-language=english")
    tokens.append("-h")
    var startup = native_cli_startup(tokens)
    return startup.output.copy()


def bringAllImportantBeginThings(
    program: LegacyRetaProgram,
) raises -> ProgramWorkflowBeginResult:
    return program.workflow.bring_all_important_begin_things(
        program.argv,
        program.maximum_columns,
        program.maximum_rows,
        program.runtime.highest,
        program.runtime.language,
        program.parallel_config,
    )


def oberesMaximumArg(
    program: LegacyRetaProgram, argument: String
) raises -> UpperLimitArgument:
    _ = program
    return upper_limit_values_for_argument(argument)


def oberesMaximum2(
    program: LegacyRetaProgram, arguments: List[String]
) raises -> Int:
    return upper_limit_from_arguments(arguments, program.runtime.highest)


def oberesMaximum(
    mut program: LegacyRetaProgram, argument: String
) raises -> Bool:
    var result = apply_upper_limit_argument(program.runtime.highest, argument)
    if result.applied:
        program.runtime.highest = result.maximum
    return result.applied


def propInfoLog(program: LegacyRetaProgram) -> Bool:
    return program.info_log


def set_propInfoLog(mut program: LegacyRetaProgram, value: Bool):
    program.info_log = value


def invertAlles(mut program: LegacyRetaProgram):
    program.invert_alles = True


def workflowEverything(
    program: LegacyRetaProgram,
    csv_path: String = "",
    reference_root: String = "python_reference",
) raises -> LegacyRetaProgramRunResult:
    # The historical top-level controls are orthogonal to table ownership.
    # Resolve them before touching CSV resources so empty/help/control-only
    # invocations are true native startup paths rather than Python children.
    var controls = normalize_native_cli_controls(program.argv)
    if controls.had_control and len(controls.tokens) == 0:
        return LegacyRetaProgramRunResult(
            True, False, controls.debug_prefix.copy(), 0
        )

    var startup = native_cli_startup(controls.tokens)
    if startup.owned:
        return LegacyRetaProgramRunResult(
            True,
            False,
            controls.debug_prefix + startup.output,
            0,
        )

    var path = csv_path if csv_path.byte_length() > 0 else csv_resource("religion.csv")
    if native_reta_tokens_supported(controls.tokens, path):
        return LegacyRetaProgramRunResult(
            True,
            False,
            controls.debug_prefix + run_native_reta(controls.tokens, path),
            0,
        )
    # Unknown vectors remain atomic: pass the original argv, including control
    # tokens, to the reference child so it alone owns all observable effects.
    var status = run_reta_arguments_native(program.argv, reference_root)
    return LegacyRetaProgramRunResult(False, True, String(), status)


def run(
    mut program: LegacyRetaProgram,
    csv_path: String = "",
    reference_root: String = "python_reference",
) raises -> LegacyRetaProgramRunResult:
    program.result = workflowEverything(program, csv_path, reference_root)
    program.result_ready = True
    program.compatibility_required = program.result.compatibility_required
    return program.result.copy()


def resultingTable(program: LegacyRetaProgram) -> String:
    return program.result.output.copy()


def combiTableWorkflow(
    program: LegacyRetaProgram,
    csv_file_name: String,
    new_table_columns: Int,
    rows_of_combi: Int,
    rows_of_combi2: Int,
) -> KombiWorkflowPlan:
    return program.workflow.combi_table_workflow(
        csv_file_name, new_table_columns, rows_of_combi, rows_of_combi2
    )


def legacy_reta_program_owner_snapshot() -> List[String]:
    return [
        "python_owner=reta.py",
        "surface=27-public-names/18-method-definitions",
        "program_state=LegacyRetaProgram",
        "parameters=parameter_runtime.mojo",
        "workflow=program_workflow.mojo",
        "table_kernel=native_reta_cli.mojo",
        "parallel=parallel_execution.mojo",
        "startup=native_cli_startup.mojo/native_cli_controls.mojo",
        "unsupported=explicit-child-process",
        "embedded_python=none",
    ]
