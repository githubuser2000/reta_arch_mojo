"""Typed native owner for ``reta_architecture.presheaves``.

Python accepts arbitrary ``object`` payloads and discovers the repository with
``pathlib.glob``.  The native implementation keeps payloads as canonical JSON
text, owns the exact local-section topology and consumes a reproducibly
generated portable catalog.  No Python object, import or child process is needed
at runtime.
"""

from std.collections import List
from std.collections.string import atol
from .csv_table import read_text_file
from .resource_paths import asset_resource, reference_root
from .os_line_endings import split_os_lines
from .topology import (
    ContextSelection,
    SelectionDimension,
    refine_selection,
    restricted_dimension,
    selection_is_empty,
    unrestricted_selection,
)


@fieldwise_init
struct LocalSection(Copyable):
    var context: ContextSelection
    var payload: String
    var source: String

    def as_dict(self) -> String:
        return local_section_json(self)


# Historical native name retained for source compatibility with earlier stages.
@fieldwise_init
struct LocalStringSection(Copyable):
    var context: ContextSelection
    var payload: String
    var source: String


@fieldwise_init
struct PresheafCatalogEntry(Copyable):
    var kind: String
    var ordinal: Int
    var relative_path: String
    var suffix: String
    var name: String
    var language: String
    var scope: String


@fieldwise_init
struct PresheafCatalog(Copyable):
    var entries: List[PresheafCatalogEntry]


@fieldwise_init
struct PresheafSnapshot(Copyable):
    var name: String
    var section_count: Int
    var sources: List[String]


@fieldwise_init
struct PresheafBundleSnapshot(Copyable):
    var csv_sections: Int
    var translation_sections: Int
    var asset_sections: Int
    var prompt_sections: Int


def _join_presheaf_path(root: String, relative: String) -> String:
    if root.byte_length() == 0:
        return relative.copy()
    if relative.byte_length() == 0:
        return root.copy()
    if root.endswith("/"):
        return root + relative
    return root + "/" + relative


def _json_escape_presheaf(text: String) -> String:
    var escaped = text.replace("\\", "\\\\")
    escaped = escaped.replace("\"", "\\\"")
    escaped = escaped.replace("\r", "\\r")
    escaped = escaped.replace("\n", "\\n")
    escaped = escaped.replace("\t", "\\t")
    return escaped^


def _dimension_json(dimension: SelectionDimension) -> String:
    if not dimension.restricted:
        return "null"
    var values = List[String]()
    for value in dimension.values:
        values.append(value.copy())
    # The ContextSelection dimensions are sets. Snapshot order is therefore
    # canonicalized locally instead of depending on hash iteration order.
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key^
    var result = String("[")
    for index in range(len(values)):
        if index > 0:
            result += ","
        result += "\"" + _json_escape_presheaf(values[index]) + "\""
    result += "]"
    return result^


def context_selection_json(context: ContextSelection) -> String:
    return (
        "{\"language\":" + _dimension_json(context.language)
        + ",\"main_parameters\":" + _dimension_json(context.main_parameters)
        + ",\"sub_parameters\":" + _dimension_json(context.sub_parameters)
        + ",\"row_parameters\":" + _dimension_json(context.row_parameters)
        + ",\"output_modes\":" + _dimension_json(context.output_modes)
        + ",\"tag_names\":" + _dimension_json(context.tag_names)
        + ",\"combination_parameters\":" + _dimension_json(context.combination_parameters)
        + ",\"scopes\":" + _dimension_json(context.scopes)
        + "}"
    )


def local_section_json(section: LocalSection) -> String:
    return (
        "{\"context\":" + context_selection_json(section.context)
        + ",\"payload\":" + section.payload
        + ",\"source\":\"" + _json_escape_presheaf(section.source) + "\"}"
    )


def _copy_local_sections(values: List[LocalSection]) -> List[LocalSection]:
    var result = List[LocalSection]()
    for index in range(len(values)):
        result.append(values[index].copy())
    return result^


def _presheaf_sources(values: List[LocalSection]) -> List[String]:
    var result = List[String]()
    for index in range(len(values)):
        result.append(values[index].source.copy())
    return result^


