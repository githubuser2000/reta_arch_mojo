#!/usr/bin/env python3
"""Capture all reference Grundstrukturen variants with one import per language."""
from __future__ import annotations

import argparse
import contextlib
import importlib.util
import io
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REFERENCE = ROOT / "python_reference"


def render_loaded(module, *, blank: bool) -> str:
    module.blank = blank
    output = io.StringIO()
    with contextlib.redirect_stdout(output):
        print(
            "".join(
                (
                    '<div style="',
                    "",
                    'white-space: normal; border-left: 40px solid rgba(0, 0, 0, .0);" ',
                    ("id='grundstrukturenDiv'" if blank else ""),
                    ">",
                )
            ),
            end="",
        )
        module.myprint(module.wahlNeu2, 0)
        print("</div>")
    return output.getvalue()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--language", default="")
    args = parser.parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)

    old_argv = sys.argv
    sys.path.insert(0, str(REFERENCE))
    sys.path.insert(0, str(REFERENCE / "libs"))
    module_argv = [str(REFERENCE / "grundStrukHtml.py")]
    if args.language:
        module_argv.append(f"-language={args.language}")
    sys.argv = module_argv
    try:
        spec = importlib.util.spec_from_file_location(
            f"grundStrukHtml_reference_{args.language or 'de'}",
            REFERENCE / "grundStrukHtml.py",
        )
        if spec is None or spec.loader is None:
            raise RuntimeError("cannot load grundStrukHtml.py")
        module = importlib.util.module_from_spec(spec)
        with contextlib.redirect_stdout(io.StringIO()):
            spec.loader.exec_module(module)
    finally:
        sys.argv = old_argv

    suffix = "en" if args.language else "de"
    normal = render_loaded(module, blank=False)
    blank = render_loaded(module, blank=True)
    selected = args.language
    debug_prefix = (
        f"Sprachenwahl: {selected}\n"
        + ("german\n" if not args.language else "not german\n")
    )
    (args.output_dir / f"python-normal-{suffix}").write_text(normal, encoding="utf-8")
    (args.output_dir / f"python-blank-{suffix}").write_text(blank, encoding="utf-8")
    (args.output_dir / f"python-debug-{suffix}").write_text(
        debug_prefix + normal,
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
