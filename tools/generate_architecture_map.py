#!/usr/bin/env python3
"""Generate typed Mojo architecture-map metadata from the Python reference."""
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
    a('"""Generated native Mojo representation of reta_architecture.architecture_map.\n')
    a('Do not edit the generated bootstrap section manually; regenerate it with\n')
    a('tools/generate_architecture_map.py from the Python reference snapshot.\n"""\n\n')
    a('from std.collections import List\n\n')

    structs = [
        ("ArchitectureCapsuleSpec", [
            ("name", "String"), ("layer", "String"), ("contains", "List[String]"),
            ("code_owners", "List[String]"), ("paradigm_roles", "List[String]"),
            ("inbound", "List[String]"), ("outbound", "List[String]"),
            ("stage_span", "String"), ("description", "String"),
        ]),
        ("ArchitectureFlowSpec", [
            ("source", "String"), ("target", "String"), ("morphism", "String"),
            ("functor_or_transformation", "String"), ("code_owner", "String"),
            ("description", "String"),
        ]),
        ("RetaPartMappingSpec", [
            ("legacy_owner", "String"), ("old_responsibility", "String"),
            ("new_capsule", "String"), ("new_owner", "List[String]"),
            ("paradigm_role", "List[String]"), ("stage", "String"),
            ("compatibility_surface", "String"), ("notes", "String"),
        ]),
        ("StageArchitectureStep", [
            ("stage", "String"), ("focus", "String"), ("moved_from", "List[String]"),
            ("moved_to", "List[String]"), ("capsule", "String"),
            ("paradigm_shift", "String"),
        ]),
        ("CapsuleContainmentSpec", [
            ("parent", "String"), ("child", "String"), ("relation", "String"),
        ]),
        ("MarkdownAuditSpec", [
            ("source_package", "String"),
            ("markdown_files_in_stage27_package", "Int"),
            ("uploaded_tar_markdown_files", "Int"),
            ("important_families", "List[String]"),
            ("conclusion", "String"),
        ]),
        ("ArchitectureMapBundle", [
            ("capsules", "List[ArchitectureCapsuleSpec]"),
            ("containment", "List[CapsuleContainmentSpec]"),
            ("flows", "List[ArchitectureFlowSpec]"),
            ("legacy_mappings", "List[RetaPartMappingSpec]"),
            ("stage_steps", "List[StageArchitectureStep]"),
            ("mermaid_diagram", "String"), ("text_diagram", "String"),
            ("markdown_audit", "MarkdownAuditSpec"),
        ]),
    ]
    for name, fields in structs:
        a('@fieldwise_init\n')
        a(f'struct {name}(Copyable):\n')
        for field, typ in fields:
            a(f'    var {field}: {typ}\n')
        a('\n')

    a('def capsule_index(bundle: ArchitectureMapBundle, name: String) -> Int:\n')
    a('    for index in range(len(bundle.capsules)):\n')
    a('        if bundle.capsules[index].name == name:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def capsule_named(bundle: ArchitectureMapBundle, name: String) raises -> ArchitectureCapsuleSpec:\n')
    a('    var index = capsule_index(bundle, name)\n')
    a('    if index < 0:\n')
    a('        raise Error("Unknown architecture capsule: " + name)\n')
    a('    return bundle.capsules[index].copy()\n\n')
    a('def architecture_map_count_line(bundle: ArchitectureMapBundle) -> String:\n')
    a('    return (\n')
    a('        "capsules=" + String(len(bundle.capsules))\n')
    a('        + " containment=" + String(len(bundle.containment))\n')
    a('        + " flows=" + String(len(bundle.flows))\n')
    a('        + " legacy_mappings=" + String(len(bundle.legacy_mappings))\n')
    a('        + " stage_steps=" + String(len(bundle.stage_steps))\n')
    a('    )\n\n')

    a('def bootstrap_architecture_map() -> ArchitectureMapBundle:\n')
    a('    var capsules = List[ArchitectureCapsuleSpec]()\n')
    for item in snapshot['capsules']:
        a('    capsules.append(ArchitectureCapsuleSpec(\n')
        a(f'        {q(item["name"])}, {q(item["layer"])},\n')
        a(f'        {list_strings(item["contains"])},\n')
        a(f'        {list_strings(item["code_owners"])},\n')
        a(f'        {list_strings(item["paradigm_roles"])},\n')
        a(f'        {list_strings(item["inbound"])},\n')
        a(f'        {list_strings(item["outbound"])},\n')
        a(f'        {q(item["stage_span"])}, {q(item["description"])},\n')
        a('    ))\n')

    a('    var containment = List[CapsuleContainmentSpec]()\n')
    for item in snapshot['containment']:
        a(f'    containment.append(CapsuleContainmentSpec({q(item["parent"])}, {q(item["child"])}, {q(item["relation"])}))\n')

    a('    var flows = List[ArchitectureFlowSpec]()\n')
    for item in snapshot['flows']:
        a('    flows.append(ArchitectureFlowSpec(\n')
        a(f'        {q(item["source"])}, {q(item["target"])}, {q(item["morphism"])},\n')
        a(f'        {q(item["functor_or_transformation"])}, {q(item["code_owner"])},\n')
        a(f'        {q(item["description"])},\n')
        a('    ))\n')

    a('    var mappings = List[RetaPartMappingSpec]()\n')
    for item in snapshot['legacy_mappings']:
        a('    mappings.append(RetaPartMappingSpec(\n')
        a(f'        {q(item["legacy_owner"])}, {q(item["old_responsibility"])},\n')
        a(f'        {q(item["new_capsule"])}, {list_strings(item["new_owner"])},\n')
        a(f'        {list_strings(item["paradigm_role"])}, {q(item["stage"])},\n')
        a(f'        {q(item["compatibility_surface"])}, {q(item["notes"])},\n')
        a('    ))\n')

    a('    var steps = List[StageArchitectureStep]()\n')
    for item in snapshot['stage_steps']:
        a('    steps.append(StageArchitectureStep(\n')
        a(f'        {q(item["stage"])}, {q(item["focus"])},\n')
        a(f'        {list_strings(item["moved_from"])}, {list_strings(item["moved_to"])},\n')
        a(f'        {q(item["capsule"])}, {q(item["paradigm_shift"])},\n')
        a('    ))\n')

    audit = snapshot['markdown_audit']
    a('    var audit = MarkdownAuditSpec(\n')
    a(f'        {q(audit["source_package"])},\n')
    a(f'        {int(audit["markdown_files_in_stage27_package"])},\n')
    a(f'        {int(audit["uploaded_tar_markdown_files"])},\n')
    a(f'        {list_strings(audit["important_families"])},\n')
    a(f'        {q(audit["conclusion"])},\n')
    a('    )\n')
    diagrams = snapshot['diagrams']
    a('    return ArchitectureMapBundle(\n')
    a('        capsules^, containment^, flows^, mappings^, steps^,\n')
    a(f'        {q(diagrams["mermaid"])}, {q(diagrams["text"])}, audit^,\n')
    a('    )\n')
    return ''.join(out)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--reference-root', type=pathlib.Path, required=True)
    parser.add_argument('--output', type=pathlib.Path, required=True)
    args = parser.parse_args()
    sys.path.insert(0, str(args.reference_root))
    sys.path.insert(0, str(args.reference_root / 'libs'))
    from reta_architecture.architecture_map import bootstrap_architecture_map

    snapshot = bootstrap_architecture_map().snapshot()
    args.output.write_text(generate(snapshot), encoding='utf-8')


if __name__ == '__main__':
    main()
