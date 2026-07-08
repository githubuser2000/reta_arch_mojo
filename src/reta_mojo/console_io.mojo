"""Complete typed owner for ``reta_architecture.console_io``.

The Python owner combines pure finite-section helpers, console effect planning,
help-file loading, terminal discovery and an ``OrderedDict`` subclass with a
default factory.  Mojo keeps effects explicit: text-producing operations return
owned strings, printing methods perform the effect, and the dynamic ordered
mapping becomes an insertion-ordered string-to-string-list value.
"""

from std.collections import List, Set
from .resource_paths import asset_resource, runtime_root
from .terminal_geometry import terminal_columns
from .os_line_endings import drop_one_trailing_line_ending


@fieldwise_init
struct ConsoleContext(Copyable, Equatable):
    var shell_width: Int
    var output_enabled: Bool
    var info_log: Bool


@fieldwise_init
struct ConsoleTextWrapRuntime(Copyable, Equatable):
    var shell_width: Int
    var has_hyphenator: Bool
    var has_dictionary: Bool
    var has_fill: Bool


@fieldwise_init
struct DefaultOrderedDictSnapshot(Copyable, Equatable):
    var class_name: String
    var default_factory_name: String
    var keys: List[String]
    var values: List[List[String]]


@fieldwise_init
struct DefaultOrderedDict(Copyable):
    """Typed ordered default mapping used by the historical center facade.

    The production callers use list-valued sections.  Keeping keys and values
    in parallel owned lists preserves insertion order independently of the
    implementation details of ``Dict``/``Set``.
    """

    var default_factory_name: String
    var keys: List[String]
    var values: List[List[String]]

    def _index_of(self, key: String) -> Int:
        for index in range(len(self.keys)):
            if self.keys[index] == key:
                return index
        return -1

    def contains(self, key: String) -> Bool:
        return self._index_of(key) >= 0

    def set(mut self, key: String, value: List[String]):
        var index = self._index_of(key)
        if index >= 0:
            self.values[index] = value.copy()
            return
        self.keys.append(key)
        self.values.append(value.copy())

    def get(self, key: String) raises -> List[String]:
        var index = self._index_of(key)
        if index < 0:
            raise Error("ordered default dictionary key not found: " + key)
        return self.values[index].copy()

    def get_or_default(mut self, key: String) raises -> List[String]:
        var index = self._index_of(key)
        if index >= 0:
            return self.values[index].copy()
        if self.default_factory_name.byte_length() == 0:
            raise Error("ordered default dictionary has no default factory")
        var value = List[String]()
        self.keys.append(key)
        self.values.append(value.copy())
        return value^

    def snapshot(self) -> DefaultOrderedDictSnapshot:
        var copied_values = List[List[String]]()
        for index in range(len(self.values)):
            copied_values.append(self.values[index].copy())
        return DefaultOrderedDictSnapshot(
            "DefaultOrderedDict",
            self.default_factory_name,
            self.keys.copy(),
            copied_values^,
        )


@fieldwise_init
struct ConsoleIOMorphismSnapshot(Copyable):
    var class_name: String
    var stage: Int
    var legacy_owner: String
    var capsule: String
    var secondary_capsule: String
    var category: String
    var functor: String
    var natural_transformation: String
    var repo_root: String
    var morphisms: List[String]
    var compatibility_names: List[String]
    var observable_invariant: String


