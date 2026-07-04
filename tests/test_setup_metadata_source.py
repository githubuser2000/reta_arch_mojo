from __future__ import annotations

import ast
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference/setup.py"
CATALOG = ROOT / "src/reta_mojo/setup_metadata_catalog.mojo"
OWNER = ROOT / "src/reta_mojo/setup_metadata.mojo"


def _quoted_list(text: str, name: str) -> list[str]:
    match = re.search(rf"def {name}\(\).*?return \[(.*?)\n    \]", text, re.S)
    assert match, name
    return re.findall(r'"((?:[^"\\]|\\.)*)"', match.group(1))


def _reference_contract():
    tree = ast.parse(REFERENCE.read_text(encoding="utf-8"))
    setup_call = next(
        node
        for node in ast.walk(tree)
        if isinstance(node, ast.Call)
        and isinstance(node.func, ast.Name)
        and node.func.id == "setup"
    )
    keywords = {item.arg: item.value for item in setup_call.keywords if item.arg}
    classes = [node for node in tree.body if isinstance(node, ast.ClassDef)]
    methods = [
        child.name
        for node in classes
        for child in node.body
        if isinstance(child, ast.FunctionDef)
    ]
    return keywords, classes, methods


def test_generator_is_reproducible_and_native_owner_is_explicit():
    result = subprocess.run(
        [sys.executable, "tools/generate_setup_metadata.py", "--check"],
        cwd=ROOT,
        text=True,
        capture_output=True,
    )
    assert result.returncode == 0, result.stderr
    owner = OWNER.read_text(encoding="utf-8")
    for token in (
        "struct SetupCommandClassSpec(Copyable):",
        "struct SetupExtractMessagesPlan(Copyable):",
        "struct SetupInstallPlan(Copyable):",
        "def setup_command_specs(",
        "def setup_extract_messages_plan(",
        "scripts/install.sh",
        "scripts/install_targets.txt",
    ):
        assert token in owner
    assert "std.python" not in owner
    body = owner.split('"""', 2)[-1]
    assert "from setuptools" not in body
    assert "import setuptools" not in body


def test_reference_setup_contract_is_frozen_exactly():
    keywords, classes, methods = _reference_contract()
    assert ast.literal_eval(keywords["name"]) == "reta"
    assert ast.literal_eval(keywords["version"]) == "3.20250507.4591"
    assert len(ast.literal_eval(keywords["install_requires"])) == 6
    assert [node.name for node in classes] == [
        "Build",
        "BuildExt",
        "BuildClib",
        "BuildScripts",
        "ExtractMessages",
    ]
    assert methods == [
        "run",
        "has_ext_modules",
        "run",
        "run",
        "run",
        "initialize_options",
        "finalize_options",
        "run",
    ]


def test_generated_catalog_covers_packages_commands_and_gettext_sources():
    text = CATALOG.read_text(encoding="utf-8")
    assert _quoted_list(text, "setup_discovered_packages") == [
        "reta_architecture",
        "tests",
    ]
    assert _quoted_list(text, "setup_command_class_names") == [
        "Build",
        "BuildExt",
        "BuildClib",
        "BuildScripts",
        "ExtractMessages",
    ]
    assert _quoted_list(text, "setup_defined_command_rows") == [
        "build\\tBuild",
        "build_ext\\tBuildExt",
        "build_clib\\tBuildClib",
        "build_scripts\\tBuildScripts",
    ]
    assert _quoted_list(text, "setup_active_command_rows") == [
        "extract_messages\\tExtractMessages"
    ]
    files = _quoted_list(text, "setup_extract_message_files")
    expected = [
        path.relative_to(ROOT / "python_reference").as_posix()
        for path in sorted((ROOT / "python_reference/i18n").rglob("*.py"))
    ]
    assert files == expected
    assert "def setup_command_method_count() -> Int:\n    return 8" in text


def test_porting_matrix_promotes_setup_to_generated_native():
    generator = (ROOT / "tools/generate_porting_matrix.py").read_text(encoding="utf-8")
    assert '"setup.py": ("generiert nativ"' in generator
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(line for line in matrix.splitlines() if "`setup.py`" in line)
    assert "| generiert nativ |" in row
    assert "setup_metadata.mojo" in row
