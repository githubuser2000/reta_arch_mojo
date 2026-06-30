"""Native deterministic execution-network primitives for Reta.

This module ports ``reta_architecture.execution_network`` without importing
Python.  The dynamic ``Any``/callable boundary of the reference implementation
is represented as UTF-8 String payloads plus an explicit operation tag.  Queue
order, priority order, deterministic reduction, bounded channels and the Linux
fork worker path are native Mojo runtime behaviour.
"""

from std.collections import List
from std.collections.string import atol, ord
from std.ffi import c_int, external_call
from std.io import FileHandle
from std.memory import stack_allocation


@fieldwise_init
struct ExecutionNetworkConfig(Copyable):
    var max_workers: Int
    var queue_discipline: String
    var use_processes: Bool
    var start_method: String
    var preserve_input_order: Bool
    var bounded_queue_size: Int


@fieldwise_init
struct ExecutionTask(Copyable):
    var index: Int
    var payload: String
    var operation: String
    var priority: Int
    var callable_path: String
    var metadata_json: String


@fieldwise_init
struct ExecutionResult(Copyable):
    var task_index: Int
    var value: String
    var operation: String
    var metadata_json: String


@fieldwise_init
struct ExecutionRunResult(Copyable):
    var values: List[String]
    var results: List[ExecutionResult]
    var config: ExecutionNetworkConfig
    var workers: Int
    var task_count: Int
    var queue_discipline: String
    var mode: String


@fieldwise_init
struct ResourceSemaphore(Copyable):
    var value: Int
    var available: Int

    def acquire(mut self, timeout_ms: Int = -1) -> Bool:
        _ = timeout_ms
        if self.available <= 0:
            return False
        self.available -= 1
        return True

    def release(mut self) raises:
        if self.available >= self.value:
            raise Error("bounded semaphore released too many times")
        self.available += 1

    def snapshot_json(self) -> String:
        return (
            '{"class":"ResourceSemaphore","value":'
            + String(self.value)
            + ',"available":'
            + String(self.available)
            + "}"
        )


struct FifoTaskQueue(Copyable):
    var _items: List[ExecutionTask]
    var _head: Int

    def __init__(out self):
        self._items = List[ExecutionTask]()
        self._head = 0

    def push(mut self, task: ExecutionTask):
        self._items.append(task.copy())

    def pop(mut self) raises -> ExecutionTask:
        if self._head >= len(self._items):
            raise Error("FIFO task queue is empty")
        var task = self._items[self._head].copy()
        self._head += 1
        return task^

    def size(self) -> Int:
        return max(0, len(self._items) - self._head)


struct LifoTaskStack(Copyable):
    var _items: List[ExecutionTask]

    def __init__(out self):
        self._items = List[ExecutionTask]()

    def push(mut self, task: ExecutionTask):
        self._items.append(task.copy())

    def pop(mut self) raises -> ExecutionTask:
        if len(self._items) == 0:
            raise Error("LIFO task stack is empty")
        return self._items.pop()

    def size(self) -> Int:
        return len(self._items)


def _task_before(left: ExecutionTask, right: ExecutionTask) -> Bool:
    if left.priority != right.priority:
        return left.priority < right.priority
    return left.index < right.index


struct PriorityTaskQueue(Copyable):
    var _heap: List[ExecutionTask]

    def __init__(out self):
        self._heap = List[ExecutionTask]()

    def push(mut self, task: ExecutionTask):
        self._heap.append(task.copy())
        var index = len(self._heap) - 1
        while index > 0:
            var parent = (index - 1) // 2
            if not _task_before(self._heap[index], self._heap[parent]):
                break
            var temporary = self._heap[parent].copy()
            self._heap[parent] = self._heap[index].copy()
            self._heap[index] = temporary^
            index = parent

    def pop(mut self) raises -> ExecutionTask:
        if len(self._heap) == 0:
            raise Error("priority task queue is empty")
        var root = self._heap[0].copy()
        var last = self._heap.pop()
        if len(self._heap) > 0:
            self._heap[0] = last^
            var index = 0
            while True:
                var left = index * 2 + 1
                var right = left + 1
                if left >= len(self._heap):
                    break
                var smallest = left
                if right < len(self._heap) and _task_before(
                    self._heap[right], self._heap[left]
                ):
                    smallest = right
                if not _task_before(self._heap[smallest], self._heap[index]):
                    break
                var temporary = self._heap[index].copy()
                self._heap[index] = self._heap[smallest].copy()
                self._heap[smallest] = temporary^
                index = smallest
        return root^

    def size(self) -> Int:
        return len(self._heap)


