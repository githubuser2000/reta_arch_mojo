#!/usr/bin/env python3
"""Compare native Stage-40 word completion with the frozen Python owner."""

from __future__ import annotations

import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
BINARY = ROOT / "target" / "test-bin" / "completion-word-probe"


def python_lines() -> bytes:
    sys.path.insert(0, str(ROOT / "python_reference"))
    from reta_architecture.completion_word import Document, iter_word_completions

    cases = [
        ("prefix", ["reta", "religion", "alpha"], "re", {}),
        ("middle", ["alpha", "beta", "theta"], "et", {"match_middle": True}),
        ("case", ["Reta", "Religion"], "re", {"ignore_case": True}),
        ("unicode", ["größe", "grün", "öße", "öko"], "grö", {}),
        ("whole", ["alpha-beta", "beta"], "alpha-beta", {"WORD": True}),
        ("sentence", ["reta --hilfe", "reta --version"], "reta --h", {"sentence": True}),
    ]
    output: list[str] = []
    for label, words, text, options in cases:
        for item in iter_word_completions(words, Document(text), **options):
            output.append(
                f"{label}\t{item.text}\t{item.start_position}\t{item.text}\t"
            )
    return ("\n".join(output) + "\n").encode()


def main() -> None:
    BINARY.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [str(ROOT / "bin" / "mojo-real"), "build", "-I", "src", "-I", "tests", "tests/completion_word_probe.mojo", "-o", str(BINARY)],
        cwd=ROOT,
        check=True,
    )
    subprocess.run(
        [sys.executable, str(ROOT / "tools" / "sanitize_mojo_runpath.py"), str(BINARY)],
        cwd=ROOT,
        check=True,
        stdout=subprocess.DEVNULL,
    )
    env = os.environ.copy()
    env["RETA_MOJO_RUNTIME_LIBDIR"] = str(ROOT / "target" / "lib" / "mojo")
    native = subprocess.run(
        [str(ROOT / "tools" / "wrappers" / "mojo-runtime-exec"), str(BINARY)],
        cwd=ROOT,
        env=env,
        check=True,
        stdout=subprocess.PIPE,
    ).stdout
    expected = python_lines()
    if native != expected:
        sys.stderr.write("Python:\n" + expected.decode())
        sys.stderr.write("Mojo:\n" + native.decode())
        raise SystemExit("completion-word parity failed")
    print("completion-word parity: 10/10 records byte-identical")


if __name__ == "__main__":
    main()
