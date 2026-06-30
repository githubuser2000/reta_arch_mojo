#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

MOJO_DB="$TMP_DIR/mojo.db"
PYTHON_DB="$TMP_DIR/python.db"

PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=python_reference:python_reference/libs python3 - "$PYTHON_DB" "$TMP_DIR" <<'PY'
from pathlib import Path
import sqlite3
import sys

from reta_architecture.persistence import (
    bootstrap_persistence,
    cache_get,
    cache_put,
    invalidate_cache,
    load_section,
    load_sheaf_snapshot,
    persist_execution_run,
    persist_section,
    persist_sheaf_snapshot,
    query_audit_events,
    record_audit_event,
    stable_digest,
)

python_db = Path(sys.argv[1])
out = Path(sys.argv[2])
bundle = bootstrap_persistence(db_path=str(python_db))
connection = bundle.connect()
context = {"scope": "prompt"}
section = persist_section(connection, kind="local", name="alpha", payload={"text": "a1"}, context=context)
loaded = load_section(connection, section.digest)
sheaf = persist_sheaf_snapshot(connection, sheaf_name="reta", payload={"canonical": "Religionen"}, context=context)
run = persist_execution_run(connection, operation="render", task_count=3, payload={"ok": True}, context=context)
audit = record_audit_event(connection, event_type="render", subject="alpha", payload={"status": "ok"})
events = query_audit_events(connection, event_type="render", subject="alpha", limit=5)
cached = cache_put(connection, "answer", {"value": 42})
cache_before = cache_get(connection, "answer")
invalidated = invalidate_cache(connection, "answer")
cache_after = cache_get(connection, "answer")
counts = {
    table: connection.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
    for table in (
        "open_contexts", "local_sections", "sheaf_snapshots", "execution_runs", "audit_events", "cache_entries"
    )
}
lines = [
    "category=PersistenceCategory",
    "tables=6 morphisms=12",
    f"context_digest={stable_digest(context)}",
    f"section_digest={section.digest}",
    f"section_payload={{\"text\":\"a1\"}}",
    f"sheaf_digest={sheaf.digest}",
    f"run_digest={run.digest}",
    f"audit_digest={audit.digest}",
    f"audit_events={len(events)}",
    f"cache_digest={cached.digest}",
    "cache_before={\"value\":42}",
    f"invalidated={invalidated}",
    "cache_after=missing" if cache_after is None else f"cache_after={cache_after}",
    "contexts={open_contexts} sections={local_sections} sheaves={sheaf_snapshots} runs={execution_runs} audit={audit_events} cache={cache_entries}".format(**counts),
]
(out / "demo.expected").write_text("\n".join(lines) + "\n", encoding="utf-8")

(out / "python-section.expected").write_text(
    "\n".join([
        f"section_hash={section.digest}",
        "kind=local",
        "name=alpha",
        f"context_hash={stable_digest(context)}",
        "payload_json={\"text\":\"a1\"}",
    ]) + "\n",
    encoding="utf-8",
)
(out / "python-sheaf.expected").write_text(
    "\n".join([
        f"snapshot_hash={sheaf.digest}",
        "sheaf_name=reta",
        f"context_hash={stable_digest(context)}",
        "payload_json={\"canonical\":\"Religionen\"}",
    ]) + "\n",
    encoding="utf-8",
)
(out / "python-section.hash").write_text(section.digest, encoding="ascii")
(out / "python-sheaf.hash").write_text(sheaf.digest, encoding="ascii")
connection.close()
PY

./target/bin/reta-mojo-persistence --demo "$MOJO_DB" > "$TMP_DIR/demo.actual"
cmp "$TMP_DIR/demo.expected" "$TMP_DIR/demo.actual"

# Python reads the database created by Mojo and validates semantic round-trips.
PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=python_reference:python_reference/libs python3 - "$MOJO_DB" <<'PY'
import sqlite3
import sys
from reta_architecture.persistence import load_section, load_sheaf_snapshot

connection = sqlite3.connect(sys.argv[1])
connection.row_factory = sqlite3.Row
section_hash = connection.execute("SELECT section_hash FROM local_sections").fetchone()[0]
snapshot_hash = connection.execute("SELECT snapshot_hash FROM sheaf_snapshots").fetchone()[0]
section = load_section(connection, section_hash)
sheaf = load_sheaf_snapshot(connection, snapshot_hash)
assert section["payload"] == {"text": "a1"}
assert section["context_hash"] == "0b2c33c459f712cf02967ba6b34959c66788358fa136227de528c83c0f0b31f7"
assert sheaf["payload"] == {"canonical": "Religionen"}
assert connection.execute("SELECT COUNT(*) FROM execution_runs").fetchone()[0] == 1
assert connection.execute("SELECT COUNT(*) FROM audit_events").fetchone()[0] == 1
assert connection.execute("SELECT valid FROM cache_entries WHERE cache_key='answer'").fetchone()[0] == 0
connection.close()
PY

# Mojo reads rows produced by the Python reference implementation.
PY_SECTION_HASH=$(cat "$TMP_DIR/python-section.hash")
PY_SHEAF_HASH=$(cat "$TMP_DIR/python-sheaf.hash")
./target/bin/reta-mojo-persistence --load-section "$PYTHON_DB" "$PY_SECTION_HASH" > "$TMP_DIR/python-section.actual"
./target/bin/reta-mojo-persistence --load-sheaf "$PYTHON_DB" "$PY_SHEAF_HASH" > "$TMP_DIR/python-sheaf.actual"
cmp "$TMP_DIR/python-section.expected" "$TMP_DIR/python-section.actual"
cmp "$TMP_DIR/python-sheaf.expected" "$TMP_DIR/python-sheaf.actual"

MOJO_DIGEST=$(./target/bin/reta-mojo-persistence --digest-json '{"ä":"ß"}')
PY_DIGEST=$(PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=python_reference python3 - <<'PY'
from reta_architecture.persistence import stable_digest
print(stable_digest({"ä": "ß"}))
PY
)
[ "$MOJO_DIGEST" = "$PY_DIGEST" ]

printf '%s\n' 'persistence parity: 5/5 (demo, Python reads Mojo DB, Mojo reads Python section, Mojo reads Python sheaf, Unicode digest)'
