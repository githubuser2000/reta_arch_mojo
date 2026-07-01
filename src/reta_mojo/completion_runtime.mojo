"""Typed native completion-runtime bundle.

This is the native owner for ``reta_architecture/completion_runtime.py``.
The Python module builds a large dynamic object graph from i18n dictionaries.
The Mojo port consumes the reproducibly generated multilingual completion
catalog instead.  The catalog preserves the Python ordering and values, while
this module provides owned sections, start commands, snapshots and stable
lookup semantics without Python objects or import-time caches.
"""

from std.collections import List
from .prompt_language import (
    PromptLanguageCatalog,
    load_prompt_language_catalog,
    normalize_prompt_language,
)


@fieldwise_init
struct CompletionRuntimeSnapshot(Copyable):
    var class_name: String
    var language: String
    var root_commands_len: Int
    var main_parameters_len: Int
    var completion_sections_len: Int
    var start_commands_with_numeric_shortcuts: List[String]
    var value_contexts: List[String]


struct CompletionRuntimeBundle(Copyable):
    """Owned native view of the generated completion runtime."""

    var catalog: PromptLanguageCatalog
    var language: String
    var root_commands: List[String]
    var main_parameters: List[String]
    var completion_sections_len: Int
    var value_contexts: List[String]

    def __init__(
        out self,
        catalog: PromptLanguageCatalog,
        language: String,
    ):
        self.catalog = catalog.copy()
        self.language = normalize_prompt_language(language)
        self.root_commands = completion_runtime_values(
            self.catalog, self.language, "root", "*"
        )
        self.main_parameters = completion_runtime_values(
            self.catalog, self.language, "main", "*"
        )
        self.completion_sections_len = completion_runtime_section_count(
            self.catalog, self.language
        )
        self.value_contexts = completion_runtime_value_contexts(
            self.catalog, self.language
        )

    def values(self, scope: String, context: String) -> List[String]:
        return completion_runtime_values(
            self.catalog, self.language, scope, context
        )

    def parameters(self, main_parameter: String) -> List[String]:
        return self.values("parameter", main_parameter)

    def value_options(
        self, main_parameter: String, parameter_name: String
    ) -> List[String]:
        return self.values(
            "value", main_parameter + "|" + parameter_name
        )

    def has_value_context(
        self, main_parameter: String, parameter_name: String
    ) -> Bool:
        return completion_runtime_has_section(
            self.catalog,
            self.language,
            "value",
            main_parameter + "|" + parameter_name,
        )

    def value_parameter_names(
        self, main_parameter: String
    ) -> List[String]:
        var result = List[String]()
        var prefix = main_parameter + "|"
        for index in range(len(self.value_contexts)):
            var context = self.value_contexts[index]
            if context.startswith(prefix):
                var name = String(
                    StringSlice(context)[byte=prefix.byte_length():]
                )
                if name != "*":
                    _append_unique_runtime(result, name^)
        return result^

    def start_commands(
        self, include_numeric_shortcuts: Bool = False
    ) -> List[String]:
        var result = self.root_commands.copy()
        if include_numeric_shortcuts:
            _append_unique_runtime(result, "15_")
            _append_unique_runtime(result, "16_")
        return result^

    def snapshot(self) -> CompletionRuntimeSnapshot:
        var first_commands = self.start_commands(True)
        var limited = List[String]()
        for index in range(min(10, len(first_commands))):
            limited.append(first_commands[index])
        return CompletionRuntimeSnapshot(
            "CompletionRuntimeBundle",
            self.language,
            len(self.root_commands),
            len(self.main_parameters),
            self.completion_sections_len,
            limited^,
            self.value_contexts.copy(),
        )


def _contains_runtime(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _append_unique_runtime(mut values: List[String], value: String) -> None:
    if not _contains_runtime(values, value):
        values.append(value)


def completion_runtime_values(
    catalog: PromptLanguageCatalog,
    language: String,
    scope: String,
    context: String,
) -> List[String]:
    """Return one deduplicated completion section in Python catalog order."""
    var result = List[String]()
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.completions)):
        var entry = catalog.completions[index].copy()
        if (
            entry.language == normalized
            and entry.scope == scope
            and entry.context == context
        ):
            for value_index in range(len(entry.values)):
                _append_unique_runtime(result, entry.values[value_index])
    return result^



def completion_runtime_has_section(
    catalog: PromptLanguageCatalog,
    language: String,
    scope: String,
    context: String,
) -> Bool:
    var normalized = normalize_prompt_language(language)
    for index in range(len(catalog.completions)):
        var entry = catalog.completions[index].copy()
        if (
            entry.language == normalized
            and entry.scope == scope
            and entry.context == context
        ):
            return True
    return False

def completion_runtime_section_count(
    catalog: PromptLanguageCatalog, language: String
) -> Int:
    var normalized = normalize_prompt_language(language)
    var count = 0
    for index in range(len(catalog.completions)):
        if catalog.completions[index].language == normalized:
            count += 1
    return count


def completion_runtime_value_contexts(
    catalog: PromptLanguageCatalog, language: String
) -> List[String]:
    var normalized = normalize_prompt_language(language)
    var result = List[String]()
    for index in range(len(catalog.completions)):
        var entry = catalog.completions[index].copy()
        if entry.language == normalized and entry.scope == "value":
            _append_unique_runtime(result, entry.context)
    return result^


def completion_runtime_order_index(
    runtime: CompletionRuntimeBundle, key: String
) -> Int:
    """Stable generated equivalent of Python's ``sort_completion_key``.

    The generator has already applied the Python ordering.  Returning the
    position in that order is both cheaper and less fragile than reconstructing
    the old i18n-dependent tuple cascade at runtime.
    """
    for index in range(len(runtime.root_commands)):
        if runtime.root_commands[index] == key:
            return index
    return len(runtime.root_commands)


def bootstrap_completion_runtime(
    asset_root: String,
    language: String = "deutsch",
) raises -> CompletionRuntimeBundle:
    return CompletionRuntimeBundle(
        load_prompt_language_catalog(asset_root), language
    )
