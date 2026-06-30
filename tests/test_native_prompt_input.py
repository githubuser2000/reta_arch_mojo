from __future__ import annotations

import os
import subprocess
from pathlib import Path


def test_native_probe_reads_pipe_and_persists_history(tmp_path: Path) -> None:
    root = Path(__file__).resolve().parents[1]
    probe = root / "target" / "tests" / "native-prompt-input-probe"
    assert probe.is_file(), f"missing built probe: {probe}"
    history = tmp_path / "history"
    result = subprocess.run(
        [str(probe), "1", str(history)],
        input="prim 12\n",
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
        env={**os.environ, "HOME": str(tmp_path)},
    )
    assert result.stdout == "native> <LINE>prim 12\n"
    assert history.read_text(encoding="utf-8") == "prim 12\n"


def test_native_probe_maps_pipe_eof_to_historical_sentinel(tmp_path: Path) -> None:
    root = Path(__file__).resolve().parents[1]
    probe = root / "target" / "tests" / "native-prompt-input-probe"
    result = subprocess.run(
        [str(probe), "0", str(tmp_path / "history")],
        input="",
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
    )
    assert result.stdout == "native> <EOF>\n"
