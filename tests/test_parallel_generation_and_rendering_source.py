from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MOJO = ROOT / "src/reta_mojo"


def read(name: str) -> str:
    return (MOJO / name).read_text(encoding="utf-8")


def test_native_cli_threads_parallel_config_through_all_expensive_phases() -> None:
    source = read("native_reta_cli.mojo")
    for call in (
        "apply_native_generated_columns_parallel(",
        "apply_kombi_join_columns_parallel(",
        "render_table_with_native_context_parallel(",
    ):
        assert call in source
    configured = source.split("def run_native_reta_with_parallel_config(", 1)[1]
    assert configured.count("parallel_config,") >= 3


def test_generators_choose_one_parallel_axis_per_phase() -> None:
    sources = {
        "prime_universe_columns.mojo": (
            "_pu_column_parallel(",
            "_fpu_column_parallel(",
            "len(coordinates) == 1",
            "parallelize[load_worker](2, 2)",
        ),
        "fraction_concat_columns.mojo": (
            "_fraction_column_from_source_parallel(",
            "len(emitted) == 1",
            "parallelize[load_worker]",
        ),
        "kombi_join_columns.mojo": (
            "_kombi_values_for_request_parallel(",
            "len(job_requests) == 1",
            "parallelize[load_worker]",
        ),
        "generated_table_columns.mojo": (
            "_modal_logic_column_parallel(",
            "len(valid) == 1",
            "parallelize[worker]",
        ),
        "prime_effect_columns.mojo": (
            "generate_prime_effect_columns_parallel(",
            "parallelize[worker]",
        ),
        "meta_columns.mojo": (
            "generate_meta_columns_parallel(",
            "parallelize[worker]",
        ),
    }
    for filename, markers in sources.items():
        source = read(filename)
        for marker in markers:
            assert marker in source, (filename, marker)


def test_shell_and_bbcode_use_private_ordered_row_buffers() -> None:
    source = read("table_rendering.mojo")
    for function in (
        "render_shell_table_with_width_reference_parallel(",
        "render_bbcode_table_with_width_reference_parallel(",
        "_render_shell_page_rows(",
        "_render_bbcode_page_rows(",
    ):
        assert function in source
    assert source.count("chunk_results[chunk_index]") >= 6
    assert source.count("parallelize[worker]") >= 3
    assert "for chunk_index in range(chunks):\n        result += chunk_results[chunk_index]" in source


def test_width_analysis_and_prompt_state_remain_outside_workers() -> None:
    rendering = read("table_rendering.mojo")
    shell_parallel = rendering.split(
        "def render_shell_table_with_width_reference_parallel(", 1
    )[1].split("def render_table_with_width_reference_parallel(", 1)[0]
    assert "_shell_column_width(" in shell_parallel
    assert "_render_shell_page_rows(" in shell_parallel

    for filename in (
        "prompt_reaction_input.mojo",
        "prompt_reaction_storage.mojo",
        "prompt_terminal_input.mojo",
        "native_prompt_input.mojo",
    ):
        source = read(filename)
        assert "from std.algorithm import parallelize" not in source
        assert "parallelize[" not in source


def test_parallel_renderer_test_is_an_exclusive_global_barrier() -> None:
    build_tests = (ROOT / "scripts/build-tests.sh").read_text(encoding="utf-8")
    exclusive = build_tests.split("execution_class()", 1)[1].split(
        "*) printf '%s' parallel", 1
    )[0]
    assert "tests/test_table_rendering.mojo" in exclusive
