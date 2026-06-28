#!/usr/bin/env python3
"""Regenerate the Mojo prompt-completion catalog from the Python reference."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
REFERENCE = ROOT / "python_reference"
sys.path.insert(0, str(REFERENCE))

from reta_architecture.facade import RetaArchitecture  # noqa: E402
from reta_architecture.completion_runtime import bootstrap_completion_runtime  # noqa: E402

architecture = RetaArchitecture.bootstrap(REFERENCE)
runtime = bootstrap_completion_runtime(architecture=architecture)
commands = runtime.start_commands(include_numeric_shortcuts=True)
out = ROOT / "src" / "reta_mojo" / "prompt_catalog.mojo"
with out.open("w", encoding="utf-8") as handle:
    handle.write(
        '"""Generated native completion catalog for retaPrompt.\n\n'
        'Source: Python reference completion runtime. Regenerate with\n'
        '``scripts/generate_prompt_catalog.py``.\n"""\n\n'
        'from std.collections import List\n\n\n'
        'def prompt_completion_words() -> List[String]:\n'
        '    var values = List[String]()\n'
    )
    for command in commands:
        escaped = str(command).replace("\\\\", "\\\\\\\\").replace('"', '\\"')
        handle.write(f'    values.append("{escaped}")\n')
    handle.write("    return values^\n")
print(f"{len(commands)} Promptwörter nach {out} geschrieben")
