"""Native diagnostic surface for the complete console-IO owner."""

from std.collections import List
from std.collections.string import atol
from reta_mojo.cli_arguments import owned_process_argv
from reta_mojo.console_io import *


def _bool_text(value: Bool) -> String:
    return "true" if value else "false"


def _print_values(prefix: String, values: List[String]):
    print(prefix, end="")
    for index in range(len(values)):
        if index > 0:
            print("\x1f", end="")
        print(values[index], end="")
    print()


def _usage():
    print("reta-mojo-console-io")
    print("  --summary")
    print("  --chunks SIZE VALUE...")
    print("  --unique VALUE...")
    print("  --unique-lower VALUE...")
    print("  --cli COLOR ENABLED TEXT")
    print("  --help-text prompt|reta german|english")
    print("  --ordered-default")


def run_console_io_cli(args: List[String]) raises -> Int:
    var bundle = bootstrap_console_io_morphisms()
    if len(args) == 1 or (len(args) == 2 and args[1] == "--summary"):
        var snapshot = bundle.snapshot()
        print("class=" + snapshot.class_name)
        print("stage=" + String(snapshot.stage))
        print("legacy_owner=" + snapshot.legacy_owner)
        print("capsule=" + snapshot.capsule)
        print("secondary_capsule=" + snapshot.secondary_capsule)
        print("category=" + snapshot.category)
        print("functor=" + snapshot.functor)
        print("natural_transformation=" + snapshot.natural_transformation)
        print("repo_root=" + snapshot.repo_root)
        for index in range(len(snapshot.morphisms)):
            print("morphism=" + snapshot.morphisms[index])
        for index in range(len(snapshot.compatibility_names)):
            print("compatibility=" + snapshot.compatibility_names[index])
        print("observable_invariant=" + snapshot.observable_invariant)
        return 0

    if len(args) >= 4 and args[1] == "--chunks":
        var values = List[String]()
        for index in range(3, len(args)):
            values.append(args[index])
        var chunked = chunks_strings(values, atol(args[2]))
        for index in range(len(chunked)):
            _print_values("chunk=", chunked[index])
        return 0

    if len(args) >= 3 and args[1] == "--unique":
        var values = List[String]()
        for index in range(2, len(args)):
            values.append(args[index])
        _print_values("unique=", unique_everseen_strings(values))
        return 0

    if len(args) >= 3 and args[1] == "--unique-lower":
        var values = List[String]()
        for index in range(2, len(args)):
            values.append(args[index])
        _print_values("unique=", unique_everseen_ascii_lower(values))
        return 0

    if len(args) == 5 and args[1] == "--cli":
        var color = args[2] == "true" or args[2] == "1"
        var enabled = args[3] == "true" or args[3] == "1"
        print(cli_output_text(args[4], color, enabled), end="")
        return 0

    if len(args) == 4 and args[1] == "--help-text":
        var kind = args[2]
        var language = args[3]
        if kind == "prompt":
            print(reta_prompt_help_text(language), end="")
            return 0
        if kind == "reta":
            print(reta_help_text(language), end="")
            return 0

    if len(args) == 2 and args[1] == "--ordered-default":
        var ordered = default_ordered_dict()
        var first = ordered.get_or_default("alpha")
        first.append("1")
        ordered.set("alpha", first)
        ordered.set("beta", ["2", "3"])
        var snapshot = ordered.snapshot()
        print("class=" + snapshot.class_name)
        print("factory=" + snapshot.default_factory_name)
        for index in range(len(snapshot.keys)):
            _print_values("entry=" + snapshot.keys[index] + "=", snapshot.values[index])
        print("contains_alpha=" + _bool_text(ordered.contains("alpha")))
        print("contains_gamma=" + _bool_text(ordered.contains("gamma")))
        return 0

    _usage()
    raise Error("invalid console-io diagnostic arguments")


def main() raises:
    _ = run_console_io_cli(owned_process_argv())
