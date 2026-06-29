"""Native Mojo orchestration for the historical ``generate_html`` program.

Asset loading, middle-file handling, hierarchy rendering and byte-preserving
page assembly are native Mojo.  The still-unported ``-spalten --alles`` table
family remains one explicit child-process boundary until the complete all-column
matrix is owned by the native table engine; no CPython runtime is embedded in
this executable.
"""

from std.io import FileHandle
from std.os import getenv
from std.subprocess import run
from std.sys import argv
from reta_mojo.csv_table import read_text_file
from reta_mojo.grundstrukturen_html import render_grundstrukturen_html


def _language_from_arguments(
    args: Span[StaticString, StaticConstantOrigin],
) -> String:
    var language = String()
    for index in range(1, len(args)):
        var argument = String(args[index])
        if argument == "-language=english" or argument == "-language=englisch":
            language = "english"
        elif argument == "-language=deutsch" or argument == "-language=german":
            language = "german"
        elif (
            argument == "-language=vietnamese"
            or argument == "-language=vietnamesisch"
            or argument == "-language=tiếngviệt"
        ):
            language = "vietnamese"
        elif (
            argument == "-language=chinese"
            or argument == "-language=chinesisch"
            or argument == "-language=中國人"
        ):
            language = "chinese"
        elif (
            argument == "-language=korean"
            or argument == "-language=koreanisch"
            or argument == "-language=한국인"
        ):
            language = "korean"
    return language^


def _shell_quote(value: String) -> String:
    return "'" + value.replace("'", "'\"'\"'") + "'"


def _write_text_file(path: String, text: String) raises:
    var file = open(path, "w")
    file.write_all(text.as_bytes())


def _generate_middle(language: String) raises -> String:
    var override = String(getenv("RETA_GENERATE_HTML_MIDDLE_FILE").strip())
    if override.byte_length() > 0:
        var middle = read_text_file(override)
        _write_text_file("middle.alx", middle)
        return middle^

    var reference_python = String(getenv("RETA_REFERENCE_PYTHON", "python3").strip())
    if reference_python.byte_length() == 0:
        reference_python = "python3"
    var command = (
        _shell_quote(reference_python)
        + " python_reference/reta.py -spalten --alles --breite=0"
        + " -ausgabe --art=html --onetable --nocolor"
    )
    if language.byte_length() > 0:
        command += " -language=" + _shell_quote(language)
    var row_limit = String(getenv("RETA_GENERATE_HTML_ROWS").strip())
    if row_limit.byte_length() > 0:
        command += " -zeilen --vorhervonausschnitt=" + _shell_quote(row_limit)
    command += " > middle.alx && printf RETA_GENERATE_HTML_OK"
    var marker = run(command)
    if marker != "RETA_GENERATE_HTML_OK":
        raise Error("reta HTML generation failed")
    return read_text_file("middle.alx")


def _write_stdout(text: String) raises:
    var stdout_file = FileHandle()
    stdout_file.handle = 1
    stdout_file.write_all(text.as_bytes())


def main() raises:
    var language = _language_from_arguments(argv())
    var hierarchy_html = render_grundstrukturen_html(True, language)
    var middle = _generate_middle(language)
    var document = (
        read_text_file("assets/html/head1.alx")
        + read_text_file("assets/html/religionen.js")
        + read_text_file("assets/html/head2.alx")
        + middle
        + hierarchy_html
        + read_text_file("assets/html/footer.alx")
    )
    _write_stdout(document)
