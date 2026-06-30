"""Compact native query surface for the generated Stage-35 rehearsal bundle."""

from std.sys import argv
from reta_mojo.architecture_rehearsal import (
    architecture_rehearsal_count_line,
    bootstrap_architecture_rehearsal,
    rehearsal_cover_index,
    rehearsal_gate_index,
    rehearsal_move_index,
    rehearsal_open_set_index,
    rehearsal_snapshot_validation_passed,
)


def _usage() -> None:
    print("reta-mojo-rehearsal")
    print("  --summary")
    print("  --open-set ID")
    print("  --move ID")
    print("  --gate ID")
    print("  --cover ID")


def main() raises:
    var args = argv()
    var bundle = bootstrap_architecture_rehearsal()

    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        print(architecture_rehearsal_count_line(bundle))
        print("snapshot_validation=" + bundle.validation.status)
        print("snapshot_passed=" + ("true" if rehearsal_snapshot_validation_passed(bundle) else "false"))
        return

    if len(args) == 3 and String(args[1]) == "--open-set":
        var index = rehearsal_open_set_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown rehearsal open set")
        print(bundle.open_sets[index].open_set_id)
        print(bundle.open_sets[index].wave_id)
        print(bundle.open_sets[index].status)
        print("candidates=" + String(len(bundle.open_sets[index].candidates)))
        return

    if len(args) == 3 and String(args[1]) == "--move":
        var index = rehearsal_move_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown rehearsal move")
        print(bundle.moves[index].move_id)
        print(bundle.moves[index].legacy_owner)
        print(bundle.moves[index].target_owner)
        print(bundle.moves[index].status)
        print("gates=" + String(len(bundle.moves[index].gates)))
        return

    if len(args) == 3 and String(args[1]) == "--gate":
        var index = rehearsal_gate_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown rehearsal gate")
        print(bundle.gate_rehearsals[index].gate_suite_id)
        print(bundle.gate_rehearsals[index].status)
        print("preflight=" + String(len(bundle.gate_rehearsals[index].preflight_commands)))
        print("postflight=" + String(len(bundle.gate_rehearsals[index].postflight_commands)))
        return

    if len(args) == 3 and String(args[1]) == "--cover":
        var index = rehearsal_cover_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown rehearsal cover")
        print(bundle.covers[index].cover_id)
        print(bundle.covers[index].wave_id)
        print(bundle.covers[index].status)
        print("moves=" + String(len(bundle.covers[index].moves)))
        return

    _usage()
    raise Error("invalid architecture-rehearsal arguments")
