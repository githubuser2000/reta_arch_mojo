from std.collections import List
from reta_mojo.execution_network import (
    ExecutionResult,
    FifoTaskQueue,
    FullDuplexChannel,
    HalfDuplexChannel,
    LifoTaskStack,
    PriorityTaskQueue,
    ResourceSemaphore,
    available_worker_count,
    bootstrap_default_execution_network,
    bootstrap_execution_network,
    default_execution_network_config,
    deterministic_reduce,
    execute_task,
    execute_tasks_deterministically,
    execution_network_bundle_snapshot_json,
    execution_network_config_snapshot_json,
    execution_result_snapshot_json,
    execution_task_snapshot_json,
    execution_run_snapshot_json,
    make_execution_network_config,
    make_execution_task,
    order_tasks,
    workers_for,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def assert_raises(flag: Bool, message: String) raises:
    if not flag:
        raise Error(message)


def main() raises:
    var checks = 0

    assert_true(available_worker_count() >= 1, "available workers")
    checks += 1
    var defaults = default_execution_network_config()
    assert_true(defaults.max_workers >= 1, "default max workers")
    checks += 1
    assert_true(defaults.queue_discipline == "fifo", "default discipline")
    checks += 1
    assert_true(not defaults.use_threads, "default thread mode")
    checks += 1
    assert_true(defaults.preserve_input_order, "default input order")
    checks += 1

    var normalized = make_execution_network_config(
        -2, "INVALID", True, "none", False, -5
    )
    assert_true(normalized.max_workers == 1, "normalized workers")
    checks += 1
    assert_true(normalized.queue_discipline == "fifo", "normalized discipline")
    checks += 1
    assert_true(normalized.use_threads, "normalized thread mode")
    checks += 1
    assert_true(normalized.bounded_queue_size == 1, "normalized queue size")
    checks += 1
    assert_true(
        not normalized.preserve_input_order, "normalized preserve order"
    )
    checks += 1
    assert_true(
        workers_for(make_execution_network_config(4), 2) == 2,
        "workers task cap",
    )
    checks += 1
    assert_true(
        workers_for(make_execution_network_config(2), 8) == 2,
        "workers config cap",
    )
    checks += 1

    var bundle = bootstrap_default_execution_network()
    assert_true(bundle.processor_cores >= 1, "bundle processor cores")
    checks += 1
    assert_true(
        bundle.cpu_semaphore.value == bundle.config.max_workers, "cpu semaphore"
    )
    checks += 1
    assert_true(bundle.file_io_semaphore.value <= 4, "file semaphore")
    checks += 1
    assert_true(bundle.output_semaphore.value == 1, "output semaphore")
    checks += 1
    var bundle_json = execution_network_bundle_snapshot_json(bundle)
    assert_true(
        bundle_json.find("ExecutionNetworkCategory") >= 0,
        "bundle category snapshot",
    )
    checks += 1
    assert_true(
        bundle_json.find("deterministic_reduce") >= 0,
        "bundle morphism snapshot",
    )
    checks += 1
    assert_true(
        bundle_json.find("HalfDuplexChannel") >= 0, "bundle channel snapshot"
    )
    checks += 1

    var semaphore = ResourceSemaphore(2, 2)
    assert_true(semaphore.acquire(), "semaphore acquire 1")
    checks += 1
    assert_true(semaphore.acquire(), "semaphore acquire 2")
    checks += 1
    assert_true(not semaphore.acquire(), "semaphore exhausted")
    checks += 1
    semaphore.release()
    assert_true(semaphore.available == 1, "semaphore release")
    checks += 1
    semaphore.release()
    var release_failed = False
    try:
        semaphore.release()
    except:
        release_failed = True
    assert_raises(release_failed, "bounded semaphore overflow")
    checks += 1
    assert_true(
        semaphore.snapshot_json().find('"available":2') >= 0,
        "semaphore snapshot",
    )
    checks += 1

    var task_two = make_execution_task(2, "2")
    var task_zero = make_execution_task(0, "0")
    var task_one = make_execution_task(1, "1")
    var task_json = execution_task_snapshot_json(
        make_execution_task(
            4, "payload", "identity", 3, metadata_json='{"kind":"unit"}'
        )
    )
    assert_true(
        task_json.find('"callable_path":null') >= 0, "task snapshot callable"
    )
    checks += 1
    assert_true(
        task_json.find('"metadata":{"kind":"unit"}') >= 0,
        "task snapshot metadata",
    )
    checks += 1
    var result_json = execution_result_snapshot_json(
        ExecutionResult(4, "äß", "identity", "{}")
    )
    assert_true(
        result_json.find('"value_len":2') >= 0, "result snapshot codepoints"
    )
    checks += 1

    var fifo = FifoTaskQueue()
    fifo.push(task_two)
    fifo.push(task_zero)
    fifo.push(task_one)
    assert_true(fifo.size() == 3, "fifo size")
    checks += 1
    assert_true(fifo.pop().index == 2, "fifo first")
    checks += 1
    assert_true(fifo.pop().index == 0, "fifo second")
    checks += 1
    assert_true(fifo.pop().index == 1, "fifo third")
    checks += 1
    var fifo_empty = False
    try:
        _ = fifo.pop()
    except:
        fifo_empty = True
    assert_raises(fifo_empty, "fifo empty")
    checks += 1

    var lifo = LifoTaskStack()
    lifo.push(task_two)
    lifo.push(task_zero)
    lifo.push(task_one)
    assert_true(lifo.size() == 3, "lifo size")
    checks += 1
    assert_true(lifo.pop().index == 1, "lifo first")
    checks += 1
    assert_true(lifo.pop().index == 0, "lifo second")
    checks += 1
    assert_true(lifo.pop().index == 2, "lifo third")
    checks += 1

    var priority = PriorityTaskQueue()
    priority.push(make_execution_task(7, "late", priority=10))
    priority.push(make_execution_task(4, "first-tie", priority=1))
    priority.push(make_execution_task(1, "first", priority=0))
    priority.push(make_execution_task(3, "second-tie", priority=1))
    assert_true(priority.size() == 4, "priority size")
    checks += 1
    assert_true(priority.pop().index == 1, "priority first")
    checks += 1
    assert_true(priority.pop().index == 3, "priority tie index first")
    checks += 1
    assert_true(priority.pop().index == 4, "priority tie index second")
    checks += 1
    assert_true(priority.pop().index == 7, "priority last")
    checks += 1

    var tasks = List[type_of(task_two)]()
    tasks.append(task_two.copy())
    tasks.append(task_zero.copy())
    tasks.append(task_one.copy())
    var fifo_order = order_tasks(
        tasks, make_execution_network_config(2, "fifo")
    )
    assert_true(
        fifo_order[0].index == 2 and fifo_order[2].index == 1, "fifo order"
    )
    checks += 1
    var lifo_order = order_tasks(
        tasks, make_execution_network_config(2, "lifo")
    )
    assert_true(
        lifo_order[0].index == 1 and lifo_order[2].index == 2, "lifo order"
    )
    checks += 1

    var half = HalfDuplexChannel(2)
    half.send_request('{"cmd":"run"}')
    assert_true(
        half.snapshot_json().find('"requests":1') >= 0, "half request count"
    )
    checks += 1
    assert_true(half.receive_request() == '{"cmd":"run"}', "half request")
    checks += 1
    half.send_response('{"ok":true}')
    assert_true(half.receive_response() == '{"ok":true}', "half response")
    checks += 1
    var half_empty = False
    try:
        _ = half.receive_request(1)
    except:
        half_empty = True
    assert_raises(half_empty, "half empty")
    checks += 1

    var bounded = HalfDuplexChannel(1)
    bounded.send_request("one")
    var bounded_full = False
    try:
        bounded.send_request("two")
    except:
        bounded_full = True
    assert_raises(bounded_full, "bounded channel full")
    checks += 1

    var full = FullDuplexChannel()
    full.send_a_to_b("cancel")
    full.send_b_to_a("progress")
    assert_true(full.receive_a_to_b() == "cancel", "full a to b")
    checks += 1
    assert_true(full.receive_b_to_a() == "progress", "full b to a")
    checks += 1
    assert_true(full.snapshot_json().find('"a_to_b":0') >= 0, "full snapshot")
    checks += 1

    assert_true(
        execute_task(make_execution_task(0, "abc")).value == "abc",
        "identity operation",
    )
    checks += 1
    assert_true(
        execute_task(make_execution_task(0, "21", "double_int")).value == "42",
        "double operation",
    )
    checks += 1
    assert_true(
        execute_task(make_execution_task(0, "-7", "square_int")).value == "49",
        "square operation",
    )
    checks += 1
    assert_true(
        execute_task(make_execution_task(0, "Abc", "uppercase")).value == "ABC",
        "uppercase operation",
    )
    checks += 1
    assert_true(
        execute_task(make_execution_task(0, "AbC", "lowercase")).value == "abc",
        "lowercase operation",
    )
    checks += 1
    assert_true(
        execute_task(make_execution_task(0, "ä", "byte_length")).value == "2",
        "byte length operation",
    )
    checks += 1
    assert_true(
        execute_task(
            make_execution_task(
                0, "8", callable_path="reta_mojo.execution_network:double_int"
            )
        ).value
        == "16",
        "callable path operation",
    )
    checks += 1
    assert_true(
        execute_task(
            make_execution_task(
                0,
                "same",
                operation="uppercase",
                callable_path="reta_mojo.execution_network:_builtin_operation",
            )
        ).value
        == "same",
        "builtin callable path",
    )
    checks += 1
    var unknown_failed = False
    try:
        _ = execute_task(make_execution_task(0, "x", "not-an-operation"))
    except:
        unknown_failed = True
    assert_raises(unknown_failed, "unknown operation")
    checks += 1
    var integer_failed = False
    try:
        _ = execute_task(make_execution_task(0, "7x", "double_int"))
    except:
        integer_failed = True
    assert_raises(integer_failed, "invalid integer")
    checks += 1

    var unsorted_results = List[ExecutionResult]()
    unsorted_results.append(ExecutionResult(2, "two", "identity", "{}"))
    unsorted_results.append(ExecutionResult(0, "zero", "identity", "{}"))
    unsorted_results.append(ExecutionResult(1, "one", "identity", "{}"))
    var reduced = deterministic_reduce(unsorted_results)
    assert_true(
        reduced[0] == "zero" and reduced[2] == "two", "deterministic reduce"
    )
    checks += 1
    var unreduced = deterministic_reduce(unsorted_results, False)
    assert_true(
        unreduced[0] == "two" and unreduced[2] == "one", "non-preserving reduce"
    )
    checks += 1

    var empty_tasks = List[type_of(task_two)]()
    var empty_run = execute_tasks_deterministically(empty_tasks, defaults)
    assert_true(empty_run.mode == "empty", "empty mode")
    checks += 1
    assert_true(
        empty_run.workers == 0 and empty_run.task_count == 0, "empty counts"
    )
    checks += 1

    var serial_tasks = List[type_of(task_two)]()
    serial_tasks.append(
        make_execution_task(2, "2", "double_int", metadata_json='{"slot":2}')
    )
    serial_tasks.append(
        make_execution_task(0, "0", "double_int", metadata_json='{"slot":0}')
    )
    serial_tasks.append(
        make_execution_task(1, "1", "double_int", metadata_json='{"slot":1}')
    )
    var serial_run = execute_tasks_deterministically(
        serial_tasks, make_execution_network_config(4, "fifo")
    )
    assert_true(serial_run.mode == "serial", "serial mode")
    checks += 1
    assert_true(serial_run.workers == 1, "serial workers")
    checks += 1
    assert_true(
        serial_run.values[0] == "0" and serial_run.values[2] == "4",
        "serial deterministic values",
    )
    checks += 1
    assert_true(
        serial_run.results[0].task_index == 2, "serial scheduled result order"
    )
    checks += 1
    assert_true(
        serial_run.results[0].metadata_json == '{"slot":2}', "serial metadata"
    )
    checks += 1
    assert_true(
        execution_run_snapshot_json(serial_run).find('"task_count":3') >= 0,
        "run snapshot count",
    )
    checks += 1
    assert_true(
        execution_run_snapshot_json(serial_run).find("parallel_or_serial") >= 0,
        "run snapshot property",
    )
    checks += 1

    var lifo_run = execute_tasks_deterministically(
        serial_tasks,
        make_execution_network_config(4, "lifo", preserve_input_order=False),
    )
    assert_true(
        lifo_run.values[0] == "2" and lifo_run.values[2] == "4",
        "lifo non-preserving values",
    )
    checks += 1
    assert_true(lifo_run.results[0].task_index == 1, "lifo scheduled results")
    checks += 1

    var priority_tasks = List[type_of(task_two)]()
    priority_tasks.append(make_execution_task(0, "slow", priority=10))
    priority_tasks.append(make_execution_task(1, "fast", priority=1))
    var priority_run = execute_tasks_deterministically(
        priority_tasks,
        make_execution_network_config(
            2, "priority", preserve_input_order=False
        ),
    )
    assert_true(priority_run.values[0] == "fast", "priority execution")
    checks += 1

    var thread_tasks = List[type_of(task_two)]()
    thread_tasks.append(
        make_execution_task(
            2,
            "2",
            callable_path="reta_mojo.execution_network:double_int",
            metadata_json='{"worker":2}',
        )
    )
    thread_tasks.append(
        make_execution_task(
            0,
            "0",
            callable_path="reta_mojo.execution_network:double_int",
            metadata_json='{"worker":0}',
        )
    )
    thread_tasks.append(
        make_execution_task(
            1,
            "1",
            callable_path="reta_mojo.execution_network:double_int",
            metadata_json='{"worker":1}',
        )
    )
    var thread_run = execute_tasks_deterministically(
        thread_tasks,
        make_execution_network_config(2, "fifo", True, "fork"),
    )
    assert_true(thread_run.mode == "threads", "thread mode")
    checks += 1
    assert_true(thread_run.workers == 2, "thread workers")
    checks += 1
    assert_true(
        thread_run.values[0] == "0" and thread_run.values[2] == "4",
        "thread deterministic values",
    )
    checks += 1
    assert_true(
        thread_run.results[0].task_index == 2, "thread scheduled result order"
    )
    checks += 1
    assert_true(
        thread_run.results[0].metadata_json == '{"worker":2}',
        "thread metadata",
    )
    checks += 1

    var unicode_thread_tasks = List[type_of(task_two)]()
    unicode_thread_tasks.append(
        make_execution_task(
            0, "ä\nß", callable_path="reta_mojo.execution_network:identity"
        )
    )
    unicode_thread_tasks.append(
        make_execution_task(
            1, "終", callable_path="reta_mojo.execution_network:identity"
        )
    )
    var unicode_thread = execute_tasks_deterministically(
        unicode_thread_tasks,
        make_execution_network_config(2, "fifo", True, "fork"),
    )
    assert_true(unicode_thread.values[0] == "ä\nß", "thread UTF-8 payload")
    checks += 1

    var no_callable_run = execute_tasks_deterministically(
        serial_tasks, make_execution_network_config(3, "fifo", True, "fork")
    )
    assert_true(
        no_callable_run.mode == "threads",
        "thread execution does not require callable paths",
    )
    checks += 1

    var legacy_spawn = execute_tasks_deterministically(
        thread_tasks,
        make_execution_network_config(2, "fifo", True, "spawn"),
    )
    assert_true(
        legacy_spawn.mode == "threads",
        "legacy start method is ignored by thread backend",
    )
    checks += 1

    var broken_thread_tasks = List[type_of(task_two)]()
    broken_thread_tasks.append(
        make_execution_task(
            0,
            "not-an-int",
            callable_path="reta_mojo.execution_network:double_int",
        )
    )
    broken_thread_tasks.append(
        make_execution_task(
            1,
            "2",
            callable_path="reta_mojo.execution_network:double_int",
        )
    )
    var worker_failed = False
    try:
        _ = execute_tasks_deterministically(
            broken_thread_tasks,
            make_execution_network_config(2, "fifo", True, "fork"),
        )
    except:
        worker_failed = True
    assert_raises(worker_failed, "thread worker failure")
    checks += 1

    assert_true(checks == 85, "test count")
    print("execution network thread tests: 85/85")
