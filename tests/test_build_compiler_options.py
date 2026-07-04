from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"


def _text(name: str) -> str:
    return (SCRIPTS / name).read_text(encoding="utf-8")


def test_build_scripts_are_valid_posix_shell_and_expose_help() -> None:
    names = (
        "build.sh",
        "build-heavy.sh",
        "build-all.sh",
        "build_diagnostics_shared.sh",
    )
    subprocess.run(
        ["sh", "-n", *(str(SCRIPTS / name) for name in names)],
        check=True,
        cwd=ROOT,
    )
    for name in names:
        result = subprocess.run(
            [str(SCRIPTS / name), "--help"],
            check=True,
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        assert "MOJO_BUILD_OPTION" in result.stdout


def test_full_build_forwards_the_exact_argument_vector_to_both_subbuilds(
    tmp_path: Path,
) -> None:
    project = tmp_path / "project"
    scripts = project / "scripts"
    scripts.mkdir(parents=True)
    shutil.copy2(SCRIPTS / "build-all.sh", scripts / "build-all.sh")

    trace = project / "trace.txt"
    child = """#!/usr/bin/env sh
set -eu
printf '%s' "$(basename \"$0\")" >> "$TRACE"
for argument do
    printf '\\t<%s>' "$argument" >> "$TRACE"
done
printf '\\n' >> "$TRACE"
"""
    for name in ("build-heavy.sh", "build.sh"):
        path = scripts / name
        path.write_text(child, encoding="utf-8")
        path.chmod(0o755)
    checker = scripts / "check_build_layout.sh"
    checker.write_text("#!/usr/bin/env sh\nexit 0\n", encoding="utf-8")
    checker.chmod(0o755)

    env = os.environ.copy()
    env["TRACE"] = str(trace)
    result = subprocess.run(
        [
            str(scripts / "build-all.sh"),
            "--optimize-heavy",
            "--",
            "--optimization-level",
            "2",
            "--target-cpu",
            "cpu name with space",
            "-j",
            "8",
        ],
        cwd=project,
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    assert result.returncode == 0, result.stderr
    assert trace.read_text(encoding="utf-8").splitlines() == [
        "build-heavy.sh\t<-->\t<--optimization-level>\t<2>"
        "\t<--target-cpu>\t<cpu name with space>\t<-j>\t<8>",
        "build.sh\t<-->\t<--optimization-level>\t<2>"
        "\t<--target-cpu>\t<cpu name with space>\t<-j>\t<8>",
    ]


def test_regular_build_forwards_options_to_every_target_and_shared_library() -> None:
    source = _text("build.sh")
    body = source.split("build_regular_targets() {", 1)[1].split(
        "\n}\n\nprint_forwarded_options", 1
    )[0]
    assert 'build_regular_targets "$@"' in source
    assert '"$ROOT/scripts/build_diagnostics_shared.sh" -- "$@"' in body
    assert body.count('"$@"') >= 23
    assert 'build "$@" --emit exe' in source

    diagnostics = _text("build_diagnostics_shared.sh")
    assert 'build -I src "$@" --emit shared-lib' in diagnostics
    assert '"$CC" -std=c11 -O2 -Wall -Wextra -Werror' in diagnostics


def test_heavy_o0_defaults_are_explicit_and_can_be_removed() -> None:
    source = _text("build-heavy.sh")
    assert "--optimize-heavy" in source
    assert "RETA_HEAVY_DEFAULT_NO_OPT" in source
    assert '"$@" --no-optimization' in source
    assert 'build_heavy_targets "$@"' in source
    assert "-j 4 \"$@\"" in source

    full = _text("build-all.sh")
    assert 'RETA_HEAVY_DEFAULT_NO_OPT="$HEAVY_DEFAULT_NO_OPT"' in full
    assert '"$ROOT/scripts/build-heavy.sh" -- "$@"' in full
    assert '"$ROOT/scripts/build.sh" -- "$@"' in full


def test_build_documentation_has_optimization_and_cpu_examples() -> None:
    build = (ROOT / "BUILD.md").read_text(encoding="utf-8")
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    for text in (build, readme):
        assert "--optimization-level" in text
        assert "--target-cpu" in text
        assert "--optimize-heavy" in text
        assert "MOJO_BUILD_OPTION" in text
