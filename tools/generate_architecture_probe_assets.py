#!/usr/bin/env python3
"""Generate deterministic assets for the native architecture probe.

The Python architecture remains the reference during migration, but the
installed probe never imports or executes Python.  This generator freezes the
observable JSON/Markdown command surfaces into immutable UTF-8 assets.  The
native runtime reads those assets through ``resource_paths.asset_resource``.
"""
from __future__ import annotations

import argparse
import errno
import hashlib
import json
import os
import shutil
import sys
import tempfile
import time
from contextlib import contextmanager
from unittest.mock import patch
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
PYROOT = ROOT / "python_reference"
OUT = ROOT / "assets" / "architecture_probe"
SOURCE_MANIFEST = ROOT / "SOURCE_MANIFEST.sha256"
SYMLINK_MANIFEST = ROOT / "SOURCE_SYMLINKS.txt"
CANONICAL_HOME = "/__reta_canonical_home__"
CANONICAL_PROCESSOR_CORES = 8
REFERENCE_TOKEN = "@@RETA_REFERENCE_ROOT@@"
HOME_TOKEN = "@@RETA_HOME@@"


def _remove_tree_with_retries(path: Path) -> None:
    """Remove a cache tree even if another process briefly recreates entries."""
    for attempt in range(12):
        try:
            shutil.rmtree(path)
        except FileNotFoundError:
            return
        except OSError as exc:
            if exc.errno not in (errno.ENOTEMPTY, errno.EBUSY):
                raise
            if attempt == 11:
                raise
            time.sleep(0.01 * (attempt + 1))
        else:
            if not path.exists():
                return
    raise RuntimeError(f"runtime cache tree survived cleanup: {path}")


def _runtime_artifact_paths(reference_root: Path) -> list[Path]:
    result: list[Path] = []
    for directory_name in ("__pycache__", ".pytest_cache", ".mypy_cache"):
        result.extend(path for path in reference_root.rglob(directory_name) if path.is_dir())
    for suffix in ("*.pyc", "*.pyo"):
        result.extend(path for path in reference_root.rglob(suffix) if path.is_file())
    return result


def _remove_runtime_artifacts(reference_root: Path) -> None:
    """Keep snapshots independent of caches, including concurrent recreation."""
    for sweep in range(8):
        for path in _runtime_artifact_paths(reference_root):
            try:
                if path.is_dir():
                    _remove_tree_with_retries(path)
                else:
                    path.unlink(missing_ok=True)
            except FileNotFoundError:
                pass
        remaining = _runtime_artifact_paths(reference_root)
        if not remaining:
            return
        if sweep < 7:
            time.sleep(0.02 * (sweep + 1))
    rendered = ", ".join(str(path) for path in remaining[:8])
    raise RuntimeError(f"runtime artifacts survived cleanup: {rendered}")


def _manifest_regular_files() -> list[tuple[str, str]]:
    if not SOURCE_MANIFEST.exists():
        raise RuntimeError(f"missing canonical source manifest: {SOURCE_MANIFEST}")
    entries: list[tuple[str, str]] = []
    prefix = "./python_reference/"
    for line in SOURCE_MANIFEST.read_text(encoding="utf-8").splitlines():
        if "  " not in line:
            continue
        digest, relative = line.split("  ", 1)
        if relative.startswith(prefix):
            entries.append((digest, relative[2:]))
    if not entries:
        raise RuntimeError("SOURCE_MANIFEST.sha256 contains no python_reference files")
    return entries


def _manifest_symlinks() -> list[tuple[str, str]]:
    if not SYMLINK_MANIFEST.exists():
        raise RuntimeError(f"missing canonical symlink manifest: {SYMLINK_MANIFEST}")
    entries: list[tuple[str, str]] = []
    prefix = "./python_reference/"
    for line in SYMLINK_MANIFEST.read_text(encoding="utf-8").splitlines():
        if " -> " not in line:
            continue
        relative, target = line.split(" -> ", 1)
        if relative.startswith(prefix):
            entries.append((relative[2:], target))
    return entries


