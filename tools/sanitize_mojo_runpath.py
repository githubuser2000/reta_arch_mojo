#!/usr/bin/env python3
"""Remove compiler-installation paths from ELF RUNPATH/RPATH strings.

Mojo 1.0.0b2 automatically adds its own absolute ``modular/lib`` directory even
when the build also supplies a portable ``$ORIGIN`` runpath.  The dynamic string
entry can safely be shortened in place: ELF string-table offsets remain stable
and the unused tail is filled with NUL bytes.
"""
from __future__ import annotations

import argparse
import os
import re
import subprocess
from pathlib import Path

PORTABLE_COMPONENT = "$ORIGIN/../lib/mojo"
PATH_RE = re.compile(r"Library r(?:un)?path: \[(.*?)\]")


def read_runpath(path: Path) -> str | None:
    result = subprocess.run(
        ["readelf", "-d", os.fspath(path)],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        return None
    for line in result.stdout.splitlines():
        match = PATH_RE.search(line)
        if match:
            return match.group(1)
    return None


def portable_runpath(old: str) -> str:
    components = [part for part in old.split(":") if part]
    portable = [part for part in components if "$ORIGIN" in part]
    if PORTABLE_COMPONENT not in portable:
        portable.append(PORTABLE_COMPONENT)
    # Preserve order but remove duplicates.
    return ":".join(dict.fromkeys(portable))


def sanitize(path: Path, *, check_only: bool = False) -> bool:
    old = read_runpath(path)
    if old is None:
        return False
    new = portable_runpath(old)
    if old == new:
        return True
    if check_only:
        raise SystemExit(f"non-portable RUNPATH in {path}: {old}")
    old_bytes = old.encode()
    new_bytes = new.encode()
    if len(new_bytes) > len(old_bytes):
        raise SystemExit(f"cannot grow ELF RUNPATH in place: {path}: {old!r} -> {new!r}")
    payload = path.read_bytes()
    count = payload.count(old_bytes)
    if count < 1:
        raise SystemExit(f"RUNPATH string not found in ELF bytes: {path}: {old}")
    replacement = new_bytes + b"\0" * (len(old_bytes) - len(new_bytes))
    path.write_bytes(payload.replace(old_bytes, replacement, 1))
    path.chmod(path.stat().st_mode | 0o111)
    observed = read_runpath(path)
    if observed != new:
        raise SystemExit(f"RUNPATH verification failed for {path}: {observed!r} != {new!r}")
    return True


def iter_candidates(paths: list[Path]):
    for path in paths:
        if path.is_dir():
            for child in sorted(path.iterdir()):
                if child.is_file():
                    yield child
        elif path.is_file():
            yield path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("paths", nargs="+", type=Path)
    args = parser.parse_args()
    seen = 0
    for path in iter_candidates(args.paths):
        if sanitize(path, check_only=args.check):
            seen += 1
            print(f"portable RUNPATH: {path}")
    if seen == 0:
        raise SystemExit("no ELF file with RUNPATH/RPATH found")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
