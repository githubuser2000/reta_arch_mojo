"""Native Mojo orchestration for the historical ``generate_html`` program.

Asset loading, all-column table generation, hierarchy rendering and byte-preserving
page assembly are native Mojo.  The historical ``-spalten --alles`` middle table
is resolved through a generated twelve-bucket selection plan and the native table
engine; this executable starts neither Python nor a child process.
"""

from std.sys import argv
from reta_mojo.grundstrukturen_html import render_grundstrukturen_html
from reta_mojo.html_document import (
    assemble_html_document,
    write_html_document_stdout,
)


def _language_from_arguments(
    args: Span[StaticString, StaticConstantOrigin],
) -> String:
    var language = String()
    for index in range(1, len(args)):
        var argument = String(args[index])
        if (
            argument == "-language=english"
            or argument == "-language=englisch"
            or argument == "--language=english"
            or argument == "--language=englisch"
        ):
            language = "english"
        elif (
            argument == "-language=deutsch"
            or argument == "-language=german"
            or argument == "--language=deutsch"
            or argument == "--language=german"
        ):
            language = "german"
        elif (
            argument == "-language=vietnamese"
            or argument == "-language=vietnamesisch"
            or argument == "-language=tiếngviệt"
            or argument == "--language=vietnamese"
            or argument == "--language=vietnamesisch"
        ):
            language = "vietnamese"
        elif (
            argument == "-language=chinese"
            or argument == "-language=chinesisch"
            or argument == "-language=中國人"
            or argument == "--language=chinese"
            or argument == "--language=chinesisch"
        ):
            language = "chinese"
        elif (
            argument == "-language=korean"
            or argument == "-language=koreanisch"
            or argument == "-language=한국인"
            or argument == "--language=korean"
            or argument == "--language=koreanisch"
        ):
            language = "korean"
    return language^


def main() raises:
    var language = _language_from_arguments(argv())
    var hierarchy_html = render_grundstrukturen_html(True, language)
    write_html_document_stdout(
        assemble_html_document(hierarchy_html, language)
    )
