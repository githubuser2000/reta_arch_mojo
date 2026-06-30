"""Narrow compatibility adapter for the final prompt-only Python boundary.

The native prompt controller does not import or expose ``PythonObject``.  Only
three legacy operations remain behind this module:

* GNU-Readline/Vi/completion input on a real TTY;
* one atomic historical prompt fallback;
* an explicitly unsupported raw ``reta`` invocation.

Keeping those calls here prevents Python implementation types from leaking
through the native controller and gives Stage 12c4 one auditable replacement
surface.
"""

from std.python import Python, PythonObject


def _bridge() raises -> PythonObject:
    Python.add_to_path("python_reference")
    return Python.import_module("mojo_bridge")


def read_prompt_line_encoded_bridge(encoded: String) raises -> String:
    var bridge = _bridge()
    return String(py=bridge.read_prompt_line_encoded(encoded))


def run_reta_prompt_line_encoded_bridge(encoded: String) raises -> None:
    var bridge = _bridge()
    bridge.run_reta_prompt_line_encoded(encoded)


def run_reta_line_bridge(line: String) raises -> None:
    var bridge = _bridge()
    bridge.run_reta_line(line)
