"""Native source-tree integrity manifest for reta.

This module preserves the observable contract of
``reta_architecture.package_integrity`` without importing Python.  It scans a
POSIX source tree, follows file symlinks without descending through directory
symlinks, ignores runtime artifacts for hashing, computes binary SHA-256 file
hashes, verifies required paths and counts CSV lines with Python-compatible
``str.splitlines`` separators.
"""

from std.collections import List
from std.collections.string import StringSlice
from std.ffi import CStringSlice, c_int, c_long, c_size_t, external_call
from std.memory import Span, UnsafePointer, stack_allocation


@fieldwise_init
struct CsvLineCount(Copyable):
    var path: String
    var line_count: Int


@fieldwise_init
struct RepoManifest(Copyable):
    var root: String
    var file_count: Int
    var total_bytes: Int
    var digest: String
    var files: List[String]
    var missing_required: List[String]
    var runtime_artifact_count: Int
    var csv_line_counts: List[CsvLineCount]
    var suspicious_csvs: List[String]


def required_source_paths() -> List[String]:
    var result = List[String]()
    result.append("reta.py")
    result.append("retaPrompt.py")
    result.append("reta_architecture/__init__.py")
    result.append("reta_architecture/facade.py")
    result.append("reta_architecture/topology.py")
    result.append("reta_architecture/presheaves.py")
    result.append("reta_architecture/sheaves.py")
    result.append("reta_architecture/morphisms.py")
    result.append("reta_architecture/universal.py")
    result.append("reta_architecture/category_theory.py")
    result.append("reta_architecture/architecture_map.py")
    result.append("reta_architecture/architecture_contracts.py")
    result.append("reta_architecture/architecture_witnesses.py")
    result.append("reta_architecture/architecture_validation.py")
    result.append("reta_architecture/architecture_coherence.py")
    result.append("reta_architecture/architecture_traces.py")
    result.append("reta_architecture/architecture_boundaries.py")
    result.append("reta_architecture/architecture_impact.py")
    result.append("reta_architecture/architecture_migration.py")
    result.append("reta_architecture/architecture_rehearsal.py")
    result.append("reta_architecture/architecture_activation.py")
    result.append("reta_architecture/architecture_progress.py")
    result.append("reta_architecture/parallel_execution.py")
    result.append("reta_architecture/execution_network.py")
    result.append("reta_architecture/persistence.py")
    result.append("reta_architecture/schema.py")
    result.append("reta_architecture/tag_schema.py")
    result.append("reta_architecture/semantics_builder.py")
    result.append("reta_architecture/input_semantics.py")
    result.append("reta_architecture/row_ranges.py")
    result.append("reta_architecture/arithmetic.py")
    result.append("reta_architecture/console_io.py")
    result.append("reta_architecture/completion_word.py")
    result.append("reta_architecture/completion_nested.py")
    result.append("reta_architecture/column_selection.py")
    result.append("reta_architecture/parameter_runtime.py")
    result.append("reta_architecture/program_workflow.py")
    result.append("reta_architecture/output_syntax.py")
    result.append("reta_architecture/output_semantics.py")
    result.append("reta_architecture/table_generation.py")
    result.append("reta_architecture/table_preparation.py")
    result.append("reta_architecture/row_filtering.py")
    result.append("reta_architecture/table_wrapping.py")
    result.append("reta_architecture/table_state.py")
    result.append("reta_architecture/number_theory.py")
    result.append("reta_architecture/table_output.py")
    result.append("reta_architecture/table_runtime.py")
    result.append("reta_architecture/generated_columns.py")
    result.append("reta_architecture/meta_columns.py")
    result.append("reta_architecture/concat_csv.py")
    result.append("reta_architecture/combi_join.py")
    result.append("reta_architecture/prompt_runtime.py")
    result.append("reta_architecture/completion_runtime.py")
    result.append("reta_architecture/prompt_language.py")
    result.append("reta_architecture/prompt_session.py")
    result.append("reta_architecture/prompt_execution.py")
    result.append("reta_architecture/prompt_preparation.py")
    result.append("reta_architecture/prompt_interaction.py")
    result.append("i18n/words.py")
    result.append("i18n/words_context.py")
    result.append("i18n/words_matrix.py")
    result.append("i18n/words_runtime.py")
    result.append("libs/center.py")
    result.append("libs/LibRetaPrompt.py")
    result.append("libs/nestedAlx.py")
    result.append("libs/word_completerAlx.py")
    result.append("libs/tableHandling.py")
    result.append("libs/lib4tables.py")
    result.append("libs/lib4tables_concat.py")
    result.append("libs/lib4tables_prepare.py")
    result.append("csv/religion.csv")
    result.append("csv/vn-religion.csv")
    result.append("tests/test_architecture_refactor.py")
    result.append("tests/test_command_parity.py")
    return result^


