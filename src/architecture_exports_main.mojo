"""Query CLI for the native reta_architecture export catalogue."""

from std.sys import argv
from reta_mojo.architecture_exports import *


def _usage() -> None:
    print("reta-mojo-exports")
    print("  --summary")
    print("  --symbol PUBLIC_NAME")
    print("  --module MODULE [--public]")
    print("  --public")
    print("  --dump")


def _print_summary(catalog: ArchitectureExportCatalog) -> None:
    var snapshot = architecture_export_snapshot(catalog)
    print("imports=" + String(snapshot.imports))
    print("public_exports=" + String(snapshot.public_exports))
    print("private_imports=" + String(snapshot.private_imports))
    print("modules=" + String(snapshot.modules))


def main() raises:
    var args = argv()
    var catalog = load_architecture_export_catalog()
    if len(args) == 1 or String(args[1]) == "--summary":
        _print_summary(catalog)
        return
    var command = String(args[1])
    if command == "--symbol" and len(args) == 3:
        print(render_architecture_export(architecture_export(catalog, String(args[2]))))
        return
    if command == "--module" and (len(args) == 3 or len(args) == 4):
        var public_only = len(args) == 4 and String(args[3]) == "--public"
        var entries = architecture_exports_for_module(
            catalog, String(args[2]), public_only
        )
        for index in range(len(entries)):
            print(render_architecture_export(entries[index]))
        return
    if command == "--public" and len(args) == 2:
        print(render_architecture_export_catalog(catalog, True), end="")
        return
    if command == "--dump" and len(args) == 2:
        print(render_architecture_export_catalog(catalog), end="")
        return
    _usage()
    raise Error("invalid architecture export arguments")
