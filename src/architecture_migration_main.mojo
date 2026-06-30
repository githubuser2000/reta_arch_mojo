"""Compact native query surface for the generated Stage-34 migration plan."""

from std.sys import argv
from reta_mojo.architecture_migration import (
    architecture_migration_count_line,
    bootstrap_architecture_migration,
    migration_first_owner_step_index,
    migration_owner_step_count,
    migration_snapshot_validation_passed,
    migration_step_index,
    migration_wave_index,
)


def _usage() -> None:
    print("reta-mojo-migration")
    print("  --summary")
    print("  --wave ID")
    print("  --step ID")
    print("  --owner PATH")


def main() raises:
    var args = argv()
    var bundle = bootstrap_architecture_migration()

    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        print(architecture_migration_count_line(bundle))
        print("snapshot_validation=" + bundle.validation.status)
        print("snapshot_passed=" + ("true" if migration_snapshot_validation_passed(bundle) else "false"))
        return

    if len(args) == 3 and String(args[1]) == "--wave":
        var index = migration_wave_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown migration wave")
        print(bundle.waves[index].wave_id)
        print(bundle.waves[index].name)
        print(bundle.waves[index].status)
        print("candidates=" + String(len(bundle.waves[index].candidates)))
        return

    if len(args) == 3 and String(args[1]) == "--step":
        var index = migration_step_index(bundle, String(args[2]))
        if index < 0:
            raise Error("unknown migration step")
        print(bundle.steps[index].step_id)
        print(bundle.steps[index].wave_id)
        print(bundle.steps[index].legacy_owner)
        print(bundle.steps[index].status)
        return

    if len(args) == 3 and String(args[1]) == "--owner":
        var owner = String(args[2])
        var index = migration_first_owner_step_index(bundle, owner)
        if index < 0:
            raise Error("unknown migration owner")
        print(owner)
        print("steps=" + String(migration_owner_step_count(bundle, owner)))
        print("first_step=" + bundle.steps[index].step_id)
        print("wave=" + bundle.steps[index].wave_id)
        return

    _usage()
    raise Error("invalid architecture-migration arguments")
