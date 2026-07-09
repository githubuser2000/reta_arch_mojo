"""PTY-level parity for the exact public ``rpb a1`` command."""
from __future__ import annotations

import errno
import fcntl
import os
from pathlib import Path
import pty
import re
import struct
import subprocess

ROOT = Path(__file__).resolve().parents[1]
ANSI = re.compile(rb"\x1b\[[0-?]*[ -/]*[@-~]")


def _run_pty(command: list[str], columns: int) -> bytes:
    master, slave = pty.openpty()
    try:
        fcntl.ioctl(slave, 0x5414, struct.pack("HHHH", 40, columns, 0, 0))
        env = os.environ.copy()
        env.setdefault("TERM", "xterm-256color")
        process = subprocess.Popen(
            command,
            cwd=ROOT,
            stdin=slave,
            stdout=slave,
            stderr=slave,
            env=env,
            close_fds=True,
        )
    finally:
        os.close(slave)

    chunks: list[bytes] = []
    try:
        while True:
            try:
                chunk = os.read(master, 65536)
            except OSError as exc:
                if exc.errno == errno.EIO:
                    break
                raise
            if not chunk:
                break
            chunks.append(chunk)
    finally:
        os.close(master)
    return_code = process.wait(timeout=120)
    output = b"".join(chunks).replace(b"\r\n", b"\n").replace(b"\r", b"\n")
    assert return_code == 0, output.decode("utf-8", "replace")
    return output


def _visible_lines(output: bytes) -> list[bytes]:
    return [ANSI.sub(b"", line).rstrip() for line in output.splitlines()]


def test_terminal_geometry_probe_tracks_real_pty_width() -> None:
    probe = Path(
        os.environ.get(
            "RETA_TERMINAL_GEOMETRY_PROBE",
            ROOT / "target" / "test-bin" / "terminal-geometry-probe",
        )
    )
    assert probe.is_file() and os.access(probe, os.X_OK), (
        "check_prompt_terminal_parity.sh must compile the geometry probe first"
    )

    for columns in (80, 120, 200):
        visible = _visible_lines(_run_pty([str(probe)], columns))
        assert visible == [f"{columns} {columns - 7}".encode()]


def test_rpb_a1_matches_python_at_real_terminal_widths() -> None:
    prompt = ROOT / "target" / "bin" / "reta-prompt-native"
    assert prompt.is_file() and os.access(prompt, os.X_OK), (
        "scripts/build.sh must compile target/bin/reta-prompt-native first"
    )

    for columns in (80, 120, 200):
        reference = _visible_lines(
            _run_pty(["python3", "python_reference/rpb", "a1"], columns)
        )
        native = _visible_lines(_run_pty(["tools/wrappers/rpb", "a1"], columns))
        assert native == reference, f"rpb a1 differs at {columns} columns"
        assert native[0].endswith(b"reta-Befehl:")
        assert native[1].startswith(b"reta -zeilen ")
        assert b"Intrinsische" not in native[1]

        table_lines = native[2:]
        assert table_lines
        assert max(map(len, table_lines)) <= columns
        # The historical output uses almost the complete screen rather than
        # silently reverting to the old 80-column default.
        assert max(map(len, table_lines)) >= columns - 4
