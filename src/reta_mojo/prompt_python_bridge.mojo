"""Narrow compatibility adapter for the final prompt-only Python boundary.

The native prompt controller does not import or expose ``PythonObject``.  After
Stage 12c4b, only GNU-Readline/Vi/completion input on a real TTY remains behind
this module.  Unsupported ``reta`` and atomic historical prompt fallbacks are
started directly by the explicit Mojo child-process adapter instead of first
embedding CPython merely to ask it to spawn another interpreter.
"""

from std.python import Python, PythonObject


def _bridge() raises -> PythonObject:
    Python.add_to_path("python_reference")
    return Python.import_module("mojo_bridge")


def read_prompt_line_encoded_bridge(encoded: String) raises -> String:
    var bridge = _bridge()
    return String(py=bridge.read_prompt_line_encoded(encoded))
