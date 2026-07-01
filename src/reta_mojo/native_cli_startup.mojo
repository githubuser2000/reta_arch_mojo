"""Native ownership of Reta's startup, language-only and help surfaces.

The historical CLI has three observable paths before table construction:

* an empty invocation prints one short German hint;
* one or more supported ``-language=...`` selectors alone print nothing;
* ``-h``/``-help`` print the complete localized help once per occurrence.

The large help payloads are immutable generated assets.  Reading them at
runtime preserves exact bytes without embedding CPython or compiling a giant
string literal into every executable that imports the compatibility launcher.
"""

from std.collections import List
from .resource_paths import asset_resource


@fieldwise_init
struct NativeCliStartupResult(Copyable):
    var owned: Bool
    var output: String
    var language: String
    var help_count: Int


def _read_startup_asset(filename: String) raises -> String:
    var file = open(asset_resource(filename), "r")
    var payload = file.read()
    file.close()
    return payload^


def _supported_language_selector(token: String) -> Tuple[Bool, String]:
    if not token.startswith("-language="):
        return (False, String())
    var pieces = token.split("=")
    if len(pieces) != 2:
        return (False, String())
    var value = String(pieces[1])
    if value == "english":
        return (True, "english")
    if value == "german" or value == "deutsch":
        return (True, "german")
    return (False, String())


def native_cli_startup(tokens: List[String]) raises -> NativeCliStartupResult:
    """Conservatively classify pre-table argument vectors.

    Only exact, reference-tested token families are owned.  Any additional
    option or unsupported language leaves the complete vector to the ordinary
    native-table predicate or atomic Python compatibility child.
    """
    if len(tokens) == 0:
        return NativeCliStartupResult(
            True, "Versuche Parameter -h\n", "german", 0
        )

    var language = String("german")
    var language_chosen = False
    var help_count = 0
    for index in range(len(tokens)):
        var token = tokens[index]
        if token == "-h" or token == "-help":
            help_count += 1
            continue
        var selector = _supported_language_selector(token)
        if not selector[0]:
            return NativeCliStartupResult(
                False, String(), String(), 0
            )
        # The legacy bootstrap chooses the first ``-language=...`` token.
        if not language_chosen:
            language = selector[1]
            language_chosen = True

    if help_count == 0:
        # Language selectors alone initialize translation state but never enter
        # the table workflow and therefore have an empty byte stream.
        return NativeCliStartupResult(True, String(), language^, 0)

    var asset = (
        "reta_help_en.txt" if language == "english" else "reta_help_de.txt"
    )
    var help = _read_startup_asset(asset)
    var output = String()
    for _ in range(help_count):
        output += help
    return NativeCliStartupResult(True, output^, language^, help_count)
