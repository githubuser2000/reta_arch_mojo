#!/usr/bin/env python3
"""Generate the native Mojo Stage-32 architecture trace bundle."""
from __future__ import annotations

import argparse
import json
import pathlib
import sys
from typing import Any, Iterable


def q(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def strings(values: Iterable[str]) -> str:
    return "[" + ", ".join(q(str(value)) for value in values) + "]"


def emit_struct(out: list[str], name: str, fields: list[tuple[str, str]]) -> None:
    out.append('@fieldwise_init\n')
    out.append(f'struct {name}(Copyable):\n')
    for field, typ in fields:
        out.append(f'    var {field}: {typ}\n')
    out.append('\n')


def generate(snapshot: dict[str, Any]) -> str:
    out: list[str] = []
    a = out.append
    a('"""Generated native Mojo representation of architecture_traces.\n')
    a('The Python reference is evaluated only during explicit regeneration; runtime\n')
    a('trace navigation and snapshot validation are fully native.\n')
    a('Regenerate with tools/generate_architecture_traces.py.\n"""\n\n')
    a('from std.collections import List\n\n')

    emit_struct(out, 'TraceHopSpec', [
        ('source', 'String'), ('target', 'String'), ('relation', 'String'),
        ('categorical_kind', 'String'), ('evidence', 'List[String]'),
    ])
    emit_struct(out, 'RetaComponentTraceSpec', [
        ('legacy_owner', 'String'), ('primary_capsules', 'List[String]'),
        ('categories', 'List[String]'), ('functors', 'List[String]'),
        ('natural_transformations', 'List[String]'), ('diagrams', 'List[String]'),
        ('witnesses', 'List[String]'), ('laws', 'List[String]'),
        ('route', 'List[TraceHopSpec]'), ('reading', 'String'),
    ])
    emit_struct(out, 'CapsuleTraceSpec', [
        ('capsule', 'String'), ('category', 'String'), ('functors', 'List[String]'),
        ('natural_transformations', 'List[String]'), ('diagrams', 'List[String]'),
        ('laws', 'List[String]'), ('witnesses', 'List[String]'),
        ('code_owners', 'List[String]'), ('reading', 'String'),
    ])
    emit_struct(out, 'StageHistoryTraceSpec', [
        ('stage', 'String'), ('capsule', 'String'), ('moved_to', 'List[String]'),
        ('paradigms', 'List[String]'), ('trace_target', 'String'),
    ])
    emit_struct(out, 'TraceValidationSpec', [
        ('status', 'String'), ('missing_component_traces', 'List[String]'),
        ('missing_capsule_traces', 'List[String]'), ('missing_stage_traces', 'List[String]'),
        ('missing_stage32_documents', 'List[String]'), ('unresolved_hops', 'List[String]'),
        ('routes_needing_attention', 'List[String]'),
        ('transformations_needing_attention', 'List[String]'),
        ('route_hop_count', 'Int'), ('component_trace_count', 'Int'),
    ])
    emit_struct(out, 'Stage32ArchitecturePlan', [
        ('planned_after_stage_31', 'List[String]'), ('implemented_in_stage_32', 'List[String]'),
        ('inherited_from_previous_stages', 'List[String]'), ('behaviour_change', 'String'),
    ])
    emit_struct(out, 'ArchitectureTraceBundle', [
        ('component_traces', 'List[RetaComponentTraceSpec]'),
        ('capsule_traces', 'List[CapsuleTraceSpec]'),
        ('stage_traces', 'List[StageHistoryTraceSpec]'), ('validation', 'TraceValidationSpec'),
        ('text_diagram', 'String'), ('mermaid_diagram', 'String'), ('plan', 'Stage32ArchitecturePlan'),
    ])

    a('def component_trace_index(bundle: ArchitectureTraceBundle, owner: String) -> Int:\n')
    a('    for index in range(len(bundle.component_traces)):\n')
    a('        if bundle.component_traces[index].legacy_owner == owner:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def capsule_trace_index(bundle: ArchitectureTraceBundle, capsule: String) -> Int:\n')
    a('    for index in range(len(bundle.capsule_traces)):\n')
    a('        if bundle.capsule_traces[index].capsule == capsule:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def stage_trace_index(bundle: ArchitectureTraceBundle, stage: String) -> Int:\n')
    a('    for index in range(len(bundle.stage_traces)):\n')
    a('        if bundle.stage_traces[index].stage == stage:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def trace_route_hop_count(bundle: ArchitectureTraceBundle) -> Int:\n')
    a('    var count = 0\n')
    a('    for index in range(len(bundle.component_traces)):\n')
    a('        count += len(bundle.component_traces[index].route)\n')
    a('    return count\n\n')
    a('def trace_snapshot_validation_passed(bundle: ArchitectureTraceBundle) -> Bool:\n')
    a('    return (\n')
    a('        bundle.validation.status == "passed"\n')
    for field in (
        'missing_component_traces', 'missing_capsule_traces', 'missing_stage_traces',
        'missing_stage32_documents', 'unresolved_hops', 'routes_needing_attention',
        'transformations_needing_attention',
    ):
        a(f'        and len(bundle.validation.{field}) == 0\n')
    a('        and bundle.validation.route_hop_count == trace_route_hop_count(bundle)\n')
    a('        and bundle.validation.component_trace_count == len(bundle.component_traces)\n')
    a('    )\n\n')
    a('def architecture_trace_count_line(bundle: ArchitectureTraceBundle) -> String:\n')
    a('    return (\n')
    a('        "components=" + String(len(bundle.component_traces))\n')
    a('        + " capsules=" + String(len(bundle.capsule_traces))\n')
    a('        + " stages=" + String(len(bundle.stage_traces))\n')
    a('        + " route_hops=" + String(trace_route_hop_count(bundle))\n')
    a('    )\n\n')

    a('def bootstrap_architecture_traces() -> ArchitectureTraceBundle:\n')
    a('    var components = List[RetaComponentTraceSpec]()\n')
    for index, item in enumerate(snapshot['component_traces']):
        a(f'    var route_{index} = List[TraceHopSpec]()\n')
        for hop in item['route']:
            a(f'    route_{index}.append(TraceHopSpec({q(hop["source"])}, {q(hop["target"])}, {q(hop["relation"])}, {q(hop["categorical_kind"])}, {strings(hop["evidence"])}))\n')
        a('    components.append(RetaComponentTraceSpec(\n')
        a(f'        {q(item["legacy_owner"])}, {strings(item["primary_capsules"])}, {strings(item["categories"])},\n')
        a(f'        {strings(item["functors"])}, {strings(item["natural_transformations"])}, {strings(item["diagrams"])},\n')
        a(f'        {strings(item["witnesses"])}, {strings(item["laws"])}, route_{index}^, {q(item["reading"])},\n')
        a('    ))\n')

    a('    var capsules = List[CapsuleTraceSpec]()\n')
    for item in snapshot['capsule_traces']:
        a('    capsules.append(CapsuleTraceSpec(\n')
        a(f'        {q(item["capsule"])}, {q(item["category"])}, {strings(item["functors"])},\n')
        a(f'        {strings(item["natural_transformations"])}, {strings(item["diagrams"])}, {strings(item["laws"])},\n')
        a(f'        {strings(item["witnesses"])}, {strings(item["code_owners"])}, {q(item["reading"])},\n')
        a('    ))\n')

    a('    var stages = List[StageHistoryTraceSpec]()\n')
    for item in snapshot['stage_traces']:
        a('    stages.append(StageHistoryTraceSpec(\n')
        a(f'        {q(item["stage"])}, {q(item["capsule"])}, {strings(item["moved_to"])},\n')
        a(f'        {strings(item["paradigms"])}, {q(item["trace_target"])},\n')
        a('    ))\n')

    validation = snapshot['validation']
    a('    var validation = TraceValidationSpec(\n')
    a(f'        {q(validation["status"])},\n')
    for field in (
        'missing_component_traces', 'missing_capsule_traces', 'missing_stage_traces',
        'missing_stage32_documents', 'unresolved_hops', 'routes_needing_attention',
        'transformations_needing_attention',
    ):
        a(f'        {strings(validation[field])},\n')
    a(f'        {int(validation["route_hop_count"])}, {int(validation["component_trace_count"])},\n')
    a('    )\n')

    plan = snapshot['plan']
    a('    var plan = Stage32ArchitecturePlan(\n')
    a(f'        {strings(plan["planned_after_stage_31"])}, {strings(plan["implemented_in_stage_32"])},\n')
    a(f'        {strings(plan["inherited_from_previous_stages"])}, {q(plan["behaviour_change"])},\n')
    a('    )\n')
    a('    return ArchitectureTraceBundle(\n')
    a(f'        components^, capsules^, stages^, validation^, {q(snapshot["diagrams"]["text"])},\n')
    a(f'        {q(snapshot["diagrams"]["mermaid"])}, plan^,\n')
    a('    )\n')
    return ''.join(out)


def load_snapshot(reference_root: pathlib.Path) -> dict[str, Any]:
    sys.path.insert(0, str(reference_root))
    sys.path.insert(0, str(reference_root / 'libs'))
    from reta_architecture.category_theory import bootstrap_category_theory
    from reta_architecture.architecture_map import bootstrap_architecture_map
    from reta_architecture.architecture_contracts import bootstrap_architecture_contracts
    from reta_architecture.architecture_witnesses import bootstrap_architecture_witnesses
    from reta_architecture.architecture_coherence import bootstrap_architecture_coherence
    from reta_architecture.architecture_traces import bootstrap_architecture_traces

    category = bootstrap_category_theory()
    architecture_map = bootstrap_architecture_map()
    contracts = bootstrap_architecture_contracts(category, architecture_map)
    witnesses = bootstrap_architecture_witnesses(reference_root, category, architecture_map, contracts)
    coherence = bootstrap_architecture_coherence(
        category_theory=category,
        architecture_map=architecture_map,
        architecture_contracts=contracts,
        architecture_witnesses=witnesses,
    )
    bundle = bootstrap_architecture_traces(
        repo_root=reference_root,
        category_theory=category,
        architecture_map=architecture_map,
        architecture_contracts=contracts,
        architecture_witnesses=witnesses,
        architecture_coherence=coherence,
    )
    return bundle.snapshot()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--reference-root', type=pathlib.Path, default=pathlib.Path('python_reference'))
    parser.add_argument('--output', type=pathlib.Path, default=pathlib.Path('src/reta_mojo/architecture_traces.mojo'))
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    generated = generate(load_snapshot(args.reference_root.resolve()))
    if args.check:
        current = args.output.read_text(encoding='utf-8')
        if current != generated:
            raise SystemExit(f'generated architecture traces differ: {args.output}')
        return
    args.output.write_text(generated, encoding='utf-8')


if __name__ == '__main__':
    main()
