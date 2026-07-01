"""Native prompt input for pipes, plain sessions and interactive terminals.

Piped stdin uses Mojo's built-in ``input`` path.  Real terminals use the native
POSIX adapter and pure Mojo line editor, including UTF-8 editing, persistent
history, Emacs/Vi navigation and nested completion.  No embedded Python runtime
is required to read prompt input.
"""

from std.collections import List
from std.os import getenv, isatty
from .prompt_language import PromptLanguageCatalog
from .prompt_session import history_should_append
from .prompt_terminal_input import read_terminal_prompt_line


comptime PROMPT_EOF = "\x04"


def _truthy_environment(value: String) -> Bool:
    var normalized = value.strip().lower()
    return (
        normalized == "1"
        or normalized == "true"
        or normalized == "yes"
        or normalized == "on"
    )


def native_plain_input_requested() -> Bool:
    """Return true for pipes or an explicit portable plain-input request."""
    if not isatty(0) or not isatty(1):
        return True
    return _truthy_environment(String(getenv("RETA_PROMPT_PLAIN_INPUT", "")))


def expanded_history_path(path: String) -> String:
    """Expand the exact ``~/`` form used by the historical prompt."""
    if not path.startswith("~/"):
        return path
    var home = String(getenv("HOME", "")).strip()
    if home.byte_length() == 0:
        return path
    if home.endswith("/"):
        return home + String(StringSlice(path)[byte=2:])
    return home + "/" + String(StringSlice(path)[byte=2:])


def append_prompt_history(path: String, line: String) -> Bool:
    """Append one non-empty command, retaining duplicates like readline."""
    if line.strip().byte_length() == 0:
        return False
    try:
        var file = open(expanded_history_path(path), "a")
        var payload = line + "\n"
        file.write_all(payload.as_bytes())
        return True
    except:
        # History persistence has always been best effort.
        return False


def read_plain_prompt_line(
    prompt: String,
    history_enabled: Bool = False,
    history_path: String = "~/.ReTaPromptHistory",
) -> String:
    """Read one line with Mojo I/O and return the historical EOF sentinel."""
    try:
        var line = input(prompt)
        if history_enabled:
            _ = append_prompt_history(history_path, line)
        return line
    except:
        return PROMPT_EOF


def load_prompt_history(path: String) -> List[String]:
    """Load the persistent readline-compatible one-command-per-line history."""
    var result = List[String]()
    try:
        var file = open(expanded_history_path(path), "r")
        var text = file.read()
        file.close()
        for line_slice in text.split("\n"):
            var line = String(line_slice)
            if line.endswith("\r"):
                line = String(
                    StringSlice(line)[byte = 0 : line.byte_length() - 1]
                )
            if line.byte_length() > 0:
                result.append(line^)
    except:
        pass
    return result^


def read_native_prompt_line(
    prompt: String,
    catalog: PromptLanguageCatalog,
    language: String,
    vi_mode: Bool = False,
    history_enabled: Bool = False,
    history_path: String = "~/.ReTaPromptHistory",
) raises -> String:
    """Read one prompt line through the appropriate fully native input path."""
    if native_plain_input_requested():
        var plain_line = read_plain_prompt_line(prompt, False, history_path)
        if history_enabled and history_should_append(plain_line, catalog, language):
            _ = append_prompt_history(history_path, plain_line)
        return plain_line^

    var history = load_prompt_history(history_path)
    var result = read_terminal_prompt_line(
        prompt, history, catalog, language, vi_mode
    )
    if not result.native_ready:
        var fallback_line = read_plain_prompt_line(prompt, False, history_path)
        if history_enabled and history_should_append(fallback_line, catalog, language):
            _ = append_prompt_history(history_path, fallback_line)
        return fallback_line^
    if result.interrupted:
        return "\x03"
    if result.eof:
        return PROMPT_EOF
    if history_enabled and history_should_append(result.line, catalog, language):
        _ = append_prompt_history(history_path, result.line)
    return result.line
