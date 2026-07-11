from __future__ import annotations

from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def test_install_profile_matrix_script() -> None:
    result = subprocess.run(
        [str(ROOT / "scripts" / "check_install_profile_matrix.sh")],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert "Installprofil-Matrix" in result.stdout


def test_release_bridge_policy_script() -> None:
    result = subprocess.run(
        [str(ROOT / "scripts" / "check_release_bridge_policy.sh")],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert "Release-Bridge-Policy" in result.stdout


def test_public_loaders_do_not_force_installed_python_reference() -> None:
    for relative in ("tools/reta_core_loader.c", "tools/reta_prompt_loader.c"):
        text = (ROOT / relative).read_text(encoding="utf-8")
        assert "directory_exists(reference)" in text
        assert "!installed_bin_layout &&" in text
        assert "join_path(csv, sizeof(csv), root, \"python_reference/csv\")" in text
        assert "directory_exists(assets)" in text


def test_release_check_runs_new_gates_before_build() -> None:
    text = (ROOT / "scripts" / "release_check.sh").read_text(encoding="utf-8")
    body = text.split("run_step 'Artefaktmanifest", 1)[1]
    artifact = body.index("check_artifact_manifest_consistency.sh")
    matrix = body.index("check_install_profile_matrix.sh")
    bridge = body.index("check_release_bridge_policy.sh")
    build = body.index("build-all.sh")
    assert artifact < matrix < bridge < build


def test_user_readme_points_to_hardening_checks() -> None:
    text = (ROOT / "README.md").read_text(encoding="utf-8")
    assert "scripts/check_install_profile_matrix.sh" in text
    assert "scripts/check_release_bridge_policy.sh" in text
    assert "standard` does not install Python" in text
    assert "`standard` kein Python" in text
