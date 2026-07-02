from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_html_renderer_has_no_raw_string_slice() -> None:
    source = (ROOT / "src/reta_mojo/table_rendering.mojo").read_text()
    assert "StringSlice(text)[byte=" not in source
    assert "for character in text.codepoint_slices()" in source
    assert "Return a valid UTF-8 span" in source


def test_stale_binary_guard_is_centralized() -> None:
    runtime = (ROOT / "bin/mojo-runtime-exec").read_text()
    assert 'check_mojo_binary_freshness.sh" "$TARGET"' in runtime
    build = (ROOT / "scripts/build.sh").read_text()
    assert "stamp_mojo_binary.sh" in build
    assert (ROOT / "scripts/check_mojo_binary_freshness.sh").is_file()
    assert (ROOT / "scripts/current_source_id.sh").is_file()
    assert (ROOT / "scripts/stamp_mojo_binary.sh").is_file()


def test_legacy_table_handling_surface_is_complete() -> None:
    import ast
    import re

    py = (ROOT / "python_reference/libs/tableHandling.py").read_text()
    mojo = (ROOT / "src/reta_mojo/legacy_table_handling.mojo").read_text()
    tree = ast.parse(py)
    expected = None
    for node in tree.body:
        if isinstance(node, ast.Assign) and any(
            isinstance(target, ast.Name) and target.id == "__all__"
            for target in node.targets
        ):
            expected = ast.literal_eval(node.value)
            break
    assert expected is not None
    snapshot_body = mojo.split("def table_handling_snapshot", 1)[1]
    exported_block = snapshot_body.split("],", 1)[0]
    actual = re.findall(r'\"([^\"]+)\"', exported_block)
    assert actual == expected
    assert "PythonObject" not in mojo
    assert "std.python" not in mojo
    assert "subprocess" not in mojo


def test_stale_binary_guard_rejects_unmarked_target(tmp_path: Path) -> None:
    import os
    import subprocess

    target = ROOT / "target/bin/stage12c5s-fake"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text("#!/bin/sh\nexit 0\n")
    target.chmod(0o755)
    try:
        rejected = subprocess.run(
            [str(ROOT / "scripts/check_mojo_binary_freshness.sh"), str(target)],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        assert rejected.returncode == 78
        assert "Bitte neu kompilieren" in rejected.stderr
        subprocess.run(
            [str(ROOT / "scripts/stamp_mojo_binary.sh"), str(target)],
            cwd=ROOT,
            check=True,
        )
        accepted = subprocess.run(
            [str(ROOT / "scripts/check_mojo_binary_freshness.sh"), str(target)],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        assert accepted.returncode == 0, accepted.stderr
    finally:
        target.unlink(missing_ok=True)
        Path(str(target) + ".reta-source-id").unlink(missing_ok=True)
