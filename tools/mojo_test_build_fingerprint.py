#!/usr/bin/env python3
"""Compute conservative content fingerprints for Mojo test binaries.

Local Mojo imports are followed transitively. Unknown local imports are encoded
as markers, so removing or renaming a dependency changes the fingerprint rather
than accidentally reusing an old executable.
"""
from __future__ import annotations

import argparse
import hashlib
import re
from functools import lru_cache
from pathlib import Path

IMPORT_RE = re.compile(
    r"^\s*(?:from\s+(?P<from>[A-Za-z_][\w.]*|\.+[A-Za-z_][\w.]*)\s+import\b|"
    r"import\s+(?P<import>[A-Za-z_][\w.]*))",
    re.MULTILINE,
)


def link_profile(entry: Path) -> str:
    rel = entry.as_posix()
    if rel.endswith("test_execution_network_persistence.mojo") or rel.endswith("test_persistence.mojo"):
        return "sqlite-crypto"
    if rel.endswith("test_package_integrity.mojo"):
        return "crypto"
    return "default"


class DependencyGraph:
    def __init__(self, root: Path):
        self.root = root.resolve()

    def candidates(self, source: Path, module: str) -> list[Path]:
        if module.startswith("."):
            dots = len(module) - len(module.lstrip("."))
            tail = module[dots:]
            base = source.parent
            for _ in range(max(0, dots - 1)):
                base = base.parent
            rel = Path(*tail.split(".")) if tail else Path("__init__")
            return [base / rel.with_suffix(".mojo"), base / rel / "__init__.mojo"]
        rel = Path(*module.split("."))
        return [
            self.root / "src" / rel.with_suffix(".mojo"),
            self.root / "src" / rel / "__init__.mojo",
            self.root / "tests" / rel.with_suffix(".mojo"),
            self.root / "tests" / rel / "__init__.mojo",
        ]

    @lru_cache(maxsize=None)
    def direct(self, source: Path) -> tuple[tuple[Path, ...], tuple[str, ...]]:
        if not source.is_file():
            return (), (f"missing:{source}",)
        dependencies: set[Path] = set()
        unresolved: set[str] = set()
        text = source.read_text(encoding="utf-8")
        for match in IMPORT_RE.finditer(text):
            module = match.group("from") or match.group("import")
            resolved = next((p.resolve() for p in self.candidates(source, module) if p.is_file()), None)
            if resolved is not None:
                dependencies.add(resolved)
            elif module.startswith(".") or module.startswith("reta_mojo"):
                try:
                    rel = source.relative_to(self.root)
                except ValueError:
                    rel = source
                unresolved.add(f"unresolved:{rel}:{module}")
        return tuple(sorted(dependencies)), tuple(sorted(unresolved))

    def closure(self, entry: Path) -> tuple[list[Path], list[str]]:
        pending = [entry.resolve()]
        seen: set[Path] = set()
        unresolved: set[str] = set()
        while pending:
            source = pending.pop()
            if source in seen:
                continue
            seen.add(source)
            dependencies, markers = self.direct(source)
            pending.extend(dependencies)
            unresolved.update(markers)
        return sorted(seen), sorted(unresolved)


def fingerprint(graph: DependencyGraph, entry: Path, context_id: str, profile: str) -> str:
    digest = hashlib.sha256()
    digest.update(b"reta-mojo-test-build-v2\0")
    digest.update(context_id.encode())
    digest.update(b"\0")
    digest.update(profile.encode())
    digest.update(b"\0")
    files, unresolved = graph.closure(entry)
    # Importing a package submodule may also make package metadata relevant.
    # Hash package __init__.mojo files without traversing their broad re-export
    # graph, preserving safety without turning every submodule test into a
    # package-wide rebuild.
    package_init = graph.root / "src/reta_mojo/__init__.mojo"
    if package_init.is_file() and any(
        path.is_relative_to(graph.root / "src/reta_mojo") for path in files
    ):
        files = sorted(set(files) | {package_init.resolve()})
    for path in files:
        try:
            rel = path.relative_to(graph.root).as_posix()
        except ValueError:
            rel = str(path)
        digest.update(b"file\0" + rel.encode() + b"\0")
        if path.is_symlink():
            digest.update(b"link\0" + str(path.readlink()).encode() + b"\0")
        if path.is_file():
            digest.update(path.read_bytes())
        digest.update(b"\0")
    for marker in unresolved:
        digest.update(b"marker\0" + marker.encode() + b"\0")
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("tests", type=Path, nargs="+")
    parser.add_argument("--context-id", required=True)
    parser.add_argument("--link-profile")
    parser.add_argument("--list-dependencies", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    graph = DependencyGraph(root)
    for raw in args.tests:
        entry = (root / raw).resolve() if not raw.is_absolute() else raw.resolve()
        if args.list_dependencies:
            files, unresolved = graph.closure(entry)
            for path in files:
                print(path.relative_to(root))
            for marker in unresolved:
                print(marker)
            continue
        profile = args.link_profile or link_profile(entry)
        try:
            rel = entry.relative_to(root).as_posix()
        except ValueError:
            rel = str(entry)
        print(f"{rel}\t{fingerprint(graph, entry, args.context_id, profile)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
