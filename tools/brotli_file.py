#!/usr/bin/env python3
"""Stream-compress or decompress one file with Brotli.

Used by the source archive workflow so `.tar.br` does not require a separate
brotli command-line program when the Python module is installed.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import sys

try:
    import brotli
except ImportError as exc:  # pragma: no cover - environment dependent
    raise SystemExit(
        "Python module 'brotli' is required for .tar.br archives "
        "(install package Brotli/brotli)."
    ) from exc

CHUNK = 1024 * 1024


def compress(source: Path, target: Path, quality: int, text_mode: bool) -> None:
    mode = brotli.MODE_TEXT if text_mode else brotli.MODE_GENERIC
    encoder = brotli.Compressor(mode=mode, quality=quality)
    with source.open("rb") as src, target.open("wb") as dst:
        while block := src.read(CHUNK):
            dst.write(encoder.process(block))
        dst.write(encoder.finish())


def decompress(source: Path, target: Path) -> None:
    decoder = brotli.Decompressor()
    with source.open("rb") as src, target.open("wb") as dst:
        while block := src.read(CHUNK):
            dst.write(decoder.process(block))
        if not decoder.is_finished():
            raise SystemExit(f"incomplete Brotli stream: {source}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("operation", choices=("compress", "decompress"))
    parser.add_argument("source", type=Path)
    parser.add_argument("target", type=Path)
    parser.add_argument("--quality", type=int, default=9, choices=range(0, 12))
    parser.add_argument(
        "--generic",
        action="store_true",
        help="Use generic mode instead of text mode when compressing.",
    )
    args = parser.parse_args()
    if not args.source.is_file():
        parser.error(f"source does not exist: {args.source}")
    args.target.parent.mkdir(parents=True, exist_ok=True)
    if args.operation == "compress":
        compress(args.source, args.target, args.quality, not args.generic)
    else:
        decompress(args.source, args.target)
    return 0


if __name__ == "__main__":
    sys.exit(main())
