from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_current_stage_and_previous_runtime_gate_are_chained() -> None:
    current = _text("scripts/test_current_stage.sh")
    current_stage = _text("scripts/test_stage12c5bd.sh")
    newest = _text("scripts/test_stage12c5bc.sh")
    positive_first = _text("scripts/test_stage12c5bb.sh")
    stage = _text("scripts/test_stage12c5ba.sh")
    assert "test_stage12c5" in current
    assert '"$ROOT/scripts/test_stage12c5bc.sh"' in current_stage
    assert '"$ROOT/scripts/test_stage12c5bb.sh"' in newest
    assert '"$ROOT/scripts/test_stage12c5ba.sh"' in positive_first
    assert '"$ROOT/scripts/test_stage12c5az.sh"' in stage
    assert "tests/test_build_compiler_options.py" in stage
    assert "tests/test_build_thread_option_dedup.py" in stage
    assert "tests/test_prompt_mixed_fraction_multiple_source.py" in stage


def test_effectful_integer_conversion_is_explicitly_propagated() -> None:
    source = _text("src/reta_mojo/prompt_table_execution.mojo")
    assert (
        "def _merge_expanded_reciprocal_multiple_rows(\n"
        "    seed_rows: List[String],\n"
        "    pairs: List[_PromptFractionPair],\n"
        "    upper_exclusive: Int,\n"
        ") raises -> List[String]:"
    ) in source
    assert (
        "def _expanded_reciprocal_multiple_rows(\n"
        "    pairs: List[_PromptFractionPair], upper_exclusive: Int\n"
        ") raises -> List[String]:"
    ) in source
    assert "attempts.append(Int(seed_rows[index]))" in source


def test_stage_document_records_both_real_compiler_failures_and_native_noops() -> None:
    document = _text(
        "STAGE12C5BA_BUILD_THREADS_RAISES_NEGATIVE_FRACTION_NOOPS.md"
    )
    assert "Number of threads can only be specified once" in document
    assert "cannot call function that may raise" not in document  # summarized, not copied blindly
    assert "_merge_expanded_reciprocal_multiple_rows" in document
    assert "universum v-1/4,2/3" in document
    assert "universum v-2/3" in document
    assert "universum v-2/3,1/4" in document
    assert "universum v1/4,-2/3" in document
    assert "universum v1/4,-1/8,2/3" in document
