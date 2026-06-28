"""Compatibility bridge used by the incremental Mojo port.

The bridge is intentionally tiny: it only converts an argument list and calls
the untouched Python reference Program. Native Mojo commands never enter this
module.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path
from typing import Iterable

REFERENCE_ROOT = Path(__file__).resolve().parent


def run_reta(arguments: Iterable[str]) -> int:
    argv = [str(value) for value in arguments]
    if not argv:
        argv = [str(REFERENCE_ROOT / "reta.py")]
    elif argv[0] in {"reta", "reta.py"}:
        argv[0] = str(REFERENCE_ROOT / "reta.py")

    root = str(REFERENCE_ROOT)
    libs = str(REFERENCE_ROOT / "libs")
    if root not in sys.path:
        sys.path.insert(0, root)
    if libs not in sys.path:
        sys.path.insert(0, libs)

    old_cwd = Path.cwd()
    old_argv = sys.argv
    try:
        os.chdir(REFERENCE_ROOT)
        sys.argv = argv
        from reta import Program

        Program(argv)
        return 0
    finally:
        sys.argv = old_argv
        os.chdir(old_cwd)


def run_reta_encoded(encoded: str) -> int:
    """Run reta from a unit-separator-delimited Mojo argument string."""
    return run_reta(str(encoded).split("\x1f"))


def run_reta_subprocess_encoded(encoded: str) -> int:
    """Run the Python reference in a child process to isolate CPython globals."""
    import subprocess

    argv = str(encoded).split("\x1f")
    command = [sys.executable, str(REFERENCE_ROOT / "reta.py"), *argv[1:]]
    completed = subprocess.run(command, cwd=REFERENCE_ROOT, check=False)
    return int(completed.returncode)
