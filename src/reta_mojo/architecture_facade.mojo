"""Typed native contract for the ``RetaArchitecture`` composition facade.

The Python object aggregates heterogeneous bundles, some of which still have a
reference-only owner.  This module therefore owns the static and observable
composition graph first: fields, method surface, bootstrap order, rebuild
edges and snapshot order.  It never imports Python and can be queried at
runtime by native diagnostics and migration tooling.
"""

from std.collections import List
from std.collections.string import atol
from .csv_table import read_text_file
from .resource_paths import asset_resource
from .os_line_endings import os_linesep, split_os_lines


@fieldwise_init
struct ArchitectureFacadeEntry(Copyable):
    var kind: String
    var ordinal: Int
    var name: String
    var value: String
    var extra: String


@fieldwise_init
struct ArchitectureFacadeCatalog(Copyable):
    var entries: List[ArchitectureFacadeEntry]


@fieldwise_init
struct ArchitectureFacadeSnapshot(Copyable):
    var fields: Int
    var methods: Int
    var bootstrap_steps: Int
    var snapshot_entries: Int
    var force_rebuild_methods: Int
    var dependency_edges: Int


def load_architecture_facade_catalog(
    path: String = "",
) raises -> ArchitectureFacadeCatalog:
    var source_path = (
        path
        if path.byte_length() > 0
        else asset_resource("architecture_facade.tsv")
    )
    var entries = List[ArchitectureFacadeEntry]()
    var lines = split_os_lines(read_text_file(source_path))
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0 or line.startswith("#"):
            continue
        var fields = line.split("\t")
        if len(fields) != 5:
            raise Error(
                "invalid architecture facade row " + String(line_index + 1)
            )
        entries.append(
            ArchitectureFacadeEntry(
                String(fields[0]),
                atol(String(fields[1])),
                String(fields[2]),
                String(fields[3]),
                String(fields[4]),
            )
        )
    return ArchitectureFacadeCatalog(entries^)


def architecture_facade_entry_index(
    catalog: ArchitectureFacadeCatalog, kind: String, name: String
) -> Int:
    for index in range(len(catalog.entries)):
        if (
            catalog.entries[index].kind == kind
            and catalog.entries[index].name == name
        ):
            return index
    return -1


def architecture_facade_entry(
    catalog: ArchitectureFacadeCatalog, kind: String, name: String
) raises -> ArchitectureFacadeEntry:
    var index = architecture_facade_entry_index(catalog, kind, name)
    if index < 0:
        raise Error("unknown architecture facade entry: " + kind + "/" + name)
    return catalog.entries[index].copy()


def architecture_facade_entries_for_kind(
    catalog: ArchitectureFacadeCatalog, kind: String
) -> List[ArchitectureFacadeEntry]:
    var result = List[ArchitectureFacadeEntry]()
    for index in range(len(catalog.entries)):
        var entry = catalog.entries[index].copy()
        if entry.kind == kind:
            result.append(entry^)
    return result^


def architecture_facade_dependencies(
    catalog: ArchitectureFacadeCatalog, method_name: String
) raises -> List[String]:
    var entry = architecture_facade_entry(catalog, "method", method_name)
    var result = List[String]()
    if entry.extra == "-":
        return result^
    var values = entry.extra.split(",")
    for index in range(len(values)):
        result.append(String(values[index]))
    return result^


def _architecture_facade_name_exists(
    catalog: ArchitectureFacadeCatalog, kind: String, name: String
) -> Bool:
    return architecture_facade_entry_index(catalog, kind, name) >= 0


def _architecture_facade_dependency_count(extra: String) -> Int:
    if extra == "-":
        return 0
    return len(extra.split(","))


def architecture_facade_snapshot(
    catalog: ArchitectureFacadeCatalog,
) -> ArchitectureFacadeSnapshot:
    var fields = 0
    var methods = 0
    var bootstrap_steps = 0
    var snapshot_entries = 0
    var force_rebuild_methods = 0
    var dependency_edges = 0
    for index in range(len(catalog.entries)):
        var entry = catalog.entries[index].copy()
        if entry.kind == "field":
            fields += 1
        elif entry.kind == "method":
            methods += 1
            if entry.value == "1":
                force_rebuild_methods += 1
            dependency_edges += _architecture_facade_dependency_count(entry.extra)
        elif entry.kind == "bootstrap":
            bootstrap_steps += 1
        elif entry.kind == "snapshot":
            snapshot_entries += 1
    return ArchitectureFacadeSnapshot(
        fields,
        methods,
        bootstrap_steps,
        snapshot_entries,
        force_rebuild_methods,
        dependency_edges,
    )


def _architecture_facade_duplicate_before(
    catalog: ArchitectureFacadeCatalog, entry_index: Int
) -> Bool:
    for index in range(entry_index):
        if (
            catalog.entries[index].kind == catalog.entries[entry_index].kind
            and catalog.entries[index].name == catalog.entries[entry_index].name
        ):
            return True
    return False