@fieldwise_init
struct ConsoleIOMorphismBundle(Copyable):
    var repo_root: String
    var legacy_owner: String
    var activated_stage: Int

    def chunks(
        self, values: List[String], size: Int
    ) raises -> List[List[String]]:
        return chunks_strings(values, size)

    def unique_everseen(self, values: List[String]) -> List[String]:
        return unique_everseen_strings(values)

    def cliout(
        self,
        text: String,
        color: Bool = False,
        stype: String = "",
        output_enabled: Bool = True,
    ) -> String:
        _ = stype
        return cli_output_text(text, color, output_enabled)

    def debug_pair(
        self,
        label: String,
        value: String,
        info_log: Bool,
        output_enabled: Bool = True,
    ) -> String:
        return debug_pair_output(label, value, info_log, output_enabled)

    def debug_value(
        self,
        value: String,
        info_log: Bool,
        output_enabled: Bool = True,
    ) -> String:
        return debug_value_output(value, info_log, output_enabled)

    def reta_prompt_help_text(
        self, language: String = "german"
    ) raises -> String:
        return reta_prompt_help_text(language)

    def print_reta_prompt_help(
        self, language: String = "german"
    ) raises:
        print(self.reta_prompt_help_text(language), end="")

    def reta_help_text(self, language: String = "german") raises -> String:
        return reta_help_text(language)

    def print_reta_help(self, language: String = "german") raises:
        print(self.reta_help_text(language), end="")

    def text_wrap_runtime(
        self, max_len: Int = 0
    ) -> ConsoleTextWrapRuntime:
        return get_text_wrap_things(max_len)

    def default_ordered_dict_type(self) -> String:
        return "DefaultOrderedDict"

    def snapshot(self) -> ConsoleIOMorphismSnapshot:
        return ConsoleIOMorphismSnapshot(
            "ConsoleIOMorphismBundle",
            self.activated_stage,
            self.legacy_owner,
            "OutputRenderingCapsule",
            "InputPromptCapsule",
            "ActivatedConsoleIOCategory",
            "ConsoleIOActivationFunctor",
            "CenterConsoleIOToArchitectureTransformation",
            self.repo_root,
            [
                "reta_prompt_help_text",
                "print_reta_prompt_help",
                "reta_help_text",
                "print_reta_help",
                "get_text_wrap_things",
                "cli_output",
                "debug_pair",
                "debug_value",
                "chunks",
                "unique_everseen",
                "DefaultOrderedDict",
            ],
            [
                "retaPromptHilfe",
                "retaHilfe",
                "getTextWrapThings",
                "cliout",
                "x",
                "alxp",
                "chunks",
                "unique_everseen",
                "DefaultOrderedDict",
            ],
            "center console/help/utility wrappers and ConsoleIOMorphismBundle expose the same visible output and finite-section helper results",
        )


def default_console_context() -> ConsoleContext:
    return ConsoleContext(80, True, False)


def default_ordered_dict(
    default_factory_name: String = "list"
) -> DefaultOrderedDict:
    return DefaultOrderedDict(
        default_factory_name, List[String](), List[List[String]]()
    )


def chunks_strings(values: List[String], size: Int) raises -> List[List[String]]:
    if size <= 0:
        raise Error("chunk size must be positive")
    var result = List[List[String]]()
    var index = 0
    while index < len(values):
        var chunk = List[String]()
        var end = min(index + size, len(values))
        while index < end:
            chunk.append(values[index])
            index += 1
        result.append(chunk^)
    return result^


def unique_everseen_strings(values: List[String]) -> List[String]:
    var seen = Set[String]()
    var result = List[String]()
    for index in range(len(values)):
        var value = values[index]
        if value not in seen:
            seen.add(value)
            result.append(value)
    return result^


def unique_everseen_ascii_lower(values: List[String]) -> List[String]:
    """Typed counterpart for ``unique_everseen(..., key=str.lower)``."""
    var seen = Set[String]()
    var result = List[String]()
    for index in range(len(values)):
        var marker = String(values[index].lower())
        if marker not in seen:
            seen.add(marker)
            result.append(values[index])
    return result^


def normalize_colored_cli_text(text: String) -> String:
    """Mirror ``' '.join(text.split())`` used by colored ``cli_output``."""
    var words = text.split()
    var result = String()
    for index in range(len(words)):
        if index > 0:
            result += " "
        result += String(words[index])
    return result^


def cli_output_text(
    text: String,
    color: Bool = False,
    output_enabled: Bool = True,
) -> String:
    if not output_enabled:
        return String()
    if color and text.byte_length() > 0:
        return normalize_colored_cli_text(text)
    return text


