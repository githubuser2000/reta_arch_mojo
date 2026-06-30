"""Command-line probe for the native deterministic execution network."""

from std.collections import List
from std.collections.string import atol
from std.sys import argv
from reta_mojo.execution_network import (
    ExecutionResult,
    ExecutionTask,
    FullDuplexChannel,
    HalfDuplexChannel,
    bootstrap_default_execution_network,
    deterministic_reduce,
    execute_tasks_deterministically,
    execution_network_bundle_snapshot_json,
    execution_run_snapshot_json,
    make_execution_network_config,
    make_execution_task,
    order_tasks,
)


def _usage():
    print("reta-mojo-execution-network")
    print("  --summary")
    print(
        "  --config MAX_WORKERS DISCIPLINE USE_THREADS LEGACY_START_METHOD"
        " PRESERVE_ORDER BOUNDED_SIZE"
    )
    print("  --order fifo|lifo|priority")
    print("  --run-serial fifo|lifo|priority preserve|scheduled")
    print("  --run-threads fifo|lifo|priority preserve|scheduled WORKERS")
    print("  --run-process is a legacy alias for --run-threads")
    print("  --channels")
    print("  --task OPERATION PAYLOAD")


def _bool_value(value: String) -> Bool:
    var lowered = value.strip().lower()
    return (
        lowered == "1"
        or lowered == "true"
        or lowered == "yes"
        or lowered == "on"
        or lowered == "preserve"
    )


def _join_task_indexes(tasks: List[ExecutionTask]) -> String:
    var result = String()
    for index in range(len(tasks)):
        if index > 0:
            result += ","
        result += String(tasks[index].index)
    return result^


def _join_strings(values: List[String]) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += ","
        result += values[index]
    return result^


def _demo_tasks(callable: Bool = False) -> List[ExecutionTask]:
    var path = "reta_mojo.execution_network:identity" if callable else ""
    var tasks = List[ExecutionTask]()
    tasks.append(make_execution_task(2, "2", priority=10, callable_path=path))
    tasks.append(make_execution_task(0, "0", priority=5, callable_path=path))
    tasks.append(make_execution_task(1, "1", priority=1, callable_path=path))
    return tasks^


def main() raises:
    var args = argv()
    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        var bundle = bootstrap_default_execution_network()
        print(execution_network_bundle_snapshot_json(bundle))
        print("processor_cores=" + String(bundle.processor_cores))
        print("max_workers=" + String(bundle.config.max_workers))
        return

    if len(args) == 8 and String(args[1]) == "--config":
        var config = make_execution_network_config(
            atol(String(args[2])),
            String(args[3]),
            _bool_value(String(args[4])),
            String(args[5]),
            _bool_value(String(args[6])),
            atol(String(args[7])),
        )
        print("max_workers=" + String(config.max_workers))
        print("queue_discipline=" + config.queue_discipline)
        print("use_threads=" + ("true" if config.use_threads else "false"))
        print("legacy_start_method_ignored=true")
        print(
            "preserve_input_order="
            + ("true" if config.preserve_input_order else "false")
        )
        print("bounded_queue_size=" + String(config.bounded_queue_size))
        return

    if len(args) == 3 and String(args[1]) == "--order":
        var config = make_execution_network_config(2, String(args[2]))
        print(_join_task_indexes(order_tasks(_demo_tasks(), config)))
        return

    if len(args) == 4 and String(args[1]) == "--run-serial":
        var preserve = String(args[3]) == "preserve"
        var config = make_execution_network_config(
            4, String(args[2]), preserve_input_order=preserve
        )
        var run = execute_tasks_deterministically(_demo_tasks(), config)
        print("values=" + _join_strings(run.values))
        print("results=" + _join_task_indexes(_results_as_tasks(run.results)))
        print("workers=" + String(run.workers))
        print("mode=" + run.mode)
        print(execution_run_snapshot_json(run))
        return

    if len(args) == 5 and (
        String(args[1]) == "--run-threads" or String(args[1]) == "--run-process"
    ):
        var preserve = String(args[3]) == "preserve"
        var config = make_execution_network_config(
            atol(String(args[4])), String(args[2]), True, "", preserve
        )
        var run = execute_tasks_deterministically(_demo_tasks(True), config)
        print("values=" + _join_strings(run.values))
        print("results=" + _join_task_indexes(_results_as_tasks(run.results)))
        print("workers=" + String(run.workers))
        print("mode=" + run.mode)
        print(execution_run_snapshot_json(run))
        return

    if len(args) == 2 and String(args[1]) == "--channels":
        var half = HalfDuplexChannel(2)
        half.send_request("run")
        half.send_response("ok")
        print("half_request=" + half.receive_request())
        print("half_response=" + half.receive_response())
        var full = FullDuplexChannel(2)
        full.send_a_to_b("cancel")
        full.send_b_to_a("progress")
        print("a_to_b=" + full.receive_a_to_b())
        print("b_to_a=" + full.receive_b_to_a())
        return

    if len(args) == 4 and String(args[1]) == "--task":
        var tasks = List[ExecutionTask]()
        tasks.append(make_execution_task(0, String(args[3]), String(args[2])))
        var run = execute_tasks_deterministically(
            tasks, make_execution_network_config(1)
        )
        print(run.values[0])
        return

    _usage()
    raise Error("invalid execution-network arguments")


def _results_as_tasks(results: List[ExecutionResult]) -> List[ExecutionTask]:
    var tasks = List[ExecutionTask]()
    for result in results:
        tasks.append(make_execution_task(result.task_index, result.value))
    return tasks^