struct Presheaf(Copyable):
    var name: String
    var _sections: List[LocalSection]

    def __init__(out self, name: String):
        self.name = name
        self._sections = List[LocalSection]()

    def add_section(
        mut self,
        context: ContextSelection,
        payload: String,
        source: String = "",
    ) -> None:
        self._sections.append(
            LocalSection(context.copy(), payload.copy(), source.copy())
        )

    def restrict(self, context: ContextSelection) -> List[LocalSection]:
        var result = List[LocalSection]()
        for index in range(len(self._sections)):
            var section = self._sections[index].copy()
            var refined = refine_selection(section.context, context)
            if not selection_is_empty(refined):
                result.append(
                    LocalSection(
                        refined^,
                        section.payload.copy(),
                        section.source.copy(),
                    )
                )
        return result^

    def sections(self) -> List[LocalSection]:
        return _copy_local_sections(self._sections)

    def snapshot(self) -> PresheafSnapshot:
        return PresheafSnapshot(
            self.name.copy(),
            len(self._sections),
            _presheaf_sources(self._sections),
        )

    def snapshot_json(self) -> String:
        var result = String("[")
        for index in range(len(self._sections)):
            if index > 0:
                result += ","
            result += local_section_json(self._sections[index])
        result += "]"
        return result^


# Compatibility facade used by the earlier native tests. It delegates to the
# same semantics but preserves the historical LocalStringSection return type.
struct StringPresheaf(Copyable):
    var name: String
    var _sections: List[LocalStringSection]

    def __init__(out self, name: String):
        self.name = name
        self._sections = List[LocalStringSection]()

    def add_section(
        mut self,
        context: ContextSelection,
        payload: String,
        source: String = "",
    ) -> None:
        self._sections.append(
            LocalStringSection(
                context.copy(), payload.copy(), source.copy()
            )
        )

    def sections(self) -> List[LocalStringSection]:
        var result = List[LocalStringSection]()
        for index in range(len(self._sections)):
            result.append(self._sections[index].copy())
        return result^

    def restrict(
        self, context: ContextSelection
    ) -> List[LocalStringSection]:
        var result = List[LocalStringSection]()
        for index in range(len(self._sections)):
            var refined = refine_selection(
                self._sections[index].context, context
            )
            if not selection_is_empty(refined):
                result.append(
                    LocalStringSection(
                        refined^,
                        self._sections[index].payload.copy(),
                        self._sections[index].source.copy(),
                    )
                )
        return result^


struct FilesystemPresheaf(Copyable):
    var name: String
    var root: String
    var presheaf: Presheaf

    def __init__(out self, name: String, root: String):
        self.name = name.copy()
        self.root = root
        self.presheaf = Presheaf(name)

    def discover(
        mut self,
        catalog: PresheafCatalog,
        kind: String,
    ) -> None:
        for index in range(len(catalog.entries)):
            var entry = catalog.entries[index].copy()
            if entry.kind != kind:
                continue
            var context = unrestricted_selection()
            if entry.language.byte_length() > 0:
                context.language = restricted_dimension([entry.language.copy()])
            context.scopes = restricted_dimension([entry.scope.copy()])
            self.presheaf.add_section(
                context,
                filesystem_payload_json(entry),
                _join_presheaf_path(self.root, entry.relative_path),
            )

    def add_section(
        mut self,
        context: ContextSelection,
        payload: String,
        source: String = "",
    ) -> None:
        self.presheaf.add_section(context, payload, source)

    def restrict(self, context: ContextSelection) -> List[LocalSection]:
        return self.presheaf.restrict(context)

    def sections(self) -> List[LocalSection]:
        return self.presheaf.sections()

    def snapshot(self) -> PresheafSnapshot:
        return self.presheaf.snapshot()

    def snapshot_json(self) -> String:
        return self.presheaf.snapshot_json()


