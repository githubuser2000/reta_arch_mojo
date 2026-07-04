from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"


def text(name: str) -> str:
    return (SCRIPTS / name).read_text(encoding="utf-8")


def test_shared_thread_option_validator_is_used_by_public_builds() -> None:
    helper = text("mojo_build_options.sh")
    assert "def " not in helper  # POSIX shell, not an accidental Python helper
    assert "mojo_thread_option_count()" in helper
    assert "mojo_validate_build_options()" in helper
    assert "mojo_has_thread_option()" in helper
    assert "Threadanzahl wurde mehrfach angegeben" in helper
    for name in (
        "build.sh",
        "build-heavy.sh",
        "build-all.sh",
        "build_diagnostics_shared.sh",
    ):
        source = text(name)
        assert '. "$ROOT/scripts/mojo_build_options.sh"' in source
        assert 'mojo_validate_build_options "$@"' in source


def test_three_large_targets_use_user_thread_count_or_one_local_default() -> None:
    source = text("build-heavy.sh")
    assert "build_heavy_default_noopt_threaded()" in source
    assert 'if mojo_has_thread_option "$@"; then' in source
    assert '"$description" "$source_file" "$output_name" -j 4 "$@"' in source
    for output in (
        "reta-mojo-execution-network",
        "reta-mojo-parallel-execution",
        "reta-mojo-row-preparation",
    ):
        line_index = source.index(output)
        prefix = source[max(0, line_index - 220) : line_index]
        assert "build_heavy_default_noopt_threaded" in prefix
    assert "reta-mojo-execution-network -j 4" not in source
    assert "reta-mojo-parallel-execution -j 4" not in source
    assert "reta-mojo-row-preparation -j 4" not in source


def test_build_option_regression_suite_covers_user_and_default_thread_counts() -> None:
    source = (ROOT / "tests/test_build_compiler_options.py").read_text(
        encoding="utf-8"
    )
    assert "test_heavy_thread_default_is_suppressed_by_forwarded_user_value" in source
    assert "test_heavy_thread_default_is_added_only_when_user_omits_it" in source
    assert '== ["-j", "8"]' in source
    assert '== ["-j", "4"]' in source
