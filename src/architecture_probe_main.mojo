"""Native generated replacement for ``reta_architecture_probe_py.py``."""

from std.sys import argv

from reta_mojo.architecture_probe_assets import (
    architecture_probe_asset_filename,
    load_architecture_probe_asset,
)
from reta_mojo.package_integrity import default_repo_manifest, repo_manifest_json
from reta_mojo.resource_paths import reference_root


def _help(program_name: String) -> None:
    print(program_name + " - Architektur-Inspektion für reta")
    print("")
    print("Aufruf:")
    print("  " + program_name + " snapshot-json")
    print("  " + program_name + " schema-json")
    print("  " + program_name + " module-split-json")
    print("  " + program_name + " topology-json")
    print("  " + program_name + " inputs-json")
    print("  " + program_name + " word-completion-json")
    print("  " + program_name + " nested-completion-json")
    print("  " + program_name + " row-ranges-json")
    print("  " + program_name + " arithmetic-json")
    print("  " + program_name + " console-io-json")
    print("  " + program_name + " column-selection-json")
    print("  " + program_name + " parameter-runtime-json")
    print("  " + program_name + " program-workflow-json")
    print("  " + program_name + " table-generation-json")
    print("  " + program_name + " table-preparation-json")
    print("  " + program_name + " row-filtering-json")
    print("  " + program_name + " table-wrapping-json")
    print("  " + program_name + " table-state-json")
    print("  " + program_name + " number-theory-json")
    print("  " + program_name + " table-output-json")
    print("  " + program_name + " table-runtime-json")
    print("  " + program_name + " generated-columns-json")
    print("  " + program_name + " meta-columns-json")
    print("  " + program_name + " concat-csv-json")
    print("  " + program_name + " combi-join-json")
    print("  " + program_name + " prompt-runtime-json")
    print("  " + program_name + " prompt-session-json")
    print("  " + program_name + " prompt-execution-json")
    print("  " + program_name + " prompt-preparation-json")
    print("  " + program_name + " prompt-interaction-json")
    print("  " + program_name + " package-integrity-json")
    print("  " + program_name + " completion-runtime-json")
    print("  " + program_name + " output-syntax-json")
    print("  " + program_name + " output-json")
    print("  " + program_name + " prompt-language-json")
    print("  " + program_name + " presheaves-json")
    print("  " + program_name + " sheaves-json")
    print("  " + program_name + " morphisms-json")
    print("  " + program_name + " universal-json")
    print("  " + program_name + " category-theory-json")
    print("  " + program_name + " architecture-map-json")
    print("  " + program_name + " architecture-diagram-md")
    print("  " + program_name + " architecture-contracts-json")
    print("  " + program_name + " architecture-contracts-md")
    print("  " + program_name + " architecture-witnesses-json")
    print("  " + program_name + " architecture-witnesses-md")
    print("  " + program_name + " architecture-validation-json")
    print("  " + program_name + " architecture-validation-md")
    print("  " + program_name + " architecture-coherence-json")
    print("  " + program_name + " architecture-coherence-md")
    print("  " + program_name + " architecture-traces-json")
    print("  " + program_name + " architecture-traces-md")
    print("  " + program_name + " architecture-boundaries-json")
    print("  " + program_name + " architecture-boundaries-md")
    print("  " + program_name + " architecture-impact-json")
    print("  " + program_name + " architecture-impact-md")
    print("  " + program_name + " architecture-migration-json")
    print("  " + program_name + " architecture-migration-md")
    print("  " + program_name + " architecture-rehearsal-json")
    print("  " + program_name + " architecture-rehearsal-md")
    print("  " + program_name + " architecture-activation-json")
    print("  " + program_name + " architecture-activation-md")
    print("  " + program_name + " architecture-progress-json")
    print("  " + program_name + " architecture-progress-md")


def main() raises:
    var args = argv()
    var program_name = "reta-mojo-architecture-probe"
    if len(args) <= 1 or String(args[1]) == "-h" or String(args[1]) == "--help" or String(args[1]) == "help":
        _help(program_name)
        return
    if len(args) != 2:
        raise Error("architecture probe commands accept no additional arguments")

    var command = String(args[1])
    if command == "package-integrity-json":
        print(repo_manifest_json(default_repo_manifest(reference_root())))
        return

    if architecture_probe_asset_filename(command).byte_length() == 0:
        raise Error("Unbekannter Befehl: " + command)
    print(load_architecture_probe_asset(command), end="")
