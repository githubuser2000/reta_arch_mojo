from __future__ import annotations

import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def test_generated_native_cli_help_assets_are_current() -> None:
    result = subprocess.run(
        [sys.executable, "tools/generate_native_cli_help_assets.py", "--check"],
        cwd=ROOT,
        env={
            **os.environ,
            "RETA_REFERENCE_PYTHON": os.environ.get(
                "RETA_REFERENCE_PYTHON", sys.executable
            ),
        },
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr.decode("utf-8", errors="replace")
    assert b"reta_help_de.txt: 12042 bytes" in result.stdout
    assert b"reta_help_en.txt: 11409 bytes" in result.stdout
