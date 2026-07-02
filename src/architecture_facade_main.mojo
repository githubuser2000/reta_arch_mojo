"""Native query CLI for the RetaArchitecture composition graph."""

from std.sys import argv
from reta_mojo.architecture_facade import *


def _usage() -> None:
    print("reta-mojo-facade")
    print("  --summary")
    print("  --field NAME")
    print("  --method NAME")
    print("  --dependencies METHOD")
    print("  --kind field|method|bootstrap|snapshot")
    print("  --dump")


def _print_summary(catalog: ArchitectureFacadeCatalog) -> None:
    var snapshot = architecture_facade_snapshot(catalog)
    print("fields=" + String(snapshot.fields))
    print("methods=" + String(snapshot.methods))
    print("bootstrap_steps=" + String(snapshot.bootstrap_steps))
    print("snapshot_entries=" + String(snapshot.snapshot_entries))
    print("force_rebuild_methods=" + String(snapshot.force_rebuild_methods))
    print("dependency_edges=" + String(snapshot.dependency_edges))
    print(
        "valid="
        + ("true" if architecture_facade_catalog_valid(catalog) else "false")
    )


def main() raises:
    var args = argv()
    var catalog = load_architecture_facade_catalog()
    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        _print_summary(catalog)
        return
    if len(args) == 3 and String(args[1]) == "--field":
        print(
            render_architecture_facade_entry(
                architecture_facade_entry(catalog, "field", String(args[2]))
            )
        )
        return
    if len(args) == 3 and String(args[1]) == "--method":
        print(
            render_architecture_facade_entry(
                architecture_facade_entry(catalog, "method", String(args[2]))
            )
        )
        return
    if len(args) == 3 and String(args[1]) == "--dependencies":
        var dependencies = architecture_facade_dependencies(
            catalog, String(args[2])
        )
        for index in range(len(dependencies)):
            print(dependencies[index])
        return
    if len(args) == 3 and String(args[1]) == "--kind":
        print(
            render_architecture_facade_catalog(catalog, String(args[2])),
            end="",
        )
        return
    if len(args) == 2 and String(args[1]) == "--dump":
        print(render_architecture_facade_catalog(catalog), end="")
        return
    _usage()
    raise Error("invalid architecture-facade arguments")
