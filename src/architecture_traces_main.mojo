"""Native query surface for generated Stage-32 architecture traces."""

from std.sys import argv
from reta_mojo.architecture_traces import (
    architecture_trace_count_line,
    bootstrap_architecture_traces,
    capsule_trace_index,
    component_trace_index,
    stage_trace_index,
    trace_route_hop_count,
    trace_snapshot_validation_passed,
)


def _usage() -> None:
    print("reta-mojo-traces")
    print("  --summary")
    print("  --component LEGACY_OWNER")
    print("  --capsule NAME")
    print("  --stage NAME")
    print("  --render text|mermaid")


def main() raises:
    var args = argv()
    var bundle = bootstrap_architecture_traces()

    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        print(architecture_trace_count_line(bundle))
        print("snapshot_validation=" + bundle.validation.status)
        print("snapshot_passed=" + ("true" if trace_snapshot_validation_passed(bundle) else "false"))
        return

    if len(args) == 3 and String(args[1]) == "--component":
        var owner = String(args[2])
        var index = component_trace_index(bundle, owner)
        if index < 0:
            raise Error("unknown component trace: " + owner)
        var item = bundle.component_traces[index].copy()
        print(item.legacy_owner)
        print("capsules=" + String(len(item.primary_capsules)) + " categories=" + String(len(item.categories)) + " functors=" + String(len(item.functors)))
        print("transformations=" + String(len(item.natural_transformations)) + " diagrams=" + String(len(item.diagrams)) + " witnesses=" + String(len(item.witnesses)) + " laws=" + String(len(item.laws)))
        print("route_hops=" + String(len(item.route)))
        for hop_index in range(len(item.route)):
            var hop = item.route[hop_index].copy()
            print(hop.source + " -> " + hop.target + "\t" + hop.relation + "\t" + hop.categorical_kind)
        print(item.reading)
        return

    if len(args) == 3 and String(args[1]) == "--capsule":
        var name = String(args[2])
        var index = capsule_trace_index(bundle, name)
        if index < 0:
            raise Error("unknown capsule trace: " + name)
        var item = bundle.capsule_traces[index].copy()
        print(item.capsule + "\t" + item.category)
        print("functors=" + String(len(item.functors)) + " transformations=" + String(len(item.natural_transformations)) + " diagrams=" + String(len(item.diagrams)) + " laws=" + String(len(item.laws)))
        print("witnesses=" + String(len(item.witnesses)) + " code_owners=" + String(len(item.code_owners)))
        print(item.reading)
        return

    if len(args) == 3 and String(args[1]) == "--stage":
        var name = String(args[2])
        var index = stage_trace_index(bundle, name)
        if index < 0:
            raise Error("unknown architecture stage trace: " + name)
        var item = bundle.stage_traces[index].copy()
        print(item.stage + "\t" + item.capsule + "\t" + item.trace_target)
        print("moved_to=" + String(len(item.moved_to)) + " paradigms=" + String(len(item.paradigms)))
        return

    if len(args) == 3 and String(args[1]) == "--render":
        var kind = String(args[2])
        if kind == "text":
            print(bundle.text_diagram, end="")
            return
        if kind == "mermaid":
            print(bundle.mermaid_diagram, end="")
            return
        raise Error("render must be text or mermaid")

    _usage()
    raise Error("invalid architecture-trace arguments")
