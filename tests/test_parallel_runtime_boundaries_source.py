from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PARALLEL = ROOT / "src/reta_mojo/parallel_execution.mojo"
WORKFLOW = ROOT / "src/reta_mojo/program_workflow.mojo"
LEGACY = ROOT / "src/reta_mojo/legacy_reta_program.mojo"
LEGACY_TEST = ROOT / "tests/test_legacy_reta_program.mojo"


def test_environment_effect_is_split_from_pure_parallel_config_mapping() -> None:
    source = PARALLEL.read_text(encoding="utf-8")
    assert "struct ParallelEnvironmentValues(Copyable)" in source
    assert "def parallel_config_from_environment_values(" in source
    assert "def read_parallel_environment()" in source
    assert "def parallel_config_from_environment()" in source
    pure = source.split("def parallel_config_from_environment_values(", 1)[1].split(
        "def read_parallel_environment()", 1
    )[0]
    assert "getenv(" not in pure
    effect = source.split("def read_parallel_environment()", 1)[1].split(
        "def parallel_config_from_environment()", 1
    )[0]
    assert effect.count("getenv(") == 6
    assert "__RETA_ENV_UNSET_12C5AS__" in effect


def test_no_runtime_environment_call_remains_in_a_default_argument() -> None:
    offenders: list[str] = []
    for path in (ROOT / "src").rglob("*.mojo"):
        source = path.read_text(encoding="utf-8")
        # Limit the check to typed parameter declarations; ordinary runtime
        # assignments such as ``var config = ...`` are intentionally allowed.
        if re.search(
            r":\s*ParallelExecutionConfig\s*=\s*parallel_config_from_environment\(\)",
            source,
        ):
            offenders.append(str(path.relative_to(ROOT)))
        if re.search(r":\s*[^,\n]+\s*=\s*getenv\(", source):
            offenders.append(str(path.relative_to(ROOT)))
    assert offenders == []


def test_parallel_argv_and_bundle_apis_require_explicit_inherited_config() -> None:
    source = PARALLEL.read_text(encoding="utf-8")
    extract_header = source.split("def extract_parallel_config_from_argv(", 1)[1].split(
        ") -> ParallelArgvResult:", 1
    )[0]
    assert "inherited: ParallelExecutionConfig" in extract_header
    assert "parallel_config_from_environment" not in extract_header
    bundle_header = source.split("def bootstrap_parallel_execution(", 1)[1].split(
        ") -> ParallelExecutionBundle:", 1
    )[0]
    assert "config: ParallelExecutionConfig" in bundle_header
    assert "parallel_config_from_environment" not in bundle_header
    assert "def bootstrap_parallel_execution_from_environment()" in source


def test_program_workflow_requires_parallel_config_at_every_runtime_entry() -> None:
    source = WORKFLOW.read_text(encoding="utf-8")
    assert "parallel_config_from_environment" not in source
    assert source.count("config: ParallelExecutionConfig,") == 4
    for name in (
        "_load_religion_table",
        "bring_all_important_begin_things",
        "workflow_everything",
        "load_program_workflow_religion_table",
    ):
        header = source.split(f"def {name}(", 1)[1].split(")", 1)[0]
        assert "config: ParallelExecutionConfig" in header


def test_legacy_program_has_deterministic_and_runtime_bootstraps() -> None:
    source = LEGACY.read_text(encoding="utf-8")
    assert "def bootstrap_legacy_reta_program_with_parallel_config(" in source
    assert "extract_parallel_config_from_argv(" in source
    runtime = source.split("def bootstrap_legacy_reta_program(", 1)[1].split(
        "def produceAllSpaltenNumbers(", 1
    )[0]
    assert "parallel_config_from_environment()" in runtime
    test_source = LEGACY_TEST.read_text(encoding="utf-8")
    assert "bootstrap_legacy_reta_program_with_parallel_config(" in test_source
    assert "make_parallel_config(\"off\"" in test_source
    assert "bootstrap_legacy_reta_program(" not in test_source


def test_stage_12c5as_remains_in_current_chain_and_keeps_compilation_user_invoked() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    monotonic_stage = (ROOT / "scripts/test_stage12c5aw.sh").read_text(encoding="utf-8")
    head = (ROOT / "scripts/test_stage12c5av.sh").read_text(encoding="utf-8")
    startup_stage = (ROOT / "scripts/test_stage12c5au.sh").read_text(encoding="utf-8")
    prompt_stage = (ROOT / "scripts/test_stage12c5at.sh").read_text(encoding="utf-8")
    stage = (ROOT / "scripts/test_stage12c5as.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bi.sh" in current
    presheaf_stage = (ROOT / "scripts/test_stage12c5bd.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bc.sh" in presheaf_stage
    installed_launcher_stage = (ROOT / "scripts/test_stage12c5bc.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bb.sh" in installed_launcher_stage
    positive_first_stage = (ROOT / "scripts/test_stage12c5bb.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ba.sh" in positive_first_stage
    build_fix_stage = (ROOT / "scripts/test_stage12c5ba.sh").read_text(encoding="utf-8")
    assert "test_stage12c5az.sh" in build_fix_stage
    mixed_fraction_stage = (ROOT / "scripts/test_stage12c5az.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ay.sh" in mixed_fraction_stage
    process_alias_stage = (ROOT / "scripts/test_stage12c5ay.sh").read_text(encoding="utf-8")
    historical_prompt_stage = (ROOT / "scripts/test_stage12c5ax.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ax.sh" in process_alias_stage
    assert "test_stage12c5aw.sh" in historical_prompt_stage
    assert "test_stage12c5av.sh" in monotonic_stage
    assert "test_stage12c5au.sh" in head
    assert "test_stage12c5at.sh" in startup_stage
    assert "test_stage12c5as.sh" in prompt_stage
    assert "test_stage12c5ar.sh" in stage
    for test in (
        "test_parallel_execution_config.mojo",
        "test_program_workflow.mojo",
        "test_legacy_reta_program.mojo",
    ):
        assert test in stage
    for build_script in ("build.sh", "build-heavy.sh", "build-all.sh"):
        source = (ROOT / "scripts" / build_script).read_text(encoding="utf-8")
        assert "tests/test_legacy_reta_program.mojo" not in source
