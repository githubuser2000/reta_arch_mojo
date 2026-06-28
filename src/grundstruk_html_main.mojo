"""Command-line entry point for the native Grundstrukturen HTML renderer."""

from std.sys import argv
from reta_mojo.grundstrukturen_html import (
    is_supported_grundstrukturen_language,
    render_grundstrukturen_html,
)


def main() raises:
    var args = argv()
    var blank = len(args) > 1 and String(args[1]) == "blank"
    var language = String()
    var selected_language = String()
    var debug = False

    for index in range(1, len(args)):
        var argument = String(args[index])
        if argument == "-language=english" or argument == "-language=englisch":
            language = "english"
            selected_language = String(StringSlice(argument)[byte=10:])
        elif argument == "-language=deutsch" or argument == "-language=german":
            language = "german"
            selected_language = String(StringSlice(argument)[byte=10:])
        elif (
            argument == "-language=vietnamese"
            or argument == "-language=vietnamesisch"
            or argument == "-language=tiếngviệt"
        ):
            language = "vietnamese"
            selected_language = String(StringSlice(argument)[byte=10:])
        elif (
            argument == "-language=chinese"
            or argument == "-language=chinesisch"
            or argument == "-language=中國人"
        ):
            language = "chinese"
            selected_language = String(StringSlice(argument)[byte=10:])
        elif (
            argument == "-language=korean"
            or argument == "-language=koreanisch"
            or argument == "-language=한국인"
        ):
            language = "korean"
            selected_language = String(StringSlice(argument)[byte=10:])
        elif argument == "-debug":
            debug = True
        elif argument != "blank":
            # Preserve the historical program's narrow argument surface.  A
            # non-language extra argument did not affect rendering.
            continue

    if not is_supported_grundstrukturen_language(language):
        raise Error("nicht unterstützte Sprache: " + language)
    if debug:
        print("Sprachenwahl:", selected_language)
        if language == "" or language == "german":
            print("german")
        else:
            print("not german")
    print(render_grundstrukturen_html(blank, language), end="")
