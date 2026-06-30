#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

PYTHONPATH=python_reference:python_reference/libs python3 - "$TMP_DIR" <<'PY'
from pathlib import Path
import sys
from reta_architecture.category_theory import bootstrap_category_theory
from reta_architecture.architecture_map import bootstrap_architecture_map
from reta_architecture.architecture_contracts import bootstrap_architecture_contracts
from reta_architecture.architecture_witnesses import bootstrap_architecture_witnesses
from reta_architecture.architecture_coherence import bootstrap_architecture_coherence
from reta_architecture.architecture_traces import bootstrap_architecture_traces

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

def write(name: str, lines: list[str]) -> None:
    (out / name).write_text('\n'.join(lines) + '\n', encoding='utf-8')

write('coherence-summary.expected', [
    f'capsules={len(coherence.capsule_coherence)} routes={len(coherence.functorial_routes)} naturality={len(coherence.naturality_coherence)} laws={len(coherence.law_coherence)}',
    f'snapshot_validation={coherence.validation.status}',
    'snapshot_passed=true',
])
item = coherence.capsule_named('InputPromptCapsule')
write('coherence-capsule.expected', [
    f'{item.capsule}\t{item.category}\t{item.stage_span}',
    f'functors={len(item.functors)} transformations={len(item.natural_transformations)} diagrams={len(item.diagrams)} laws={len(item.laws)}',
    f'witness_slice={item.witness_slice}',
    item.coherence_reading,
])
item = coherence.route_for('SchemaTopologyCapsule', 'LocalSectionCapsule')
write('coherence-route.expected', [
    f'{item.source_capsule}\t{item.target_capsule}\t{item.categorical_kind}',
    f'morphism={item.morphism}',
    f'functor_or_transformation={item.functor_or_transformation}',
    f'status={item.status} contract_diagrams={len(item.contract_diagrams)} witness_diagrams={len(item.witness_diagrams)}',
    item.reading,
])
item = coherence.naturality_named('RawToCanonicalParameterTransformation')
write('coherence-transformation.expected', [
    f'{item.transformation}\t{item.status}\t{item.witness_status}',
    f'source_functor={item.source_functor}',
    f'target_functor={item.target_functor}',
    f'components={item.component_count} diagrams={len(item.diagrams)} capsules={len(item.capsules)}',
    item.naturality_condition,
])
item = next(x for x in coherence.law_coherence if x.law == 'RawCanonicalNaturalityLaw')
write('coherence-law.expected', [
    f'{item.law}\t{item.status}',
    f'obligation_present={str(item.obligation_present).lower()}',
    f'protected_capsules={len(item.protected_capsules)} diagrams={len(item.diagrams)}',
    item.reading,
])
write('traces-summary.expected', [
    f'components={len(traces.component_traces)} capsules={len(traces.capsule_traces)} stages={len(traces.stage_traces)} route_hops={sum(len(x.route) for x in traces.component_traces)}',
    f'snapshot_validation={traces.validation.status}',
    'snapshot_passed=true',
])
item = next(x for x in traces.component_traces if x.legacy_owner == 'reta.py')
lines = [
    item.legacy_owner,
    f'capsules={len(item.primary_capsules)} categories={len(item.categories)} functors={len(item.functors)}',
    f'transformations={len(item.natural_transformations)} diagrams={len(item.diagrams)} witnesses={len(item.witnesses)} laws={len(item.laws)}',
    f'route_hops={len(item.route)}',
]
lines += [f'{hop.source} -> {hop.target}\t{hop.relation}\t{hop.categorical_kind}' for hop in item.route]
lines += [item.reading]
write('traces-component.expected', lines)
item = next(x for x in traces.stage_traces if x.stage == 'Stage 32')
write('traces-stage.expected', [
    f'{item.stage}\t{item.capsule}\t{item.trace_target}',
    f'moved_to={len(item.moved_to)} paradigms={len(item.paradigms)}',
])
PY

./target/bin/reta-mojo-coherence --summary > "$TMP_DIR/coherence-summary.actual"
./target/bin/reta-mojo-coherence --capsule InputPromptCapsule > "$TMP_DIR/coherence-capsule.actual"
./target/bin/reta-mojo-coherence --route SchemaTopologyCapsule LocalSectionCapsule > "$TMP_DIR/coherence-route.actual"
./target/bin/reta-mojo-coherence --transformation RawToCanonicalParameterTransformation > "$TMP_DIR/coherence-transformation.actual"
./target/bin/reta-mojo-coherence --law RawCanonicalNaturalityLaw > "$TMP_DIR/coherence-law.actual"
./target/bin/reta-mojo-traces --summary > "$TMP_DIR/traces-summary.actual"
./target/bin/reta-mojo-traces --component reta.py > "$TMP_DIR/traces-component.actual"
./target/bin/reta-mojo-traces --stage 'Stage 32' > "$TMP_DIR/traces-stage.actual"

count=0
for name in coherence-summary coherence-capsule coherence-route coherence-transformation coherence-law traces-summary traces-component traces-stage; do
    cmp "$TMP_DIR/$name.expected" "$TMP_DIR/$name.actual"
    count=$((count + 1))
done
printf 'architecture coherence/trace parity: %s/8 byte-identical\n' "$count"
