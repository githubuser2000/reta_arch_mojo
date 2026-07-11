from __future__ import annotations

import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "scripts/install_targets.txt"

PUBLIC = {
    "reta",
    "grundStrukHtml",
    "rp",
    "rpl",
    "rpe",
    "rpb",
    "generate_html",
}
REGULAR_DIAGNOSTIC_SAMPLE = {
    "reta-native",
    "generate-html-native",
    "reta-prompt-native",
    "reta-mojo-diagnostics",
    "reta-mojo",
    "reta-mojo-compat",
    "mojo-runtime-exec",
}
HEAVY_SAMPLE = {
    "reta-mojo-boundaries",
    "reta-mojo-semantics",
    "reta-mojo-architecture",
}


def _current_source_id() -> str:
    return subprocess.run(
        [str(ROOT / "scripts/current_source_id.sh")],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        check=True,
    ).stdout.strip() + "\n"


def _write_stub_target(path: Path, source_id: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
    path.chmod(0o755)
    path.with_name(path.name + ".reta-source-id").write_text(
        source_id, encoding="utf-8"
    )


def _write_stub_library(path: Path, source_id: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(b"fake-shared-library")
    path.with_name(path.name + ".reta-source-id").write_text(source_id, encoding="utf-8")


def _manifest_names() -> list[str]:
    return [
        line
        for raw in MANIFEST.read_text(encoding="utf-8").splitlines()
        if (line := raw.strip()) and not line.startswith("#")
    ]


def _shell_words(function_call: str) -> list[str]:
    result = subprocess.run(
        ["sh", "-c", f". scripts/reta_artifacts.sh; {function_call}"],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        check=True,
    )
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


def _prepared_target_tree(tmp_path: Path, profile: str = "standard") -> tuple[Path, str]:
    target_root = tmp_path / f"compiled-target-{profile}"
    target_dir = target_root / "bin"
    target_lib = target_root / "lib" / "reta"
    target_dir.mkdir(parents=True)
    source_id = _current_source_id()
    pairs = _shell_words(f"reta_artifact_profile_install_pairs {profile}")
    for pair in pairs:
        source = pair.split(":", 1)[1]
        _write_stub_target(target_dir / source, source_id)
    libraries = _shell_words(f"reta_artifact_profile_shared_libraries {profile}")
    for library in libraries:
        _write_stub_library(target_lib / library, source_id)
    return target_dir, source_id


def _install(tmp_path: Path, profile: str = "standard") -> Path:
    target_dir, _ = _prepared_target_tree(tmp_path, profile)
    stage = tmp_path / f"stage-{profile}"
    result = subprocess.run(
        [str(ROOT / "scripts/install.sh"), f"--{profile}"],
        cwd=ROOT,
        env={
            **os.environ,
            "DESTDIR": str(stage),
            "PREFIX": "/usr",
            "RETA_INSTALL_MOJO_RUNTIME": "0",
            "RETA_TARGET_DIR": str(target_dir),
        },
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    return stage


def test_manifest_contains_only_standard_public_user_commands() -> None:
    names = _manifest_names()
    assert len(names) == len(set(names)) == 7
    assert set(names) == PUBLIC
    assert "reta-native" not in names
    assert "generate-html-native" not in names
    assert "reta-mojo-boundaries" not in names


def test_profile_manifests_are_cumulative() -> None:
    standard = set(_shell_words("reta_artifact_profile_install_executables standard"))
    zusatz = set(_shell_words("reta_artifact_profile_install_executables zusatz"))
    all_ = set(_shell_words("reta_artifact_profile_install_executables all"))
    assert standard == PUBLIC
    assert standard < zusatz < all_
    assert REGULAR_DIAGNOSTIC_SAMPLE <= zusatz
    assert HEAVY_SAMPLE.isdisjoint(zusatz)
    assert HEAVY_SAMPLE <= all_


def test_standard_installer_copies_only_public_commands_and_needed_libraries(tmp_path: Path) -> None:
    stage = _install(tmp_path, "standard")
    installed = stage / "usr/bin"
    actual_targets = {
        path.name
        for path in installed.iterdir()
        if path.is_file() and not path.is_symlink() and not path.name.endswith(".reta-source-id")
    }
    assert actual_targets == PUBLIC
    assert not (installed / "generate-html-native").exists()
    assert not (installed / "reta-native").exists()
    assert not (installed / "reta-mojo-diagnostics").exists()
    assert not (installed / "reta-mojo-boundaries").exists()
    assert not (installed / "mojo-runtime-exec").exists()
    assert not (stage / "usr/lib/libreta_diagnostics_mojo.so").exists()
    assert (stage / "usr/lib/libreta_core_mojo.so").is_file()
    assert (stage / "usr/lib/libreta_prompt_mojo.so").is_file()
    assert (stage / "usr/lib/libreta_prompt_interactive_mojo.so").is_file()
    assert not list((stage / "usr").rglob("*.reta-source-id"))
    layout = (stage / "usr/share/reta/INSTALL_LAYOUT").read_text(encoding="utf-8")
    assert "install_profile=standard" in layout
    assert "installed_public_commands=reta,rp,rpl,rpe,rpb,generate_html,grundStrukHtml" in layout
    assert "compiled_targets=7" in layout


def test_zusatz_installer_adds_regular_diagnostics_but_not_heavy(tmp_path: Path) -> None:
    stage = _install(tmp_path, "zusatz")
    installed = {path.name for path in (stage / "usr/bin").iterdir() if path.is_file()}
    assert PUBLIC <= installed
    assert REGULAR_DIAGNOSTIC_SAMPLE <= installed
    assert HEAVY_SAMPLE.isdisjoint(installed)
    assert (stage / "usr/lib/libreta_diagnostics_mojo.so").is_file()
    layout = (stage / "usr/share/reta/INSTALL_LAYOUT").read_text(encoding="utf-8")
    assert "install_profile=zusatz" in layout


def test_all_installer_adds_heavy_diagnostics(tmp_path: Path) -> None:
    stage = _install(tmp_path, "all")
    installed = {path.name for path in (stage / "usr/bin").iterdir() if path.is_file()}
    assert PUBLIC <= installed
    assert REGULAR_DIAGNOSTIC_SAMPLE <= installed
    assert HEAVY_SAMPLE <= installed
    layout = (stage / "usr/share/reta/INSTALL_LAYOUT").read_text(encoding="utf-8")
    assert "install_profile=all" in layout


def test_build_layout_still_uses_central_build_manifest() -> None:
    layout = (ROOT / "scripts/check_build_layout.sh").read_text(encoding="utf-8")
    assert "expected=$(reta_artifact_build_executables)" in layout
    assert "heavy=$(reta_artifact_heavy_executables)" in layout