@contextmanager
def _canonical_reference_tree():
    """Materialise only manifest-owned Python reference inputs outside Git.

    Local build outputs, untracked files, a parent ``.git`` directory and prior
    runtime caches must not change immutable architecture-probe assets.
    """
    with tempfile.TemporaryDirectory(prefix="reta-architecture-reference-") as temp:
        temp_root = Path(temp)
        for expected_digest, relative in _manifest_regular_files():
            source = ROOT / relative
            if not source.is_file() or source.is_symlink():
                raise RuntimeError(f"manifest source is missing or not regular: {relative}")
            payload = source.read_bytes()
            actual_digest = hashlib.sha256(payload).hexdigest()
            if actual_digest != expected_digest:
                raise RuntimeError(
                    f"canonical Python reference input changed without manifest update: {relative}"
                )
            destination = temp_root / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(payload)
        for relative, target in _manifest_symlinks():
            destination = temp_root / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.symlink_to(target)
        reference_root = temp_root / "python_reference"
        _remove_runtime_artifacts(reference_root)
        yield reference_root


def _prepare_imports(reference_root: Path) -> None:
    sys.dont_write_bytecode = True
    for module_name in tuple(sys.modules):
        if module_name == "reta_architecture" or module_name.startswith("reta_architecture."):
            del sys.modules[module_name]
    for value in (reference_root, reference_root / "libs", reference_root / "i18n"):
        sys.path.insert(0, str(value))

def _json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, separators=(",", ":")) + "\n"


def _markdown(
    title: str,
    section: str,
    text_diagram: str,
    mermaid_diagram: str,
) -> str:
    return (
        f"# {title}\n\n"
        f"## {section}\n\n"
        "```text\n"
        f"{text_diagram.rstrip()}\n"
        "```\n\n"
        "## Mermaid\n\n"
        f"{mermaid_diagram.rstrip()}\n"
    )


