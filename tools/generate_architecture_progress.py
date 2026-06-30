#!/usr/bin/env python3
"""Generate the native Mojo Stage-42 architecture-progress snapshot."""
from __future__ import annotations

import argparse
import json
import pathlib
import sys
from typing import Any, Iterable, Mapping


def q(value: object) -> str:
    return json.dumps(str(value), ensure_ascii=False)


def strings(values: Iterable[object]) -> str:
    return "[" + ", ".join(q(value) for value in values) + "]"


def boolean(value: bool) -> str:
    return 'True' if value else 'False'


def status_counts(values: Mapping[str, object]) -> str:
    return '[' + ', '.join(
        f'ProgressStatusCountSpec({q(name)}, {int(count)})' for name, count in values.items()
    ) + ']'


def emit_struct(out: list[str], name: str, fields: list[tuple[str, str]]) -> None:
    out.append('@fieldwise_init\n')
    out.append(f'struct {name}(Copyable):\n')
    for field, typ in fields:
        out.append(f'    var {field}: {typ}\n')
    out.append('\n')


def generate(snapshot: dict[str, Any]) -> str:
    out: list[str] = []
    a = out.append
    a('"""Generated native Mojo representation of architecture_progress.\n')
    a('The Python AST/repository analysis runs only during explicit regeneration;\n')
    a('runtime navigation and overlay consistency validation are fully native.\n')
    a('Regenerate with tools/generate_architecture_progress.py.\n"""\n\n')
    a('from std.collections import List\n\n')

    emit_struct(out, 'LegacySurfaceProgressSpec', [
        ('owner', 'String'), ('owner_kind', 'String'), ('path', 'String'),
        ('exists', 'Bool'), ('line_count', 'Int'), ('function_count', 'Int'),
        ('wrapper_like_count', 'Int'), ('architecture_imports', 'List[String]'),
        ('execution_status', 'String'), ('evidence', 'List[String]'),
        ('remaining_work', 'List[String]'), ('reading', 'String'),
    ])
    emit_struct(out, 'MigrationExecutionSpec', [
        ('step_id', 'String'), ('wave_id', 'String'), ('candidate', 'String'),
        ('legacy_owner', 'String'), ('target_owner', 'String'),
        ('planned_status', 'String'), ('execution_status', 'String'),
        ('owner_kind', 'String'), ('evidence', 'List[String]'),
        ('remaining_work', 'List[String]'), ('reading', 'String'),
    ])
    emit_struct(out, 'ProgressStatusCountSpec', [('status', 'String'), ('count', 'Int')])
    emit_struct(out, 'WaveExecutionSpec', [
        ('wave_id', 'String'), ('name', 'String'), ('total_steps', 'Int'),
        ('completed_steps', 'Int'), ('mixed_steps', 'Int'), ('outstanding_steps', 'Int'),
        ('step_statuses', 'List[ProgressStatusCountSpec]'),
        ('remaining_owners', 'List[String]'), ('status', 'String'),
    ])
    emit_struct(out, 'OutstandingWorkItemSpec', [
        ('item_id', 'String'), ('priority', 'String'), ('title', 'String'),
        ('owners', 'List[String]'), ('reason', 'String'),
        ('recommended_next_step', 'String'), ('status', 'String'),
    ])
    emit_struct(out, 'ProgressCheckSpec', [
        ('name', 'String'), ('status', 'String'), ('failed_items', 'List[String]'),
        ('checked_count', 'Int'), ('reading', 'String'),
    ])
    emit_struct(out, 'ProgressValidationSpec', [
        ('status', 'String'), ('steps_without_surface', 'List[String]'),
        ('inconsistent_wave_counts', 'List[String]'), ('mixed_owners', 'List[String]'),
        ('outstanding_items', 'List[String]'), ('checks', 'List[ProgressCheckSpec]'),
    ])
    emit_struct(out, 'Stage42ArchitecturePlan', [
        ('planned_after_stage_41', 'List[String]'),
        ('implemented_in_stage_42', 'List[String]'),
        ('inherited_from_previous_stages', 'List[String]'),
        ('behaviour_change', 'String'),
    ])
    emit_struct(out, 'ArchitectureProgressBundle', [
        ('stage', 'Int'), ('purpose', 'String'), ('paradigm', 'List[String]'),
        ('surfaces', 'List[LegacySurfaceProgressSpec]'),
        ('step_progress', 'List[MigrationExecutionSpec]'),
        ('wave_progress', 'List[WaveExecutionSpec]'),
        ('outstanding_work', 'List[OutstandingWorkItemSpec]'),
        ('validation', 'ProgressValidationSpec'),
        ('text_diagram', 'String'), ('mermaid_diagram', 'String'),
        ('plan', 'Stage42ArchitecturePlan'),
    ])

    a('def architecture_progress_surface_index(bundle: ArchitectureProgressBundle, owner: String) -> Int:\n')
    a('    for index in range(len(bundle.surfaces)):\n')
    a('        if bundle.surfaces[index].owner == owner:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def architecture_progress_step_index(bundle: ArchitectureProgressBundle, step_id: String) -> Int:\n')
    a('    for index in range(len(bundle.step_progress)):\n')
    a('        if bundle.step_progress[index].step_id == step_id:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def architecture_progress_wave_index(bundle: ArchitectureProgressBundle, wave_id: String) -> Int:\n')
    a('    for index in range(len(bundle.wave_progress)):\n')
    a('        if bundle.wave_progress[index].wave_id == wave_id:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def architecture_progress_work_index(bundle: ArchitectureProgressBundle, item_id: String) -> Int:\n')
    a('    for index in range(len(bundle.outstanding_work)):\n')
    a('        if bundle.outstanding_work[index].item_id == item_id:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def architecture_progress_snapshot_consistent(bundle: ArchitectureProgressBundle) -> Bool:\n')
    a('    return (\n')
    a('        bundle.stage == 42\n')
    a('        and len(bundle.validation.steps_without_surface) == 0\n')
    a('        and len(bundle.validation.inconsistent_wave_counts) == 0\n')
    a('        and len(bundle.validation.mixed_owners) == 0\n')
    a('        and len(bundle.validation.outstanding_items) == len(bundle.outstanding_work)\n')
    a('        and bundle.validation.status == ("passed" if len(bundle.outstanding_work) == 0 else "attention")\n')
    a('    )\n\n')
    a('def architecture_progress_runtime_consistency_passed(bundle: ArchitectureProgressBundle) -> Bool:\n')
    a('    for surface_index in range(len(bundle.surfaces)):\n')
    a('        var surface = bundle.surfaces[surface_index].copy()\n')
    a('        for other in range(surface_index + 1, len(bundle.surfaces)):\n')
    a('            if bundle.surfaces[other].owner == surface.owner:\n')
    a('                return False\n')
    a('    for step_index in range(len(bundle.step_progress)):\n')
    a('        var step = bundle.step_progress[step_index].copy()\n')
    a('        if architecture_progress_surface_index(bundle, step.legacy_owner) < 0:\n')
    a('            return False\n')
    a('        if architecture_progress_wave_index(bundle, step.wave_id) < 0:\n')
    a('            return False\n')
    a('        for other in range(step_index + 1, len(bundle.step_progress)):\n')
    a('            if bundle.step_progress[other].step_id == step.step_id:\n')
    a('                return False\n')
    a('    for wave_index in range(len(bundle.wave_progress)):\n')
    a('        var wave = bundle.wave_progress[wave_index].copy()\n')
    a('        var actual_steps = 0\n')
    a('        for step in bundle.step_progress:\n')
    a('            if step.wave_id == wave.wave_id:\n')
    a('                actual_steps += 1\n')
    a('        if actual_steps != wave.total_steps:\n')
    a('            return False\n')
    a('        if wave.completed_steps + wave.mixed_steps + wave.outstanding_steps != wave.total_steps:\n')
    a('            return False\n')
    a('        var status_total = 0\n')
    a('        for status_count in wave.step_statuses:\n')
    a('            status_total += status_count.count\n')
    a('        if status_total != wave.total_steps:\n')
    a('            return False\n')
    a('    for item in bundle.outstanding_work:\n')
    a('        var found = False\n')
    a('        for item_id in bundle.validation.outstanding_items:\n')
    a('            if item_id == item.item_id:\n')
    a('                found = True\n')
    a('                break\n')
    a('        if not found:\n')
    a('            return False\n')
    a('    return architecture_progress_snapshot_consistent(bundle)\n\n')
    a('def architecture_progress_count_line(bundle: ArchitectureProgressBundle) -> String:\n')
    a('    return (\n')
    a('        "surfaces=" + String(len(bundle.surfaces))\n')
    a('        + " steps=" + String(len(bundle.step_progress))\n')
    a('        + " waves=" + String(len(bundle.wave_progress))\n')
    a('        + " outstanding=" + String(len(bundle.outstanding_work))\n')
    a('        + " checks=" + String(len(bundle.validation.checks))\n')
    a('    )\n\n')

    a('def bootstrap_architecture_progress() -> ArchitectureProgressBundle:\n')
    a('    var surfaces = List[LegacySurfaceProgressSpec]()\n')
    for item in snapshot['surfaces']:
        a('    surfaces.append(LegacySurfaceProgressSpec(\n')
        a(f'        {q(item["owner"])}, {q(item["owner_kind"])}, {q(item["path"])},\n')
        a(f'        {boolean(bool(item["exists"]))}, {int(item["line_count"])}, {int(item["function_count"])}, {int(item["wrapper_like_count"])},\n')
        a(f'        {strings(item["architecture_imports"])}, {q(item["execution_status"])},\n')
        a(f'        {strings(item["evidence"])}, {strings(item["remaining_work"])}, {q(item["reading"])},\n')
        a('    ))\n')
    a('    var steps = List[MigrationExecutionSpec]()\n')
    for item in snapshot['step_progress']:
        a('    steps.append(MigrationExecutionSpec(\n')
        a(f'        {q(item["step_id"])}, {q(item["wave_id"])}, {q(item["candidate"])},\n')
        a(f'        {q(item["legacy_owner"])}, {q(item["target_owner"])},\n')
        a(f'        {q(item["planned_status"])}, {q(item["execution_status"])}, {q(item["owner_kind"])},\n')
        a(f'        {strings(item["evidence"])}, {strings(item["remaining_work"])}, {q(item["reading"])},\n')
        a('    ))\n')
    a('    var waves = List[WaveExecutionSpec]()\n')
    for item in snapshot['wave_progress']:
        a('    waves.append(WaveExecutionSpec(\n')
        a(f'        {q(item["wave_id"])}, {q(item["name"])}, {int(item["total_steps"])},\n')
        a(f'        {int(item["completed_steps"])}, {int(item["mixed_steps"])}, {int(item["outstanding_steps"])},\n')
        a(f'        {status_counts(item["step_statuses"])}, {strings(item["remaining_owners"])}, {q(item["status"])},\n')
        a('    ))\n')
    a('    var outstanding = List[OutstandingWorkItemSpec]()\n')
    for item in snapshot['outstanding_work']:
        a('    outstanding.append(OutstandingWorkItemSpec(\n')
        a(f'        {q(item["item_id"])}, {q(item["priority"])}, {q(item["title"])},\n')
        a(f'        {strings(item["owners"])}, {q(item["reason"])},\n')
        a(f'        {q(item["recommended_next_step"])}, {q(item["status"])},\n')
        a('    ))\n')
    a('    var checks = List[ProgressCheckSpec]()\n')
    for item in snapshot['validation']['checks']:
        a('    checks.append(ProgressCheckSpec(\n')
        a(f'        {q(item["name"])}, {q(item["status"])}, {strings(item["failed_items"])},\n')
        a(f'        {int(item["checked_count"])}, {q(item["reading"])},\n')
        a('    ))\n')
    validation = snapshot['validation']
    a('    var validation = ProgressValidationSpec(\n')
    a(f'        {q(validation["status"])}, {strings(validation["steps_without_surface"])},\n')
    a(f'        {strings(validation["inconsistent_wave_counts"])}, {strings(validation["mixed_owners"])},\n')
    a(f'        {strings(validation["outstanding_items"])}, checks^,\n')
    a('    )\n')
    plan = snapshot['plan']
    a('    var plan = Stage42ArchitecturePlan(\n')
    a(f'        {strings(plan["planned_after_stage_41"])}, {strings(plan["implemented_in_stage_42"])},\n')
    a(f'        {strings(plan["inherited_from_previous_stages"])}, {q(plan["behaviour_change"])},\n')
    a('    )\n')
    a('    return ArchitectureProgressBundle(\n')
    a(f'        {int(snapshot["stage"])}, {q(snapshot["purpose"])}, {strings(snapshot["paradigm"])},\n')
    a('        surfaces^, steps^, waves^, outstanding^, validation^,\n')
    a(f'        {q(snapshot["diagrams"]["text"])}, {q(snapshot["diagrams"]["mermaid"])}, plan^,\n')
    a('    )\n')
    return ''.join(out)


def load_snapshot(reference_root: pathlib.Path) -> dict[str, Any]:
    sys.path.insert(0, str(reference_root))
    sys.path.insert(0, str(reference_root / 'libs'))
    from reta_architecture import RetaArchitecture
    return RetaArchitecture.bootstrap(reference_root, use_cache=False).architecture_progress.snapshot()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--reference-root', type=pathlib.Path, default=pathlib.Path('python_reference'))
    parser.add_argument('--output', type=pathlib.Path, default=pathlib.Path('src/reta_mojo/architecture_progress.mojo'))
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    generated = generate(load_snapshot(args.reference_root.resolve()))
    if args.check:
        current = args.output.read_text(encoding='utf-8')
        if current != generated:
            raise SystemExit(f'generated architecture progress differs: {args.output}')
        return
    args.output.write_text(generated, encoding='utf-8')


if __name__ == '__main__':
    main()
