from reta_mojo.architecture_contracts import *


def _require(condition: Bool, message: String) raises:
    if not condition:
        raise Error(message)


def main() raises:
    var bundle = bootstrap_architecture_contracts()
    _require(len(bundle.diagrams) == 33, "diagram count")
    _require(len(bundle.capsule_contracts) == 11, "capsule contract count")
    _require(len(bundle.laws) == 22, "law count")
    _require(len(bundle.validation.known_capsules) == 11, "known capsule count")
    _require(len(bundle.validation.known_categories) == 26, "known category count")
    _require(len(bundle.validation.known_functors) == 77, "known functor count")
    _require(len(bundle.validation.known_natural_transformations) == 42, "known transformation count")
    _require(contract_snapshot_validation_passed(bundle), "snapshot validation")

    var diagram_index = contract_diagram_index(bundle, "RawCommandNaturalitySquare")
    _require(diagram_index >= 0, "known diagram")
    _require(len(bundle.diagrams[diagram_index].top_path) == 2, "top path count")
    _require(len(bundle.diagrams[diagram_index].bottom_path) == 2, "bottom path count")

    var contract_index = capsule_contract_index(bundle, "CategoricalMetaCapsule")
    _require(contract_index >= 0, "known capsule contract")
    _require(bundle.capsule_contracts[contract_index].primary_category == "CommutativeArchitectureContractCategory", "primary category")

    var law_index = refactor_law_index(bundle, "ExecutionNetworkPersistenceLaw")
    _require(law_index >= 0, "known law")
    _require("validated" in bundle.laws[law_index].status, "law status")

    var line = architecture_contracts_count_line(bundle)
    _require("commutative_diagrams=33" in line, "count line diagrams")
    _require("capsule_contracts=11" in line, "count line contracts")
    _require("laws=22" in line, "count line laws")
    _require("RawCommandNaturalitySquare" in bundle.text_diagram, "text diagram")
    _require("flowchart TD" in bundle.mermaid_diagram, "mermaid diagram")
    print("architecture_contracts_probe=passed")
