"""Native SQLite persistence and audit layer for the Reta architecture.

The Python reference accepts arbitrary Python values and canonicalises them with
``json.dumps(sort_keys=True, separators=(",", ":"), ensure_ascii=False)``.
The native boundary is deliberately static: callers supply already-canonical
UTF-8 JSON text.  All enclosing records are canonicalised here, so digests and
SQLite rows are interoperable with the Python implementation.
"""

from std.collections import List
from std.ffi import CStringSlice, c_int, c_size_t, external_call
from std.memory import OpaquePointer, UnsafePointer, stack_allocation


@fieldwise_init
struct PersistenceConfig(Copyable):
    var db_path: String
    var initialise: Bool
    var journal_mode: String


@fieldwise_init
struct JsonContext(Copyable):
    var present: Bool
    var json: String


@fieldwise_init
struct PersistenceBundle(Copyable):
    var config: PersistenceConfig
    var category: String
    var tables: List[String]
    var morphisms: List[String]
    var universal_property: String


@fieldwise_init
struct PersistenceConnection(Copyable):
    var handle: OpaquePointer[MutUntrackedOrigin]
    var db_path: String


@fieldwise_init
struct PersistedRecord(Copyable):
    var table: String
    var key: String
    var digest: String
    var has_rowid: Bool
    var rowid: Int


@fieldwise_init
struct LoadedSection(Copyable):
    var found: Bool
    var section_hash: String
    var kind: String
    var name: String
    var context_hash: String
    var payload_json: String
    var created_at: Float64


@fieldwise_init
struct LoadedSheafSnapshot(Copyable):
    var found: Bool
    var snapshot_hash: String
    var sheaf_name: String
    var context_hash: String
    var payload_json: String
    var created_at: Float64


@fieldwise_init
struct AuditEvent(Copyable):
    var event_id: Int
    var event_type: String
    var subject: String
    var payload_hash: String
    var payload_json: String
    var created_at: Float64


@fieldwise_init
struct CacheLookup(Copyable):
    var found: Bool
    var value_json: String


@fieldwise_init
struct SectionWrite(Copyable):
    var kind: String
    var name: String
    var payload_json: String
    var context: JsonContext


@fieldwise_init
struct SheafSnapshotWrite(Copyable):
    var sheaf_name: String
    var payload_json: String
    var context: JsonContext


@fieldwise_init
struct CacheWrite(Copyable):
    var cache_key: String
    var value_json: String


@fieldwise_init
struct PersistenceCounts(Copyable):
    var open_contexts: Int
    var local_sections: Int
    var sheaf_snapshots: Int
    var execution_runs: Int
    var audit_events: Int
    var cache_entries: Int


def default_persistence_config() -> PersistenceConfig:
    return PersistenceConfig(":memory:", True, "WAL")


def no_context() -> JsonContext:
    return JsonContext(False, "")


def json_context(canonical_json: String) -> JsonContext:
    return JsonContext(True, canonical_json)


def _empty_record(table: String, key: String, digest: String) -> PersistedRecord:
    return PersistedRecord(table, key, digest, False, 0)


def _nibble(value: Int) -> String:
    if value < 10:
        return chr(48 + value)
    return chr(87 + value)


def stable_digest_json(canonical_json: String) -> String:
    """Return the Python-compatible SHA-256 digest of canonical UTF-8 JSON."""
    var input_bytes = canonical_json.as_bytes()
    var output = stack_allocation[32, UInt8]()
    _ = external_call[
        "SHA256",
        Optional[UnsafePointer[UInt8, MutUntrackedOrigin]],
    ](input_bytes.unsafe_ptr(), c_size_t(len(input_bytes)), output)
    var result = String()
    for index in range(32):
        var byte = Int(output[index])
        result += _nibble((byte >> 4) & 15)
        result += _nibble(byte & 15)
    return result^


