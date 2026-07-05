from __future__ import annotations

import sys


class Console:
    """Minimal non-colouring console with Rich's newline behaviour here."""

    def __init__(self, *args, **kwargs) -> None:
        pass

    def print(self, *args, **kwargs) -> None:
        end = kwargs.get("end", "\n")
        text = " ".join(str(arg) for arg in args)
        sys.stdout.write(text)
        # ``center.cli_output`` passes ``end=''`` for Syntax objects.  Rich
        # still terminates the rendered logical line; reproduce that directly.
        if end == "" and not text.endswith("\n"):
            sys.stdout.write("\n")
        else:
            sys.stdout.write(end)
