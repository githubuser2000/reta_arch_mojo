from __future__ import annotations

import os
from pathlib import Path
import shutil
import subprocess

import pytest

ROOT = Path(__file__).resolve().parents[1]
PROMPT_ABI = ROOT / "src/reta_prompt_abi.mojo"
INTERACTIVE_ABI = ROOT / "src/reta_prompt_interactive_abi.mojo"
PROMPT_MAIN = ROOT / "src/prompt_main.mojo"
LOADER_SOURCE = ROOT / "tools/reta_prompt_loader.c"
BUILD_SCRIPT = ROOT / "scripts/build_prompt_shared.sh"


def _compiler() -> str:
    compiler = shutil.which(os.environ.get("CC", "cc"))
    if compiler is None:
        pytest.skip("C compiler unavailable")
    return compiler


def _build_fake_prompt_bundle(tmp_path: Path) -> tuple[Path, Path, Path, Path]:
    compiler = _compiler()
    target = tmp_path / "target"
    bin_dir = target / "bin"
    lib_dir = target / "lib" / "reta"
    bin_dir.mkdir(parents=True)
    lib_dir.mkdir(parents=True)
    loader_source = LOADER_SOURCE
    rpb = bin_dir / "rpb"
    rp = bin_dir / "rp"
    prompt = lib_dir / "libreta-prompt.so"
    interactive = lib_dir / "libreta-prompt-interactive.so"

    subprocess.run(
        [
            compiler,
            "-std=c11",
            "-O2",
            "-Wall",
            "-Wextra",
            "-Werror",
            os.fspath(loader_source),
            "-ldl",
            "-o",
            os.fspath(rpb),
        ],
        check=True,
    )
    shutil.copy2(rpb, rp)

    fake_prompt = tmp_path / "fake_prompt.c"
    fake_prompt.write_text(
        r'''
#include <stdio.h>
int reta_prompt_abi_version(void) { return 1; }
int reta_prompt_entry(int argc, char **argv) {
    printf("entry=prompt argc=%d", argc);
    for (int i = 0; i < argc; ++i) { printf(" argv%d=%s", i, argv[i]); }
    putchar('\n');
    return 0;
}
''',
        encoding="utf-8",
    )
    subprocess.run(
        [
            compiler,
            "-std=c11",
            "-O2",
            "-Wall",
            "-Wextra",
            "-Werror",
            "-shared",
            "-fPIC",
            os.fspath(fake_prompt),
            "-o",
            os.fspath(prompt),
        ],
        check=True,
    )

    fake_interactive = tmp_path / "fake_interactive.c"
    fake_interactive.write_text(
        r'''
#include <stdio.h>
int reta_prompt_interactive_abi_version(void) { return 1; }
int reta_prompt_interactive_entry(int argc, char **argv) {
    printf("entry=interactive argc=%d", argc);
    for (int i = 0; i < argc; ++i) { printf(" argv%d=%s", i, argv[i]); }
    putchar('\n');
    return 0;
}
''',
        encoding="utf-8",
    )
    subprocess.run(
        [
            compiler,
            "-std=c11",
            "-O2",
            "-Wall",
            "-Wextra",
            "-Werror",
            "-shared",
            "-fPIC",
            os.fspath(fake_interactive),
            "-o",
            os.fspath(interactive),
        ],
        check=True,
    )

    source_id = "source-id-for-prompt-loader-test\n"
    for artifact in (rpb, rp, prompt, interactive):
        artifact.with_name(artifact.name + ".reta-source-id").write_text(
            source_id, encoding="utf-8"
        )
    return rpb, rp, prompt, interactive


def test_prompt_main_exposes_shared_controller_entry_without_changing_main() -> None:
    source = PROMPT_MAIN.read_text(encoding="utf-8")
    assert "def run_prompt_profile_from_args(" in source
    assert "parse_prompt_startup(profile_name, startup_args)" in source
    assert "def main() raises:" in source
    assert "run_prompt_profile_from_args(profile_name, startup_args)" in source
    assert "var profile_name = String(args[1])" in source


def test_prompt_abi_exports_only_c_abi_values() -> None:
    source = PROMPT_ABI.read_text(encoding="utf-8")
    assert source.count("@export") == 2
    assert source.count('abi("C")') == 2
    assert "reta_prompt_abi_version" in source
    assert "reta_prompt_entry" in source
    assert "owned_c_argv" in source
    assert "run_prompt_profile_from_args" in source
    signature_lines = "\n".join(
        line for line in source.splitlines() if line.startswith("def reta_prompt")
    )
    assert "List[" not in signature_lines
    assert "String" not in signature_lines


def test_interactive_prompt_abi_is_separate_and_documents_rpb_exclusion() -> None:
    source = INTERACTIVE_ABI.read_text(encoding="utf-8")
    assert source.count("@export") == 2
    assert "reta_prompt_interactive_abi_version" in source
    assert "reta_prompt_interactive_entry" in source
    assert "rpb stays on the one-shot" in source
    assert "run_prompt_profile_from_args" in source


def test_prompt_shared_build_script_is_now_an_official_build_all_target() -> None:
    build = BUILD_SCRIPT.read_text(encoding="utf-8")
    assert "src/reta_prompt_abi.mojo" in build
    assert "src/reta_prompt_interactive_abi.mojo" in build
    assert "libreta-prompt.so" in build
    assert "libreta-prompt-interactive.so" in build
    assert "tools/reta_prompt_loader.c" in build
    assert '"$TARGET_DIR/$name"' in build
    assert "rpb lädt nur libreta-prompt.so" in build
    build_all = (ROOT / "scripts/build-all.sh").read_text(encoding="utf-8")
    assert "build_prompt_shared.sh" in build_all
    assert "build_core_shared.sh" in build_all


def test_rpb_loader_uses_prompt_library_without_interactive_library(tmp_path: Path) -> None:
    rpb, _, _, interactive = _build_fake_prompt_bundle(tmp_path)
    interactive.unlink()
    interactive.with_name(interactive.name + ".reta-source-id").unlink()
    result = subprocess.run(
        [str(rpb), "mond"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout.startswith("entry=prompt argc=2")
    assert "argv0=rpb" in result.stdout
    assert "argv1=mond" in result.stdout


def test_rp_loader_uses_interactive_prompt_library(tmp_path: Path) -> None:
    _, rp, _, _ = _build_fake_prompt_bundle(tmp_path)
    result = subprocess.run(
        [str(rp), "hilfe"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout.startswith("entry=interactive argc=2")
    assert "argv0=rp" in result.stdout
    assert "argv1=hilfe" in result.stdout


def test_prompt_loader_rejects_mismatched_source_ids(tmp_path: Path) -> None:
    rpb, _, prompt, _ = _build_fake_prompt_bundle(tmp_path)
    prompt.with_name(prompt.name + ".reta-source-id").write_text(
        "different-source-id\n", encoding="utf-8"
    )
    result = subprocess.run(
        [str(rpb), "hilfe"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 78
    assert "nicht aus demselben Quellstand" in result.stderr
