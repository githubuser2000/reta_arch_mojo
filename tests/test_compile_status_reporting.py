from __future__ import annotations

import os
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"


def test_three_top_level_compilation_scripts_report_boolean_status() -> None:
    expected = {
        "build-all.sh": "Kompilierung des vollständigen nativen Builds erfolgreich",
        "build-and-test-shared-diagnostics.sh": "Kompilierung und Shared-Diagnostics-Prüfung erfolgreich",
        "test_all.sh": "Kompilierung und Ausführung aller ausgewählten Mojo-Tests erfolgreich",
    }
    for filename, label in expected.items():
        source = (SCRIPTS / filename).read_text(encoding="utf-8")
        assert 'status=$?' in source
        assert '[ "$status" -eq 0 ]' in source
        assert f"'{label}'" in source
        assert ": JA\\n" in source
        assert ": NEIN (Exitstatus %s)\\n" in source
        assert "== 0" not in source
        assert "?$" not in source


def test_each_top_level_script_reports_no_and_preserves_failure_status(
    tmp_path: Path,
) -> None:
    env = os.environ.copy()
    env.update(
        {
            "MOJO_BIN": "/bin/false",
            "RETA_TARGET_DIR": str(tmp_path / "bin"),
            "RETA_TARGET_LIB_DIR": str(tmp_path / "lib"),
            "RETA_TEST_TARGET_DIR": str(tmp_path / "tests"),
        }
    )
    for filename in (
        "build-all.sh",
        "build-and-test-shared-diagnostics.sh",
        "test_all.sh",
    ):
        result = subprocess.run(
            [str(SCRIPTS / filename)],
            cwd=ROOT,
            env=env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
        )
        assert result.returncode != 0
        lines = [line for line in result.stdout.splitlines() if line.strip()]
        match = re.search(r"erfolgreich: NEIN \(Exitstatus (\d+)\)$", lines[-1])
        assert match is not None
        assert int(match.group(1)) == result.returncode


def test_top_level_scripts_keep_the_original_compiler_error_visible(
    tmp_path: Path,
) -> None:
    fake_mojo = tmp_path / "mojo"
    fake_mojo.write_text(
        "#!/usr/bin/env sh\n"
        "if [ \"${1-}\" = --version ]; then\n"
        "    printf '%s\\n' 'Mojo 1.0.0 test compiler'\n"
        "    exit 0\n"
        "fi\n"
        "printf '%s\\n' 'ORIGINAL-COMPILER-DIAGNOSTIC: unknown declaration' >&2\n"
        "exit 31\n",
        encoding="utf-8",
    )
    fake_mojo.chmod(0o755)
    runtime = tmp_path / "runtime"
    runtime.mkdir()
    for library in (
        "libKGENCompilerRTShared.so",
        "libAsyncRTMojoBindings.so",
        "libMSupportGlobals.so",
        "libAsyncRTRuntimeGlobals.so",
        "libNVPTX.so",
    ):
        (runtime / library).touch()
    env = os.environ.copy()
    env.update(
        {
            "MOJO_BIN": str(fake_mojo),
            "RETA_MOJO_RUNTIME_LIBDIR": str(runtime),
            "RETA_TARGET_DIR": str(tmp_path / "bin"),
            "RETA_TARGET_LIB_DIR": str(tmp_path / "lib"),
            "RETA_TEST_TARGET_DIR": str(tmp_path / "tests"),
        }
    )
    for filename in (
        "build-all.sh",
        "build-and-test-shared-diagnostics.sh",
        "test_all.sh",
    ):
        result = subprocess.run(
            [str(SCRIPTS / filename)],
            cwd=ROOT,
            env=env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
        )
        assert result.returncode == 31
        assert "ORIGINAL-COMPILER-DIAGNOSTIC: unknown declaration" in result.stdout
        assert "erfolgreich: NEIN (Exitstatus 31)" in result.stdout
