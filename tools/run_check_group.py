#!/usr/bin/env python3
"""Run independent repository checks with bounded process parallelism.

The manifest is tab separated:

    class<TAB>title<TAB>command<TAB>arg...

``parallel`` rows are executed concurrently up to ``--jobs``. ``serial`` and
``exclusive`` rows flush the current parallel batch and run alone. Every check
receives a private TMPDIR and output is printed in manifest order, so faster
checks cannot reorder the release log.
"""
from __future__ import annotations

import argparse
import concurrent.futures
import os
import shlex
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class CheckEntry:
    execution_class: str
    title: str
    argv: tuple[str, ...]


@dataclass(frozen=True)
class CheckResult:
    entry: CheckEntry
    returncode: int
    stdout: str
    stderr: str


def parse_manifest(path: Path) -> list[CheckEntry]:
    entries: list[CheckEntry] = []
    header_seen = False
    for line_number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not raw or raw.startswith("#"):
            continue
        if raw == "class\ttitle\tcommand\targs...":
            header_seen = True
            continue
        parts = raw.split("\t")
        if len(parts) < 3:
            raise ValueError(f"invalid manifest row {line_number}: {raw!r}")
        execution_class, title, *argv = parts
        if execution_class not in {"parallel", "serial", "exclusive"}:
            raise ValueError(
                f"invalid execution class on row {line_number}: {execution_class!r}"
            )
        if not title or not argv or not argv[0]:
            raise ValueError(f"incomplete manifest row {line_number}: {raw!r}")
        entries.append(CheckEntry(execution_class, title, tuple(argv)))
    if not header_seen:
        raise ValueError("check manifest header missing")
    return entries


def resolved_argv(entry: CheckEntry, root: Path) -> list[str]:
    argv = list(entry.argv)
    executable = Path(argv[0])
    if not executable.is_absolute() and "/" in argv[0]:
        argv[0] = str(root / executable)
    return argv


def run_one(
    entry: CheckEntry,
    root: Path,
    temp_root: Path,
    timeout: float | None,
    child_parallel_workers: int,
) -> CheckResult:
    safe_prefix = "".join(c if c.isalnum() or c in "-_" else "-" for c in entry.title)
    sandbox = Path(tempfile.mkdtemp(prefix=f"{safe_prefix[:48]}.", dir=temp_root))
    env = dict(os.environ)
    env["TMPDIR"] = str(sandbox)
    env["RETA_CHECK_SANDBOX"] = str(sandbox)
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    if child_parallel_workers > 0:
        # The outer scheduler owns process parallelism. Native table workers are
        # capped so jobs * child workers remains a predictable global ceiling.
        env["RETA_PARALLEL_WORKERS"] = str(child_parallel_workers)
    argv = resolved_argv(entry, root)
    try:
        completed = subprocess.run(
            argv,
            cwd=root,
            env=env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=timeout,
            check=False,
        )
        return CheckResult(
            entry,
            completed.returncode,
            completed.stdout,
            completed.stderr,
        )
    except subprocess.TimeoutExpired as exc:
        stdout = exc.stdout if isinstance(exc.stdout, str) else (exc.stdout or b"").decode(errors="replace")
        stderr = exc.stderr if isinstance(exc.stderr, str) else (exc.stderr or b"").decode(errors="replace")
        stderr += f"\nTIMEOUT after {timeout} seconds\n"
        return CheckResult(entry, 124, stdout, stderr)
    finally:
        shutil.rmtree(sandbox, ignore_errors=True)


def print_result(result: CheckResult, root: Path) -> None:
    command = shlex.join(resolved_argv(result.entry, root))
    print(f"\n== {result.entry.title} ==")
    print(f"+ {command}")
    if result.stdout:
        sys.stdout.write(result.stdout)
        if not result.stdout.endswith("\n"):
            sys.stdout.write("\n")
    if result.stderr:
        sys.stderr.write(result.stderr)
        if not result.stderr.endswith("\n"):
            sys.stderr.write("\n")
    if result.returncode != 0:
        print(
            f"FEHLER {result.entry.title}: Exitstatus {result.returncode}",
            file=sys.stderr,
        )


def run_parallel_batch(
    entries: list[CheckEntry],
    jobs: int,
    root: Path,
    temp_root: Path,
    timeout: float | None,
    child_parallel_workers: int,
) -> int:
    if not entries:
        return 0
    if jobs == 1:
        for entry in entries:
            result = run_one(entry, root, temp_root, timeout, child_parallel_workers)
            print_result(result, root)
            if result.returncode != 0:
                return result.returncode
        return 0

    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as executor:
        futures = {
            entry: executor.submit(
                run_one,
                entry,
                root,
                temp_root,
                timeout,
                child_parallel_workers,
            )
            for entry in entries
        }
        # Preserve manifest order in the visible report.
        results = [futures[entry].result() for entry in entries]

    status = 0
    for result in results:
        print_result(result, root)
        if status == 0 and result.returncode != 0:
            status = result.returncode
    return status


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--jobs", type=int, default=1)
    parser.add_argument("--timeout", type=float, default=0.0)
    parser.add_argument("--child-parallel-workers", type=int, default=0)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    if args.jobs < 1:
        parser.error("--jobs must be at least 1")
    if args.child_parallel_workers < 0:
        parser.error("--child-parallel-workers must be nonnegative")

    root = args.root.resolve()
    entries = parse_manifest(args.manifest)
    if args.dry_run:
        for entry in entries:
            command = shlex.join(resolved_argv(entry, root))
            print(f"[{entry.execution_class}] {entry.title}: {command}")
        return 0

    timeout = args.timeout if args.timeout > 0 else None
    temp_root = root / "target" / "check-groups-tmp"
    temp_root.mkdir(parents=True, exist_ok=True)

    pending: list[CheckEntry] = []
    for entry in entries:
        if entry.execution_class == "parallel":
            pending.append(entry)
            continue
        status = run_parallel_batch(
            pending,
            args.jobs,
            root,
            temp_root,
            timeout,
            args.child_parallel_workers,
        )
        pending.clear()
        if status != 0:
            return status
        result = run_one(
            entry,
            root,
            temp_root,
            timeout,
            args.child_parallel_workers,
        )
        print_result(result, root)
        if result.returncode != 0:
            return result.returncode

    return run_parallel_batch(
        pending,
        args.jobs,
        root,
        temp_root,
        timeout,
        args.child_parallel_workers,
    )


if __name__ == "__main__":
    raise SystemExit(main())