def build_assets() -> dict[str, str]:
    _remove_runtime_artifacts(PYROOT)
    with _canonical_reference_tree() as reference_root:
        _prepare_imports(reference_root)
        canonical_environment = {
            "HOME": CANONICAL_HOME,
            "COLUMNS": "80",
            "LINES": "80",
            "RETA_ARCHITECTURE_CANONICAL_SNAPSHOT": "1",
        }
        real_path_exists = os.path.exists

        def canonical_path_exists(path: object) -> bool:
            if os.fspath(path) == "/proc/cpuinfo":
                return False
            return real_path_exists(path)

        with open(os.devnull, "r", encoding="utf-8") as null_stdin, patch.dict(
            os.environ, canonical_environment, clear=False
        ), patch.object(sys, "stdin", null_stdin), patch(
            "os.get_terminal_size", side_effect=OSError
        ), patch(
            "os.cpu_count", return_value=CANONICAL_PROCESSOR_CORES
        ), patch(
            "os.process_cpu_count", return_value=CANONICAL_PROCESSOR_CORES, create=True
        ), patch(
            "os.sched_getaffinity",
            return_value=set(range(CANONICAL_PROCESSOR_CORES)),
            create=True,
        ), patch(
            "os.path.exists", side_effect=canonical_path_exists
        ):
            from reta_architecture import RetaArchitecture  # type: ignore
            import reta_architecture.architecture_progress as progress_module  # type: ignore

            progress_module._parity_reference_state = lambda _repo_root: (
                False,
                "no external archive and no readable git baseline available",
            )
            architecture = RetaArchitecture.bootstrap(reference_root, use_cache=False)
            snapshot = architecture.snapshot()

            values: dict[str, Any] = {
                "snapshot-json": snapshot,
                "schema-json": snapshot["schema"],
                "module-split-json": snapshot["schema"].get("schema_modules", {}),
                "topology-json": snapshot["topology"],
                "inputs-json": snapshot["inputs"],
                "word-completion-json": architecture.bootstrap_word_completion().snapshot(),
                "nested-completion-json": architecture.bootstrap_nested_completion().snapshot(),
                "row-ranges-json": architecture.bootstrap_row_ranges().snapshot(),
                "arithmetic-json": architecture.bootstrap_arithmetic().snapshot(),
                "console-io-json": architecture.bootstrap_console_io().snapshot(),
                "column-selection-json": architecture.bootstrap_column_selection().snapshot(),
                "parameter-runtime-json": architecture.bootstrap_parameter_runtime().snapshot(),
                "program-workflow-json": architecture.bootstrap_program_workflow().snapshot(),
                "table-generation-json": architecture.bootstrap_table_generation().snapshot(),
                "table-preparation-json": architecture.bootstrap_table_preparation().snapshot(),
                "row-filtering-json": architecture.bootstrap_row_filtering().snapshot(),
                "table-wrapping-json": architecture.bootstrap_table_wrapping().snapshot(),
                "table-state-json": architecture.bootstrap_table_state().snapshot(),
                "number-theory-json": architecture.bootstrap_number_theory().snapshot(),
                "table-output-json": architecture.bootstrap_table_output().snapshot(),
                "table-runtime-json": architecture.bootstrap_table_runtime().snapshot(),
                "generated-columns-json": architecture.bootstrap_generated_columns().snapshot(),
                "meta-columns-json": architecture.bootstrap_meta_columns().snapshot(),
                "concat-csv-json": architecture.bootstrap_concat_csv().snapshot(),
                "combi-join-json": architecture.bootstrap_combi_join().snapshot(),
                "prompt-runtime-json": architecture.bootstrap_prompt_runtime().snapshot(),
                "completion-runtime-json": architecture.bootstrap_completion_runtime().snapshot(),
                "prompt-session-json": architecture.bootstrap_prompt_session().snapshot(),
                "prompt-execution-json": architecture.bootstrap_prompt_execution().snapshot(),
                "prompt-preparation-json": architecture.bootstrap_prompt_preparation().snapshot(),
                "prompt-interaction-json": architecture.bootstrap_prompt_interaction().snapshot(),
                "output-syntax-json": architecture.bootstrap_output_syntax().snapshot(),
                "output-json": snapshot["output_semantics"],
                "prompt-language-json": architecture.bootstrap_prompt_language().snapshot(),
                "presheaves-json": snapshot["presheaves"],
                "sheaves-json": snapshot["sheaves"],
                "morphisms-json": snapshot["morphisms"],
                "universal-json": snapshot["universal"],
                "category-theory-json": architecture.bootstrap_category_theory().snapshot(),
                "architecture-map-json": architecture.bootstrap_architecture_map().snapshot(),
                "architecture-contracts-json": architecture.bootstrap_architecture_contracts().snapshot(),
                "architecture-witnesses-json": architecture.bootstrap_architecture_witnesses().snapshot(),
                "architecture-validation-json": architecture.bootstrap_architecture_validation().snapshot(),
                "architecture-coherence-json": architecture.bootstrap_architecture_coherence().snapshot(),
                "architecture-traces-json": architecture.bootstrap_architecture_traces().snapshot(),
                "architecture-boundaries-json": architecture.bootstrap_architecture_boundaries().snapshot(),
                "architecture-impact-json": architecture.bootstrap_architecture_impact().snapshot(),
                "architecture-migration-json": architecture.bootstrap_architecture_migration().snapshot(),
                "architecture-rehearsal-json": architecture.bootstrap_architecture_rehearsal().snapshot(),
                "architecture-activation-json": architecture.bootstrap_architecture_activation().snapshot(),
                "architecture-progress-json": architecture.bootstrap_architecture_progress().snapshot(),
            }
            assets = {f"{command}.json": _json(value) for command, value in values.items()}

            markdown_specs = {
                "architecture-validation-md": (
                    "Reta Stage-40 Architektur-Validation",
                    "Validierungsbaum",
                    architecture.bootstrap_architecture_validation(),
                ),
                "architecture-coherence-md": (
                    "Reta Stage-40 Architektur-Kohärenz",
                    "Kohärenzbaum",
                    architecture.bootstrap_architecture_coherence(),
                ),
                "architecture-traces-md": (
                    "Reta Stage-32 Architektur-Traces",
                    "Trace-Baum",
                    architecture.bootstrap_architecture_traces(),
                ),
                "architecture-boundaries-md": (
                    "Reta Stage-32 Architektur-Grenzen",
                    "Boundary-Baum",
                    architecture.bootstrap_architecture_boundaries(),
                ),
                "architecture-impact-md": (
                    "Reta Stage-33 Architektur-Impact",
                    "Impact-Baum",
                    architecture.bootstrap_architecture_impact(),
                ),
                "architecture-migration-md": (
                    "Reta Stage-34 Architektur-Migration",
                    "Migration-Plan-Baum",
                    architecture.bootstrap_architecture_migration(),
                ),
                "architecture-rehearsal-md": (
                    "Reta Stage-35 Architektur-Rehearsal",
                    "Rehearsal-/Readiness-Baum",
                    architecture.bootstrap_architecture_rehearsal(),
                ),
                "architecture-activation-md": (
                    "Reta Stage-36 Architektur-Aktivierung",
                    "Aktivierungs-/Commit-/Rollback-Baum",
                    architecture.bootstrap_architecture_activation(),
                ),
                "architecture-progress-md": (
                    "Reta Stage-42 Architektur-Fortschritt",
                    "Fortschrittsbaum",
                    architecture.bootstrap_architecture_progress(),
                ),
                "architecture-witnesses-md": (
                    "Reta Stage-30 Architektur-Witnesses",
                    "Witness-Baum",
                    architecture.bootstrap_architecture_witnesses(),
                ),
                "architecture-contracts-md": (
                    "Reta Stage-29 Architekturverträge",
                    "Vertragsbaum",
                    architecture.bootstrap_architecture_contracts(),
                ),
                "architecture-diagram-md": (
                    "Reta Stage-42 Gesamtarchitektur",
                    "Kapselbaum",
                    architecture.bootstrap_architecture_map(),
                ),
            }
            for command, (title, section, bundle) in markdown_specs.items():
                assets[f"{command}.md"] = _markdown(
                    title, section, bundle.text_diagram, bundle.mermaid_diagram
                )

            # Absolute source/home paths are observable in reference snapshots.
            # Store portable tokens and resolve them in the native runtime.
            canonical_reference = str(reference_root.resolve())
            assets = {
                filename: content.replace(canonical_reference, REFERENCE_TOKEN).replace(
                    CANONICAL_HOME, HOME_TOKEN
                )
                for filename, content in assets.items()
            }

            manifest_lines = []
            for filename in sorted(assets):
                payload = assets[filename].encode("utf-8")
                manifest_lines.append(
                    f"{filename}\t{len(payload)}\t{hashlib.sha256(payload).hexdigest()}\n"
                )
            assets["manifest.tsv"] = "".join(manifest_lines)
            return assets


