from std.sys import argv
from std.collections import List
from reta_mojo.prompt_language import (
    PromptLanguageCatalog,
    custom_split,
    custom_split2,
    is15or16command,
    isReTaParameter,
    load_prompt_language_catalog,
    prompt_language_snapshot,
)


def _join(values: List[String]) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += "\x1f"
        result += values[index]
    return result^


def _bool(value: Bool) -> String:
    return "1" if value else "0"


def _parameter_cases(language: String) -> List[String]:
    var values = List[String]()
    if language == "deutsch":
        values.append("-zeilen")
        values.append("--zeit=heute")
        values.append("--breite=0")
    else:
        values.append("-lines")
        values.append("--time=today")
        values.append("--width=0")
    values.append("--Religionen=sternpolygon")
    values.append("-1")
    values.append("-1-3")
    values.append("-1/2")
    values.append("--unbekannt=2")
    return values^


def main() raises:
    var arguments = argv()
    if len(arguments) != 2:
        raise Error("usage: prompt_language_legacy_probe LANGUAGE")
    var language = arguments[1]
    var catalog = load_prompt_language_catalog("assets")
    var snapshot = prompt_language_snapshot(catalog, language)
    print(
        "snapshot\t" + language + "\t" + snapshot.class_name + "\t"
        + String(snapshot.not_parameter_values_len) + "\t"
        + String(snapshot.parameter_bases_len) + "\t"
        + String(snapshot.commands_len) + "\t"
        + String(snapshot.allowed_fraction_numbers_len) + "\t"
        + String(snapshot.wahl15_len) + "\t"
        + String(snapshot.wahl16_len) + "\t"
        + _join(snapshot.short_command_letters)
    )
    var parameters = _parameter_cases(language)
    for index in range(len(parameters)):
        var text = parameters[index]
        print(
            "parameter\t" + language + "\t" + text + "\t"
            + _bool(isReTaParameter(catalog, language, text))
        )
    var numeric = ["15_", "15_13_10", "16_15_13_10", "16_5", "16_999"]
    for index in range(len(numeric)):
        var text = numeric[index]
        print(
            "numeric\t" + language + "\t" + text + "\t"
            + _bool(is15or16command(catalog, language, text))
        )
    var split_cases = ["reta (1 2)  ende", "a b", "(1 2 3)"]
    for index in range(len(split_cases)):
        var text = split_cases[index]
        print("split\t" + language + "\t" + text + "\t" + _join(custom_split(text)))
    var split2_text = "1,(2,3),[4,5],6"
    print(
        "split2\t" + language + "\t" + split2_text + "\t"
        + _join(custom_split2(split2_text, ","))
    )
