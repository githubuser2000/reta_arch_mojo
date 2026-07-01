"""Native control-main semantics for the historical Reta CLI.

``-debug`` is an orthogonal diagnostic prefix.  ``-nichts``/``-nothing``
is a control-only main parameter: by itself it emits nothing, but in a real
table vector it is ignored exactly like the Python parameter parser does.  An
explicit ``--art=nichts``/``--type=nothing`` remains the actual silent output
mode.  Controls are removed before startup/table ownership checks so they cannot
become accidental section names.
"""

from std.collections import List


@fieldwise_init
struct NativeCliControls(Copyable):
    var tokens: List[String]
    var had_control: Bool
    var debug: Bool
    var control_only_nothing: Bool
    var debug_prefix: String


def _selector_value_control(token: String) -> String:
    var pieces = token.split("=")
    if len(pieces) == 2:
        return String(pieces[1])
    return String()


def _debug_prefix(tokens: List[String], enabled: Bool) -> String:
    if not enabled:
        return String()
    var selected = String()
    for index in range(len(tokens)):
        if tokens[index].startswith("-language="):
            selected = _selector_value_control(tokens[index])
            break
    var language_line = "not german" if selected == "english" else "german"
    return "Sprachenwahl: " + selected + "\n" + language_line + "\n"


def normalize_native_cli_controls(tokens: List[String]) -> NativeCliControls:
    """Remove native control mains while preserving Python's table semantics."""
    var filtered = List[String]()
    var debug = False
    var nothing = False

    for index in range(len(tokens)):
        var token = tokens[index]
        if token == "-debug":
            debug = True
            continue
        if token == "-nichts" or token == "-nothing":
            nothing = True
            continue

        filtered.append(token)
    return NativeCliControls(
        filtered^,
        debug or nothing,
        debug,
        nothing and len(filtered) == 0,
        _debug_prefix(tokens, debug),
    )
