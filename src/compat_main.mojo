"""Mojo launcher for the bundled Python reference implementation.

This executable is the migration boundary: it preserves the complete historical
CLI while native subsystems are moved into ``reta_mojo`` one by one.
"""
from std.sys import argv
from std.python import Python


def main() raises:
    var args = argv()
    Python.add_to_path("python_reference")
    var bridge = Python.import_module("mojo_bridge")
    var encoded = String("reta.py")
    for index in range(1, len(args)):
        encoded += "\x1f" + String(args[index])
    bridge.run_reta_subprocess_encoded(encoded)
