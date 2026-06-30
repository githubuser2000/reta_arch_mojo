"""Native query surface for the generated Stage-31 coherence matrix."""

from std.sys import argv
from reta_mojo.architecture_coherence import (
    architecture_coherence_count_line,
    bootstrap_architecture_coherence,
    coherent_capsule_index,
    coherence_snapshot_validation_passed,
    functorial_route_index,
    law_coherence_index,
    naturality_coherence_index,
)


def _usage() -> None:
    print("reta-mojo-coherence")
    print("  --summary")
    print("  --capsule NAME")
    print("  --route SOURCE TARGET [FUNCTOR_OR_TRANSFORMATION]")
    print("  --transformation NAME")
    print("  --law NAME")
    print("  --render text|mermaid")


def main() raises:
    var args = argv()
    var bundle = bootstrap_architecture_coherence()

    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        print(architecture_coherence_count_line(bundle))
        print("snapshot_validation=" + bundle.validation.status)
        print("snapshot_passed=" + ("true" if coherence_snapshot_validation_passed(bundle) else "false"))
        return

    if len(args) == 3 and String(args[1]) == "--capsule":
        var name = String(args[2])
        var index = coherent_capsule_index(bundle, name)
        if index < 0:
            raise Error("unknown coherent capsule: " + name)
        var item = bundle.capsule_coherence[index].copy()
        print(item.capsule + "\t" + item.category + "\t" + item.stage_span)
        print("functors=" + String(len(item.functors)) + " transformations=" + String(len(item.natural_transformations)) + " diagrams=" + String(len(item.diagrams)) + " laws=" + String(len(item.laws)))
        print("witness_slice=" + item.witness_slice)
        print(item.coherence_reading)
        return

    if (len(args) == 4 or len(args) == 5) and String(args[1]) == "--route":
        var source = String(args[2])
        var target = String(args[3])
        var name = ""
        if len(args) == 5:
            name = String(args[4])
        var index = functorial_route_index(bundle, source, target, name)
        if index < 0:
            raise Error("unknown coherent route: " + source + " -> " + target)
        var item = bundle.functorial_routes[index].copy()
        print(item.source_capsule + "\t" + item.target_capsule + "\t" + item.categorical_kind)
        print("morphism=" + item.morphism)
        print("functor_or_transformation=" + item.functor_or_transformation)
        print("status=" + item.status + " contract_diagrams=" + String(len(item.contract_diagrams)) + " witness_diagrams=" + String(len(item.witness_diagrams)))
        print(item.reading)
        return

    if len(args) == 3 and String(args[1]) == "--transformation":
        var name = String(args[2])
        var index = naturality_coherence_index(bundle, name)
        if index < 0:
            raise Error("unknown coherent natural transformation: " + name)
        var item = bundle.naturality_coherence[index].copy()
        print(item.transformation + "\t" + item.status + "\t" + item.witness_status)
        print("source_functor=" + item.source_functor)
        print("target_functor=" + item.target_functor)
        print("components=" + String(item.component_count) + " diagrams=" + String(len(item.diagrams)) + " capsules=" + String(len(item.capsules)))
        print(item.naturality_condition)
        return

    if len(args) == 3 and String(args[1]) == "--law":
        var name = String(args[2])
        var index = law_coherence_index(bundle, name)
        if index < 0:
            raise Error("unknown coherent refactor law: " + name)
        var item = bundle.law_coherence[index].copy()
        print(item.law + "\t" + item.status)
        print("obligation_present=" + ("true" if item.obligation_present else "false"))
        print("protected_capsules=" + String(len(item.protected_capsules)) + " diagrams=" + String(len(item.diagrams)))
        print(item.reading)
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
    raise Error("invalid architecture-coherence arguments")
