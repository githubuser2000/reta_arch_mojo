from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def test_prompt_session_has_single_native_owner():
    runtime = (ROOT / "src/reta_mojo/prompt_runtime.mojo").read_text(encoding="utf-8")
    session = (ROOT / "src/reta_mojo/prompt_session.mojo").read_text(encoding="utf-8")
    prompt_main = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "struct NativePromptSession" not in runtime
    assert "struct NativePromptSession" in session
    assert "struct PromptTextState" in session
    assert "from reta_mojo.prompt_session import" in prompt_main


def test_native_history_uses_python_toggle_policy():
    source = (ROOT / "src/reta_mojo/native_prompt_input.mojo").read_text(encoding="utf-8")
    assert "history_should_append" in source
    assert "history_enabled and history_should_append" in source


def test_prompt_runtime_contract_is_generated_and_typed():
    runtime = (ROOT / "src/reta_mojo/prompt_runtime.mojo").read_text(encoding="utf-8")
    catalog = (ROOT / "src/reta_mojo/prompt_runtime_catalog.mojo").read_text(encoding="utf-8")
    generator = (ROOT / "tools/generate_prompt_runtime_catalog.py").read_text(encoding="utf-8")
    assert "struct PromptRuntimeContract" in runtime
    assert "def prime_command_predicate" in runtime
    assert "def prompt_runtime_contract" in catalog
    assert "PYTHONHASHSEED" in generator


def test_dead_embedded_python_prompt_bridge_is_absent():
    assert not (ROOT / "src/reta_mojo/prompt_python_bridge.mojo").exists()


def test_prompt_main_uses_generated_localized_prefixes():
    prompt_main = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    interaction = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(encoding="utf-8")
    runtime = (ROOT / "src/reta_mojo/prompt_runtime.mojo").read_text(encoding="utf-8")
    assert "new_prompt_interaction(startup)" in prompt_main
    assert "new_prompt_session_for_language(" in interaction
    assert "startup.profile.language" in interaction
    assert "prompt_prefix_catalog" in (ROOT / "src/reta_mojo/prompt_session.mojo").read_text(encoding="utf-8")
    assert "var store_prefix: String" in runtime
    assert "var delete_prefix: String" in runtime