def architecture_facade_catalog_valid(
    catalog: ArchitectureFacadeCatalog,
) -> Bool:
    var snapshot = architecture_facade_snapshot(catalog)
    if (
        snapshot.fields != 45
        or snapshot.methods != 49
        or snapshot.bootstrap_steps != 45
        or snapshot.snapshot_entries != 48
        or snapshot.force_rebuild_methods != 44
        or snapshot.dependency_edges != 98
    ):
        return False

    var next_field = 0
    var next_method = 0
    var next_bootstrap = 0
    var next_snapshot = 0
    for index in range(len(catalog.entries)):
        var entry = catalog.entries[index].copy()
        if entry.ordinal < 0 or entry.name.byte_length() == 0:
            return False
        if _architecture_facade_duplicate_before(catalog, index):
            return False
        if entry.kind == "field":
            if entry.ordinal != next_field:
                return False
            next_field += 1
        elif entry.kind == "method":
            if entry.ordinal != next_method:
                return False
            next_method += 1
        elif entry.kind == "bootstrap":
            if entry.ordinal != next_bootstrap:
                return False
            next_bootstrap += 1
        elif entry.kind == "snapshot":
            if entry.ordinal != next_snapshot:
                return False
            next_snapshot += 1
        if entry.kind == "field":
            if not _architecture_facade_name_exists(
                catalog, "bootstrap", entry.name
            ):
                return False
        elif entry.kind == "bootstrap":
            if not _architecture_facade_name_exists(catalog, "field", entry.name):
                return False
        elif entry.kind == "method" and entry.extra != "-":
            var dependencies = entry.extra.split(",")
            for dependency_index in range(len(dependencies)):
                if not _architecture_facade_name_exists(
                    catalog, "method", String(dependencies[dependency_index])
                ):
                    return False
        elif (
            entry.kind != "snapshot"
            and entry.kind != "field"
            and entry.kind != "bootstrap"
            and entry.kind != "method"
        ):
            return False
    return True


@fieldwise_init
struct ArchitectureFacadeNativeCompletionPlan(Copyable):
    """Native completion witness for the RetaArchitecture facade.

    The facade owns the observable composition contract itself: ordered fields,
    ordered bootstrap assignments, rebuild method graph and snapshot surface.
    Child bundles keep their own porting status, but the facade file no longer
    needs Python runtime aggregation to prove its surface.
    """

    var source_file: String
    var status: String
    var complete: Bool
    var bridge_free: Bool
    var fields: Int
    var methods: Int
    var bootstrap_steps: Int
    var snapshot_entries: Int
    var force_rebuild_methods: Int
    var dependency_edges: Int


def plan_architecture_facade_native_completion(
    catalog: ArchitectureFacadeCatalog,
) -> ArchitectureFacadeNativeCompletionPlan:
    """Plan the native completion status of ``facade.py``.

    This intentionally validates the facade as a composition graph, not as a
    duplicate owner of every child bundle implementation.  Those child bundles
    remain accountable in their own matrix rows; the facade owns only the
    static orchestration surface that Python previously supplied.
    """

    var snapshot = architecture_facade_snapshot(catalog)
    var valid = architecture_facade_catalog_valid(catalog)
    var complete = valid
    if snapshot.fields != 45:
        complete = False
    if snapshot.methods != 49:
        complete = False
    if snapshot.bootstrap_steps != 45:
        complete = False
    if snapshot.snapshot_entries != 48:
        complete = False
    if snapshot.force_rebuild_methods != 44:
        complete = False
    if snapshot.dependency_edges != 98:
        complete = False

    return ArchitectureFacadeNativeCompletionPlan(
        "reta_architecture/facade.py",
        "nativ",
        complete,
        True,
        snapshot.fields,
        snapshot.methods,
        snapshot.bootstrap_steps,
        snapshot.snapshot_entries,
        snapshot.force_rebuild_methods,
        snapshot.dependency_edges,
    )


def architecture_facade_native_completion_valid(
    catalog: ArchitectureFacadeCatalog,
) -> Bool:
    var plan = plan_architecture_facade_native_completion(catalog)
    return plan.complete and plan.bridge_free and plan.status == "nativ"


def render_architecture_facade_entry(entry: ArchitectureFacadeEntry) -> String:
    return (
        entry.kind
        + "\t"
        + String(entry.ordinal)
        + "\t"
        + entry.name
        + "\t"
        + entry.value
        + "\t"
        + entry.extra
    )


def render_architecture_facade_catalog(
    catalog: ArchitectureFacadeCatalog, kind: String = ""
) -> String:
    var result = String()
    for index in range(len(catalog.entries)):
        var entry = catalog.entries[index].copy()
        if kind.byte_length() > 0 and entry.kind != kind:
            continue
        result += render_architecture_facade_entry(entry) + os_linesep()
    return result^
