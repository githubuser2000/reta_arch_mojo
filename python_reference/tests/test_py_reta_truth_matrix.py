from i18n.words_matrix import paraNdataMatrix
from i18n.words_context import ParametersMain


def _entry_columns(main, alias):
    for entry in paraNdataMatrix:
        entry_main, aliases, columns = entry[:3]
        if entry_main == main and alias in aliases:
            return columns
    raise AssertionError(f"matrix entry not found: {main!r} / {alias!r}")


def test_strukturgroesse_matches_py_reta_truth_alternative_groessenordnungen():
    expected = {4, 21, 54, 197, 425, 745}
    assert _entry_columns(ParametersMain.grundstrukturen, "Strukturgrösse") == expected
    assert _entry_columns(ParametersMain.strukturgroesse, "Strukturgrösse") == expected


def test_organisationen_matches_py_reta_truth_alternative_groessenordnungen():
    assert _entry_columns(ParametersMain.strukturgroesse, "Organisationen") == {30, 82, 425, 745}
