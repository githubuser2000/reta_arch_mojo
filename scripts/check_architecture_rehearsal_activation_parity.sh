#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=python_reference:python_reference/libs python3 - "$TMP_DIR" <<'PY'
from pathlib import Path
import sys
from reta_architecture.category_theory import bootstrap_category_theory
from reta_architecture.architecture_map import bootstrap_architecture_map
from reta_architecture.architecture_contracts import bootstrap_architecture_contracts
from reta_architecture.architecture_witnesses import bootstrap_architecture_witnesses
from reta_architecture.architecture_coherence import bootstrap_architecture_coherence
from reta_architecture.architecture_traces import bootstrap_architecture_traces
from reta_architecture.architecture_boundaries import bootstrap_architecture_boundaries
from reta_architecture.architecture_impact import bootstrap_architecture_impact
from reta_architecture.architecture_migration import bootstrap_architecture_migration
from reta_architecture.architecture_rehearsal import bootstrap_architecture_rehearsal
from reta_architecture.architecture_activation import bootstrap_architecture_activation

out = Path(sys.argv[1])
root = Path('python_reference').resolve()
category = bootstrap_category_theory()
architecture_map = bootstrap_architecture_map()
contracts = bootstrap_architecture_contracts(category, architecture_map)
witnesses = bootstrap_architecture_witnesses(root, category, architecture_map, contracts)
coherence = bootstrap_architecture_coherence(
    category_theory=category,
    architecture_map=architecture_map,
    architecture_contracts=contracts,
    architecture_witnesses=witnesses,
)
traces = bootstrap_architecture_traces(
    repo_root=root,
    category_theory=category,
    architecture_map=architecture_map,
    architecture_contracts=contracts,
    architecture_witnesses=witnesses,
    architecture_coherence=coherence,
)
boundaries = bootstrap_architecture_boundaries(
    repo_root=root,
    architecture_map=architecture_map,
    architecture_coherence=coherence,
)
impact = bootstrap_architecture_impact(
    repo_root=root,
    category_theory=category,
    architecture_map=architecture_map,
    architecture_contracts=contracts,
    architecture_witnesses=witnesses,
    architecture_coherence=coherence,
    architecture_traces=traces,
    architecture_boundaries=boundaries,
)
migration = bootstrap_architecture_migration(
    category_theory=category,
    architecture_map=architecture_map,
    architecture_contracts=contracts,
    architecture_impact=impact,
)
rehearsal = bootstrap_architecture_rehearsal(
    category_theory=category,
    architecture_contracts=contracts,
    architecture_impact=impact,
    architecture_migration=migration,
)
activation = bootstrap_architecture_activation(
    category_theory=category,
    architecture_contracts=contracts,
    architecture_migration=migration,
    architecture_rehearsal=rehearsal,
)

def write(name: str, lines: list[str]) -> None:
    (out / f'{name}.expected').write_text('\n'.join(lines) + '\n', encoding='utf-8')

write('rehearsal-summary', [
    f'open_sets={len(rehearsal.open_sets)} moves={len(rehearsal.moves)} gate_rehearsals={len(rehearsal.gate_rehearsals)} covers={len(rehearsal.covers)}',
    f'snapshot_validation={rehearsal.validation.status}',
    'snapshot_passed=true',
])
item = next(x for x in rehearsal.open_sets if x.open_set_id == 'REH35-OPEN-M0')
write('rehearsal-open-set', [item.open_set_id, item.wave_id, item.status, f'candidates={len(item.candidates)}'])
item = next(x for x in rehearsal.moves if x.move_id == 'REH35-MOVE-MIG34-01')
write('rehearsal-move', [item.move_id, item.legacy_owner, item.target_owner, item.status, f'gates={len(item.gates)}'])
item = next(x for x in rehearsal.gate_rehearsals if x.gate_suite_id == 'REH35-GATE-MIG34-01')
write('rehearsal-gate', [item.gate_suite_id, item.status, f'preflight={len(item.preflight_commands)}', f'postflight={len(item.postflight_commands)}'])
item = next(x for x in rehearsal.covers if x.cover_id == 'REH35-COVER-M0')
write('rehearsal-cover', [item.cover_id, item.wave_id, item.status, f'moves={len(item.moves)}'])

