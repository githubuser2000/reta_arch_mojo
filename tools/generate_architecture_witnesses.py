#!/usr/bin/env python3
"""Generate native Mojo architecture witnesses from the Python reference truth."""

from __future__ import annotations

import argparse
import json
import pathlib
import sys
from typing import Any, Iterable, Mapping


def q(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def list_strings(values: Iterable[str]) -> str:
    return "[" + ", ".join(q(value) for value in values) + "]"


def mappings(values: Mapping[str, str]) -> str:
    return "[" + ", ".join(
        f"WitnessMappingSpec({q(key)}, {q(value)})" for key, value in values.items()
    ) + "]"


def generate(snapshot: dict[str, Any]) -> str:
    out: list[str] = []
    a = out.append
    a('"""Generated native Mojo representation of architecture_witnesses.\n')
    a('Repository path resolution happens only during explicit regeneration; runtime\n')
    a('witness navigation and coverage inspection are fully native.\n')
    a('Regenerate with tools/generate_architecture_witnesses.py.\n"""\n\n')
    a('from std.collections import List\n\n')

    structs: list[tuple[str, list[tuple[str, str]]]] = [
        ('WitnessMappingSpec', [('key', 'String'), ('value', 'String')]),
        ('AnchorWitnessSpec', [
            ('anchor', 'String'), ('owner', 'String'), ('resolution_kind', 'String'),
            ('matched_paths', 'List[String]'), ('status', 'String'), ('note', 'String'),
        ]),
        ('CapsuleSliceSpec', [
            ('capsule', 'String'), ('layer', 'String'), ('old_reta_parts', 'List[String]'),
            ('new_owners', 'List[String]'), ('contained_sections', 'List[String]'),
            ('math_roles', 'List[String]'), ('protected_by', 'List[String]'),
            ('witness_anchors', 'List[String]'), ('anchor_status', 'String'),
            ('stage_span', 'String'), ('description', 'String'),
        ]),
        ('DiagramWitnessSpec', [
            ('diagram', 'String'), ('diagram_type', 'String'), ('capsules', 'List[String]'),
            ('natural_transformations', 'List[String]'),
            ('implementation_anchors', 'List[String]'),
            ('verification_evidence', 'List[String]'), ('probe_commands', 'List[String]'),
            ('proof_obligation', 'String'), ('witness_status', 'String'),
        ]),
        ('NaturalTransformationWitnessSpec', [
            ('transformation', 'String'), ('source_functor', 'String'),
            ('target_functor', 'String'), ('diagrams', 'List[String]'),
            ('capsules', 'List[String]'), ('component_anchors', 'List[WitnessMappingSpec]'),
            ('code_owner', 'String'), ('witness_status', 'String'),
            ('naturality_condition', 'String'),
        ]),
        ('RefactorObligationSpec', [
            ('name', 'String'), ('obligation_type', 'String'),
            ('applies_to', 'List[String]'), ('witness_diagrams', 'List[String]'),
            ('evidence', 'List[String]'), ('keep_true_when', 'String'), ('status', 'String'),
        ]),
        ('WitnessValidationSpec', [
            ('status', 'String'), ('file_like_anchor_count', 'Int'),
            ('resolved_anchor_count', 'Int'), ('symbolic_anchor_count', 'Int'),
            ('missing_file_like_anchors', 'List[String]'),
            ('uncovered_capsules', 'List[String]'), ('uncovered_diagrams', 'List[String]'),
            ('uncovered_laws', 'List[String]'),
            ('uncovered_natural_transformations', 'List[String]'),
        ]),
        ('Stage30ArchitecturePlan', [
            ('planned_after_stage_29', 'List[String]'),
            ('implemented_in_stage_30', 'List[String]'),
            ('inherited_from_previous_stages', 'List[String]'),
            ('behaviour_change', 'String'),
        ]),
        ('ArchitectureWitnessBundle', [
            ('anchor_witnesses', 'List[AnchorWitnessSpec]'),
            ('capsule_slices', 'List[CapsuleSliceSpec]'),
            ('diagram_witnesses', 'List[DiagramWitnessSpec]'),
            ('naturality_witnesses', 'List[NaturalTransformationWitnessSpec]'),
            ('obligations', 'List[RefactorObligationSpec]'),
            ('validation', 'WitnessValidationSpec'),
            ('text_diagram', 'String'), ('mermaid_diagram', 'String'),
            ('plan', 'Stage30ArchitecturePlan'),
        ]),
    ]
    for name, fields in structs:
        a('@fieldwise_init\n')
        a(f'struct {name}(Copyable):\n')
        for field, typ in fields:
            a(f'    var {field}: {typ}\n')
        a('\n')

    a('def anchor_witness_index(bundle: ArchitectureWitnessBundle, owner: String, anchor: String) -> Int:\n')
    a('    for index in range(len(bundle.anchor_witnesses)):\n')
    a('        if bundle.anchor_witnesses[index].owner == owner and bundle.anchor_witnesses[index].anchor == anchor:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def capsule_slice_index(bundle: ArchitectureWitnessBundle, capsule: String) -> Int:\n')
    a('    for index in range(len(bundle.capsule_slices)):\n')
    a('        if bundle.capsule_slices[index].capsule == capsule:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def diagram_witness_index(bundle: ArchitectureWitnessBundle, diagram: String) -> Int:\n')
    a('    for index in range(len(bundle.diagram_witnesses)):\n')
    a('        if bundle.diagram_witnesses[index].diagram == diagram:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def naturality_witness_index(bundle: ArchitectureWitnessBundle, transformation: String) -> Int:\n')
    a('    for index in range(len(bundle.naturality_witnesses)):\n')
    a('        if bundle.naturality_witnesses[index].transformation == transformation:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def refactor_obligation_index(bundle: ArchitectureWitnessBundle, name: String) -> Int:\n')
    a('    for index in range(len(bundle.obligations)):\n')
    a('        if bundle.obligations[index].name == name:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def witness_validation_passed(bundle: ArchitectureWitnessBundle) -> Bool:\n')
    a('    return (\n')
    a('        bundle.validation.status == "passed"\n')
    a('        and bundle.validation.file_like_anchor_count == bundle.validation.resolved_anchor_count\n')
    a('        and len(bundle.validation.missing_file_like_anchors) == 0\n')
    a('        and len(bundle.validation.uncovered_capsules) == 0\n')
    a('        and len(bundle.validation.uncovered_diagrams) == 0\n')
    a('        and len(bundle.validation.uncovered_laws) == 0\n')
    a('        and len(bundle.validation.uncovered_natural_transformations) == 0\n')
    a('    )\n\n')
    a('def architecture_witnesses_count_line(bundle: ArchitectureWitnessBundle) -> String:\n')
    a('    return (\n')
    a('        "anchor_witnesses=" + String(len(bundle.anchor_witnesses))\n')
    a('        + " capsule_slices=" + String(len(bundle.capsule_slices))\n')
    a('        + " diagram_witnesses=" + String(len(bundle.diagram_witnesses))\n')
    a('        + " naturality_witnesses=" + String(len(bundle.naturality_witnesses))\n')
    a('        + " obligations=" + String(len(bundle.obligations))\n')
    a('        + " resolved_anchors=" + String(bundle.validation.resolved_anchor_count)\n')
    a('    )\n\n')

    a('def bootstrap_architecture_witnesses() -> ArchitectureWitnessBundle:\n')
    a('    var anchor_witnesses = List[AnchorWitnessSpec]()\n')
    for item in snapshot['anchor_witnesses']:
        a('    anchor_witnesses.append(AnchorWitnessSpec(\n')
        a(f'        {q(item["anchor"])}, {q(item["owner"])}, {q(item["resolution_kind"])},\n')
        a(f'        {list_strings(item["matched_paths"])}, {q(item["status"])}, {q(item["note"])},\n')
        a('    ))\n')

    a('    var capsule_slices = List[CapsuleSliceSpec]()\n')
    for item in snapshot['capsule_slices']:
        a('    capsule_slices.append(CapsuleSliceSpec(\n')
        a(f'        {q(item["capsule"])}, {q(item["layer"])},\n')
        a(f'        {list_strings(item["old_reta_parts"])}, {list_strings(item["new_owners"])},\n')
        a(f'        {list_strings(item["contained_sections"])}, {list_strings(item["math_roles"])},\n')
        a(f'        {list_strings(item["protected_by"])}, {list_strings(item["witness_anchors"])},\n')
        a(f'        {q(item["anchor_status"])}, {q(item["stage_span"])}, {q(item["description"])},\n')
        a('    ))\n')

    a('    var diagram_witnesses = List[DiagramWitnessSpec]()\n')
    for item in snapshot['diagram_witnesses']:
        a('    diagram_witnesses.append(DiagramWitnessSpec(\n')
        a(f'        {q(item["diagram"])}, {q(item["diagram_type"])},\n')
        a(f'        {list_strings(item["capsules"])}, {list_strings(item["natural_transformations"])},\n')
        a(f'        {list_strings(item["implementation_anchors"])},\n')
        a(f'        {list_strings(item["verification_evidence"])}, {list_strings(item["probe_commands"])},\n')
        a(f'        {q(item["proof_obligation"])}, {q(item["witness_status"])},\n')
        a('    ))\n')

    a('    var naturality_witnesses = List[NaturalTransformationWitnessSpec]()\n')
    for item in snapshot['naturality_witnesses']:
        a('    naturality_witnesses.append(NaturalTransformationWitnessSpec(\n')
        a(f'        {q(item["transformation"])}, {q(item["source_functor"])}, {q(item["target_functor"])},\n')
        a(f'        {list_strings(item["diagrams"])}, {list_strings(item["capsules"])},\n')
        a(f'        {mappings(item["component_anchors"])}, {q(item["code_owner"])},\n')
        a(f'        {q(item["witness_status"])}, {q(item["naturality_condition"])},\n')
        a('    ))\n')

    a('    var obligations = List[RefactorObligationSpec]()\n')
    for item in snapshot['obligations']:
        a('    obligations.append(RefactorObligationSpec(\n')
        a(f'        {q(item["name"])}, {q(item["obligation_type"])}, {list_strings(item["applies_to"])},\n')
        a(f'        {list_strings(item["witness_diagrams"])}, {list_strings(item["evidence"])},\n')
        a(f'        {q(item["keep_true_when"])}, {q(item["status"])},\n')
        a('    ))\n')

    validation = snapshot['validation']
    a('    var validation = WitnessValidationSpec(\n')
    a(f'        {q(validation["status"])}, {int(validation["file_like_anchor_count"])},\n')
    a(f'        {int(validation["resolved_anchor_count"])}, {int(validation["symbolic_anchor_count"])},\n')
    a(f'        {list_strings(validation["missing_file_like_anchors"])},\n')
    a(f'        {list_strings(validation["uncovered_capsules"])}, {list_strings(validation["uncovered_diagrams"])},\n')
    a(f'        {list_strings(validation["uncovered_laws"])}, {list_strings(validation["uncovered_natural_transformations"])},\n')
    a('    )\n')

    plan = snapshot['plan']
    a('    var plan = Stage30ArchitecturePlan(\n')
    a(f'        {list_strings(plan["planned_after_stage_29"])},\n')
    a(f'        {list_strings(plan["implemented_in_stage_30"])},\n')
    a(f'        {list_strings(plan["inherited_from_previous_stages"])},\n')
    a(f'        {q(plan["behaviour_change"])},\n')
    a('    )\n')
    diagrams = snapshot['diagrams']
    a('    return ArchitectureWitnessBundle(\n')
    a('        anchor_witnesses^, capsule_slices^, diagram_witnesses^,\n')
    a('        naturality_witnesses^, obligations^, validation^,\n')
    a(f'        {q(diagrams["text"])}, {q(diagrams["mermaid"])}, plan^,\n')
    a('    )\n')
    return ''.join(out)


def load_snapshot(reference_root: pathlib.Path) -> dict[str, Any]:
    sys.path.insert(0, str(reference_root))
    sys.path.insert(0, str(reference_root / 'libs'))
    from reta_architecture.architecture_contracts import bootstrap_architecture_contracts
    from reta_architecture.architecture_map import bootstrap_architecture_map
    from reta_architecture.architecture_witnesses import bootstrap_architecture_witnesses
    from reta_architecture.category_theory import bootstrap_category_theory

    category_theory = bootstrap_category_theory()
    architecture_map = bootstrap_architecture_map()
    contracts = bootstrap_architecture_contracts(category_theory, architecture_map)
    return bootstrap_architecture_witnesses(
        reference_root, category_theory, architecture_map, contracts
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
