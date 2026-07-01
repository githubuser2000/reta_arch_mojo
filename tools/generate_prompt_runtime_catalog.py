#!/usr/bin/env python3
"""Generate the native prompt-runtime contract from the frozen Python tree."""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REFERENCE = ROOT / "python_reference"
LANGUAGES = ("deutsch", "english", "vietnamese", "chinese", "korean")


def _snapshot(language: str) -> dict:
    code = r'''
import json, sys
from pathlib import Path
root=Path(sys.argv[1]); language=sys.argv[2]; reference=root/'python_reference'
sys.argv=['prompt-runtime-generator','-language='+language]
sys.path.insert(0,str(reference))
from reta_architecture.facade import RetaArchitecture
from reta_architecture.prompt_runtime import bootstrap_prompt_runtime
import i18n.words_runtime as i18n
architecture=RetaArchitecture.bootstrap(reference)
bundle=bootstrap_prompt_runtime(architecture=architecture,i18n=i18n,force_rebuild=True)
s=bundle.snapshot(); p=bundle.program
print(json.dumps({
 'language': language,
 'program': s['program_view'],
 'para_n_data_matrix_len': len(bundle.semantics.para_n_data_matrix),
 'main_parameter_indices': [-1 if value is None else int(value) for value in p.mainParaCmds.values()],
 'vocabulary': s['vocabulary'],
 'normal_prefix': '>',
 'store_prefix': i18n.retaPrompt.wspeichernWort,
 'delete_prefix': i18n.retaPrompt.wloeschenWort,
 'validation': s['validation'],
}, ensure_ascii=False, sort_keys=True))
'''
    completed = subprocess.run(
        [sys.executable, "-c", code, str(ROOT), language],
        check=True,
        text=True,
        capture_output=True,
        env={**dict(__import__("os").environ), "PYTHONHASHSEED": "0"},
    )
    return json.loads(completed.stdout)


def _string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def _string_list(values: list[str]) -> str:
    return "[" + ", ".join(_string(value) for value in values) + "]"


def _int_list(values: list[int]) -> str:
    return "[" + ", ".join(str(int(value)) for value in values) + "]"


def render() -> str:
    snapshots = [_snapshot(language) for language in LANGUAGES]
    out = [
        '"""Generated prompt-runtime contract; do not edit by hand.\n\nRegenerate with ``tools/generate_prompt_runtime_catalog.py``.\n"""',
        "",
        "from std.collections import List",
        "from .prompt_runtime import (",
        "    PromptProgramViewContract,",
        "    PromptVocabularyContract,",
        "    PromptRuntimeContract,",
        ")",
        "",
        "",
        "def prompt_runtime_contract(language: String) -> PromptRuntimeContract:",
        "    var normalized = language.strip().lower()",
    ]
    for index, snapshot in enumerate(snapshots):
        prefix = "if" if index == 0 else "elif"
        p = snapshot["program"]
        v = snapshot["vocabulary"]
        validation = snapshot["validation"]
        aliases = [snapshot["language"]]
        if snapshot["language"] == "deutsch":
            aliases += ["de", "german"]
        elif snapshot["language"] == "english":
            aliases += ["en", "englisch"]
        condition = " or ".join(f"normalized == {_string(alias)}" for alias in aliases)
        out += [
            f"    {prefix} {condition}:",
            "        return PromptRuntimeContract(",
            f"            {_string(snapshot['language'])},",
            "            PromptProgramViewContract(",
            f"                {_string(p['class'])},",
            f"                {_string_list(p['mainParaCmds'])},",
            f"                {_int_list(snapshot['main_parameter_indices'])},",
            f"                {snapshot['para_n_data_matrix_len']},",
            f"                {p['paraDict_len']},",
            f"                {_int_list(p['dataDict_sizes'])},",
            f"                {p['kombiReverseDict_len']},",
            f"                {p['kombiReverseDict2_len']},",
            f"                {p['AllSimpleCommandSpalten_len']},",
            f"                {p['max_rows'].get('1024', p['max_rows'].get(1024))},",
            f"                {p['max_rows'].get('114', p['max_rows'].get(114))},",
            "            ),",
            "            PromptVocabularyContract(",
            f"                {v['main_parameters_len']},",
            f"                {v['zeilen_paras_len']},",
            f"                {v['ausgabe_paras_len']},",
            f"                {v['ausgabe_art_len']},",
            f"                {v['kombi_main_paras_len']},",
            f"                {v['befehle2_len']},",
            f"                {v['befehle_len']},",
            f"                {v['spalten_dict_keys']},",
            f"                {v['spalten_len']},",
            f"                {v['gebrochen_erlaubte_zahlen_len']},",
            f"                {v['haupt_for_neben_len']},",
            "            ),",
            f"            {_string(snapshot['normal_prefix'])},",
            f"            {_string(snapshot['store_prefix'])},",
            f"            {_string(snapshot['delete_prefix'])},",
            f"            {'True' if validation['wahl15_valid'] else 'False'},",
            f"            {_string_list(validation['wahl15_missing_values'])},",
            "        )",
        ]
    out += [
        "    return prompt_runtime_contract(\"deutsch\")",
        "",
    ]
    return "\n".join(out)



def render_prefix_catalog() -> str:
    snapshots = [_snapshot(language) for language in LANGUAGES]
    out = [
        '"""Generated lightweight prompt-prefix contract; do not edit by hand.\n\nRegenerate with ``tools/generate_prompt_runtime_catalog.py``.\n"""',
        "",
        "",
        "@fieldwise_init",
        "struct PromptPrefixContract(Copyable):",
        "    var normal: String",
        "    var store: String",
        "    var delete: String",
        "",
        "",
        "def prompt_prefix_contract(language: String) -> PromptPrefixContract:",
        "    var normalized = language.strip().lower()",
    ]
    for index, snapshot in enumerate(snapshots):
        prefix = "if" if index == 0 else "elif"
        aliases = [snapshot["language"]]
        if snapshot["language"] == "deutsch":
            aliases += ["de", "german"]
        elif snapshot["language"] == "english":
            aliases += ["en", "englisch"]
        condition = " or ".join(f"normalized == {_string(alias)}" for alias in aliases)
        out += [
            f"    {prefix} {condition}:",
            "        return PromptPrefixContract(",
            f"            {_string(snapshot['normal_prefix'])},",
            f"            {_string(snapshot['store_prefix'])},",
            f"            {_string(snapshot['delete_prefix'])},",
            "        )",
        ]
    out += [
        '    return prompt_prefix_contract("deutsch")',
        "",
    ]
    return "\n".join(out)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "src" / "reta_mojo" / "prompt_runtime_catalog.mojo",
    )
    parser.add_argument(
        "--prefix-output",
        type=Path,
        default=ROOT / "src" / "reta_mojo" / "prompt_prefix_catalog.mojo",
    )
    args = parser.parse_args()
    text = render()
    prefix_text = render_prefix_catalog()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.prefix_output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(text, encoding="utf-8")
    args.prefix_output.write_text(prefix_text, encoding="utf-8")
    print(f"generated {args.output}")
    print(f"generated {args.prefix_output}")


if __name__ == "__main__":
    main()
