#!/usr/bin/env python3
"""Generate the native Mojo Stage-35 architecture-rehearsal bundle."""
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


def command_specs(values: Mapping[str, str]) -> str:
    return "[" + ", ".join(
        f"RehearsalCommandSpec({q(name)}, {q(command)})"
        for name, command in values.items()
    ) + "]"


def emit_struct(out: list[str], name: str, fields: list[tuple[str, str]]) -> None:
    out.append("@fieldwise_init\n")
    out.append(f"struct {name}(Copyable):\n")
    for field, typ in fields:
        out.append(f"    var {field}: {typ}\n")
    out.append("\n")


def generate(snapshot: dict[str, Any]) -> str:
    out: list[str] = []
    a = out.append
    a('"""Generated native Mojo representation of architecture_rehearsal.\n')
    a('The Python reference is evaluated only during explicit regeneration; runtime\n')
    a('navigation and snapshot validation are fully native.\n')
    a('Regenerate with tools/generate_architecture_rehearsal.py.\n"""\n\n')
    a('from std.collections import List\n\n')

    emit_struct(out, "RehearsalCommandSpec", [("name", "String"), ("command", "String")])
    emit_struct(out, "RehearsalOpenSetSpec", [
        ("open_set_id", "String"), ("wave_id", "String"), ("order", "Int"),
        ("name", "String"), ("owner_capsules", "List[String]"),
        ("candidates", "List[String]"), ("basis", "List[String]"),
        ("topology_role", "String"), ("status", "String"),
    ])
    emit_struct(out, "RehearsalMoveSpec", [
        ("move_id", "String"), ("step_id", "String"), ("wave_id", "String"),
        ("legacy_owner", "String"), ("target_owner", "String"),
        ("current_capsule", "String"), ("target_capsule", "String"),
        ("action_type", "String"), ("category", "String"),
        ("functors", "List[String]"), ("natural_transformations", "List[String]"),
        ("diagrams", "List[String]"), ("laws", "List[String]"),
        ("gates", "List[String]"), ("preconditions", "List[String]"),
        ("postconditions", "List[String]"), ("rollback_anchor", "String"),
        ("status", "String"),
    ])
    emit_struct(out, "GateRehearsalSpec", [
        ("gate_suite_id", "String"), ("step_id", "String"),
        ("candidate", "String"), ("gates", "List[String]"),
        ("preflight_commands", "List[RehearsalCommandSpec]"),
        ("postflight_commands", "List[RehearsalCommandSpec]"),
        ("rollback_anchor", "String"), ("command_parity_required", "Bool"),
        ("bound_diagrams", "List[String]"), ("status", "String"),
    ])
    emit_struct(out, "RehearsalCoverSpec", [
        ("cover_id", "String"), ("open_set_id", "String"), ("wave_id", "String"),
        ("moves", "List[String]"), ("gate_suites", "List[String]"),
        ("gluing_operation", "String"), ("universal_property", "String"),
        ("status", "String"),
    ])
    emit_struct(out, "RehearsalCheckSpec", [
        ("name", "String"), ("status", "String"),
        ("failed_items", "List[String]"), ("checked_count", "Int"),
        ("reading", "String"),
    ])
    emit_struct(out, "RehearsalValidationSpec", [
        ("status", "String"), ("missing_migration_steps", "List[String]"),
        ("rehearsals_without_gate_suite", "List[String]"),
        ("open_sets_without_cover", "List[String]"),
        ("unknown_diagrams", "List[String]"), ("unknown_laws", "List[String]"),
        ("unknown_natural_transformations", "List[String]"),
        ("gate_suites_with_missing_commands", "List[String]"),
        ("checks", "List[RehearsalCheckSpec]"),
    ])
    emit_struct(out, "Stage35ArchitecturePlan", [
        ("planned_after_stage_34", "List[String]"),
        ("implemented_in_stage_35", "List[String]"),
        ("inherited_from_previous_stages", "List[String]"),
        ("behaviour_change", "String"),
    ])
    emit_struct(out, "ArchitectureRehearsalBundle", [
        ("open_sets", "List[RehearsalOpenSetSpec]"),
        ("moves", "List[RehearsalMoveSpec]"),
        ("gate_rehearsals", "List[GateRehearsalSpec]"),
        ("covers", "List[RehearsalCoverSpec]"),
        ("validation", "RehearsalValidationSpec"),
        ("text_diagram", "String"), ("mermaid_diagram", "String"),
        ("plan", "Stage35ArchitecturePlan"),
    ])

    for fn, collection, field in (
        ("rehearsal_open_set_index", "open_sets", "open_set_id"),
        ("rehearsal_move_index", "moves", "move_id"),
        ("rehearsal_step_index", "moves", "step_id"),
        ("rehearsal_gate_index", "gate_rehearsals", "gate_suite_id"),
        ("rehearsal_cover_index", "covers", "cover_id"),
    ):
        a(f"def {fn}(bundle: ArchitectureRehearsalBundle, value: String) -> Int:\n")
        a(f"    for index in range(len(bundle.{collection})):\n")
        a(f"        if bundle.{collection}[index].{field} == value:\n")
        a("            return index\n")
        a("    return -1\n\n")

    a("def rehearsal_wave_move_count(bundle: ArchitectureRehearsalBundle, wave_id: String) -> Int:\n")
    a("    var count = 0\n")
    a("    for index in range(len(bundle.moves)):\n")
    a("        if bundle.moves[index].wave_id == wave_id:\n")
    a("            count += 1\n")
    a("    return count\n\n")

    a("def rehearsal_snapshot_validation_passed(bundle: ArchitectureRehearsalBundle) -> Bool:\n")
    a("    return (\n")
    a('        bundle.validation.status == "passed"\n')
    for field in (
        "missing_migration_steps", "rehearsals_without_gate_suite",
        "open_sets_without_cover", "unknown_diagrams", "unknown_laws",
        "unknown_natural_transformations", "gate_suites_with_missing_commands",
    ):
        a(f"        and len(bundle.validation.{field}) == 0\n")
    a("    )\n\n")

    a("def rehearsal_runtime_validation_passed(bundle: ArchitectureRehearsalBundle) -> Bool:\n")
    a("    if len(bundle.moves) != len(bundle.gate_rehearsals):\n")
    a("        return False\n")
    a("    if len(bundle.open_sets) != len(bundle.covers):\n")
    a("        return False\n")
    a("    for move_index in range(len(bundle.moves)):\n")
    a("        var found_gate = False\n")
    a("        for gate_index in range(len(bundle.gate_rehearsals)):\n")
    a("            if bundle.gate_rehearsals[gate_index].step_id == bundle.moves[move_index].step_id:\n")
    a("                found_gate = True\n")
    a("                if bundle.gate_rehearsals[gate_index].status != \"ready\":\n")
    a("                    return False\n")
    a("                if len(bundle.gate_rehearsals[gate_index].preflight_commands) == 0:\n")
    a("                    return False\n")
    a("                if len(bundle.gate_rehearsals[gate_index].postflight_commands) == 0:\n")
    a("                    return False\n")
    a("                break\n")
    a("        if not found_gate or bundle.moves[move_index].status != \"rehearsed\":\n")
    a("            return False\n")
    a("    for open_index in range(len(bundle.open_sets)):\n")
    a("        var found_cover = False\n")
    a("        for cover_index in range(len(bundle.covers)):\n")
    a("            if bundle.covers[cover_index].open_set_id == bundle.open_sets[open_index].open_set_id:\n")
    a("                found_cover = True\n")
    a("                if bundle.covers[cover_index].status != \"covered\":\n")
    a("                    return False\n")
    a("                if len(bundle.covers[cover_index].moves) != len(bundle.covers[cover_index].gate_suites):\n")
    a("                    return False\n")
    a("                break\n")
    a("        if not found_cover:\n")
    a("            return False\n")
    a("    return rehearsal_snapshot_validation_passed(bundle)\n\n")

    a("def architecture_rehearsal_count_line(bundle: ArchitectureRehearsalBundle) -> String:\n")
    a("    return (\n")
    a('        "open_sets=" + String(len(bundle.open_sets))\n')
    a('        + " moves=" + String(len(bundle.moves))\n')
    a('        + " gate_rehearsals=" + String(len(bundle.gate_rehearsals))\n')
    a('        + " covers=" + String(len(bundle.covers))\n')
    a("    )\n\n")

    a("def bootstrap_architecture_rehearsal() -> ArchitectureRehearsalBundle:\n")
    a("    var open_sets = List[RehearsalOpenSetSpec]()\n")
    for item in snapshot["open_sets"]:
        a("    open_sets.append(RehearsalOpenSetSpec(\n")
        a(f'        {q(item["open_set_id"])}, {q(item["wave_id"])}, {int(item["order"])}, {q(item["name"])},\n')
        a(f'        {strings(item["owner_capsules"])}, {strings(item["candidates"])}, {strings(item["basis"])},\n')
        a(f'        {q(item["topology_role"])}, {q(item["status"])},\n')
        a("    ))\n")

    a("    var moves = List[RehearsalMoveSpec]()\n")
    for item in snapshot["moves"]:
        a("    moves.append(RehearsalMoveSpec(\n")
        a(f'        {q(item["move_id"])}, {q(item["step_id"])}, {q(item["wave_id"])},\n')
        a(f'        {q(item["legacy_owner"])}, {q(item["target_owner"])},\n')
        a(f'        {q(item["current_capsule"])}, {q(item["target_capsule"])},\n')
        a(f'        {q(item["action_type"])}, {q(item["category"])}, {strings(item["functors"])},\n')
        a(f'        {strings(item["natural_transformations"])}, {strings(item["diagrams"])},\n')
        a(f'        {strings(item["laws"])}, {strings(item["gates"])},\n')
        a(f'        {strings(item["preconditions"])}, {strings(item["postconditions"])},\n')
        a(f'        {q(item["rollback_anchor"])}, {q(item["status"])},\n')
        a("    ))\n")

    a("    var gate_rehearsals = List[GateRehearsalSpec]()\n")
    for item in snapshot["gate_rehearsals"]:
        a("    gate_rehearsals.append(GateRehearsalSpec(\n")
        a(f'        {q(item["gate_suite_id"])}, {q(item["step_id"])}, {q(item["candidate"])},\n')
        a(f'        {strings(item["gates"])}, {command_specs(item["preflight_commands"])},\n')
        a(f'        {command_specs(item["postflight_commands"])}, {q(item["rollback_anchor"])},\n')
        a(f'        {boolean(bool(item["command_parity_required"]))}, {strings(item["bound_diagrams"])},\n')
        a(f'        {q(item["status"])},\n')
        a("    ))\n")

    a("    var covers = List[RehearsalCoverSpec]()\n")
    for item in snapshot["covers"]:
        a("    covers.append(RehearsalCoverSpec(\n")
        a(f'        {q(item["cover_id"])}, {q(item["open_set_id"])}, {q(item["wave_id"])},\n')
        a(f'        {strings(item["moves"])}, {strings(item["gate_suites"])},\n')
        a(f'        {q(item["gluing_operation"])}, {q(item["universal_property"])}, {q(item["status"])},\n')
        a("    ))\n")

    a("    var checks = List[RehearsalCheckSpec]()\n")
    for item in snapshot["validation"]["checks"]:
        a("    checks.append(RehearsalCheckSpec(\n")
        a(f'        {q(item["name"])}, {q(item["status"])}, {strings(item["failed_items"])},\n')
        a(f'        {int(item["checked_count"])}, {q(item["reading"])},\n')
        a("    ))\n")
    validation = snapshot["validation"]
    a("    var validation = RehearsalValidationSpec(\n")
    a(f'        {q(validation["status"])}, {strings(validation["missing_migration_steps"])},\n')
    a(f'        {strings(validation["rehearsals_without_gate_suite"])}, {strings(validation["open_sets_without_cover"])},\n')
    a(f'        {strings(validation["unknown_diagrams"])}, {strings(validation["unknown_laws"])},\n')
    a(f'        {strings(validation["unknown_natural_transformations"])},\n')
    a(f'        {strings(validation["gate_suites_with_missing_commands"])}, checks^,\n')
    a("    )\n")
    plan = snapshot["plan"]
    a("    var plan = Stage35ArchitecturePlan(\n")
    a(f'        {strings(plan["planned_after_stage_34"])}, {strings(plan["implemented_in_stage_35"])},\n')
    a(f'        {strings(plan["inherited_from_previous_stages"])}, {q(plan["behaviour_change"])},\n')
    a("    )\n")
    a("    return ArchitectureRehearsalBundle(\n")
    a("        open_sets^, moves^, gate_rehearsals^, covers^, validation^,\n")
    a(f'        {q(snapshot["diagrams"]["text"])}, {q(snapshot["diagrams"]["mermaid"])}, plan^,\n')
    a("    )\n")
    return "".join(out)


