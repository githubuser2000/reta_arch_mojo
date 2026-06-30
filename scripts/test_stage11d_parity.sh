#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TARGET_DIR=${RETA_TARGET_DIR:-"$ROOT/target/bin"}
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

python3 python_reference/reta_architecture_probe_py.py architecture-impact-json > "$TMP_DIR/impact.json"
python3 python_reference/reta_architecture_probe_py.py architecture-migration-json > "$TMP_DIR/migration.json"

emit_expected() {
    domain=$1
    query=$2
    value=${3-}
    python3 - "$TMP_DIR/$domain.json" "$domain" "$query" "$value" <<'PY'
import json, sys
path, domain, query, value = sys.argv[1:]
d = json.load(open(path, encoding='utf-8'))
if domain == 'impact':
    if query == 'summary':
        c=d['counts']; v=d['validation']
        print(f"sources={c['impact_sources']} contracts={c['impact_contracts']} gates={c['regression_gates']} candidates={c['migration_candidates']}")
        print(f"snapshot_validation={v['status']}")
        passed = v['status']=='passed' and not any(v[k] for k in ('missing_sources','sources_without_contracts','candidates_without_gates','unknown_capsules','uncovered_natural_transformations'))
        print('snapshot_passed=' + ('true' if passed else 'false'))
    elif query == 'source':
        item=next(x for x in d['impact_sources'] if x['source']==value)
        print(item['source']); print(item['source_kind'])
        print(f"capsules={len(item['capsules'])}")
        print(f"diagrams={len(item['diagrams'])}")
        print(f"route_hops={len(item['route_hops'])}")
    elif query == 'gate':
        item=next(x for x in d['regression_gates'] if x['name']==value)
        print(item['name']); print(item['status']); print(item['command'])
    elif query == 'candidate':
        item=next(x for x in d['migration_candidates'] if x['candidate']==value)
        print(item['candidate']); print(item['legacy_owner']); print(item['status'])
        print(f"gates={len(item['gates'])}")
else:
    if query == 'summary':
        c=d['counts']; v=d['validation']
        print(f"waves={c['waves']} steps={c['steps']} gate_bindings={c['gate_bindings']} invariants={c['invariants']}")
        print(f"snapshot_validation={v['status']}")
        passed = v['status']=='passed' and not any(v[k] for k in ('missing_candidates','steps_without_gate_binding','unknown_gates','unknown_diagrams','unknown_natural_transformations','unordered_waves','empty_waves'))
        print('snapshot_passed=' + ('true' if passed else 'false'))
    elif query == 'wave':
        item=next(x for x in d['waves'] if x['wave_id']==value)
        print(item['wave_id']); print(item['name']); print(item['status'])
        print(f"candidates={len(item['candidates'])}")
    elif query == 'step':
        item=next(x for x in d['steps'] if x['step_id']==value)
        print(item['step_id']); print(item['wave_id']); print(item['legacy_owner']); print(item['status'])
    elif query == 'owner':
        items=[x for x in d['steps'] if x['legacy_owner']==value]
        print(value); print(f"steps={len(items)}")
        print(f"first_step={items[0]['step_id']}"); print(f"wave={items[0]['wave_id']}")
PY
}

compare_case() {
    name=$1
    domain=$2
    query=$3
    value=${4-}
    expected="$TMP_DIR/$name.expected"
    actual="$TMP_DIR/$name.actual"
    emit_expected "$domain" "$query" "$value" > "$expected"
    if [ "$query" = summary ]; then
        "$TARGET_DIR/reta-mojo-$domain" --summary > "$actual"
    else
        "$TARGET_DIR/reta-mojo-$domain" "--$query" "$value" > "$actual"
    fi
    cmp "$expected" "$actual"
    printf '%s\n' "stage11d parity: $name"
}

compare_case impact-summary impact summary
compare_case impact-source impact source reta.py
compare_case impact-gate impact gate CommandParityGate
compare_case impact-candidate impact candidate 'Stage33Guard::reta.py'
compare_case migration-summary migration summary
compare_case migration-wave migration wave M3
compare_case migration-step migration step MIG34-03
compare_case migration-owner migration owner reta.py
printf '%s\n' 'stage11d Python↔Mojo query parity: 8/8 byte-identical'
