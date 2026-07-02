from __future__ import annotations

import hashlib
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
REFERENCE = ROOT / "python_reference/libs/generate4readme.py"


def _reference(seed: str, english: bool) -> bytes:
    command = [sys.executable, str(REFERENCE)]
    if english:
        command.append("-language=english")
    env = os.environ.copy()
    env.update(
        {
            "PYTHONDONTWRITEBYTECODE": "1",
            "PYTHONHASHSEED": seed,
            "PYTHONPATH": str(ROOT / "python_reference"),
        }
    )
    return subprocess.run(
        command,
        cwd=ROOT,
        env=env,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).stdout


def test_readme_assets_reproduce_canonical_reference() -> None:
    subprocess.run(
        [sys.executable, "tools/generate_readme_assets.py", "--check"],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    )
    german = (ASSETS / "generated_readme_german.md").read_bytes()
    english = (ASSETS / "generated_readme_english.md").read_bytes()
    assert german == _reference("0", False)
    assert english == _reference("0", True)
    assert (len(german), german.count(b"\n")) == (13562, 206)
    assert (len(english), english.count(b"\n")) == (12877, 208)


def test_manifest_matches_assets() -> None:
    rows = [
        line.split("\t")
        for line in (ASSETS / "generated_readme_manifest.tsv")
        .read_text(encoding="utf-8")
        .splitlines()
        if line and not line.startswith("#")
    ]
    assert [row[0] for row in rows] == ["german", "english"]
    for language, filename, byte_count, lines, digest, seed in rows:
        payload = (ASSETS / filename).read_bytes()
        assert int(byte_count) == len(payload)
        assert int(lines) == payload.count(b"\n")
        assert digest == hashlib.sha256(payload).hexdigest()
        assert seed == "0"


def test_python_reference_is_hash_seed_dependent_and_documented() -> None:
    seed_zero = _reference("0", False)
    seed_one = _reference("1", False)
    assert seed_zero != seed_one
    zero_lines = seed_zero.decode("utf-8").splitlines()
    one_lines = seed_one.decode("utf-8").splitlines()
    changed = [
        index
        for index, (seed_zero_line, seed_one_line) in enumerate(
            zip(zero_lines, one_lines, strict=True)
        )
        if seed_zero_line != seed_one_line
    ]
    assert len(changed) == 4
    labels = [zero_lines[index - 1].strip() for index in changed]
    assert labels == [
        "* --gebrochengalaxie=",
        "* --gebrochenuniversum=",
        "* --gebrochenemotion=",
        "* --gebrochengroesse=",
    ]
    ledger = (ROOT / "KNOWN_DEFECTS.json").read_text(encoding="utf-8")
    assert "PY-CAND-012" in ledger


def test_native_owner_build_launcher_and_install_target_are_wired() -> None:
    module = (ROOT / "src/reta_mojo/readme_generator.mojo").read_text(encoding="utf-8")
    main = (ROOT / "src/generate_readme_main.mojo").read_text(encoding="utf-8")
    build = (ROOT / "scripts/build.sh").read_text(encoding="utf-8")
    targets = (ROOT / "scripts/install_targets.txt").read_text(encoding="utf-8")
    launcher = ROOT / "bin/generate4readme"
    assert "def generate_readme" in module
    assert "from std.python import" not in module
    assert "PythonObject" not in module
    assert "subprocess" not in module
    assert "print(document.text, end=\"\")" in main
    assert "generate_readme_main.mojo generate-readme-native" in build
    assert "generate-readme-native" in targets.splitlines()
    assert launcher.stat().st_mode & 0o111


def test_porting_matrix_marks_generate4readme_generated_native() -> None:
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(line for line in matrix.splitlines() if "`libs/generate4readme.py`" in line)
    assert "| generiert nativ |" in row
    assert "readme_generator.mojo" in row
