"""Native command surface for Stage-11g SQLite persistence."""

from std.sys import argv
from reta_mojo.persistence import (
    PersistenceConfig,
    bootstrap_persistence,
    cache_get,
    cache_put,
    close_persistence,
    invalidate_cache,
    json_context,
    load_section,
    load_sheaf_snapshot,
    no_context,
    open_persistence,
    persist_execution_run,
    persist_section,
    persist_sheaf_snapshot,
    persistence_count_line,
    persistence_counts,
    query_audit_events,
    record_audit_event,
    section_digest,
    stable_digest_json,
)


def _usage() -> None:
    print("reta-mojo-persistence")
    print("  --summary [DB]")
    print("  --inspect DB")
    print("  --demo [DB]")
    print("  --digest-json CANONICAL_JSON")
    print("  --section-digest KIND NAME PAYLOAD_JSON [CONTEXT_JSON]")
    print("  --load-section DB SECTION_HASH")
    print("  --load-sheaf DB SNAPSHOT_HASH")
    print("  --cache-get DB CACHE_KEY")


def _config(path: String) -> PersistenceConfig:
    return PersistenceConfig(path, True, "WAL")


def _summary(path: String) raises:
    var config = _config(path)
    var bundle = bootstrap_persistence(config)
    var connection = open_persistence(config)
    print("category=" + bundle.category)
    print("tables=" + String(len(bundle.tables)))
    print("morphisms=" + String(len(bundle.morphisms)))
    print("universal_property=" + bundle.universal_property)
    print(persistence_count_line(persistence_counts(connection)))
    close_persistence(connection)


def _demo(path: String) raises:
    var config = _config(path)
    var bundle = bootstrap_persistence(config)
    var connection = open_persistence(config)
    var context = json_context("{\"scope\":\"prompt\"}")

    var section = persist_section(
        connection,
        "local",
        "alpha",
        "{\"text\":\"a1\"}",
        context,
    )
    var loaded = load_section(connection, section.digest)
    var sheaf = persist_sheaf_snapshot(
        connection,
        "reta",
        "{\"canonical\":\"Religionen\"}",
        context,
    )
    var run = persist_execution_run(
        connection,
        "render",
        3,
        "{\"ok\":true}",
        context,
    )
    var audit = record_audit_event(
        connection,
        "render",
        "alpha",
        "{\"status\":\"ok\"}",
    )
    var events = query_audit_events(connection, "render", "alpha", 5)
    var cached = cache_put(connection, "answer", "{\"value\":42}")
    var cache_before = cache_get(connection, "answer")
    var invalidated = invalidate_cache(connection, "answer")
    var cache_after = cache_get(connection, "answer")

    print("category=" + bundle.category)
    print("tables=" + String(len(bundle.tables)) + " morphisms=" + String(len(bundle.morphisms)))
    print("context_digest=" + stable_digest_json(context.json))
    print("section_digest=" + section.digest)
    print("section_payload=" + loaded.payload_json)
    print("sheaf_digest=" + sheaf.digest)
    print("run_digest=" + run.digest)
    print("audit_digest=" + audit.digest)
    print("audit_events=" + String(len(events)))
    print("cache_digest=" + cached.digest)
    print("cache_before=" + (cache_before.value_json if cache_before.found else "missing"))
    print("invalidated=" + String(invalidated))
    print("cache_after=" + (cache_after.value_json if cache_after.found else "missing"))
    print(persistence_count_line(persistence_counts(connection)))
    close_persistence(connection)


def main() raises:
    var args = argv()
    if len(args) == 1:
        _summary(":memory:")
        return

    var command = String(args[1])
    if command == "--summary" and len(args) == 2:
        _summary(":memory:")
        return
    if command == "--summary" and len(args) == 3:
        _summary(String(args[2]))
        return
    if command == "--inspect" and len(args) == 3:
        _summary(String(args[2]))
        return
    if command == "--demo" and len(args) == 2:
        _demo(":memory:")
        return
    if command == "--demo" and len(args) == 3:
        _demo(String(args[2]))
        return
    if command == "--digest-json" and len(args) == 3:
        print(stable_digest_json(String(args[2])))
        return
    if command == "--section-digest" and len(args) == 5:
        print(
            section_digest(
                String(args[2]),
                String(args[3]),
                String(args[4]),
                no_context(),
            )
        )
        return
    if command == "--section-digest" and len(args) == 6:
        print(
            section_digest(
                String(args[2]),
                String(args[3]),
                String(args[4]),
                json_context(String(args[5])),
            )
        )
        return
    if command == "--load-section" and len(args) == 4:
        var config = _config(String(args[2]))
        var connection = open_persistence(config)
        var loaded = load_section(connection, String(args[3]))
        if not loaded.found:
            print("missing")
        else:
            print("section_hash=" + loaded.section_hash)
            print("kind=" + loaded.kind)
            print("name=" + loaded.name)
            print("context_hash=" + (loaded.context_hash if loaded.context_hash != "" else "null"))
            print("payload_json=" + loaded.payload_json)
        close_persistence(connection)
        return
    if command == "--load-sheaf" and len(args) == 4:
        var config = _config(String(args[2]))
        var connection = open_persistence(config)
        var loaded = load_sheaf_snapshot(connection, String(args[3]))
        if not loaded.found:
            print("missing")
        else:
            print("snapshot_hash=" + loaded.snapshot_hash)
            print("sheaf_name=" + loaded.sheaf_name)
            print("context_hash=" + (loaded.context_hash if loaded.context_hash != "" else "null"))
            print("payload_json=" + loaded.payload_json)
        close_persistence(connection)
        return
    if command == "--cache-get" and len(args) == 4:
        var config = _config(String(args[2]))
        var connection = open_persistence(config)
        var value = cache_get(connection, String(args[3]))
        print(value.value_json if value.found else "missing")
        close_persistence(connection)
        return

    _usage()
    raise Error("invalid persistence arguments")
