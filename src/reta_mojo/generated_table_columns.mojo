"""Native table-level generated-column morphisms.

This module applies the already ported scalar classifiers to an owned ``CsvTable``
and ports the first stateful generated-column algorithms from
``reta_architecture/generated_columns.py``.  The order is deliberately identical
to ``TableGenerationOrchestrator._apply_generated_column_morphisms`` for the
families implemented here.
"""

from std.collections import List
from .csv_table import CsvTable, read_semicolon_csv
from .resource_paths import csv_resource
from .number_theory import moon_number
from .generated_aliases import (
    FractionColumnRequest,
    MetaColumnRequest,
    ModalConcept,
    sort_modal_concepts,
)
from .prime_cross_columns import generate_prime_cross_columns
from .prime_universe_columns import (
    generate_integer_prime_universe_columns,
    generate_fractional_prime_universe_columns,
)
from .prime_effect_columns import generate_prime_effect_columns
from .meta_columns import generate_meta_columns
from .fraction_concat_columns import generate_fraction_concat_columns
from .generated_columns import (
    equality_freedom_value,
    mind_energy_topology_value,
    prime_creativity_value,
    celestial_value,
)


@fieldwise_init
struct GeneratedTableResult(Copyable):
    var table: CsvTable
    var output_columns: List[Int]
    var generated_names: List[String]


@fieldwise_init
struct MultipleSource(Copyable):
    var row: Int
    var content: String


def _contains_column_generated(columns: List[Int], wanted: Int) -> Bool:
    for index in range(len(columns)):
        if columns[index] == wanted:
            return True
    return False


def _contains_generated_command(commands: List[String], wanted: String) -> Bool:
    for index in range(len(commands)):
        if commands[index] == wanted:
            return True
    return False


def _cell(table: CsvTable, row: Int, column: Int) -> String:
    if row < 0 or row >= len(table.rows):
        return ""
    if column < 0 or column >= len(table.rows[row]):
        return ""
    return table.rows[row][column]


def _append_column(table: CsvTable, values: List[String]) -> CsvTable:
    var rows = List[List[String]]()
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        if row_index < len(values):
            row.append(values[row_index])
        else:
            row.append("")
        rows.append(row^)
    return CsvTable(rows^, table.maximum_columns + 1)


def _column_index_after_append(table: CsvTable) -> Int:
    return table.maximum_columns


def _append_generated(
    table: CsvTable,
    values: List[String],
    mut output_columns: List[Int],
    mut generated_names: List[String],
    name: String,
) -> CsvTable:
    var index = _column_index_after_append(table)
    var result = _append_column(table, values)
    output_columns.append(index)
    generated_names.append(name)
    return result^


def _prime_csv_heading(language: String) -> String:
    if language == "english" or language == "en" or language == "englisch":
        return "prime multiples, not generated"
    return "Primzahlvielfache, nicht generiert"


def _prime_csv_column(
    main_table: CsvTable,
    last_row: Int,
    output_mode: String,
    language: String,
    path: String = "",
) raises -> List[String]:
    var source_path = path if path.byte_length() > 0 else csv_resource("primenumbers.csv")
    var source = read_semicolon_csv(source_path)
    var values = List[String]()
    values.append(_prime_csv_heading(language))
    for row_index in range(1, len(main_table.rows)):
        if row_index > last_row or row_index >= len(source.rows):
            values.append("")
            continue
        var row = source.rows[row_index].copy()
        var content = String()
        var item_count = 0
        if output_mode == "html":
            content = "<ul>"
        elif output_mode == "bbcode":
            content = "[list]"
        for column_index in range(len(row)):
            var cell = row[column_index]
            if String(cell.strip()).byte_length() <= 3:
                continue
            if output_mode == "html":
                content += "<li>" + cell + "</li>"
            elif output_mode == "bbcode":
                content += "[*]" + cell
            else:
                if item_count == 0:
                    content = "| " + cell
                else:
                    content += " | " + cell
            item_count += 1
        if output_mode == "html":
            content += "</ul>"
        elif output_mode == "bbcode":
            content += "[/list]"
        elif item_count == 0:
            content = "|"
        else:
            content += " |"
        values.append(content^)
    return values^


