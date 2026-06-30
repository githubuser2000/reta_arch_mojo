"""Native Mojo orchestration for the historical ``generate_html`` program.

Asset loading, all-column table generation, hierarchy rendering and byte-preserving
page assembly are native Mojo.  The historical ``-spalten --alles`` middle table
is resolved through a generated twelve-bucket selection plan and the native table
engine; this executable starts neither Python nor a child process.
"""

from std.collections import List
from std.io import FileHandle
from std.os import getenv
from std.sys import argv
from reta_mojo.csv_table import read_text_file
from reta_mojo.grundstrukturen_html import render_grundstrukturen_html
from reta_mojo.native_reta_cli import run_native_reta


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


def _write_text_file(path: String, text: String) raises:
    var file = open(path, "w")
    file.write_all(text.as_bytes())


def _generate_middle(language: String) raises -> String:
    var override = String(getenv("RETA_GENERATE_HTML_MIDDLE_FILE").strip())
    if override.byte_length() > 0:
        var middle = read_text_file(override)
        _write_text_file("middle.alx", middle)
        return middle^

    var tokens = List[String]()
    tokens.append("-spalten")
    tokens.append("--alles")
    tokens.append("--breite=0")
    tokens.append("-ausgabe")
    tokens.append("--art=html")
    tokens.append("--onetable")
    tokens.append("--nocolor")
    if language.byte_length() > 0:
        tokens.append("-language=" + language)
    var row_limit = String(getenv("RETA_GENERATE_HTML_ROWS").strip())
    if row_limit.byte_length() > 0:
        tokens.append("-zeilen")
        tokens.append("--vorhervonausschnitt=" + row_limit)
    var middle = run_native_reta(tokens, "python_reference/csv/religion.csv")
    _write_text_file("middle.alx", middle)
    return middle^


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
