from __future__ import annotations

import os
from pathlib import Path
import shutil
import subprocess

import pytest

ROOT = Path(__file__).resolve().parents[1]
ABI_SOURCE = ROOT / "src/reta_core_abi.mojo"
LOADER_SOURCE = ROOT / "tools/reta_core_loader.c"
BUILD_SCRIPT = ROOT / "scripts/build_core_shared.sh"


def _compiler() -> str:
    compiler = shutil.which(os.environ.get("CC", "cc"))
    if compiler is None:
        pytest.skip("C compiler unavailable")
    return compiler


def _build_fake_core_bundle(tmp_path: Path) -> tuple[Path, Path, Path]:
    compiler = _compiler()
    target = tmp_path / "target"
    bin_dir = target / "bin"
    lib_dir = target / "lib" / "reta"
    bin_dir.mkdir(parents=True)
    lib_dir.mkdir(parents=True)
    reta_loader = bin_dir / "reta"
    grund_loader = bin_dir / "grundStrukHtml"
    library = lib_dir / "libreta_core_mojo.so"

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
            os.fspath(reta_loader),
        ],
        check=True,
    )
    shutil.copy2(reta_loader, grund_loader)

    fake_source = tmp_path / "fake_core.c"
    fake_source.write_text(
        r'''
#include <stdio.h>

int reta_core_abi_version(void) { return 1; }

static int emit(const char *name, int argc, char **argv) {
    printf("entry=%s argc=%d", name, argc);
    for (int i = 0; i < argc; ++i) {
        printf(" argv%d=%s", i, argv[i]);
    }
    putchar('\n');
    return 0;
}

int reta_core_reta_entry(int argc, char **argv) {
    return emit("reta", argc, argv);
}
int reta_core_grundstrukhtml_entry(int argc, char **argv) {
    return emit("grundStrukHtml", argc, argv);
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
    source_id = "source-id-for-core-loader-test\n"
    for artifact in (reta_loader, grund_loader, library):
        artifact.with_name(artifact.name + ".reta-source-id").write_text(
            source_id, encoding="utf-8"
        )
    return reta_loader, grund_loader, library


def test_core_abi_exports_only_c_abi_values() -> None:
    source = ABI_SOURCE.read_text(encoding="utf-8")
    assert source.count("@export") == 3
    assert source.count('abi("C")') == 3
    assert "reta_core_abi_version" in source
    assert "reta_core_reta_entry" in source
    assert "reta_core_grundstrukhtml_entry" in source
    signature_lines = "\n".join(
        line for line in source.splitlines() if line.startswith("def reta_core_")
    )
    assert "List[" not in signature_lines
    assert "String" not in signature_lines
    assert "owned_c_argv" in source
    assert "run_native_reta" in source
    assert "render_grundstrukturen_html" in source


def test_core_shared_build_script_compiles_library_and_two_thin_starters() -> None:
    build = BUILD_SCRIPT.read_text(encoding="utf-8")
    assert "--emit shared-lib" in build
    assert "src/reta_core_abi.mojo" in build
    assert "libreta_core_mojo.so" in build
    assert "tools/reta_core_loader.c" in build
    assert '"$TARGET_DIR/reta"' in build
    assert '"$TARGET_DIR/grundStrukHtml"' in build
    assert "stamp_mojo_binary.sh" in build
    assert "sanitize_mojo_runpath.py" in build
    assert "libreta_prompt_interactive_mojo" not in build


def test_reta_alias_dispatches_to_core_reta_entry(tmp_path: Path) -> None:
    reta_loader, _, _ = _build_fake_core_bundle(tmp_path)
    result = subprocess.run(
        [str(reta_loader), "-zeilen", "--vorhervonausschnitt=1"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout.startswith("entry=reta argc=3")
    assert "argv1=-zeilen" in result.stdout
    assert "argv2=--vorhervonausschnitt=1" in result.stdout


def test_grundstrukhtml_alias_dispatches_to_core_renderer_entry(tmp_path: Path) -> None:
    _, grund_loader, _ = _build_fake_core_bundle(tmp_path)
    result = subprocess.run(
        [str(grund_loader), "blank", "-language=english"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout.startswith("entry=grundStrukHtml argc=3")
    assert "argv1=blank" in result.stdout
    assert "argv2=-language=english" in result.stdout


def test_core_loader_rejects_library_from_different_source_id(tmp_path: Path) -> None:
    reta_loader, _, library = _build_fake_core_bundle(tmp_path)
    library.with_name(library.name + ".reta-source-id").write_text(
        "different-source-id\n", encoding="utf-8"
    )
    result = subprocess.run(
        [str(reta_loader), "--help"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 78
    assert "nicht aus demselben Quellstand" in result.stderr
