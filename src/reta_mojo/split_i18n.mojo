"""Typed native replacement for ``reta_architecture.split_i18n``.

Python assembled a ``SimpleNamespace`` by importing context, matrix and runtime
modules in order.  Native Mojo cannot expose a dynamically mutating namespace,
so the same merge order is represented explicitly by a typed proxy over the
frozen i18n catalog.  Lookups walk source modules from last to first, preserving
Python's "later module wins" rule.
"""

from std.collections import List
from std.collections.string import StringSlice
from .i18n_words import (
    I18nWordNode,
    I18nWordsCatalog,
    canonical_i18n_language,
    load_i18n_words_catalog,
)


@fieldwise_init
struct SplitI18nProxy(Copyable):
    var language: String
    var source_modules: List[String]
    var catalog: I18nWordsCatalog


@fieldwise_init
struct SplitI18nSnapshot(Copyable):
    var language: String
    var source_modules: List[String]
    var node_count: Int
    var root_count: Int


def default_split_i18n_module_names() -> List[String]:
    return [
        "i18n.words_context",
        "i18n.words_matrix",
        "i18n.words_runtime",
    ]


def _contains(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _module_exists(catalog: I18nWordsCatalog, module_name: String) -> Bool:
    for index in range(len(catalog.nodes)):
        if catalog.nodes[index].module == module_name:
            return True
    return False


def build_split_i18n_proxy_from_modules(
    language: String, module_names: List[String]
) raises -> SplitI18nProxy:
    var catalog = load_i18n_words_catalog(language)
    var sources = List[String]()
    for index in range(len(module_names)):
        var module_name = module_names[index]
        if not _module_exists(catalog, module_name):
            raise Error("unknown split i18n module: " + module_name)
        sources.append(module_name)
    return SplitI18nProxy(canonical_i18n_language(language), sources^, catalog^)


def build_split_i18n_proxy(
    language: String = "deutsch",
) raises -> SplitI18nProxy:
    return build_split_i18n_proxy_from_modules(
        language, default_split_i18n_module_names()
    )


def split_i18n_node_index(proxy: SplitI18nProxy, path: String) -> Int:
    var source_index = len(proxy.source_modules) - 1
    while source_index >= 0:
        var module_name = proxy.source_modules[source_index]
        for node_index in range(len(proxy.catalog.nodes)):
            if (
                proxy.catalog.nodes[node_index].module == module_name
                and proxy.catalog.nodes[node_index].path == path
            ):
                return node_index
        source_index -= 1
    return -1


def split_i18n_has(proxy: SplitI18nProxy, path: String) -> Bool:
    return split_i18n_node_index(proxy, path) >= 0


def split_i18n_node(proxy: SplitI18nProxy, path: String) raises -> I18nWordNode:
    var index = split_i18n_node_index(proxy, path)
    if index < 0:
        raise Error("unknown split i18n attribute: " + path)
    return proxy.catalog.nodes[index].copy()


def split_i18n_value(proxy: SplitI18nProxy, path: String) raises -> String:
    return split_i18n_node(proxy, path).value


def split_i18n_kind(proxy: SplitI18nProxy, path: String) raises -> String:
    return split_i18n_node(proxy, path).kind


def split_i18n_node_count(proxy: SplitI18nProxy) -> Int:
    var count = 0
    for index in range(len(proxy.catalog.nodes)):
        if _contains(proxy.source_modules, proxy.catalog.nodes[index].module):
            count += 1
    return count


def split_i18n_root_count(proxy: SplitI18nProxy) -> Int:
    var roots = List[String]()
    for index in range(len(proxy.catalog.nodes)):
        var node = proxy.catalog.nodes[index].copy()
        if not _contains(proxy.source_modules, node.module):
            continue
        var path = node.path
        var bracket = path.find("[")
        var dot = path.find(".")
        var end = path.byte_length()
        if bracket >= 0 and bracket < end:
            end = bracket
        if dot >= 0 and dot < end:
            end = dot
        var root = String(StringSlice(path)[byte=0:end])
        if not _contains(roots, root):
            roots.append(root)
    return len(roots)


def split_i18n_snapshot(proxy: SplitI18nProxy) -> SplitI18nSnapshot:
    var sources = List[String]()
    for index in range(len(proxy.source_modules)):
        sources.append(proxy.source_modules[index])
    return SplitI18nSnapshot(
        proxy.language,
        sources^,
        split_i18n_node_count(proxy),
        split_i18n_root_count(proxy),
    )
