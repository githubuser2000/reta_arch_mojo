from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / "scripts/build-tests.sh"
RUN = ROOT / "scripts/run-tests.sh"
WRAPPER = ROOT / "scripts/test_all.sh"
SOURCE_ID = ROOT / "scripts/current_test_source_id.sh"
RUNNER = ROOT / "tools/run_mojo_test_binaries.py"


def test_test_pipeline_has_separate_build_run_and_compatibility_entrypoints() -> None:
    build = BUILD.read_text(encoding="utf-8")
    run = RUN.read_text(encoding="utf-8")
    wrapper = WRAPPER.read_text(encoding="utf-8")
    source_id = SOURCE_ID.read_text(encoding="utf-8")

    assert "führt aber keinen Test aus" in build
    assert 'MANIFEST="$TARGET/manifest.tsv"' in build
    assert 'SOURCE_ID=$("$ROOT/scripts/current_test_source_id.sh")' in build
    assert 'rm -f "$MANIFEST"' in build
    assert 'mv -f "$ACTIVE_TMP" "$final"' in build
    assert "mojo-runtime-exec" not in build
    assert "ThreadPoolExecutor" in RUNNER.read_text(encoding="utf-8")
    assert "mojo build" not in run
    assert '"$ROOT/scripts/build-tests.sh"' in wrapper
    assert '"$ROOT/scripts/run-tests.sh"' in wrapper
    assert '--run-jobs' in wrapper
    assert '"$ROOT/scripts/build-tests.sh" -- "$@"' in wrapper
    assert '"$ROOT/scripts/build-tests.sh" --heavy -- "$@"' in wrapper
    assert "find src tests assets -type f" in source_id


def test_test_builds_are_sequential_but_runtime_parallelism_is_opt_in() -> None:
    build = BUILD.read_text(encoding="utf-8")
    run = RUN.read_text(encoding="utf-8")
    runner = RUNNER.read_text(encoding="utf-8")

    assert "Mehrere Mojo-Compilerprozesse werden absichtlich nicht" in build
    assert "xargs -P" not in build
    assert "&\n" not in build
    assert "RETA_TEST_RUN_JOBS" in run
    assert '--jobs "$JOBS"' in run
    assert 'execution_class == "parallel"' in runner
    assert 'entry.execution_class == "parallel"' in runner
    assert "serial and exclusive are both barriers" in runner


def test_known_shared_and_resource_heavy_tests_are_serial_barriers() -> None:
    build = BUILD.read_text(encoding="utf-8")
    native_prompt = (ROOT / "tests/test_native_prompt_input.mojo").read_text(encoding="utf-8")
    assert 'getenv("RETA_TEST_SANDBOX", "/tmp")' in native_prompt
    assert "tests/test_native_prompt_input.mojo) printf '%s' serial" not in build
    for name in (
        "test_generated_table_columns.mojo",
        "test_native_reta_cli.mojo",
        "test_native_reta_utf8_html.mojo",
        "test_parallel_number_threads.mojo",
        "test_parallel_row_processes.mojo",
        "test_prime_universe_columns.mojo",
    ):
        assert name in build
    assert "printf '%s' exclusive" in build


def test_runtime_runner_executes_manifest_and_isolates_tmpdirs(tmp_path: Path) -> None:
    runtime = tmp_path / "runtime"
    runtime.write_text('#!/bin/sh\nexec "$@"\n', encoding="utf-8")
    runtime.chmod(0o755)

    binaries: list[Path] = []
    for index in range(3):
        binary = tmp_path / f"test-{index}"
        binary.write_text(
            "#!/bin/sh\n"
            f"printf 'case-{index} TMP=%s\\n' \"$TMPDIR\"\n",
            encoding="utf-8",
        )
        binary.chmod(0o755)
        binaries.append(binary)

    manifest = tmp_path / "manifest.tsv"
    manifest.write_text(
        "# reta-test-manifest-v1\n"
        "source_id\tdummy\n"
        "heavy\t0\n"
        "name\tsource\tbinary\tclass\n"
        f"a\ttests/a.mojo\t{binaries[0]}\tparallel\n"
        f"b\ttests/b.mojo\t{binaries[1]}\tparallel\n"
        f"c\ttests/c.mojo\t{binaries[2]}\tserial\n",
        encoding="utf-8",
    )

    completed = subprocess.run(
        [
            sys.executable,
            str(RUNNER),
            "--manifest",
            str(manifest),
            "--runtime-exec",
            str(runtime),
            "--root",
            str(ROOT),
            "--jobs",
            "2",
        ],
        check=True,
        text=True,
        capture_output=True,
        env={**os.environ, "PYTHONDONTWRITEBYTECODE": "1"},
    )
    assert completed.stdout.index("== run a ==") < completed.stdout.index("== run b ==")
    assert completed.stdout.index("== run b ==") < completed.stdout.index("== run c ==")
    tmpdirs = [
        line.split("TMP=", 1)[1]
        for line in completed.stdout.splitlines()
        if " TMP=" in line
    ]
    assert len(tmpdirs) == 3
    assert len(set(tmpdirs)) == 3


def test_shell_entrypoints_are_syntactically_valid_and_help_without_compiler() -> None:
    subprocess.run(
        ["sh", "-n", str(BUILD), str(RUN), str(WRAPPER), str(SOURCE_ID)],
        check=True,
    )
    for script in (BUILD, RUN, WRAPPER):
        completed = subprocess.run(
            [str(script), "--help"],
            cwd=ROOT,
            check=True,
            text=True,
            capture_output=True,
        )
        assert "Verwendung:" in completed.stdout


def test_run_entrypoint_rejects_stale_manifest_before_execution(tmp_path: Path) -> None:
    manifest = tmp_path / "manifest.tsv"
    manifest.write_text(
        "# reta-test-manifest-v1\n"
        "source_id\tstale\n"
        "heavy\t0\n"
        "name\tsource\tbinary\tclass\n",
        encoding="utf-8",
    )
    completed = subprocess.run(
        [str(RUN)],
        cwd=ROOT,
        env={**os.environ, "RETA_TEST_TARGET_DIR": str(tmp_path)},
        text=True,
        capture_output=True,
        check=False,
    )
    assert completed.returncode == 78
    assert "veraltet" in completed.stderr
    assert "scripts/build-tests.sh" in completed.stderr
