#!/usr/bin/env python3
from __future__ import annotations

import ast
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
PYROOT = ROOT / "python_reference"
OUT = ROOT / "PORTING_MATRIX.md"

NATIVE = {
    "bbcode.py": ("nativ", "src/reta_mojo/compat_text.mojo", "identische Text-Fallbacksemantik ohne Python-Abhängigkeit"),
    "html2text.py": ("nativ", "src/reta_mojo/compat_text.mojo", "identische Text-Fallbacksemantik ohne Python-Abhängigkeit"),
    "multis.py": ("nativ", "src/reta_mojo/arithmetic.mojo + prompt_runtime.mojo", "Faktorpaare und öffentliche multis-CLI nativ"),
    "multis3.py": ("nativ", "src/reta_mojo/arithmetic.mojo + prompt_runtime.mojo", "Dreifach-Faktorisierung nativ; deterministische lexikographische Ausgabe statt Set-Reihenfolge"),
    "libs/lib4tables_Enum.py": ("generiert nativ", "src/reta_mojo/tag_schema.mojo + tag_schema_catalog.mojo", "sieben Tagarten und vollständige Tabellen-Tag-Zuordnung"),
    "libs/tableHandling.py": ("teilweise nativ", "src/reta_mojo/table_state.mojo + table_wrapping.mojo + output_modes.mojo", "deterministischer Tabellenzustand, Umbruch und Ausgabemodi; große Tabellenberechnung noch Bridge"),
    "grundStrukHtml.py": ("generiert nativ", "src/reta_mojo/grundstrukturen_html.mojo + grundstrukturen_catalog.mojo", "Renderer vollständig nativ; lokalisierter wahl15-Katalog reproduzierbar generiert und bytegleich"),
    "reta_architecture/number_theory.py": ("nativ", "src/reta_mojo/number_theory.mojo", "Kernfunktionen vollständig typisiert"),
    "reta_architecture/row_ranges.py": ("nativ", "src/reta_mojo/row_ranges.mojo", "legitime Bereichssyntax; eval bewusst entfernt"),
    "reta_architecture/arithmetic.py": ("nativ", "src/reta_mojo/arithmetic.mojo + parallel_execution.mojo", "arithmetischer Kern sowie typisierte Thread-Chunkausführung für Primfaktoren und Faktorpaare nativ"),
    "reta_architecture/category_theory.py": ("generiert nativ", "src/reta_mojo/category_theory.mojo", "26 Kategorien, 77 Funktoren, 42 Transformationen"),
    "reta_architecture/architecture_map.py": ("generiert nativ", "src/reta_mojo/architecture_map.mojo + tools/generate_architecture_map.py", "11 Kapseln, 34 Einschließungen, 53 Flüsse, 34 Legacy-Zuordnungen und 42 Stufenschritte"),
    "reta_architecture/architecture_boundaries.py": ("generiert nativ", "src/reta_mojo/architecture_boundaries.mojo + tools/generate_architecture_boundaries.py", "161 Modulbesitzer, 279 Importkanten, 37 Kapselkanten und 11 Grenzobjekte"),
    "reta_architecture/architecture_contracts.py": ("generiert nativ", "src/reta_mojo/architecture_contracts.mojo + tools/generate_architecture_contracts.py", "33 kommutierende Diagramme, 11 Kapselverträge und 22 Gesetze"),
    "reta_architecture/architecture_witnesses.py": ("generiert nativ", "src/reta_mojo/architecture_witnesses.mojo + tools/generate_architecture_witnesses.py", "536 Anker, 11 Kapselschnitte, 33 Diagramm-, 42 Natürlichkeits-Witnesses und 55 Verpflichtungen"),
    "reta_architecture/architecture_coherence.py": ("generiert nativ", "src/reta_mojo/architecture_coherence.mojo + tools/generate_architecture_coherence.py", "11 Kapselkohärenzen, 53 Routen, 42 Natürlichkeits- und 22 Gesetzeskohärenzen"),
    "reta_architecture/architecture_traces.py": ("generiert nativ", "src/reta_mojo/architecture_traces.mojo + tools/generate_architecture_traces.py", "34 Komponenten-, 11 Kapsel- und 42 Stufentraces mit 204 Route-Hops"),
    "reta_architecture/architecture_impact.py": ("generiert nativ", "src/reta_mojo/architecture_impact.mojo + tools/generate_architecture_impact.py", "34 Impact-Quellen, 34 Verträge, 10 Gates und 34 Migrationskandidaten; Validierung passed"),
    "reta_architecture/architecture_migration.py": ("generiert nativ", "src/reta_mojo/architecture_migration.mojo + tools/generate_architecture_migration.py", "7 Wellen, 34 Schritte, 34 Gate-Bindungen und 7 Invarianten; Validierung passed"),
    "reta_architecture/architecture_rehearsal.py": ("generiert nativ", "src/reta_mojo/architecture_rehearsal.mojo + tools/generate_architecture_rehearsal.py", "7 Öffnungen, 34 Moves, 34 Gate-Suiten und 7 Cover; Referenz- und native Kreuzvalidierung passed"),
    "reta_architecture/architecture_activation.py": ("generiert nativ", "src/reta_mojo/architecture_activation.mojo + tools/generate_architecture_activation.py", "7 Fenster, 34 Units, 34 Commit-Gates, 34 Rollbacks und 7 Transaktionen; Referenz- und native Kreuzvalidierung passed"),
    "reta_architecture/architecture_validation.py": ("generiert nativ", "src/reta_mojo/architecture_validation.mojo + tools/generate_architecture_validation.py", "51 Checks, 17 Schichten und 3.448 geprüfte Objekte; Referenz- und native Kreuzvalidierung passed"),
    "reta_architecture/architecture_progress.py": ("generiert nativ", "src/reta_mojo/architecture_progress.mojo + tools/generate_architecture_progress.py", "30 Oberflächen, 34 Schritte, 7 Wellen und ein dokumentierter Umweltblock; native Kreuzvalidierung konsistent"),
    "reta_architecture/console_io.py": ("teilweise nativ", "src/reta_mojo/console_io.mojo", "reine Chunk-, Deduplikations-, Whitespace- und Debugformatierung nativ; Terminal-/Rich-I/O bleibt Systemgrenze"),
    "reta_architecture/runtime_compat.py": ("teilweise nativ", "src/reta_mojo/runtime_compat.mojo + arithmetic.mojo", "Enums, fill_both und deterministische Arithmetik nativ; dynamische Python-Kompatibilität bleibt Bridge"),
    "reta_architecture/table_state.py": ("nativ", "src/reta_mojo/table_state.mojo", "typisierter Tabellenzustand, Abschnittsnamen und Zeilengrenzen"),
    "reta_architecture/table_wrapping.py": ("teilweise nativ", "src/reta_mojo/table_wrapping.mojo", "Unicode-sicherer harter Umbruch und Breitenlogik nativ; Wörterbuchtrennung bleibt externe Grenze"),
    "reta_architecture/tag_schema.py": ("generiert nativ", "src/reta_mojo/tag_schema.mojo + tag_schema_catalog.mojo", "Primär- und Kombi-Tag-Schemata mit Vorwärts-/Rückabbildung"),
    "reta_architecture/topology.py": ("nativ", "src/reta_mojo/topology.mojo", "symbolische Auswahl, Verfeinerung, Aliasauflösung"),
    "reta_architecture/output_semantics.py": ("nativ", "src/reta_mojo/output_modes.mojo", "reine Modusauflösung und vollständige Tabellen-Flaganwendung"),
    "reta_architecture/output_syntax.py": ("teilweise nativ", "src/reta_mojo/output_modes.mojo", "statische Syntax und Zeilenfarben"),
    "reta_architecture/persistence.py": ("nativ", "src/reta_mojo/persistence.mojo + src/architecture_persistence_main.mojo", "SQLite-Schema, stabile SHA-256-Digests, Sections, Garben-Snapshots, Runs, Audit, Cache und Batch-Schreibpfade nativ; JSON-Grenze ist kanonischer UTF-8-Text"),
    "reta_architecture/execution_network.py": ("nativ", "src/reta_mojo/execution_network.mojo + src/architecture_execution_network_main.mojo", "typisierte FIFO-/LIFO-/Prioritätsplanung, Kanal-/Semaphorgrenzen, native Mojo-Threads und deterministische Reduktion; 0 POSIX-Prozessprimitive; Nutzlastgrenze ist UTF-8-Text mit expliziter Operationskennung"),
    "reta_architecture/parallel_execution.py": ("nativ", "src/reta_mojo/parallel_execution.mojo + parallel_row_preparation.mojo + beide Parallel-CLIs", "zehn reine Tabellen-/Zahlenkerne verwenden typisierte Mojo-Thread-Chunks; historische Prozessoptionen sind Alias; der dynamische WorkerPrepare/deepcopy-Pfad ist durch einen besitzenden typisierten Zeilenkontext ersetzt"),
    "reta_architecture/presheaves.py": ("teilweise nativ", "src/reta_mojo/presheaves.mojo", "typisierte String-Lokalsektionen und Restriktion"),
    "reta_architecture/universal.py": ("teilweise nativ", "src/reta_mojo/universal.mojo", "Normalisierung positiver/negativer Spalten-Buckets"),
    "reta_architecture/column_selection.py": ("teilweise nativ", "src/reta_mojo/column_selection.mojo", "24 typisierte Bucket-Koordinaten und Bucket-Erzeugung; Legacy-Programmbindung noch Bridge"),
    "reta_architecture/schema.py": ("generiert nativ", "src/reta_mojo/schema.mojo + schema_catalog.mojo", "33 Hauptgruppen, 431 Parametereinträge und Kontext-Mappings als besitzender Snapshot"),
    "reta_architecture/sheaves.py": ("teilweise nativ", "src/reta_mojo/parameter_semantics.mojo", "ParameterSemanticsSheaf: Aliasauflösung, kanonische Paare, direkte Spalten und Rückabbildung"),
    "reta_architecture/morphisms.py": ("teilweise nativ", "src/reta_mojo/morphisms.mojo", "Alias-, Bereichs-, Prompt-Split- und Renderer-Modus-Morphismen"),
    "reta_architecture/input_semantics.py": ("teilweise nativ", "src/reta_mojo/input_semantics.mojo + row_ranges.mojo", "CLI-Normalisierung, Kommasyntax, Polarität, kanonische Spaltenauswahl und schemaabgeleitetes Prompt-Vokabular; dynamischer Prompt-Executor noch Bridge"),
    "reta.py": ("teilweise nativ", "src/reta_native_main.mojo + src/reta_mojo/native_reta_cli.mojo", "häufige deutsche und englische Tabellenaufrufe nativ; vollständige Legacy-Oberfläche bleibt über RETA_NATIVE=0 kompatibel"),
    "reta_architecture/row_filtering.py": ("nativ", "src/reta_mojo/row_filtering.mojo", "Zeilenbereiche, Zeit, Zählgruppen, Primklassen, Gestirne, Vielfache, Potenzen, Invertierung und Positionsfilter"),
    "reta_architecture/generated_columns.py": ("teilweise nativ", "src/reta_mojo/generated_columns.mojo", "vier Generatorfamilien zweisprachig nativ; restliche Generator- und Metaspalten folgen in Stufe 7"),
    "reta_architecture/table_preparation.py": ("weitgehend nativ", "src/reta_mojo/table_preparation.mojo + parallel_row_preparation.mojo", "Zeilenauswahl, Tabellenprojektion, Unicode-sicherer Zellenumbruch und typisierte serielle/threadbasierte Vorbereitung unabhängiger Datenzeilen nativ; globale Header-Tag-Mutation bleibt bewusst seriell"),
    "reta_architecture/table_output.py": ("teilweise nativ", "src/reta_mojo/table_rendering.mojo", "CSV, Markdown und Emacs für den nativen Tabellenpfad bytegleich; komplexes HTML/BBCode-Wrapping noch unvollständig"),
    "reta_architecture/table_generation.py": ("teilweise nativ", "src/reta_mojo/csv_table.mojo + native_reta_cli.mojo", "CSV-Grundtabelle, Spaltenprojektion und einfacher Ende-zu-Ende-Tabellenpfad nativ"),
    "reta_architecture/table_runtime.py": ("teilweise nativ", "src/reta_mojo/native_reta_cli.mojo + table_preparation.mojo", "typisierter nativer Laufzeitplan für häufige Zeilen-, Spalten- und Ausgabeparameter"),
    "libs/lib4tables_prepare.py": ("teilweise nativ", "src/reta_mojo/table_preparation.mojo + row_filtering.mojo", "deterministische Zeilenauswahl und Vorbereitung nativ; Generatorverkettung noch Bridge"),
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
    "Stand: 30. Juni 2026. Die Matrix unterscheidet echten nativen Mojo-Code von der gebündelten Python-Kompatibilitätsreferenz.\n\n",
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
