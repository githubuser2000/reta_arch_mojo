#!/usr/bin/env python3
"""Generate the native Mojo Stage-34 architecture-migration bundle."""
from __future__ import annotations

import argparse
import json
import pathlib
import sys
from typing import Any, Iterable, Mapping


def q(value: str) -> str:
    return json.dumps(str(value), ensure_ascii=False)


def strings(values: Iterable[str]) -> str:
    return "[" + ", ".join(q(value) for value in values) + "]"


def boolean(value: bool) -> str:
    return "True" if value else "False"


def emit_struct(out: list[str], name: str, fields: list[tuple[str, str]]) -> None:
    out.append("@fieldwise_init\n")
    out.append(f"struct {name}(Copyable):\n")
    for field, typ in fields:
        out.append(f"    var {field}: {typ}\n")
    out.append("\n")


def command_specs(values: Mapping[str, str]) -> str:
    return "[" + ", ".join(f"GateCommandSpec({q(name)}, {q(command)})" for name, command in values.items()) + "]"


def generate(snapshot: dict[str, Any]) -> str:
    out: list[str] = []
    a = out.append
    a('"""Generated native Mojo representation of architecture_migration.\n')
    a('The Python reference is evaluated only during explicit regeneration; runtime\n')
    a('navigation and validation are fully native.\n')
    a('Regenerate with tools/generate_architecture_migration.py.\n"""\n\n')
    a('from std.collections import List\n\n')

    emit_struct(out, 'MigrationWaveSpec', [
        ('wave_id', 'String'), ('order', 'Int'), ('name', 'String'), ('focus', 'String'),
        ('owner_capsules', 'List[String]'), ('candidates', 'List[String]'),
        ('universal_property', 'String'), ('functorial_route', 'List[String]'),
        ('naturality_requirement', 'String'), ('required_gates', 'List[String]'),
        ('status', 'String'),
    ])
    emit_struct(out, 'MigrationStepSpec', [
        ('step_id', 'String'), ('wave_id', 'String'), ('candidate', 'String'),
        ('legacy_owner', 'String'), ('current_capsule', 'String'), ('target_capsule', 'String'),
        ('action_type', 'String'), ('target_owner', 'String'), ('category', 'String'),
        ('functors', 'List[String]'), ('natural_transformations', 'List[String]'),
        ('diagrams', 'List[String]'), ('laws', 'List[String]'), ('gates', 'List[String]'),
        ('prerequisites', 'List[String]'), ('observable_invariant', 'String'), ('status', 'String'),
    ])
    emit_struct(out, 'GateCommandSpec', [('name', 'String'), ('command', 'String')])
    emit_struct(out, 'MigrationGateBindingSpec', [
        ('step_id', 'String'), ('candidate', 'String'), ('gates', 'List[String]'),
        ('gate_commands', 'List[GateCommandSpec]'), ('command_parity_required', 'Bool'),
        ('bound_diagrams', 'List[String]'), ('missing_gates', 'List[String]'),
        ('status', 'String'), ('reading', 'String'),
    ])
    emit_struct(out, 'MigrationInvariantSpec', [
        ('name', 'String'), ('wave_id', 'String'), ('applies_to', 'List[String]'),
        ('diagrams', 'List[String]'), ('laws', 'List[String]'),
        ('natural_transformations', 'List[String]'), ('required_gates', 'List[String]'),
        ('proof_obligation', 'String'), ('status', 'String'),
    ])
    emit_struct(out, 'MigrationCheckSpec', [
        ('name', 'String'), ('status', 'String'), ('failed_items', 'List[String]'),
        ('checked_count', 'Int'), ('reading', 'String'),
    ])
    emit_struct(out, 'MigrationValidationSpec', [
        ('status', 'String'), ('missing_candidates', 'List[String]'),
        ('steps_without_gate_binding', 'List[String]'), ('unknown_gates', 'List[String]'),
        ('unknown_diagrams', 'List[String]'), ('unknown_natural_transformations', 'List[String]'),
        ('unordered_waves', 'List[String]'), ('empty_waves', 'List[String]'),
        ('checks', 'List[MigrationCheckSpec]'),
    ])
    emit_struct(out, 'Stage34ArchitecturePlan', [
        ('planned_after_stage_33', 'List[String]'), ('implemented_in_stage_34', 'List[String]'),
        ('inherited_from_previous_stages', 'List[String]'), ('behaviour_change', 'String'),
    ])
    emit_struct(out, 'ArchitectureMigrationBundle', [
        ('waves', 'List[MigrationWaveSpec]'), ('steps', 'List[MigrationStepSpec]'),
        ('gate_bindings', 'List[MigrationGateBindingSpec]'),
        ('invariants', 'List[MigrationInvariantSpec]'), ('validation', 'MigrationValidationSpec'),
        ('text_diagram', 'String'), ('mermaid_diagram', 'String'), ('plan', 'Stage34ArchitecturePlan'),
    ])

    a('def migration_wave_index(bundle: ArchitectureMigrationBundle, wave_id: String) -> Int:\n')
    a('    for index in range(len(bundle.waves)):\n')
    a('        if bundle.waves[index].wave_id == wave_id:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def migration_step_index(bundle: ArchitectureMigrationBundle, step_id: String) -> Int:\n')
    a('    for index in range(len(bundle.steps)):\n')
    a('        if bundle.steps[index].step_id == step_id:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def migration_gate_binding_index(bundle: ArchitectureMigrationBundle, step_id: String) -> Int:\n')
    a('    for index in range(len(bundle.gate_bindings)):\n')
    a('        if bundle.gate_bindings[index].step_id == step_id:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def migration_invariant_index(bundle: ArchitectureMigrationBundle, wave_id: String) -> Int:\n')
    a('    for index in range(len(bundle.invariants)):\n')
    a('        if bundle.invariants[index].wave_id == wave_id:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def migration_owner_step_count(bundle: ArchitectureMigrationBundle, owner: String) -> Int:\n')
    a('    var count = 0\n')
    a('    for index in range(len(bundle.steps)):\n')
    a('        if bundle.steps[index].legacy_owner == owner:\n')
    a('            count += 1\n')
    a('    return count\n\n')
    a('def migration_first_owner_step_index(bundle: ArchitectureMigrationBundle, owner: String) -> Int:\n')
    a('    for index in range(len(bundle.steps)):\n')
    a('        if bundle.steps[index].legacy_owner == owner:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def migration_snapshot_validation_passed(bundle: ArchitectureMigrationBundle) -> Bool:\n')
    a('    return (\n')
    a('        bundle.validation.status == "passed"\n')
    for field in ('missing_candidates', 'steps_without_gate_binding', 'unknown_gates', 'unknown_diagrams', 'unknown_natural_transformations', 'unordered_waves', 'empty_waves'):
        a(f'        and len(bundle.validation.{field}) == 0\n')
    a('    )\n\n')
    a('def architecture_migration_count_line(bundle: ArchitectureMigrationBundle) -> String:\n')
    a('    return (\n')
    a('        "waves=" + String(len(bundle.waves))\n')
    a('        + " steps=" + String(len(bundle.steps))\n')
    a('        + " gate_bindings=" + String(len(bundle.gate_bindings))\n')
    a('        + " invariants=" + String(len(bundle.invariants))\n')
    a('    )\n\n')

    a('def bootstrap_architecture_migration() -> ArchitectureMigrationBundle:\n')
    a('    var waves = List[MigrationWaveSpec]()\n')
    for item in snapshot['waves']:
        a('    waves.append(MigrationWaveSpec(\n')
        a(f'        {q(item["wave_id"])}, {int(item["order"])}, {q(item["name"])}, {q(item["focus"])},\n')
        a(f'        {strings(item["owner_capsules"])}, {strings(item["candidates"])},\n')
        a(f'        {q(item["universal_property"])}, {strings(item["functorial_route"])},\n')
        a(f'        {q(item["naturality_requirement"])}, {strings(item["required_gates"])}, {q(item["status"])},\n')
        a('    ))\n')

    a('    var steps = List[MigrationStepSpec]()\n')
    for item in snapshot['steps']:
        a('    steps.append(MigrationStepSpec(\n')
        a(f'        {q(item["step_id"])}, {q(item["wave_id"])}, {q(item["candidate"])}, {q(item["legacy_owner"])},\n')
        a(f'        {q(item["current_capsule"])}, {q(item["target_capsule"])}, {q(item["action_type"])},\n')
        a(f'        {q(item["target_owner"])}, {q(item["category"])}, {strings(item["functors"])},\n')
        a(f'        {strings(item["natural_transformations"])}, {strings(item["diagrams"])},\n')
        a(f'        {strings(item["laws"])}, {strings(item["gates"])}, {strings(item["prerequisites"])},\n')
        a(f'        {q(item["observable_invariant"])}, {q(item["status"])},\n')
        a('    ))\n')

    a('    var bindings = List[MigrationGateBindingSpec]()\n')
    for item in snapshot['gate_bindings']:
        a('    bindings.append(MigrationGateBindingSpec(\n')
        a(f'        {q(item["step_id"])}, {q(item["candidate"])}, {strings(item["gates"])},\n')
        a(f'        {command_specs(item["gate_commands"])}, {boolean(bool(item["command_parity_required"]))},\n')
        a(f'        {strings(item["bound_diagrams"])}, {strings(item["missing_gates"])},\n')
        a(f'        {q(item["status"])}, {q(item["reading"])},\n')
        a('    ))\n')

    a('    var invariants = List[MigrationInvariantSpec]()\n')
    for item in snapshot['invariants']:
        a('    invariants.append(MigrationInvariantSpec(\n')
        a(f'        {q(item["name"])}, {q(item["wave_id"])}, {strings(item["applies_to"])},\n')
        a(f'        {strings(item["diagrams"])}, {strings(item["laws"])},\n')
        a(f'        {strings(item["natural_transformations"])}, {strings(item["required_gates"])},\n')
        a(f'        {q(item["proof_obligation"])}, {q(item["status"])},\n')
        a('    ))\n')

    a('    var checks = List[MigrationCheckSpec]()\n')
    for item in snapshot['validation']['checks']:
        a('    checks.append(MigrationCheckSpec(\n')
        a(f'        {q(item["name"])}, {q(item["status"])}, {strings(item["failed_items"])},\n')
        a(f'        {int(item["checked_count"])}, {q(item["reading"])},\n')
        a('    ))\n')
    validation = snapshot['validation']
    a('    var validation = MigrationValidationSpec(\n')
    a(f'        {q(validation["status"])}, {strings(validation["missing_candidates"])},\n')
    a(f'        {strings(validation["steps_without_gate_binding"])}, {strings(validation["unknown_gates"])},\n')
    a(f'        {strings(validation["unknown_diagrams"])}, {strings(validation["unknown_natural_transformations"])},\n')
    a(f'        {strings(validation["unordered_waves"])}, {strings(validation["empty_waves"])}, checks^,\n')
    a('    )\n')
    plan = snapshot['plan']
    a('    var plan = Stage34ArchitecturePlan(\n')
    a(f'        {strings(plan["planned_after_stage_33"])}, {strings(plan["implemented_in_stage_34"])},\n')
    a(f'        {strings(plan["inherited_from_previous_stages"])}, {q(plan["behaviour_change"])},\n')
    a('    )\n')
    a('    return ArchitectureMigrationBundle(\n')
    a('        waves^, steps^, bindings^, invariants^, validation^,\n')
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
    from reta_architecture.architecture_migration import bootstrap_architecture_migration

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
    impact = bootstrap_architecture_impact(
        repo_root=reference_root,
        category_theory=category,
        architecture_map=architecture_map,
        architecture_contracts=contracts,
        architecture_witnesses=witnesses,
        architecture_coherence=coherence,
        architecture_traces=traces,
        architecture_boundaries=boundaries,
    )
    bundle = bootstrap_architecture_migration(
        category_theory=category,
        architecture_map=architecture_map,
        architecture_contracts=contracts,
        architecture_impact=impact,
    )
    return bundle.snapshot()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--reference-root', type=pathlib.Path, default=pathlib.Path('python_reference'))
    parser.add_argument('--output', type=pathlib.Path, default=pathlib.Path('src/reta_mojo/architecture_migration.mojo'))
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    generated = generate(load_snapshot(args.reference_root.resolve()))
    if args.check:
        current = args.output.read_text(encoding='utf-8')
        if current != generated:
            raise SystemExit(f'generated architecture migration differs: {args.output}')
        return
    args.output.write_text(generated, encoding='utf-8')


if __name__ == '__main__':
    main()
