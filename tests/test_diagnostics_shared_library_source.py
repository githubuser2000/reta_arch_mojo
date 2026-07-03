from __future__ import annotations

import os
from pathlib import Path
import shutil
import subprocess

import pytest

ROOT = Path(__file__).resolve().parents[1]
LOADER_SOURCE = ROOT / "tools/reta_mojo_diagnostics_loader.c"
ABI_SOURCE = ROOT / "src/reta_diagnostics_abi.mojo"
BUILD_SCRIPT = ROOT / "scripts/build_diagnostics_shared.sh"


def _compiler() -> str:
    compiler = shutil.which(os.environ.get("CC", "cc"))
    if compiler is None:
        pytest.skip("C compiler unavailable")
    return compiler


def _build_fake_bundle(tmp_path: Path) -> tuple[Path, Path]:
    compiler = _compiler()
    target = tmp_path / "target"
    bin_dir = target / "bin"
    lib_dir = target / "lib" / "reta"
    bin_dir.mkdir(parents=True)
    lib_dir.mkdir(parents=True)
    loader = bin_dir / "reta-mojo-diagnostics"
    library = lib_dir / "libreta-mojo-diagnostics.so"

    subprocess.run(
        [
            compiler,
            "-std=c11",
            "-O2",
            "-Wall",
            "-Wextra",
            "-Werror",
            os.fspath(LOADER_SOURCE),
            "-ldl",
            "-o",
            os.fspath(loader),
        ],
        check=True,
    )
    fake_source = tmp_path / "fake_diagnostics.c"
    fake_source.write_text(
        r'''
#include <stdio.h>

int reta_mojo_diagnostics_abi_version(void) { return 1; }

static int emit(const char *name, int argc, char **argv) {
    printf("entry=%s argc=%d", name, argc);
    for (int i = 0; i < argc; ++i) {
        printf(" argv%d=%s", i, argv[i]);
    }
    putchar('\n');
    return 0;
}

int reta_mojo_table_generation_entry(int argc, char **argv) {
    return emit("table-generation", argc, argv);
}
int reta_mojo_output_syntax_entry(int argc, char **argv) {
    return emit("output-syntax", argc, argv);
}
int reta_mojo_console_io_entry(int argc, char **argv) {
    return emit("console-io", argc, argv);
}
int reta_mojo_table_output_entry(int argc, char **argv) {
    return emit("table-output", argc, argv);
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
            os.fspath(fake_source),
            "-o",
            os.fspath(library),
        ],
        check=True,
    )
    source_id = "source-id-for-shared-loader-test\n"
    loader.with_name(loader.name + ".reta-source-id").write_text(source_id)
    library.with_name(library.name + ".reta-source-id").write_text(source_id)
    return loader, library


def test_mojo_library_exports_only_c_abi_values() -> None:
    source = ABI_SOURCE.read_text(encoding="utf-8")
    assert source.count("@export") == 5
    assert source.count('abi("C")') == 5
    assert "reta_mojo_diagnostics_abi_version" in source
    for symbol in (
        "reta_mojo_table_generation_entry",
        "reta_mojo_output_syntax_entry",
        "reta_mojo_console_io_entry",
        "reta_mojo_table_output_entry",
    ):
        assert symbol in source
    assert "List[" not in "\n".join(
        line for line in source.splitlines() if "def reta_mojo_" in line
    )
    assert "String" not in "\n".join(
        line for line in source.splitlines() if "def reta_mojo_" in line
    )


def test_shared_build_and_loader_are_compiler_wired() -> None:
    build = BUILD_SCRIPT.read_text(encoding="utf-8")
    assert "--emit shared-lib" in build
    assert "src/reta_diagnostics_abi.mojo" in build
    assert "libreta-mojo-diagnostics.so" in build
    assert "reta_mojo_diagnostics_loader.c" in build
    assert "stamp_mojo_binary.sh" in build
    assert "--portable-component '$ORIGIN/../mojo'" in build


def test_generic_loader_dispatches_and_rebuilds_program_argv(tmp_path: Path) -> None:
    loader, _ = _build_fake_bundle(tmp_path)
    result = subprocess.run(
        [str(loader), "console-io", "--summary"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == (
        "entry=console-io argc=2 "
        "argv0=reta-mojo-console-io argv1=--summary"
    )


def test_compatibility_command_name_dispatches_without_extra_subcommand(
    tmp_path: Path,
) -> None:
    loader, _ = _build_fake_bundle(tmp_path)
    alias = loader.parent / "reta-mojo-table-output"
    alias.symlink_to(loader.name)
    result = subprocess.run(
        [str(alias), "--snapshot"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert "entry=table-output argc=2" in result.stdout
    assert "argv1=--snapshot" in result.stdout


def test_loader_rejects_library_from_different_source_id(tmp_path: Path) -> None:
    loader, library = _build_fake_bundle(tmp_path)
    library.with_name(library.name + ".reta-source-id").write_text(
        "different-source-id\n", encoding="utf-8"
    )
    result = subprocess.run(
        [str(loader), "output-syntax"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 78
    assert "nicht aus demselben Quellstand" in result.stderr