struct StringChannelQueue(Copyable):
    var _items: List[String]
    var _head: Int
    var maxsize: Int

    def __init__(out self, maxsize: Int = 0):
        self._items = List[String]()
        self._head = 0
        self.maxsize = max(0, maxsize)

    def send(mut self, message: String) raises:
        if self.maxsize > 0 and self.size() >= self.maxsize:
            raise Error("channel queue is full")
        self._items.append(message.copy())

    def receive(mut self, timeout_ms: Int = -1) raises -> String:
        _ = timeout_ms
        if self._head >= len(self._items):
            raise Error("channel queue is empty")
        var message = self._items[self._head].copy()
        self._head += 1
        return message^

    def size(self) -> Int:
        return max(0, len(self._items) - self._head)


struct HalfDuplexChannel(Copyable):
    var requests: StringChannelQueue
    var responses: StringChannelQueue

    def __init__(out self, maxsize: Int = 0):
        self.requests = StringChannelQueue(maxsize)
        self.responses = StringChannelQueue(maxsize)

    def send_request(mut self, message: String) raises:
        self.requests.send(message)

    def receive_request(mut self, timeout_ms: Int = -1) raises -> String:
        return self.requests.receive(timeout_ms)

    def send_response(mut self, message: String) raises:
        self.responses.send(message)

    def receive_response(mut self, timeout_ms: Int = -1) raises -> String:
        return self.responses.receive(timeout_ms)

    def snapshot_json(self) -> String:
        return (
            '{"class":"HalfDuplexChannel","requests":'
            + String(self.requests.size())
            + ',"responses":'
            + String(self.responses.size())
            + "}"
        )


struct FullDuplexChannel(Copyable):
    var a_to_b: StringChannelQueue
    var b_to_a: StringChannelQueue

    def __init__(out self, maxsize: Int = 0):
        self.a_to_b = StringChannelQueue(maxsize)
        self.b_to_a = StringChannelQueue(maxsize)

    def send_a_to_b(mut self, message: String) raises:
        self.a_to_b.send(message)

    def receive_a_to_b(mut self, timeout_ms: Int = -1) raises -> String:
        return self.a_to_b.receive(timeout_ms)

    def send_b_to_a(mut self, message: String) raises:
        self.b_to_a.send(message)

    def receive_b_to_a(mut self, timeout_ms: Int = -1) raises -> String:
        return self.b_to_a.receive(timeout_ms)

    def snapshot_json(self) -> String:
        return (
            '{"class":"FullDuplexChannel","a_to_b":'
            + String(self.a_to_b.size())
            + ',"b_to_a":'
            + String(self.b_to_a.size())
            + "}"
        )


@fieldwise_init
struct ExecutionNetworkBundle(Copyable):
    var config: ExecutionNetworkConfig
    var processor_cores: Int
    var cpu_semaphore: ResourceSemaphore
    var file_io_semaphore: ResourceSemaphore
    var output_semaphore: ResourceSemaphore


def available_worker_count() -> Int:
    """Return online logical processors through glibc, with a safe fallback."""
    var detected = Int(external_call["get_nprocs", c_int]())
    return max(1, detected)


def _hex_nibble(value: Int) -> String:
    if value < 10:
        return chr(48 + value)
    return chr(87 + value)


def _json_quote(value: String) -> String:
    var escaped = value.replace("\\", "\\\\")
    escaped = escaped.replace('"', '\\"')
    escaped = escaped.replace(chr(8), "\\b")
    escaped = escaped.replace(chr(12), "\\f")
    escaped = escaped.replace("\n", "\\n")
    escaped = escaped.replace("\r", "\\r")
    escaped = escaped.replace("\t", "\\t")
    for code in range(32):
        if code == 8 or code == 9 or code == 10 or code == 12 or code == 13:
            continue
        escaped = escaped.replace(
            chr(code),
            "\\u00" + _hex_nibble((code >> 4) & 15) + _hex_nibble(code & 15),
        )
    return '"' + escaped + '"'


def _json_bool(value: Bool) -> String:
    return "true" if value else "false"


