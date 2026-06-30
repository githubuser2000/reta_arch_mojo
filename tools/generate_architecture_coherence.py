#!/usr/bin/env python3
"""Generate the native Mojo Stage-31 architecture-coherence bundle."""
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


def boolean(value: bool) -> str:
    return "True" if value else "False"


def emit_struct(out: list[str], name: str, fields: list[tuple[str, str]]) -> None:
    out.append("@fieldwise_init\n")
    out.append(f"struct {name}(Copyable):\n")
    for field, typ in fields:
        out.append(f"    var {field}: {typ}\n")
    out.append("\n")


def generate(snapshot: dict[str, Any]) -> str:
    out: list[str] = []
    a = out.append
    a('"""Generated native Mojo representation of architecture_coherence.\n')
    a('The Python reference is evaluated only during explicit regeneration; runtime\n')
    a('navigation and snapshot validation are fully native.\n')
    a('Regenerate with tools/generate_architecture_coherence.py.\n"""\n\n')
    a('from std.collections import List\n\n')

    emit_struct(out, 'CapsuleCoherenceSpec', [
        ('capsule', 'String'), ('category', 'String'), ('functors', 'List[String]'),
        ('natural_transformations', 'List[String]'), ('diagrams', 'List[String]'),
        ('laws', 'List[String]'), ('witness_slice', 'String'),
        ('code_owners', 'List[String]'), ('stage_span', 'String'),
        ('coherence_reading', 'String'),
    ])
    emit_struct(out, 'FunctorialRouteSpec', [
        ('source_capsule', 'String'), ('target_capsule', 'String'), ('morphism', 'String'),
        ('functor_or_transformation', 'String'), ('categorical_kind', 'String'),
        ('contract_diagrams', 'List[String]'), ('witness_diagrams', 'List[String]'),
        ('code_owner', 'String'), ('status', 'String'), ('reading', 'String'),
    ])
    emit_struct(out, 'NaturalityCoherenceSpec', [
        ('transformation', 'String'), ('source_functor', 'String'), ('target_functor', 'String'),
        ('component_count', 'Int'), ('diagrams', 'List[String]'), ('capsules', 'List[String]'),
        ('witness_status', 'String'), ('status', 'String'), ('naturality_condition', 'String'),
    ])
    emit_struct(out, 'LawCoherenceSpec', [
        ('law', 'String'), ('protected_capsules', 'List[String]'), ('diagrams', 'List[String]'),
        ('obligation_present', 'Bool'), ('status', 'String'), ('reading', 'String'),
    ])
    emit_struct(out, 'CoherenceValidationSpec', [
        ('status', 'String'), ('missing_capsule_contracts', 'List[String]'),
        ('missing_capsule_witnesses', 'List[String]'), ('unresolved_categories', 'List[String]'),
        ('unresolved_functors', 'List[String]'), ('unresolved_natural_transformations', 'List[String]'),
        ('routes_without_known_functor_or_transformation', 'List[String]'),
        ('routes_without_contract', 'List[String]'), ('routes_without_witness', 'List[String]'),
        ('transformations_without_witness', 'List[String]'), ('laws_without_obligation', 'List[String]'),
    ])
    emit_struct(out, 'Stage31CoherencePlan', [
        ('planned_after_stage_30', 'List[String]'), ('implemented_in_stage_31', 'List[String]'),
        ('inherited_from_previous_stages', 'List[String]'), ('behaviour_change', 'String'),
    ])
    emit_struct(out, 'ArchitectureCoherenceBundle', [
        ('capsule_coherence', 'List[CapsuleCoherenceSpec]'),
        ('functorial_routes', 'List[FunctorialRouteSpec]'),
        ('naturality_coherence', 'List[NaturalityCoherenceSpec]'),
        ('law_coherence', 'List[LawCoherenceSpec]'), ('validation', 'CoherenceValidationSpec'),
        ('text_diagram', 'String'), ('mermaid_diagram', 'String'), ('plan', 'Stage31CoherencePlan'),
    ])

    a('def coherent_capsule_index(bundle: ArchitectureCoherenceBundle, name: String) -> Int:\n')
    a('    for index in range(len(bundle.capsule_coherence)):\n')
    a('        if bundle.capsule_coherence[index].capsule == name:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def functorial_route_index(bundle: ArchitectureCoherenceBundle, source: String, target: String, name: String = "") -> Int:\n')
    a('    for index in range(len(bundle.functorial_routes)):\n')
    a('        var route = bundle.functorial_routes[index].copy()\n')
    a('        if route.source_capsule == source and route.target_capsule == target:\n')
    a('            if name.byte_length() == 0 or route.functor_or_transformation == name:\n')
    a('                return index\n')
    a('    return -1\n\n')
    a('def naturality_coherence_index(bundle: ArchitectureCoherenceBundle, name: String) -> Int:\n')
    a('    for index in range(len(bundle.naturality_coherence)):\n')
    a('        if bundle.naturality_coherence[index].transformation == name:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def law_coherence_index(bundle: ArchitectureCoherenceBundle, name: String) -> Int:\n')
    a('    for index in range(len(bundle.law_coherence)):\n')
    a('        if bundle.law_coherence[index].law == name:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def coherence_snapshot_validation_passed(bundle: ArchitectureCoherenceBundle) -> Bool:\n')
    a('    return (\n')
    a('        bundle.validation.status == "passed"\n')
    for field in (
        'missing_capsule_contracts', 'missing_capsule_witnesses', 'unresolved_categories',
        'unresolved_functors', 'unresolved_natural_transformations',
        'routes_without_known_functor_or_transformation', 'routes_without_contract',
        'routes_without_witness', 'transformations_without_witness', 'laws_without_obligation',
    ):
        a(f'        and len(bundle.validation.{field}) == 0\n')
    a('    )\n\n')
    a('def architecture_coherence_count_line(bundle: ArchitectureCoherenceBundle) -> String:\n')
    a('    return (\n')
    a('        "capsules=" + String(len(bundle.capsule_coherence))\n')
    a('        + " routes=" + String(len(bundle.functorial_routes))\n')
    a('        + " naturality=" + String(len(bundle.naturality_coherence))\n')
    a('        + " laws=" + String(len(bundle.law_coherence))\n')
    a('    )\n\n')

    a('def bootstrap_architecture_coherence() -> ArchitectureCoherenceBundle:\n')
    a('    var capsules = List[CapsuleCoherenceSpec]()\n')
    for item in snapshot['capsule_coherence']:
        a('    capsules.append(CapsuleCoherenceSpec(\n')
        a(f'        {q(item["capsule"])}, {q(item["category"])}, {strings(item["functors"])},\n')
        a(f'        {strings(item["natural_transformations"])}, {strings(item["diagrams"])},\n')
        a(f'        {strings(item["laws"])}, {q(item["witness_slice"])}, {strings(item["code_owners"])},\n')
        a(f'        {q(item["stage_span"])}, {q(item["coherence_reading"])},\n')
        a('    ))\n')

    a('    var routes = List[FunctorialRouteSpec]()\n')
    for item in snapshot['functorial_routes']:
        a('    routes.append(FunctorialRouteSpec(\n')
        a(f'        {q(item["source_capsule"])}, {q(item["target_capsule"])}, {q(item["morphism"])},\n')
        a(f'        {q(item["functor_or_transformation"])}, {q(item["categorical_kind"])},\n')
        a(f'        {strings(item["contract_diagrams"])}, {strings(item["witness_diagrams"])},\n')
        a(f'        {q(item["code_owner"])}, {q(item["status"])}, {q(item["reading"])},\n')
        a('    ))\n')

    a('    var naturality = List[NaturalityCoherenceSpec]()\n')
    for item in snapshot['naturality_coherence']:
        a('    naturality.append(NaturalityCoherenceSpec(\n')
        a(f'        {q(item["transformation"])}, {q(item["source_functor"])}, {q(item["target_functor"])},\n')
        a(f'        {int(item["component_count"])}, {strings(item["diagrams"])}, {strings(item["capsules"])},\n')
        a(f'        {q(item["witness_status"])}, {q(item["status"])}, {q(item["naturality_condition"])},\n')
        a('    ))\n')

    a('    var laws = List[LawCoherenceSpec]()\n')
    for item in snapshot['law_coherence']:
        a('    laws.append(LawCoherenceSpec(\n')
        a(f'        {q(item["law"])}, {strings(item["protected_capsules"])}, {strings(item["diagrams"])},\n')
        a(f'        {boolean(bool(item["obligation_present"]))}, {q(item["status"])}, {q(item["reading"])},\n')
        a('    ))\n')

    validation = snapshot['validation']
    a('    var validation = CoherenceValidationSpec(\n')
    a(f'        {q(validation["status"])},\n')
    for field in (
        'missing_capsule_contracts', 'missing_capsule_witnesses', 'unresolved_categories',
        'unresolved_functors', 'unresolved_natural_transformations',
        'routes_without_known_functor_or_transformation', 'routes_without_contract',
        'routes_without_witness', 'transformations_without_witness', 'laws_without_obligation',
    ):
        a(f'        {strings(validation[field])},\n')
    a('    )\n')

    plan = snapshot['plan']
    a('    var plan = Stage31CoherencePlan(\n')
    a(f'        {strings(plan["planned_after_stage_30"])}, {strings(plan["implemented_in_stage_31"])},\n')
    a(f'        {strings(plan["inherited_from_previous_stages"])}, {q(plan["behaviour_change"])},\n')
    a('    )\n')
    a('    return ArchitectureCoherenceBundle(\n')
    a(f'        capsules^, routes^, naturality^, laws^, validation^, {q(snapshot["diagrams"]["text"])},\n')
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

    category = bootstrap_category_theory()
    architecture_map = bootstrap_architecture_map()
    contracts = bootstrap_architecture_contracts(category, architecture_map)
    witnesses = bootstrap_architecture_witnesses(reference_root, category, architecture_map, contracts)
    bundle = bootstrap_architecture_coherence(
        category_theory=category,
        architecture_map=architecture_map,
        architecture_contracts=contracts,
        architecture_witnesses=witnesses,
    )
    return bundle.snapshot()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--reference-root', type=pathlib.Path, default=pathlib.Path('python_reference'))
    parser.add_argument('--output', type=pathlib.Path, default=pathlib.Path('src/reta_mojo/architecture_coherence.mojo'))
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    generated = generate(load_snapshot(args.reference_root.resolve()))
    if args.check:
        current = args.output.read_text(encoding='utf-8')
        if current != generated:
            raise SystemExit(f'generated architecture coherence differs: {args.output}')
        return
    args.output.write_text(generated, encoding='utf-8')


if __name__ == '__main__':
    main()
