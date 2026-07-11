from __future__ import annotations

import errno
import hashlib
import importlib.util
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


def test_runtime_cache_cleanup_retries_directory_not_empty(
    tmp_path: Path, monkeypatch
) -> None:
    script = ROOT / "tools" / "generate_architecture_probe_assets.py"
    spec = importlib.util.spec_from_file_location("architecture_probe_generator_test", script)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    reference_root = tmp_path / "python_reference"
    cache = reference_root / "reta_architecture" / "__pycache__"
    cache.mkdir(parents=True)
    (cache / "artificial.pyc").write_bytes(b"cache")
    real_rmtree = module.shutil.rmtree
    attempts = 0

    def flaky_rmtree(path: Path) -> None:
        nonlocal attempts
        attempts += 1
        if attempts == 1:
            raise OSError(errno.ENOTEMPTY, "simulated concurrent cache recreation")
        real_rmtree(path)

    monkeypatch.setattr(module.shutil, "rmtree", flaky_rmtree)
    module._remove_runtime_artifacts(reference_root)
    assert attempts >= 2
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


def test_generator_ignores_host_processor_topology() -> None:
    with tempfile.TemporaryDirectory(prefix="reta-sitecustomize-") as directory:
        sitecustomize = Path(directory) / "sitecustomize.py"
        sitecustomize.write_text(
            "import os\n"
            "os.cpu_count = lambda: 173\n"
            "os.process_cpu_count = lambda: 19\n"
            "os.sched_getaffinity = lambda _pid: set(range(17))\n",
            encoding="utf-8",
        )
        env = {**os.environ, "PYTHONPATH": directory}
        subprocess.run(
            [sys.executable, str(ROOT / "tools/generate_architecture_probe_assets.py"), "--check"],
            cwd=ROOT,
            env=env,
            check=True,
        )
    snapshot = __import__("json").loads(
        (ASSETS / "snapshot-json.json").read_text(encoding="utf-8")
    )
    parallel = snapshot["parallel_execution"]
    assert parallel["default_workers"] == 8
    assert parallel["processor_cores"] == {
        "physical": 8,
        "virtual": 8,
        "available": 8,
        "default_workers": 8,
    }


def test_generator_uses_manifest_isolation_and_portable_home_token() -> None:
    source = (ROOT / "tools/generate_architecture_probe_assets.py").read_text(encoding="utf-8")
    assert "_canonical_reference_tree" in source
    assert "SOURCE_MANIFEST.sha256" in source
    assert "TemporaryDirectory" in source
    assert '"os.get_terminal_size"' in source
    assert "side_effect=OSError" in source
    assert "CANONICAL_PROCESSOR_CORES = 8" in source
    assert '"os.cpu_count"' in source
    assert '"os.process_cpu_count"' in source
    assert '"os.sched_getaffinity"' in source
    prompt = (ASSETS / "prompt-session-json.json").read_text(encoding="utf-8")
    assert "@@RETA_HOME@@/.ReTa_arch_mojo_prompt_history" in prompt
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
    launcher = ROOT / "tools/wrappers/reta-mojo-architecture-probe"
    assert "src/architecture_probe_main.mojo reta-mojo-architecture-probe" in build
    assert "reta-mojo-architecture-probe" in targets.splitlines()
    assert launcher.exists()
    assert launcher.stat().st_mode & 0o111
