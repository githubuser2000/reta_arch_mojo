"""Reusable native owner of the historical complete HTML document pipeline."""

from std.collections import List
from std.io import FileHandle
from std.os import getenv
from .csv_table import read_text_file
from .native_reta_cli import run_native_reta
from .resource_paths import asset_resource, csv_resource


def _write_text_file(path: String, text: String) raises:
    var file = open(path, "w")
    file.write_all(text.as_bytes())
    file.close()


def _write_middle_if_requested(middle: String) raises:
    var output = String(getenv("RETA_GENERATE_HTML_MIDDLE_OUTPUT").strip())
    if output.byte_length() == 0 and String(
        getenv("RETA_GENERATE_HTML_LEGACY_MIDDLE").strip()
    ) == "1":
        output = "middle.alx"
    if output.byte_length() > 0:
        _write_text_file(output, middle)


def generate_html_middle(language: String = "") raises -> String:
    var override = String(getenv("RETA_GENERATE_HTML_MIDDLE_FILE").strip())
    if override.byte_length() > 0:
        var middle = read_text_file(override)
        _write_middle_if_requested(middle)
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
    var middle = run_native_reta(tokens, csv_resource("religion.csv"))
    _write_middle_if_requested(middle)
    return middle^


def assemble_html_document(
    native_hierarchy_html: String,
    language: String = "",
) raises -> String:
    return (
        read_text_file(asset_resource("html/head1.alx"))
        + read_text_file(asset_resource("html/religionen.js"))
        + read_text_file(asset_resource("html/head2.alx"))
        + generate_html_middle(language)
        + native_hierarchy_html
        + read_text_file(asset_resource("html/footer.alx"))
    )


def write_html_document_stdout(document: String) raises:
    var stdout_file = FileHandle()
    stdout_file.handle = 1
    stdout_file.write_all(document.as_bytes())
