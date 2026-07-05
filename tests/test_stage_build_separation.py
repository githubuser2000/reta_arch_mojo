from __future__ import annotations

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"


def test_stage_scripts_never_build_installable_runtime_targets() -> None:
    offenders: list[str] = []
    for script in sorted(SCRIPTS.glob("test_stage*.sh")):
        text = script.read_text(encoding="utf-8")
        if "build_diagnostics_shared.sh" in text:
            offenders.append(f"{script.name}: shared production build")
        for line_number, line in enumerate(text.splitlines(), 1):
            stripped = line.strip()
            if stripped.startswith("#"):
                continue
            if re.search(r"(?:target/bin|\$BIN_DIR|\$TARGET_DIR)/reta-", line) and (
                " build " in f" {line} " or "-o " in line
            ):
                offenders.append(f"{script.name}:{line_number}: {stripped}")
    assert offenders == []


def test_single_full_build_entry_point_owns_regular_heavy_and_shared_outputs() -> None:
    full = (SCRIPTS / "build-all.sh").read_text(encoding="utf-8")
    regular = (SCRIPTS / "build.sh").read_text(encoding="utf-8")
    assert '"$ROOT/scripts/build-heavy.sh"' in full
    assert '"$ROOT/scripts/build.sh"' in full
    assert '"$ROOT/scripts/build_diagnostics_shared.sh"' in regular


def test_optional_shared_diagnostics_script_is_named_as_build_and_test() -> None:
    optional = SCRIPTS / "build-and-test-shared-diagnostics.sh"
    assert optional.is_file()
    assert not (SCRIPTS / "test_stage12c5z.sh").exists()
    text = optional.read_text(encoding="utf-8")
    assert "build_diagnostics_shared.sh" in text
    assert "temporary standalone parity oracles" in text


def test_setup_and_release_use_the_explicit_full_build_entry_point() -> None:
    setup = (SCRIPTS / "setup_mojo.sh").read_text(encoding="utf-8")
    release = (SCRIPTS / "release_check.sh").read_text(encoding="utf-8")
    assert './scripts/build-all.sh' in setup
    assert '${RETA_BUILD_SCOPE-all}' in setup
    assert './scripts/build-all.sh' in release


def test_full_mojo_suite_runs_through_portable_runtime_wrapper() -> None:
    wrapper = (SCRIPTS / "test_all.sh").read_text(encoding="utf-8")
    run = (SCRIPTS / "run-tests.sh").read_text(encoding="utf-8")
    runner = (ROOT / "tools/run_mojo_test_binaries.py").read_text(encoding="utf-8")
    assert 'scripts/run-tests.sh' in wrapper
    assert 'bin/mojo-runtime-exec' in run
    assert '[str(runtime_exec), str(entry.binary)]' in runner
    assert not any(
        line.strip() == '"$TARGET/$name"' for line in wrapper.splitlines()
    )
    assert "RETA_TEST_HEAVY" in wrapper


def test_three_production_build_scripts_never_compile_test_sources() -> None:
    for name in ("build.sh", "build-heavy.sh", "build-all.sh"):
        source = (SCRIPTS / name).read_text(encoding="utf-8")
        assert "tests/test_" not in source
        assert '"$ROOT/scripts/test_all.sh"' not in source
        assert '"$ROOT/scripts/test_current_stage.sh"' not in source
