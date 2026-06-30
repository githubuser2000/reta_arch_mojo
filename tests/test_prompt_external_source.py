from pathlib import Path


def test_hintere_commands_do_not_cross_python_bridge() -> None:
    root = Path(__file__).resolve().parents[1]
    source = (root / "src" / "prompt_main.mojo").read_text(encoding="utf-8")
    assert "from reta_mojo.prompt_external_commands import" in source
    assert "bridge.run_shell_prompt_line" not in source
    assert "bridge.run_python_prompt_line" not in source
    assert "bridge.run_math_prompt_line" not in source
    assert "run_shell_prompt_line_native(command.raw)" in source
    assert "run_python_prompt_line_native(command.raw)" in source
    assert "run_math_prompt_line_native(command.raw)" in source


def test_raw_commands_bypass_compact_parser_before_payload_scan() -> None:
    root = Path(__file__).resolve().parents[1]
    source = (root / "src" / "reta_mojo" / "prompt_language.mojo").read_text(
        encoding="utf-8"
    )
    function = source[source.index("def expand_compact_prompt_tokens(") :]
    early = function.index("if _is_raw_prompt_command")
    joined = function.index("var joined = String()")
    loop = function.index("for token_index in range(len(split_tokens))")
    assert early < joined < loop
    assert 'for canonical in ["shell", "python", "math"]' in source


def test_prompt_launcher_preserves_project_python_interpreter() -> None:
    root = Path(__file__).resolve().parents[1]
    source = (root / "bin" / "reta-prompt-profile").read_text(encoding="utf-8")
    assert '[ -z "${RETA_PYTHON-}" ]' in source
    assert '[ -x "$ROOT/.venv/bin/python" ]' in source
    assert 'export RETA_PYTHON' in source
