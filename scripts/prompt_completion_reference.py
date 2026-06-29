#!/usr/bin/env python3
"""Print the Python reference's nested prompt completions for one context."""
from __future__ import annotations

import sys
from pathlib import Path

if len(sys.argv) != 3:
    raise SystemExit("usage: prompt_completion_reference.py LANGUAGE TEXT")

language, text = sys.argv[1:]
root = Path(__file__).resolve().parent.parent
reference = root / "python_reference"
sys.argv = ["prompt-completion-reference", "-language=" + language]
sys.path.insert(0, str(reference))

from reta_architecture.facade import RetaArchitecture  # noqa: E402
from reta_architecture.completion_runtime import bootstrap_completion_runtime  # noqa: E402
from reta_architecture.completion_nested import (  # noqa: E402
    ComplSitua,
    CompleteEvent,
    Document,
    NestedCompleter,
)
import i18n.words_runtime as i18n  # noqa: E402

architecture = RetaArchitecture.bootstrap(reference)
runtime = bootstrap_completion_runtime(
    architecture=architecture,
    i18n=i18n,
    force_rebuild=True,
)
completer = NestedCompleter(
    {
        command: None
        for command in runtime.start_commands(include_numeric_shortcuts=True)
    },
    {},
    ComplSitua.retaAnfang,
    "",
    {
        **{"reta": ComplSitua.retaAnfang},
        **{
            command: ComplSitua.befehleNichtReta
            for command in runtime.befehle2
        },
    },
    completion_runtime=runtime,
    i18n=i18n,
)
event = CompleteEvent(completion_requested=True)
for completion in completer.get_completions(Document(text), event):
    print(completion.text)
