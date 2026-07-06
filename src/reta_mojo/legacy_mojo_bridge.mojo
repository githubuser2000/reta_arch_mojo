"""Typed native compatibility owner for historical ``mojo_bridge.py``.

The old module embedded CPython or imported Python merely to reach terminal and
child-process services.  These adapters now delegate to native Mojo owners.
Unsupported historical ``reta`` and prompt commands remain an explicit child
process boundary until their owning Python entry points are fully ported; no
Python interpreter is embedded in this module.
"""

from std.collections import List
from std.collections.string import StringSlice
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
    run_math_prompt_payload_native,
    run_python_prompt_payload_native,
    run_reta_arguments_native,
    run_reta_prompt_arguments_native,
    reta_child_arguments_native,
    run_reta_prompt_fallback_arguments_native,
    run_shell_prompt_payload_native,
    shell_split,
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




def _prompt_line_slice(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def _prompt_line_payload(line: String) -> String:
    """Match Python ``line.partition(" ")[2]`` for legacy facades."""
    var bytes = line.as_bytes()
    for index in range(len(bytes)):
        if Int(bytes[index]) == 32:
            return _prompt_line_slice(line, index + 1, len(bytes))
    return ""


def _split_encoded(encoded: String, separator: String) -> List[String]:
    var result = List[String]()
    for piece in encoded.split(separator):
        result.append(String(piece))
    return result^


def run_reta(arguments: List[String]) raises -> Int:
    return run_reta_arguments_native(
        reta_child_arguments_native(arguments), reference_root()
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
    return run_shell_prompt_payload_native(line, reference_root())


def run_python_code(code: String) raises -> Int:
    return run_python_prompt_payload_native(code, reference_root())


def run_math_expression(expression: String) raises -> Int:
    return run_math_prompt_payload_native(expression, reference_root())


def run_reta_line(line: String) raises -> Int:
    return run_reta_arguments_native(
        reta_child_arguments_native(shell_split(line)), reference_root()
    )


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
    return run_reta_prompt_fallback_arguments_native(
        flags, shell_split(raw_line), reference_root()
    )


def run_shell_prompt_line(line: String) raises -> Int:
    return run_shell_prompt_payload_native(
        _prompt_line_payload(line), reference_root()
    )


def run_python_prompt_line(line: String) raises -> Int:
    return run_python_prompt_payload_native(
        _prompt_line_payload(line), reference_root()
    )


def run_math_prompt_line(line: String) raises -> Int:
    return run_math_prompt_payload_native(
        _prompt_line_payload(line), reference_root()
    )


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
        "reta_line_bridge=native-argv-owner",
        "prompt_line_bridge=payload-owner",
        "external_line_wrappers=removed-payload-argv-only",
        "fallback_bridge=native-argv-owner",
        "external_raw_payload_helper=legacy-local",
        "reta_child_arguments=shared-native-argv-owner",
    ]
