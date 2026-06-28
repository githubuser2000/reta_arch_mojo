#!/usr/bin/env python3
"""Generate the native Mojo Grundstrukturen hierarchy catalog.

The Python reference obtains ``wahl15`` through gettext and a large prompt
bootstrap.  Runtime Mojo must not repeat that dynamic import graph, so this
developer tool evaluates the reference once per distinct language catalog and
writes a compact, traversal-ordered Mojo data module.
"""
from __future__ import annotations

import json
import subprocess
import sys
from collections import OrderedDict
from functools import cmp_to_key
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parent.parent
REFERENCE = ROOT / "python_reference"
OUT = ROOT / "src" / "reta_mojo" / "grundstrukturen_catalog.mojo"

DUMP_CODE = r"""
import json
import sys
sys.path.insert(0, 'libs')
from LibRetaPrompt import wahl15
from reta_architecture.split_i18n import build_split_i18n_proxy
i18n = build_split_i18n_proxy()
print(json.dumps({
    'label': i18n.ParametersMain.grundstrukturen[0],
    'wahl15': wahl15,
}, ensure_ascii=False))
"""


def load_catalog(language: str) -> tuple[str, dict[str, str]]:
    completed = subprocess.run(
        [sys.executable, "-c", DUMP_CODE, f"-language={language}"],
        cwd=REFERENCE,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    )
    payload = json.loads(completed.stdout.splitlines()[-1])
    return str(payload["label"]), dict(payload["wahl15"])


def cmp_before(value: tuple[str, Any]) -> tuple[bool, str]:
    text = value[0]
    is_number = True
    if "/" in text:
        candidate = text.split("/")[-1]
        if candidate.isdecimal():
            to_sort = candidate
        else:
            is_number = False
            to_sort = text
    elif text.isdecimal():
        to_sort = text
    else:
        is_number = False
        to_sort = text
    return is_number, to_sort


def cmpx(first: tuple[str, Any], second: tuple[str, Any]) -> int:
    is_number_1, value_1 = cmp_before(first)
    is_number_2, value_2 = cmp_before(second)
    if is_number_1 and is_number_2:
        number_1 = int(value_1)
        number_2 = int(value_2)
        if number_1 == number_2:
            if "/" in first[0]:
                return 1
            if "/" in second[0]:
                return -1
            return 0
        return number_1 - number_2
    if is_number_1 and not is_number_2:
        return 1
    if not is_number_1 and is_number_2:
        return -1
    # Preserve the historical comparator bug exactly: bool is used as cmp int.
    return int(value_1 < value_2)


def sorted_ordered(values: dict[str, Any] | OrderedDict[str, Any]) -> OrderedDict[str, Any]:
    return OrderedDict(sorted(values.items(), key=cmp_to_key(cmpx)))


def merge_dicts(first: OrderedDict[str, Any], second: OrderedDict[str, Any]) -> OrderedDict[str, Any]:
    for key in second:
        if (
            key in first
            and isinstance(first[key], OrderedDict)
            and isinstance(second[key], OrderedDict)
        ):
            merge_dicts(first[key], second[key])
        elif key not in first:
            first[key] = second[key]
        elif isinstance(second[key], OrderedDict) and not isinstance(first[key], OrderedDict):
            # This branch is not reached by the current wahl15 data. Keep an
            # explicit, deterministic conversion rather than the legacy
            # OrderedDict.update(None) defect.
            converted = OrderedDict([(str(first[key]), None)])
            converted.update(second[key])
            first[key] = sorted_ordered(converted)
    return sorted_ordered(first)


def traverse_hierarchy(parts: tuple[str, ...], thing: OrderedDict[str, Any], index: int, value: str) -> OrderedDict[str, Any]:
    node_key = parts[index].replace("pro", "/")
    if index == 0:
        leaf_keys = value.split(",")
        thing.update(sorted_ordered(OrderedDict((key, None) for key in leaf_keys)))
    thing = sorted_ordered(OrderedDict([(node_key, thing)]))
    if len(parts) > index + 1:
        thing = traverse_hierarchy(parts, thing, index + 1, value)
    return thing


