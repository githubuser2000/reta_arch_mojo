#!/usr/bin/env python3
"""Generate the native Mojo Stage-41 architecture-validation snapshot."""
from __future__ import annotations

import argparse
import json
import pathlib
import sys
from typing import Any, Iterable


def q(value: object) -> str:
    return json.dumps(str(value), ensure_ascii=False)


def strings(values: Iterable[object]) -> str:
    return "[" + ", ".join(q(value) for value in values) + "]"


def emit_struct(out: list[str], name: str, fields: list[tuple[str, str]]) -> None:
    out.append("@fieldwise_init\n")
    out.append(f"struct {name}(Copyable):\n")
    for field, typ in fields:
        out.append(f"    var {field}: {typ}\n")
    out.append("\n")


def generate(snapshot: dict[str, Any]) -> str:
    out: list[str] = []
    a = out.append
    a('"""Generated native Mojo representation of architecture_validation.\n')
    a('The Python reference is evaluated only during explicit regeneration; runtime\n')
    a('navigation and consistency validation are fully native.\n')
    a('Regenerate with tools/generate_architecture_validation.py.\n"""\n\n')
    a('from std.collections import List\n\n')

    emit_struct(out, "ArchitectureValidationCheckSpec", [
        ("name", "String"), ("layer", "String"), ("obligation", "String"),
        ("status", "String"), ("severity", "String"), ("checked_count", "Int"),
        ("failed_items", "List[String]"), ("evidence", "List[String]"),
        ("description", "String"),
    ])
    emit_struct(out, "ArchitectureValidationLayerSpec", [
        ("name", "String"), ("role", "String"), ("checks", "List[String]"),
        ("status", "String"), ("failed_checks", "List[String]"),
    ])
    emit_struct(out, "ArchitectureValidationSummarySpec", [
        ("status", "String"), ("total_checks", "Int"), ("passed_checks", "Int"),
        ("attention_checks", "Int"), ("failed_checks", "Int"),
        ("warning_checks", "Int"), ("error_checks", "Int"),
        ("checked_items", "Int"), ("failed_items", "List[String]"),
    ])
    emit_struct(out, "Stage31ArchitecturePlan", [
        ("planned_after_stage_30", "List[String]"),
        ("implemented_in_stage_31", "List[String]"),
        ("inherited_from_previous_stages", "List[String]"),
        ("behaviour_change", "String"),
    ])
    emit_struct(out, "ArchitectureValidationBundle", [
        ("stage", "Int"), ("purpose", "String"), ("paradigm", "List[String]"),
        ("checks", "List[ArchitectureValidationCheckSpec]"),
        ("layers", "List[ArchitectureValidationLayerSpec]"),
        ("summary", "ArchitectureValidationSummarySpec"),
        ("text_diagram", "String"), ("mermaid_diagram", "String"),
        ("plan", "Stage31ArchitecturePlan"),
    ])

    a('def architecture_validation_check_index(bundle: ArchitectureValidationBundle, name: String) -> Int:\n')
    a('    for index in range(len(bundle.checks)):\n')
    a('        if bundle.checks[index].name == name:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def architecture_validation_layer_index(bundle: ArchitectureValidationBundle, name: String) -> Int:\n')
    a('    for index in range(len(bundle.layers)):\n')
    a('        if bundle.layers[index].name == name:\n')
    a('            return index\n')
    a('    return -1\n\n')
    a('def architecture_validation_layer_check_count(bundle: ArchitectureValidationBundle, name: String) -> Int:\n')
    a('    var index = architecture_validation_layer_index(bundle, name)\n')
    a('    if index < 0:\n')
    a('        return 0\n')
    a('    return len(bundle.layers[index].checks)\n\n')
    a('def architecture_validation_snapshot_passed(bundle: ArchitectureValidationBundle) -> Bool:\n')
    a('    return (\n')
    a('        bundle.stage == 41\n')
    a('        and bundle.summary.status == "passed"\n')
    a('        and bundle.summary.total_checks == len(bundle.checks)\n')
    a('        and bundle.summary.passed_checks == len(bundle.checks)\n')
    a('        and bundle.summary.attention_checks == 0\n')
    a('        and bundle.summary.failed_checks == 0\n')
    a('        and len(bundle.summary.failed_items) == 0\n')
    a('    )\n\n')
    a('def architecture_validation_runtime_consistency_passed(bundle: ArchitectureValidationBundle) -> Bool:\n')
    a('    var passed = 0\n')
    a('    var attention = 0\n')
    a('    var failed = 0\n')
    a('    var checked_items = 0\n')
    a('    for index in range(len(bundle.checks)):\n')
    a('        var check = bundle.checks[index].copy()\n')
    a('        if architecture_validation_layer_index(bundle, check.layer) < 0:\n')
    a('            return False\n')
    a('        if check.status == "passed":\n')
    a('            passed += 1\n')
    a('            if len(check.failed_items) != 0:\n')
    a('                return False\n')
    a('        elif check.status == "attention":\n')
    a('            attention += 1\n')
    a('        else:\n')
    a('            failed += 1\n')
    a('        checked_items += check.checked_count\n')
    a('        for other in range(index + 1, len(bundle.checks)):\n')
    a('            if bundle.checks[other].name == check.name:\n')
    a('                return False\n')
    a('    if passed != bundle.summary.passed_checks:\n')
    a('        return False\n')
    a('    if attention != bundle.summary.attention_checks:\n')
    a('        return False\n')
    a('    if failed != bundle.summary.failed_checks:\n')
    a('        return False\n')
    a('    if checked_items != bundle.summary.checked_items:\n')
    a('        return False\n')
    a('    for layer_index in range(len(bundle.layers)):\n')
    a('        var layer = bundle.layers[layer_index].copy()\n')
    a('        for other in range(layer_index + 1, len(bundle.layers)):\n')
    a('            if bundle.layers[other].name == layer.name:\n')
    a('                return False\n')
    a('        var failed_in_layer = 0\n')
    a('        for name in layer.checks:\n')
    a('            var check_index = architecture_validation_check_index(bundle, name)\n')
    a('            if check_index < 0:\n')
    a('                return False\n')
    a('            if bundle.checks[check_index].layer != layer.name:\n')
    a('                return False\n')
    a('            if bundle.checks[check_index].status != "passed":\n')
    a('                failed_in_layer += 1\n')
    a('        if failed_in_layer != len(layer.failed_checks):\n')
    a('            return False\n')
    a('        if (failed_in_layer == 0) != (layer.status == "passed"):\n')
    a('            return False\n')
    a('    return architecture_validation_snapshot_passed(bundle)\n\n')
    a('def architecture_validation_count_line(bundle: ArchitectureValidationBundle) -> String:\n')
    a('    return (\n')
    a('        "checks=" + String(len(bundle.checks))\n')
    a('        + " layers=" + String(len(bundle.layers))\n')
    a('        + " passed=" + String(bundle.summary.passed_checks)\n')
    a('        + " attention=" + String(bundle.summary.attention_checks)\n')
    a('        + " failed=" + String(bundle.summary.failed_checks)\n')
    a('        + " checked_items=" + String(bundle.summary.checked_items)\n')
    a('    )\n\n')

    a('def bootstrap_architecture_validation() -> ArchitectureValidationBundle:\n')
    a('    var checks = List[ArchitectureValidationCheckSpec]()\n')
    for item in snapshot['checks']:
        a('    checks.append(ArchitectureValidationCheckSpec(\n')
        a(f'        {q(item["name"])}, {q(item["layer"])}, {q(item["obligation"])},\n')
        a(f'        {q(item["status"])}, {q(item["severity"])}, {int(item["checked_count"])},\n')
        a(f'        {strings(item["failed_items"])}, {strings(item["evidence"])}, {q(item["description"])},\n')
        a('    ))\n')
    a('    var layers = List[ArchitectureValidationLayerSpec]()\n')
    for item in snapshot['layers']:
        a('    layers.append(ArchitectureValidationLayerSpec(\n')
        a(f'        {q(item["name"])}, {q(item["role"])}, {strings(item["checks"])},\n')
        a(f'        {q(item["status"])}, {strings(item["failed_checks"])},\n')
        a('    ))\n')
    summary = snapshot['summary']
    a('    var summary = ArchitectureValidationSummarySpec(\n')
    a(f'        {q(summary["status"])}, {int(summary["total_checks"])}, {int(summary["passed_checks"])},\n')
    a(f'        {int(summary["attention_checks"])}, {int(summary["failed_checks"])},\n')
    a(f'        {int(summary["warning_checks"])}, {int(summary["error_checks"])},\n')
    a(f'        {int(summary["checked_items"])}, {strings(summary["failed_items"])},\n')
    a('    )\n')
    plan = snapshot['plan']
    a('    var plan = Stage31ArchitecturePlan(\n')
    a(f'        {strings(plan["planned_after_stage_30"])}, {strings(plan["implemented_in_stage_31"])},\n')
    a(f'        {strings(plan["inherited_from_previous_stages"])}, {q(plan["behaviour_change"])},\n')
    a('    )\n')
    a('    return ArchitectureValidationBundle(\n')
    a(f'        {int(snapshot["stage"])}, {q(snapshot["purpose"])}, {strings(snapshot["paradigm"])},\n')
    a('        checks^, layers^, summary^,\n')
    a(f'        {q(snapshot["diagrams"]["text"])}, {q(snapshot["diagrams"]["mermaid"])}, plan^,\n')
    a('    )\n')
    return ''.join(out)


