"""Native, deterministic view of reta's split ``i18n.words`` namespace.

The catalog is generated from the frozen Python reference for each canonical
language.  Native consumers load typed rows only; no Python interpreter,
callback, gettext object or dynamic import participates at runtime.
"""

from std.collections import List
from std.collections.string import atol
from .csv_table import read_text_file
from .resource_paths import asset_resource
from .os_line_endings import os_linesep, split_os_lines


@fieldwise_init
struct I18nWordNode(Copyable):
    var module: String
    var path: String
    var kind: String
    var value: String


@fieldwise_init
struct I18nWordsCatalog(Copyable):
    var language: String
    var nodes: List[I18nWordNode]


@fieldwise_init
struct I18nWordsSnapshot(Copyable):
    var language: String
    var rows: Int
    var roots: Int
    var bootstrap_rows: Int
    var context_rows: Int
    var matrix_rows: Int
    var runtime_rows: Int
    var facade_rows: Int
    var legacy_monolith_rows: Int


@fieldwise_init
struct LegacyI18nMonolithSnapshot(Copyable):
    var language: String
    var rows: Int
    var roots: Int
    var functions: Int
    var classes: Int


def canonical_i18n_language(language: String) -> String:
    var normalized = language.strip().lower()
    if (
        normalized.byte_length() == 0
        or normalized == "deutsch"
        or normalized == "german"
        or normalized == "de"
    ):
        return "deutsch"
    if normalized == "english" or normalized == "englisch" or normalized == "en":
        return "english"
    if (
        normalized == "vietnamese"
        or normalized == "vietnamesisch"
        or normalized == "tiếngviệt"
        or normalized == "vn"
    ):
        return "vietnamese"
    if (
        normalized == "chinese"
        or normalized == "chinesisch"
        or normalized == "中國人"
        or normalized == "cn"
    ):
        return "chinese"
    if (
        normalized == "korean"
        or normalized == "koreanisch"
        or normalized == "한국인"
        or normalized == "kr"
    ):
        return "korean"
    return "deutsch"


def i18n_words_catalog_path(language: String) -> String:
    return asset_resource(
        "i18n_words/" + canonical_i18n_language(language) + ".tsv"
    )


