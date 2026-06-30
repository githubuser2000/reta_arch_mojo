from std.collections import List
from reta_mojo.persistence import (
    CacheWrite,
    PersistenceConfig,
    SectionWrite,
    SheafSnapshotWrite,
    bootstrap_persistence,
    cache_get,
    cache_put,
    cache_put_many,
    close_persistence,
    execution_run_digest,
    invalidate_cache,
    json_context,
    load_section,
    load_sheaf_snapshot,
    no_context,
    open_persistence,
    persist_execution_run,
    persist_section,
    persist_sections_batch,
    persist_sheaf_snapshot,
    persist_sheaf_snapshots_batch,
    persistence_counts,
    query_audit_events,
    record_audit_event,
    section_digest,
    sheaf_snapshot_digest,
    stable_digest_json,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var config = PersistenceConfig(":memory:", True, "WAL")
    var bundle = bootstrap_persistence(config)
    assert_true(bundle.category == "PersistenceCategory", "bundle category")
    assert_true(len(bundle.tables) == 6, "table count")
    assert_true(len(bundle.morphisms) == 12, "morphism count")
    assert_true(
        bundle.universal_property
        == "load_persisted_snapshot_equals_original_snapshot_when_digest_matches",
        "universal property",
    )

    var context = json_context("{\"scope\":\"prompt\"}")
    assert_true(
        stable_digest_json(context.json)
        == "0b2c33c459f712cf02967ba6b34959c66788358fa136227de528c83c0f0b31f7",
        "context digest parity",
    )
    assert_true(
        section_digest("local", "alpha", "{\"text\":\"a1\"}", context)
        == "3caadc4462208b90853df7fa9d58a2968b9a5e44e87a1bbeb0a688ac3f09cf27",
        "section digest parity",
    )
    assert_true(
        sheaf_snapshot_digest("reta", "{\"canonical\":\"Religionen\"}", context)
        == "cffea35e90ead8999314317295e473fb3503d8138c49843086812d74accbecdd",
        "sheaf digest parity",
    )
    assert_true(
        execution_run_digest("render", 3, "{\"ok\":true}", context)
        == "770d60e4e9c683aed6abf92f63c2aee22eeeb22aa4ccfb2267a164fe14b8e3ae",
        "execution digest parity",
    )
    assert_true(
        stable_digest_json("{\"ä\":\"ß\"}")
        == "caa4680584e000acc7f3efe59689ca80d6d4cc3d3c90e22d526b9bfcac04775b",
        "unicode digest parity",
    )
    assert_true(
        stable_digest_json("{\"status\":\"ok\"}")
        == "a29ee2b15c494311c52521766e44af56a3ad2248e7a8ab465e5206463c13d288",
        "audit digest parity",
    )

    var connection = open_persistence(config)
    var section = persist_section(
        connection,
        "local",
        "alpha",
        "{\"text\":\"a1\"}",
        context,
    )
    var loaded = load_section(connection, section.digest)
    assert_true(loaded.found, "section found")
    assert_true(loaded.kind == "local", "section kind")
    assert_true(loaded.name == "alpha", "section name")
    assert_true(loaded.payload_json == "{\"text\":\"a1\"}", "section payload")
    assert_true(loaded.context_hash == stable_digest_json(context.json), "section context")
    assert_true(not load_section(connection, "missing").found, "missing section")

    var sheaf = persist_sheaf_snapshot(
        connection,
        "reta",
        "{\"canonical\":\"Religionen\"}",
        context,
    )
    var loaded_sheaf = load_sheaf_snapshot(connection, sheaf.digest)
    assert_true(loaded_sheaf.found, "sheaf found")
    assert_true(loaded_sheaf.sheaf_name == "reta", "sheaf name")
    assert_true(
        loaded_sheaf.payload_json == "{\"canonical\":\"Religionen\"}",
        "sheaf payload",
    )

    var run = persist_execution_run(
        connection,
        "render",
        3,
        "{\"ok\":true}",
        context,
    )
    assert_true(run.digest == "770d60e4e9c683aed6abf92f63c2aee22eeeb22aa4ccfb2267a164fe14b8e3ae", "run digest")

    var audit = record_audit_event(connection, "render", "alpha", "{\"status\":\"ok\"}")
    assert_true(audit.has_rowid, "audit rowid")
    assert_true(audit.rowid == 1, "audit rowid value")
    var events = query_audit_events(connection, "render", "alpha", 5)
    assert_true(len(events) == 1, "audit query count")
    assert_true(events[0].payload_json == "{\"status\":\"ok\"}", "audit payload")
    assert_true(len(query_audit_events(connection, "", "", 0)) == 1, "audit minimum limit")

    var cached = cache_put(connection, "answer", "{\"value\":42}")
    assert_true(cached.digest == "dc60e632a90329ccfd34fbe904d94704dbbb6669575185e26389854ff64139c3", "cache digest")
    var cache_value = cache_get(connection, "answer")
    assert_true(cache_value.found, "cache found")
    assert_true(cache_value.value_json == "{\"value\":42}", "cache payload")
    assert_true(invalidate_cache(connection, "answer") == 1, "cache invalidation")
    assert_true(not cache_get(connection, "answer").found, "cache invalid")
    _ = cache_put(connection, "answer", "{\"value\":43}")
    assert_true(cache_get(connection, "answer").found, "cache reactivated")
    assert_true(cache_get(connection, "answer").value_json == "{\"value\":43}", "cache replacement")

    var cache_entries = List[CacheWrite]()
    cache_entries.append(CacheWrite("a", "1"))
    cache_entries.append(CacheWrite("b", "2"))
    var cache_records = cache_put_many(connection, cache_entries)
    assert_true(len(cache_records) == 2, "cache batch")
    assert_true(invalidate_cache(connection, "") == 3, "global cache invalidation")
    assert_true(not cache_get(connection, "b").found, "global cache invalid")

    var section_entries = List[SectionWrite]()
    section_entries.append(SectionWrite("local", "beta", "{\"text\":\"b1\"}", context.copy()))
    section_entries.append(SectionWrite("local", "gamma", "{\"text\":\"g1\"}", no_context()))
    var section_records = persist_sections_batch(connection, section_entries)
    assert_true(len(section_records) == 2, "section batch")
    assert_true(load_section(connection, section_records[1].digest).context_hash == "", "null context")
    var quoted_section = persist_section(
        connection,
        "local's",
        "delta'; DROP TABLE local_sections;--",
        "{\"text\":\"D'Angelo\"}",
        no_context(),
    )
    var quoted_loaded = load_section(connection, quoted_section.digest)
    assert_true(quoted_loaded.found, "quoted section found")
    assert_true(quoted_loaded.name == "delta'; DROP TABLE local_sections;--", "quoted section name")
    assert_true(quoted_loaded.payload_json == "{\"text\":\"D'Angelo\"}", "quoted section payload")

    var sheaf_entries = List[SheafSnapshotWrite]()
    sheaf_entries.append(SheafSnapshotWrite("one", "{\"x\":1}", context.copy()))
    sheaf_entries.append(SheafSnapshotWrite("two", "{\"x\":2}", no_context()))
    var sheaf_records = persist_sheaf_snapshots_batch(connection, sheaf_entries)
    assert_true(len(sheaf_records) == 2, "sheaf batch")

    var counts = persistence_counts(connection)
    assert_true(counts.open_contexts == 1, "context rows")
    assert_true(counts.local_sections == 4, "section rows")
    assert_true(counts.sheaf_snapshots == 3, "sheaf rows")
    assert_true(counts.execution_runs == 1, "run rows")
    assert_true(counts.audit_events == 1, "audit rows")
    assert_true(counts.cache_entries == 3, "cache rows")
    close_persistence(connection)
    print("persistence tests: 47/47")
