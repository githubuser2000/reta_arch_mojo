"""Native query surface for generated commutative architecture contracts."""

from std.sys import argv
from reta_mojo.architecture_contracts import (
    architecture_contracts_count_line,
    bootstrap_architecture_contracts,
    capsule_contract_index,
    contract_diagram_index,
    contract_snapshot_validation_passed,
    refactor_law_index,
)


def _print_usage() -> None:
    print("reta-mojo-contracts")
    print("  --summary")
    print("  --diagram NAME")
    print("  --capsule NAME")
    print("  --law NAME")
    print("  --render text|mermaid")


def main() raises:
    var args = argv()
    var contracts = bootstrap_architecture_contracts()

    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        print(architecture_contracts_count_line(contracts))
        print("snapshot_validation=" + contracts.validation.status)
        print("snapshot_passed=" + ("true" if contract_snapshot_validation_passed(contracts) else "false"))
        return

    if len(args) == 3 and String(args[1]) == "--diagram":
        var name = String(args[2])
        var index = contract_diagram_index(contracts, name)
        if index < 0:
            raise Error("unknown commutative diagram: " + name)
        var diagram = contracts.diagrams[index].copy()
        print(diagram.name + "\t" + diagram.diagram_type + "\t" + diagram.stage_origin)
        print("nodes=" + String(len(diagram.nodes)) + " top_path=" + String(len(diagram.top_path)) + " bottom_path=" + String(len(diagram.bottom_path)))
        print("equality=" + diagram.equality)
        print(diagram.description)
        return

    if len(args) == 3 and String(args[1]) == "--capsule":
        var name = String(args[2])
        var index = capsule_contract_index(contracts, name)
        if index < 0:
            raise Error("unknown capsule contract: " + name)
        var contract = contracts.capsule_contracts[index].copy()
        print(contract.capsule + "\t" + contract.stage_span)
        print("primary_category=" + contract.primary_category)
        print("primary_functor_or_transformation=" + contract.primary_functor_or_transformation)
        print("owns=" + String(len(contract.owns)) + " accepts=" + String(len(contract.accepts)) + " produces=" + String(len(contract.produces)) + " must_not_own=" + String(len(contract.must_not_own)))
        print(contract.description)
        return

    if len(args) == 3 and String(args[1]) == "--law":
        var name = String(args[2])
        var index = refactor_law_index(contracts, name)
        if index < 0:
            raise Error("unknown refactor law: " + name)
        var law = contracts.laws[index].copy()
        print(law.name + "\t" + law.law_type + "\t" + law.status)
        print("mathematical=" + law.mathematical_reading)
        print("reta=" + law.reta_reading)
        return

    if len(args) == 3 and String(args[1]) == "--render":
        var kind = String(args[2])
        if kind == "text":
            print(contracts.text_diagram, end="")
            return
        if kind == "mermaid":
            print(contracts.mermaid_diagram, end="")
            return
        raise Error("render must be text or mermaid")

    _print_usage()
    raise Error("invalid architecture-contract arguments")
