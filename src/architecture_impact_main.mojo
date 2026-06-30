"""Compact native query surface for the generated Stage-33 impact calculus."""

from std.sys import argv
from reta_mojo.architecture_impact import (
    architecture_impact_count_line,
    bootstrap_architecture_impact,
    impact_snapshot_validation_passed,
    impact_source_index,
    migration_candidate_index,
    regression_gate_index,
)


def _usage() -> None:
    print("reta-mojo-impact")
    print("  --summary")
    print("  --source OWNER")
    print("  --gate NAME")
    print("  --candidate NAME")


def main() raises:
    var args = argv()
    var bundle = bootstrap_architecture_impact()

    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        print(architecture_impact_count_line(bundle))
        print("snapshot_validation=" + bundle.validation.status)
        print("snapshot_passed=" + ("true" if impact_snapshot_validation_passed(bundle) else "false"))
        return

    if len(args) == 3 and String(args[1]) == "--source":
        var index = impact_source_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown impact source")
        print(bundle.impact_sources[index].source)
        print(bundle.impact_sources[index].source_kind)
        print("capsules=" + String(len(bundle.impact_sources[index].capsules)))
        print("diagrams=" + String(len(bundle.impact_sources[index].diagrams)))
        print("route_hops=" + String(len(bundle.impact_sources[index].route_hops)))
        return

    if len(args) == 3 and String(args[1]) == "--gate":
        var index = regression_gate_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown regression gate")
        print(bundle.regression_gates[index].name)
        print(bundle.regression_gates[index].status)
        print(bundle.regression_gates[index].command)
        return

    if len(args) == 3 and String(args[1]) == "--candidate":
        var index = migration_candidate_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown migration candidate")
        print(bundle.migration_candidates[index].candidate)
        print(bundle.migration_candidates[index].legacy_owner)
        print(bundle.migration_candidates[index].status)
        print("gates=" + String(len(bundle.migration_candidates[index].gates)))
        return

    _usage()
    raise Error("invalid architecture-impact arguments")
