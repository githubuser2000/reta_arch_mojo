"""Native query surface for the generated architecture map and boundary graph."""

from std.sys import argv
from reta_mojo.architecture_map import (
    architecture_map_count_line,
    bootstrap_architecture_map,
    capsule_index,
)
from reta_mojo.architecture_boundaries import (
    architecture_boundaries_count_line,
    bootstrap_architecture_boundaries,
    boundary_validation_passed,
    capsule_boundary_index,
    ownership_index,
)


def _print_usage() -> None:
    print("reta-mojo-boundaries")
    print("  --summary")
    print("  --module PFAD")
    print("  --capsule NAME")
    print("  --diagram text|mermaid")


def main() raises:
    var args = argv()
    var architecture_map = bootstrap_architecture_map()
    var boundaries = bootstrap_architecture_boundaries()

    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        print(architecture_map_count_line(architecture_map))
        print(architecture_boundaries_count_line(boundaries))
        print("validation=" + boundaries.validation.status)
        print("passed=" + ("true" if boundary_validation_passed(boundaries) else "false"))
        return

    if len(args) == 3 and String(args[1]) == "--module":
        var path = String(args[2])
        var index = ownership_index(boundaries, path)
        if index < 0:
            raise Error("unknown architecture-owned path: " + path)
        var owner = boundaries.module_ownership[index].copy()
        print(owner.path + "\t" + owner.capsule + "\t" + owner.owner_kind)
        print(owner.reason)
        return

    if len(args) == 3 and String(args[1]) == "--capsule":
        var name = String(args[2])
        var map_index = capsule_index(architecture_map, name)
        var boundary_index = capsule_boundary_index(boundaries, name)
        if map_index < 0 or boundary_index < 0:
            raise Error("unknown architecture capsule: " + name)
        var capsule = architecture_map.capsules[map_index].copy()
        var boundary = boundaries.capsule_boundaries[boundary_index].copy()
        print(capsule.name + "\t" + capsule.layer)
        print("modules=" + String(len(boundary.owns_modules)))
        print("outbound=" + String(len(boundary.allowed_outbound_capsules)))
        print("inbound=" + String(len(boundary.inbound_capsules)))
        print(boundary.boundary_reading)
        return

    if len(args) == 3 and String(args[1]) == "--diagram":
        var kind = String(args[2])
        if kind == "text":
            print(boundaries.text_diagram, end="")
            return
        if kind == "mermaid":
            print(boundaries.mermaid_diagram, end="")
            return
        raise Error("diagram must be text or mermaid")

    _print_usage()
    raise Error("invalid architecture-boundary arguments")