def json_quote(value: String) -> String:
    """Quote a UTF-8 string using the canonical JSON escaping used by Python."""
    var escaped = value.replace("\\", "\\\\")
    escaped = escaped.replace("\"", "\\\"")
    escaped = escaped.replace(chr(8), "\\b")
    escaped = escaped.replace(chr(12), "\\f")
    escaped = escaped.replace("\n", "\\n")
    escaped = escaped.replace("\r", "\\r")
    escaped = escaped.replace("\t", "\\t")
    for code in range(32):
        if code == 8 or code == 9 or code == 10 or code == 12 or code == 13:
            continue
        var replacement = "\\u00" + _nibble((code >> 4) & 15) + _nibble(code & 15)
        escaped = escaped.replace(chr(code), replacement)
    return "\"" + escaped + "\""


def _nullable_json_string(value: String, present: Bool) -> String:
    if present:
        return json_quote(value)
    return "null"


def _context_hash(context: JsonContext) -> String:
    if not context.present:
        return ""
    return stable_digest_json(context.json)


def section_digest(
    kind: String,
    name: String,
    payload_json: String,
    context: JsonContext,
) -> String:
    var context_hash = _context_hash(context)
    var wrapper = (
        "{\"context_hash\":"
        + _nullable_json_string(context_hash, context.present)
        + ",\"kind\":"
        + json_quote(kind)
        + ",\"name\":"
        + json_quote(name)
        + ",\"payload\":"
        + payload_json
        + "}"
    )
    return stable_digest_json(wrapper)


def sheaf_snapshot_digest(
    sheaf_name: String,
    payload_json: String,
    context: JsonContext,
) -> String:
    var context_hash = _context_hash(context)
    var wrapper = (
        "{\"context_hash\":"
        + _nullable_json_string(context_hash, context.present)
        + ",\"payload\":"
        + payload_json
        + ",\"sheaf_name\":"
        + json_quote(sheaf_name)
        + "}"
    )
    return stable_digest_json(wrapper)


def execution_run_digest(
    operation: String,
    task_count: Int,
    payload_json: String,
    context: JsonContext,
) -> String:
    var context_hash = _context_hash(context)
    var wrapper = (
        "{\"context_hash\":"
        + _nullable_json_string(context_hash, context.present)
        + ",\"operation\":"
        + json_quote(operation)
        + ",\"payload\":"
        + payload_json
        + ",\"task_count\":"
        + String(task_count)
        + "}"
    )
    return stable_digest_json(wrapper)


def _sql_quote(value: String) -> String:
    return "'" + value.replace("'", "''") + "'"


def _sql_nullable(value: String, present: Bool) -> String:
    if present:
        return _sql_quote(value)
    return "NULL"


def _sqlite_error(operation: String, code: Int) -> Error:
    return Error(operation + " failed with SQLite code " + String(code))


def _prepare(
    connection: PersistenceConnection,
    sql: String,
) raises -> OpaquePointer[MutUntrackedOrigin]:
    var statement_out = stack_allocation[1, OpaquePointer[MutUntrackedOrigin]]()
    var sql_storage = sql + "\0"
    var sql_c = CStringSlice(sql_storage)
    var tail = Optional[OpaquePointer[MutUntrackedOrigin]]()
    var code = external_call["sqlite3_prepare_v2", c_int](
        connection.handle,
        sql_c,
        c_int(-1),
        statement_out,
        tail,
    )
    if Int(code) != 0:
        raise _sqlite_error("sqlite3_prepare_v2", Int(code))
    return statement_out[0]


def _finalize(statement: OpaquePointer[MutUntrackedOrigin]) raises:
    var code = external_call["sqlite3_finalize", c_int](statement)
    if Int(code) != 0:
        raise _sqlite_error("sqlite3_finalize", Int(code))


def _execute_done(connection: PersistenceConnection, sql: String) raises:
    var statement = _prepare(connection, sql)
    var code = external_call["sqlite3_step", c_int](statement)
    if Int(code) != 101:
        _ = external_call["sqlite3_finalize", c_int](statement)
        raise _sqlite_error("sqlite3_step", Int(code))
    _finalize(statement)


