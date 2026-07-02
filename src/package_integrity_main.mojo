"""Native command surface for reta source-tree package integrity."""

from std.sys import argv
from reta_mojo.package_integrity import (
    default_repo_manifest,
    repo_manifest_json,
    repo_manifest_summary,
)


def _usage() -> None:
    print("reta-mojo-package-integrity")
    print("  --summary [ROOT]")
    print("  --json [ROOT]")
    print("  --json-files [ROOT]")


def main() raises:
    var args = argv()
    if len(args) == 1:
        print(repo_manifest_summary(default_repo_manifest("python_reference")))
        return
    var command = String(args[1])
    if command == "--summary":
        print(
            repo_manifest_summary(
                default_repo_manifest(
                    String(args[2]) if len(args) > 2 else "python_reference"
                )
            )
        )
        return
    if command == "--json":
        print(
            repo_manifest_json(
                default_repo_manifest(
                    String(args[2]) if len(args) > 2 else "python_reference"
                )
            )
        )
        return
    if command == "--json-files":
        print(
            repo_manifest_json(
                default_repo_manifest(
                    String(args[2]) if len(args) > 2 else "python_reference"
                ),
                True,
            )
        )
        return
    _usage()
    raise Error("invalid package-integrity arguments")
