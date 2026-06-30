from pathlib import Path


def test_prompt_uses_native_input_for_pipes_before_python_bridge() -> None:
    root = Path(__file__).resolve().parents[1]
    source = (root / "src" / "prompt_main.mojo").read_text(encoding="utf-8")
    assert "from reta_mojo.native_prompt_input import" in source
    assert "if native_plain_input_requested():" in source
    assert "return read_plain_prompt_line(" in source
    main = source[source.index("def main() raises:") :]
    assert 'Python.add_to_path("python_reference")' not in main
    assert 'Python.import_module("mojo_bridge")' not in main


def test_tty_editor_remains_compatibility_owned_until_key_parity() -> None:
    root = Path(__file__).resolve().parents[1]
    source = (root / "src" / "prompt_main.mojo").read_text(encoding="utf-8")
    read_line = source[source.index("def _read_line(") : source.index("def _run_fallback(")]
    assert "native_plain_input_requested" in read_line
    assert "bridge.read_prompt_line_encoded" in read_line
    assert read_line.index("native_plain_input_requested") < read_line.index("bridge.read_prompt_line_encoded")
