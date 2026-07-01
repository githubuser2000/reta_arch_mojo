from __future__ import annotations

import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
REQUIRED_LIBRARIES = (
    "libKGENCompilerRTShared.so",
    "libAsyncRTMojoBindings.so",
    "libMSupportGlobals.so",
    "libAsyncRTRuntimeGlobals.so",
    "libNVPTX.so",
)


def _fake_runtime(path: Path) -> Path:
    path.mkdir()
    for name in REQUIRED_LIBRARIES:
        (path / name).write_bytes(b"test-runtime")
    return path


def test_explicit_runtime_directory_is_discovered(tmp_path: Path) -> None:
    runtime = _fake_runtime(tmp_path / "runtime")
    result = subprocess.run(
        [str(ROOT / "scripts" / "find_mojo_runtime.sh")],
        cwd=ROOT,
        env={**os.environ, "RETA_MOJO_RUNTIME_LIBDIR": str(runtime)},
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert Path(result.stdout.strip()).resolve() == runtime.resolve()


def test_runtime_configuration_creates_project_relative_links(tmp_path: Path) -> None:
    runtime = _fake_runtime(tmp_path / "runtime")
    link_dir = tmp_path / "project-runtime"
    result = subprocess.run(
        [str(ROOT / "scripts" / "configure_mojo_runtime.sh")],
        cwd=ROOT,
        env={
            **os.environ,
            "RETA_MOJO_RUNTIME_LIBDIR": str(runtime),
            "RETA_MOJO_RUNTIME_LINK_DIR": str(link_dir),
        },
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    for name in REQUIRED_LIBRARIES:
        link = link_dir / name
        assert link.is_symlink()
        assert link.resolve() == (runtime / name).resolve()


def test_runtime_exec_prepends_detected_directory(tmp_path: Path) -> None:
    runtime = _fake_runtime(tmp_path / "runtime")
    target = tmp_path / "print-library-path"
    target.write_text("#!/bin/sh\nprintf '%s' \"$LD_LIBRARY_PATH\"\n", encoding="utf-8")
    target.chmod(0o755)
    result = subprocess.run(
        [str(ROOT / "bin" / "mojo-runtime-exec"), str(target)],
        cwd=ROOT,
        env={
            **os.environ,
            "RETA_MOJO_RUNTIME_LIBDIR": str(runtime),
            "LD_LIBRARY_PATH": "/already/present",
        },
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout.split(":", 1) == [str(runtime), "/already/present"]


def test_builds_embed_project_relative_runtime_runpath() -> None:
    for relative in ("scripts/build.sh", "scripts/build-heavy.sh"):
        source = (ROOT / relative).read_text(encoding="utf-8")
        assert "MOJO_RUNTIME_RPATH='$ORIGIN/../lib/mojo'" in source
        assert "configure_mojo_runtime.sh" in source
        assert '-Xlinker -rpath -Xlinker "$MOJO_RUNTIME_RPATH"' in source
