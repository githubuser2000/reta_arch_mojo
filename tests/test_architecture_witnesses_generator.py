#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import pathlib
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
GENERATOR = ROOT / "tools" / "generate_architecture_witnesses.py"
REFERENCE = ROOT / "python_reference"
GENERATED = ROOT / "src" / "reta_mojo" / "architecture_witnesses.mojo"


def generate(seed: str, destination: pathlib.Path) -> bytes:
    env = os.environ.copy()
    env["PYTHONHASHSEED"] = seed
    subprocess.run(
        [sys.executable, str(GENERATOR), "--reference-root", str(REFERENCE), "--output", str(destination)],
        check=True,
        cwd=ROOT,
        env=env,
    )
    return destination.read_bytes()


def main() -> None:
    expected = GENERATED.read_bytes()
    hashes: set[str] = set()
    with tempfile.TemporaryDirectory() as temp:
        temp_root = pathlib.Path(temp)
        for seed in ("0", "1", "42", "random"):
            payload = generate(seed, temp_root / f"witnesses-{seed}.mojo")
            assert payload == expected, f"generated witnesses differ for PYTHONHASHSEED={seed}"
            hashes.add(hashlib.sha256(payload).hexdigest())
    assert len(hashes) == 1

    sys.path.insert(0, str(REFERENCE))
    sys.path.insert(0, str(REFERENCE / "libs"))
    from reta_architecture.architecture_contracts import bootstrap_architecture_contracts
    from reta_architecture.architecture_map import bootstrap_architecture_map
    from reta_architecture.architecture_witnesses import bootstrap_architecture_witnesses
    from reta_architecture.category_theory import bootstrap_category_theory

    category_theory = bootstrap_category_theory()
    architecture_map = bootstrap_architecture_map()
    contracts = bootstrap_architecture_contracts(category_theory, architecture_map)
    snapshot = bootstrap_architecture_witnesses(
        REFERENCE, category_theory, architecture_map, contracts
    ).snapshot()
    assert snapshot["counts"] == {
        "anchor_witnesses": 536,
        "capsule_slices": 11,
        "diagram_witnesses": 33,
        "naturality_witnesses": 42,
        "obligations": 55,
    }
    validation = snapshot["validation"]
    assert validation["status"] == "passed"
    assert validation["file_like_anchor_count"] == 351
    assert validation["resolved_anchor_count"] == 351
    assert validation["symbolic_anchor_count"] == 185
    for key in (
        "missing_file_like_anchors",
        "uncovered_capsules",
        "uncovered_diagrams",
        "uncovered_laws",
        "uncovered_natural_transformations",
    ):
        assert validation[key] == []
    print("architecture_witnesses_generator=passed")
    print("sha256=" + next(iter(hashes)))


if __name__ == "__main__":
    main()
