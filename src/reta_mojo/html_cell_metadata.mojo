"""Runtime catalogs for reference-compatible HTML cell openings."""

from std.collections import List
from std.collections.string import atol
from .csv_table import read_text_file
from .resource_paths import asset_resource


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
    path: String = "",
    heading_path: String = "",
) raises -> HtmlCellCatalog:
    var entries = List[HtmlCellMetadata]()
    var cell_path = path if path.byte_length() > 0 else asset_resource("html_cell_catalog.tsv")
    var heading_source_path = heading_path if heading_path.byte_length() > 0 else asset_resource("html_heading_catalog.tsv")
    var lines = read_text_file(cell_path).split("\n")
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
    var heading_lines = read_text_file(heading_source_path).split("\n")
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


def _normalize_html_heading_text(text: String) -> String:
    return (
        String(text.strip())
        .replace("\t", " ")
        .replace("\r", " ")
        .replace("\n", " ")
    )


def html_cell_open(
    catalog: HtmlCellCatalog,
    language: String,
    source_column: Int,
    rendered_column: Int,
    heading: Bool,
    heading_text: String = "",
    prefer_rendered_position: Bool = False,
) -> String:
    var canonical_language = _canonical_html_language(language)
    var normalized_heading_text = _normalize_html_heading_text(heading_text)

    # The complete all-columns table has a frozen, authoritative position map.
    # Later entries win so the full reference fixture overrides focused cases
    # that happen to use the same small rendered position.
    if prefer_rendered_position:
        var position_found = False
        var position_heading_open = String()
        var position_body_open = String()
        for index in range(len(catalog.headings)):
            var position_entry = catalog.headings[index].copy()
            if (
                position_entry.language == canonical_language
                and position_entry.reference_rendered_column == rendered_column
            ):
                position_found = True
                position_heading_open = position_entry.heading_open
                position_body_open = position_entry.body_open
        if position_found:
            return position_heading_open^ if heading else position_body_open^

    # Parameter aliases use physical CSV indices, while the legacy HTML layer
    # first reorders and augments columns.  For catalogued semantic headings,
    # the heading text is therefore a stronger identity than the raw index.
    # Later duplicate keys intentionally win, matching Python's dict overwrite.
    var found = False
    var reference_rendered_column = 0
    var heading_open = String()
    var body_open = String()
    if normalized_heading_text.byte_length() > 0:
        for index in range(len(catalog.headings)):
            var heading_entry = catalog.headings[index].copy()
            if (
                heading_entry.language == canonical_language
                and heading_entry.heading_text == normalized_heading_text
            ):
                # Duplicate visible headings can belong to different semantic
                # columns.  In the complete all-columns table the original
                # rendered position is therefore the strongest identity.
                if heading_entry.reference_rendered_column == rendered_column:
                    if not heading:
                        return heading_entry.body_open
                    return heading_entry.heading_open
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
