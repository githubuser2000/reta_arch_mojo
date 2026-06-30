#!/usr/bin/env python3
"""Generate the native Mojo architecture-contract bundle from the Python truth."""

from __future__ import annotations

import argparse
import json
import pathlib
import sys
from typing import Any, Iterable


def q(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def list_strings(values: Iterable[str]) -> str:
    return "[" + ", ".join(q(value) for value in values) + "]"


def generate(snapshot: dict[str, Any]) -> str:
    out: list[str] = []
    a = out.append
    a('"""Generated native Mojo representation of architecture_contracts.\n')
    a('The Python reference is evaluated only during explicit regeneration; runtime\n')
    a('lookup, contract navigation and cross-bundle validation are fully native.\n')
    a('Regenerate with tools/generate_architecture_contracts.py.\n"""\n\n')
    a('from std.collections import List\n')

    structs: list[tuple[str, list[tuple[str, str]]]] = [
        ('DiagramNodeSpec', [('name', 'String'), ('label', 'String')]),
        ('DiagramArrowSpec', [
            ('source', 'String'), ('target', 'String'), ('label', 'String'),
            ('code_owner', 'String'), ('paradigm_terms', 'List[String]'),
        ]),
        ('CommutativeDiagramSpec', [
            ('name', 'String'), ('diagram_type', 'String'),
            ('nodes', 'List[DiagramNodeSpec]'),
            ('top_path', 'List[DiagramArrowSpec]'), ('bottom_path', 'List[DiagramArrowSpec]'),
            ('equality', 'String'), ('capsules', 'List[String]'),
            ('categories', 'List[String]'), ('functors', 'List[String]'),
            ('natural_transformations', 'List[String]'), ('verification', 'List[String]'),
            ('stage_origin', 'String'), ('description', 'String'),
        ]),
        ('CapsuleContractSpec', [
            ('capsule', 'String'), ('owns', 'List[String]'), ('accepts', 'List[String]'),
            ('produces', 'List[String]'), ('must_not_own', 'List[String]'),
            ('primary_category', 'String'),
            ('primary_functor_or_transformation', 'String'),
            ('protected_by', 'List[String]'), ('implementation_anchors', 'List[String]'),
            ('stage_span', 'String'), ('description', 'String'),
        ]),
        ('RefactorLawSpec', [
            ('name', 'String'), ('law_type', 'String'), ('applies_to', 'List[String]'),
            ('mathematical_reading', 'String'), ('reta_reading', 'String'),
            ('protected_paths', 'List[String]'), ('evidence', 'List[String]'),
            ('status', 'String'),
        ]),
        ('ContractValidationSpec', [
            ('status', 'String'), ('known_capsules', 'List[String]'),
            ('known_categories', 'List[String]'), ('known_functors', 'List[String]'),
            ('known_natural_transformations', 'List[String]'),
            ('missing_capsules', 'List[String]'), ('missing_categories', 'List[String]'),
            ('missing_functors', 'List[String]'),
            ('missing_natural_transformations', 'List[String]'),
        ]),
        ('Stage29ArchitecturePlan', [
            ('planned_after_stage_28', 'List[String]'),
            ('implemented_in_stage_29', 'List[String]'),
            ('inherited_from_previous_stages', 'List[String]'),
            ('behaviour_change', 'String'),
        ]),
        ('ArchitectureContractsBundle', [
            ('diagrams', 'List[CommutativeDiagramSpec]'),
            ('capsule_contracts', 'List[CapsuleContractSpec]'),
            ('laws', 'List[RefactorLawSpec]'),
            ('mermaid_diagram', 'String'), ('text_diagram', 'String'),
            ('validation', 'ContractValidationSpec'), ('plan', 'Stage29ArchitecturePlan'),
        ]),
    ]
    for name, fields in structs:
        a('@fieldwise_init\n')
        a(f'struct {name}(Copyable):\n')
        for field, typ in fields:
            a(f'    var {field}: {typ}\n')
        a('\n')

    a('def contract_diagram_index(bundle: ArchitectureContractsBundle, name: String) -> Int:\n')
    a('    for index in range(len(bundle.diagrams)):\n')
    a('        if bundle.diagrams[index].name == name:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def capsule_contract_index(bundle: ArchitectureContractsBundle, capsule: String) -> Int:\n')
    a('    for index in range(len(bundle.capsule_contracts)):\n')
    a('        if bundle.capsule_contracts[index].capsule == capsule:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def refactor_law_index(bundle: ArchitectureContractsBundle, name: String) -> Int:\n')
    a('    for index in range(len(bundle.laws)):\n')
    a('        if bundle.laws[index].name == name:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def contract_snapshot_validation_passed(bundle: ArchitectureContractsBundle) -> Bool:\n')
    a('    return (\n')
    a('        bundle.validation.status == "passed"\n')
    a('        and len(bundle.validation.missing_capsules) == 0\n')
    a('        and len(bundle.validation.missing_categories) == 0\n')
    a('        and len(bundle.validation.missing_functors) == 0\n')
    a('        and len(bundle.validation.missing_natural_transformations) == 0\n')
    a('    )\n\n')
    a('def architecture_contracts_count_line(bundle: ArchitectureContractsBundle) -> String:\n')
    a('    return (\n')
    a('        "commutative_diagrams=" + String(len(bundle.diagrams))\n')
    a('        + " capsule_contracts=" + String(len(bundle.capsule_contracts))\n')
    a('        + " laws=" + String(len(bundle.laws))\n')
    a('        + " known_categories=" + String(len(bundle.validation.known_categories))\n')
    a('        + " known_functors=" + String(len(bundle.validation.known_functors))\n')
    a('        + " known_transformations=" + String(len(bundle.validation.known_natural_transformations))\n')
    a('    )\n\n')

    a('def bootstrap_architecture_contracts() -> ArchitectureContractsBundle:\n')
    a('    var diagrams = List[CommutativeDiagramSpec]()\n')
    for di, item in enumerate(snapshot['commutative_diagrams']):
        a(f'    var nodes_{di} = List[DiagramNodeSpec]()\n')
        for name, label in item['nodes'].items():
            a(f'    nodes_{di}.append(DiagramNodeSpec({q(name)}, {q(label)}))\n')
        for path_name in ('top_path', 'bottom_path'):
            a(f'    var {path_name}_{di} = List[DiagramArrowSpec]()\n')
            for arrow in item[path_name]:
                a(f'    {path_name}_{di}.append(DiagramArrowSpec(\n')
                a(f'        {q(arrow["source"])}, {q(arrow["target"])}, {q(arrow["label"])},\n')
                a(f'        {q(arrow["code_owner"])}, {list_strings(arrow["paradigm_terms"])},\n')
                a('    ))\n')
        a('    diagrams.append(CommutativeDiagramSpec(\n')
        a(f'        {q(item["name"])}, {q(item["diagram_type"])}, nodes_{di}^,\n')
        a(f'        top_path_{di}^, bottom_path_{di}^, {q(item["equality"])},\n')
        a(f'        {list_strings(item["capsules"])}, {list_strings(item["categories"])},\n')
        a(f'        {list_strings(item["functors"])}, {list_strings(item["natural_transformations"])},\n')
        a(f'        {list_strings(item["verification"])}, {q(item["stage_origin"])},\n')
        a(f'        {q(item["description"])},\n')
        a('    ))\n')

    a('    var capsule_contracts = List[CapsuleContractSpec]()\n')
    for item in snapshot['capsule_contracts']:
        a('    capsule_contracts.append(CapsuleContractSpec(\n')
        a(f'        {q(item["capsule"])}, {list_strings(item["owns"])},\n')
        a(f'        {list_strings(item["accepts"])}, {list_strings(item["produces"])},\n')
        a(f'        {list_strings(item["must_not_own"])}, {q(item["primary_category"])},\n')
        a(f'        {q(item["primary_functor_or_transformation"])},\n')
        a(f'        {list_strings(item["protected_by"])}, {list_strings(item["implementation_anchors"])},\n')
        a(f'        {q(item["stage_span"])}, {q(item["description"])},\n')
        a('    ))\n')

    a('    var laws = List[RefactorLawSpec]()\n')
    for item in snapshot['laws']:
        a('    laws.append(RefactorLawSpec(\n')
        a(f'        {q(item["name"])}, {q(item["law_type"])}, {list_strings(item["applies_to"])},\n')
        a(f'        {q(item["mathematical_reading"])}, {q(item["reta_reading"])},\n')
        a(f'        {list_strings(item["protected_paths"])}, {list_strings(item["evidence"])},\n')
        a(f'        {q(item["status"])},\n')
        a('    ))\n')

    validation = snapshot['validation']
    a('    var validation = ContractValidationSpec(\n')
    for field in (
        'status', 'known_capsules', 'known_categories', 'known_functors',
        'known_natural_transformations', 'missing_capsules', 'missing_categories',
        'missing_functors', 'missing_natural_transformations',
    ):
        value = validation[field]
        rendered = q(value) if isinstance(value, str) else list_strings(value)
        a(f'        {rendered},\n')
    a('    )\n')

    plan = snapshot['plan']
    a('    var plan = Stage29ArchitecturePlan(\n')
    a(f'        {list_strings(plan["planned_after_stage_28"])},\n')
    a(f'        {list_strings(plan["implemented_in_stage_29"])},\n')
    a(f'        {list_strings(plan["inherited_from_previous_stages"])},\n')
    a(f'        {q(plan["behaviour_change"])},\n')
    a('    )\n')
    diagrams = snapshot['diagrams']
    a('    return ArchitectureContractsBundle(\n')
    a(f'        diagrams^, capsule_contracts^, laws^, {q(diagrams["mermaid"])},\n')
    a(f'        {q(diagrams["text"])}, validation^, plan^,\n')
    a('    )\n')
    return ''.join(out)


def load_snapshot(reference_root: pathlib.Path) -> dict[str, Any]:
    sys.path.insert(0, str(reference_root))
    sys.path.insert(0, str(reference_root / 'libs'))
    from reta_architecture.architecture_contracts import bootstrap_architecture_contracts
    from reta_architecture.architecture_map import bootstrap_architecture_map
    from reta_architecture.category_theory import bootstrap_category_theory

    return bootstrap_architecture_contracts(
        bootstrap_category_theory(), bootstrap_architecture_map()
    ).snapshot()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--reference-root', type=pathlib.Path, required=True)
    parser.add_argument('--output', type=pathlib.Path, required=True)
    args = parser.parse_args()
    snapshot = load_snapshot(args.reference_root.resolve())
    generated = generate(snapshot)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(generated, encoding='utf-8')


if __name__ == '__main__':
    main()
