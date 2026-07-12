from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_stty_size_is_read_as_rows_then_columns() -> None:
    source = (
        ROOT
        / "python_reference"
        / "reta_architecture"
        / "console_io.py"
    ).read_text(encoding="utf-8")

    assert (
        'shell_rows_amount, columns_amount = '
        'os.popen("stty size", "r").read().split()'
    ) in source
    assert (
        'columns_amount, shell_rows_amount = '
        'os.popen("stty size", "r").read().split()'
    ) not in source
