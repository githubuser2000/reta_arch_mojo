from std.collections import List
from reta_mojo.execution_network import (
    execute_tasks_deterministically,
    execution_run_snapshot_json,
    make_execution_network_config,
    make_execution_task,
)
from reta_mojo.persistence import (
    PersistenceConfig,
    close_persistence,
    execution_run_digest,
    json_context,
    open_persistence,
    persist_execution_run,
    persistence_counts,
    query_audit_events,
    record_audit_event,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var checks = 0
    var tasks = List[type_of(make_execution_task(0, "0"))]()
    tasks.append(
        make_execution_task(
            0,
            "6",
            callable_path="reta_mojo.execution_network:double_int",
            metadata_json='{"source":"stage11h"}',
        )
    )
    tasks.append(
        make_execution_task(
            1,
            "7",
            callable_path="reta_mojo.execution_network:square_int",
            metadata_json='{"source":"stage11h"}',
        )
    )

    var config = make_execution_network_config(2, "fifo", True, "fork")
    var run = execute_tasks_deterministically(tasks, config)
    assert_true(run.mode == "threads", "thread execution mode")
    checks += 1
    assert_true(run.workers == 2, "thread worker count")
    checks += 1
    assert_true(run.values[0] == "12", "first thread value")
    checks += 1
    assert_true(run.values[1] == "49", "second thread value")
    checks += 1

    var payload_json = execution_run_snapshot_json(run)
    assert_true(
        payload_json.find('"task_count":2') >= 0, "run payload task count"
    )
    checks += 1
    assert_true(
        payload_json.find('"mode":"threads"') >= 0, "run payload thread mode"
    )
    checks += 1

    var context = json_context('{"scope":"execution-network","stage":"11h"}')
    var connection = open_persistence(
        PersistenceConfig(":memory:", True, "WAL")
    )
    var record = persist_execution_run(
        connection,
        "execution-network",
        run.task_count,
        payload_json,
        context,
    )
    assert_true(record.table == "execution_runs", "execution table")
    checks += 1
    assert_true(record.key == "execution-network", "execution operation key")
    checks += 1
    assert_true(
        record.digest
        == execution_run_digest(
            "execution-network", run.task_count, payload_json, context
        ),
        "execution digest",
    )
    checks += 1

    var audit_payload = (
        '{"mode":"'
        + run.mode
        + '","workers":'
        + String(run.workers)
        + ',"task_count":'
        + String(run.task_count)
        + "}"
    )
    var audit = record_audit_event(
        connection, "thread_execution", record.digest, audit_payload
    )
    assert_true(audit.has_rowid and audit.rowid > 0, "audit row id")
    checks += 1

    var events = query_audit_events(
        connection, "thread_execution", record.digest, 10
    )
    assert_true(len(events) == 1, "audit event count")
    checks += 1
    assert_true(
        events[0].payload_json == audit_payload, "audit payload roundtrip"
    )
    checks += 1

    var counts = persistence_counts(connection)
    assert_true(counts.open_contexts == 1, "persisted context count")
    checks += 1
    assert_true(counts.execution_runs == 1, "persisted execution count")
    checks += 1
    assert_true(counts.audit_events == 1, "persisted audit count")
    checks += 1
    close_persistence(connection)

    assert_true(checks == 15, "integration test count")
    print("execution-network persistence integration tests: 15/15")