def _scalar_column(
    table: CsvTable,
    last_row: Int,
    kind: Int,
    language: String,
) -> List[String]:
    var values = List[String]()
    for row_index in range(len(table.rows)):
        if row_index > last_row:
            values.append("")
        elif kind == 0:
            values.append(prime_creativity_value(row_index, language))
        elif kind == 1:
            values.append(equality_freedom_value(row_index, language))
        elif kind == 2:
            values.append(mind_energy_topology_value(row_index, language))
        else:
            values.append(celestial_value(row_index, language))
    return values^


def love_polygon_value(
    table: CsvTable,
    row: Int,
    language: String = "german",
) -> String:
    var love = String(_cell(table, row, 8).strip())
    if love.byte_length() == 0:
        return ""
    var structure_size = String(_cell(table, row, 4).strip())
    if language == "english" or language == "en":
        return love + " own structure size (" + structure_size + ") on you with regular polygons"
    return love + " der eigenen Strukturgröße (" + structure_size + ") auf dich bei gleichförmigen Polygonen"


def _love_polygon_column(
    table: CsvTable,
    last_row: Int,
    language: String,
) -> List[String]:
    var values = List[String]()
    for row_index in range(len(table.rows)):
        if row_index <= last_row:
            values.append(love_polygon_value(table, row_index, language))
        else:
            values.append("")
    return values^


def _moon_labels(language: String) -> Tuple[String, String, String]:
    if language == "english" or language == "en":
        return ("moon type of a star polygon", "moon type of a uniform polygon", "no moon")
    return ("Mond-Typ eines Sternpolygons", "Mond-Typ eines gleichförmigen Polygons", "kein Mond")


def moon_relation_value(
    table: CsvTable,
    number: Int,
    source_column: Int,
    output_mode: String,
    language: String = "german",
) -> String:
    var labels = _moon_labels(language)
    if number == 0:
        return labels[0] if source_column == 44 else labels[1]
    var moon = moon_number(number)
    var bases = moon[0].copy()
    var exponents_minus_two = moon[1].copy()
    if len(bases) == 0:
        if output_mode == "html":
            return "<ul>" + labels[2] + "</ul>"
        if output_mode == "bbcode":
            return "[list]" + labels[2] + "[/list]"
        return labels[2]

    var result = String()
    if output_mode == "bbcode":
        result += "[list]"
    elif output_mode == "html":
        result += "<ul>"

    for index in range(len(bases)):
        if index > 0:
            result += " | "
        if output_mode == "html":
            result += "<li>"
        elif output_mode == "bbcode":
            result += "[*]"

        var basis = bases[index]
        var exponent_row = exponents_minus_two[index] + 2
        var insertion = _cell(table, basis, source_column).replace(
            "<SG>", String(_cell(table, number, 4).strip())
        )
        insertion = insertion.replace(
            "&lt;SG&gt;", String(_cell(table, number, 4).strip())
        )
        result += insertion
        result += " - "
        result += _cell(table, exponent_row, 10)
        result += " | "
        if output_mode == "html":
            result += "</li>"
        result += _cell(table, number, 10)
        result += " + "
        result += _cell(table, number, 11)
        result += ", "
        result += _cell(table, exponent_row, 85)

    if output_mode == "html":
        result += "</ul>"
    elif output_mode == "bbcode":
        result += "[/list]"
    return result^


def _moon_relation_column(
    table: CsvTable,
    last_row: Int,
    source_column: Int,
    output_mode: String,
    language: String,
) -> List[String]:
    var values = List[String]()
    for row_index in range(len(table.rows)):
        if row_index <= last_row:
            values.append(
                moon_relation_value(
                    table, row_index, source_column, output_mode, language
                )
            )
        else:
            values.append("")
    return values^


def _collect_multiple_sources(
    table: CsvTable,
    source_column: Int,
    last_row: Int,
) -> List[MultipleSource]:
    var sources = List[MultipleSource]()
    var stop = min(last_row, len(table.rows) - 1)
    for row_index in range(2, stop + 1):
        var content = _cell(table, row_index, source_column)
        if String(content.strip()).byte_length() > 0:
            sources.append(MultipleSource(row_index, content))
    return sources^