def _execute_discard(connection: PersistenceConnection, sql: String) raises:
    var statement = _prepare(connection, sql)
    var code = external_call["sqlite3_step", c_int](statement)
    if Int(code) != 100 and Int(code) != 101:
        _ = external_call["sqlite3_finalize", c_int](statement)
        raise _sqlite_error("sqlite3_step", Int(code))
    _finalize(statement)


def _column_text(statement: OpaquePointer[MutUntrackedOrigin], index: Int) raises -> String:
    var value = external_call[
        "sqlite3_column_text",
        Optional[CStringSlice[ImmutUntrackedOrigin]],
    ](statement, c_int(index))
    if value:
        return String(value[])
    return ""


def _column_int(statement: OpaquePointer[MutUntrackedOrigin], index: Int) -> Int:
    return Int(external_call["sqlite3_column_int64", Int64](statement, c_int(index)))


def _column_float(statement: OpaquePointer[MutUntrackedOrigin], index: Int) -> Float64:
    return external_call["sqlite3_column_double", Float64](statement, c_int(index))


def _normalise_journal_mode(value: String) -> String:
    if value == "WAL" or value == "wal":
        return "WAL"
    if value == "DELETE" or value == "delete":
        return "DELETE"
    if value == "TRUNCATE" or value == "truncate":
        return "TRUNCATE"
    if value == "PERSIST" or value == "persist":
        return "PERSIST"
    if value == "MEMORY" or value == "memory":
        return "MEMORY"
    if value == "OFF" or value == "off":
        return "OFF"
    return ""


def open_persistence(config: PersistenceConfig) raises -> PersistenceConnection:
    var database_out = stack_allocation[1, OpaquePointer[MutUntrackedOrigin]]()
    var path_storage = config.db_path + "\0"
    var path_c = CStringSlice(path_storage)
    var code = external_call["sqlite3_open", c_int](path_c, database_out)
    if Int(code) != 0:
        raise _sqlite_error("sqlite3_open", Int(code))
    var connection = PersistenceConnection(database_out[0], config.db_path)
    if config.db_path != ":memory:":
        var journal_mode = _normalise_journal_mode(config.journal_mode)
        if journal_mode != "":
            _execute_discard(connection, "PRAGMA journal_mode=" + journal_mode)
    if config.initialise:
        initialise_persistence_schema(connection)
    return connection^


def close_persistence(connection: PersistenceConnection) raises:
    var code = external_call["sqlite3_close", c_int](connection.handle)
    if Int(code) != 0:
        raise _sqlite_error("sqlite3_close", Int(code))


def initialise_persistence_schema(connection: PersistenceConnection) raises:
    _execute_done(connection, "CREATE TABLE IF NOT EXISTS open_contexts (context_hash TEXT PRIMARY KEY, context_json TEXT NOT NULL, created_at REAL NOT NULL)")
    _execute_done(connection, "CREATE TABLE IF NOT EXISTS local_sections (section_hash TEXT PRIMARY KEY, kind TEXT NOT NULL, name TEXT NOT NULL, context_hash TEXT, payload_json TEXT NOT NULL, created_at REAL NOT NULL)")
    _execute_done(connection, "CREATE INDEX IF NOT EXISTS idx_local_sections_kind_name ON local_sections(kind, name)")
    _execute_done(connection, "CREATE TABLE IF NOT EXISTS sheaf_snapshots (snapshot_hash TEXT PRIMARY KEY, sheaf_name TEXT NOT NULL, context_hash TEXT, payload_json TEXT NOT NULL, created_at REAL NOT NULL)")
    _execute_done(connection, "CREATE INDEX IF NOT EXISTS idx_sheaf_snapshots_name ON sheaf_snapshots(sheaf_name)")
    _execute_done(connection, "CREATE TABLE IF NOT EXISTS execution_runs (run_hash TEXT PRIMARY KEY, operation TEXT NOT NULL, context_hash TEXT, task_count INTEGER NOT NULL, payload_json TEXT NOT NULL, created_at REAL NOT NULL)")
    _execute_done(connection, "CREATE INDEX IF NOT EXISTS idx_execution_runs_operation ON execution_runs(operation)")
    _execute_done(connection, "CREATE TABLE IF NOT EXISTS audit_events (event_id INTEGER PRIMARY KEY AUTOINCREMENT, event_type TEXT NOT NULL, subject TEXT NOT NULL, payload_hash TEXT NOT NULL, payload_json TEXT NOT NULL, created_at REAL NOT NULL)")
    _execute_done(connection, "CREATE INDEX IF NOT EXISTS idx_audit_events_type_subject ON audit_events(event_type, subject)")
    _execute_done(connection, "CREATE TABLE IF NOT EXISTS cache_entries (cache_key TEXT PRIMARY KEY, value_hash TEXT NOT NULL, value_json TEXT NOT NULL, valid INTEGER NOT NULL DEFAULT 1, created_at REAL NOT NULL, updated_at REAL NOT NULL)")


