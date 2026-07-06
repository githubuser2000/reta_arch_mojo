from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_cz_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_cy_and_checks_shared_reta_child_argv_owner() -> None:
    source = (ROOT / "scripts/test_stage12c5cz.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cy.sh" in source
    assert "shared reta child argv owner" in source
    assert "test_${test_name}_12c5cz" in source
    assert "tests/test_stage12c5cz_source.py" in source


def test_external_adapter_owns_reta_child_argument_normalization() -> None:
    adapter = (ROOT / "src/reta_mojo/prompt_external_commands.mojo").read_text(encoding="utf-8")
    assert "def reta_child_arguments_native(arguments: List[String]) -> List[String]:" in adapter
    assert "Drop an optional historical reta executable" in adapter
    assert 'arguments[0] == "reta"' in adapter
    assert 'arguments[0].endswith("/reta.py")' in adapter
    assert "def raw_command_payload(" not in adapter
    assert "def run_reta_line_native(" not in adapter


def test_legacy_bridge_and_probe_use_shared_reta_child_argv_owner() -> None:
    bridge = (ROOT / "src/reta_mojo/legacy_mojo_bridge.mojo").read_text(encoding="utf-8")
    probe = (ROOT / "tests/prompt_external_commands_probe.mojo").read_text(encoding="utf-8")
    assert "reta_child_arguments_native," in bridge
    assert "def _reta_child_arguments(" not in bridge
    assert "reta_child_arguments_native(arguments), reference_root()" in bridge
    assert "reta_child_arguments_native(shell_split(line)), reference_root()" in bridge
    assert "reta_child_arguments_native," in probe
    assert "def _reta_child_arguments(" not in probe
    assert "reta_child_arguments_native(shell_split(line)), reference_root" in probe


def test_mojo_tests_cover_shared_reta_child_argv_owner() -> None:
    test = (ROOT / "tests/test_prompt_external_commands.mojo").read_text(encoding="utf-8")
    owners = (ROOT / "tests/test_legacy_mojo_bridge.mojo").read_text(encoding="utf-8")
    assert "test_reta_child_arguments_drop_historical_entrypoint" in test
    assert 'reta_child_arguments_native(["reta", "-zeilen", "1"]' in test
    assert 'assert_equal(owners[14], "reta_child_arguments=shared-native-argv-owner")' in owners


def test_porting_matrix_mentions_shared_reta_child_argv_owner() -> None:
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(line for line in matrix.splitlines() if "`mojo_bridge.py`" in line)
    assert "gemeinsamen nativen reta-argv-Normalisierer" in row
    prompt_row = next(line for line in matrix.splitlines() if "`reta_architecture/prompt_execution.py`" in line)
    assert "gemeinsamen reta-argv-Normalisierer" in prompt_row
