#!/usr/bin/env python3
"""Verify the visible localized storage prompt through a real PTY."""
from __future__ import annotations

import argparse
import os
import pty
import re
import select
import subprocess
import time
from pathlib import Path

ANSI = re.compile(r"\x1b\[[0-?]*[ -/]*[@-~]")


def read_for(master: int, seconds: float) -> bytes:
    deadline = time.monotonic() + seconds
    data = bytearray()
    while time.monotonic() < deadline:
        readable, _, _ = select.select([master], [], [], 0.1)
        if not readable:
            continue
        try:
            chunk = os.read(master, 65536)
        except OSError:
            break
        if not chunk:
            break
        data.extend(chunk)
    return bytes(data)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "binary",
        nargs="?",
        type=Path,
        default=Path("target/bin/reta-prompt-native"),
    )
    args = parser.parse_args()
    binary = args.binary.resolve()
    if not binary.is_file():
        raise SystemExit(f"missing prompt binary: {binary}")

    master, slave = pty.openpty()
    process = subprocess.Popen(
        [str(binary), "retaPrompt", "-language=english"],
        stdin=slave,
        stdout=slave,
        stderr=slave,
        close_fds=True,
    )
    os.close(slave)
    try:
        output = bytearray(read_for(master, 1.5))
        os.write(master, b"S\n")
        output.extend(read_for(master, 2.0))
    finally:
        process.terminate()
        try:
            process.wait(timeout=2)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait(timeout=2)
        os.close(master)

    text = ANSI.sub("", output.decode("utf-8", "replace")).replace("\r", "")
    if "save what>" not in text:
        raise SystemExit("localized English storage prefix missing\n" + text)
    if "speichern> " in text or "loeschen> " in text:
        raise SystemExit("obsolete German prompt prefix leaked\n" + text)
    print("PTY-Promptpräfix ist exakt lokalisiert: save what>")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
