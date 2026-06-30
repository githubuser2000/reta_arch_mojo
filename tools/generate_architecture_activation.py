#!/usr/bin/env python3
"""Generate the native Mojo Stage-36 architecture-activation bundle."""
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
        f"ActivationCommandSpec({q(name)}, {q(command)})"
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
    a('"""Generated native Mojo representation of architecture_activation.\n')
    a('The Python reference is evaluated only during explicit regeneration; runtime\n')
    a('navigation and snapshot validation are fully native.\n')
    a('Regenerate with tools/generate_architecture_activation.py.\n"""\n\n')
    a('from std.collections import List\n\n')

    emit_struct(out, "ActivationCommandSpec", [("name", "String"), ("command", "String")])
    emit_struct(out, "ActivationWindowSpec", [
        ("window_id", "String"), ("wave_id", "String"), ("order", "Int"),
        ("open_set_id", "String"), ("owner_capsules", "List[String]"),
        ("activation_units", "List[String]"), ("basis", "List[String]"),
        ("topology_role", "String"), ("status", "String"),
    ])
    emit_struct(out, "ActivationUnitSpec", [
        ("activation_id", "String"), ("move_id", "String"),
        ("step_id", "String"), ("wave_id", "String"),
        ("legacy_owner", "String"), ("target_owner", "String"),
        ("current_capsule", "String"), ("target_capsule", "String"),
        ("activation_kind", "String"), ("category", "String"),
        ("functors", "List[String]"), ("natural_transformations", "List[String]"),
        ("diagrams", "List[String]"), ("laws", "List[String]"),
        ("required_gates", "List[String]"), ("rehearsal_gate_suite", "String"),
        ("commit_strategy", "String"), ("rollback_strategy", "String"),
        ("observable_invariant", "String"), ("status", "String"),
    ])
    emit_struct(out, "ActivationGateSpec", [
        ("activation_id", "String"), ("gate_suite_id", "String"),
        ("gates", "List[String]"),
        ("preflight_commands", "List[ActivationCommandSpec]"),
        ("commit_commands", "List[ActivationCommandSpec]"),
        ("postflight_commands", "List[ActivationCommandSpec]"),
        ("rollback_commands", "List[ActivationCommandSpec]"),
        ("command_parity_required", "Bool"),
        ("bound_diagrams", "List[String]"), ("status", "String"),
    ])
    emit_struct(out, "ActivationRollbackSpec", [
        ("activation_id", "String"), ("rollback_anchor", "String"),
        ("rollback_commands", "List[ActivationCommandSpec]"),
        ("protected_diagrams", "List[String]"),
        ("protected_laws", "List[String]"), ("status", "String"),
    ])
    emit_struct(out, "ActivationTransactionSpec", [
        ("transaction_id", "String"), ("window_id", "String"),
        ("wave_id", "String"), ("activation_units", "List[String]"),
        ("gate_suites", "List[String]"), ("rollback_sections", "List[String]"),
        ("commit_order", "List[String]"), ("gluing_operation", "String"),
        ("universal_property", "String"), ("status", "String"),
    ])
    emit_struct(out, "ActivationCheckSpec", [
        ("name", "String"), ("status", "String"),
        ("failed_items", "List[String]"), ("checked_count", "Int"),
        ("reading", "String"),
    ])
    emit_struct(out, "ActivationValidationSpec", [
        ("status", "String"), ("missing_rehearsal_moves", "List[String]"),
        ("activations_without_gate", "List[String]"),
        ("activations_without_rollback", "List[String]"),
        ("windows_without_transaction", "List[String]"),
        ("unknown_diagrams", "List[String]"), ("unknown_laws", "List[String]"),
        ("unknown_natural_transformations", "List[String]"),
        ("transactions_not_ready", "List[String]"),
        ("checks", "List[ActivationCheckSpec]"),
    ])
    emit_struct(out, "Stage36ArchitecturePlan", [
        ("planned_after_stage_35", "List[String]"),
        ("implemented_in_stage_36", "List[String]"),
        ("inherited_from_previous_stages", "List[String]"),
        ("behaviour_change", "String"),
    ])
    emit_struct(out, "ArchitectureActivationBundle", [
        ("windows", "List[ActivationWindowSpec]"),
        ("units", "List[ActivationUnitSpec]"),
        ("gates", "List[ActivationGateSpec]"),
        ("rollbacks", "List[ActivationRollbackSpec]"),
        ("transactions", "List[ActivationTransactionSpec]"),
        ("validation", "ActivationValidationSpec"),
        ("text_diagram", "String"), ("mermaid_diagram", "String"),
        ("plan", "Stage36ArchitecturePlan"),
    ])

    for fn, collection, field in (
        ("activation_window_index", "windows", "window_id"),
        ("activation_unit_index", "units", "activation_id"),
        ("activation_move_index", "units", "move_id"),
        ("activation_gate_index", "gates", "gate_suite_id"),
        ("activation_rollback_index", "rollbacks", "activation_id"),
        ("activation_transaction_index", "transactions", "transaction_id"),
    ):
        a(f"def {fn}(bundle: ArchitectureActivationBundle, value: String) -> Int:\n")
        a(f"    for index in range(len(bundle.{collection})):\n")
        a(f"        if bundle.{collection}[index].{field} == value:\n")
        a("            return index\n")
        a("    return -1\n\n")

    a("def activation_wave_unit_count(bundle: ArchitectureActivationBundle, wave_id: String) -> Int:\n")
    a("    var count = 0\n")
    a("    for index in range(len(bundle.units)):\n")
    a("        if bundle.units[index].wave_id == wave_id:\n")
    a("            count += 1\n")
    a("    return count\n\n")

    a("def activation_snapshot_validation_passed(bundle: ArchitectureActivationBundle) -> Bool:\n")
    a("    return (\n")
    a('        bundle.validation.status == "passed"\n')
    for field in (
        "missing_rehearsal_moves", "activations_without_gate",
        "activations_without_rollback", "windows_without_transaction",
        "unknown_diagrams", "unknown_laws", "unknown_natural_transformations",
        "transactions_not_ready",
    ):
        a(f"        and len(bundle.validation.{field}) == 0\n")
    a("    )\n\n")

    a("def activation_runtime_validation_passed(bundle: ArchitectureActivationBundle) -> Bool:\n")
    a("    if len(bundle.units) != len(bundle.gates) or len(bundle.units) != len(bundle.rollbacks):\n")
    a("        return False\n")
    a("    if len(bundle.windows) != len(bundle.transactions):\n")
    a("        return False\n")
    a("    for unit_index in range(len(bundle.units)):\n")
    a("        var found_gate = False\n")
    a("        var found_rollback = False\n")
    a("        for gate_index in range(len(bundle.gates)):\n")
    a("            if bundle.gates[gate_index].activation_id == bundle.units[unit_index].activation_id:\n")
    a("                found_gate = True\n")
    a("                if bundle.gates[gate_index].status != \"commit_gated\":\n")
    a("                    return False\n")
    a("                if len(bundle.gates[gate_index].commit_commands) == 0:\n")
    a("                    return False\n")
    a("                break\n")
    a("        for rollback_index in range(len(bundle.rollbacks)):\n")
    a("            if bundle.rollbacks[rollback_index].activation_id == bundle.units[unit_index].activation_id:\n")
    a("                found_rollback = True\n")
    a("                if bundle.rollbacks[rollback_index].status != \"rollback_ready\":\n")
    a("                    return False\n")
    a("                if len(bundle.rollbacks[rollback_index].rollback_commands) == 0:\n")
    a("                    return False\n")
    a("                break\n")
    a("        if not found_gate or not found_rollback or bundle.units[unit_index].status != \"activation_ready\":\n")
    a("            return False\n")
    a("    for window_index in range(len(bundle.windows)):\n")
    a("        var found_transaction = False\n")
    a("        for transaction_index in range(len(bundle.transactions)):\n")
    a("            if bundle.transactions[transaction_index].window_id == bundle.windows[window_index].window_id:\n")
    a("                found_transaction = True\n")
    a("                if bundle.transactions[transaction_index].status != \"transaction_ready\":\n")
    a("                    return False\n")
    a("                if len(bundle.transactions[transaction_index].activation_units) != len(bundle.transactions[transaction_index].gate_suites):\n")
    a("                    return False\n")
    a("                if len(bundle.transactions[transaction_index].activation_units) != len(bundle.transactions[transaction_index].rollback_sections):\n")
    a("                    return False\n")
    a("                break\n")
    a("        if not found_transaction:\n")
    a("            return False\n")
    a("    return activation_snapshot_validation_passed(bundle)\n\n")

    a("def architecture_activation_count_line(bundle: ArchitectureActivationBundle) -> String:\n")
    a("    return (\n")
    a('        "windows=" + String(len(bundle.windows))\n')
    a('        + " units=" + String(len(bundle.units))\n')
    a('        + " gates=" + String(len(bundle.gates))\n')
    a('        + " rollbacks=" + String(len(bundle.rollbacks))\n')
    a('        + " transactions=" + String(len(bundle.transactions))\n')
    a("    )\n\n")

    a("def bootstrap_architecture_activation() -> ArchitectureActivationBundle:\n")
    a("    var windows = List[ActivationWindowSpec]()\n")
    for item in snapshot["windows"]:
        a("    windows.append(ActivationWindowSpec(\n")
        a(f'        {q(item["window_id"])}, {q(item["wave_id"])}, {int(item["order"])}, {q(item["open_set_id"])},\n')
        a(f'        {strings(item["owner_capsules"])}, {strings(item["activation_units"])}, {strings(item["basis"])},\n')
        a(f'        {q(item["topology_role"])}, {q(item["status"])},\n')
        a("    ))\n")

    a("    var units = List[ActivationUnitSpec]()\n")
    for item in snapshot["units"]:
        a("    units.append(ActivationUnitSpec(\n")
        a(f'        {q(item["activation_id"])}, {q(item["move_id"])}, {q(item["step_id"])}, {q(item["wave_id"])},\n')
        a(f'        {q(item["legacy_owner"])}, {q(item["target_owner"])},\n')
        a(f'        {q(item["current_capsule"])}, {q(item["target_capsule"])},\n')
        a(f'        {q(item["activation_kind"])}, {q(item["category"])}, {strings(item["functors"])},\n')
        a(f'        {strings(item["natural_transformations"])}, {strings(item["diagrams"])},\n')
        a(f'        {strings(item["laws"])}, {strings(item["required_gates"])},\n')
        a(f'        {q(item["rehearsal_gate_suite"])}, {q(item["commit_strategy"])},\n')
        a(f'        {q(item["rollback_strategy"])}, {q(item["observable_invariant"])}, {q(item["status"])},\n')
        a("    ))\n")

    a("    var gates = List[ActivationGateSpec]()\n")
    for item in snapshot["gates"]:
        a("    gates.append(ActivationGateSpec(\n")
        a(f'        {q(item["activation_id"])}, {q(item["gate_suite_id"])}, {strings(item["gates"])},\n')
        a(f'        {command_specs(item["preflight_commands"])}, {command_specs(item["commit_commands"])},\n')
        a(f'        {command_specs(item["postflight_commands"])}, {command_specs(item["rollback_commands"])},\n')
        a(f'        {boolean(bool(item["command_parity_required"]))}, {strings(item["bound_diagrams"])}, {q(item["status"])},\n')
        a("    ))\n")

    a("    var rollbacks = List[ActivationRollbackSpec]()\n")
    for item in snapshot["rollbacks"]:
        a("    rollbacks.append(ActivationRollbackSpec(\n")
        a(f'        {q(item["activation_id"])}, {q(item["rollback_anchor"])},\n')
        a(f'        {command_specs(item["rollback_commands"])}, {strings(item["protected_diagrams"])},\n')
        a(f'        {strings(item["protected_laws"])}, {q(item["status"])},\n')
        a("    ))\n")

    a("    var transactions = List[ActivationTransactionSpec]()\n")
    for item in snapshot["transactions"]:
        a("    transactions.append(ActivationTransactionSpec(\n")
        a(f'        {q(item["transaction_id"])}, {q(item["window_id"])}, {q(item["wave_id"])},\n')
        a(f'        {strings(item["activation_units"])}, {strings(item["gate_suites"])},\n')
        a(f'        {strings(item["rollback_sections"])}, {strings(item["commit_order"])},\n')
        a(f'        {q(item["gluing_operation"])}, {q(item["universal_property"])}, {q(item["status"])},\n')
        a("    ))\n")

    a("    var checks = List[ActivationCheckSpec]()\n")
    for item in snapshot["validation"]["checks"]:
        a("    checks.append(ActivationCheckSpec(\n")
        a(f'        {q(item["name"])}, {q(item["status"])}, {strings(item["failed_items"])},\n')
        a(f'        {int(item["checked_count"])}, {q(item["reading"])},\n')
        a("    ))\n")
    validation = snapshot["validation"]
    a("    var validation = ActivationValidationSpec(\n")
    a(f'        {q(validation["status"])}, {strings(validation["missing_rehearsal_moves"])},\n')
    a(f'        {strings(validation["activations_without_gate"])}, {strings(validation["activations_without_rollback"])},\n')
    a(f'        {strings(validation["windows_without_transaction"])}, {strings(validation["unknown_diagrams"])},\n')
    a(f'        {strings(validation["unknown_laws"])}, {strings(validation["unknown_natural_transformations"])},\n')
    a(f'        {strings(validation["transactions_not_ready"])}, checks^,\n')
    a("    )\n")
    plan = snapshot["plan"]
    a("    var plan = Stage36ArchitecturePlan(\n")
    a(f'        {strings(plan["planned_after_stage_35"])}, {strings(plan["implemented_in_stage_36"])},\n')
    a(f'        {strings(plan["inherited_from_previous_stages"])}, {q(plan["behaviour_change"])},\n')
    a("    )\n")
    a("    return ArchitectureActivationBundle(\n")
    a("        windows^, units^, gates^, rollbacks^, transactions^, validation^,\n")
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
    from reta_architecture.architecture_activation import bootstrap_architecture_activation

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
    rehearsal = bootstrap_architecture_rehearsal(
        category_theory=category,
        architecture_contracts=contracts,
        architecture_impact=impact,
        architecture_migration=migration,
    )
    bundle = bootstrap_architecture_activation(
        category_theory=category,
        architecture_contracts=contracts,
        architecture_migration=migration,
        architecture_rehearsal=rehearsal,
    )
    return bundle.snapshot()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--reference-root", type=pathlib.Path, default=pathlib.Path("python_reference"))
    parser.add_argument("--output", type=pathlib.Path, default=pathlib.Path("src/reta_mojo/architecture_activation.mojo"))
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    generated = generate(load_snapshot(args.reference_root.resolve()))
    if args.check:
        current = args.output.read_text(encoding="utf-8")
        if current != generated:
            raise SystemExit(f"generated architecture activation differs: {args.output}")
        return
    args.output.write_text(generated, encoding="utf-8")


if __name__ == "__main__":
    main()
