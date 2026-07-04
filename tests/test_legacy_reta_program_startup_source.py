from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OWNER = ROOT / "src/reta_mojo/legacy_reta_program.mojo"
TEST = ROOT / "tests/test_legacy_reta_program_startup.mojo"


def test_startup_and_controls_precede_csv_and_child_process_boundaries() -> None:
    source = OWNER.read_text(encoding="utf-8")
    body = source.split("def workflowEverything(", 1)[1].split("\ndef run(", 1)[0]
    controls = body.index("normalize_native_cli_controls(program.argv)")
    startup = body.index("native_cli_startup(controls.tokens)")
    csv = body.index('csv_resource("religion.csv")')
    native_table = body.index("native_reta_tokens_supported(controls.tokens, path)")
    child = body.index("run_reta_arguments_native(program.argv, reference_root)")
    assert controls < startup < csv < native_table < child
    assert "controls.debug_prefix + startup.output" in body
    assert "controls.debug_prefix + run_native_reta(controls.tokens, path)" in body


def test_help_adapter_uses_exact_native_startup_asset() -> None:
    source = OWNER.read_text(encoding="utf-8")
    help_body = source.split("def helpPage(", 1)[1].split(
        "\ndef bringAllImportantBeginThings(", 1
    )[0]
    assert "native_cli_startup(tokens)" in help_body
    assert "owner=console_io/reta_help" not in source


def test_compile_test_covers_all_native_startup_families() -> None:
    source = TEST.read_text(encoding="utf-8")
    for token in (
        'List[String]()',
        '"-language=english"',
        '"-h"',
        '"-help"',
        '"-debug"',
        '"-nichts"',
    ):
        assert token in source
    assert "run_reta_arguments_native" not in source
