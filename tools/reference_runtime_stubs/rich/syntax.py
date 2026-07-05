from __future__ import annotations


class Syntax:
    def __init__(self, text, *args, **kwargs) -> None:
        self.text = text

    def __str__(self) -> str:
        return str(self.text)