def load_snapshot(reference_root: pathlib.Path) -> dict[str, Any]:
    sys.path.insert(0, str(reference_root))
    sys.path.insert(0, str(reference_root / "libs"))
    from reta_architecture.category_theory import bootstrap_category_theory
    from reta_architecture.architecture_map import bootstrap_architecture_map
    from reta_architecture.architecture_contracts import bootstrap_architecture_contracts
    from reta_architecture.architecture_witnesses import bootstrap_architecture_witnesses
    from reta_architecture.architecture_coherence import bootstrap_architecture_coherence
    from reta_architecture.architecture_traces import bootstrap_architecture_traces
    from reta_architecture.architecture_boundaries import bootstrap_architecture_boundaries
    from reta_architecture.architecture_impact import bootstrap_architecture_impact
    from reta_architecture.architecture_migration import bootstrap_architecture_migration
    from reta_architecture.architecture_rehearsal import bootstrap_architecture_rehearsal

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
    migration = bootstrap_architecture_migration(
        category_theory=category,
        architecture_map=architecture_map,
        architecture_contracts=contracts,
        architecture_impact=impact,
    )
    bundle = bootstrap_architecture_rehearsal(
        category_theory=category,
        architecture_contracts=contracts,
        architecture_impact=impact,
        architecture_migration=migration,
    )
    return bundle.snapshot()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--reference-root", type=pathlib.Path, default=pathlib.Path("python_reference"))
    parser.add_argument("--output", type=pathlib.Path, default=pathlib.Path("src/reta_mojo/architecture_rehearsal.mojo"))
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    generated = generate(load_snapshot(args.reference_root.resolve()))
    if args.check:
        current = args.output.read_text(encoding="utf-8")
        if current != generated:
            raise SystemExit(f"generated architecture rehearsal differs: {args.output}")
        return
    args.output.write_text(generated, encoding="utf-8")


if __name__ == "__main__":
    main()
