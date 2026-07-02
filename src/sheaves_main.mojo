"""Native diagnostics for local presheaves and global sheaves."""

from std.sys import argv
from std.collections import List
from std.collections.string import atol
from reta_mojo.presheaves import *
from reta_mojo.schema_catalog import bootstrap_reta_schema
from reta_mojo.sheaves import *


def _usage() -> None:
    print("reta-mojo-sheaves")
    print("  --summary")
    print("  --presheaf csv|translations|assets|prompt")
    print("  --html COLUMN")
    print("  --prompt TEXT")


def _print_presheaf(snapshot: PresheafSnapshot) -> None:
    print("name=" + snapshot.name)
    print("sections=" + String(snapshot.section_count))
    for index in range(min(5, len(snapshot.sources))):
        print("source=" + snapshot.sources[index])


def main() raises:
    var args = argv()
    var presheaves = PresheafBundle.discover()
    var sheaves = SheafBundle.from_repo(
        "", bootstrap_reta_schema()
    )
    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        var local = presheaves.snapshot()
        var glued = sheaves.snapshot()
        print("csv=" + String(local.csv_sections))
        print("translations=" + String(local.translation_sections))
        print("assets=" + String(local.asset_sections))
        print("prompt=" + String(local.prompt_sections))
        print(
            "main_alias_groups="
            + String(glued.parameter_semantics.main_alias_groups)
        )
        print(
            "pair_to_columns="
            + String(glued.parameter_semantics.pair_to_columns)
        )
        print("html_reference=" + String(glued.html_reference_size))
        return
    if len(args) == 3 and String(args[1]) == "--presheaf":
        var kind = String(args[2])
        if kind == "csv":
            _print_presheaf(presheaves.csv.snapshot())
            return
        if kind == "translations":
            _print_presheaf(presheaves.translations.snapshot())
            return
        if kind == "assets":
            _print_presheaf(presheaves.assets.snapshot())
            return
        if kind == "prompt":
            _print_presheaf(presheaves.prompt_state.snapshot())
            return
    if len(args) == 3 and String(args[1]) == "--html":
        print(
            sheaves.html_reference.html_meta_for_column(
                atol(String(args[2]))
            )
        )
        return
    if len(args) == 3 and String(args[1]) == "--prompt":
        var tokens = List[String]()
        tokens.append(String(args[2]))
        presheaves.prompt_state.update_default(String(args[2]), tokens)
        print(presheaves.prompt_state.snapshot_json())
        return
    _usage()
    raise Error("invalid sheaf diagnostic arguments")
