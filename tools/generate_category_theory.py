#!/usr/bin/env python3
"""Generate typed Mojo category metadata from the Python reference snapshot."""
from __future__ import annotations

import argparse
import json
import pathlib
import sys
from typing import Any


def q(value: str) -> str:
    return json.dumps(str(value), ensure_ascii=False)


def list_strings(values: list[str]) -> str:
    if not values:
        return "List[String]()"
    return "[" + ", ".join(q(v) for v in values) + "]"


def generate(snapshot: dict[str, Any]) -> str:
    out: list[str] = []
    a = out.append
    a('"""Generated native Mojo representation of reta_architecture.category_theory.\n')
    a('Do not edit the generated bootstrap section manually; regenerate it with\n')
    a('tools/generate_category_theory.py from the Python reference snapshot.\n"""\n\n')
    a('from std.collections import List\n\n')
    structs = [
        ("CategoryObjectSpec", [("name", "String"), ("code_owner", "String"), ("role", "String")]),
        ("CategoryMorphismSpec", [("name", "String"), ("source", "String"), ("target", "String"), ("code_owner", "String"), ("role", "String")]),
        ("NameMapping", [("source", "String"), ("target", "String")]),
        ("CategorySpec", [("name", "String"), ("description", "String"), ("objects", "List[CategoryObjectSpec]"), ("morphisms", "List[CategoryMorphismSpec]"), ("implemented_by", "List[String]")]),
        ("FunctorSpec", [("name", "String"), ("source_category", "String"), ("target_category", "String"), ("variance", "String"), ("object_map", "List[NameMapping]"), ("morphism_map", "List[NameMapping]"), ("code_owner", "String"), ("description", "String")]),
        ("NaturalTransformationSpec", [("name", "String"), ("source_functor", "String"), ("target_functor", "String"), ("components", "List[NameMapping]"), ("naturality_condition", "String"), ("code_owner", "String"), ("description", "String")]),
        ("ParadigmTermSpec", [("term", "String"), ("meaning", "String"), ("implemented_by", "List[String]"), ("stage_status", "String")]),
        ("Stage27ArchitecturePlan", [("planned_before_stage_27", "List[String]"), ("implemented_in_stage_27", "List[String]"), ("already_implemented_before_stage_27", "List[String]"), ("behaviour_change", "String")]),
        ("CategoryTheoryBundle", [("categories", "List[CategorySpec]"), ("functors", "List[FunctorSpec]"), ("natural_transformations", "List[NaturalTransformationSpec]"), ("paradigm_terms", "List[ParadigmTermSpec]"), ("plan", "Stage27ArchitecturePlan")]),
    ]
    for name, fields in structs:
        a('@fieldwise_init\n')
        a(f'struct {name}(Copyable):\n')
        for field, typ in fields:
            a(f'    var {field}: {typ}\n')
        a('\n')
    a('def _mapping(source: String, target: String) -> NameMapping:\n')
    a('    return NameMapping(source, target)\n\n')
    a('def category_index(bundle: CategoryTheoryBundle, name: String) -> Int:\n')
    a('    for index in range(len(bundle.categories)):\n')
    a('        if bundle.categories[index].name == name:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def functor_index(bundle: CategoryTheoryBundle, name: String) -> Int:\n')
    a('    for index in range(len(bundle.functors)):\n')
    a('        if bundle.functors[index].name == name:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def natural_transformation_index(bundle: CategoryTheoryBundle, name: String) -> Int:\n')
    a('    for index in range(len(bundle.natural_transformations)):\n')
    a('        if bundle.natural_transformations[index].name == name:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def bootstrap_category_theory() -> CategoryTheoryBundle:\n')
    a('    var categories = List[CategorySpec]()\n')
    for i, cat in enumerate(snapshot['categories']):
        a(f'    var objects_{i} = List[CategoryObjectSpec]()\n')
        for obj in cat['objects']:
            a(f'    objects_{i}.append(CategoryObjectSpec({q(obj["name"])}, {q(obj["code_owner"])}, {q(obj["role"])}))\n')
        a(f'    var morphisms_{i} = List[CategoryMorphismSpec]()\n')
        for mor in cat['morphisms']:
            a(f'    morphisms_{i}.append(CategoryMorphismSpec({q(mor["name"])}, {q(mor["source"])}, {q(mor["target"])}, {q(mor["code_owner"])}, {q(mor["role"])}))\n')
        a(f'    categories.append(CategorySpec({q(cat["name"])}, {q(cat["description"])}, objects_{i}^, morphisms_{i}^, {list_strings(cat["implemented_by"])}))\n')
    a('    var functors = List[FunctorSpec]()\n')
    for i, fun in enumerate(snapshot['functors']):
        a(f'    var object_map_{i} = List[NameMapping]()\n')
        for source, target in fun['object_map'].items():
            a(f'    object_map_{i}.append(_mapping({q(source)}, {q(target)}))\n')
        a(f'    var morphism_map_{i} = List[NameMapping]()\n')
        for source, target in fun['morphism_map'].items():
            a(f'    morphism_map_{i}.append(_mapping({q(source)}, {q(target)}))\n')
        a(f'    functors.append(FunctorSpec({q(fun["name"])}, {q(fun["source_category"])}, {q(fun["target_category"])}, {q(fun["variance"])}, object_map_{i}^, morphism_map_{i}^, {q(fun["code_owner"])}, {q(fun["description"])}))\n')
    a('    var transformations = List[NaturalTransformationSpec]()\n')
    for i, nt in enumerate(snapshot['natural_transformations']):
        a(f'    var components_{i} = List[NameMapping]()\n')
        for source, target in nt['components'].items():
            a(f'    components_{i}.append(_mapping({q(source)}, {q(target)}))\n')
        a(f'    transformations.append(NaturalTransformationSpec({q(nt["name"])}, {q(nt["source_functor"])}, {q(nt["target_functor"])}, components_{i}^, {q(nt["naturality_condition"])}, {q(nt["code_owner"])}, {q(nt["description"])}))\n')
    a('    var terms = List[ParadigmTermSpec]()\n')
    for term in snapshot['paradigm_terms']:
        a(f'    terms.append(ParadigmTermSpec({q(term["term"])}, {q(term["meaning"])}, {list_strings(term["implemented_by"])}, {q(term["stage_status"])}))\n')
    plan = snapshot['plan']
    a('    var plan = Stage27ArchitecturePlan(\n')
    a(f'        {list_strings(plan["planned_before_stage_27"])},\n')
    a(f'        {list_strings(plan["implemented_in_stage_27"])},\n')
    a(f'        {list_strings(plan["already_implemented_before_stage_27"])},\n')
    a(f'        {q(plan["behaviour_change"])},\n')
    a('    )\n')
    a('    return CategoryTheoryBundle(categories^, functors^, transformations^, terms^, plan^)\n')
    return ''.join(out)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--reference-root', type=pathlib.Path, required=True)
    parser.add_argument('--output', type=pathlib.Path, required=True)
    args = parser.parse_args()
    sys.path.insert(0, str(args.reference_root))
    from reta_architecture.category_theory import bootstrap_category_theory
    snapshot = bootstrap_category_theory().snapshot()
    args.output.write_text(generate(snapshot), encoding='utf-8')


if __name__ == '__main__':
    main()
