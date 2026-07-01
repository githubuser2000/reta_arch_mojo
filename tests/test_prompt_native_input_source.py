from pathlib import Path


def test_prompt_controller_uses_only_native_input_paths() -> None:
    root = Path(__file__).resolve().parents[1]
    source = (root / "src" / "prompt_main.mojo").read_text(encoding="utf-8")
    read_line = source[source.index("def _read_line(") : source.index("def _run_fallback(")]
    assert "read_native_prompt_line(" in read_line
    assert "prompt_python_bridge" not in source
    assert "read_prompt_line_encoded_bridge" not in source
    assert "from std.python import" not in source
    assert "PythonObject" not in source


def test_native_input_routes_pipes_and_ttys_without_python() -> None:
    root = Path(__file__).resolve().parents[1]
    source = (
        root / "src" / "reta_mojo" / "native_prompt_input.mojo"
    ).read_text(encoding="utf-8")
    assert "if native_plain_input_requested():" in source
    assert "return read_plain_prompt_line(" in source
    assert "read_terminal_prompt_line(" in source
    assert "load_prompt_history(" in source
    assert "append_prompt_history(" in source
    assert "std.python" not in source


def test_native_tty_adapter_owns_termios_and_editor_state() -> None:
    root = Path(__file__).resolve().parents[1]
    source = (
        root / "src" / "reta_mojo" / "prompt_terminal_input.mojo"
    ).read_text(encoding="utf-8")
    assert 'external_call["tcgetattr", c_int]' in source
    assert 'external_call["cfmakeraw", NoneType]' in source
    assert 'external_call["tcsetattr", c_int]' in source
    assert "FileDescriptor(0)" in source
    assert "editor_complete(" in source
    assert "editor_history_previous(" in source
    assert "std.python" not in source
