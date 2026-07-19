"""Native prime-effect generated columns from meta_columns.py."""

from std.algorithm import parallelize
from std.collections import List
from .csv_table import CsvTable
from .parallel_execution import ParallelExecutionConfig
from .number_theory import (
    couldBePrimeNumberPrimzahlkreuz,
    primCreativity,
    prime_factors,
    prime_repeat,
)


@fieldwise_init
struct PrimeEffectColumns(Copyable):
    var source_columns: List[Int]
    var columns: List[List[String]]


def _pe_english(language: String) -> Bool:
    return language == "english" or language == "en" or language == "englisch"


def _pe_contains(values: List[Int], wanted: Int) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _pe_append_unique(mut values: List[Int], value: Int):
    if not _pe_contains(values, value):
        values.append(value)


def _pe_sort(mut values: List[Int]):
    # -1 is the historical None / direction-direction column and sorts first.
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key


def _pe_parse_uint(text: String) -> Int:
    var result = 0
    for index in range(text.byte_length()):
        var code = ord(text[byte=index])
        if code < 48 or code > 57:
            return -1
        result = result * 10 + code - 48
    return result


def prime_effect_sources(commands: List[String]) -> List[Int]:
    var result = List[Int]()
    for index in range(len(commands)):
        var command = commands[index]
        if command == "prime_effect:none":
            _pe_append_unique(result, -1)
        elif command.startswith("prime_effect:"):
            var payload = String(StringSlice(command)[byte=13:])
            if payload.byte_length() > 0:
                _pe_append_unique(result, _pe_parse_uint(payload))
    _pe_sort(result)
    return result^


def _pe_heading(source: Int, language: String) -> String:
    var prefix = (
        "prime number effect (7, direction)"
        if _pe_english(language)
        else "Primzahlwirkung (7, Richtung) "
    )
    var name: String
    if source == 5:
        name = (
            "Transcendentalia, structuralia, universe n"
            if _pe_english(language)
            else "Transzendentalien, Strukturalien, Universum n"
        )
    elif source == 10:
        name = "galaxy n" if _pe_english(language) else "Galaxie n"
    elif source == 42:
        name = "galaxy 1/n" if _pe_english(language) else "Galaxie 1/n"
    elif source == 131:
        name = (
            "transcendentalia, structuralia, universe 1/n"
            if _pe_english(language)
            else "Transzendentalien, Strukturalien, Universum 1/n"
        )
    elif source == 138:
        name = (
            "against-counter-transcendentalia, counter-structuralia, universe n"
            if _pe_english(language)
            else "Dagegen-Gegen-Transzendentalien, Gegen-Strukturalien, Universum n"
        )
    elif source == 202:
        name = (
            "neutral counter-transcendentalia, counter-structuralia, universe n"
            if _pe_english(language)
            else "neutrale Gegen-Transzendentalien, Gegen-Strukturalien, Universum n"
        )
    else:
        name = "direction-direction" if _pe_english(language) else "Richtung-Richtung"
    return prefix + name


def _pe_prime_answer(
    number: Int,
    prime_amount: Int,
    old_prime_amount: Int,
    language: String,
) -> String:
    if number > 3:
        if prime_amount != old_prime_amount:
            if prime_amount % 2 == 0:
                return "for inside" if _pe_english(language) else "für innen"
            return "for outside" if _pe_english(language) else "für außen"
        return ""
    if number == 2:
        return (
            '"for other sides and against weaklings inside"'
            if _pe_english(language)
            else '"für seitlich und gegen Schwächlinge innen"'
        )
    if number == 3:
        return (
            '"against other sides and  pro weaklings inside"'
            if _pe_english(language)
            else '"gegen seitlich und für Schwächlinge innen"'
        )
    if number == 1:
        return "for outside" if _pe_english(language) else "für außen"
    return ""


def _pe_source_cell(table: CsvTable, row: Int, column: Int) -> String:
    if row < 0 or row >= len(table.rows):
        return ""
    if column < 0 or column >= len(table.rows[row]):
        return ""
    return table.rows[row][column]


def _pe_column(
    table: CsvTable,
    source: Int,
    last_row: Int,
    language: String,
) -> List[String]:
    var stop = min(last_row, len(table.rows) - 1)
    var result = List[String]()
    var previous_direction = List[String]()
    var last_prime_answers = List[String]()
    for _ in range(stop + 1):
        last_prime_answers.append("")

    var prime_amount = 0
    for number in range(stop + 1):
        if number == 0:
            var heading = _pe_heading(source, language)
            result.append(heading)
            if source == -1:
                previous_direction.append(heading)
            continue

        var old_prime_amount = prime_amount
        if couldBePrimeNumberPrimzahlkreuz(number):
            prime_amount += 1

        var value = String()
        if primCreativity(number) == 1:
            value = _pe_prime_answer(
                number, prime_amount, old_prime_amount, language
            )
            last_prime_answers[number] = value
        elif number > 1:
            var pieces = List[String]()
            var grouped = prime_repeat(prime_factors(number))
            for factor_index in range(len(grouped)):
                var prime = grouped[factor_index].first
                var amount = grouped[factor_index].second
                if amount == 1:
                    pieces.append(last_prime_answers[prime])
                elif source >= 0:
                    pieces.append(
                        _pe_source_cell(table, amount, source)
                        + " * "
                        + last_prime_answers[prime]
                    )
                else:
                    var previous = (
                        previous_direction[amount]
                        if amount < len(previous_direction)
                        else ""
                    )
                    pieces.append(
                        "["
                        + previous
                        + ("] * finally: " if _pe_english(language) else "] * letztendlich: ")
                        + last_prime_answers[prime]
                    )
            for piece_index in range(len(pieces)):
                if piece_index > 0:
                    value += " + "
                value += pieces[piece_index]
        elif number == 1:
            value = _pe_prime_answer(1, prime_amount, old_prime_amount, language)

        result.append(value)
        if source == -1:
            previous_direction.append(value)

    for _ in range(stop + 1, len(table.rows)):
        result.append("")
    return result^


def generate_prime_effect_columns(
    table: CsvTable,
    commands: List[String],
    last_row: Int,
    language: String,
) -> PrimeEffectColumns:
    var sources = prime_effect_sources(commands)
    var columns = List[List[String]]()
    for index in range(len(sources)):
        columns.append(_pe_column(table, sources[index], last_row, language))
    return PrimeEffectColumns(sources^, columns^)


def generate_prime_effect_columns_parallel(
    table: CsvTable,
    commands: List[String],
    last_row: Int,
    language: String,
    config: ParallelExecutionConfig,
) -> PrimeEffectColumns:
    """Generate independent prime-effect columns in indexed worker slots."""
    var sources = prime_effect_sources(commands)
    var columns = List[List[String]]()
    for _ in range(len(sources)):
        columns.append(List[String]())
    var work = len(sources) * max(1, min(last_row, len(table.rows) - 1) + 1)
    if len(sources) <= 1 or not config.should_use_threads(work):
        for index in range(len(sources)):
            columns[index] = _pe_column(
                table, sources[index], last_row, language
            )
        return PrimeEffectColumns(sources^, columns^)

    var workers = min(config.resolved_workers(), len(sources))

    @parameter
    def worker(index: Int):
        columns[index] = _pe_column(
            table, sources[index], last_row, language
        )

    parallelize[worker](len(sources), workers)
    return PrimeEffectColumns(sources^, columns^)

