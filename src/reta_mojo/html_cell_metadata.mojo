"""Runtime catalogs for reference-compatible HTML cell openings."""

from std.collections import List
from std.collections.string import atol
from .csv_table import read_text_file


@fieldwise_init
struct HtmlCellMetadata(Copyable):
    var language: String
    var source_column: Int
    var heading_open: String
    var body_open: String


@fieldwise_init
struct HtmlHeadingMetadata(Copyable):
    var language: String
    var reference_rendered_column: Int
    var heading_text: String
    var heading_open: String
    var body_open: String


@fieldwise_init
struct HtmlCellCatalog(Copyable):
    var entries: List[HtmlCellMetadata]
    var headings: List[HtmlHeadingMetadata]


def load_html_cell_catalog(
    path: String = "assets/html_cell_catalog.tsv",
    heading_path: String = "assets/html_heading_catalog.tsv",
) raises -> HtmlCellCatalog:
    var entries = List[HtmlCellMetadata]()
    var lines = read_text_file(path).split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0 or line.startswith("#"):
            continue
        var fields = line.split("\t")
        if len(fields) != 4:
            continue
        entries.append(
            HtmlCellMetadata(
                String(fields[0]),
                atol(String(fields[1])),
                String(fields[2]),
                String(fields[3]),
            )
        )

    var headings = List[HtmlHeadingMetadata]()
    var heading_lines = read_text_file(heading_path).split("\n")
    for line_index in range(len(heading_lines)):
        var line = String(heading_lines[line_index])
        if line.byte_length() == 0 or line.startswith("#"):
            continue
        var fields = line.split("\t")
        if len(fields) != 5:
            continue
        headings.append(
            HtmlHeadingMetadata(
                String(fields[0]),
                atol(String(fields[1])),
                String(fields[2]),
                String(fields[3]),
                String(fields[4]),
            )
        )
    return HtmlCellCatalog(entries^, headings^)


def _canonical_html_language(language: String) -> String:
    return (
        "english"
        if language == "english" or language == "en" or language == "englisch"
        else "german"
    )


def _reindex_heading_open(
    opening: String,
    reference_rendered_column: Int,
    rendered_column: Int,
) -> String:
    return opening.replace(
        " r_" + String(reference_rendered_column) + " ",
        " r_" + String(rendered_column) + " ",
    )


def html_cell_open(
    catalog: HtmlCellCatalog,
    language: String,
    source_column: Int,
    rendered_column: Int,
    heading: Bool,
    heading_text: String = "",
) -> String:
    var canonical_language = _canonical_html_language(language)

    # Parameter aliases use physical CSV indices, while the legacy HTML layer
    # first reorders and augments columns.  For catalogued semantic headings,
    # the heading text is therefore a stronger identity than the raw index.
    # Later duplicate keys intentionally win, matching Python's dict overwrite.
    var found = False
    var reference_rendered_column = 0
    var heading_open = String()
    var body_open = String()
    if heading_text.byte_length() > 0:
        for index in range(len(catalog.headings)):
            var heading_entry = catalog.headings[index].copy()
            if (
                heading_entry.language == canonical_language
                and heading_entry.heading_text == heading_text
            ):
                found = True
                reference_rendered_column = (
                    heading_entry.reference_rendered_column
                )
                heading_open = heading_entry.heading_open
                body_open = heading_entry.body_open
    if found:
        if not heading:
            return body_open^
        return _reindex_heading_open(
            heading_open,
            reference_rendered_column,
            rendered_column,
        )

    for index in range(len(catalog.entries)):
        var entry = catalog.entries[index].copy()
        if (
            entry.language == canonical_language
            and entry.source_column == source_column
        ):
            if not heading:
                return entry.body_open
            return _reindex_heading_open(
                entry.heading_open,
                source_column + 2,
                rendered_column,
            )
    return "<td>"
