"""Typed native compatibility owner for historical ``mojo_bridge.py``.

The old module embedded CPython or imported Python merely to reach terminal and
child-process services.  These adapters now delegate to native Mojo owners.
Unsupported historical ``reta`` and prompt commands remain an explicit child
process boundary until their owning Python entry points are fully ported; no
Python interpreter is embedded in this module.
"""

from std.collections import List
from .completion_nested import nested_completion_candidates_from_catalog
from .html_document import assemble_html_document, write_html_document_stdout
from .legacy_mojo_bridge_catalog import (
    legacy_mojo_bridge_function_count,
    legacy_mojo_bridge_function_names,
    legacy_mojo_bridge_public_count,
    legacy_mojo_bridge_public_names,
)
from .native_prompt_input import read_native_prompt_line
from .prompt_external_commands import (
    run_math_prompt_line_native,
    run_python_prompt_line_native,
    run_reta_arguments_native,
    run_reta_line_native,
    run_reta_prompt_arguments_native,
    run_reta_prompt_fallback_native,
    run_shell_prompt_line_native,
)
from .prompt_language import load_prompt_language_catalog
from .resource_paths import asset_root, reference_root


@fieldwise_init
struct NativePromptReadlineConfiguration(Copyable):
    var vi_mode: Bool
    var history_file: String
    var language: String
    var completion_words: List[String]
    var native_editor: Bool


@fieldwise_init
struct LegacyMojoBridgeSnapshot(Copyable, Equatable):
    var public_names: Int
    var functions: Int
    var embedded_python: Bool
    var native_prompt_input: Bool
    var native_html_pipeline: Bool
    var explicit_child_boundary: Bool


@fieldwise_init
struct LegacyMojoBridgeBundle(Copyable):
    var reference_directory: String

    def snapshot(self) -> LegacyMojoBridgeSnapshot:
        return LegacyMojoBridgeSnapshot(
            legacy_mojo_bridge_public_count(),
            legacy_mojo_bridge_function_count(),
            False,
            True,
            True,
            True,
        )


def bootstrap_legacy_mojo_bridge() -> LegacyMojoBridgeBundle:
    return LegacyMojoBridgeBundle(reference_root())


def _split_encoded(encoded: String, separator: String) -> List[String]:
    var result = List[String]()
    for piece in encoded.split(separator):
        result.append(String(piece))
    return result^


def _reta_child_arguments(arguments: List[String]) -> List[String]:
    var result = List[String]()
    var start = 0
    if len(arguments) > 0 and (
        arguments[0] == "reta"
        or arguments[0] == "reta.py"
        or arguments[0].endswith("/reta.py")
    ):
        start = 1
    for index in range(start, len(arguments)):
        result.append(arguments[index])
    return result^


def run_reta(arguments: List[String]) raises -> Int:
    return run_reta_arguments_native(
        _reta_child_arguments(arguments), reference_root()
    )


def run_reta_encoded(encoded: String) raises -> Int:
    return run_reta(_split_encoded(encoded, "\x1f"))


def run_reta_subprocess_encoded(encoded: String) raises -> Int:
    return run_reta_encoded(encoded)


def _close_prompt_completion_process():
    # Completion is in-process Mojo state now; no worker lifecycle remains.
    pass


def _prompt_completion_process(language: String) -> Bool:
    _ = language
    return False


def _native_prompt_completion(
    line: String,
    language: String,
) raises -> List[String]:
    var catalog = load_prompt_language_catalog(asset_root())
    return nested_completion_candidates_from_catalog(catalog, language, line)


def _configure_prompt_readline(
    vi_mode: Bool,
    history_file: String,
    language: String,
    completion_words: List[String],
) -> NativePromptReadlineConfiguration:
    return NativePromptReadlineConfiguration(
        vi_mode,
        history_file,
        language,
        completion_words.copy(),
        True,
    )


def read_prompt_line_encoded(encoded: String) raises -> String:
    var fields = _split_encoded(encoded, "\x1f")
    var prompt = String("> ")
    var history_enabled = False
    var vi_mode = False
    var history_file = String("~/.ReTaPromptHistory")
    var language = String("deutsch")
    if len(fields) > 0:
        prompt = fields[0]
    if len(fields) > 1:
        history_enabled = fields[1] == "1"
    if len(fields) > 2:
        vi_mode = fields[2] == "1"
    if len(fields) > 3:
        history_file = fields[3]
    if len(fields) > 4:
        language = fields[4]
    var catalog = load_prompt_language_catalog(asset_root())
    return read_native_prompt_line(
        prompt,
        catalog,
        language,
        vi_mode,
        history_enabled,
        history_file,
    )


def run_reta_prompt_subprocess_encoded(encoded: String) raises -> Int:
    var arguments = List[String]()
    if encoded.byte_length() > 0:
        arguments = _split_encoded(encoded, "\x1f")
    return run_reta_prompt_arguments_native(arguments, reference_root())


def run_shell_line(line: String) raises -> Int:
    return run_shell_prompt_line_native("shell " + line, reference_root())


def run_python_code(code: String) raises -> Int:
    return run_python_prompt_line_native("python " + code, reference_root())


def run_math_expression(expression: String) raises -> Int:
    return run_math_prompt_line_native("math " + expression, reference_root())


def run_reta_line(line: String) raises -> Int:
    return run_reta_line_native(line, reference_root())


def run_reta_prompt_line_encoded(encoded: String) raises -> Int:
    var pieces = _split_encoded(encoded, "\x1e")
    var flags = List[String]()
    if len(pieces) > 0 and pieces[0].byte_length() > 0:
        for flag in pieces[0].split("\x1f"):
            var value = String(flag)
            if value.byte_length() > 0:
                flags.append(value^)
    var raw_line = String()
    if len(pieces) > 1:
        raw_line = pieces[1]
    return run_reta_prompt_fallback_native(
        flags, raw_line, reference_root()
    )


def run_shell_prompt_line(line: String) raises -> Int:
    return run_shell_prompt_line_native(line, reference_root())


def run_python_prompt_line(line: String) raises -> Int:
    return run_python_prompt_line_native(line, reference_root())


def run_math_prompt_line(line: String) raises -> Int:
    return run_math_prompt_line_native(line, reference_root())


def generate_html_document(
    native_hierarchy_html: String,
    language: String = "",
) raises -> Int:
    write_html_document_stdout(
        assemble_html_document(native_hierarchy_html, language)
    )
    return 0


def legacy_mojo_bridge_owner_snapshot() -> List[String]:
    return [
        "module=mojo_bridge.py",
        "public_names=" + String(legacy_mojo_bridge_public_count()),
        "functions=" + String(legacy_mojo_bridge_function_count()),
        "prompt_input=native_prompt_input.mojo",
        "completion=completion_nested.mojo",
        "child_process=prompt_external_commands.mojo",
        "html=html_document.mojo",
        "embedded_python=none",
        "compatibility_child=reta.py+retaPrompt.py-only",
    ]
