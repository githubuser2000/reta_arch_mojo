"""Compact native query surface for the generated Stage-41 validation bundle."""

from std.sys import argv
from reta_mojo.architecture_validation import (
    architecture_validation_check_index,
    architecture_validation_count_line,
    architecture_validation_layer_index,
    architecture_validation_runtime_consistency_passed,
    architecture_validation_snapshot_passed,
    bootstrap_architecture_validation,
)


def _usage() -> None:
    print("reta-mojo-validation")
    print("  --summary")
    print("  --check NAME")
    print("  --layer NAME")


def main() raises:
    var args = argv()
    var bundle = bootstrap_architecture_validation()

    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        print(architecture_validation_count_line(bundle))
        print("snapshot_validation=" + bundle.summary.status)
        print("snapshot_passed=" + ("true" if architecture_validation_snapshot_passed(bundle) else "false"))
        print("runtime_passed=" + ("true" if architecture_validation_runtime_consistency_passed(bundle) else "false"))
        return

    if len(args) == 3 and String(args[1]) == "--check":
        var index = architecture_validation_check_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown architecture validation check")
        print(bundle.checks[index].name)
        print(bundle.checks[index].layer)
        print(bundle.checks[index].status)
        print(bundle.checks[index].severity)
        print("checked_count=" + String(bundle.checks[index].checked_count))
        print("failed_items=" + String(len(bundle.checks[index].failed_items)))
        return

    if len(args) == 3 and String(args[1]) == "--layer":
        var index = architecture_validation_layer_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown architecture validation layer")
        print(bundle.layers[index].name)
        print(bundle.layers[index].status)
        print("checks=" + String(len(bundle.layers[index].checks)))
        print("failed_checks=" + String(len(bundle.layers[index].failed_checks)))
        return

    _usage()
    raise Error("invalid architecture-validation arguments")
