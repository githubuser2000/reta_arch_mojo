#!/usr/bin/env python3
"""Generate the multilingual prompt dispatch and nested-completion catalogs.

The Python reference remains the source of truth while Stage 10 is being
ported.  The emitted TSV files contain only immutable runtime data; parsing,
context transitions and filtering are implemented in Mojo.
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REFERENCE = ROOT / "python_reference"
LANGUAGES = {
    "deutsch": "deutsch",
    "english": "english",
    "vietnamese": "vietnamese",
    "chinese": "chinese",
    "korean": "korean",
}

CORE_KINDS = {
    "q": 1,
    ":q": 1,
    "exit": 1,
    "quit": 1,
    "ende": 1,
    "h": 2,
    "help": 2,
    "hilfe": 2,
    "befehle": 3,
    "kurzbefehle": 4,
    "loggen": 5,
    "nichtloggen": 6,
    "leeren": 7,
    "prim": 8,
    "primfaktorzerlegung": 8,
    "multis": 9,
    "modulo": 10,
    "abc": 11,
    "abcd": 11,
    "shell": 12,
    "python": 13,
    "math": 14,
    "reta": 15,
    "prim24": 16,
    "primfaktorzerlegungModulo24": 16,
    "S": 17,
    "BefehlSpeichernDanach": 17,
    "s": 18,
    "BefehlSpeichernDavor": 18,
    "o": 19,
    "BefehlSpeicherungAusgeben": 19,
    "l": 20,
    "BefehlSpeicherungLöschen": 20,
    "multis3": 22,
    "primfaktorenvergleich": 23,
    "mond": 24,
    "abstand": 25,
    "abstandPrim": 26,
    "richtung": 27,
    "r": 27,
}


def _unique(values):
    seen = set()
    result = []
    for value in values:
        value = str(value)
        if value not in seen:
            seen.add(value)
            result.append(value)
    return result


def _snapshot(language: str) -> dict:
    code = r'''
import json
import sys
from pathlib import Path
language = sys.argv[1]
reference = Path(sys.argv[2])
sys.argv = ["prompt-catalog", "-language=" + language]
sys.path.insert(0, str(reference))
from reta_architecture.facade import RetaArchitecture
from reta_architecture.completion_runtime import bootstrap_completion_runtime
import i18n.words_runtime as i18n
architecture = RetaArchitecture.bootstrap(reference)
runtime = bootstrap_completion_runtime(
    architecture=architecture, i18n=i18n, force_rebuild=True
)

def _ordered(values):
    return [str(value) for value in values]

preparation_domains = {}
line_main = i18n.hauptForNeben["zeilen"]
line_domains = {str(key): [""] for key in i18n.haupt2neben[line_main]}
line_domains[str(i18n.zeilenParas["zeit"])] = _ordered({
    i18n.zeilenParas["gestern"], i18n.zeilenParas["heute"], i18n.zeilenParas["morgen"]
})
line_domains[str(i18n.zeilenParas["typ"])] = _ordered({
    i18n.zeilenParas["mond"], i18n.zeilenParas["sonne"],
    i18n.zeilenParas["planet"], i18n.zeilenParas["schwarzesonne"],
    i18n.zeilenParas["SonneMitMondanteil"],
})
line_domains[str(i18n.zeilenParas["primzahlen"])] = _ordered({
    i18n.zeilenParas["aussenerste"], i18n.zeilenParas["innenerste"],
    i18n.zeilenParas["innenalle"], i18n.zeilenParas["aussenalle"],
})
preparation_domains[line_main] = line_domains

column_domains = {}
for liste1 in runtime.program.dataDict[0].values():
    for liste2 in liste1:
        for liste3 in liste2:
            try:
                column_domains[str(liste3[0])] |= {str(liste3[1])}
            except KeyError:
                column_domains[str(liste3[0])] = {str(liste3[1])}
preparation_domains[i18n.hauptForNeben["spalten"]] = {
    key: _ordered(values) for key, values in column_domains.items()
}

preparation_domains[i18n.hauptForNeben["kombination"]] = {
    str(i18n.kombiMainParas["galaxie"]): _ordered({
        str(text) for values in i18n.kombiParaNdataMatrix.values() for text in values
    }),
    str(i18n.kombiMainParas["universum"]): _ordered({
        str(text) for values in i18n.kombiParaNdataMatrix2.values() for text in values
    }),
}
output_main = i18n.hauptForNeben["ausgabe"]
output_domains = {str(key): [""] for key in i18n.haupt2neben[output_main]}
output_domains[str(i18n.ausgabeParas["art"])] = _ordered(set(i18n.ausgabeArt.keys()))
preparation_domains[output_main] = output_domains

print(json.dumps({
    "commands": runtime.start_commands(include_numeric_shortcuts=True),
    "command_map": dict(i18n.befehle2),
    "replacements": dict(i18n.retaPrompt.replacements),
    "main": runtime.haupt_for_neben,
    "main_map": dict(i18n.hauptForNeben),
    "line_parameters": runtime.zeilen_paras,
    "line_map": dict(i18n.zeilenParas),
    "line_types": runtime.zeilen_typen,
    "line_prime_types": runtime.zeilen_typen_b,
    "line_time": runtime.zeilen_zeit,
    "column_parameters": runtime.spalten,
    "column_values": runtime.spalten_dict,
    "output_parameters": runtime.ausgabe_paras,
    "output_map": dict(i18n.ausgabeParas),
    "output_types": runtime.ausgabe_art,
    "combination_parameters": runtime.kombi_main_paras,
    "combination_map": dict(i18n.kombiMainParas),
    "combination_values": runtime.kombi_value_options,
    "preparation_domains": preparation_domains,
    "wahl15": dict(i18n.wahl15),
    "wahl16": dict(i18n.wahl16),
}, ensure_ascii=False))
'''
    environment = dict(os.environ)
    environment["PYTHONHASHSEED"] = "0"
    result = subprocess.run(
        [sys.executable, "-c", code, language, str(REFERENCE)],
        check=True,
        capture_output=True,
        text=True,
        cwd=REFERENCE,
        env=environment,
    )
    return json.loads(result.stdout)


def _safe(value: object) -> str:
    text = str(value)
    if any(ch in text for ch in "\t\r\n"):
        raise ValueError(f"catalog field contains a control separator: {text!r}")
    return text


def main() -> None:
    completion_rows: list[tuple[str, str, str, str]] = []
    dispatch_rows: list[tuple[str, str, int, str]] = []
    shortcut_rows: list[tuple[str, str, str]] = []
    numeric_rows: list[tuple[str, str, str, str]] = []
    vocabulary_rows: list[tuple[str, str, str, str]] = []
    preparation_rows: list[tuple[str, str, str, str]] = []

    for canonical_language, reference_language in LANGUAGES.items():
        data = _snapshot(reference_language)

        for token in _unique(data["commands"]):
            completion_rows.append((canonical_language, "root", "*", token))
        for token in _unique(data["main"]):
            completion_rows.append((canonical_language, "main", "*", token))

        main_map = data["main_map"]
        main_tokens = {
            "lines": "-" + main_map["zeilen"],
            "columns": "-" + main_map["spalten"],
            "combination": "-" + main_map["kombination"],
            "output": "-" + main_map["ausgabe"],
        }
        parameter_groups = {
            main_tokens["lines"]: data["line_parameters"],
            main_tokens["columns"]: data["column_parameters"],
            main_tokens["combination"]: data["combination_parameters"],
            main_tokens["output"]: data["output_parameters"],
        }
        for parent, values in parameter_groups.items():
            for token in _unique(values):
                completion_rows.append((canonical_language, "parameter", parent, token))

        # Line-value sections reproduce gleichKommaZeilen.
        line_map = data["line_map"]
        line_parameters = set(data["line_parameters"])
        line_values: dict[str, list[str]] = {}
        # The historical Python state machine iterates the dictionary keys,
        # not its translated values.  Keep those canonical keys exactly; the
        # three special localized value domains are overwritten below.
        for canonical in line_map.keys():
            key = str(canonical)
            line_values[key] = [str(n) for n in range(100)] if "--" + key + "=" in line_parameters else [""]
        line_values[str(line_map["typ"])] = list(data["line_types"]) + ["-" + str(v) for v in data["line_types"]]
        line_values[str(line_map["primzahlen"])] = list(data["line_prime_types"]) + ["-" + str(v) for v in data["line_prime_types"]]
        line_values[str(line_map["zeit"])] = list(data["line_time"]) + ["-" + str(v) for v in data["line_time"]]
        line_values["*"] = (
            line_values[str(line_map["typ"])]
            + line_values[str(line_map["primzahlen"])]
            + line_values[str(line_map["zeit"])]
        )
        for key, values in line_values.items():
            context = main_tokens["lines"] + "|" + key
            for value in _unique(values):
                completion_rows.append((canonical_language, "value", context, value))

        # Output-value sections reproduce gleichKommaAusg.
        output_map = data["output_map"]
        output_values = {
            "*": list(data["output_types"]),
            str(output_map["art"]): list(data["output_types"]),
            str(output_map["breite"]): [str(n) for n in range(10, 100)],
            str(output_map["breiten"]): [str(n) for n in range(10, 100)],
        }
        for key, values in output_values.items():
            context = main_tokens["output"] + "|" + key
            for value in _unique(values):
                completion_rows.append((canonical_language, "value", context, value))

        # Column and combination values are data-driven runtime maps.
        for key, values in data["column_values"].items():
            context = main_tokens["columns"] + "|" + str(key)
            for value in _unique(values):
                completion_rows.append((canonical_language, "value", context, value))
        for width_key in (output_map["breite"], output_map["breiten"]):
            context = main_tokens["columns"] + "|" + str(width_key)
            for value in (str(n) for n in range(10, 100)):
                completion_rows.append((canonical_language, "value", context, value))
        for key, values in data["combination_values"].items():
            context = main_tokens["combination"] + "|" + str(key)
            for value in _unique(values):
                completion_rows.append((canonical_language, "value", context, value))

        command_map = data["command_map"]
        for canonical, translated in command_map.items():
            vocabulary_rows.append((canonical_language, "command", str(canonical), str(translated)))
        for canonical, translated in data["main_map"].items():
            vocabulary_rows.append((canonical_language, "main", str(canonical), str(translated)))
        for canonical, translated in data["line_map"].items():
            vocabulary_rows.append((canonical_language, "line", str(canonical), str(translated)))
        for canonical, translated in data["output_map"].items():
            vocabulary_rows.append((canonical_language, "output", str(canonical), str(translated)))
        for canonical, translated in data["combination_map"].items():
            vocabulary_rows.append((canonical_language, "combination", str(canonical), str(translated)))
        for main_parameter, domains in data["preparation_domains"].items():
            for parameter, values in domains.items():
                preparation_rows.append((
                    canonical_language, str(main_parameter), str(parameter),
                    "\x1f".join(_safe(value) for value in values),
                ))
        for canonical, kind in CORE_KINDS.items():
            alias = command_map.get(canonical)
            if alias is not None:
                dispatch_rows.append((canonical_language, str(alias), kind, canonical))
        for short_alias, replacement in data["replacements"].items():
            shortcut_rows.append((canonical_language, str(short_alias), str(replacement)))
        for key, description in data["wahl15"].items():
            numeric_rows.append((canonical_language, "15", str(key), str(description)))
        for key, description in data["wahl16"].items():
            numeric_rows.append((canonical_language, "16", str(key), str(description)))

    assets = Path(os.environ.get("RETA_PROMPT_CATALOG_OUT", ROOT / "assets"))
    assets.mkdir(parents=True, exist_ok=True)
    completion_path = assets / "prompt_nested_completion.tsv"
    dispatch_path = assets / "prompt_command_aliases.tsv"
    shortcut_path = assets / "prompt_shortcut_replacements.tsv"
    numeric_path = assets / "prompt_numeric_shortcuts.tsv"
    vocabulary_path = assets / "prompt_vocabulary.tsv"
    preparation_path = assets / "prompt_preparation_domains.tsv"

    grouped_completion: dict[tuple[str, str, str], list[str]] = {}
    for language, scope, context, value in completion_rows:
        grouped_completion.setdefault((language, scope, context), []).append(value)
    completion_path.write_text(
        "".join(
            "\t".join(
                (
                    _safe(language),
                    _safe(scope),
                    _safe(context),
                    "\x1f".join(_safe(value) for value in _unique(values)),
                )
            )
            + "\n"
            for (language, scope, context), values in grouped_completion.items()
        ),
        encoding="utf-8",
    )
    dispatch_path.write_text(
        "".join("\t".join(map(_safe, row)) + "\n" for row in dispatch_rows),
        encoding="utf-8",
    )
    shortcut_path.write_text(
        "".join("\t".join(map(_safe, row)) + "\n" for row in shortcut_rows),
        encoding="utf-8",
    )
    numeric_path.write_text(
        "".join("\t".join(map(_safe, row)) + "\n" for row in numeric_rows),
        encoding="utf-8",
    )
    vocabulary_path.write_text(
        "".join("\t".join(map(_safe, row)) + "\n" for row in vocabulary_rows),
        encoding="utf-8",
    )
    preparation_path.write_text(
        "".join("\t".join(map(_safe, row)) + "\n" for row in preparation_rows),
        encoding="utf-8",
    )
    print(
        f"{len(completion_rows)} completion values in {len(grouped_completion)} sections, "
        f"{len(dispatch_rows)} dispatch aliases, "
        f"{len(shortcut_rows)} short replacements, "
        f"{len(numeric_rows)} numeric shortcuts, "
        f"{len(vocabulary_rows)} vocabulary aliases, "
        f"{len(preparation_rows)} preparation domains"
    )


if __name__ == "__main__":
    main()