def bootstrap_persistence(config: PersistenceConfig) raises -> PersistenceBundle:
    if config.initialise:
        var connection = open_persistence(config)
        close_persistence(connection)
    var tables = List[String]()
    tables.append("open_contexts")
    tables.append("local_sections")
    tables.append("sheaf_snapshots")
    tables.append("execution_runs")
    tables.append("audit_events")
    tables.append("cache_entries")
    var morphisms = List[String]()
    morphisms.append("persist_section")
    morphisms.append("persist_sections_batch")
    morphisms.append("load_section")
    morphisms.append("persist_sheaf_snapshot")
    morphisms.append("persist_sheaf_snapshots_batch")
    morphisms.append("persist_execution_run")
    morphisms.append("record_audit_event")
    morphisms.append("query_audit_events")
    morphisms.append("cache_put")
    morphisms.append("cache_put_many")
    morphisms.append("cache_get")
    morphisms.append("invalidate_cache")
    return PersistenceBundle(
        config.copy(),
        "PersistenceCategory",
        tables^,
        morphisms^,
        "load_persisted_snapshot_equals_original_snapshot_when_digest_matches",
    )


def persist_context(
    connection: PersistenceConnection,
    context: JsonContext,
) raises -> String:
    if not context.present:
        return ""
    var digest = stable_digest_json(context.json)
    _execute_done(
        connection,
        "INSERT OR IGNORE INTO open_contexts(context_hash, context_json, created_at) VALUES ("
        + _sql_quote(digest)
        + ","
        + _sql_quote(context.json)
        + ",CAST(strftime('%s','now') AS REAL))",
    )
    return digest


def persist_section(
    connection: PersistenceConnection,
    kind: String,
    name: String,
    payload_json: String,
    context: JsonContext,
) raises -> PersistedRecord:
    var context_hash = persist_context(connection, context)
    var digest = section_digest(kind, name, payload_json, context)
    _execute_done(
        connection,
        "INSERT OR REPLACE INTO local_sections(section_hash, kind, name, context_hash, payload_json, created_at) VALUES ("
        + _sql_quote(digest)
        + ","
        + _sql_quote(kind)
        + ","
        + _sql_quote(name)
        + ","
        + _sql_nullable(context_hash, context.present)
        + ","
        + _sql_quote(payload_json)
        + ",CAST(strftime('%s','now') AS REAL))",
    )
    return _empty_record("local_sections", kind + ":" + name, digest)