struct PromptStatePresheaf(Copyable):
    var name: String
    var raw_text: String
    var tokenized_text: List[String]
    var presheaf: Presheaf

    def __init__(out self):
        self.name = "prompt_state"
        self.raw_text = ""
        self.tokenized_text = List[String]()
        self.presheaf = Presheaf("prompt_state")

    def update(
        mut self,
        raw_text: String,
        tokens: List[String],
        context: ContextSelection,
    ) -> None:
        self.raw_text = raw_text.copy()
        self.tokenized_text = tokens.copy()
        self.presheaf = Presheaf("prompt_state")
        self.presheaf.add_section(
            context,
            prompt_payload_json(self.raw_text, self.tokenized_text),
            "prompt",
        )

    def update_default(
        mut self, raw_text: String, tokens: List[String]
    ) -> None:
        var context = unrestricted_selection()
        context.scopes = restricted_dimension(["prompt"])
        self.update(raw_text, tokens, context)

    def restrict(self, context: ContextSelection) -> List[LocalSection]:
        return self.presheaf.restrict(context)

    def sections(self) -> List[LocalSection]:
        return self.presheaf.sections()

    def snapshot(self) -> PresheafSnapshot:
        return self.presheaf.snapshot()

    def snapshot_json(self) -> String:
        return self.presheaf.snapshot_json()


@fieldwise_init
struct PresheafBundle(Copyable):
    var csv: FilesystemPresheaf
    var translations: FilesystemPresheaf
    var assets: FilesystemPresheaf
    var prompt_state: PromptStatePresheaf

    @staticmethod
    def discover(
        repo_root: String = "",
        catalog_path: String = "",
    ) raises -> Self:
        return discover_presheaf_bundle(repo_root, catalog_path)

    def snapshot(self) -> PresheafBundleSnapshot:
        return PresheafBundleSnapshot(
            len(self.csv.sections()),
            len(self.translations.sections()),
            len(self.assets.sections()),
            len(self.prompt_state.sections()),
        )

    def snapshot_json(self) -> String:
        return (
            "{\"csv\":" + self.csv.snapshot_json()
            + ",\"translations\":" + self.translations.snapshot_json()
            + ",\"assets\":" + self.assets.snapshot_json()
            + ",\"prompt_state\":" + self.prompt_state.snapshot_json()
            + "}"
        )


def filesystem_payload_json(entry: PresheafCatalogEntry) -> String:
    return (
        "{\"path\":\"" + _json_escape_presheaf(entry.relative_path)
        + "\",\"suffix\":\"" + _json_escape_presheaf(entry.suffix)
        + "\",\"name\":\"" + _json_escape_presheaf(entry.name)
        + "\"}"
    )


def prompt_payload_json(raw_text: String, tokens: List[String]) -> String:
    var result = String(
        "{\"raw_text\":\"" + _json_escape_presheaf(raw_text)
        + "\",\"tokens\":["
    )
    for index in range(len(tokens)):
        if index > 0:
            result += ","
        result += "\"" + _json_escape_presheaf(tokens[index]) + "\""
    result += "]}"
    return result^


def load_presheaf_catalog(
    path: String = "",
) raises -> PresheafCatalog:
    var source_path = (
        path
        if path.byte_length() > 0
        else asset_resource("presheaf_catalog.tsv")
    )
    var entries = List[PresheafCatalogEntry]()
    var lines = split_os_lines(read_text_file(source_path))
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0 or line.startswith("#"):
            continue
        var fields = line.split("\t")
        if len(fields) != 7:
            raise Error(
                "invalid presheaf catalog row " + String(line_index + 1)
            )
        entries.append(
            PresheafCatalogEntry(
                String(fields[0]),
                atol(String(fields[1])),
                String(fields[2]),
                String(fields[3]),
                String(fields[4]),
                String(fields[5]),
                String(fields[6]),
            )
        )
    return PresheafCatalog(entries^)


def presheaf_catalog_count(
    catalog: PresheafCatalog, kind: String
) -> Int:
    var count = 0
    for index in range(len(catalog.entries)):
        if catalog.entries[index].kind == kind:
            count += 1
    return count


def discover_presheaf_bundle(
    repo_root: String = "",
    catalog_path: String = "",
) raises -> PresheafBundle:
    var root = repo_root
    if root.byte_length() == 0:
        root = reference_root()
    var catalog = load_presheaf_catalog(catalog_path)
    var csv = FilesystemPresheaf("csv", root.copy())
    var translations = FilesystemPresheaf("translations", root.copy())
    var assets = FilesystemPresheaf("assets", root)
    csv.discover(catalog, "csv")
    translations.discover(catalog, "translations")
    assets.discover(catalog, "assets")
    return PresheafBundle(
        csv^,
        translations^,
        assets^,
        PromptStatePresheaf(),
    )