write('activation-summary', [
    f'windows={len(activation.windows)} units={len(activation.units)} gates={len(activation.gates)} rollbacks={len(activation.rollbacks)} transactions={len(activation.transactions)}',
    f'snapshot_validation={activation.validation.status}',
    'snapshot_passed=true',
])
item = next(x for x in activation.windows if x.window_id == 'ACT36-WINDOW-M0')
write('activation-window', [item.window_id, item.wave_id, item.status, f'units={len(item.activation_units)}'])
item = next(x for x in activation.units if x.activation_id == 'ACT36-REH35-MOVE-MIG34-01')
write('activation-unit', [item.activation_id, item.legacy_owner, item.target_owner, item.status, f'required_gates={len(item.required_gates)}'])
item = next(x for x in activation.gates if x.gate_suite_id == 'ACT36-GATE-MIG34-01')
write('activation-gate', [
    item.gate_suite_id, item.status,
    f'preflight={len(item.preflight_commands)}',
    f'commit={len(item.commit_commands)}',
    f'postflight={len(item.postflight_commands)}',
    f'rollback={len(item.rollback_commands)}',
])
item = next(x for x in activation.rollbacks if x.activation_id == 'ACT36-REH35-MOVE-MIG34-01')
write('activation-rollback', [item.activation_id, item.rollback_anchor, item.status, f'protected_diagrams={len(item.protected_diagrams)}'])
item = next(x for x in activation.transactions if x.transaction_id == 'ACT36-TX-M0')
write('activation-transaction', [item.transaction_id, item.wave_id, item.status, f'units={len(item.activation_units)}'])
PY

./target/bin/reta-mojo-rehearsal --summary > "$TMP_DIR/rehearsal-summary.actual"
./target/bin/reta-mojo-rehearsal --open-set REH35-OPEN-M0 > "$TMP_DIR/rehearsal-open-set.actual"
./target/bin/reta-mojo-rehearsal --move REH35-MOVE-MIG34-01 > "$TMP_DIR/rehearsal-move.actual"
./target/bin/reta-mojo-rehearsal --gate REH35-GATE-MIG34-01 > "$TMP_DIR/rehearsal-gate.actual"
./target/bin/reta-mojo-rehearsal --cover REH35-COVER-M0 > "$TMP_DIR/rehearsal-cover.actual"
./target/bin/reta-mojo-activation --summary > "$TMP_DIR/activation-summary.actual"
./target/bin/reta-mojo-activation --window ACT36-WINDOW-M0 > "$TMP_DIR/activation-window.actual"
./target/bin/reta-mojo-activation --unit ACT36-REH35-MOVE-MIG34-01 > "$TMP_DIR/activation-unit.actual"
./target/bin/reta-mojo-activation --gate ACT36-GATE-MIG34-01 > "$TMP_DIR/activation-gate.actual"
./target/bin/reta-mojo-activation --rollback ACT36-REH35-MOVE-MIG34-01 > "$TMP_DIR/activation-rollback.actual"
./target/bin/reta-mojo-activation --transaction ACT36-TX-M0 > "$TMP_DIR/activation-transaction.actual"

count=0
for name in \
    rehearsal-summary rehearsal-open-set rehearsal-move rehearsal-gate rehearsal-cover \
    activation-summary activation-window activation-unit activation-gate activation-rollback activation-transaction
do
    cmp "$TMP_DIR/$name.expected" "$TMP_DIR/$name.actual"
    count=$((count + 1))
done
printf 'architecture rehearsal/activation parity: %s/11 byte-identical\n' "$count"