def execution_network_config_snapshot_json(
    config: ExecutionNetworkConfig,
) -> String:
    var start_method = (
        _json_quote(config.start_method) if config.start_method.byte_length()
        > 0 else "null"
    )
    var bounded_queue_size = (
        String(config.bounded_queue_size) if config.bounded_queue_size
        > 0 else "null"
    )
    return (
        '{"class":"ExecutionNetworkConfig","max_workers":'
        + String(config.max_workers)
        + ',"resolved_available_workers":'
        + String(available_worker_count())
        + ',"queue_discipline":'
        + _json_quote(config.queue_discipline)
        + ',"use_processes":'
        + _json_bool(config.use_processes)
        + ',"start_method":'
        + start_method
        + ',"preserve_input_order":'
        + _json_bool(config.preserve_input_order)
        + ',"bounded_queue_size":'
        + bounded_queue_size
        + "}"
    )


def execution_task_snapshot_json(task: ExecutionTask) -> String:
    var callable_path = (
        _json_quote(task.callable_path) if task.callable_path.byte_length()
        > 0 else "null"
    )
    return (
        '{"class":"ExecutionTask","index":'
        + String(task.index)
        + ',"operation":'
        + _json_quote(task.operation)
        + ',"priority":'
        + String(task.priority)
        + ',"callable_path":'
        + callable_path
        + ',"metadata":'
        + task.metadata_json
        + "}"
    )


def execution_result_snapshot_json(result: ExecutionResult) -> String:
    return (
        '{"class":"ExecutionResult","task_index":'
        + String(result.task_index)
        + ',"operation":'
        + _json_quote(result.operation)
        + ',"value_type":"str","value_len":'
        + String(result.value.count_codepoints())
        + ',"metadata":'
        + result.metadata_json
        + "}"
    )


def make_execution_network_config(
    max_workers: Int = -2147483647,
    queue_discipline: String = "fifo",
    use_processes: Bool = False,
    start_method: String = "",
    preserve_input_order: Bool = True,
    bounded_queue_size: Int = -2147483647,
) -> ExecutionNetworkConfig:
    var workers = (
        available_worker_count() if max_workers
        == -2147483647 else max(1, max_workers)
    )
    var discipline = queue_discipline.strip().lower()
    if (
        discipline != "fifo"
        and discipline != "lifo"
        and discipline != "priority"
    ):
        discipline = "fifo"
    var method = start_method.strip().lower()
    if method == "default" or method == "none":
        method = ""
    var queue_size = 0 if bounded_queue_size == -2147483647 else max(
        1, bounded_queue_size
    )
    return ExecutionNetworkConfig(
        workers,
        discipline^,
        use_processes,
        method^,
        preserve_input_order,
        queue_size,
    )


def default_execution_network_config() -> ExecutionNetworkConfig:
    return make_execution_network_config()


def workers_for(config: ExecutionNetworkConfig, task_count: Int) -> Int:
    return min(config.max_workers, max(1, task_count))


def make_execution_task(
    index: Int,
    payload: String,
    operation: String = "identity",
    priority: Int = 0,
    callable_path: String = "",
    metadata_json: String = "{}",
) -> ExecutionTask:
    var normalized_operation = operation.strip().lower()
    if normalized_operation.byte_length() == 0:
        normalized_operation = "identity"
    return ExecutionTask(
        index,
        payload.copy(),
        normalized_operation^,
        priority,
        callable_path.copy(),
        metadata_json.copy(),
    )


def bootstrap_execution_network(
    config: ExecutionNetworkConfig,
) -> ExecutionNetworkBundle:
    var file_workers = max(1, min(4, config.max_workers))
    return ExecutionNetworkBundle(
        config.copy(),
        available_worker_count(),
        ResourceSemaphore(config.max_workers, config.max_workers),
        ResourceSemaphore(file_workers, file_workers),
        ResourceSemaphore(1, 1),
    )


def bootstrap_default_execution_network() -> ExecutionNetworkBundle:
    return bootstrap_execution_network(default_execution_network_config())


def execution_network_bundle_snapshot_json(
    bundle: ExecutionNetworkBundle,
) -> String:
    return (
        '{"class":"ExecutionNetworkBundle",'
        + '"category":"ExecutionNetworkCategory",'
        + '"scheduler_category":"SchedulerCategory",'
        + '"channel_category":"ChannelCategory",'
        + '"config":'
        + execution_network_config_snapshot_json(bundle.config)
        + ',"processor_cores":'
        + String(bundle.processor_cores)
        + ',"queues":["FifoTaskQueue","LifoTaskStack","PriorityTaskQueue"],'
        + '"channels":["HalfDuplexChannel","FullDuplexChannel"],'
        + '"semaphores":{"cpu":'
        + bundle.cpu_semaphore.snapshot_json()
        + ',"file_io":'
        + bundle.file_io_semaphore.snapshot_json()
        + ',"output":'
        + bundle.output_semaphore.snapshot_json()
        + '},"morphisms":["enqueue_task","dequeue_task","dispatch_task",'
        + '"collect_result","deterministic_reduce","acquire_resource",'
        + '"release_resource","send_message","receive_message"],'
        + '"universal_property":"parallel_chunks_glue_deterministically_to_serial_result"}'
    )


