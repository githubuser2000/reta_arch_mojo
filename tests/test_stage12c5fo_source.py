from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_fo() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fo.sh" in current
    assert "test_stage12c5fn.sh" in current


def test_stage_script_chains_fn_and_checks_shared_library_plan() -> None:
    script = (ROOT / "scripts/test_stage12c5fo.sh").read_text(encoding="utf-8")
    assert "shared library target architecture" in script
    assert "test_stage12c5fn.sh" in script
    assert "test_${test_name}_12c5fo" in script
    assert "shared_library_architecture" in script
    assert "build_shared_library_targets.sh" in script and "--dry-run" in script
    assert "tests/test_stage12c5fo_source.py" in script
    assert "stage12c5fo shared library target architecture complete" in script


def test_shared_library_architecture_module_matches_user_split() -> None:
    source = (ROOT / "src/reta_mojo/shared_library_architecture.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct SharedLibraryTarget" in source
    assert "struct ThinStarterTarget" in source
    assert "struct SharedLibraryArchitecturePlan" in source
    assert "def plan_shared_library_architecture(" in source
    assert "def shared_library_architecture_valid(" in source
    assert "libreta-core.so" in source
    assert "libreta-core.dll" in source
    assert "libreta-prompt.so" in source
    assert "libreta-prompt.dll" in source
    assert "libreta-prompt-interactive.so" in source
    assert "libreta-prompt-interactive.dll" in source
    assert '"grundStrukHtml"' in source
    assert 'ThinStarterTarget("reta"' in source
    assert 'ThinStarterTarget("grundStrukHtml"' in source
    assert 'ThinStarterTarget("rpb", _starter_libraries_prompt(), False)' in source
    assert 'ThinStarterTarget("rp", _starter_libraries_prompt_interactive(), True)' in source
    assert 'ThinStarterTarget("rpl", _starter_libraries_prompt_interactive(), True)' in source
    assert 'ThinStarterTarget("rpe", _starter_libraries_prompt_interactive(), True)' in source
    assert 'if _target_has_consumer(target, "rpb"):' in source
    assert "return False" in source


def test_interactive_prompt_library_never_lists_rpb_as_consumer() -> None:
    source = (ROOT / "src/reta_mojo/shared_library_architecture.mojo").read_text(
        encoding="utf-8"
    )
    start = source.index("def _interactive_consumers")
    block = source[start : source.index("def _deps_core", start)]
    assert '"rp"' in block
    assert '"rpl"' in block
    assert '"rpe"' in block
    assert '"rpb"' not in block


def test_shared_library_test_and_package_export_exist() -> None:
    mojo_test = (ROOT / "tests/test_shared_library_architecture.mojo").read_text(
        encoding="utf-8"
    )
    package = (ROOT / "src/reta_mojo/__init__.mojo").read_text(encoding="utf-8")
    assert "test_shared_library_plan_matches_requested_split" in mojo_test
    assert "test_rpb_is_one_shot_without_interactive_input_library" in mojo_test
    assert "test_interactive_prompt_starters_share_interactive_library" in mojo_test
    assert "test_core_library_is_shared_by_reta_prompts_and_grundstrukhtml" in mojo_test
    assert "from .shared_library_architecture import *" in package


def test_shared_library_build_script_is_non_destructive_plan_scaffold() -> None:
    script = (ROOT / "scripts/build_shared_library_targets.sh").read_text(
        encoding="utf-8"
    )
    assert "libreta-core.so / libreta-core.dll" in script
    assert "libreta-prompt.so / libreta-prompt.dll" in script
    assert "libreta-prompt-interactive.so / libreta-prompt-interactive.dll" in script
    assert "rpb           -> libreta-prompt + libreta-core" in script
    assert "rp/rpl/rpe    -> libreta-prompt-interactive + libreta-prompt + libreta-core" in script
    assert "libreta-core.so ist inzwischen der erste aktiv kompilierte ABI-Build" in script
    assert "build_core_shared.sh" in script
    assert "mojo build" not in script


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FO_SHARED_LIBRARY_TARGET_ARCHITECTURE.md").read_text(
        encoding="utf-8"
    )
    assert "libreta-core" in doc
    assert "libreta-prompt" in doc
    assert "libreta-prompt-interactive" in doc
    assert "rpb" in doc
    assert "nicht" in doc.lower()
    assert "grundStrukHtml" in doc
    assert "Dünne Starter" in doc
