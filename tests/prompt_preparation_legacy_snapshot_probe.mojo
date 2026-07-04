from std.sys import argv
from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_preparation import bootstrap_prompt_preparation


def main() raises:
    var args = argv()
    var language = "deutsch" if len(args) < 2 else String(args[1])
    var catalog = load_prompt_language_catalog("assets")
    var bundle = bootstrap_prompt_preparation(
        catalog,
        "assets",
        language,
        ["q", ":q", "exit", "quit", "ende"],
    )
    var snapshot = bundle.legacy_snapshot()
    print("class=" + snapshot.class_name)
    print("command_rotator=" + snapshot.command_rotator)
    print("regex_rewriter=" + snapshot.regex_rewriter)
    print("output_preparer=" + snapshot.output_preparer)
    print("cached_zeilen=" + String(snapshot.cached_zeilen))
    print("cached_spalten=" + String(snapshot.cached_spalten))
    print("cached_ausgabe=" + String(snapshot.cached_ausgabe))
    print("cached_kombination=" + String(snapshot.cached_kombination))
    print("beenden_commands_len=" + String(snapshot.beenden_commands_len))
