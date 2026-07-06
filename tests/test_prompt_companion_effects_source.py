from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OWNER = ROOT / "src/reta_mojo/prompt_historical_ownership.mojo"
CONTROLLER = ROOT / "src/prompt_main.mojo"
REFERENCE = ROOT / "python_reference/reta_architecture/prompt_execution.py"


def test_typed_companion_effect_bundle_uses_localized_membership() -> None:
    source = OWNER.read_text(encoding="utf-8")
    assert "struct PromptHistoricalCompanionEffects" in source
    assert "def historical_prompt_companion_effects(" in source
    assert 'canonical == "kurzbefehle"' in source
    assert 'canonical == "befehle"' in source
    assert 'canonical == "hilfe"' in source
    assert 'canonical == "help"' in source
    assert 'canonical == "h"' in source
    companion = source.split(
        "def historical_prompt_companion_effects(", 1
    )[1].split("def historical_prompt_control_supported", 1)[0]
    assert 'canonical == "leeren"' in companion
    assert "clear_before_table" in companion


def test_controller_emits_information_before_table_and_keeps_standalone_dispatch() -> None:
    source = CONTROLLER.read_text(encoding="utf-8")
    for function_name in ("_run_command", "_run_native_one_shot"):
        block = source.split(f"def {function_name}(", 1)[1]
        if function_name == "_run_command":
            block = block.split("def _run_native_one_shot", 1)[0]
        companion = block.index("var companion_effects = historical_prompt_companion_effects(")
        short = block.index("if companion_effects.show_short_commands:", companion)
        commands = block.index("if companion_effects.show_commands:", short)
        help_ = block.index("if companion_effects.show_help:", commands)
        clear = block.index("if companion_effects.clear_before_table:", help_)
        table = block.index("var handled_table = _run_native_table_plan(", clear)
        standalone = block.index("if command.kind == KIND_HELP:", table)
        assert companion < short < commands < help_ < clear < table < standalone


def test_reference_checker_freezes_order_and_compound_clear_contract() -> None:
    checker = (ROOT / "scripts/check_prompt_companion_effects.py").read_text(
        encoding="utf-8"
    )
    for name in ("kurzbefehle", "befehle", "hilfe", "leeren", "emotion"):
        assert name in checker
    source = REFERENCE.read_text(encoding="utf-8")
    assert source.index('i18n.befehle2["kurzbefehle"]') < source.index(
        'i18n.befehle2["befehle"]'
    ) < source.index('i18n.befehle2["hilfe"]') < source.index(
        'i18n.befehle2["leeren"]'
    )


def test_rejected_compound_falls_back_before_prefix_control_dispatch() -> None:
    source = CONTROLLER.read_text(encoding="utf-8")
    interactive = source.split("def _run_command(", 1)[1].split(
        "def _run_native_one_shot", 1
    )[0]
    rejected = interactive.index(
        "if (table_candidate or mulpri_candidate) and not ("
    )
    fallback = interactive.index("_run_fallback(profile, line)", rejected)
    help_dispatch = interactive.index("if command.kind == KIND_HELP:", fallback)
    clear = interactive.index("if command.kind == KIND_CLEAR:", help_dispatch)
    assert rejected < fallback < help_dispatch < clear

    one_shot = source.split("def _run_native_one_shot(", 1)[1]
    rejected_one_shot = one_shot.index(
        "if (table_candidate or mulpri_candidate) and not ("
    )
    standalone = one_shot.index("if command.kind == KIND_HELP:", rejected_one_shot)
    assert rejected_one_shot < standalone
