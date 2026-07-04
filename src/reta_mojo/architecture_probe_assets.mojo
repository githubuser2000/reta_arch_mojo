"""Immutable generated command surfaces for architecture inspection.

The assets are generated from the Python reference by
``tools/generate_architecture_probe_assets.py``.  Installed binaries only read
UTF-8 files from the normal Reta asset root; no Python interpreter or child
process is involved.
"""


from .resource_paths import asset_resource, home_root, reference_root


def architecture_probe_asset_filename(command: String) -> String:
    if command == "snapshot-json": return "snapshot-json.json"
    if command == "schema-json": return "schema-json.json"
    if command == "module-split-json": return "module-split-json.json"
    if command == "topology-json": return "topology-json.json"
    if command == "inputs-json": return "inputs-json.json"
    if command == "word-completion-json": return "word-completion-json.json"
    if command == "nested-completion-json": return "nested-completion-json.json"
    if command == "row-ranges-json": return "row-ranges-json.json"
    if command == "arithmetic-json": return "arithmetic-json.json"
    if command == "console-io-json": return "console-io-json.json"
    if command == "column-selection-json": return "column-selection-json.json"
    if command == "parameter-runtime-json": return "parameter-runtime-json.json"
    if command == "program-workflow-json": return "program-workflow-json.json"
    if command == "table-generation-json": return "table-generation-json.json"
    if command == "table-preparation-json": return "table-preparation-json.json"
    if command == "row-filtering-json": return "row-filtering-json.json"
    if command == "table-wrapping-json": return "table-wrapping-json.json"
    if command == "table-state-json": return "table-state-json.json"
    if command == "number-theory-json": return "number-theory-json.json"
    if command == "table-output-json": return "table-output-json.json"
    if command == "table-runtime-json": return "table-runtime-json.json"
    if command == "generated-columns-json": return "generated-columns-json.json"
    if command == "meta-columns-json": return "meta-columns-json.json"
    if command == "concat-csv-json": return "concat-csv-json.json"
    if command == "combi-join-json": return "combi-join-json.json"
    if command == "prompt-runtime-json": return "prompt-runtime-json.json"
    if command == "completion-runtime-json": return "completion-runtime-json.json"
    if command == "prompt-session-json": return "prompt-session-json.json"
    if command == "prompt-execution-json": return "prompt-execution-json.json"
    if command == "prompt-preparation-json": return "prompt-preparation-json.json"
    if command == "prompt-interaction-json": return "prompt-interaction-json.json"
    if command == "output-syntax-json": return "output-syntax-json.json"
    if command == "output-json": return "output-json.json"
    if command == "prompt-language-json": return "prompt-language-json.json"
    if command == "presheaves-json": return "presheaves-json.json"
    if command == "sheaves-json": return "sheaves-json.json"
    if command == "morphisms-json": return "morphisms-json.json"
    if command == "universal-json": return "universal-json.json"
    if command == "category-theory-json": return "category-theory-json.json"
    if command == "architecture-map-json": return "architecture-map-json.json"
    if command == "architecture-contracts-json": return "architecture-contracts-json.json"
    if command == "architecture-witnesses-json": return "architecture-witnesses-json.json"
    if command == "architecture-validation-json": return "architecture-validation-json.json"
    if command == "architecture-coherence-json": return "architecture-coherence-json.json"
    if command == "architecture-traces-json": return "architecture-traces-json.json"
    if command == "architecture-boundaries-json": return "architecture-boundaries-json.json"
    if command == "architecture-impact-json": return "architecture-impact-json.json"
    if command == "architecture-migration-json": return "architecture-migration-json.json"
    if command == "architecture-rehearsal-json": return "architecture-rehearsal-json.json"
    if command == "architecture-activation-json": return "architecture-activation-json.json"
    if command == "architecture-progress-json": return "architecture-progress-json.json"
    if command == "architecture-validation-md": return "architecture-validation-md.md"
    if command == "architecture-coherence-md": return "architecture-coherence-md.md"
    if command == "architecture-traces-md": return "architecture-traces-md.md"
    if command == "architecture-boundaries-md": return "architecture-boundaries-md.md"
    if command == "architecture-impact-md": return "architecture-impact-md.md"
    if command == "architecture-migration-md": return "architecture-migration-md.md"
    if command == "architecture-rehearsal-md": return "architecture-rehearsal-md.md"
    if command == "architecture-activation-md": return "architecture-activation-md.md"
    if command == "architecture-progress-md": return "architecture-progress-md.md"
    if command == "architecture-witnesses-md": return "architecture-witnesses-md.md"
    if command == "architecture-contracts-md": return "architecture-contracts-md.md"
    if command == "architecture-diagram-md": return "architecture-diagram-md.md"
    return ""


def architecture_probe_command_count() -> Int:
    return 63


def load_architecture_probe_asset(command: String) raises -> String:
    var filename = architecture_probe_asset_filename(command)
    if filename.byte_length() == 0:
        raise Error("unknown generated architecture probe command: " + command)
    var file = open(asset_resource("architecture_probe/" + filename), "r")
    var payload = file.read()
    file.close()
    return payload.replace("@@RETA_REFERENCE_ROOT@@", reference_root()).replace("@@RETA_HOME@@", home_root())


def load_architecture_snapshot_json() raises -> String:
    return load_architecture_probe_asset("snapshot-json")
