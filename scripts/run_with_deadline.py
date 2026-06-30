#!/usr/bin/env python3
"""Run one command with a hard process-group deadline and captured stdout."""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import signal
import subprocess
import sys


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("seconds", type=float)
    parser.add_argument("output", type=Path)
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = args.command
    if command and command[0] == "--":
        command = command[1:]
    if not command:
        parser.error("a command is required after --")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("wb") as output:
        process = subprocess.Popen(
            command,
            stdout=output,
            start_new_session=True,
        )
        try:
            return process.wait(timeout=args.seconds)
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGKILL)
            # Do not wait indefinitely for a kernel-stuck reference process.
            # The test driver must regain control even if reaping is delayed.
            print(
                f"deadline exceeded after {args.seconds:g}s: {command!r}",
                file=sys.stderr,
            )
            return 124


if __name__ == "__main__":
    raise SystemExit(main())
