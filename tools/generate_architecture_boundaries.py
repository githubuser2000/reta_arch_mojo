#!/usr/bin/env python3
"""Generate typed Mojo architecture-boundary metadata from the Python reference."""
from __future__ import annotations

import argparse
import json
import pathlib
import sys
from typing import Any, Iterable


def q(value: object) -> str:
    return json.dumps(str(value), ensure_ascii=False)


def list_strings(values: Iterable[object]) -> str:
    items = [q(value) for value in values]
    return "List[String]()" if not items else "[" + ", ".join(items) + "]"


def generate(snapshot: dict[str, Any]) -> str:
    out: list[str] = []
    a = out.append
    a('"""Generated native Mojo representation of reta_architecture.architecture_boundaries.\n')
    a('The Python reference scans its source tree at generation time. Runtime lookup,\n')
    a('validation access and capsule navigation are fully native Mojo. Regenerate with\n')
    a('tools/generate_architecture_boundaries.py after changing Python module ownership.\n"""\n\n')
    a('from std.collections import List\n\n')

    structs = [
        ("ModuleOwnershipSpec", [
            ("path", "String"), ("capsule", "String"),
            ("owner_kind", "String"), ("reason", "String"),
        ]),
        ("ImportEdgeSpec", [
            ("importer", "String"), ("imported", "String"),
            ("importer_capsule", "String"), ("imported_capsule", "String"),
            ("import_kind", "String"), ("categorical_kind", "String"),
            ("allowed", "Bool"), ("reason", "String"),
        ]),
        ("CapsuleImportEdgeSpec", [
            ("source_capsule", "String"), ("target_capsule", "String"),
            ("edge_count", "Int"), ("categorical_kind", "String"),
            ("representative_imports", "List[String]"),
        ]),
        ("CapsuleBoundarySpec", [
            ("capsule", "String"), ("owns_modules", "List[String]"),
            ("allowed_outbound_capsules", "List[String]"),
            ("inbound_capsules", "List[String]"), ("boundary_reading", "String"),
        ]),
        ("BoundaryCheckSpec", [
            ("name", "String"), ("status", "String"),
            ("failed_items", "List[String]"), ("checked_count", "Int"),
            ("reading", "String"),
        ]),
        ("BoundaryValidationSpec", [
            ("status", "String"), ("violation_edges", "List[String]"),
            ("unresolved_internal_imports", "List[String]"),
            ("unowned_scanned_paths", "List[String]"),
            ("missing_capsule_boundaries", "List[String]"),
            ("checks", "List[BoundaryCheckSpec]"),
        ]),
        ("Stage32BoundaryPlan", [
            ("planned_after_stage_31", "List[String]"),
            ("implemented_in_stage_32", "List[String]"),
            ("inherited_from_previous_stages", "List[String]"),
            ("behaviour_change", "String"),
        ]),
        ("ArchitectureBoundariesBundle", [
            ("module_ownership", "List[ModuleOwnershipSpec]"),
            ("import_edges", "List[ImportEdgeSpec]"),
            ("capsule_edges", "List[CapsuleImportEdgeSpec]"),
            ("capsule_boundaries", "List[CapsuleBoundarySpec]"),
            ("validation", "BoundaryValidationSpec"),
            ("text_diagram", "String"), ("mermaid_diagram", "String"),
            ("plan", "Stage32BoundaryPlan"),
        ]),
    ]
    for name, fields in structs:
        a('@fieldwise_init\n')
        a(f'struct {name}(Copyable):\n')
        for field, typ in fields:
            a(f'    var {field}: {typ}\n')
        a('\n')

    a('def ownership_index(bundle: ArchitectureBoundariesBundle, path: String) -> Int:\n')
    a('    for index in range(len(bundle.module_ownership)):\n')
    a('        if bundle.module_ownership[index].path == path:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def capsule_boundary_index(bundle: ArchitectureBoundariesBundle, capsule: String) -> Int:\n')
    a('    for index in range(len(bundle.capsule_boundaries)):\n')
    a('        if bundle.capsule_boundaries[index].capsule == capsule:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def boundary_check_index(bundle: ArchitectureBoundariesBundle, name: String) -> Int:\n')
    a('    for index in range(len(bundle.validation.checks)):\n')
    a('        if bundle.validation.checks[index].name == name:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def boundary_validation_passed(bundle: ArchitectureBoundariesBundle) -> Bool:\n')
    a('    if bundle.validation.status != "passed":\n')
    a('        return False\n')
    a('    for index in range(len(bundle.validation.checks)):\n')
    a('        if bundle.validation.checks[index].status != "passed":\n')
    a('            return False\n')
    a('    return True\n\n')
    a('def architecture_boundaries_count_line(bundle: ArchitectureBoundariesBundle) -> String:\n')
    a('    return (\n')
    a('        "module_ownership=" + String(len(bundle.module_ownership))\n')
    a('        + " import_edges=" + String(len(bundle.import_edges))\n')
    a('        + " capsule_edges=" + String(len(bundle.capsule_edges))\n')
    a('        + " capsule_boundaries=" + String(len(bundle.capsule_boundaries))\n')
    a('        + " checks=" + String(len(bundle.validation.checks))\n')
    a('    )\n\n')

    a('def bootstrap_architecture_boundaries() -> ArchitectureBoundariesBundle:\n')
    a('    var ownership = List[ModuleOwnershipSpec]()\n')
    for item in snapshot['module_ownership']:
        a(f'    ownership.append(ModuleOwnershipSpec({q(item["path"])}, {q(item["capsule"])}, {q(item["owner_kind"])}, {q(item["reason"])}))\n')

    a('    var import_edges = List[ImportEdgeSpec]()\n')
    for item in snapshot['import_edges']:
        allowed = 'True' if item['allowed'] else 'False'
        a('    import_edges.append(ImportEdgeSpec(\n')
        a(f'        {q(item["importer"])}, {q(item["imported"])},\n')
        a(f'        {q(item["importer_capsule"])}, {q(item["imported_capsule"])},\n')
        a(f'        {q(item["import_kind"])}, {q(item["categorical_kind"])}, {allowed},\n')
        a(f'        {q(item["reason"])},\n')
        a('    ))\n')

    a('    var capsule_edges = List[CapsuleImportEdgeSpec]()\n')
    for item in snapshot['capsule_edges']:
        a('    capsule_edges.append(CapsuleImportEdgeSpec(\n')
        a(f'        {q(item["source_capsule"])}, {q(item["target_capsule"])},\n')
        a(f'        {int(item["edge_count"])}, {q(item["categorical_kind"])},\n')
        a(f'        {list_strings(item["representative_imports"])},\n')
        a('    ))\n')

    a('    var capsule_boundaries = List[CapsuleBoundarySpec]()\n')
    for item in snapshot['capsule_boundaries']:
        a('    capsule_boundaries.append(CapsuleBoundarySpec(\n')
        a(f'        {q(item["capsule"])}, {list_strings(item["owns_modules"])},\n')
        a(f'        {list_strings(item["allowed_outbound_capsules"])},\n')
        a(f'        {list_strings(item["inbound_capsules"])},\n')
        a(f'        {q(item["boundary_reading"])},\n')
        a('    ))\n')

    validation = snapshot['validation']
    a('    var checks = List[BoundaryCheckSpec]()\n')
    for item in validation['checks']:
        a('    checks.append(BoundaryCheckSpec(\n')
        a(f'        {q(item["name"])}, {q(item["status"])},\n')
        a(f'        {list_strings(item["failed_items"])}, {int(item["checked_count"])},\n')
        a(f'        {q(item["reading"])},\n')
        a('    ))\n')
    a('    var validation = BoundaryValidationSpec(\n')
    a(f'        {q(validation["status"])},\n')
    a(f'        {list_strings(validation["violation_edges"])},\n')
    a(f'        {list_strings(validation["unresolved_internal_imports"])},\n')
    a(f'        {list_strings(validation["unowned_scanned_paths"])},\n')
    a(f'        {list_strings(validation["missing_capsule_boundaries"])},\n')
    a('        checks^,\n')
    a('    )\n')

    plan = snapshot['plan']
    a('    var plan = Stage32BoundaryPlan(\n')
    a(f'        {list_strings(plan["planned_after_stage_31"])},\n')
    a(f'        {list_strings(plan["implemented_in_stage_32"])},\n')
    a(f'        {list_strings(plan["inherited_from_previous_stages"])},\n')
    a(f'        {q(plan["behaviour_change"])},\n')
    a('    )\n')
    diagrams = snapshot['diagrams']
    a('    return ArchitectureBoundariesBundle(\n')
    a('        ownership^, import_edges^, capsule_edges^, capsule_boundaries^,\n')
    a(f'        validation^, {q(diagrams["text"])}, {q(diagrams["mermaid"])}, plan^,\n')
    a('    )\n')
    return ''.join(out)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--reference-root', type=pathlib.Path, required=True)
    parser.add_argument('--output', type=pathlib.Path, required=True)
    args = parser.parse_args()
    reference_root = args.reference_root.resolve()
    sys.path.insert(0, str(reference_root))
    sys.path.insert(0, str(reference_root / 'libs'))
    from reta_architecture.facade import RetaArchitecture

    snapshot = RetaArchitecture.bootstrap(reference_root).architecture_boundaries.snapshot()
    args.output.write_text(generate(snapshot), encoding='utf-8')


if __name__ == '__main__':
    main()