def _slice(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def normalise_manifest_path(path: String) -> String:
    var normalized = path.replace("\\", "/")
    var data = normalized.as_bytes()
    var cursor = 0
    while cursor < len(data) and (
        Int(data[cursor]) == 46 or Int(data[cursor]) == 47
    ):
        cursor += 1
    return _slice(normalized, cursor, len(data))


def is_runtime_artifact(path: String) -> Bool:
    var normalized = path.replace("\\", "/")
    var parts = normalized.split("/")
    for index in range(len(parts)):
        var part = String(parts[index])
        if (
            part == "__pycache__"
            or part == ".git"
            or part == ".pytest_cache"
            or part == ".mypy_cache"
        ):
            return True
    return normalized.endswith(".pyc") or normalized.endswith(".pyo")


def _sort_strings(mut values: List[String]) -> None:
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key


def _contains(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _c_string_from_offset(
    pointer: UnsafePointer[UInt8, MutUntrackedOrigin], offset: Int
) -> String:
    var data = List[UInt8]()
    var cursor = offset
    while pointer[cursor] != UInt8(0):
        data.append(pointer[cursor])
        cursor += 1
    return String(from_utf8_lossy=Span(data))


def _open_directory(
    path: String,
) raises -> Optional[UnsafePointer[UInt8, MutUntrackedOrigin]]:
    var storage = path + "\0"
    return external_call[
        "opendir", Optional[UnsafePointer[UInt8, MutUntrackedOrigin]]
    ](CStringSlice(storage))


def _close_directory(
    directory: UnsafePointer[UInt8, MutUntrackedOrigin]
) raises -> None:
    if Int(external_call["closedir", c_int](directory)) != 0:
        raise Error("package-integrity could not close directory")


def _path_is_symlink(path: String) raises -> Bool:
    # A one-byte destination is enough: readlink(2) returns a non-negative
    # length for every symlink, including links whose target is longer.
    var storage = path + "\0"
    var scratch = stack_allocation[1, UInt8]()
    return (
        Int(
            external_call["readlink", c_long](
                CStringSlice(storage), scratch, c_size_t(1)
            )
        )
        >= 0
    )


def _symlink_points_to_file(path: String) raises -> Bool:
    # ``os.walk(..., followlinks=False)`` exposes symlinks to directories in
    # dirnames and therefore never yields them as regular files.  A symlink to
    # a regular file is yielded because Path.is_file() follows the final link.
    var maybe_directory = _open_directory(path)
    if maybe_directory:
        _close_directory(maybe_directory.value())
        return False
    try:
        var file = open(path, "r")
        _ = file.read_bytes()
        return True
    except:
        return False


def canonical_manifest_root(root: String) raises -> String:
    var storage = root + "\0"
    var resolved = external_call[
        "realpath", Optional[UnsafePointer[UInt8, MutUntrackedOrigin]]
    ](
        CStringSlice(storage),
        Optional[UnsafePointer[UInt8, MutUntrackedOrigin]](),
    )
    if not resolved:
        raise Error("package-integrity root could not be resolved: " + root)
    var pointer = resolved.value()
    var canonical = _c_string_from_offset(pointer, 0)
    _ = external_call["free", NoneType](pointer)
    if canonical == "":
        raise Error("package-integrity root resolved to an empty path")
    return canonical^


def _walk_regular_files(
    absolute_directory: String,
    relative_directory: String,
    mut result: List[String],
) raises -> None:
    # Linux/glibc struct dirent layout: d_type at byte 18 and d_name at byte
    # 19.  The project targets Linux; no helper process or Python runtime is
    # involved.  DT_UNKNOWN is handled with readlink/opendir fallbacks.
    var maybe_directory = _open_directory(absolute_directory)
    if not maybe_directory:
        raise Error(
            "package-integrity could not open directory: " + absolute_directory
        )
    var directory = maybe_directory.value()
    var names = List[String]()
    var kinds = List[Int]()
    while True:
        var entry = external_call[
            "readdir", Optional[UnsafePointer[UInt8, MutUntrackedOrigin]]
        ](directory)
        if not entry:
            break
        var pointer = entry.value()
        var name = _c_string_from_offset(pointer, 19)
        if name == "." or name == "..":
            continue
        names.append(name)
        kinds.append(Int(pointer[18]))
    _close_directory(directory)

    for index in range(len(names)):
        var name = names[index]
        var kind = kinds[index]
        var absolute = absolute_directory + "/" + name
        var relative = (
            name if relative_directory
            == "" else relative_directory + "/" + name
        )
        if kind == 4:  # DT_DIR
            _walk_regular_files(absolute, relative, result)
        elif kind == 8:  # DT_REG
            result.append(relative)
        elif kind == 10:  # DT_LNK
            if _symlink_points_to_file(absolute):
                result.append(relative)
        elif kind == 0:  # DT_UNKNOWN
            if _path_is_symlink(absolute):
                if _symlink_points_to_file(absolute):
                    result.append(relative)
                continue
            var child_directory = _open_directory(absolute)
            if child_directory:
                _close_directory(child_directory.value())
                _walk_regular_files(absolute, relative, result)
            else:
                # A source tree is expected to contain regular files rather
                # than devices/FIFOs.  Deferred open() below validates it.
                result.append(relative)
        # Other dirent kinds (FIFO, socket, device) are not regular files.


def _listed_relative_paths(root: String) raises -> List[String]:
    var result = List[String]()
    _walk_regular_files(root, "", result)
    return result^


def _read_manifest_file(root: String, relative: String) raises -> List[UInt8]:
    var primary = root + "/" + relative
    try:
        var file = open(primary, "r")
        return file.read_bytes()
    except:
        if relative.startswith("."):
            raise Error("manifest file is missing: " + relative)
        var dotted = root + "/." + relative
        var file = open(dotted, "r")
        return file.read_bytes()


def python_splitlines_count(data: List[UInt8]) -> Int:
    """Count lines like decoded Python ``str.splitlines()`` for UTF-8 CSV data.
    """
    if len(data) == 0:
        return 0
    var count = 0
    var cursor = 0
    var line_start = 0
    while cursor < len(data):
        var code = Int(data[cursor])
        var width = 0
        if (
            code == 10
            or code == 11
            or code == 12
            or code == 28
            or code == 29
            or code == 30
        ):
            width = 1
        elif code == 13:
            width = (
                2 if cursor + 1 < len(data)
                and Int(data[cursor + 1]) == 10 else 1
            )
        elif (
            code == 0xC2
            and cursor + 1 < len(data)
            and Int(data[cursor + 1]) == 0x85
        ):
            width = 2
        elif (
            code == 0xE2
            and cursor + 2 < len(data)
            and Int(data[cursor + 1]) == 0x80
            and (Int(data[cursor + 2]) == 0xA8 or Int(data[cursor + 2]) == 0xA9)
        ):
            width = 3
        if width == 0:
            cursor += 1
            continue
        count += 1
        cursor += width
        line_start = cursor
    if line_start < len(data):
        count += 1
    return count


def _nibble(value: Int) -> String:
    return chr(48 + value) if value < 10 else chr(87 + value)


def _digest_to_hex(digest: UnsafePointer[UInt8, MutUntrackedOrigin]) -> String:
    var result = String()
    for index in range(32):
        var byte = Int(digest[index])
        result += _nibble((byte >> 4) & 15)
        result += _nibble(byte & 15)
    return result^


def sha256_bytes(data: List[UInt8]) -> String:
    var output = stack_allocation[32, UInt8]()
    if len(data) == 0:
        var empty = "".as_bytes()
        _ = external_call[
            "SHA256", Optional[UnsafePointer[UInt8, MutUntrackedOrigin]]
        ](empty.unsafe_ptr(), c_size_t(0), output)
    else:
        _ = external_call[
            "SHA256", Optional[UnsafePointer[UInt8, MutUntrackedOrigin]]
        ](data.unsafe_ptr(), c_size_t(len(data)), output)
    return _digest_to_hex(output)


def _sha256_update_bytes(
    context: UnsafePointer[UInt8, MutUntrackedOrigin], data: List[UInt8]
) raises -> None:
    if len(data) == 0:
        return
    var status = Int(
        external_call["SHA256_Update", c_int](
            context, data.unsafe_ptr(), c_size_t(len(data))
        )
    )
    if status != 1:
        raise Error("SHA256_Update failed")


def _sha256_update_pointer(
    context: UnsafePointer[UInt8, MutUntrackedOrigin],
    data: UnsafePointer[UInt8, MutUntrackedOrigin],
    size: Int,
) raises -> None:
    var status = Int(
        external_call["SHA256_Update", c_int](context, data, c_size_t(size))
    )
    if status != 1:
        raise Error("SHA256_Update failed")


def repo_manifest_from_tree(
    root: String, required_paths: List[String]
) raises -> RepoManifest:
    var canonical_root = canonical_manifest_root(root)
    var raw_paths = _listed_relative_paths(canonical_root)
    var files = List[String]()
    var runtime_artifact_count = 0
    for index in range(len(raw_paths)):
        var relative = raw_paths[index]
        if is_runtime_artifact(relative):
            runtime_artifact_count += 1
        else:
            files.append(normalise_manifest_path(relative))
    _sort_strings(files)

    var context = stack_allocation[256, UInt8]()
    if Int(external_call["SHA256_Init", c_int](context)) != 1:
        raise Error("SHA256_Init failed")
    var nul = stack_allocation[1, UInt8]()
    nul[0] = UInt8(0)
    var total_bytes = 0
    var csv_line_counts = List[CsvLineCount]()
    var suspicious_csvs = List[String]()

    for index in range(len(files)):
        var relative = files[index]
        var data = _read_manifest_file(canonical_root, relative)
        total_bytes += len(data)
        var relative_bytes = relative.as_bytes()
        if len(relative_bytes) > 0:
            if (
                Int(
                    external_call["SHA256_Update", c_int](
                        context,
                        relative_bytes.unsafe_ptr(),
                        c_size_t(len(relative_bytes)),
                    )
                )
                != 1
            ):
                raise Error("SHA256_Update failed")
        _sha256_update_pointer(context, nul, 1)
        var file_digest = stack_allocation[32, UInt8]()
        if len(data) == 0:
            var empty = "".as_bytes()
            _ = external_call[
                "SHA256", Optional[UnsafePointer[UInt8, MutUntrackedOrigin]]
            ](empty.unsafe_ptr(), c_size_t(0), file_digest)
        else:
            _ = external_call[
                "SHA256", Optional[UnsafePointer[UInt8, MutUntrackedOrigin]]
            ](data.unsafe_ptr(), c_size_t(len(data)), file_digest)
        _sha256_update_pointer(context, file_digest, 32)

        if relative.startswith("csv/") and relative.endswith(".csv"):
            var line_count = python_splitlines_count(data)
            csv_line_counts.append(CsvLineCount(relative, line_count))
            if relative.endswith("religion.csv") and line_count < 500:
                suspicious_csvs.append(relative)

    var output = stack_allocation[32, UInt8]()
    if Int(external_call["SHA256_Final", c_int](output, context)) != 1:
        raise Error("SHA256_Final failed")

    var missing_required = List[String]()
    for index in range(len(required_paths)):
        var required = normalise_manifest_path(required_paths[index])
        if not _contains(files, required):
            missing_required.append(required)

    return RepoManifest(
        canonical_root,
        len(files),
        total_bytes,
        _digest_to_hex(output),
        files^,
        missing_required^,
        runtime_artifact_count,
        csv_line_counts^,
        suspicious_csvs^,
    )


def default_repo_manifest(root: String) raises -> RepoManifest:
    return repo_manifest_from_tree(root, required_source_paths())


def _json_quote(value: String) -> String:
    var escaped = value.replace("\\", "\\\\")
    escaped = escaped.replace('"', '\\"')
    escaped = escaped.replace(chr(8), "\\b")
    escaped = escaped.replace(chr(12), "\\f")
    escaped = escaped.replace("\n", "\\n")
    escaped = escaped.replace("\r", "\\r")
    escaped = escaped.replace("\t", "\\t")
    for code in range(32):
        if code == 8 or code == 9 or code == 10 or code == 12 or code == 13:
            continue
        var replacement = (
            "\\u00" + _nibble((code >> 4) & 15) + _nibble(code & 15)
        )
        escaped = escaped.replace(chr(code), replacement)
    return '"' + escaped + '"'


def _json_string_list(values: List[String]) -> String:
    var result = "["
    for index in range(len(values)):
        if index > 0:
            result += ","
        result += _json_quote(values[index])
    return result + "]"


def repo_manifest_json(
    manifest: RepoManifest, include_files: Bool = False
) -> String:
    var result = '{"root":' + _json_quote(manifest.root)
    result += ',"file_count":' + String(manifest.file_count)
    result += ',"total_bytes":' + String(manifest.total_bytes)
    result += ',"digest":' + _json_quote(manifest.digest)
    result += ',"missing_required":' + _json_string_list(
        manifest.missing_required
    )
    result += ',"runtime_artifact_count":' + String(
        manifest.runtime_artifact_count
    )
    result += ',"suspicious_csvs":' + _json_string_list(
        manifest.suspicious_csvs
    )
    result += ',"csv_line_counts":{'
    for index in range(len(manifest.csv_line_counts)):
        if index > 0:
            result += ","
        result += _json_quote(manifest.csv_line_counts[index].path)
        result += ":" + String(manifest.csv_line_counts[index].line_count)
    result += "}"
    if include_files:
        result += ',"files":' + _json_string_list(manifest.files)
    return result + "}"


def repo_manifest_summary(manifest: RepoManifest) -> String:
    return (
        "root="
        + manifest.root
        + "\n"
        + "file_count="
        + String(manifest.file_count)
        + "\n"
        + "total_bytes="
        + String(manifest.total_bytes)
        + "\n"
        + "digest="
        + manifest.digest
        + "\n"
        + "missing_required="
        + String(len(manifest.missing_required))
        + "\n"
        + "runtime_artifact_count="
        + String(manifest.runtime_artifact_count)
        + "\n"
        + "suspicious_csvs="
        + String(len(manifest.suspicious_csvs))
    )
