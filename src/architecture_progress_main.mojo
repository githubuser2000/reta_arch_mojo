"""Compact native query surface for the generated Stage-42 progress overlay."""

from std.sys import argv
from reta_mojo.architecture_progress import (
    architecture_progress_count_line,
    architecture_progress_runtime_consistency_passed,
    architecture_progress_snapshot_consistent,
    architecture_progress_step_index,
    architecture_progress_surface_index,
    architecture_progress_wave_index,
    architecture_progress_work_index,
    bootstrap_architecture_progress,
)


def _usage() -> None:
    print("reta-mojo-progress")
    print("  --summary")
    print("  --surface OWNER")
    print("  --step ID")
    print("  --wave ID")
    print("  --work ID")


def main() raises:
    var args = argv()
    var bundle = bootstrap_architecture_progress()

    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        print(architecture_progress_count_line(bundle))
        print("snapshot_validation=" + bundle.validation.status)
        print("snapshot_consistent=" + ("true" if architecture_progress_snapshot_consistent(bundle) else "false"))
        print("runtime_passed=" + ("true" if architecture_progress_runtime_consistency_passed(bundle) else "false"))
        return

    if len(args) == 3 and String(args[1]) == "--surface":
        var index = architecture_progress_surface_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown progress surface")
        print(bundle.surfaces[index].owner)
        print(bundle.surfaces[index].owner_kind)
        print(bundle.surfaces[index].execution_status)
        print("lines=" + String(bundle.surfaces[index].line_count))
        print("functions=" + String(bundle.surfaces[index].function_count))
        print("wrappers=" + String(bundle.surfaces[index].wrapper_like_count))
        return

    if len(args) == 3 and String(args[1]) == "--step":
        var index = architecture_progress_step_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown progress step")
        print(bundle.step_progress[index].step_id)
        print(bundle.step_progress[index].wave_id)
        print(bundle.step_progress[index].legacy_owner)
        print(bundle.step_progress[index].execution_status)
        print("remaining_work=" + String(len(bundle.step_progress[index].remaining_work)))
        return

    if len(args) == 3 and String(args[1]) == "--wave":
        var index = architecture_progress_wave_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown progress wave")
        print(bundle.wave_progress[index].wave_id)
        print(bundle.wave_progress[index].name)
        print(bundle.wave_progress[index].status)
        print("total=" + String(bundle.wave_progress[index].total_steps))
        print("completed=" + String(bundle.wave_progress[index].completed_steps))
        print("mixed=" + String(bundle.wave_progress[index].mixed_steps))
        print("outstanding=" + String(bundle.wave_progress[index].outstanding_steps))
        return

    if len(args) == 3 and String(args[1]) == "--work":
        var index = architecture_progress_work_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown progress work item")
        print(bundle.outstanding_work[index].item_id)
        print(bundle.outstanding_work[index].priority)
        print(bundle.outstanding_work[index].status)
        print(bundle.outstanding_work[index].title)
        print("owners=" + String(len(bundle.outstanding_work[index].owners)))
        return

    _usage()
    raise Error("invalid architecture-progress arguments")