def _catalog_slice(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def decode_i18n_field(text: String) -> String:
    """Decode the generator's small byte-preserving TSV escape language."""
    if text.find("\\") < 0:
        return text
    var result = String()
    var bytes = text.as_bytes()
    var cursor = 0
    var chunk_start = 0
    while cursor < len(bytes):
        if Int(bytes[cursor]) != 92:  # backslash
            cursor += 1
            continue
        result += _catalog_slice(text, chunk_start, cursor)
        if cursor + 1 >= len(bytes):
            result += "\\"
            cursor += 1
            chunk_start = cursor
            continue
        var escaped = Int(bytes[cursor + 1])
        if escaped == 92:
            result += "\\"
            cursor += 2
        elif escaped == 116:
            result += "\t"
            cursor += 2
        elif escaped == 110:
            result += "\n"
            cursor += 2
        elif escaped == 114:
            result += "\r"
            cursor += 2
        elif (
            escaped == 120
            and cursor + 3 < len(bytes)
            and Int(bytes[cursor + 2]) == 49
            and Int(bytes[cursor + 3]) == 102
        ):
            result += "\x1f"
            cursor += 4
        else:
            result += "\\"
            cursor += 1
        chunk_start = cursor
    if chunk_start < len(bytes):
        result += _catalog_slice(text, chunk_start, len(bytes))
    return result^


def encode_i18n_field(text: String) -> String:
    return (
        text.replace("\\", "\\\\")
        .replace("\t", "\\t")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
        .replace("\x1f", "\\x1f")
    )


def load_i18n_words_catalog_from_path(
    language: String, path: String
) raises -> I18nWordsCatalog:
    var nodes = List[I18nWordNode]()
    var lines = split_os_lines(read_text_file(path))
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0:
            continue
        var fields = line.split("\t")
        if len(fields) != 4:
            raise Error(
                "invalid i18n words catalog row " + String(line_index + 1)
            )
        nodes.append(
            I18nWordNode(
                decode_i18n_field(String(fields[0])),
                decode_i18n_field(String(fields[1])),
                String(fields[2]),
                decode_i18n_field(String(fields[3])),
            )
        )
    return I18nWordsCatalog(canonical_i18n_language(language), nodes^)


def load_i18n_words_catalog(language: String) raises -> I18nWordsCatalog:
    return load_i18n_words_catalog_from_path(
        language, i18n_words_catalog_path(language)
    )


def render_i18n_words_catalog(catalog: I18nWordsCatalog) -> String:
    var result = String()
    for index in range(len(catalog.nodes)):
        var node = catalog.nodes[index].copy()
        result += encode_i18n_field(node.module)
        result += "\t"
        result += encode_i18n_field(node.path)
        result += "\t"
        result += node.kind
        result += "\t"
        result += encode_i18n_field(node.value)
        result += os_linesep()
    return result^


def i18n_words_node_index(
    catalog: I18nWordsCatalog, module: String, path: String
) -> Int:
    for index in range(len(catalog.nodes)):
        if (
            catalog.nodes[index].module == module
            and catalog.nodes[index].path == path
        ):
            return index
    return -1


def i18n_words_has_node(
    catalog: I18nWordsCatalog, module: String, path: String
) -> Bool:
    return i18n_words_node_index(catalog, module, path) >= 0


def i18n_words_node(
    catalog: I18nWordsCatalog, module: String, path: String
) raises -> I18nWordNode:
    var index = i18n_words_node_index(catalog, module, path)
    if index < 0:
        raise Error("unknown i18n words path: " + module + ":" + path)
    return catalog.nodes[index].copy()


def i18n_words_value(
    catalog: I18nWordsCatalog, module: String, path: String
) raises -> String:
    return i18n_words_node(catalog, module, path).value


def i18n_words_int(
    catalog: I18nWordsCatalog, module: String, path: String
) raises -> Int:
    var node = i18n_words_node(catalog, module, path)
    if node.kind != "int":
        raise Error("i18n words node is not an int: " + module + ":" + path)
    return atol(node.value)


def i18n_words_module_count(catalog: I18nWordsCatalog, module: String) -> Int:
    var count = 0
    for index in range(len(catalog.nodes)):
        if catalog.nodes[index].module == module:
            count += 1
    return count


def i18n_words_root_count(catalog: I18nWordsCatalog) -> Int:
    var count = 0
    for index in range(len(catalog.nodes)):
        var path = catalog.nodes[index].path
        if path.find("[") < 0 and path.find(".") < 0:
            count += 1
    return count


def i18n_words_module_root_count(
    catalog: I18nWordsCatalog, module: String
) -> Int:
    var count = 0
    for index in range(len(catalog.nodes)):
        var node = catalog.nodes[index].copy()
        if node.module != module:
            continue
        if node.path.find("[") < 0 and node.path.find(".") < 0:
            count += 1
    return count


def i18n_words_module_root_kind_count(
    catalog: I18nWordsCatalog, module: String, kind: String
) -> Int:
    var count = 0
    for index in range(len(catalog.nodes)):
        var node = catalog.nodes[index].copy()
        if node.module != module or node.kind != kind:
            continue
        if node.path.find("[") < 0 and node.path.find(".") < 0:
            count += 1
    return count


def i18n_words_snapshot(catalog: I18nWordsCatalog) -> I18nWordsSnapshot:
    return I18nWordsSnapshot(
        catalog.language,
        len(catalog.nodes),
        i18n_words_root_count(catalog),
        i18n_words_module_count(catalog, "i18n.words_bootstrap"),
        i18n_words_module_count(catalog, "i18n.words_context"),
        i18n_words_module_count(catalog, "i18n.words_matrix"),
        i18n_words_module_count(catalog, "i18n.words_runtime"),
        i18n_words_module_count(catalog, "i18n.words"),
        i18n_words_module_count(catalog, "i18n.words_legacy_monolith"),
    )


def classify_i18n_relation(catalog: I18nWordsCatalog, mod: Int) raises -> String:
    if mod < 0 or mod > 4:
        return ""
    return i18n_words_value(
        catalog,
        "i18n.words_runtime",
        "__behavior__.classify[" + String(mod) + "]",
    )


def contains_i18n_string(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def duplicate_i18n_strings(values: List[String]) -> List[String]:
    """Native equivalent of ``finde_mehrfache_vorkommen``.

    The first-occurrence order is retained exactly like Python's insertion-
    ordered frequency dictionary.
    """
    var duplicates = List[String]()
    for index in range(len(values)):
        var occurrences = 0
        for other in range(len(values)):
            if values[index] == values[other]:
                occurrences += 1
        if occurrences > 1 and not contains_i18n_string(duplicates, values[index]):
            duplicates.append(values[index])
    return duplicates^


def i18n_debug_value(enabled: Bool, text: String) -> None:
    if enabled:
        print(text)


def i18n_debug_pair(enabled: Bool, name: String, text: String) -> None:
    if enabled:
        print(name + ": " + text)


def legacy_i18n_monolith_snapshot(
    catalog: I18nWordsCatalog
) -> LegacyI18nMonolithSnapshot:
    var module = "i18n.words_legacy_monolith"
    return LegacyI18nMonolithSnapshot(
        catalog.language,
        i18n_words_module_count(catalog, module),
        i18n_words_module_root_count(catalog, module),
        i18n_words_module_root_kind_count(catalog, module, "function"),
        i18n_words_module_root_kind_count(catalog, module, "class"),
    )


def legacy_i18n_classify(catalog: I18nWordsCatalog, mod: Int) raises -> String:
    # The preserved monolith and split runtime share the exact classify law.
    return classify_i18n_relation(catalog, mod)


def legacy_i18n_duplicate_strings(values: List[String]) -> List[String]:
    return duplicate_i18n_strings(values)


def legacy_i18n_debug_value(enabled: Bool, text: String) -> None:
    i18n_debug_value(enabled, text)


def legacy_i18n_debug_pair(
    enabled: Bool, name: String, text: String
) -> None:
    i18n_debug_pair(enabled, name, text)
