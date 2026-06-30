#!/usr/bin/env python3
"""Generate the native Mojo Stage-33 architecture-impact bundle."""
from __future__ import annotations

import argparse
import json
import pathlib
import sys
from typing import Any, Iterable


def q(value: str) -> str:
    return json.dumps(str(value), ensure_ascii=False)


def strings(values: Iterable[str]) -> str:
    return "[" + ", ".join(q(value) for value in values) + "]"


def emit_struct(out: list[str], name: str, fields: list[tuple[str, str]]) -> None:
    out.append("@fieldwise_init\n")
    out.append(f"struct {name}(Copyable):\n")
    for field, typ in fields:
        out.append(f"    var {field}: {typ}\n")
    out.append("\n")


def generate(snapshot: dict[str, Any]) -> str:
    out: list[str] = []
    a = out.append
    a('"""Generated native Mojo representation of architecture_impact.\n')
    a('The Python reference is evaluated only during explicit regeneration; runtime\n')
    a('navigation and validation are fully native.\n')
    a('Regenerate with tools/generate_architecture_impact.py.\n"""\n\n')
    a('from std.collections import List\n\n')

    emit_struct(out, 'ImpactSourceSpec', [
        ('source', 'String'), ('source_kind', 'String'), ('capsules', 'List[String]'),
        ('categories', 'List[String]'), ('functors', 'List[String]'),
        ('natural_transformations', 'List[String]'), ('diagrams', 'List[String]'),
        ('laws', 'List[String]'), ('boundary_edges', 'List[String]'),
        ('route_hops', 'List[String]'), ('reading', 'String'),
    ])
    emit_struct(out, 'ImpactContractSpec', [
        ('source', 'String'), ('affected_capsules', 'List[String]'),
        ('affected_diagrams', 'List[String]'), ('affected_laws', 'List[String]'),
        ('affected_natural_transformations', 'List[String]'),
        ('required_gates', 'List[String]'), ('required_probes', 'List[String]'),
        ('impact_reading', 'String'),
    ])
    emit_struct(out, 'RegressionGateSpec', [
        ('name', 'String'), ('gate_type', 'String'), ('protects', 'List[String]'),
        ('command', 'String'), ('required_for', 'List[String]'),
        ('stage_origin', 'String'), ('status', 'String'), ('reading', 'String'),
    ])
    emit_struct(out, 'MigrationCandidateSpec', [
        ('candidate', 'String'), ('legacy_owner', 'String'), ('current_capsule', 'String'),
        ('target_capsule', 'String'), ('move_kind', 'String'),
        ('mathematical_reading', 'String'), ('affected_diagrams', 'List[String]'),
        ('gates', 'List[String]'), ('next_action', 'String'), ('status', 'String'),
    ])
    emit_struct(out, 'ImpactCheckSpec', [
        ('name', 'String'), ('status', 'String'), ('failed_items', 'List[String]'),
        ('checked_count', 'Int'), ('reading', 'String'),
    ])
    emit_struct(out, 'ImpactValidationSpec', [
        ('status', 'String'), ('missing_sources', 'List[String]'),
        ('sources_without_contracts', 'List[String]'), ('candidates_without_gates', 'List[String]'),
        ('unknown_capsules', 'List[String]'),
        ('uncovered_natural_transformations', 'List[String]'),
        ('checks', 'List[ImpactCheckSpec]'),
    ])
    emit_struct(out, 'Stage33ArchitecturePlan', [
        ('planned_after_stage_32', 'List[String]'), ('implemented_in_stage_33', 'List[String]'),
        ('inherited_from_previous_stages', 'List[String]'), ('behaviour_change', 'String'),
    ])
    emit_struct(out, 'ArchitectureImpactBundle', [
        ('impact_sources', 'List[ImpactSourceSpec]'),
        ('impact_contracts', 'List[ImpactContractSpec]'),
        ('regression_gates', 'List[RegressionGateSpec]'),
        ('migration_candidates', 'List[MigrationCandidateSpec]'),
        ('validation', 'ImpactValidationSpec'), ('text_diagram', 'String'),
        ('mermaid_diagram', 'String'), ('plan', 'Stage33ArchitecturePlan'),
    ])

    a('def impact_source_index(bundle: ArchitectureImpactBundle, source: String) -> Int:\n')
    a('    for index in range(len(bundle.impact_sources)):\n')
    a('        if bundle.impact_sources[index].source == source:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def impact_contract_index(bundle: ArchitectureImpactBundle, source: String) -> Int:\n')
    a('    for index in range(len(bundle.impact_contracts)):\n')
    a('        if bundle.impact_contracts[index].source == source:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def regression_gate_index(bundle: ArchitectureImpactBundle, name: String) -> Int:\n')
    a('    for index in range(len(bundle.regression_gates)):\n')
    a('        if bundle.regression_gates[index].name == name:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def migration_candidate_index(bundle: ArchitectureImpactBundle, name: String) -> Int:\n')
    a('    for index in range(len(bundle.migration_candidates)):\n')
    a('        if bundle.migration_candidates[index].candidate == name:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def impact_snapshot_validation_passed(bundle: ArchitectureImpactBundle) -> Bool:\n')
    a('    return (\n')
    a('        bundle.validation.status == "passed"\n')
    for field in ('missing_sources', 'sources_without_contracts', 'candidates_without_gates', 'unknown_capsules', 'uncovered_natural_transformations'):
        a(f'        and len(bundle.validation.{field}) == 0\n')
    a('    )\n\n')
    a('def architecture_impact_count_line(bundle: ArchitectureImpactBundle) -> String:\n')
    a('    return (\n')
    a('        "sources=" + String(len(bundle.impact_sources))\n')
    a('        + " contracts=" + String(len(bundle.impact_contracts))\n')
    a('        + " gates=" + String(len(bundle.regression_gates))\n')
    a('        + " candidates=" + String(len(bundle.migration_candidates))\n')
    a('    )\n\n')

    a('def bootstrap_architecture_impact() -> ArchitectureImpactBundle:\n')
    a('    var sources = List[ImpactSourceSpec]()\n')
    for item in snapshot['impact_sources']:
        a('    sources.append(ImpactSourceSpec(\n')
        a(f'        {q(item["source"])}, {q(item["source_kind"])}, {strings(item["capsules"])},\n')
        a(f'        {strings(item["categories"])}, {strings(item["functors"])},\n')
        a(f'        {strings(item["natural_transformations"])}, {strings(item["diagrams"])},\n')
        a(f'        {strings(item["laws"])}, {strings(item["boundary_edges"])},\n')
        a(f'        {strings(item["route_hops"])}, {q(item["reading"])},\n')
        a('    ))\n')

    a('    var contracts = List[ImpactContractSpec]()\n')
    for item in snapshot['impact_contracts']:
        a('    contracts.append(ImpactContractSpec(\n')
        a(f'        {q(item["source"])}, {strings(item["affected_capsules"])},\n')
        a(f'        {strings(item["affected_diagrams"])}, {strings(item["affected_laws"])},\n')
        a(f'        {strings(item["affected_natural_transformations"])},\n')
        a(f'        {strings(item["required_gates"])}, {strings(item["required_probes"])},\n')
        a(f'        {q(item["impact_reading"])},\n')
        a('    ))\n')

    a('    var gates = List[RegressionGateSpec]()\n')
    for item in snapshot['regression_gates']:
        a('    gates.append(RegressionGateSpec(\n')
        a(f'        {q(item["name"])}, {q(item["gate_type"])}, {strings(item["protects"])},\n')
        a(f'        {q(item["command"])}, {strings(item["required_for"])},\n')
        a(f'        {q(item["stage_origin"])}, {q(item["status"])}, {q(item["reading"])},\n')
        a('    ))\n')

    a('    var candidates = List[MigrationCandidateSpec]()\n')
    for item in snapshot['migration_candidates']:
        a('    candidates.append(MigrationCandidateSpec(\n')
        a(f'        {q(item["candidate"])}, {q(item["legacy_owner"])},\n')
        a(f'        {q(item["current_capsule"])}, {q(item["target_capsule"])},\n')
        a(f'        {q(item["move_kind"])}, {q(item["mathematical_reading"])},\n')
        a(f'        {strings(item["affected_diagrams"])}, {strings(item["gates"])},\n')
        a(f'        {q(item["next_action"])}, {q(item["status"])},\n')
        a('    ))\n')

    a('    var checks = List[ImpactCheckSpec]()\n')
    for item in snapshot['validation']['checks']:
        a('    checks.append(ImpactCheckSpec(\n')
        a(f'        {q(item["name"])}, {q(item["status"])}, {strings(item["failed_items"])},\n')
        a(f'        {int(item["checked_count"])}, {q(item["reading"])},\n')
        a('    ))\n')
    validation = snapshot['validation']
    a('    var validation = ImpactValidationSpec(\n')
    a(f'        {q(validation["status"])}, {strings(validation["missing_sources"])},\n')
    a(f'        {strings(validation["sources_without_contracts"])}, {strings(validation["candidates_without_gates"])},\n')
    a(f'        {strings(validation["unknown_capsules"])}, {strings(validation["uncovered_natural_transformations"])},\n')
    a('        checks^,\n')
    a('    )\n')
    plan = snapshot['plan']
    a('    var plan = Stage33ArchitecturePlan(\n')
    a(f'        {strings(plan["planned_after_stage_32"])}, {strings(plan["implemented_in_stage_33"])},\n')
    a(f'        {strings(plan["inherited_from_previous_stages"])}, {q(plan["behaviour_change"])},\n')
    a('    )\n')
    a('    return ArchitectureImpactBundle(\n')
    a('        sources^, contracts^, gates^, candidates^, validation^,\n')
    a(f'        {q(snapshot["diagrams"]["text"])}, {q(snapshot["diagrams"]["mermaid"])}, plan^,\n')
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
    from reta_architecture.architecture_boundaries import bootstrap_architecture_boundaries
    from reta_architecture.architecture_impact import bootstrap_architecture_impact

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
    traces = bootstrap_architecture_traces(
        repo_root=reference_root,
        category_theory=category,
        architecture_map=architecture_map,
        architecture_contracts=contracts,
        architecture_witnesses=witnesses,
        architecture_coherence=coherence,
    )
    boundaries = bootstrap_architecture_boundaries(
        repo_root=reference_root,
        architecture_map=architecture_map,
        architecture_coherence=coherence,
    )
    bundle = bootstrap_architecture_impact(
        repo_root=reference_root,
        category_theory=category,
        architecture_map=architecture_map,
        architecture_contracts=contracts,
        architecture_witnesses=witnesses,
        architecture_coherence=coherence,
        architecture_traces=traces,
        architecture_boundaries=boundaries,
    )
    return bundle.snapshot()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--reference-root', type=pathlib.Path, default=pathlib.Path('python_reference'))
    parser.add_argument('--output', type=pathlib.Path, default=pathlib.Path('src/reta_mojo/architecture_impact.mojo'))
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    generated = generate(load_snapshot(args.reference_root.resolve()))
    if args.check:
        current = args.output.read_text(encoding='utf-8')
        if current != generated:
            raise SystemExit(f'generated architecture impact differs: {args.output}')
        return
    args.output.write_text(generated, encoding='utf-8')


if __name__ == '__main__':
    main()
