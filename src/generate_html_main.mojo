"""Native Mojo orchestration for the historical ``generate_html`` program.

The Grundstrukturen hierarchy and command orchestration are native Mojo.  Until
the complete table engine is ported, only generation of ``middle.alx`` crosses
the explicit compatibility boundary to the bundled Python reference.
"""

from std.sys import argv
from std.python import Python
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


def main() raises:
    var language = _language_from_arguments(argv())
    var hierarchy_html = render_grundstrukturen_html(True, language)
    Python.add_to_path("python_reference")
    var bridge = Python.import_module("mojo_bridge")
    bridge.generate_html_document(hierarchy_html, language)