def cli_output(
    text: String,
    color: Bool = False,
    stype: String = "",
    output_enabled: Bool = True,
):
    _ = stype
    var payload = cli_output_text(text, color, output_enabled)
    if payload.byte_length() == 0 and not output_enabled:
        return
    # Colored Rich/Syntax rendering normalizes whitespace and writes no extra
    # newline.  Plain Python ``print`` appends one.
    if color and text.byte_length() > 0:
        print(payload, end="")
    else:
        print(payload)


def debug_pair_text(label: String, value: String) -> String:
    return label + ": " + value


def debug_pair_output(
    label: String,
    value: String,
    info_log: Bool,
    output_enabled: Bool = True,
) -> String:
    if not (info_log and output_enabled):
        return String()
    return debug_pair_text(label, value)


def debug_pair(
    label: String,
    value: String,
    info_log: Bool,
    output_enabled: Bool = True,
):
    var payload = debug_pair_output(label, value, info_log, output_enabled)
    if payload.byte_length() > 0:
        print(payload)


def debug_value_output(
    value: String,
    info_log: Bool,
    output_enabled: Bool = True,
) -> String:
    if not (info_log and output_enabled):
        return String()
    return value


def debug_value(
    value: String,
    info_log: Bool,
    output_enabled: Bool = True,
):
    var payload = debug_value_output(value, info_log, output_enabled)
    if payload.byte_length() > 0:
        print(payload)


def should_emit(context: ConsoleContext) -> Bool:
    return context.output_enabled


def should_emit_debug(context: ConsoleContext) -> Bool:
    return context.output_enabled and context.info_log


def _basename(path: String) -> String:
    var parts = path.split("/")
    if len(parts) == 0:
        return path
    return String(parts[len(parts) - 1])


def _doc_path(repo_root: String, readme_filename: String) -> String:
    var root = String(repo_root.strip())
    var filename = _basename(readme_filename)
    if root.byte_length() == 0:
        return "doc/" + filename
    if root.endswith("/"):
        return root + "doc/" + filename
    return root + "/doc/" + filename


def _drop_one_trailing_newline(text: String) -> String:
    return drop_one_trailing_line_ending(text)


def _read_help_asset(filename: String) raises -> String:
    var file = open(asset_resource(filename), "r")
    var payload = file.read()
    file.close()
    return payload^


def reta_prompt_help_text(language: String = "german") raises -> String:
    return _read_help_asset(
        "reta_prompt_help_en.txt"
        if language == "english"
        else "reta_prompt_help_de.txt"
    )


def print_reta_prompt_help(language: String = "german") raises:
    print(reta_prompt_help_text(language), end="")


def reta_help_text(language: String = "german") raises -> String:
    var payload = _read_help_asset(
        "reta_help_en.txt" if language == "english" else "reta_help_de.txt"
    )
    # The startup asset intentionally contains the extra newline printed by
    # ``reta.py -h``.  ``console_io.reta_help_text`` returns only the Markdown
    # file body, so remove exactly that generated trailing newline here.
    return _drop_one_trailing_newline(payload)


def print_reta_help(language: String = "german") raises:
    print(reta_help_text(language), end="")


def get_text_wrap_things(max_len: Int = 0) -> ConsoleTextWrapRuntime:
    var shell_width = max_len if max_len > 0 else terminal_columns()
    # Native hard wrapping and Unicode codepoint splitting are always present.
    # Optional Python pyphen objects are represented as explicit capabilities.
    return ConsoleTextWrapRuntime(shell_width, False, False, True)


def bootstrap_console_io_morphisms(
    repo_root: String = "",
    legacy_owner: String = "libs.center",
    activated_stage: Int = 39,
) -> ConsoleIOMorphismBundle:
    var resolved_root = repo_root
    if resolved_root.byte_length() == 0:
        resolved_root = runtime_root()
    if resolved_root.byte_length() == 0:
        resolved_root = "."
    return ConsoleIOMorphismBundle(
        resolved_root^, legacy_owner, activated_stage
    )