def load_section(
    connection: PersistenceConnection,
    section_hash: String,
) raises -> LoadedSection:
    var statement = _prepare(
        connection,
        "SELECT section_hash, kind, name, context_hash, payload_json, created_at FROM local_sections WHERE section_hash="
        + _sql_quote(section_hash),
    )
    var code = external_call["sqlite3_step", c_int](statement)
    if Int(code) == 101:
        _finalize(statement)
        return LoadedSection(False, "", "", "", "", "", 0.0)
    if Int(code) != 100:
        _ = external_call["sqlite3_finalize", c_int](statement)
        raise _sqlite_error("load_section", Int(code))
    var result = LoadedSection(
        True,
        _column_text(statement, 0),
        _column_text(statement, 1),
        _column_text(statement, 2),
        _column_text(statement, 3),
        _column_text(statement, 4),
        _column_float(statement, 5),
    )
    _finalize(statement)
    return result^


def persist_sheaf_snapshot(
    connection: PersistenceConnection,
    sheaf_name: String,
    payload_json: String,
    context: JsonContext,
) raises -> PersistedRecord:
    var context_hash = persist_context(connection, context)
    var digest = sheaf_snapshot_digest(sheaf_name, payload_json, context)
    _execute_done(
        connection,
        "INSERT OR REPLACE INTO sheaf_snapshots(snapshot_hash, sheaf_name, context_hash, payload_json, created_at) VALUES ("
        + _sql_quote(digest)
        + ","
        + _sql_quote(sheaf_name)
        + ","
        + _sql_nullable(context_hash, context.present)
        + ","
        + _sql_quote(payload_json)
        + ",CAST(strftime('%s','now') AS REAL))",
    )
    return _empty_record("sheaf_snapshots", sheaf_name, digest)


def load_sheaf_snapshot(
    connection: PersistenceConnection,
    snapshot_hash: String,
) raises -> LoadedSheafSnapshot:
    var statement = _prepare(
        connection,
        "SELECT snapshot_hash, sheaf_name, context_hash, payload_json, created_at FROM sheaf_snapshots WHERE snapshot_hash="
        + _sql_quote(snapshot_hash),
    )
    var code = external_call["sqlite3_step", c_int](statement)
    if Int(code) == 101:
        _finalize(statement)
        return LoadedSheafSnapshot(False, "", "", "", "", 0.0)
    if Int(code) != 100:
        _ = external_call["sqlite3_finalize", c_int](statement)
        raise _sqlite_error("load_sheaf_snapshot", Int(code))
    var result = LoadedSheafSnapshot(
        True,
        _column_text(statement, 0),
        _column_text(statement, 1),
        _column_text(statement, 2),
        _column_text(statement, 3),
        _column_float(statement, 4),
    )
    _finalize(statement)
    return result^


def persist_execution_run(
    connection: PersistenceConnection,
    operation: String,
    task_count: Int,
    payload_json: String,
    context: JsonContext,
) raises -> PersistedRecord:
    var context_hash = persist_context(connection, context)
    var digest = execution_run_digest(operation, task_count, payload_json, context)
    _execute_done(
        connection,
        "INSERT OR REPLACE INTO execution_runs(run_hash, operation, context_hash, task_count, payload_json, created_at) VALUES ("
        + _sql_quote(digest)
        + ","
        + _sql_quote(operation)
        + ","
        + _sql_nullable(context_hash, context.present)
        + ","
        + String(task_count)
        + ","
        + _sql_quote(payload_json)
        + ",CAST(strftime('%s','now') AS REAL))",
    )
    return _empty_record("execution_runs", operation, digest)


def record_audit_event(
    connection: PersistenceConnection,
    event_type: String,
    subject: String,
    payload_json: String,
) raises -> PersistedRecord:
    var digest = stable_digest_json(payload_json)
    _execute_done(
        connection,
        "INSERT INTO audit_events(event_type, subject, payload_hash, payload_json, created_at) VALUES ("
        + _sql_quote(event_type)
        + ","
        + _sql_quote(subject)
        + ","
        + _sql_quote(digest)
        + ","
        + _sql_quote(payload_json)
        + ",CAST(strftime('%s','now') AS REAL))",
    )
    var rowid = Int(external_call["sqlite3_last_insert_rowid", Int64](connection.handle))
    return PersistedRecord(
        "audit_events",
        event_type + ":" + subject,
        digest,
        True,
        rowid,
    )


