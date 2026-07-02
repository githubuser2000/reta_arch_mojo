import os
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_stage12c5e_does_not_forward_wrapper_as_mojo_bin() -> None:
    text = (ROOT / "scripts/test_stage12c5e.sh").read_text(encoding="utf-8")
    assert 'MOJO_BIN="$MOJO" "$ROOT/scripts/build_concat_csv_probe.sh"' not in text
    assert '"$ROOT/scripts/build_concat_csv_probe.sh"' in text


def test_mojo_wrapper_ignores_self_referential_mojo_bin() -> None:
    text = (ROOT / "bin/mojo-real").read_text(encoding="utf-8")
    assert 'if [ "$configured_resolved" = "$SELF" ]' in text
    assert "unset MOJO_BIN" in text
    assert "MOJO-FIXED-030" in (ROOT / "KNOWN_DEFECTS.json").read_text(encoding="utf-8")


def test_self_referential_mojo_bin_falls_back_to_project_compiler(tmp_path: Path) -> None:
    root = tmp_path / "project"
    (root / "bin").mkdir(parents=True)
    (root / ".venv/bin").mkdir(parents=True)
    wrapper = root / "bin/mojo-real"
    shutil.copy2(ROOT / "bin/mojo-real", wrapper)
    wrapper.chmod(0o755)
    compiler = root / ".venv/bin/mojo"
    compiler.write_text(
        "#!/bin/sh\n"
        "if [ \"${1-}\" = --version ]; then\n"
        "  echo 'Mojo 1.0.0-test'\n"
        "  exit 0\n"
        "fi\n"
        "printf 'fake-compiler:%s\\n' \"$*\"\n",
        encoding="utf-8",
    )
    compiler.chmod(0o755)
    env = os.environ.copy()
    env["MOJO_BIN"] = str(wrapper)
    completed = subprocess.run(
        [str(wrapper), "--version"],
        env=env,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    assert completed.stdout.strip() == "Mojo 1.0.0-test"
    assert completed.stderr == ""
