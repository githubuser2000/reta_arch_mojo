"""Native catalogue for the ``reta_architecture`` package export facade.

``reta_architecture/__init__.py`` owns no algorithms.  Its observable contract
is the binding between 314 imported symbols and the ordered 232-name
``__all__`` surface.  The source TSV is generated from the frozen Python AST;
runtime lookup is pure Mojo and does not import Python.
"""

from std.collections import List
from std.collections.string import atol
from .csv_table import read_text_file
from .resource_paths import asset_resource


@fieldwise_init
struct ArchitectureExportSpec(Copyable):
    var all_ordinal: Int
    var import_ordinal: Int
    var module: String
    var imported_name: String
    var public_name: String
    var is_public: Bool


@fieldwise_init
struct ArchitectureExportCatalog(Copyable):
    var entries: List[ArchitectureExportSpec]


@fieldwise_init
struct ArchitectureExportSnapshot(Copyable):
    var imports: Int
    var public_exports: Int
    var private_imports: Int
    var modules: Int


def load_architecture_export_catalog(
    path: String = "",
) raises -> ArchitectureExportCatalog:
    var entries = List[ArchitectureExportSpec]()
    var source_path = (
        path
        if path.byte_length() > 0
        else asset_resource("architecture_exports.tsv")
    )
    var lines = read_text_file(source_path).split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0 or line.startswith("#"):
            continue
        var fields = line.split("\t")
        if len(fields) != 6:
            raise Error(
                "invalid architecture export row " + String(line_index + 1)
            )
        entries.append(
            ArchitectureExportSpec(
                atol(String(fields[0])),
                atol(String(fields[1])),
                String(fields[2]),
                String(fields[3]),
                String(fields[4]),
                String(fields[5]) == "1",
            )
        )
    return ArchitectureExportCatalog(entries^)


def architecture_export_index(
    catalog: ArchitectureExportCatalog, public_name: String
) -> Int:
    for index in range(len(catalog.entries)):
        if catalog.entries[index].public_name == public_name:
            return index
    return -1


def architecture_export(
    catalog: ArchitectureExportCatalog, public_name: String
) raises -> ArchitectureExportSpec:
    var index = architecture_export_index(catalog, public_name)
    if index < 0:
        raise Error("unknown reta_architecture export: " + public_name)
    return catalog.entries[index].copy()


def architecture_exports_for_module(
    catalog: ArchitectureExportCatalog,
    module: String,
    public_only: Bool = False,
) -> List[ArchitectureExportSpec]:
    var result = List[ArchitectureExportSpec]()
    for index in range(len(catalog.entries)):
        var entry = catalog.entries[index].copy()
        if entry.module == module and (entry.is_public or not public_only):
            result.append(entry^)
    return result^


def architecture_public_exports(
    catalog: ArchitectureExportCatalog,
) -> List[ArchitectureExportSpec]:
    # The generator emits public rows first in exact __all__ order.
    var result = List[ArchitectureExportSpec]()
    for index in range(len(catalog.entries)):
        if catalog.entries[index].is_public:
            result.append(catalog.entries[index].copy())
    return result^


def _contains_export_module(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def architecture_export_snapshot(
    catalog: ArchitectureExportCatalog,
) -> ArchitectureExportSnapshot:
    var public_exports = 0
    var modules = List[String]()
    for index in range(len(catalog.entries)):
        var entry = catalog.entries[index].copy()
        if entry.is_public:
            public_exports += 1
        if not _contains_export_module(modules, entry.module):
            modules.append(entry.module)
    return ArchitectureExportSnapshot(
        len(catalog.entries),
        public_exports,
        len(catalog.entries) - public_exports,
        len(modules),
    )


def render_architecture_export(entry: ArchitectureExportSpec) -> String:
    return (
        String(entry.all_ordinal)
        + "\t"
        + String(entry.import_ordinal)
        + "\t"
        + entry.module
        + "\t"
        + entry.imported_name
        + "\t"
        + entry.public_name
        + "\t"
        + ("public" if entry.is_public else "private")
    )


def render_architecture_export_catalog(
    catalog: ArchitectureExportCatalog, public_only: Bool = False
) -> String:
    var result = String()
    for index in range(len(catalog.entries)):
        var entry = catalog.entries[index].copy()
        if public_only and not entry.is_public:
            continue
        result += render_architecture_export(entry) + "\n"
    return result^
