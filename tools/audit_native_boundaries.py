#!/usr/bin/env python3
"""Audit explicit native/Python/subprocess boundaries and thread-only kernels."""

from __future__ import annotations

import argparse
import csv
import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INVENTORY = ROOT / "assets/native_bridge_inventory.tsv"
THREAD_MODULES = (
    ROOT / "src/reta_mojo/execution_network.mojo",
    ROOT / "src/reta_mojo/parallel_execution.mojo",
    ROOT / "src/reta_mojo/parallel_row_preparation.mojo",
)
FORBIDDEN_PROCESS_PATTERNS = {
    "fork": re.compile(r'external_call\[\s*["\']fork["\']'),
    "waitpid": re.compile(r'external_call\[\s*["\']waitpid["\']'),
    "pipe": re.compile(r'external_call\[\s*["\']pipe["\']'),
    "_exit": re.compile(r'external_call\[\s*["\']_exit["\']'),
}
BRIDGE_IMPORT = re.compile(r"^from\s+std\.(python|subprocess)\s+import\s+", re.MULTILINE)


@dataclass(frozen=True)
class Bridge:
    path: str
    kind: str
    status: str
    purpose: str
    target_stage: str


def load_inventory() -> list[Bridge]:
    with INVENTORY.open(encoding="utf-8", newline="") as handle:
        rows = csv.DictReader(handle, delimiter="\t")
        return [Bridge(**row) for row in rows]


def discover_bridges() -> dict[str, str]:
    found: dict[str, str] = {}
    for path in sorted((ROOT / "src").rglob("*.mojo")):
        text = path.read_text(encoding="utf-8")
        matches = sorted(set(BRIDGE_IMPORT.findall(text)))
        if not matches:
            continue
        if len(matches) != 1:
            raise AssertionError(f"multiple bridge kinds in {path.relative_to(ROOT)}: {matches}")
        found[path.relative_to(ROOT).as_posix()] = f"std.{matches[0]}"
    return found


def audit() -> dict[str, object]:
    inventory = load_inventory()
    expected = {entry.path: entry.kind for entry in inventory if entry.status == "active"}
    discovered = discover_bridges()
    if discovered != expected:
        missing = sorted(set(expected) - set(discovered))
        unexpected = sorted(set(discovered) - set(expected))
        wrong = sorted(
            path
            for path in set(expected) & set(discovered)
            if expected[path] != discovered[path]
        )
        raise AssertionError(
            "native bridge inventory mismatch: "
            f"missing={missing}, unexpected={unexpected}, wrong_kind={wrong}"
        )

    violations: list[str] = []
    for path in sorted((ROOT / "src").rglob("*.mojo")):
        text = path.read_text(encoding="utf-8")
        for name, pattern in FORBIDDEN_PROCESS_PATTERNS.items():
            if pattern.search(text):
                violations.append(f"{path.relative_to(ROOT)}:{name}")
    if violations:
        raise AssertionError("native POSIX process primitives remain: " + ", ".join(violations))

    for path in THREAD_MODULES:
        text = path.read_text(encoding="utf-8")
        if BRIDGE_IMPORT.search(text):
            raise AssertionError(f"thread kernel imports a Python/subprocess bridge: {path.relative_to(ROOT)}")
        if "from std.algorithm import parallelize" not in text:
            raise AssertionError(f"thread kernel lacks parallelize backend: {path.relative_to(ROOT)}")

    parallel_text = (ROOT / "src/reta_mojo/parallel_execution.mojo").read_text(encoding="utf-8")
    execution_text = (ROOT / "src/reta_mojo/execution_network.mojo").read_text(encoding="utf-8")
    required_symbols = (
        "decode_religion_rows_threaded",
        "decode_kombi_rows_threaded",
        "moon_numbers_threaded",
        "prime_factors_threaded",
        "filter_numbers_threaded",
        "factor_pairs_threaded",
        "select_columns_threaded",
        "max_cell_text_len_threaded",
        "normalize_column_buckets_threaded",
        "prepare_kombi_join_tables_threaded",
    )
    missing_symbols = [symbol for symbol in required_symbols if f"def {symbol}(" not in parallel_text]
    if missing_symbols:
        raise AssertionError(f"missing canonical thread APIs: {missing_symbols}")
    if "def _run_threads(" not in execution_text:
        raise AssertionError("execution network has no native thread runner")

    return {
        "active_bridges": [asdict(entry) for entry in inventory if entry.status == "active"],
        "active_bridge_count": len(expected),
        "thread_modules": [path.relative_to(ROOT).as_posix() for path in THREAD_MODULES],
        "thread_module_count": len(THREAD_MODULES),
        "native_posix_process_primitives": 0,
        "canonical_thread_api_count": len(required_symbols),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    result = audit()
    if args.json:
        print(json.dumps(result, ensure_ascii=False, sort_keys=True, separators=(",", ":")))
    else:
        print(
            "native boundary audit: "
            f"{result['native_posix_process_primitives']} process primitives, "
            f"{result['thread_module_count']} thread modules, "
            f"{result['active_bridge_count']} explicit bridges"
        )


if __name__ == "__main__":
    main()