def _same_as_existing_legacy(current: String, candidate: String) -> Bool:
    return (
        current == candidate
        or current + " | " == candidate
        or "<li>" + current + "</li>" == candidate
        or "[*]" + current == candidate
    )


def _propagated_multiple_value(
    table: CsvTable,
    sources: List[MultipleSource],
    row_index: Int,
    source_column: Int,
    output_mode: String,
) -> String:
    var existing = _cell(table, row_index, source_column)
    var result = existing
    if String(existing.strip()).byte_length() > 0:
        if output_mode == "html":
            result = "<li>" + existing + "</li>"
        elif output_mode == "bbcode":
            result = "[*]" + existing
        else:
            result = existing + " | "

    var appended_plain = False
    for source_index in range(len(sources)):
        var source = sources[source_index].copy()
        if source.row == 0 or row_index % source.row != 0 or source.row == row_index:
            continue
        if _same_as_existing_legacy(result, source.content):
            continue
        if source.content.byte_length() == 0:
            continue
        if output_mode == "html":
            result += "<li>" + source.content + "</li>"
        elif output_mode == "bbcode":
            result += "[*]" + source.content
        else:
            result += source.content + " | "
            appended_plain = True

    if output_mode == "html":
        return "<ul>" + result + "</ul>"
    if output_mode == "bbcode":
        return "[list]" + result + "[/list]"
    if appended_plain and result.endswith(" | "):
        return String(StringSlice(result)[byte=:-3])
    return result^


def propagate_multiples_column(
    table: CsvTable,
    source_column: Int,
    last_row: Int,
    output_mode: String,
) -> CsvTable:
    if source_column < 0 or source_column >= table.maximum_columns:
        return table.copy()
    var sources = _collect_multiple_sources(table, source_column, last_row)
    var rows = List[List[String]]()
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        if row_index >= 2 and row_index <= last_row and source_column < len(row):
            row[source_column] = _propagated_multiple_value(
                table, sources, row_index, source_column, output_mode
            )
        rows.append(row^)
    return CsvTable(rows^, table.maximum_columns)




def _is_english_generated(language: String) -> Bool:
    return language == "english" or language == "en" or language == "englisch"


def _modal_prefix(distance: Int, language: String) -> String:
    var magnitude = abs(distance)
    if _is_english_generated(language):
        if magnitude == 0:
            return "very: "
        if magnitude == 1:
            return "above average: "
        if magnitude == 2:
            return "medium above average: "
        if magnitude == 3:
            return "moderately above average: "
        return "very slightly above average: "
    if magnitude == 0:
        return "sehr: "
    if magnitude == 1:
        return "überdurchschnittlich: "
    if magnitude == 2:
        return "mittelstark überdurchschnittlich: "
    if magnitude == 3:
        return "mittelleicht überdurchschnittlich: "
    return "sehr leicht überdurchschnittlich: "


def _modal_generated_word(language: String) -> String:
    if _is_english_generated(language):
        return "Generated: "
    return "Generiert: "


def _modal_related_sentence(language: String) -> String:
    if _is_english_generated(language):
        return "All only related to the same structure size of a "
    return "Alles nur bezogen auf die selbe Strukturgröße einer "


def _modal_replace_polarity(text: String, language: String) -> String:
    if _is_english_generated(language):
        return text.replace("intrinsic", "first").replace("extrinsic", "second")
    return text.replace("intrinsisch", "zuerst").replace("extrinsisch", "als zweites")


def _join_generated_strings(values: List[String], separator: String) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += separator
        result += values[index]
    return result^


def _modal_operators(table: CsvTable, multiplier: Int) -> List[String]:
    var result = List[String]()
    if multiplier < 0 or multiplier >= len(table.rows):
        return result^
    if 97 < len(table.rows[multiplier]) and 98 < len(table.rows[multiplier]):
        result.append(table.rows[multiplier][97])
        result.append(table.rows[multiplier][98])
    var end = multiplier * 2
    for row_index in range(multiplier + 1, end):
        if row_index >= 0 and row_index < len(table.rows) and 42 < len(table.rows[row_index]):
            result.append(table.rows[row_index][42])
    return result^


