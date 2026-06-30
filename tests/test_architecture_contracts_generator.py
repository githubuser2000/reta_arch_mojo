#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import pathlib
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
GENERATOR = ROOT / "tools" / "generate_architecture_contracts.py"
REFERENCE = ROOT / "python_reference"
GENERATED = ROOT / "src" / "reta_mojo" / "architecture_contracts.mojo"


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
            payload = generate(seed, temp_root / f"contracts-{seed}.mojo")
            assert payload == expected, f"generated contracts differ for PYTHONHASHSEED={seed}"
            hashes.add(hashlib.sha256(payload).hexdigest())
    assert len(hashes) == 1

    sys.path.insert(0, str(REFERENCE))
    sys.path.insert(0, str(REFERENCE / "libs"))
    from reta_architecture.architecture_contracts import bootstrap_architecture_contracts
    from reta_architecture.architecture_map import bootstrap_architecture_map
    from reta_architecture.category_theory import bootstrap_category_theory

    snapshot = bootstrap_architecture_contracts(
        bootstrap_category_theory(), bootstrap_architecture_map()
    ).snapshot()
    assert snapshot["counts"] == {
        "commutative_diagrams": 33,
        "capsule_contracts": 11,
        "laws": 22,
    }
    assert snapshot["validation"]["status"] == "passed"
    for key in (
        "missing_capsules",
        "missing_categories",
        "missing_functors",
        "missing_natural_transformations",
    ):
        assert snapshot["validation"][key] == []
    print("architecture_contracts_generator=passed")
    print("sha256=" + next(iter(hashes)))


if __name__ == "__main__":
    main()
