"""Native summary and indexed lookup surface for architecture witnesses."""

from std.sys import argv
from reta_mojo.architecture_witnesses import (
    anchor_witness_index,
    architecture_witnesses_count_line,
    bootstrap_architecture_witnesses,
    capsule_slice_index,
    diagram_witness_index,
    naturality_witness_index,
    refactor_obligation_index,
    witness_validation_passed,
)


def _print_usage() -> None:
    print("reta-mojo-witnesses")
    print("  --summary")
    print("  --anchor OWNER ANCHOR")
    print("  --capsule NAME")
    print("  --diagram NAME")
    print("  --transformation NAME")
    print("  --obligation NAME")


def main() raises:
    var args = argv()
    var witnesses = bootstrap_architecture_witnesses()

    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        print(architecture_witnesses_count_line(witnesses))
        print("validation=" + witnesses.validation.status)
        print("passed=" + ("true" if witness_validation_passed(witnesses) else "false"))
        print("file_like=" + String(witnesses.validation.file_like_anchor_count))
        print("symbolic=" + String(witnesses.validation.symbolic_anchor_count))
        return

    if len(args) == 4 and String(args[1]) == "--anchor":
        var index = anchor_witness_index(witnesses, String(args[2]), String(args[3]))
        if index < 0:
            raise Error("unknown owner/anchor witness")
        print(witnesses.anchor_witnesses[index].owner)
        print(witnesses.anchor_witnesses[index].anchor)
        print(witnesses.anchor_witnesses[index].status)
        print("matched_paths=" + String(len(witnesses.anchor_witnesses[index].matched_paths)))
        return

    if len(args) == 3 and String(args[1]) == "--capsule":
        var index = capsule_slice_index(witnesses, String(args[2]))
        if index < 0:
            raise Error("unknown capsule witness slice")
        print(witnesses.capsule_slices[index].capsule)
        print(witnesses.capsule_slices[index].anchor_status)
        print("owners=" + String(len(witnesses.capsule_slices[index].new_owners)))
        print("sections=" + String(len(witnesses.capsule_slices[index].contained_sections)))
        return

    if len(args) == 3 and String(args[1]) == "--diagram":
        var index = diagram_witness_index(witnesses, String(args[2]))
        if index < 0:
            raise Error("unknown diagram witness")
        print(witnesses.diagram_witnesses[index].diagram)
        print(witnesses.diagram_witnesses[index].witness_status)
        print("anchors=" + String(len(witnesses.diagram_witnesses[index].implementation_anchors)))
        return

    if len(args) == 3 and String(args[1]) == "--transformation":
        var index = naturality_witness_index(witnesses, String(args[2]))
        if index < 0:
            raise Error("unknown naturality witness")
        print(witnesses.naturality_witnesses[index].transformation)
        print(witnesses.naturality_witnesses[index].witness_status)
        print("components=" + String(len(witnesses.naturality_witnesses[index].component_anchors)))
        return

    if len(args) == 3 and String(args[1]) == "--obligation":
        var index = refactor_obligation_index(witnesses, String(args[2]))
        if index < 0:
            raise Error("unknown refactor obligation")
        print(witnesses.obligations[index].name)
        print(witnesses.obligations[index].status)
        print("diagrams=" + String(len(witnesses.obligations[index].witness_diagrams)))
        return

    _print_usage()
    raise Error("invalid architecture-witness arguments")