def _modal_occurrence_rows(table: CsvTable, concept: ModalConcept) -> List[Int]:
    var result = List[Int]()
    for row_index in range(1, len(table.rows)):
        if String(_cell(table, row_index, concept.first).strip()).byte_length() > 0:
            result.append(row_index)
    return result^


def _modal_item(
    table: CsvTable,
    occurrence_row: Int,
    multiplier: Int,
    distance: Int,
    concept: ModalConcept,
    output_mode: String,
    language: String,
) -> String:
    var operators = _modal_operators(table, multiplier)
    if len(operators) < 2:
        return ""
    var content_column = concept.first if abs(distance) % 2 == 0 else concept.second
    var content = _cell(table, occurrence_row, content_column)
    if operators[0] != _cell(table, 1, 97):
        content = _modal_replace_polarity(content, language)

    var result = String()
    if output_mode == "html":
        result += "<li>"
    elif output_mode == "bbcode":
        result += "[*]"
    result += _modal_prefix(distance, language)
    result += operators[0]
    result += " "
    result += content
    result += " "
    result += operators[1]

    if abs(distance) % 2 == 1 and len(operators) > 2:
        result += ", not: " if _is_english_generated(language) else ", nicht: "
        var remaining = List[String]()
        for operator_index in range(2, len(operators)):
            remaining.append(operators[operator_index])
        result += _join_generated_strings(remaining, ", ")
        result += " (not all that): " if _is_english_generated(language) else " (das alles nicht): "
        result += _modal_replace_polarity(
            _cell(table, occurrence_row, concept.first), language
        )

    if output_mode == "html":
        result += "</li>"
    elif output_mode != "bbcode":
        result += " | "
    return result^


def modal_logic_column(
    table: CsvTable,
    concept: ModalConcept,
    last_row: Int,
    output_mode: String,
    language: String,
) -> List[String]:
    """Port ``concat_modallogik`` for one physical concept-column pair."""
    var values = List[String]()
    var occurrences = _modal_occurrence_rows(table, concept)
    var stop = min(last_row, len(table.rows) - 1)
    for row_index in range(len(table.rows)):
        if row_index == 0:
            values.append(_modal_generated_word(language) + _cell(table, 0, concept.first))
            continue
        if row_index > stop:
            values.append("")
            continue

        var content = String()
        for distance in range(-4, 5):
            var product = row_index + distance
            if product <= 0:
                continue
            for occurrence_index in range(len(occurrences)):
                var occurrence_row = occurrences[occurrence_index]
                if occurrence_row <= 0 or product % occurrence_row != 0:
                    continue
                var multiplier = product // occurrence_row
                if multiplier <= 0:
                    continue
                content += _modal_item(
                    table,
                    occurrence_row,
                    multiplier,
                    distance,
                    concept,
                    output_mode,
                    language,
                )

        if content.byte_length() > 0:
            var fill_column = 197 if (
                concept.first == 62
                or concept.first == 63
                or (concept.first >= 358 and concept.first <= 367)
                or (concept.first >= 371 and concept.first <= 374)
            ) else 4
            if output_mode == "html":
                content += "<li>" + _modal_related_sentence(language) + _cell(table, row_index, fill_column) + "</li>"
                content = "<ul>" + content + "</ul>"
            elif output_mode == "bbcode":
                content += "[*]" + _modal_related_sentence(language) + _cell(table, row_index, fill_column)
                content = "[list]" + content + "[/list]"
            else:
                content += _modal_related_sentence(language) + _cell(table, row_index, fill_column)
        values.append(content^)
    return values^


