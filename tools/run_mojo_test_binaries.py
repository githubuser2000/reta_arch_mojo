#!/usr/bin/env python3
"""Run precompiled Mojo test binaries with conservative parallel barriers."""
from __future__ import annotations

import argparse
import concurrent.futures
import os
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class TestEntry:
    name: str
    source: str
    binary: Path
    execution_class: str


@dataclass(frozen=True)
class TestResult:
    entry: TestEntry
    returncode: int
    stdout: str
    stderr: str


def parse_manifest(path: Path) -> list[TestEntry]:
    entries: list[TestEntry] = []
    header_seen = False
    for raw in path.read_text(encoding="utf-8").splitlines():
        if not raw or raw.startswith("#") or raw.startswith("source_id\t") or raw.startswith("heavy\t"):
            continue
        if raw == "name\tsource\tbinary\tclass":
            header_seen = True
            continue
        parts = raw.split("\t")
        if len(parts) != 4:
            raise ValueError(f"invalid manifest row: {raw!r}")
        name, source, binary, execution_class = parts
        if execution_class not in {"parallel", "serial", "exclusive"}:
            raise ValueError(f"invalid execution class for {name}: {execution_class}")
        entries.append(TestEntry(name, source, Path(binary), execution_class))
    if not header_seen:
        raise ValueError("test manifest header missing")
    return entries


def run_one(entry: TestEntry, runtime_exec: Path, root: Path, temp_root: Path, timeout: float | None) -> TestResult:
    sandbox = Path(tempfile.mkdtemp(prefix=f"{entry.name}.", dir=temp_root))
    env = dict(os.environ)
    env["TMPDIR"] = str(sandbox)
    env["RETA_TEST_SANDBOX"] = str(sandbox)
    try:
        proc = subprocess.run(
            [str(runtime_exec), str(entry.binary)],
            cwd=root,
            env=env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=timeout,
            check=False,
        )
        return TestResult(entry, proc.returncode, proc.stdout, proc.stderr)
    except subprocess.TimeoutExpired as exc:
        stdout = exc.stdout if isinstance(exc.stdout, str) else (exc.stdout or b"").decode(errors="replace")
        stderr = exc.stderr if isinstance(exc.stderr, str) else (exc.stderr or b"").decode(errors="replace")
        stderr += f"\nTIMEOUT after {timeout} seconds\n"
        return TestResult(entry, 124, stdout, stderr)
    finally:
        shutil.rmtree(sandbox, ignore_errors=True)


def print_result(result: TestResult) -> None:
    print(f"\n== run {result.entry.name} ==")
    if result.stdout:
        sys.stdout.write(result.stdout)
        if not result.stdout.endswith("\n"):
            sys.stdout.write("\n")
    if result.stderr:
        sys.stderr.write(result.stderr)
        if not result.stderr.endswith("\n"):
            sys.stderr.write("\n")
    if result.returncode != 0:
        print(f"FAIL {result.entry.name}: exit status {result.returncode}", file=sys.stderr)


def run_parallel_group(
    entries: list[TestEntry],
    jobs: int,
    runtime_exec: Path,
    root: Path,
    temp_root: Path,
    timeout: float | None,
) -> int:
    if not entries:
        return 0
    if jobs == 1:
        for entry in entries:
            result = run_one(entry, runtime_exec, root, temp_root, timeout)
            print_result(result)
            if result.returncode != 0:
                return result.returncode
        return 0

    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as executor:
        futures = {
            entry: executor.submit(run_one, entry, runtime_exec, root, temp_root, timeout)
            for entry in entries
        }
        # Print in manifest order even though processes complete out of order.
        results = [futures[entry].result() for entry in entries]
    status = 0
    for result in results:
        print_result(result)
        if status == 0 and result.returncode != 0:
            status = result.returncode
    return status


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--runtime-exec", type=Path, required=True)
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--jobs", type=int, default=1)
    parser.add_argument("--timeout", type=float, default=0.0)
    args = parser.parse_args()
    if args.jobs < 1:
        parser.error("--jobs must be at least 1")
    timeout = args.timeout if args.timeout > 0 else None
    entries = parse_manifest(args.manifest)
    temp_root = args.manifest.parent / ".run-tmp"
    temp_root.mkdir(parents=True, exist_ok=True)

    pending: list[TestEntry] = []
    for entry in entries:
        if entry.execution_class == "parallel":
            pending.append(entry)
            continue
        status = run_parallel_group(pending, args.jobs, args.runtime_exec, args.root, temp_root, timeout)
        pending.clear()
        if status != 0:
            return status
        # serial and exclusive are both barriers. The distinction is retained
        # in the manifest so future schedulers may apply resource policies.
        result = run_one(entry, args.runtime_exec, args.root, temp_root, timeout)
        print_result(result)
        if result.returncode != 0:
            return result.returncode
    return run_parallel_group(pending, args.jobs, args.runtime_exec, args.root, temp_root, timeout)


if __name__ == "__main__":
    raise SystemExit(main())
