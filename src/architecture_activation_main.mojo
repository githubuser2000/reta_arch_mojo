"""Compact native query surface for the generated Stage-36 activation bundle."""

from std.sys import argv
from reta_mojo.architecture_activation import (
    activation_gate_index,
    activation_rollback_index,
    activation_snapshot_validation_passed,
    activation_transaction_index,
    activation_unit_index,
    activation_window_index,
    architecture_activation_count_line,
    bootstrap_architecture_activation,
)


def _usage() -> None:
    print("reta-mojo-activation")
    print("  --summary")
    print("  --window ID")
    print("  --unit ID")
    print("  --gate ID")
    print("  --rollback ACTIVATION_ID")
    print("  --transaction ID")


def main() raises:
    var args = argv()
    var bundle = bootstrap_architecture_activation()

    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        print(architecture_activation_count_line(bundle))
        print("snapshot_validation=" + bundle.validation.status)
        print("snapshot_passed=" + ("true" if activation_snapshot_validation_passed(bundle) else "false"))
        return

    if len(args) == 3 and String(args[1]) == "--window":
        var index = activation_window_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown activation window")
        print(bundle.windows[index].window_id)
        print(bundle.windows[index].wave_id)
        print(bundle.windows[index].status)
        print("units=" + String(len(bundle.windows[index].activation_units)))
        return

    if len(args) == 3 and String(args[1]) == "--unit":
        var index = activation_unit_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown activation unit")
        print(bundle.units[index].activation_id)
        print(bundle.units[index].legacy_owner)
        print(bundle.units[index].target_owner)
        print(bundle.units[index].status)
        print("required_gates=" + String(len(bundle.units[index].required_gates)))
        return

    if len(args) == 3 and String(args[1]) == "--gate":
        var index = activation_gate_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown activation gate")
        print(bundle.gates[index].gate_suite_id)
        print(bundle.gates[index].status)
        print("preflight=" + String(len(bundle.gates[index].preflight_commands)))
        print("commit=" + String(len(bundle.gates[index].commit_commands)))
        print("postflight=" + String(len(bundle.gates[index].postflight_commands)))
        print("rollback=" + String(len(bundle.gates[index].rollback_commands)))
        return

    if len(args) == 3 and String(args[1]) == "--rollback":
        var index = activation_rollback_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown activation rollback")
        print(bundle.rollbacks[index].activation_id)
        print(bundle.rollbacks[index].rollback_anchor)
        print(bundle.rollbacks[index].status)
        print("protected_diagrams=" + String(len(bundle.rollbacks[index].protected_diagrams)))
        return

    if len(args) == 3 and String(args[1]) == "--transaction":
        var index = activation_transaction_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown activation transaction")
        print(bundle.transactions[index].transaction_id)
        print(bundle.transactions[index].wave_id)
        print(bundle.transactions[index].status)
        print("units=" + String(len(bundle.transactions[index].activation_units)))
        return

    _usage()
    raise Error("invalid architecture-activation arguments")
