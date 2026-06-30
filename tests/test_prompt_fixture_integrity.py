"""Integrity checks for compact-prompt golden output framing."""
from pathlib import Path

FIXTURE_DIR = Path(__file__).parent / "fixtures" / "prompt_compact_execution"


def test_compact_prompt_fixtures_have_explicit_command_line_boundary() -> None:
    fixtures = sorted(FIXTURE_DIR.glob("*.expected"))
    assert fixtures, "compact prompt fixture directory is empty"

    for fixture in fixtures:
        raw = fixture.read_bytes()
        assert raw, f"empty compact-prompt fixture: {fixture.name}"
        assert b"reta-Befehl:reta " not in raw, (
            f"announcement and command are glued in {fixture.name}"
        )

        lines = raw.decode("utf-8").splitlines()
        assert lines[0].endswith("reta-Befehl:"), (
            f"announcement line has no explicit boundary in {fixture.name}: "
            f"{lines[0]!r}"
        )
        assert len(lines) >= 2, f"missing payload line in {fixture.name}"
        assert lines[1].startswith(("reta ", "12:", "13:")), (
            f"unexpected first payload line in {fixture.name}: {lines[1]!r}"
        )