def query_audit_events(
    connection: PersistenceConnection,
    event_type: String,
    subject: String,
    limit: Int,
) raises -> List[AuditEvent]:
    var where = String()
    if event_type != "":
        where = "event_type=" + _sql_quote(event_type)
    if subject != "":
        if where != "":
            where += " AND "
        where += "subject=" + _sql_quote(subject)
    if where != "":
        where = " WHERE " + where
    var safe_limit = limit
    if safe_limit < 1:
        safe_limit = 1
    var statement = _prepare(
        connection,
        "SELECT event_id, event_type, subject, payload_hash, payload_json, created_at FROM audit_events"
        + where
        + " ORDER BY event_id DESC LIMIT "
        + String(safe_limit),
    )
    var events = List[AuditEvent]()
    while True:
        var code = external_call["sqlite3_step", c_int](statement)
        if Int(code) == 101:
            break
        if Int(code) != 100:
            _ = external_call["sqlite3_finalize", c_int](statement)
            raise _sqlite_error("query_audit_events", Int(code))
        events.append(
            AuditEvent(
                _column_int(statement, 0),
                _column_text(statement, 1),
                _column_text(statement, 2),
                _column_text(statement, 3),
                _column_text(statement, 4),
                _column_float(statement, 5),
            )
        )
    _finalize(statement)
    return events^


def cache_put(
    connection: PersistenceConnection,
    cache_key: String,
    value_json: String,
) raises -> PersistedRecord:
    var digest = stable_digest_json(value_json)
    _execute_done(
        connection,
        "INSERT INTO cache_entries(cache_key, value_hash, value_json, valid, created_at, updated_at) VALUES ("
        + _sql_quote(cache_key)
        + ","
        + _sql_quote(digest)
        + ","
        + _sql_quote(value_json)
        + ",1,CAST(strftime('%s','now') AS REAL),CAST(strftime('%s','now') AS REAL)) "
        + "ON CONFLICT(cache_key) DO UPDATE SET value_hash=excluded.value_hash,value_json=excluded.value_json,valid=1,updated_at=excluded.updated_at",
    )
    return _empty_record("cache_entries", cache_key, digest)


def cache_get(
    connection: PersistenceConnection,
    cache_key: String,
) raises -> CacheLookup:
    var statement = _prepare(
        connection,
        "SELECT value_json FROM cache_entries WHERE cache_key="
        + _sql_quote(cache_key)
        + " AND valid=1",
    )
    var code = external_call["sqlite3_step", c_int](statement)
    if Int(code) == 101:
        _finalize(statement)
        return CacheLookup(False, "")
    if Int(code) != 100:
        _ = external_call["sqlite3_finalize", c_int](statement)
        raise _sqlite_error("cache_get", Int(code))
    var result = CacheLookup(True, _column_text(statement, 0))
    _finalize(statement)
    return result^


def invalidate_cache(
    connection: PersistenceConnection,
    cache_key: String,
) raises -> Int:
    var where = " WHERE valid=1"
    if cache_key != "":
        where = " WHERE cache_key=" + _sql_quote(cache_key)
    _execute_done(
        connection,
        "UPDATE cache_entries SET valid=0,updated_at=CAST(strftime('%s','now') AS REAL)"
        + where,
    )
    return Int(external_call["sqlite3_changes", c_int](connection.handle))


def cache_put_many(
    connection: PersistenceConnection,
    entries: List[CacheWrite],
) raises -> List[PersistedRecord]:
    var records = List[PersistedRecord]()
    _execute_done(connection, "BEGIN IMMEDIATE")
    for entry in entries:
        var digest = stable_digest_json(entry.value_json)
        _execute_done(
            connection,
            "INSERT INTO cache_entries(cache_key, value_hash, value_json, valid, created_at, updated_at) VALUES ("
            + _sql_quote(entry.cache_key)
            + ","
            + _sql_quote(digest)
            + ","
            + _sql_quote(entry.value_json)
            + ",1,CAST(strftime('%s','now') AS REAL),CAST(strftime('%s','now') AS REAL)) "
            + "ON CONFLICT(cache_key) DO UPDATE SET value_hash=excluded.value_hash,value_json=excluded.value_json,valid=1,updated_at=excluded.updated_at",
        )
        records.append(_empty_record("cache_entries", entry.cache_key, digest))
    _execute_done(connection, "COMMIT")
    return records^