def order_tasks(
    tasks: List[ExecutionTask],
    config: ExecutionNetworkConfig,
) raises -> List[ExecutionTask]:
    var ordered = List[ExecutionTask]()
    if config.queue_discipline == "lifo":
        var queue = LifoTaskStack()
        for task in tasks:
            queue.push(task)
        while queue.size() > 0:
            ordered.append(queue.pop())
    elif config.queue_discipline == "priority":
        var queue = PriorityTaskQueue()
        for task in tasks:
            queue.push(task)
        while queue.size() > 0:
            ordered.append(queue.pop())
    else:
        var queue = FifoTaskQueue()
        for task in tasks:
            queue.push(task)
        while queue.size() > 0:
            ordered.append(queue.pop())
    return ordered^


def _is_decimal_byte(value: Int) -> Bool:
    return value >= 48 and value <= 57


def _parse_strict_int(text: String) raises -> Int:
    var stripped = text.strip()
    if stripped.byte_length() == 0:
        raise Error("integer operation requires a decimal payload")
    var start = 0
    var first = ord(stripped[byte=0])
    if first == 43 or first == 45:
        start = 1
    if start >= stripped.byte_length():
        raise Error("integer operation requires digits")
    for index in range(start, stripped.byte_length()):
        if not _is_decimal_byte(ord(stripped[byte=index])):
            raise Error("integer operation requires a decimal payload")
    return atol(stripped)


def _operation_from_callable_path(task: ExecutionTask) -> String:
    if task.callable_path.byte_length() == 0:
        return task.operation.copy()
    var parts = task.callable_path.split(":")
    if len(parts) != 2:
        return task.operation.copy()
    var name = String(parts[1]).strip().lower()
    if name == "_builtin_operation" or name == "identity":
        return "identity"
    if name == "double_int" or name == "_double_payload":
        return "double_int"
    if name == "square_int":
        return "square_int"
    if name == "uppercase":
        return "uppercase"
    if name == "lowercase":
        return "lowercase"
    if name == "byte_length":
        return "byte_length"
    return task.operation.copy()


def execute_task(task: ExecutionTask) raises -> ExecutionResult:
    var operation = _operation_from_callable_path(task)
    var value: String
    if operation == "identity":
        value = task.payload.copy()
    elif operation == "double_int":
        value = String(_parse_strict_int(task.payload) * 2)
    elif operation == "square_int":
        var integer = _parse_strict_int(task.payload)
        value = String(integer * integer)
    elif operation == "uppercase":
        value = task.payload.upper()
    elif operation == "lowercase":
        value = task.payload.lower()
    elif operation == "byte_length":
        value = String(task.payload.byte_length())
    else:
        raise Error("unknown native execution operation: " + operation)
    return ExecutionResult(
        task.index,
        value^,
        task.operation.copy(),
        task.metadata_json.copy(),
    )


def _run_serial(tasks: List[ExecutionTask]) raises -> List[ExecutionResult]:
    var results = List[ExecutionResult]()
    for task in tasks:
        results.append(execute_task(task))
    return results^


def _wait_exit_code(pid: Int) -> Int:
    var status = stack_allocation[1, c_int]()
    status[0] = c_int(0)
    _ = external_call["waitpid", c_int](c_int(pid), status, c_int(0))
    return (Int(status[0]) >> 8) & 255


