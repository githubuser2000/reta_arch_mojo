#!/usr/bin/env python3
"""Emit one fresh-process PromptRuntimeBundle contract for byte parity."""
from __future__ import annotations

import sys
from pathlib import Path

if len(sys.argv) != 2:
    raise SystemExit("usage: prompt_runtime_reference.py LANGUAGE")
language = sys.argv[1]
root = Path(__file__).resolve().parent.parent
reference = root / "python_reference"
sys.argv = ["prompt-runtime-reference", "-language=" + language]
sys.path.insert(0, str(reference))

from reta_architecture.facade import RetaArchitecture  # noqa: E402
from reta_architecture.prompt_runtime import bootstrap_prompt_runtime  # noqa: E402
import i18n.words_runtime as i18n  # noqa: E402

architecture = RetaArchitecture.bootstrap(reference)
bundle = bootstrap_prompt_runtime(
    architecture=architecture, i18n=i18n, force_rebuild=True
)
snapshot = bundle.snapshot()
program = snapshot["program_view"]
vocabulary = snapshot["vocabulary"]
print("@@@" + language)
print("class=" + program["class"])
for name, value in bundle.program.mainParaCmds.items():
    print("main=" + name + ":" + ("-1" if value is None else str(value)))
print("para_n_data=" + str(len(bundle.semantics.para_n_data_matrix)))
print("para_dict=" + str(program["paraDict_len"]))
print("data=" + ",".join(map(str, program["dataDict_sizes"])))
print("kombi=" + str(program["kombiReverseDict_len"]))
print("kombi2=" + str(program["kombiReverseDict2_len"]))
print("simple=" + str(program["AllSimpleCommandSpalten_len"]))
print("max1024=" + str(program["max_rows"][1024]))
print("max114=" + str(program["max_rows"][114]))
for key in (
    "main_parameters_len",
    "zeilen_paras_len",
    "ausgabe_paras_len",
    "ausgabe_art_len",
    "kombi_main_paras_len",
    "befehle2_len",
    "befehle_len",
    "spalten_dict_keys",
    "spalten_len",
    "gebrochen_erlaubte_zahlen_len",
    "haupt_for_neben_len",
):
    print(key + "=" + str(vocabulary[key]))
print("normal_prefix=>")
print("store_prefix=" + i18n.retaPrompt.wspeichernWort)
print("delete_prefix=" + i18n.retaPrompt.wloeschenWort)
validation = snapshot["validation"]
print("wahl15=" + ("1" if validation["wahl15_valid"] else "0"))
print("missing=" + str(len(validation["wahl15_missing_values"])))
for value in validation["wahl15_missing_values"]:
    print("missing_value=[" + value + "]")
