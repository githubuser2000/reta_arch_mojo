#!/usr/bin/env python3
"""Emit the observable fresh-bootstrap snapshot of prompt_preparation.py."""
from __future__ import annotations

import sys
from pathlib import Path

language = sys.argv[1] if len(sys.argv) > 1 else "deutsch"
root = Path(__file__).resolve().parent.parent
reference = root / "python_reference"
sys.argv = ["prompt-preparation-legacy-reference", "-language=" + language]
sys.path.insert(0, str(reference))

from reta_architecture.facade import RetaArchitecture  # noqa: E402
from reta_architecture.prompt_preparation import bootstrap_prompt_preparation  # noqa: E402
import i18n.words_runtime as i18n  # noqa: E402

architecture = RetaArchitecture.bootstrap(reference)
bundle = bootstrap_prompt_preparation(
    architecture=architecture,
    i18n=i18n,
    force_rebuild=True,
)
snapshot = bundle.snapshot()
print("class=" + snapshot["class"])
print("command_rotator=" + snapshot["command_rotator"])
print("regex_rewriter=" + snapshot["regex_rewriter"])
print("output_preparer=" + snapshot["output_preparer"])
for name in ("zeilen", "spalten", "ausgabe", "kombination"):
    print(f"cached_{name}={snapshot['cached_parameter_value_domains'][name]}")
print("beenden_commands_len=" + str(snapshot["beenden_commands_len"]))