def apply_modal_logic_columns(
    table: CsvTable,
    concepts: List[ModalConcept],
    last_row: Int,
    output_mode: String,
    language: String,
    mut output_columns: List[Int],
    mut generated_names: List[String],
) -> CsvTable:
    var result = table.copy()
    var ordered = concepts.copy()
    sort_modal_concepts(ordered)
    for concept_index in range(len(ordered)):
        var concept = ordered[concept_index].copy()
        if concept.first < 0 or concept.second < 0:
            continue
        result = _append_generated(
            result,
            modal_logic_column(result, concept, last_row, output_mode, language),
            output_columns,
            generated_names,
            "concatModallogik:" + String(concept.first) + "," + String(concept.second),
        )
    return result^

def apply_native_generated_columns(
    table: CsvTable,
    selected_columns: List[Int],
    modal_concepts: List[ModalConcept],
    meta_requests: List[MetaColumnRequest],
    fraction_requests: List[FractionColumnRequest],
    generated_commands: List[String],
    language: String,
    output_mode: String,
    last_row: Int,
) raises -> GeneratedTableResult:
    """Apply the native subset in historical mutation order.

    ``selected_columns`` contains the original zero-based Reta column numbers.
    The returned selection preserves those columns and appends every generated
    column triggered by them, exactly as the Python pipeline does.
    """
    var result = table.copy()
    var output_columns = selected_columns.copy()
    var generated_names = List[String]()
    var stop = min(last_row, len(table.rows) - 1)

    # Python attaches concatTable == 1 before the four fractional CSV
    # families.  This ordering is observable in ``--alles`` and keeps the
    # described-prime column directly after the physical selection.
    # readConcatCsv(concatTable == 1): the legacy described-prime table is
    # appended before the generated-column morphism chain.
    if _contains_generated_command(generated_commands, "PrimCSV"):
        result = _append_generated(
            result,
            _prime_csv_column(result, stop, output_mode, language),
            output_columns,
            generated_names,
            "PrimCSV",
        )

    # The fractional galaxy/universe/emotion/size presheaves follow the
    # described-prime table and precede the generated-column morphism chain.
    # _concat_csv_inputs: fractional galaxy/universe/emotion/size presheaves
    # are glued before the generated-column morphism chain.
    var fraction_columns = generate_fraction_concat_columns(
        result, fraction_requests, stop, output_mode, language
    )
    for fraction_index in range(len(fraction_columns.columns)):
        var request = fraction_columns.requests[fraction_index].copy()
        var reciprocal = fraction_columns.reciprocal_flags[fraction_index]
        result = _append_generated(
            result,
            fraction_columns.columns[fraction_index],
            output_columns,
            generated_names,
            "readConcatCsv:"
            + request.domain
            + ","
            + String(request.denominator)
            + ","
            + String(reciprocal),
        )

    # concatVervielfacheZeile mutates the selected source columns before any
    # generated columns are appended.
    if _contains_column_generated(selected_columns, 90):
        result = propagate_multiples_column(result, 90, stop, output_mode)
    if _contains_column_generated(selected_columns, 19):
        result = propagate_multiples_column(result, 19, stop, output_mode)

    # concatModallogik appends one column per generated concept pair.
    result = apply_modal_logic_columns(
        result,
        modal_concepts,
        stop,
        output_mode,
        language,
        output_columns,
        generated_names,
    )

    # concatPrimCreativityType
    if _contains_column_generated(selected_columns, 64):
        result = _append_generated(
            result,
            _scalar_column(result, stop, 0, language),
            output_columns,
            generated_names,
            "concatPrimCreativityType",
        )

    # concatGleichheitFreiheitDominieren
    if _contains_column_generated(selected_columns, 132):
        result = _append_generated(
            result,
            _scalar_column(result, stop, 1, language),
            output_columns,
            generated_names,
            "concatGleichheitFreiheitDominieren",
        )

    # concatGeistEmotionEnergieMaterieTopologie
    if _contains_column_generated(selected_columns, 242):
        result = _append_generated(
            result,
            _scalar_column(result, stop, 2, language),
            output_columns,
            generated_names,
            "concatGeistEmotionEnergieMaterieTopologie",
        )

    # concatMondExponzierenLogarithmusTyp appends two columns.
    if _contains_column_generated(selected_columns, 64):
        result = _append_generated(
            result,
            _moon_relation_column(result, stop, 44, output_mode, language),
            output_columns,
            generated_names,
            "concatMondExponzierenLogarithmusTyp:44",
        )
        result = _append_generated(
            result,
            _moon_relation_column(result, stop, 56, output_mode, language),
            output_columns,
            generated_names,
            "concatMondExponzierenLogarithmusTyp:56",
        )

    # concatPrimUniverseRow, integer branch (brr == 0).  Each command
    # contributes three coordinates; overlapping coordinates are emitted once.
    var prime_universe = generate_integer_prime_universe_columns(
        result, generated_commands, stop, output_mode, language
    )
    for universe_index in range(len(prime_universe.columns)):
        var coordinate = prime_universe.coordinates[universe_index].copy()
        result = _append_generated(
            result,
            prime_universe.columns[universe_index],
            output_columns,
            generated_names,
            "concatPrimUniverseRow:"
            + String(coordinate.polygon)
            + ","
            + String(coordinate.combination)
            + ",0",
        )

    # concatPrimUniverseRow, fractional-rational branch (brr == 1).
    var fractional_prime_universe = generate_fractional_prime_universe_columns(
        result, generated_commands, stop, output_mode, language
    )
    for universe_index in range(len(fractional_prime_universe.columns)):
        var coordinate = fractional_prime_universe.coordinates[universe_index].copy()
        result = _append_generated(
            result,
            fractional_prime_universe.columns[universe_index],
            output_columns,
            generated_names,
            "concatPrimUniverseRow:"
            + String(coordinate.polygon)
            + ","
            + String(coordinate.combination)
            + ",1",
        )

    # concatPrimzahlkreuzProContra appends the forward and reverse relation
    # columns after the moon columns and before the love-polygon column.
    if _contains_generated_command(generated_commands, "primzahlkreuzprocontra"):
        var prime_cross = generate_prime_cross_columns(
            result, stop, output_mode, language
        )
        result = _append_generated(
            result,
            prime_cross.forward,
            output_columns,
            generated_names,
            "concatPrimzahlkreuzProContra:forward",
        )
        result = _append_generated(
            result,
            prime_cross.reverse,
            output_columns,
            generated_names,
            "concatPrimzahlkreuzProContra:reverse",
        )

    # concatLovePolygon runs after prime-universe/prime-cross in Python.
    if _contains_column_generated(selected_columns, 9):
        result = _append_generated(
            result,
            _love_polygon_column(result, stop, language),
            output_columns,
            generated_names,
            "concatLovePolygon",
        )

    # spalteFuerGegenInnenAussenSeitlichPrim: one generated column per
    # selected prime-effect source, sorted with Richtung-Richtung first.
    var prime_effect = generate_prime_effect_columns(
        result, generated_commands, stop, language
    )
    for effect_index in range(len(prime_effect.columns)):
        result = _append_generated(
            result,
            prime_effect.columns[effect_index],
            output_columns,
            generated_names,
            "spalteFuerGegenInnenAussenSeitlichPrim:"
            + String(prime_effect.source_columns[effect_index]),
        )

    # spalteMetaKontretTheorieAbstrakt_etc_1 follows prime effects and emits
    # two columns per selected (metavariable, side) coordinate.
    var meta_columns = generate_meta_columns(
        result, meta_requests, stop, output_mode, language
    )
    for meta_index in range(len(meta_columns.columns)):
        var request = meta_columns.requests[meta_index].copy()
        var inverse = meta_columns.inversion_flags[meta_index]
        result = _append_generated(
            result,
            meta_columns.columns[meta_index],
            output_columns,
            generated_names,
            "spalteMetaKontretTheorieAbstrakt_etc:"
            + String(request.metavariable)
            + ","
            + String(request.side)
            + ","
            + String(inverse),
        )

    # createSpalteGestirn is the final generated-column morphism.
    if _contains_column_generated(selected_columns, 64):
        result = _append_generated(
            result,
            _scalar_column(result, stop, 3, language),
            output_columns,
            generated_names,
            "createSpalteGestirn",
        )

    return GeneratedTableResult(result^, output_columns^, generated_names^)
