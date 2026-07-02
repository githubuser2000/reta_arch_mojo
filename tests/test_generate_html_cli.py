from __future__ import annotations

import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
COMMAND = ROOT / "bin" / "generate_html"
RUNTIME_LIBS = (
    "libKGENCompilerRTShared.so",
    "libAsyncRTMojoBindings.so",
    "libMSupportGlobals.so",
    "libAsyncRTRuntimeGlobals.so",
    "libNVPTX.so",
)


def _fake_environment(tmp_path: Path) -> tuple[dict[str, str], Path]:
    runtime = tmp_path / "runtime"
    runtime.mkdir()
    for name in RUNTIME_LIBS:
        (runtime / name).write_bytes(b"")

    log = tmp_path / "fake.log"
    binary = tmp_path / "generate-html-fake"
    binary.write_text(
        """#!/bin/sh
set -eu
{
  printf 'pwd=%s\\n' "$PWD"
  printf 'args=%s\\n' "$*"
  printf 'middle_file=%s\\n' "${RETA_GENERATE_HTML_MIDDLE_FILE-}"
  printf 'middle_output=%s\\n' "${RETA_GENERATE_HTML_MIDDLE_OUTPUT-}"
  printf 'rows=%s\\n' "${RETA_GENERATE_HTML_ROWS-}"
  printf 'data_dir=%s\\n' "${RETA_DATA_DIR-}"
  printf 'asset_dir=%s\\n' "${RETA_ASSET_DIR-}"
} > "$RETA_TEST_LOG"
if [ -n "${RETA_GENERATE_HTML_MIDDLE_OUTPUT-}" ]; then
  printf 'middle-copy\\n' > "$RETA_GENERATE_HTML_MIDDLE_OUTPUT"
fi
printf 'complete-document\\n'
""",
        encoding="utf-8",
    )
    binary.chmod(0o755)
    env = {
        **os.environ,
        "RETA_GENERATE_HTML_BINARY": str(binary),
        "RETA_MOJO_RUNTIME_LIBDIR": str(runtime),
        "RETA_TEST_LOG": str(log),
    }
    return env, log


def test_help_and_version_do_not_require_native_binary() -> None:
    help_result = subprocess.run(
        [str(COMMAND), "--help"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
        env={**os.environ, "RETA_GENERATE_HTML_BINARY": "/missing"},
    )
    assert help_result.returncode == 0
    assert "--middle-file" in help_result.stdout
    assert "keine Zwischenatei" in help_result.stdout

    version_result = subprocess.run(
        [str(COMMAND), "--version"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
        env={**os.environ, "RETA_GENERATE_HTML_BINARY": "/missing"},
    )
    assert version_result.returncode == 0
    assert "reta Mojo HTML generator" in version_result.stdout


def test_cli_keeps_caller_directory_and_forwards_explicit_contract(
    tmp_path: Path,
) -> None:
    env, log = _fake_environment(tmp_path)
    caller = tmp_path / "caller"
    caller.mkdir()
    data = tmp_path / "csv"
    assets = tmp_path / "assets"
    data.mkdir()
    assets.mkdir()
    middle = tmp_path / "python-middle.alx"
    middle.write_text("python-middle\n", encoding="utf-8")
    middle_copy = caller / "saved-middle.alx"
    output = caller / "reta.html"

    result = subprocess.run(
        [
            str(COMMAND),
            "--output",
            str(output),
            "--language",
            "en",
            "--middle-file",
            str(middle),
            "--middle-output",
            str(middle_copy),
            "--rows",
            "2",
            "--data-dir",
            str(data),
            "--asset-dir",
            str(assets),
        ],
        cwd=caller,
        text=True,
        capture_output=True,
        check=False,
        env=env,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout == ""
    assert output.read_text(encoding="utf-8") == "complete-document\n"
    assert middle_copy.read_text(encoding="utf-8") == "middle-copy\n"
    details = log.read_text(encoding="utf-8")
    assert f"pwd={caller}" in details
    assert "args=-language=english" in details
    assert f"middle_file={middle}" in details
    assert f"middle_output={middle_copy}" in details
    assert "rows=2" in details
    assert f"data_dir={data}" in details
    assert f"asset_dir={assets}" in details
    assert not (caller / "middle.alx").exists()


def test_stdout_mode_has_no_implicit_middle_file(tmp_path: Path) -> None:
    env, log = _fake_environment(tmp_path)
    caller = tmp_path / "caller"
    caller.mkdir()
    result = subprocess.run(
        [str(COMMAND)],
        cwd=caller,
        text=True,
        capture_output=True,
        check=False,
        env=env,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout == "complete-document\n"
    assert "middle_output=\n" in log.read_text(encoding="utf-8")
    assert not (caller / "middle.alx").exists()


def test_no_clobber_and_invalid_options_have_stable_exit_codes(
    tmp_path: Path,
) -> None:
    env, _ = _fake_environment(tmp_path)
    output = tmp_path / "existing.html"
    output.write_text("keep\n", encoding="utf-8")
    no_clobber = subprocess.run(
        [str(COMMAND), "--no-clobber", "--output", str(output)],
        text=True,
        capture_output=True,
        check=False,
        env=env,
    )
    assert no_clobber.returncode == 73
    assert output.read_text(encoding="utf-8") == "keep\n"

    invalid = subprocess.run(
        [str(COMMAND), "--definitely-invalid"],
        text=True,
        capture_output=True,
        check=False,
        env=env,
    )
    assert invalid.returncode == 2
    assert "unbekannte Option" in invalid.stderr


def test_legacy_middle_is_opt_in(tmp_path: Path) -> None:
    env, log = _fake_environment(tmp_path)
    result = subprocess.run(
        [str(COMMAND), "--legacy-middle"],
        cwd=tmp_path,
        text=True,
        capture_output=True,
        check=False,
        env=env,
    )
    assert result.returncode == 0, result.stderr
    assert "middle_output=middle.alx" in log.read_text(encoding="utf-8")
    assert (tmp_path / "middle.alx").read_text(encoding="utf-8") == "middle-copy\n"
