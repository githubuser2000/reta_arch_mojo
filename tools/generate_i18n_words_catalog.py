#!/usr/bin/env python3
"""Generate a deterministic native catalog for reta's split ``i18n.words`` tree.

The Python files remain the frozen compatibility reference.  This generator
serializes their effective public domain namespace for each canonical language
without evaluating Python at native runtime.  Container order, named-tuple
fields, class attributes and shared-object references are preserved.
"""
from __future__ import annotations

import argparse
import hashlib
import importlib
import inspect
import json
import os
import sys
from collections import OrderedDict, defaultdict
from dataclasses import dataclass
from pathlib import Path
from types import ModuleType
from typing import Any, Iterable

ROOT = Path(__file__).resolve().parent.parent
REFERENCE = ROOT / "python_reference"
LANGUAGES = ("deutsch", "english", "vietnamese", "chinese", "korean")
MODULES = (
    "i18n.words_bootstrap",
    "i18n.words_context",
    "i18n.words_matrix",
    "i18n.words_runtime",
    "i18n.words",
    "i18n.words_legacy_monolith",
)
LEGACY_MONOLITH = "i18n.words_legacy_monolith"
SCALAR_TYPES = (str, int, bool, float, type(None))


def _escape(text: str) -> str:
    return (
        text.replace("\\", "\\\\")
        .replace("\t", "\\t")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
        .replace("\x1f", "\\x1f")
    )


def _canonical_sort_key(value: Any) -> tuple[str, str]:
    """Stable ordering for historically unordered set/frozenset values."""
    return (type(value).__name__, repr(value))


def _portable_string(value: str) -> str:
    """Remove checkout-specific roots from exported public path values.

    The Python i18n modules expose ``localedir``/``i18nPath`` as absolute
    import-time paths.  Keeping those bytes would bind the generated native
    catalog to the generator checkout and make source-only regeneration
    impossible after extraction.  The project-relative spelling remains
    directly resolvable by the native launchers, which change to the project
    root before execution.
    """
    reference_root = str(REFERENCE.resolve())
    if value == reference_root:
        return "python_reference"
    prefix = reference_root + os.sep
    if value.startswith(prefix):
        return "python_reference/" + value[len(prefix) :].replace(os.sep, "/")
    project_root = str(ROOT.resolve())
    if value == project_root:
        return "."
    project_prefix = project_root + os.sep
    if value.startswith(project_prefix):
        return value[len(project_prefix) :].replace(os.sep, "/")
    return value


def _is_owned_callable(value: Any) -> bool:
    module = getattr(value, "__module__", "")
    return isinstance(module, str) and module.startswith("i18n.words")


def _is_domain_value(value: Any) -> bool:
    if isinstance(value, SCALAR_TYPES):
        return True
    if isinstance(value, (dict, list, tuple, set, frozenset)):
        return True
    if inspect.isclass(value):
        return hasattr(value, "_fields") or _is_owned_callable(value)
    if inspect.isfunction(value):
        return _is_owned_callable(value)
    return False


@dataclass(frozen=True)
class Row:
    module: str
    path: str
    kind: str
    value: str

    def encode(self) -> str:
        return "\t".join(
            (_escape(self.module), _escape(self.path), self.kind, _escape(self.value))
        )


