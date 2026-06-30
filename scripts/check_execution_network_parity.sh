#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
BIN=${RETA_EXECUTION_NETWORK_BIN:-"$ROOT/target/bin/reta-mojo-execution-network"}
PYTHON=${RETA_REFERENCE_PYTHON:-python3}
TMP=${TMPDIR:-/tmp}/reta-execution-network-parity-$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

PYTHONPATH="$ROOT/python_reference${PYTHONPATH:+:$PYTHONPATH}" "$PYTHON" - <<'PY' > "$TMP/expected"
from reta_architecture.execution_network import (
    ExecutionNetworkConfig,
    ExecutionTask,
    FullDuplexChannel,
    HalfDuplexChannel,
    execute_tasks_deterministically,
    order_tasks,
)

def indexes(items):
    return ",".join(str(item.index) for item in items)

def result_indexes(items):
    return ",".join(str(item.task_index) for item in items)

def values(items):
    return ",".join(str(item) for item in items)

print("[config]")
c = ExecutionNetworkConfig(
    max_workers=-2,
    queue_discipline="INVALID",
    use_processes=True,
    start_method="none",
    preserve_input_order=False,
    bounded_queue_size=-5,
)
print(f"max_workers={c.max_workers}")
print(f"queue_discipline={c.queue_discipline}")
print(f"use_processes={str(c.use_processes).lower()}")
print(f"start_method={c.start_method or ''}")
print(f"preserve_input_order={str(c.preserve_input_order).lower()}")
print(f"bounded_queue_size={c.bounded_queue_size}")

tasks = [
    ExecutionTask(2, "2", priority=10),
    ExecutionTask(0, "0", priority=5),
    ExecutionTask(1, "1", priority=1),
]
for discipline in ("fifo", "lifo", "priority"):
    print(f"[order-{discipline}]")
    print(indexes(order_tasks(tasks, ExecutionNetworkConfig(max_workers=2, queue_discipline=discipline))))

print("[serial-fifo]")
r = execute_tasks_deterministically(
    tasks,
    config=ExecutionNetworkConfig(max_workers=4, queue_discipline="fifo"),
)
print("values=" + values(r.values))
print("results=" + result_indexes(r.results))
print(f"workers={r.workers}")
print(f"mode={r.mode}")

print("[serial-lifo]")
r = execute_tasks_deterministically(
    tasks,
    config=ExecutionNetworkConfig(
        max_workers=4,
        queue_discipline="lifo",
        preserve_input_order=False,
    ),
)
print("values=" + values(r.values))
print("results=" + result_indexes(r.results))
print(f"workers={r.workers}")
print(f"mode={r.mode}")

print("[process-fork]")
process_tasks = [
    ExecutionTask(2, "2", priority=10, callable_path="reta_architecture.execution_network:_builtin_operation"),
    ExecutionTask(0, "0", priority=5, callable_path="reta_architecture.execution_network:_builtin_operation"),
    ExecutionTask(1, "1", priority=1, callable_path="reta_architecture.execution_network:_builtin_operation"),
]
r = execute_tasks_deterministically(
    process_tasks,
    config=ExecutionNetworkConfig(
        max_workers=2,
        queue_discipline="fifo",
        use_processes=True,
        start_method="fork",
    ),
)
print("values=" + values(r.values))
print("results=" + result_indexes(r.results))
print(f"workers={r.workers}")
print(f"mode={r.mode}")

print("[channels]")
half = HalfDuplexChannel(maxsize=2)
half.send_request("run")
half.send_response("ok")
print("half_request=" + half.receive_request(timeout=0.1))
print("half_response=" + half.receive_response(timeout=0.1))
full = FullDuplexChannel(maxsize=2)
full.send_a_to_b("cancel")
full.send_b_to_a("progress")
print("a_to_b=" + full.receive_a_to_b(timeout=0.1))
print("b_to_a=" + full.receive_b_to_a(timeout=0.1))
PY

{
    printf '%s\n' '[config]'
    "$BIN" --config -2 INVALID true none false -5
    for discipline in fifo lifo priority; do
        printf '[order-%s]\n' "$discipline"
        "$BIN" --order "$discipline"
    done
    printf '%s\n' '[serial-fifo]'
    "$BIN" --run-serial fifo preserve | sed -n '1,4p'
    printf '%s\n' '[serial-lifo]'
    "$BIN" --run-serial lifo scheduled | sed -n '1,4p'
    printf '%s\n' '[process-fork]'
    "$BIN" --run-process fifo preserve 2 | sed -n '1,4p'
    printf '%s\n' '[channels]'
    "$BIN" --channels
} > "$TMP/actual"

if ! diff -u "$TMP/expected" "$TMP/actual"; then
    printf '%s\n' 'execution-network Python↔Mojo parity failed' >&2
    exit 1
fi
printf '%s\n' 'execution-network Python↔Mojo parity: 8/8'