def write_assets(destination: Path, assets: dict[str, str]) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    expected = set(assets)
    for old in destination.iterdir():
        if old.is_file() and old.name not in expected:
            old.unlink()
    for filename, content in assets.items():
        (destination / filename).write_text(content, encoding="utf-8")


def check_assets(destination: Path, assets: dict[str, str]) -> int:
    mismatches: list[str] = []
    existing = {path.name for path in destination.iterdir() if path.is_file()} if destination.exists() else set()
    if existing != set(assets):
        missing = sorted(set(assets) - existing)
        extra = sorted(existing - set(assets))
        if missing:
            mismatches.append("missing: " + ", ".join(missing))
        if extra:
            mismatches.append("extra: " + ", ".join(extra))
    for filename, expected in assets.items():
        path = destination / filename
        if not path.exists() or path.read_text(encoding="utf-8") != expected:
            mismatches.append(filename)
    if mismatches:
        print("architecture probe assets differ:", file=sys.stderr)
        for mismatch in mismatches:
            print("  " + mismatch, file=sys.stderr)
        return 1
    print(f"architecture probe assets: {len(assets) - 1} command assets identical")
    return 0


def main() -> int:
    if (
        os.environ.get("PYTHONHASHSEED") != "0"
        or os.environ.get("PYTHONDONTWRITEBYTECODE") != "1"
    ):
        env = dict(os.environ)
        env["PYTHONHASHSEED"] = "0"
        env["PYTHONDONTWRITEBYTECODE"] = "1"
        os.execve(
            sys.executable,
            [sys.executable, str(Path(__file__).resolve()), *sys.argv[1:]],
            env,
        )

    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--output", type=Path, default=OUT)
    args = parser.parse_args()
    assets = build_assets()
    if args.check:
        return check_assets(args.output, assets)
    write_assets(args.output, assets)
    print(f"generated {len(assets) - 1} architecture probe command assets in {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
