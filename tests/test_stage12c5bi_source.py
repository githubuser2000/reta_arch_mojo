from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_extends_bh_and_forwards_compiler_options() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ee.sh" in current or "test_stage12c5ed.sh" in current:
        return
    stage = (ROOT / "scripts/test_stage12c5bi.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert 'test_stage12c5bh.sh" -- "$@"' in stage
    assert "mojo_build_options.sh" in stage
    assert 'mojo_validate_build_options "$@"' in stage
    assert 'mojo_has_thread_option "$@"' in stage
    assert 'tests/test_native_prompt_input.mojo "$@"' in stage
    assert 'tests/test_prompt_table_execution.mojo "$@"' in stage
    assert 'check_prompt_true_fraction_multiples.sh" -- "$@"' in stage


def test_prompt_history_sandbox_owns_a_string_not_a_slice() -> None:
    source = (ROOT / "tests/test_native_prompt_input.mojo").read_text(encoding="utf-8")
    assert 'var root = String(getenv("RETA_TEST_SANDBOX", "/tmp"))' in source
    assert "root = String(root.strip())" in source
    assert 'root = "/tmp"' in source
    assert '.strip()\n    if root.byte_length()' not in source


def test_reported_true_fraction_failure_uses_the_real_domain_boundary() -> None:
    test = (ROOT / "tests/test_prompt_table_execution.mojo").read_text(
        encoding="utf-8"
    )
    assert '"--vielfachevonzahlen=5" in _tokens(mixed_integer_axis, 3)' in test
    assert '"--Universum=transzendentaliereziproke"' in test
    assert 'assert_false("--vielfachevonzahlen=" in _tokens(mixed_integer_axis, 4))' in test


def test_full_test_wrapper_separates_compile_and_runtime_parallelism() -> None:
    wrapper = (ROOT / "scripts/test_all.sh").read_text(encoding="utf-8")
    build = (ROOT / "scripts/build-tests.sh").read_text(encoding="utf-8")
    assert "--run-jobs N" in wrapper
    assert '"$ROOT/scripts/build-tests.sh" -- "$@"' in wrapper
    assert '"$ROOT/scripts/build-tests.sh" --heavy -- "$@"' in wrapper
    assert '"$ROOT/scripts/run-tests.sh" --jobs "$RUN_JOBS"' in wrapper
    assert 'mojo_validate_build_options "$@"' in build
    assert '"$MOJO" build' in build and '"$@" -o "$ACTIVE_TMP"' in build
