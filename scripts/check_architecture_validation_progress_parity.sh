#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=python_reference:python_reference/libs python3 - "$TMP_DIR" <<'PY'
from pathlib import Path
import sys
from reta_architecture import RetaArchitecture
from tools.generate_architecture_validation import normalize_snapshot

out = Path(sys.argv[1])
root = Path('python_reference').resolve()
arch = RetaArchitecture.bootstrap(root, use_cache=False)
validation = arch.architecture_validation
validation_snapshot = normalize_snapshot(validation.snapshot(), root)
progress = arch.architecture_progress

def write(name: str, lines: list[str]) -> None:
    (out / f'{name}.expected').write_text('\n'.join(lines) + '\n', encoding='utf-8')

write('validation-summary', [
    f"checks={len(validation_snapshot['checks'])} layers={len(validation_snapshot['layers'])} passed={validation_snapshot['summary']['passed_checks']} attention={validation_snapshot['summary']['attention_checks']} failed={validation_snapshot['summary']['failed_checks']} checked_items={validation_snapshot['summary']['checked_items']}",
    f"snapshot_validation={validation_snapshot['summary']['status']}",
    'snapshot_passed=true',
    'runtime_passed=true',
])
item = validation.check_named('CategoryFunctorReferenceCheck')
write('validation-check', [
    item.name, item.layer, item.status, item.severity,
    f'checked_count={item.checked_count}', f'failed_items={len(item.failed_items)}',
])
item = next(x for x in validation.layers if x.name == 'ArchitectureActivationBundle')
write('validation-layer', [
    item.name, item.status, f'checks={len(item.checks)}', f'failed_checks={len(item.failed_checks)}',
])

write('progress-summary', [
    f'surfaces={len(progress.surfaces)} steps={len(progress.step_progress)} waves={len(progress.wave_progress)} outstanding={len(progress.outstanding_work)} checks={len(progress.validation.checks)}',
    f'snapshot_validation={progress.validation.status}',
    'snapshot_consistent=true',
    'runtime_passed=true',
])
item = next(x for x in progress.surfaces if x.owner == 'reta.py')
write('progress-surface', [
    item.owner, item.owner_kind, item.execution_status,
    f'lines={item.line_count}', f'functions={item.function_count}', f'wrappers={item.wrapper_like_count}',
])
item = next(x for x in progress.step_progress if x.step_id == 'MIG34-34')
write('progress-step', [
    item.step_id, item.wave_id, item.legacy_owner, item.execution_status,
    f'remaining_work={len(item.remaining_work)}',
])
item = next(x for x in progress.wave_progress if x.wave_id == 'M0')
write('progress-wave', [
    item.wave_id, item.name, item.status,
    f'total={item.total_steps}', f'completed={item.completed_steps}',
    f'mixed={item.mixed_steps}', f'outstanding={item.outstanding_steps}',
])
item = next(x for x in progress.outstanding_work if x.item_id == 'WIP42-01')
write('progress-work', [
    item.item_id, item.priority, item.status, item.title, f'owners={len(item.owners)}',
])
PY

./target/bin/reta-mojo-validation --summary > "$TMP_DIR/validation-summary.actual"
./target/bin/reta-mojo-validation --check CategoryFunctorReferenceCheck > "$TMP_DIR/validation-check.actual"
./target/bin/reta-mojo-validation --layer ArchitectureActivationBundle > "$TMP_DIR/validation-layer.actual"
./target/bin/reta-mojo-progress --summary > "$TMP_DIR/progress-summary.actual"
./target/bin/reta-mojo-progress --surface reta.py > "$TMP_DIR/progress-surface.actual"
./target/bin/reta-mojo-progress --step MIG34-34 > "$TMP_DIR/progress-step.actual"
./target/bin/reta-mojo-progress --wave M0 > "$TMP_DIR/progress-wave.actual"
./target/bin/reta-mojo-progress --work WIP42-01 > "$TMP_DIR/progress-work.actual"

count=0
for name in \
    validation-summary validation-check validation-layer \
    progress-summary progress-surface progress-step progress-wave progress-work
do
    cmp "$TMP_DIR/$name.expected" "$TMP_DIR/$name.actual"
    count=$((count + 1))
done
printf 'architecture validation/progress parity: %s/8 byte-identical\n' "$count"