def build_tree(wahl15: dict[str, str]) -> OrderedDict[str, Any]:
    hierarchy: OrderedDict[str, Any] = OrderedDict()
    for key, value in wahl15.items():
        parts = tuple(reversed([part for part in ("_" + key).split("_") if part]))
        thing = traverse_hierarchy(parts, OrderedDict(), 0, value)
        hierarchy = merge_dicts(thing, hierarchy)

    result: OrderedDict[str, Any] = OrderedDict()
    result["15"] = sorted_ordered(hierarchy)
    return merge_dicts(result, sorted_ordered(hierarchy["15"]))


def flatten(tree: OrderedDict[str, Any]) -> list[tuple[int, str, bool, bool, bool]]:
    records: list[tuple[int, str, bool, bool, bool]] = []

    def walk(mapping: OrderedDict[str, Any], depth: int) -> None:
        items = list(mapping.items())
        if depth >= 2:
            items.reverse()
        for key, value in items:
            is_leaf = value is None
            child_count = 0 if is_leaf else len(value)
            nested_child = False if is_leaf else any(child is not None for child in value.values())
            open_div = (not is_leaf and child_count > 1) or depth < 2
            show_text = is_leaf or ((not is_leaf and nested_child and child_count > 1) or depth < 2)
            records.append((depth, key, is_leaf, open_div, show_text))
            if not is_leaf:
                walk(value, depth + 1)

    walk(tree, 0)
    return records


def mojo_string(value: str) -> str:
    return (
        value.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("\n", "\\n")
        .replace("\r", "\\r")
        .replace("\t", "\\t")
    )


def emit_function(handle, name: str, records: list[tuple[int, str, bool, bool, bool]]) -> None:
    handle.write(f"def {name}() -> List[GrundstrukturRenderRecord]:\n")
    handle.write("    var records = List[GrundstrukturRenderRecord]()\n")
    for depth, key, is_leaf, open_div, show_text in records:
        handle.write(
            "    records.append(GrundstrukturRenderRecord("
            f'{depth}, "{mojo_string(key)}", '
            f"{'True' if is_leaf else 'False'}, "
            f"{'True' if open_div else 'False'}, "
            f"{'True' if show_text else 'False'}))\n"
        )
    handle.write("    return records^\n\n\n")


def main() -> None:
    german_label, german_source = load_catalog("german")
    english_label, english_source = load_catalog("english")
    german_records = flatten(build_tree(german_source))
    english_records = flatten(build_tree(english_source))

    if len(german_records) != 151 or len(english_records) != 151:
        raise SystemExit("unexpected Grundstrukturen tree size")
    if sum(record[2] for record in german_records) != 84:
        raise SystemExit("unexpected German leaf count")
    if sum(record[2] for record in english_records) != 84:
        raise SystemExit("unexpected English leaf count")

    with OUT.open("w", encoding="utf-8", newline="\n") as handle:
        handle.write(
            '"""Generated traversal catalog for the native Grundstrukturen HTML renderer.\n\n'
            "Source: ``python_reference/grundStrukHtml.py`` and its localized\n"
            "``wahl15`` data. Regenerate with\n"
            "``tools/generate_grundstrukturen_catalog.py``.\n"
            '"""\n\n'
            "from std.collections import List\n\n\n"
            "@fieldwise_init\n"
            "struct GrundstrukturRenderRecord(Copyable):\n"
            "    var depth: Int\n"
            "    var key: String\n"
            "    var is_leaf: Bool\n"
            "    var open_div: Bool\n"
            "    var show_text: Bool\n\n\n"
            f'def german_basic_structures_label() -> String:\n    return "{mojo_string(german_label)}"\n\n\n'
            f'def international_basic_structures_label() -> String:\n    return "{mojo_string(english_label)}"\n\n\n'
        )
        emit_function(handle, "german_grundstruktur_records", german_records)
        emit_function(handle, "international_grundstruktur_records", english_records)

    print(
        f"wrote {OUT}: {len(german_records)} German and "
        f"{len(english_records)} international records"
    )


if __name__ == "__main__":
    main()
