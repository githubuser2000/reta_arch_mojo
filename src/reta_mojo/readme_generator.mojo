"""Native owner for the historical ``libs/generate4readme.py`` output.

The Python script mixes a large static manual with values from the i18n
parameter catalogue.  Four value sets inherit CPython hash iteration order, so
its output is not stable across ``PYTHONHASHSEED`` values.  The source generator
freezes the complete German and English documents under seed zero; runtime
loading and output are pure Mojo and require no Python interpreter.
"""

from std.collections import List

from .csv_table import read_text_file
from .resource_paths import asset_resource
from .os_line_endings import split_os_lines, endswith_line_ending


@fieldwise_init
struct GeneratedReadme(Copyable):
    var language: String
    var asset_name: String
    var text: String
    var byte_count: Int
    var line_count: Int


@fieldwise_init
struct ReadmeGeneratorBundle(Copyable):
    var languages: List[String]
    var assets: List[String]
    var canonical_python_hash_seed: Int


def bootstrap_readme_generator() -> ReadmeGeneratorBundle:
    return ReadmeGeneratorBundle(
        ["german", "english"],
        ["generated_readme_german.md", "generated_readme_english.md"],
        0,
    )


def normalize_readme_language(language: String) -> String:
    var normalized = String(language.strip().lower())
    if (
        normalized == "english"
        or normalized == "englisch"
        or normalized == "en"
    ):
        return "english"
    return "german"


def readme_language_from_arguments(arguments: List[String]) -> String:
    # Preserve the historical script contract: either exact token selects the
    # English document, and every other argument vector remains German.
    for index in range(len(arguments)):
        if (
            arguments[index] == "-language=english"
            or arguments[index] == "-language=englisch"
        ):
            return "english"
    return "german"


def readme_asset_name(language: String) -> String:
    if normalize_readme_language(language) == "english":
        return "generated_readme_english.md"
    return "generated_readme_german.md"


def _readme_line_count(text: String) -> Int:
    if text.byte_length() == 0:
        return 0
    var pieces = split_os_lines(text)
    return len(pieces) - 1 if endswith_line_ending(text) else len(pieces)


def generate_readme(language: String = "german") raises -> GeneratedReadme:
    var normalized = normalize_readme_language(language)
    var asset_name = readme_asset_name(normalized)
    var text = read_text_file(asset_resource(asset_name))
    return GeneratedReadme(
        normalized^,
        asset_name^,
        text.copy(),
        text.byte_length(),
        _readme_line_count(text),
    )


def readme_generator_valid(bundle: ReadmeGeneratorBundle) -> Bool:
    return (
        len(bundle.languages) == 2
        and len(bundle.assets) == 2
        and bundle.languages[0] == "german"
        and bundle.languages[1] == "english"
        and bundle.assets[0] == "generated_readme_german.md"
        and bundle.assets[1] == "generated_readme_english.md"
        and bundle.canonical_python_hash_seed == 0
    )
