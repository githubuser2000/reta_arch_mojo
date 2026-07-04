from __future__ import annotations

import ast
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
GENERATOR = ROOT / "tools/generate_porting_matrix.py"
MATRIX = ROOT / "PORTING_MATRIX.md"

EXPECTED = {
    "reta_architecture/program_workflow.py": "nativ",
    "reta_architecture/facade.py": "teilweise nativ",
    "reta_architecture/table_adapters.py": "nativ",
    "libs/lib4tables_concat.py": "nativ",
    "reta_architecture/concat_csv.py": "nativ",
    "libs/center.py": "nativ",
    "reta_architecture/console_io.py": "nativ",
    "reta_architecture/runtime_compat.py": "nativ",
    "libs/lib4tables.py": "nativ",
    "i18n/words.py": "generiert nativ",
    "i18n/words_bootstrap.py": "generiert nativ",
    "i18n/words_context.py": "generiert nativ",
    "i18n/words_matrix.py": "generiert nativ",
    "i18n/words_runtime.py": "generiert nativ",
    "libs/nestedAlx.py": "nativ",
    "libs/word_completerAlx.py": "nativ",
    "reta_architecture/completion_nested.py": "nativ",
    "reta_architecture/completion_runtime.py": "generiert nativ",
    "reta_architecture/completion_word.py": "nativ",
    "reta_architecture/parameter_runtime.py": "weitgehend nativ",
    "reta_architecture/table_generation.py": "nativ",
    "reta_architecture/output_semantics.py": "nativ",
    "reta_architecture/output_syntax.py": "nativ",
    "reta_architecture/input_semantics.py": "generiert nativ",
    "reta_architecture/prompt_interaction.py": "nativ",
    "reta_architecture/prompt_language.py": "generiert nativ",
    "reta_architecture/prompt_preparation.py": "nativ",
    "retaPrompt.py": "weitgehend nativ",
    "libs/LibRetaPrompt.py": "nativ",
}


def native_mapping() -> dict[str, tuple[str, str, str]]:
    tree = ast.parse(GENERATOR.read_text(encoding="utf-8"))
    for node in tree.body:
        if isinstance(node, ast.Assign) and any(
            isinstance(target, ast.Name) and target.id == "NATIVE"
            for target in node.targets
        ):
            value = ast.literal_eval(node.value)
            assert isinstance(value, dict)
            return value
    raise AssertionError("NATIVE mapping missing")


def test_prior_native_ownership_is_not_lost_by_matrix_regeneration() -> None:
    mapping = native_mapping()
    for path, expected_status in EXPECTED.items():
        assert path in mapping
        assert mapping[path][0] == expected_status


def test_generated_matrix_contains_expected_statuses() -> None:
    subprocess.run([sys.executable, str(GENERATOR)], cwd=ROOT, check=True)
    text = MATRIX.read_text(encoding="utf-8")
    for path, status in EXPECTED.items():
        prefix = f"| `{path}` |"
        row = next(line for line in text.splitlines() if line.startswith(prefix))
        assert f"| {status} |" in row
