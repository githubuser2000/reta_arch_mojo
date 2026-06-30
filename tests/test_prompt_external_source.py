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
    assert "run_reta_line_native(command.raw)" in source
    assert "run_reta_prompt_fallback_native(" in source


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


def test_external_adapter_avoids_conflicting_dynamic_link_symbols() -> None:
    root = Path(__file__).resolve().parents[1]
    source = (
        root / "src" / "reta_mojo" / "prompt_external_commands.mojo"
    ).read_text(encoding="utf-8")
    assert 'external_call["system", c_int]' in source
    assert 'external_call["dlsym"' not in source
    assert 'external_call["dlopen"' not in source
    assert 'external_call["posix_spawn"' not in source
    assert 'external_call["waitpid"' not in source


def test_prompt_controller_encapsulates_python_types() -> None:
    root = Path(__file__).resolve().parents[1]
    controller = (root / "src" / "prompt_main.mojo").read_text(encoding="utf-8")
    adapter = (
        root / "src" / "reta_mojo" / "prompt_python_bridge.mojo"
    ).read_text(encoding="utf-8")
    assert "from std.python import" not in controller
    assert "PythonObject" not in controller
    assert "from reta_mojo.prompt_python_bridge import" in controller
    assert "from std.python import Python" in adapter
    assert "read_prompt_line_encoded_bridge" in adapter
    assert "run_reta_prompt_line_encoded_bridge" not in adapter
    assert "run_reta_line_bridge" not in adapter
    assert "run_reta_prompt_fallback_native" in controller
    assert "run_reta_line_native" in controller


def test_only_tty_input_remains_in_embedded_prompt_python_adapter() -> None:
    root = Path(__file__).resolve().parents[1]
    controller = (root / "src" / "prompt_main.mojo").read_text(encoding="utf-8")
    adapter = (
        root / "src" / "reta_mojo" / "prompt_python_bridge.mojo"
    ).read_text(encoding="utf-8")
    assert "run_reta_prompt_line_encoded_bridge" not in controller
    assert "run_reta_line_bridge" not in controller
    assert "bridge.run_reta_prompt_line_encoded" not in adapter
    assert "bridge.run_reta_line" not in adapter
    assert adapter.count("bridge.") == 1
    assert "bridge.read_prompt_line_encoded(encoded)" in adapter