class Flattener:
    def __init__(self) -> None:
        self.rows: list[Row] = []
        self.seen: dict[int, tuple[str, str]] = {}
        self.module_counts: dict[str, int] = defaultdict(int)
        self.root_counts: dict[str, int] = defaultdict(int)

    def emit(self, module: str, path: str, kind: str, value: str = "") -> None:
        self.rows.append(Row(module, path, kind, value))
        self.module_counts[module] += 1

    def flatten(self, module: str, path: str, value: Any) -> None:
        if isinstance(value, bool):
            self.emit(module, path, "bool", "true" if value else "false")
            return
        if value is None:
            self.emit(module, path, "none", "")
            return
        if isinstance(value, str):
            self.emit(module, path, "str", _portable_string(value))
            return
        if isinstance(value, int):
            self.emit(module, path, "int", str(value))
            return
        if isinstance(value, float):
            self.emit(module, path, "float", repr(value))
            return
        if inspect.isfunction(value):
            signature = str(inspect.signature(value))
            self.emit(module, path, "function", signature)
            return
        if inspect.isclass(value) and hasattr(value, "_fields"):
            fields = tuple(str(field) for field in value._fields)
            self.emit(module, path, "namedtuple_type", "\x1f".join(fields))
            return

        object_id = id(value)
        if object_id in self.seen:
            target_module, target_path = self.seen[object_id]
            self.emit(module, path, "ref", f"{target_module}:{target_path}")
            return
        self.seen[object_id] = (module, path)

        if isinstance(value, tuple) and hasattr(value, "_fields"):
            fields = tuple(str(field) for field in value._fields)
            self.emit(
                module,
                path,
                "namedtuple",
                f"{value.__class__.__name__}\x1f{len(fields)}",
            )
            for field, child in zip(fields, value):
                self.flatten(module, f"{path}.{field}", child)
            return

        if isinstance(value, dict):
            if isinstance(value, defaultdict):
                kind = "defaultdict"
            elif isinstance(value, OrderedDict):
                kind = "ordereddict"
            else:
                kind = "dict"
            self.emit(module, path, kind, str(len(value)))
            for index, (key, child) in enumerate(value.items()):
                self.flatten(module, f"{path}[{index}].key", key)
                self.flatten(module, f"{path}[{index}].value", child)
            return

        if isinstance(value, (list, tuple, set, frozenset)):
            kind = type(value).__name__.lower()
            children = list(value)
            if isinstance(value, (set, frozenset)):
                children.sort(key=_canonical_sort_key)
            self.emit(module, path, kind, str(len(children)))
            for index, child in enumerate(children):
                self.flatten(module, f"{path}[{index}]", child)
            return

        if inspect.isclass(value) and _is_owned_callable(value):
            attributes = [
                (name, child)
                for name, child in vars(value).items()
                if not name.startswith("__")
                and not inspect.isroutine(child)
                and not isinstance(child, (classmethod, staticmethod, property))
                and _is_domain_value(child)
            ]
            self.emit(module, path, "class", str(len(attributes)))
            for name, child in attributes:
                self.flatten(module, f"{path}.{name}", child)
            return

        raise TypeError(f"unsupported public i18n value at {module}:{path}: {type(value)!r}")

    def module(self, module: ModuleType) -> None:
        declared = getattr(module, "__all__", None)
        if declared is None and module.__name__ == LEGACY_MONOLITH:
            # The preserved pre-split module predates ``__all__``.  Its public
            # compatibility surface is the effective non-private domain
            # namespace after import.  Imported helper modules and typing
            # objects are rejected by ``_is_domain_value`` below.
            names: Iterable[str] = tuple(
                name for name in vars(module) if not name.startswith("_")
            )
        else:
            names = declared or ()
        for name in names:
            if name.startswith("__") or not hasattr(module, name):
                continue
            value = getattr(module, name)
            if not _is_domain_value(value):
                continue
            self.root_counts[module.__name__] += 1
            self.flatten(module.__name__, name, value)


def _clear_i18n_modules() -> None:
    for name in tuple(sys.modules):
        if name == "i18n" or name.startswith("i18n."):
            del sys.modules[name]


def _load_language(language: str) -> list[ModuleType]:
    _clear_i18n_modules()
    sys.argv = ["generate_i18n_words_catalog.py", f"-language={language}"]
    importlib.invalidate_caches()
    return [importlib.import_module(name) for name in MODULES]


def _generate_language(language: str) -> tuple[str, dict[str, Any]]:
    flattener = Flattener()
    modules = _load_language(language)
    for module in modules:
        flattener.module(module)

    runtime = modules[3]
    for mod in range(5):
        flattener.emit(
            "i18n.words_runtime",
            f"__behavior__.classify[{mod}]",
            "str",
            str(runtime.classify(mod)),
        )

    lines = [row.encode() for row in flattener.rows]
    text = "\n".join(lines) + "\n"
    metadata = {
        "language": language,
        "rows": len(lines),
        "roots": sum(flattener.root_counts.values()),
        "module_rows": dict(flattener.module_counts),
        "module_roots": dict(flattener.root_counts),
        "sha256": hashlib.sha256(text.encode("utf-8")).hexdigest(),
    }
    return text, metadata


def generate(output: Path) -> dict[str, Any]:
    output.mkdir(parents=True, exist_ok=True)
    languages: list[dict[str, Any]] = []
    for language in LANGUAGES:
        text, metadata = _generate_language(language)
        path = output / f"{language}.tsv"
        path.write_text(text, encoding="utf-8", newline="")
        languages.append(metadata)

    manifest = {
        "format": "reta-i18n-words-tree-v2",
        "canonical_languages": list(LANGUAGES),
        "source_modules": list(MODULES),
        "total_rows": sum(item["rows"] for item in languages),
        "languages": languages,
    }
    (output / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
        newline="",
    )
    return manifest


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "assets" / "i18n_words",
    )
    args = parser.parse_args()
    if str(REFERENCE) not in sys.path:
        sys.path.insert(0, str(REFERENCE))
    manifest = generate(args.output)
    print(
        f"generated {manifest['total_rows']} rows across "
        f"{len(manifest['canonical_languages'])} languages in {args.output}"
    )


if __name__ == "__main__":
    main()