def _run_process_batch(
    tasks: List[ExecutionTask],
    start: Int,
    end: Int,
) raises -> List[ExecutionResult]:
    var pids = List[Int]()
    var read_fds = List[Int]()
    var batch_tasks = List[ExecutionTask]()

    for task_index in range(start, end):
        var descriptors = stack_allocation[2, c_int]()
        if external_call["pipe", c_int](descriptors) != 0:
            raise Error("unable to create execution worker pipe")
        var pid = Int(external_call["fork", c_int]())
        if pid < 0:
            _ = external_call["close", c_int](descriptors[0])
            _ = external_call["close", c_int](descriptors[1])
            raise Error("unable to fork execution worker")
        if pid == 0:
            _ = external_call["close", c_int](descriptors[0])
            var writer = FileHandle()
            writer.handle = Int(descriptors[1])
            try:
                var child_result = execute_task(tasks[task_index])
                writer.write_all(child_result.value.as_bytes())
                writer.close()
                _ = external_call["_exit", NoneType](c_int(0))
            except:
                writer.write_all(
                    String("native execution worker failed").as_bytes()
                )
                writer.close()
                _ = external_call["_exit", NoneType](c_int(70))
        _ = external_call["close", c_int](descriptors[1])
        pids.append(pid)
        read_fds.append(Int(descriptors[0]))
        batch_tasks.append(tasks[task_index].copy())

    var results = List[ExecutionResult]()
    for slot in range(len(pids)):
        var reader = FileHandle()
        reader.handle = read_fds[slot]
        var value = reader.read()
        reader.close()
        var exit_code = _wait_exit_code(pids[slot])
        if exit_code != 0:
            raise Error(
                "native execution worker exited with code "
                + String(exit_code)
                + ": "
                + value
            )
        var task = batch_tasks[slot].copy()
        results.append(
            ExecutionResult(
                task.index,
                value^,
                task.operation.copy(),
                task.metadata_json.copy(),
            )
        )
    return results^


def _run_processes(
    tasks: List[ExecutionTask],
    workers: Int,
    start_method: String,
) raises -> List[ExecutionResult]:
    if start_method.byte_length() > 0 and start_method != "fork":
        raise Error(
            "native execution network currently supports start_method=fork"
        )
    var results = List[ExecutionResult]()
    var start = 0
    while start < len(tasks):
        var end = min(len(tasks), start + max(1, workers))
        var batch = _run_process_batch(tasks, start, end)
        for item in batch:
            results.append(item.copy())
        start = end
    return results^


def deterministic_reduce(
    results: List[ExecutionResult],
    preserve_input_order: Bool = True,
) -> List[String]:
    var ordered = List[ExecutionResult]()
    for result in results:
        ordered.append(result.copy())
    if preserve_input_order:
        for index in range(1, len(ordered)):
            var current = ordered[index].copy()
            var position = index
            while (
                position > 0
                and ordered[position - 1].task_index > current.task_index
            ):
                ordered[position] = ordered[position - 1].copy()
                position -= 1
            ordered[position] = current^
    var values = List[String]()
    for result in ordered:
        values.append(result.value.copy())
    return values^


def execute_tasks_deterministically(
    tasks: List[ExecutionTask],
    config: ExecutionNetworkConfig,
) raises -> ExecutionRunResult:
    if len(tasks) == 0:
        return ExecutionRunResult(
            List[String](),
            List[ExecutionResult](),
            config.copy(),
            0,
            0,
            config.queue_discipline.copy(),
            "empty",
        )

    var scheduled = order_tasks(tasks, config)
    var has_callable = False
    for task in scheduled:
        if task.callable_path.byte_length() > 0:
            has_callable = True
            break
    var use_processes = config.use_processes and has_callable
    var workers = workers_for(config, len(scheduled)) if use_processes else 1
    var results = _run_processes(
        scheduled, workers, config.start_method
    ) if use_processes else _run_serial(scheduled)
    var values = deterministic_reduce(results, config.preserve_input_order)
    return ExecutionRunResult(
        values^,
        results^,
        config.copy(),
        workers,
        len(scheduled),
        config.queue_discipline.copy(),
        "processes" if use_processes else "serial",
    )


def execution_run_snapshot_json(run: ExecutionRunResult) -> String:
    var result_snapshots = String()
    for index in range(len(run.results)):
        if index > 0:
            result_snapshots += ","
        result_snapshots += execution_result_snapshot_json(run.results[index])
    return (
        '{"class":"ExecutionRunResult","values":'
        + String(len(run.values))
        + ',"results":['
        + result_snapshots
        + '],"config":'
        + execution_network_config_snapshot_json(run.config)
        + ',"workers":'
        + String(run.workers)
        + ',"task_count":'
        + String(run.task_count)
        + ',"queue_discipline":'
        + _json_quote(run.queue_discipline)
        + ',"mode":'
        + _json_quote(run.mode)
        + ',"universal_property":'
        + '"parallel_or_serial_task_cover_glues_to_the_same_ordered_result"}'
    )
