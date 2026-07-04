from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "src/reta_mojo/parallel_execution.mojo"
NUMBER_TEST = ROOT / "tests/test_parallel_number_processes.mojo"
ROW_TEST = ROOT / "tests/test_parallel_row_processes.mojo"


def test_legacy_process_spellings_normalize_to_threads() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    process_branch = source.split(
        'if (\n        mode == "process"', 1
    )[1].split('if mode == "auto"', 1)[0]
    assert 'return "threads"' in process_branch
    assert 'return "processes"' not in process_branch
    assert 'def should_use_processes(self, item_count: Int) -> Bool:' in source
    assert 'return False' in source.split(
        'def should_use_processes(self, item_count: Int) -> Bool:', 1
    )[1].split('@fieldwise_init', 1)[0]


def test_every_legacy_process_alias_delegates_to_thread_backend() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    aliases = {
        "decode_religion_rows_in_processes": "decode_religion_rows_threaded",
        "decode_kombi_rows_in_processes": "decode_kombi_rows_threaded",
        "moon_numbers_in_processes": "moon_numbers_threaded",
        "prime_factors_in_processes": "prime_factors_threaded",
        "filter_numbers_in_processes": "filter_numbers_threaded",
        "factor_pairs_in_processes": "factor_pairs_threaded",
        "select_columns_in_processes": "select_columns_threaded",
        "max_cell_text_len_in_processes": "max_cell_text_len_threaded",
        "normalize_column_buckets_in_processes": "normalize_column_buckets_threaded",
        "prepare_kombi_join_tables_in_processes": "prepare_kombi_join_tables_threaded",
    }
    alias_section = source.split("# Legacy API aliases", 1)[1]
    for alias, owner in aliases.items():
        body = alias_section.split(f"def {alias}(", 1)[1]
        next_definition = body.find("\ndef ")
        if next_definition >= 0:
            body = body[:next_definition]
        assert f"return {owner}(" in body


def test_runtime_tests_report_the_resolved_backend_not_the_legacy_spelling() -> None:
    combined = NUMBER_TEST.read_text(encoding="utf-8") + ROW_TEST.read_text(
        encoding="utf-8"
    )
    assert combined.count('.stats.mode == "threads"') == 6
    assert '.stats.mode == "processes"' not in combined
    assert combined.count("legacy process alias uses threads") == 6
