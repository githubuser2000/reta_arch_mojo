"""PTY end-to-end checks for the native Mojo prompt line editor."""
from __future__ import annotations

import errno
import fcntl
import os
from pathlib import Path
import pty
import select
import struct
import subprocess
import termios
import time

ROOT = Path(__file__).resolve().parents[1]
PROBE = Path(
    os.environ.get(
        "RETA_PROMPT_NATIVE_TTY_PROBE",
        ROOT / "target" / "test-bin" / "prompt-native-tty-probe",
    )
)


def _run_tty(
    payloads: list[tuple[bytes, float]],
    history: Path,
    *,
    vi: bool = False,
    logging: bool = False,
) -> tuple[bytes, str]:
    assert PROBE.is_file() and os.access(PROBE, os.X_OK), (
        "the native TTY probe must be compiled before this test"
    )
    master, slave = pty.openpty()
    command = [
        str(PROBE),
        str(history),
        "vi" if vi else "emacs",
        "log" if logging else "nolog",
        "deutsch",
    ]
    process = subprocess.Popen(
        command,
        cwd=ROOT,
        stdin=slave,
        stdout=slave,
        stderr=slave,
        env={**os.environ, "TERM": "xterm-256color"},
        close_fds=True,
    )
    os.close(slave)
    output = bytearray()
    try:
        deadline = time.monotonic() + 10
        while b"probe> " not in output and time.monotonic() < deadline:
            ready, _, _ = select.select([master], [], [], 0.1)
            if ready:
                output.extend(os.read(master, 65536))
        assert b"probe> " in output, bytes(output)

        for payload, delay_after in payloads:
            os.write(master, payload)
            if delay_after:
                time.sleep(delay_after)

        deadline = time.monotonic() + 10
        while process.poll() is None and time.monotonic() < deadline:
            ready, _, _ = select.select([master], [], [], 0.1)
            if ready:
                try:
                    output.extend(os.read(master, 65536))
                except OSError as exc:
                    if exc.errno != errno.EIO:
                        raise
                    break
        assert process.wait(timeout=2) == 0, bytes(output).decode(
            "utf-8", "replace"
        )
        while True:
            ready, _, _ = select.select([master], [], [], 0)
            if not ready:
                break
            try:
                output.extend(os.read(master, 65536))
            except OSError as exc:
                if exc.errno == errno.EIO:
                    break
                raise
    finally:
        os.close(master)
        if process.poll() is None:
            process.kill()
            process.wait()

    marker = bytes(output).rfind(b"@@RESULT@@")
    assert marker >= 0, bytes(output).decode("utf-8", "replace")
    result = bytes(output)[marker + len(b"@@RESULT@@") :]
    result = result.replace(b"\r", b"").replace(b"\n", b"").decode(
        "utf-8", "strict"
    )
    return bytes(output), result



def _run_tty_twice_with_wrap(history: Path) -> tuple[str, str, bytes]:
    assert PROBE.is_file() and os.access(PROBE, os.X_OK)
    master, slave = pty.openpty()
    # Force an actual multi-row edit: both prompts plus payload exceed 16 cells.
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 16, 0, 0))
    process = subprocess.Popen(
        [str(PROBE), str(history), "emacs", "nolog", "deutsch", "twice"],
        cwd=ROOT,
        stdin=slave,
        stdout=slave,
        stderr=slave,
        env={**os.environ, "TERM": "xterm-256color"},
        close_fds=True,
    )
    os.close(slave)
    output = bytearray()

    def read_until(marker: bytes) -> None:
        deadline = time.monotonic() + 10
        while marker not in output and time.monotonic() < deadline:
            ready, _, _ = select.select([master], [], [], 0.1)
            if ready:
                try:
                    output.extend(os.read(master, 65536))
                except OSError as exc:
                    if exc.errno == errno.EIO:
                        break
                    raise
        assert marker in output, bytes(output).decode("utf-8", "replace")

    try:
        read_until(b"probe> ")
        # Move across the explicit wrap boundary and insert in the middle.
        os.write(master, b"abcdefghijklmnop")
        os.write(master, b"\x1b[D\x1b[D\x1b[DZ\r")
        read_until(b"probe2> ")
        os.write(master, b"second\r")
        assert process.wait(timeout=10) == 0
        while True:
            ready, _, _ = select.select([master], [], [], 0)
            if not ready:
                break
            try:
                output.extend(os.read(master, 65536))
            except OSError as exc:
                if exc.errno == errno.EIO:
                    break
                raise
    finally:
        os.close(master)
        if process.poll() is None:
            process.kill()
            process.wait()

    raw = bytes(output)
    first_marker = raw.rfind(b"@@FIRST@@")
    result_marker = raw.rfind(b"@@RESULT@@")
    assert 0 <= first_marker < result_marker, raw.decode("utf-8", "replace")
    first = raw[first_marker + len(b"@@FIRST@@") : result_marker]
    # Strip terminal control traffic preceding the second prompt by taking the
    # first physical result line only.
    first = first.split(b"\r", 1)[0].split(b"\n", 1)[0].decode("utf-8")
    second = raw[result_marker + len(b"@@RESULT@@") :]
    second = second.replace(b"\r", b"").replace(b"\n", b"").decode("utf-8")
    return first, second, raw


def test_emacs_editing_is_utf8_safe(tmp_path: Path) -> None:
    _, result = _run_tty(
        [("münd".encode(), 0), (b"\x1b[D\x1b[D", 0.05), (b"\x7f", 0), ("ü\r".encode(), 0)],
        tmp_path / "history",
    )
    assert result == "münd"


def test_emacs_cursor_insertion_and_nested_completion(tmp_path: Path) -> None:
    _, inserted = _run_tty(
        [(b"abc\x1b[D\x1b[DZ\r", 0)], tmp_path / "history"
    )
    assert inserted == "aZbc"

    _, completed = _run_tty(
        [(b"reta -ausgabe --art=bb\t\r", 0)], tmp_path / "history"
    )
    assert completed == "reta -ausgabe --art=bbcode "


def test_history_navigation_and_duplicate_persistence(tmp_path: Path) -> None:
    history = tmp_path / "history"
    history.write_text("prim 12\nmond 3\n", encoding="utf-8")
    _, result = _run_tty([(b"\x1b[A\r", 0.05)], history, logging=True)
    assert result == "mond 3"
    assert history.read_text(encoding="utf-8") == "prim 12\nmond 3\nmond 3\n"


def test_vi_insert_and_normal_modes(tmp_path: Path) -> None:
    _, result = _run_tty(
        [(b"abc", 0), (b"\x1b", 0.05), (b"hx", 0), (b"iZ\r", 0)],
        tmp_path / "history",
        vi=True,
    )
    assert result == "abZ"


def test_interrupt_and_eof_sentinels(tmp_path: Path) -> None:
    _, interrupted = _run_tty([(b"\x03", 0)], tmp_path / "history")
    assert interrupted == "INTERRUPT"
    _, eof = _run_tty([(b"\x04", 0)], tmp_path / "history")
    assert eof == "EOF"



def test_wrapped_editing_and_second_prompt_reenable_raw_mode(tmp_path: Path) -> None:
    first, second, raw = _run_tty_twice_with_wrap(tmp_path / "history")
    assert first == "abcdefghijklmZnop", raw.decode("utf-8", "replace")
    assert second == "second", raw.decode("utf-8", "replace")
