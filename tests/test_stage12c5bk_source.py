from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "src/reta_mojo/prompt_table_execution.mojo"
MOJO_TEST = ROOT / "tests/test_prompt_table_execution.mojo"
PROBE = ROOT / "tests/prompt_true_fraction_multiple_probe.mojo"
CHECKER = ROOT / "scripts/check_prompt_true_fraction_multiples.py"
REFERENCE = ROOT / "scripts/prompt_classic_fraction_guard_reference.py"
DOC = ROOT / "STAGE12C5BK_HERMETIC_PARITY_CLASSIC_FRACTION_GUARDS.md"


def test_current_stage_extends_bj_and_forwards_compiler_options() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    stage = (ROOT / "scripts/test_stage12c5bk.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bk.sh" in current
    assert 'test_stage12c5bj.sh" -- "$@"' in stage
    assert 'check_prompt_true_fraction_multiples.sh" -- "$@"' in stage
    assert "mojo_validate_build_options" in stage
    assert "hermetic native representative command parity" in stage
    assert "RETA_SHARE_DIR=/__reta_parity_must_ignore__/share" in stage
    assert "tests/test_command_parity_environment.py" in stage


def test_planner_separates_explicit_and_projected_integer_axes() -> None:
    source = MODULE.read_text(encoding="utf-8")
    assert "var has_explicit_integer_axis = len(row_parts) > 0" in source
    assert "def _only_fraction_domains_or_inert_classic_commands(" in source
    assert "is_classic_integer_prompt_table_family(canonical)" in source
    for command in ("mond", "primzahlkreuz", "alles"):
        assert (
            f'_contains(canonical_words, "{command}") and '
            "has_explicit_integer_axis"
        ) in source
    assert ") and has_explicit_integer_axis:" in source


def test_runtime_contract_owns_pure_classic_fraction_noops_only() -> None:
    test = MOJO_TEST.read_text(encoding="utf-8")
    probe = PROBE.read_text(encoding="utf-8")
    checker = CHECKER.read_text(encoding="utf-8")
    for command in (
        "mond universum v2/3",
        "mond universum motive v2/3",
        "mond richtung primzahlkreuz alles thomas universum v2/3",
        "mond universum motive v2/3,5",
    ):
        assert command in test
        assert command in probe
        assert command in checker
    assert "serialize_prompt_table_plan(moon_multi_base)" in test
    assert 'assert_false(_plan("mond universum motive v2/3,5").handled)' in test
    assert "inert moon changed the corrected multi-domain fraction plan" in checker


def test_reference_probe_freezes_the_python_number_guard() -> None:
    source = REFERENCE.read_text(encoding="utf-8")
    assert "prompt_execution.retaExecuteNprint = collect" in source
    assert '"IndexError"' in source
    assert '"SystemExit"' in source
    assert '"mond universum motive v2/3,5"' in source
    checker = CHECKER.read_text(encoding="utf-8")
    assert "assert_python_classic_fraction_guard" in checker
    assert '("IndexError", 0, 0)' in checker
    assert 'explicit[2] != 1' in checker


def test_outer_divider_restores_one_without_duplication() -> None:
    source = MODULE.read_text(encoding="utf-8")
    helper = source[
        source.index("def _projected_fraction_divisor_rows(") :
        source.index("def _base_projected_fraction_multiple_tokens(")
    ]
    assert 'result.append("1")' in helper
    assert "if divisors[index] != 1:" in helper
    test = MOJO_TEST.read_text(encoding="utf-8")
    assert 'var one_axis_divisor = _plan("universum v2/3,1 teiler")' in test
    assert '"--vorhervonausschnitt=2,1,4,6,3,1,v1"' in test


def test_native_parity_checker_overrides_ambient_resources() -> None:
    source = (ROOT / "scripts/check_command_parity_native.py").read_text(
        encoding="utf-8"
    )
    assert 'env.pop("RETA_SHARE_DIR", None)' in source
    for name in ("RETA_ROOT", "RETA_REFERENCE_DIR", "RETA_DATA_DIR", "RETA_ASSET_DIR"):
        assert f'env["{name}"] =' in source
        assert f'env.setdefault("{name}"' not in source
    assert "first_difference(actual, expected)" in source


def test_stage_document_states_the_remaining_atomic_boundary() -> None:
    document = DOC.read_text(encoding="utf-8")
    assert "has_explicit_integer_axis" in document
    assert "mond universum motive v2/3,5" in document
    assert "atomarer Fallback" in document
    assert "Hermetische native Kommando-Parität" in document
    assert "äußere Zeile 1" in document


def test_stage_owns_incremental_test_build_and_non_raising_table_runtime() -> None:
    stage = (ROOT / "scripts/test_stage12c5bk.sh").read_text(encoding="utf-8")
    build = (ROOT / "scripts/build-tests.sh").read_text(encoding="utf-8")
    runtime = (ROOT / "src/reta_mojo/table_runtime.mojo").read_text(encoding="utf-8")
    assert "tests/test_table_runtime_complete.mojo" in stage
    assert "tests/test_incremental_test_build.py" in stage
    assert "mojo_test_build_fingerprint.py" in build
    assert "--rebuild-all" in build
    assert "== reuse %s ==" in build
    assert "self.state.highest_rows.get(114, 163)" in runtime
    assert "self.state.highest_rows.get(1024, 1024)" in runtime
