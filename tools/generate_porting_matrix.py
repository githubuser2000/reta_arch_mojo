#!/usr/bin/env python3
from __future__ import annotations

import ast
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
PYROOT = ROOT / "python_reference"
OUT = ROOT / "PORTING_MATRIX.md"

NATIVE = {
    "reta_architecture/number_theory.py": ("nativ", "src/reta_mojo/number_theory.mojo", "Kernfunktionen vollständig typisiert"),
    "reta_architecture/row_ranges.py": ("nativ", "src/reta_mojo/row_ranges.mojo", "legitime Bereichssyntax; eval bewusst entfernt"),
    "reta_architecture/arithmetic.py": ("nativ", "src/reta_mojo/arithmetic.mojo", "arithmetischer Kern; Prozessparallelisierung noch nicht"),
    "reta_architecture/category_theory.py": ("generiert nativ", "src/reta_mojo/category_theory.mojo", "26 Kategorien, 77 Funktoren, 42 Transformationen"),
    "reta_architecture/topology.py": ("nativ", "src/reta_mojo/topology.mojo", "symbolische Auswahl, Verfeinerung, Aliasauflösung"),
    "reta_architecture/output_semantics.py": ("teilweise nativ", "src/reta_mojo/output_modes.mojo", "Modusauflösung und Flags"),
    "reta_architecture/output_syntax.py": ("teilweise nativ", "src/reta_mojo/output_modes.mojo", "statische Syntax und Zeilenfarben"),
    "reta_architecture/presheaves.py": ("teilweise nativ", "src/reta_mojo/presheaves.mojo", "typisierte String-Lokalsektionen und Restriktion"),
    "reta_architecture/universal.py": ("teilweise nativ", "src/reta_mojo/universal.mojo", "Normalisierung positiver/negativer Spalten-Buckets"),
    "reta_architecture/column_selection.py": ("teilweise nativ", "src/reta_mojo/column_selection.mojo", "24 typisierte Bucket-Koordinaten und Bucket-Erzeugung; Legacy-Programmbindung noch Bridge"),
    "reta_architecture/schema.py": ("generiert nativ", "src/reta_mojo/schema.mojo + schema_catalog.mojo", "33 Hauptgruppen, 431 Parametereinträge und Kontext-Mappings als besitzender Snapshot"),
    "reta_architecture/sheaves.py": ("teilweise nativ", "src/reta_mojo/parameter_semantics.mojo", "ParameterSemanticsSheaf: Aliasauflösung, kanonische Paare, direkte Spalten und Rückabbildung"),
    "reta_architecture/morphisms.py": ("teilweise nativ", "src/reta_mojo/morphisms.mojo", "Alias-, Bereichs-, Prompt-Split- und Renderer-Modus-Morphismen"),
    "reta_architecture/input_semantics.py": ("teilweise nativ", "src/reta_mojo/input_semantics.mojo + row_ranges.mojo", "CLI-Normalisierung, Kommasyntax, Polarität, kanonische Spaltenauswahl und schemaabgeleitetes Prompt-Vokabular; dynamischer Prompt-Executor noch Bridge"),
}


def metrics(path: pathlib.Path) -> tuple[int, int, int, int]:
    text = path.read_text(encoding="utf-8", errors="replace")
    try:
        tree = ast.parse(text)
    except SyntaxError:
        return len(text.splitlines()), 0, 0, 0
    functions = sum(isinstance(n, (ast.FunctionDef, ast.AsyncFunctionDef)) for n in ast.walk(tree))
    classes = sum(isinstance(n, ast.ClassDef) for n in ast.walk(tree))
    dynamic = sum(
        isinstance(n, ast.Call) and isinstance(n.func, ast.Name) and n.func.id in {"getattr", "setattr", "eval", "exec"}
        for n in ast.walk(tree)
    )
    return len(text.splitlines()), functions, classes, dynamic


rows = []
for path in sorted(PYROOT.rglob("*.py")):
    rel = path.relative_to(PYROOT).as_posix()
    lines, functions, classes, dynamic = metrics(path)
    if rel in NATIVE:
        status, target, note = NATIVE[rel]
    else:
        status, target, note = "Python-Referenz/Bridge", "python_reference/" + rel, "noch nicht nativ portiert"
    rows.append((rel, lines, functions, classes, dynamic, status, target, note))

original_rows = [r for r in rows if r[0] != "mojo_bridge.py"]
native_lines = sum(r[1] for r in original_rows if r[0] in NATIVE)
total_lines = sum(r[1] for r in original_rows)
content = [
    "# Portierungsmatrix Python → Mojo\n\n",
    "Stand: 28. Juni 2026. Die Matrix unterscheidet echten nativen Mojo-Code von der gebündelten Python-Kompatibilitätsreferenz.\n\n",
    f"- Ursprüngliche Python-Dateien: **{len(original_rows)}**\n",
    f"- Ursprüngliche Python-Zeilen insgesamt: **{total_lines}**\n",
    "- Zusätzlicher Bridge-Adapter: **1 Python-Datei**\n",
    f"- Quellzeilen der bereits angegriffenen Architekturmodule: **{native_lines}**\n",
    "- Native Mojo-Quellzeilen: siehe `src/` (inklusive generiertem Kategoriekatalog)\n\n",
    "| Python-Datei | Zeilen | Funktionen | Klassen | dynamische Aufrufe | Status | Mojo/Ziel | Anmerkung |\n",
    "|---|---:|---:|---:|---:|---|---|---|\n",
]
for row in rows:
    rel, lines, functions, classes, dynamic, status, target, note = row
    content.append(f"| `{rel}` | {lines} | {functions} | {classes} | {dynamic} | {status} | `{target}` | {note} |\n")
OUT.write_text("".join(content), encoding="utf-8")
