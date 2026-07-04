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
        "mojo_build_options.sh",
    )
    subprocess.run(
        ["sh", "-n", *(str(SCRIPTS / name) for name in names)],
        check=True,
        cwd=ROOT,
    )
    for name in names[:-1]:
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
    shutil.copy2(
        SCRIPTS / "mojo_build_options.sh", scripts / "mojo_build_options.sh"
    )

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


def _prepare_fake_heavy_project(tmp_path: Path) -> tuple[Path, Path, dict[str, str]]:
    project = tmp_path / "heavy-project"
    scripts = project / "scripts"
    tools = project / "tools"
    fake_bin = project / "fake-bin"
    scripts.mkdir(parents=True)
    tools.mkdir()
    fake_bin.mkdir()
    for name in ("build-heavy.sh", "mojo_build_options.sh"):
        shutil.copy2(SCRIPTS / name, scripts / name)

    (scripts / "configure_mojo_runtime.sh").write_text(
        "#!/usr/bin/env sh\nexit 0\n", encoding="utf-8"
    )
    (scripts / "current_source_id.sh").write_text(
        "#!/usr/bin/env sh\nprintf 'source-id\\n'\n", encoding="utf-8"
    )
    (scripts / "stamp_mojo_binary.sh").write_text(
        "#!/usr/bin/env sh\nprintf '%s\\n' \"${RETA_BUILD_SOURCE_ID:-source-id}\" > \"$1.reta-source-id\"\n",
        encoding="utf-8",
    )
    for name in (
        "configure_mojo_runtime.sh",
        "current_source_id.sh",
        "stamp_mojo_binary.sh",
    ):
        (scripts / name).chmod(0o755)
    (tools / "sanitize_mojo_runpath.py").write_text(
        "raise SystemExit(0)\n", encoding="utf-8"
    )

    trace = project / "mojo-trace.txt"
    fake_mojo = fake_bin / "mojo"
    fake_mojo.write_text(
        """#!/usr/bin/env sh
set -eu
printf 'CALL' >> "$TRACE"
output=
expect_output=0
for argument do
    printf '\t<%s>' "$argument" >> "$TRACE"
    if [ "$expect_output" -eq 1 ]; then
        output=$argument
        expect_output=0
    elif [ "$argument" = -o ]; then
        expect_output=1
    fi
done
printf '\n' >> "$TRACE"
: "${output:?missing -o output}"
: > "$output"
""",
        encoding="utf-8",
    )
    fake_mojo.chmod(0o755)
    fake_file = fake_bin / "file"
    fake_file.write_text(
        "#!/usr/bin/env sh\nprintf 'ELF 64-bit LSB executable\\n'\n",
        encoding="utf-8",
    )
    fake_file.chmod(0o755)
    fake_python = fake_bin / "python3"
    fake_python.write_text("#!/usr/bin/env sh\nexit 0\n", encoding="utf-8")
    fake_python.chmod(0o755)

    env = os.environ.copy()
    env.update(
        {
            "TRACE": str(trace),
            "MOJO_BIN": str(fake_mojo),
            "PATH": str(fake_bin) + os.pathsep + env["PATH"],
        }
    )
    return project, trace, env


def _thread_options(line: str) -> list[str]:
    fields = [field[1:-1] for field in line.split("\t")[1:]]
    result: list[str] = []
    index = 0
    while index < len(fields):
        field = fields[index]
        if field in {"-j", "--jobs", "--threads"}:
            result.append(field)
            if index + 1 < len(fields):
                result.append(fields[index + 1])
                index += 2
                continue
        elif field.startswith("-j") and field != "-j":
            result.append(field)
        elif field.startswith("--jobs=") or field.startswith("--threads="):
            result.append(field)
        index += 1
    return result


def test_heavy_thread_default_is_suppressed_by_forwarded_user_value(
    tmp_path: Path,
) -> None:
    project, trace, env = _prepare_fake_heavy_project(tmp_path)
    completed = subprocess.run(
        [str(project / "scripts/build-heavy.sh"), "--", "-j", "8"],
        cwd=project,
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    assert completed.returncode == 0, completed.stderr
    lines = trace.read_text(encoding="utf-8").splitlines()
    threaded = [
        line
        for line in lines
        if any(
            name in line
            for name in (
                "architecture_execution_network_main.mojo",
                "architecture_parallel_execution_main.mojo",
                "architecture_parallel_row_preparation_main.mojo",
            )
        )
    ]
    assert len(threaded) == 3
    assert all(_thread_options(line) == ["-j", "8"] for line in threaded)


def test_heavy_thread_default_is_added_only_when_user_omits_it(
    tmp_path: Path,
) -> None:
    project, trace, env = _prepare_fake_heavy_project(tmp_path)
    completed = subprocess.run(
        [str(project / "scripts/build-heavy.sh"), "--", "--optimization-level", "2"],
        cwd=project,
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    assert completed.returncode == 0, completed.stderr
    threaded = [
        line
        for line in trace.read_text(encoding="utf-8").splitlines()
        if any(
            name in line
            for name in (
                "architecture_execution_network_main.mojo",
                "architecture_parallel_execution_main.mojo",
                "architecture_parallel_row_preparation_main.mojo",
            )
        )
    ]
    assert len(threaded) == 3
    assert all(_thread_options(line) == ["-j", "4"] for line in threaded)


def test_public_build_scripts_reject_two_user_thread_options() -> None:
    helper_path = SCRIPTS / "mojo_build_options.sh"
    helper = helper_path.read_text(encoding="utf-8")
    assert "mojo_thread_option_count" in helper
    assert "Mojo-Compileroption für die Threadanzahl wurde mehrfach angegeben" in helper
    completed = subprocess.run(
        [
            "sh",
            "-c",
            '. "$1"; shift; mojo_validate_build_options "$@"',
            "sh",
            str(helper_path),
            "-j",
            "8",
            "--jobs=4",
        ],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    assert completed.returncode == 2
    assert "Threadanzahl wurde mehrfach angegeben" in completed.stderr
    for name in ("build.sh", "build-heavy.sh", "build-all.sh"):
        source = _text(name)
        assert '. "$ROOT/scripts/mojo_build_options.sh"' in source
        assert 'mojo_validate_build_options "$@"' in source
