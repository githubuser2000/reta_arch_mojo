from __future__ import annotations

import hashlib
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "architecture_probe"


def test_generated_architecture_probe_assets_are_current() -> None:
    subprocess.run(
        [sys.executable, str(ROOT / "tools/generate_architecture_probe_assets.py"), "--check"],
        cwd=ROOT,
        check=True,
    )



def test_generator_removes_runtime_cache_state_before_snapshot() -> None:
    cache = ROOT / "python_reference" / "reta_architecture" / "__pycache__"
    cache.mkdir(parents=True, exist_ok=True)
    marker = cache / "artificial.cpython-test.pyc"
    marker.write_bytes(b"not bytecode; only a runtime-artifact regression marker")
    subprocess.run(
        [sys.executable, str(ROOT / "tools/generate_architecture_probe_assets.py"), "--check"],
        cwd=ROOT,
        check=True,
    )
    assert not cache.exists()


def test_generator_ignores_local_unmanifested_outputs_git_parent_and_home() -> None:
    marker = ROOT / "python_reference" / "local-only-architecture-output.alx"
    marker.write_text("must not enter a canonical architecture snapshot\n", encoding="utf-8")
    try:
        with tempfile.TemporaryDirectory(prefix="reta-home-") as home:
            env = {**os.environ, "HOME": home}
            subprocess.run(
                [sys.executable, str(ROOT / "tools/generate_architecture_probe_assets.py"), "--check"],
                cwd=ROOT,
                env=env,
                check=True,
            )
    finally:
        marker.unlink(missing_ok=True)


def test_generator_uses_manifest_isolation_and_portable_home_token() -> None:
    source = (ROOT / "tools/generate_architecture_probe_assets.py").read_text(encoding="utf-8")
    assert "_canonical_reference_tree" in source
    assert "SOURCE_MANIFEST.sha256" in source
    assert "TemporaryDirectory" in source
    assert '"os.get_terminal_size"' in source
    assert "side_effect=OSError" in source
    prompt = (ASSETS / "prompt-session-json.json").read_text(encoding="utf-8")
    assert "@@RETA_HOME@@/.ReTaPromptHistory" in prompt
    assert "/home/oai" not in prompt
    assert "/home/alex" not in prompt


def test_manifest_has_all_static_reference_commands() -> None:
    lines = (ASSETS / "manifest.tsv").read_text(encoding="utf-8").splitlines()
    assert len(lines) == 63
    names = []
    for line in lines:
        name, size_text, digest = line.split("\t")
        payload = (ASSETS / name).read_bytes()
        assert len(payload) == int(size_text)
        assert hashlib.sha256(payload).hexdigest() == digest
        names.append(name)
    assert "snapshot-json.json" in names
    assert "architecture-diagram-md.md" in names
    assert "package-integrity-json.json" not in names


def test_assets_are_portable_and_native_loader_has_no_python_bridge() -> None:
    for path in ASSETS.iterdir():
        if path.is_file():
            text = path.read_text(encoding="utf-8")
            assert str(ROOT) not in text
    mojo = (ROOT / "src/reta_mojo/architecture_probe_assets.mojo").read_text(encoding="utf-8")
    main = (ROOT / "src/architecture_probe_main.mojo").read_text(encoding="utf-8")
    combined = mojo + main
    assert "std.python" not in combined
    assert "subprocess" not in combined
    assert "python_reference/reta_architecture_probe_py.py" not in combined
    assert 'command == "package-integrity-json"' in main
    assert "default_repo_manifest" in main
    parity = (ROOT / "scripts/check_architecture_probe_parity.py").read_text(encoding="utf-8")
    assert '"PYTHONDONTWRITEBYTECODE": "1"' in parity
    assert 'HOME_TOKEN = "@@RETA_HOME@@"' in parity
    assert "home_root" in mojo


def test_domain_probe_owns_final_architecture_command() -> None:
    source = (ROOT / "src/domain_probe_main.mojo").read_text(encoding="utf-8")
    assert 'command == "architecture-json"' in source
    assert "load_architecture_snapshot_json" in source
    parity = (ROOT / "scripts/check_domain_probe_parity.py").read_text(encoding="utf-8")
    assert '("mains",)' in parity
    assert '("architecture-json",)' in parity
    assert 'ASSET_DIR / "snapshot-json.json"' in parity


def test_build_install_and_launcher_include_architecture_probe() -> None:
    build = (ROOT / "scripts/build.sh").read_text(encoding="utf-8")
    targets = (ROOT / "scripts/install_targets.txt").read_text(encoding="utf-8")
    launcher = ROOT / "bin/reta-mojo-architecture-probe"
    assert "src/architecture_probe_main.mojo reta-mojo-architecture-probe" in build
    assert "reta-mojo-architecture-probe" in targets.splitlines()
    assert launcher.exists()
    assert launcher.stat().st_mode & 0o111
