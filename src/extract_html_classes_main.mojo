"""Native replacement for ``reta_extract_html_classes.py``."""

from std.collections import List
from std.os import getenv
from std.sys import argv

from reta_mojo.csv_table import read_text_file
from reta_mojo.html_class_extractor import extract_header_cells, render_html_class_jsonl
from reta_mojo.native_reta_cli import run_native_reta
from reta_mojo.resource_paths import csv_resource


def _native_header_html() raises -> String:
    var tokens = List[String]()
    tokens.append("-zeilen")
    tokens.append("--vorhervonausschnitt=1")
    tokens.append("-spalten")
    tokens.append("--alles")
    tokens.append("-ausgabe")
    tokens.append("--art=html")
    return run_native_reta(tokens, csv_resource("religion.csv"))


def main() raises:
    var arguments = argv()
    var output_path = String("htmlclassesPy.jsonl")
    if len(arguments) > 1:
        output_path = String(arguments[1])
    var input_path = String(getenv("RETA_HTML_CLASSES_INPUT").strip())
    var html = read_text_file(input_path) if input_path.byte_length() > 0 else _native_header_html()
    var cells = extract_header_cells(html)
    var output = open(output_path, "w")
    output.write_all(render_html_class_jsonl(cells).as_bytes())
    print("geschrieben: " + output_path)
    print("spalten: " + String(len(cells)))
