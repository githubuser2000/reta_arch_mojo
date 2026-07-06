from pathlib import Path


def test_hintere_commands_do_not_cross_python_bridge() -> None:
    root = Path(__file__).resolve().parents[1]
    source = (root / "src" / "prompt_main.mojo").read_text(encoding="utf-8")
    assert "from reta_mojo.prompt_external_commands import" in source
    assert "bridge.run_shell_prompt_line" not in source
    assert "bridge.run_python_prompt_line" not in source
    assert "bridge.run_math_prompt_line" not in source
    assert "run_shell_prompt_arguments_native(external_process.arguments)" in source
    assert "run_python_prompt_payload_native(external_process.payload)" in source
    assert "run_math_prompt_payload_native(external_process.payload)" in source
    assert (
        "run_reta_arguments_native(\n                external_process.arguments, reference_root()"
        in source
    )
    assert "run_reta_line_native(command.raw)" not in source
    assert "run_reta_prompt_arguments_native" in source


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
    assert 'scripts/select_reference_python.sh' in source
    assert 'RETA_PROJECT_ROOT="$ROOT"' in source
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


def test_prompt_controller_has_no_embedded_python_boundary() -> None:
    root = Path(__file__).resolve().parents[1]
    controller = (root / "src" / "prompt_main.mojo").read_text(encoding="utf-8")
    prompt_modules = [
        path.read_text(encoding="utf-8")
        for path in (root / "src" / "reta_mojo").glob("prompt*.mojo")
    ]
    assert "from std.python import" not in controller
    assert "PythonObject" not in controller
    assert "prompt_python_bridge" not in controller
    assert not (root / "src" / "reta_mojo" / "prompt_python_bridge.mojo").exists()
    assert all("from std.python import" not in source for source in prompt_modules)
    assert "run_reta_prompt_arguments_native" in controller
    assert "run_reta_arguments_native" in controller
    assert "run_reta_line_native" not in controller


def test_native_tty_input_is_the_prompt_controller_boundary() -> None:
    root = Path(__file__).resolve().parents[1]
    controller = (root / "src" / "prompt_main.mojo").read_text(encoding="utf-8")
    native_input = (
        root / "src" / "reta_mojo" / "native_prompt_input.mojo"
    ).read_text(encoding="utf-8")
    terminal_input = (
        root / "src" / "reta_mojo" / "prompt_terminal_input.mojo"
    ).read_text(encoding="utf-8")
    assert "read_native_prompt_line" in controller
    assert "read_terminal_prompt_line" in native_input
    assert "prompt_line_editor" in terminal_input
    assert "tcgetattr" in terminal_input
    assert "cfmakeraw" in terminal_input
    assert "tcsetattr" in terminal_input


def test_external_adapter_exposes_payload_and_argument_children_only() -> None:
    root = Path(__file__).resolve().parents[1]
    adapter = (root / "src" / "reta_mojo" / "prompt_external_commands.mojo").read_text(
        encoding="utf-8"
    )
    assert "def run_shell_prompt_arguments_native(" in adapter
    assert "def run_shell_prompt_payload_native(" in adapter
    assert "def run_python_prompt_payload_native(" in adapter
    assert "def run_math_prompt_payload_native(" in adapter
    assert "def raw_command_payload(" not in adapter
    assert "def run_reta_arguments_native(" in adapter
    assert "def run_shell_prompt_line_native(" not in adapter
    assert "def run_python_prompt_line_native(" not in adapter
    assert "def run_math_prompt_line_native(" not in adapter
    assert "def run_reta_line_native(" not in adapter