def normalize_snapshot(snapshot: dict[str, Any], reference_root: pathlib.Path) -> dict[str, Any]:
    """Remove runtime-artifact sensitivity from the package-integrity count.

    The Python validation deliberately does not treat caches as failures, but its
    diagnostic checked_count includes them.  A generated source snapshot must be
    independent of whether __pycache__ files happen to exist while regenerating.
    """
    from reta_architecture.package_integrity import iter_manifest_files

    clean_file_count = sum(1 for _ in iter_manifest_files(reference_root))
    package_check_found = False
    for check in snapshot['checks']:
        if check['name'] == 'PackageIntegrityValidationCheck':
            check['checked_count'] = clean_file_count
            package_check_found = True
            break
    if not package_check_found:
        raise ValueError('PackageIntegrityValidationCheck missing from validation snapshot')
    snapshot['summary']['checked_items'] = sum(
        int(check['checked_count']) for check in snapshot['checks']
    )
    return snapshot


def load_snapshot(reference_root: pathlib.Path) -> dict[str, Any]:
    sys.path.insert(0, str(reference_root))
    sys.path.insert(0, str(reference_root / 'libs'))
    from reta_architecture import RetaArchitecture

    snapshot = RetaArchitecture.bootstrap(
        reference_root, use_cache=False
    ).architecture_validation.snapshot()
    return normalize_snapshot(snapshot, reference_root)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--reference-root', type=pathlib.Path, default=pathlib.Path('python_reference'))
    parser.add_argument('--output', type=pathlib.Path, default=pathlib.Path('src/reta_mojo/architecture_validation.mojo'))
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    generated = generate(load_snapshot(args.reference_root.resolve()))
    if args.check:
        current = args.output.read_text(encoding='utf-8')
        if current != generated:
            raise SystemExit(f'generated architecture validation differs: {args.output}')
        return
    args.output.write_text(generated, encoding='utf-8')


if __name__ == '__main__':
    main()
