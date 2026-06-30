"""Portable native prompt input for non-interactive and plain-input sessions.

The historical TTY editor still uses the Python/readline compatibility boundary
until vi editing and completion callbacks have native parity.  Piped stdin and
an explicitly requested plain editor use Mojo's built-in ``input`` function,
so batch prompt sessions no longer initialize Python merely to read a line.
"""

from std.os import getenv, isatty


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
    if not isatty(0):
        return True
    return _truthy_environment(
        String(getenv("RETA_PROMPT_PLAIN_INPUT", ""))
    )


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
