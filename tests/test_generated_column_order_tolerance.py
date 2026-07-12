import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "tools" / "normalize_generated_column_order.py"

spec = importlib.util.spec_from_file_location("normalize_generated_column_order", MODULE_PATH)
module = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(module)


def test_prime_cross_number_lists_are_sorted_without_touching_single_explanation():
    text = (
        "pro dieser Zahl sind: 19, 3 (Motivationsgeber (19)) | "
        "contra this number are: 11, 4, 5 (Typ 17)"
    )

    assert module.normalize_text(text) == (
        "pro dieser Zahl sind: 3, 19 (Motivationsgeber (19)) | "
        "contra this number are: 4, 5, 11 (Typ 17)"
    )


def test_attached_explanation_clauses_follow_the_same_canonical_number_order():
    python_text = (
        "pro dieser Zahl sind: 19, 3 "
        "(Typ 3 kann sehr manipulativ (1) sein. , "
        "Motivationsgeber (19) sind überhaupt pro Absichten (1) "
        "(aber eigentlich pro Zielen))"
    )
    mojo_text = (
        "pro dieser Zahl sind: 3, 19 "
        "(Motivationsgeber (19) sind überhaupt pro Absichten (1) "
        "(aber eigentlich pro Zielen) , "
        "Typ 3 kann sehr manipulativ (1) sein.)"
    )

    expected = (
        "pro dieser Zahl sind: 3, 19 "
        "(Typ 3 kann sehr manipulativ (1) sein. , "
        "Motivationsgeber (19) sind überhaupt pro Absichten (1) "
        "(aber eigentlich pro Zielen))"
    )
    assert module.normalize_text(python_text) == expected
    assert module.normalize_text(mojo_text) == expected


def test_nested_commas_and_unrelated_parentheses_are_not_split_or_reordered():
    text = (
        "pro dieser Zahl sind: 19, 3 "
        "(Typ 3: eins, zwei (innen, unverändert) , Motivationsgeber (19)) | "
        "anderer Text (B, A)"
    )

    assert module.normalize_text(text) == (
        "pro dieser Zahl sind: 3, 19 "
        "(Typ 3: eins, zwei (innen, unverändert) , Motivationsgeber (19)) | "
        "anderer Text (B, A)"
    )


def test_repeated_relation_lists_are_sorted_per_relation_word():
    text = "gegen 5, gegen 4 | against 9, against 3 | pro 7, pro 2"

    assert module.normalize_text(text) == (
        "gegen 4, gegen 5 | against 3, against 9 | pro 2, pro 7"
    )
