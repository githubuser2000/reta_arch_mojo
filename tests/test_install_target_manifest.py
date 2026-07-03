from __future__ import annotations

import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "scripts/install_targets.txt"

REGULAR = {
    "reta-mojo-native",
    "reta-mojo-table",
    "reta-mojo-tags",
    "reta-mojo-i18n",
    "reta-mojo-package-integrity",
    "reta-mojo-exports",
    "reta-mojo-facade",
    "reta-mojo-sheaves",
    "reta-mojo-table-generation",
    "reta-mojo-workflow",
    "reta-mojo-combi-join",
    "reta-mojo-domain-probe",
    "reta-native",
    "reta-mojo-compat-bin",
    "reta-prompt-native",
    "reta-prompt-complete",
    "grundStrukHtml-native",
    "generate-html-native",
    "generate-readme-native",
    "reta-extract-html-classes-native",
}
HEAVY = {
    "reta-mojo-semantics",
    "reta-mojo-schema",
    "reta-mojo-architecture",
    "reta-mojo-boundaries",
    "reta-mojo-contracts",
    "reta-mojo-witnesses",
    "reta-mojo-coherence",
    "reta-mojo-traces",
    "reta-mojo-impact",
    "reta-mojo-migration",
    "reta-mojo-rehearsal",
    "reta-mojo-activation",
    "reta-mojo-validation",
    "reta-mojo-progress",
    "reta-mojo-persistence",
    "reta-mojo-execution-network",
    "reta-mojo-parallel-execution",
    "reta-mojo-row-preparation",
}


def _manifest_names() -> list[str]:
    return [
        line
        for raw in MANIFEST.read_text(encoding="utf-8").splitlines()
        if (line := raw.strip()) and not line.startswith("#")
    ]


def test_manifest_is_complete_unique_and_excludes_stale_debug_targets() -> None:
    names = _manifest_names()
    assert len(names) == len(set(names)) == 38
    assert set(names) == REGULAR | HEAVY
    assert "reta-native-o0" not in names


def test_installer_copies_only_manifested_compiler_targets(tmp_path: Path) -> None:
    target_dir = ROOT / "target/bin"
    target_dir_preexisted = target_dir.exists()
    target_dir.mkdir(parents=True, exist_ok=True)
    created_required: list[Path] = []
    for name in ("reta-native", "reta-mojo-compat-bin", "generate-html-native"):
        path = target_dir / name
        if not path.exists():
            path.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
            path.chmod(0o755)
            created_required.append(path)

    stale = target_dir / "reta-unofficial-stale-test"
    stale.write_text("stale\n", encoding="utf-8")
    stale.chmod(0o755)
    stage = tmp_path / "stage"
    try:
        result = subprocess.run(
            [str(ROOT / "scripts/install.sh")],
            cwd=ROOT,
            env={
                **os.environ,
                "DESTDIR": str(stage),
                "PREFIX": "/usr",
                "RETA_INSTALL_MOJO_RUNTIME": "0",
            },
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        assert result.returncode == 0, result.stderr
        installed = stage / "usr/lib/reta/target/bin"
        actual = {path.name for path in installed.iterdir() if path.is_file()}
        expected = {
            name for name in _manifest_names() if (ROOT / "target/bin" / name).is_file()
        }
        assert actual == expected
        assert "reta-unofficial-stale-test" not in actual
        assert "reta-native-o0" not in actual
        layout = (stage / "usr/lib/reta/INSTALL_LAYOUT").read_text(encoding="utf-8")
        assert f"compiled_targets={len(expected)}" in layout
    finally:
        stale.unlink(missing_ok=True)
        for path in created_required:
            path.unlink(missing_ok=True)
        if not target_dir_preexisted:
            target_dir.rmdir()
            target_dir.parent.rmdir()


def test_build_layout_checks_every_regular_target() -> None:
    layout = (ROOT / "scripts/check_build_layout.sh").read_text(encoding="utf-8")
    prefix = "expected='"
    line = next(raw for raw in layout.splitlines() if raw.startswith(prefix))
    expected = set(line[len(prefix):-1].split())
    assert expected == REGULAR
