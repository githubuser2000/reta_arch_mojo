from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "src/reta_mojo/prompt_table_execution.mojo"
MOJO_TEST = ROOT / "tests/test_prompt_table_execution.mojo"
PROBE = ROOT / "tests/prompt_true_fraction_multiple_probe.mojo"
CHECKER = ROOT / "scripts/check_prompt_true_fraction_multiples.py"
REFERENCE = ROOT / "scripts/check_prompt_classic_fraction_composition.py"
DOC = ROOT / "STAGE12C5BL_CLASSIC_INTEGER_MULTI_DOMAIN_COMPOSITION.md"
PARITY = ROOT / "scripts/check_command_parity_native.py"


def test_current_stage_extends_bk_and_forwards_compiler_options() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    stage = (ROOT / "scripts/test_stage12c5bl.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bl.sh" in current
    assert 'test_stage12c5bk.sh" -- "$@"' in stage
    assert 'check_prompt_true_fraction_multiples.sh" -- "$@"' in stage
    assert "check_prompt_classic_fraction_composition.py" in stage
    assert "mojo_validate_build_options" in stage


def test_multi_domain_planner_owns_classic_integer_order() -> None:
    source = MODULE.read_text(encoding="utf-8")
    assert "var shared_whole_rows = List[String]()" in source
    assert "def _append_unique_projection_rows(" in source
    assert "def _base_true_fraction_prime_cross_tokens(" in source
    assert "var ordered = List[PromptTableInvocation]()" in source
    assert "_base_true_fraction_prime_cross_tokens(" in source
    assert 'result.append("--oberesmaximum=1029")' in source
    assert "return PromptTablePlan(True, ordered^)" in source


def test_runtime_contract_covers_prefix_suffix_and_projection_union() -> None:
    test = MOJO_TEST.read_text(encoding="utf-8")
    probe = PROBE.read_text(encoding="utf-8")
    checker = CHECKER.read_text(encoding="utf-8")
    commands = (
        "mond universum motive v2/3,5",
        "mond universum motive v2/3,5 teiler",
        "mond emotion universum v2/3,5",
        "mond richtung primzahlkreuz alles thomas universum motive v2/3,5",
    )
    for command in commands:
        assert command in test
        assert command in probe
        assert command in checker
    assert "assert_equal(len(all_classic_explicit.invocations), 31)" in test
    assert '"--vorhervonausschnitt=2,1,4,6,3,5,v5"' in test
    assert "classic moon did not union domain projections" in checker


def test_reference_probe_freezes_only_the_outer_python_composition() -> None:
    source = REFERENCE.read_text(encoding="utf-8")
    assert "prompt_execution.retaExecuteNprint = collect" in source
    assert "calls[:-1] != base" in source
    assert "Thomas did not precede" in source
    assert 'prime_cross[1] != "--oberesmaximum=1029"' in source
    assert "classic fraction composition reference: 10/10" in source


def test_stage_document_explains_corrected_union_not_python_rectangle() -> None:
    document = DOC.read_text(encoding="utf-8")
    assert "Emotion projiziert `[2,1]`" in document
    assert "Universum `[2,1,4,6,3]`" in document
    assert "31 Aufrufe" in document
    assert "nicht als Beleg für ihr inneres Bruchrechteck" in document


def test_native_parity_isolated_from_wide_stdin_terminal() -> None:
    source = PARITY.read_text(encoding="utf-8")
    stage = (ROOT / "scripts/test_stage12c5bl.sh").read_text(encoding="utf-8")
    defects = (ROOT / "KNOWN_DEFECTS.json").read_text(encoding="utf-8")
    document = DOC.read_text(encoding="utf-8")
    assert "stdin=subprocess.DEVNULL" in source
    assert 'env["COLUMNS"] = "80"' in source
    assert 'env["LINES"] = "24"' in source
    assert "COLUMNS=197" in stage
    assert "terminal-independent native representative command parity" in stage
    assert "TEST-FIXED-058" in defects
    assert "180-Spalten-Pseudoterminal" in document