def persist_sections_batch(
    connection: PersistenceConnection,
    entries: List[SectionWrite],
) raises -> List[PersistedRecord]:
    var records = List[PersistedRecord]()
    _execute_done(connection, "BEGIN IMMEDIATE")
    for entry in entries:
        var context_hash = persist_context(connection, entry.context)
        var digest = section_digest(
            entry.kind,
            entry.name,
            entry.payload_json,
            entry.context,
        )
        _execute_done(
            connection,
            "INSERT OR REPLACE INTO local_sections(section_hash, kind, name, context_hash, payload_json, created_at) VALUES ("
            + _sql_quote(digest)
            + ","
            + _sql_quote(entry.kind)
            + ","
            + _sql_quote(entry.name)
            + ","
            + _sql_nullable(context_hash, entry.context.present)
            + ","
            + _sql_quote(entry.payload_json)
            + ",CAST(strftime('%s','now') AS REAL))",
        )
        records.append(
            _empty_record(
                "local_sections",
                entry.kind + ":" + entry.name,
                digest,
            )
        )
    _execute_done(connection, "COMMIT")
    return records^


def persist_sheaf_snapshots_batch(
    connection: PersistenceConnection,
    entries: List[SheafSnapshotWrite],
) raises -> List[PersistedRecord]:
    var records = List[PersistedRecord]()
    _execute_done(connection, "BEGIN IMMEDIATE")
    for entry in entries:
        var context_hash = persist_context(connection, entry.context)
        var digest = sheaf_snapshot_digest(
            entry.sheaf_name,
            entry.payload_json,
            entry.context,
        )
        _execute_done(
            connection,
            "INSERT OR REPLACE INTO sheaf_snapshots(snapshot_hash, sheaf_name, context_hash, payload_json, created_at) VALUES ("
            + _sql_quote(digest)
            + ","
            + _sql_quote(entry.sheaf_name)
            + ","
            + _sql_nullable(context_hash, entry.context.present)
            + ","
            + _sql_quote(entry.payload_json)
            + ",CAST(strftime('%s','now') AS REAL))",
        )
        records.append(_empty_record("sheaf_snapshots", entry.sheaf_name, digest))
    _execute_done(connection, "COMMIT")
    return records^


def _table_count(connection: PersistenceConnection, table: String) raises -> Int:
    var statement = _prepare(connection, "SELECT COUNT(*) FROM " + table)
    var code = external_call["sqlite3_step", c_int](statement)
    if Int(code) != 100:
        _ = external_call["sqlite3_finalize", c_int](statement)
        raise _sqlite_error("table_count", Int(code))
    var result = _column_int(statement, 0)
    _finalize(statement)
    return result


def persistence_counts(connection: PersistenceConnection) raises -> PersistenceCounts:
    return PersistenceCounts(
        _table_count(connection, "open_contexts"),
        _table_count(connection, "local_sections"),
        _table_count(connection, "sheaf_snapshots"),
        _table_count(connection, "execution_runs"),
        _table_count(connection, "audit_events"),
        _table_count(connection, "cache_entries"),
    )


def persistence_count_line(counts: PersistenceCounts) -> String:
    return (
        "contexts="
        + String(counts.open_contexts)
        + " sections="
        + String(counts.local_sections)
        + " sheaves="
        + String(counts.sheaf_snapshots)
        + " runs="
        + String(counts.execution_runs)
        + " audit="
        + String(counts.audit_events)
        + " cache="
        + String(counts.cache_entries)
    )
