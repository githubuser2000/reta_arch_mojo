from reta_mojo.architecture_witnesses import *


def _require(condition: Bool, message: String) raises:
    if not condition:
        raise Error(message)


def main() raises:
    var bundle = bootstrap_architecture_witnesses()
    _require(len(bundle.anchor_witnesses) == 536, "anchor witness count")
    _require(len(bundle.capsule_slices) == 11, "capsule slice count")
    _require(len(bundle.diagram_witnesses) == 33, "diagram witness count")
    _require(len(bundle.naturality_witnesses) == 42, "naturality witness count")
    _require(len(bundle.obligations) == 55, "obligation count")
    _require(bundle.validation.file_like_anchor_count == 351, "file-like anchor count")
    _require(bundle.validation.resolved_anchor_count == 351, "resolved anchor count")
    _require(bundle.validation.symbolic_anchor_count == 185, "symbolic anchor count")
    _require(witness_validation_passed(bundle), "witness validation")

    var anchor_index = anchor_witness_index(bundle, "RetaArchitectureRoot", "reta_architecture/facade.py")
    _require(anchor_index >= 0, "known anchor")
    _require(bundle.anchor_witnesses[anchor_index].status == "resolved", "anchor status")
    _require(len(bundle.anchor_witnesses[anchor_index].matched_paths) == 1, "anchor path count")

    var capsule_index = capsule_slice_index(bundle, "CategoricalMetaCapsule")
    _require(capsule_index >= 0, "known capsule slice")
    _require(bundle.capsule_slices[capsule_index].anchor_status == "resolved", "capsule anchor status")

    var diagram_index = diagram_witness_index(bundle, "RawCommandNaturalitySquare")
    _require(diagram_index >= 0, "known diagram witness")
    _require(bundle.diagram_witnesses[diagram_index].witness_status == "witnessed", "diagram witness status")

    var naturality_index = naturality_witness_index(bundle, "RawToCanonicalParameterTransformation")
    _require(naturality_index >= 0, "known naturality witness")
    _require(len(bundle.naturality_witnesses[naturality_index].component_anchors) == 3, "naturality components")

    var obligation_index = refactor_obligation_index(bundle, "ExecutionNetworkPersistenceLaw")
    _require(obligation_index >= 0, "known obligation")
    _require(bundle.obligations[obligation_index].status == "witnessed", "obligation status")

    var line = architecture_witnesses_count_line(bundle)
    _require("anchor_witnesses=536" in line, "count line anchors")
    _require("resolved_anchors=351" in line, "count line resolved")
    _require("ArchitectureWitnessBundle" in bundle.text_diagram, "text diagram")
    _require("flowchart" in bundle.mermaid_diagram, "mermaid diagram")
    print("architecture_witnesses_probe=passed")
