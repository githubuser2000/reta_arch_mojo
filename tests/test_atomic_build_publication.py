from __future__ import annotations

from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def test_build_scripts_publish_temporary_outputs_only_after_validation() -> None:
    regular = (ROOT / "scripts/build.sh").read_text(encoding="utf-8")
    heavy = (ROOT / "scripts/build-heavy.sh").read_text(encoding="utf-8")
    shared = (ROOT / "scripts/build_diagnostics_shared.sh").read_text(
        encoding="utf-8"
    )
    for source in (regular, heavy):
        assert ".tmp.$$" in source
        assert 'mv -f "$ACTIVE_TMP" "$final_output"' in source
        assert "file -b" in source
        assert "stamp_mojo_binary.sh" in source
    assert "trap sanitize_binaries EXIT" not in heavy
    assert 'mv -f "$TMP_LIBRARY" "$LIBRARY"' in shared
    assert 'mv -f "$TMP_LOADER" "$LOADER"' in shared
    assert shared.index('"$CC" -std=c11') < shared.index(
        'mv -f "$TMP_LIBRARY" "$LIBRARY"'
    )


def test_live_content_id_changes_when_a_build_recipe_changes(tmp_path: Path) -> None:
    script = ROOT / "scripts/current_source_id.sh"
    before = subprocess.run(
        [str(script)], cwd=ROOT, text=True, stdout=subprocess.PIPE, check=True
    ).stdout
    build = ROOT / "scripts/build.sh"
    original = build.read_text(encoding="utf-8")
    try:
        build.write_text(original + "\n# content-id-probe\n", encoding="utf-8")
        after = subprocess.run(
            [str(script)], cwd=ROOT, text=True, stdout=subprocess.PIPE, check=True
        ).stdout
    finally:
        build.write_text(original, encoding="utf-8")
    assert before != after


def test_do_script_cannot_misread_a_successful_exit_status() -> None:
    source = (ROOT / "do.sh").read_text(encoding="utf-8")
    assert "set -eu" in source
    assert '"echo $?"' not in source
    assert "==" not in source
    assert source.index("scripts/build-all.sh") < source.index("git commit")
    assert source.index("scripts/test_all.sh") < source.index("git commit")
