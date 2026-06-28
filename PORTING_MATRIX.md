# Portierungsmatrix Python → Mojo

Stand: 28. Juni 2026. Die Matrix unterscheidet echten nativen Mojo-Code von der gebündelten Python-Kompatibilitätsreferenz.

- Ursprüngliche Python-Dateien: **92**
- Ursprüngliche Python-Zeilen insgesamt: **48831**
- Zusätzlicher Bridge-Adapter: **1 Python-Datei**
- Quellzeilen der bereits angegriffenen Architekturmodule: **11326**
- Native Mojo-Quellzeilen: siehe `src/` (inklusive generiertem Kategoriekatalog)

| Python-Datei | Zeilen | Funktionen | Klassen | dynamische Aufrufe | Status | Mojo/Ziel | Anmerkung |
|---|---:|---:|---:|---:|---|---|---|
| `bbcode.py` | 9 | 2 | 1 | 0 | nativ | `src/reta_mojo/compat_text.mojo` | identische Text-Fallbacksemantik ohne Python-Abhängigkeit |
| `grundStrukHtml.py` | 232 | 5 | 0 | 0 | generiert nativ | `src/reta_mojo/grundstrukturen_html.mojo + grundstrukturen_catalog.mojo` | Renderer vollständig nativ; lokalisierter wahl15-Katalog reproduzierbar generiert und bytegleich |
| `html2text.py` | 9 | 2 | 1 | 0 | nativ | `src/reta_mojo/compat_text.mojo` | identische Text-Fallbacksemantik ohne Python-Abhängigkeit |
| `i18n/words.py` | 24 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/i18n/words.py` | noch nicht nativ portiert |
| `i18n/words_bootstrap.py` | 49 | 2 | 0 | 0 | Python-Referenz/Bridge | `python_reference/i18n/words_bootstrap.py` | noch nicht nativ portiert |
| `i18n/words_context.py` | 753 | 1 | 0 | 0 | Python-Referenz/Bridge | `python_reference/i18n/words_context.py` | noch nicht nativ portiert |
| `i18n/words_legacy_monolith.py` | 5431 | 4 | 8 | 0 | Python-Referenz/Bridge | `python_reference/i18n/words_legacy_monolith.py` | noch nicht nativ portiert |
| `i18n/words_matrix.py` | 4111 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/i18n/words_matrix.py` | noch nicht nativ portiert |
| `i18n/words_runtime.py` | 548 | 1 | 8 | 0 | Python-Referenz/Bridge | `python_reference/i18n/words_runtime.py` | noch nicht nativ portiert |
| `libs/LibRetaPrompt.py` | 80 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/libs/LibRetaPrompt.py` | noch nicht nativ portiert |
| `libs/center.py` | 333 | 33 | 1 | 0 | Python-Referenz/Bridge | `python_reference/libs/center.py` | noch nicht nativ portiert |
| `libs/generate4readme.py` | 382 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/libs/generate4readme.py` | noch nicht nativ portiert |
| `libs/lib4tables.py` | 59 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/libs/lib4tables.py` | noch nicht nativ portiert |
| `libs/lib4tables_Enum.py` | 37 | 0 | 0 | 0 | generiert nativ | `src/reta_mojo/tag_schema.mojo + tag_schema_catalog.mojo` | sieben Tagarten und vollständige Tabellen-Tag-Zuordnung |
| `libs/lib4tables_concat.py` | 252 | 35 | 1 | 0 | Python-Referenz/Bridge | `python_reference/libs/lib4tables_concat.py` | noch nicht nativ portiert |
| `libs/lib4tables_prepare.py` | 313 | 26 | 1 | 0 | teilweise nativ | `src/reta_mojo/table_preparation.mojo + row_filtering.mojo` | deterministische Zeilenauswahl und Vorbereitung nativ; Generatorverkettung noch Bridge |
| `libs/nestedAlx.py` | 24 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/libs/nestedAlx.py` | noch nicht nativ portiert |
| `libs/tableHandling.py` | 68 | 0 | 0 | 0 | teilweise nativ | `src/reta_mojo/table_state.mojo + table_wrapping.mojo + output_modes.mojo` | deterministischer Tabellenzustand, Umbruch und Ausgabemodi; große Tabellenberechnung noch Bridge |
| `libs/word_completerAlx.py` | 10 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/libs/word_completerAlx.py` | noch nicht nativ portiert |
| `mojo_bridge.py` | 297 | 17 | 0 | 0 | Python-Referenz/Bridge | `python_reference/mojo_bridge.py` | noch nicht nativ portiert |
| `multis.py` | 34 | 2 | 0 | 0 | nativ | `src/reta_mojo/arithmetic.mojo + prompt_runtime.mojo` | Faktorpaare und öffentliche multis-CLI nativ |
| `multis3.py` | 34 | 1 | 0 | 0 | nativ | `src/reta_mojo/arithmetic.mojo + prompt_runtime.mojo` | Dreifach-Faktorisierung nativ; deterministische lexikographische Ausgabe statt Set-Reihenfolge |
| `reta.py` | 214 | 19 | 1 | 3 | teilweise nativ | `src/reta_native_main.mojo + src/reta_mojo/native_reta_cli.mojo` | häufige deutsche und englische Tabellenaufrufe nativ; vollständige Legacy-Oberfläche bleibt über RETA_NATIVE=0 kompatibel |
| `retaPrompt.py` | 130 | 10 | 0 | 3 | Python-Referenz/Bridge | `python_reference/retaPrompt.py` | noch nicht nativ portiert |
| `reta_architecture/__init__.py` | 598 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/__init__.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_activation.py` | 600 | 20 | 9 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_activation.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_boundaries.py` | 343 | 20 | 8 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_boundaries.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_coherence.py` | 796 | 19 | 7 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_coherence.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_contracts.py` | 1190 | 43 | 7 | 6 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_contracts.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_impact.py` | 525 | 24 | 8 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_impact.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_map.py` | 1568 | 71 | 7 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_map.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_migration.py` | 661 | 28 | 8 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_migration.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_progress.py` | 839 | 27 | 9 | 1 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_progress.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_rehearsal.py` | 437 | 16 | 8 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_rehearsal.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_traces.py` | 352 | 17 | 7 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_traces.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_validation.py` | 1137 | 29 | 5 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_validation.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_witnesses.py` | 640 | 26 | 8 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_witnesses.py` | noch nicht nativ portiert |
| `reta_architecture/arithmetic.py` | 273 | 19 | 1 | 0 | nativ | `src/reta_mojo/arithmetic.mojo` | arithmetischer Kern; Prozessparallelisierung noch nicht |
| `reta_architecture/category_theory.py` | 1441 | 53 | 8 | 0 | generiert nativ | `src/reta_mojo/category_theory.mojo` | 26 Kategorien, 77 Funktoren, 42 Transformationen |
| `reta_architecture/column_selection.py` | 119 | 7 | 1 | 0 | teilweise nativ | `src/reta_mojo/column_selection.mojo` | 24 typisierte Bucket-Koordinaten und Bucket-Erzeugung; Legacy-Programmbindung noch Bridge |
| `reta_architecture/combi_join.py` | 712 | 12 | 2 | 4 | Python-Referenz/Bridge | `python_reference/reta_architecture/combi_join.py` | noch nicht nativ portiert |
| `reta_architecture/completion_nested.py` | 589 | 37 | 9 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/completion_nested.py` | noch nicht nativ portiert |
| `reta_architecture/completion_runtime.py` | 192 | 8 | 2 | 1 | Python-Referenz/Bridge | `python_reference/reta_architecture/completion_runtime.py` | noch nicht nativ portiert |
| `reta_architecture/completion_word.py` | 265 | 21 | 6 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/completion_word.py` | noch nicht nativ portiert |
| `reta_architecture/concat_csv.py` | 305 | 18 | 2 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/concat_csv.py` | noch nicht nativ portiert |
| `reta_architecture/console_io.py` | 349 | 41 | 6 | 0 | teilweise nativ | `src/reta_mojo/console_io.mojo` | reine Chunk-, Deduplikations-, Whitespace- und Debugformatierung nativ; Terminal-/Rich-I/O bleibt Systemgrenze |
| `reta_architecture/execution_network.py` | 412 | 45 | 11 | 3 | Python-Referenz/Bridge | `python_reference/reta_architecture/execution_network.py` | noch nicht nativ portiert |
| `reta_architecture/facade.py` | 709 | 49 | 1 | 1 | Python-Referenz/Bridge | `python_reference/reta_architecture/facade.py` | noch nicht nativ portiert |
| `reta_architecture/generated_columns.py` | 2010 | 38 | 3 | 0 | teilweise nativ | `src/reta_mojo/generated_columns.mojo` | vier Generatorfamilien zweisprachig nativ; restliche Generator- und Metaspalten folgen in Stufe 7 |
| `reta_architecture/input_semantics.py` | 249 | 15 | 4 | 0 | teilweise nativ | `src/reta_mojo/input_semantics.mojo + row_ranges.mojo` | CLI-Normalisierung, Kommasyntax, Polarität, kanonische Spaltenauswahl und schemaabgeleitetes Prompt-Vokabular; dynamischer Prompt-Executor noch Bridge |
| `reta_architecture/meta_columns.py` | 977 | 24 | 2 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/meta_columns.py` | noch nicht nativ portiert |
| `reta_architecture/morphisms.py` | 89 | 13 | 5 | 0 | teilweise nativ | `src/reta_mojo/morphisms.mojo` | Alias-, Bereichs-, Prompt-Split- und Renderer-Modus-Morphismen |
| `reta_architecture/number_theory.py` | 200 | 12 | 1 | 0 | nativ | `src/reta_mojo/number_theory.mojo` | Kernfunktionen vollständig typisiert |
| `reta_architecture/output_semantics.py` | 155 | 13 | 3 | 8 | nativ | `src/reta_mojo/output_modes.mojo` | reine Modusauflösung und vollständige Tabellen-Flaganwendung |
| `reta_architecture/output_syntax.py` | 409 | 13 | 8 | 3 | teilweise nativ | `src/reta_mojo/output_modes.mojo` | statische Syntax und Zeilenfarben |
| `reta_architecture/package_integrity.py` | 232 | 9 | 1 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/package_integrity.py` | noch nicht nativ portiert |
| `reta_architecture/parallel_execution.py` | 1076 | 53 | 6 | 10 | Python-Referenz/Bridge | `python_reference/reta_architecture/parallel_execution.py` | noch nicht nativ portiert |
| `reta_architecture/parameter_runtime.py` | 894 | 11 | 1 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/parameter_runtime.py` | noch nicht nativ portiert |
| `reta_architecture/persistence.py` | 485 | 27 | 3 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/persistence.py` | noch nicht nativ portiert |
| `reta_architecture/presheaves.py` | 150 | 15 | 5 | 0 | teilweise nativ | `src/reta_mojo/presheaves.mojo` | typisierte String-Lokalsektionen und Restriktion |
| `reta_architecture/program_workflow.py` | 379 | 12 | 1 | 4 | Python-Referenz/Bridge | `python_reference/reta_architecture/program_workflow.py` | noch nicht nativ portiert |
| `reta_architecture/prompt_execution.py` | 2516 | 24 | 1 | 3 | Python-Referenz/Bridge | `python_reference/reta_architecture/prompt_execution.py` | noch nicht nativ portiert |
| `reta_architecture/prompt_interaction.py` | 273 | 15 | 1 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/prompt_interaction.py` | noch nicht nativ portiert |
| `reta_architecture/prompt_language.py` | 492 | 23 | 2 | 2 | Python-Referenz/Bridge | `python_reference/reta_architecture/prompt_language.py` | noch nicht nativ portiert |
| `reta_architecture/prompt_preparation.py` | 462 | 14 | 1 | 4 | Python-Referenz/Bridge | `python_reference/reta_architecture/prompt_preparation.py` | noch nicht nativ portiert |
| `reta_architecture/prompt_runtime.py` | 158 | 9 | 4 | 1 | Python-Referenz/Bridge | `python_reference/reta_architecture/prompt_runtime.py` | noch nicht nativ portiert |
| `reta_architecture/prompt_session.py` | 543 | 37 | 8 | 1 | Python-Referenz/Bridge | `python_reference/reta_architecture/prompt_session.py` | noch nicht nativ portiert |
| `reta_architecture/row_filtering.py` | 714 | 13 | 1 | 5 | nativ | `src/reta_mojo/row_filtering.mojo` | Zeilenbereiche, Zeit, Zählgruppen, Primklassen, Gestirne, Vielfache, Potenzen, Invertierung und Positionsfilter |
| `reta_architecture/row_ranges.py` | 329 | 26 | 1 | 1 | nativ | `src/reta_mojo/row_ranges.mojo` | legitime Bereichssyntax; eval bewusst entfernt |
| `reta_architecture/runtime_compat.py` | 189 | 23 | 1 | 0 | teilweise nativ | `src/reta_mojo/runtime_compat.mojo + arithmetic.mojo` | Enums, fill_both und deterministische Arithmetik nativ; dynamische Python-Kompatibilität bleibt Bridge |
| `reta_architecture/schema.py` | 186 | 10 | 2 | 12 | generiert nativ | `src/reta_mojo/schema.mojo + schema_catalog.mojo` | 33 Hauptgruppen, 431 Parametereinträge und Kontext-Mappings als besitzender Snapshot |
| `reta_architecture/semantics_builder.py` | 267 | 6 | 2 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/semantics_builder.py` | noch nicht nativ portiert |
| `reta_architecture/sheaves.py` | 269 | 22 | 5 | 4 | teilweise nativ | `src/reta_mojo/parameter_semantics.mojo` | ParameterSemanticsSheaf: Aliasauflösung, kanonische Paare, direkte Spalten und Rückabbildung |
| `reta_architecture/split_i18n.py` | 33 | 1 | 0 | 3 | Python-Referenz/Bridge | `python_reference/reta_architecture/split_i18n.py` | noch nicht nativ portiert |
| `reta_architecture/table_adapters.py` | 419 | 60 | 2 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/table_adapters.py` | noch nicht nativ portiert |
| `reta_architecture/table_generation.py` | 298 | 8 | 2 | 2 | teilweise nativ | `src/reta_mojo/csv_table.mojo + native_reta_cli.mojo` | CSV-Grundtabelle, Spaltenprojektion und einfacher Ende-zu-Ende-Tabellenpfad nativ |
| `reta_architecture/table_output.py` | 769 | 24 | 3 | 2 | teilweise nativ | `src/reta_mojo/table_rendering.mojo` | CSV, Markdown und Emacs für den nativen Tabellenpfad bytegleich; komplexes HTML/BBCode-Wrapping noch unvollständig |
| `reta_architecture/table_preparation.py` | 475 | 19 | 3 | 1 | teilweise nativ | `src/reta_mojo/table_preparation.mojo` | positive/negative Zeilenauswahl, Headerbehandlung und Tabellenprojektion nativ |
| `reta_architecture/table_runtime.py` | 310 | 42 | 4 | 2 | teilweise nativ | `src/reta_mojo/native_reta_cli.mojo + table_preparation.mojo` | typisierter nativer Laufzeitplan für häufige Zeilen-, Spalten- und Ausgabeparameter |
| `reta_architecture/table_state.py` | 137 | 8 | 4 | 1 | nativ | `src/reta_mojo/table_state.mojo` | typisierter Tabellenzustand, Abschnittsnamen und Zeilengrenzen |
| `reta_architecture/table_wrapping.py` | 200 | 16 | 3 | 1 | teilweise nativ | `src/reta_mojo/table_wrapping.mojo` | Unicode-sicherer harter Umbruch und Breitenlogik nativ; Wörterbuchtrennung bleibt externe Grenze |
| `reta_architecture/tag_schema.py` | 694 | 5 | 2 | 0 | generiert nativ | `src/reta_mojo/tag_schema.mojo + tag_schema_catalog.mojo` | Primär- und Kombi-Tag-Schemata mit Vorwärts-/Rückabbildung |
| `reta_architecture/topology.py` | 230 | 15 | 3 | 1 | nativ | `src/reta_mojo/topology.mojo` | symbolische Auswahl, Verfeinerung, Aliasauflösung |
| `reta_architecture/universal.py` | 132 | 8 | 1 | 0 | teilweise nativ | `src/reta_mojo/universal.mojo` | Normalisierung positiver/negativer Spalten-Buckets |
| `reta_architecture_probe_py.py` | 440 | 4 | 0 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture_probe_py.py` | noch nicht nativ portiert |
| `reta_domain_probe_py.py` | 408 | 17 | 0 | 0 | Python-Referenz/Bridge | `python_reference/reta_domain_probe_py.py` | noch nicht nativ portiert |
| `reta_extract_html_classes.py` | 125 | 7 | 0 | 0 | Python-Referenz/Bridge | `python_reference/reta_extract_html_classes.py` | noch nicht nativ portiert |
| `setup.py` | 113 | 8 | 5 | 0 | Python-Referenz/Bridge | `python_reference/setup.py` | noch nicht nativ portiert |
| `tests/__init__.py` | 0 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/tests/__init__.py` | noch nicht nativ portiert |
| `tests/test_architecture_refactor.py` | 1804 | 80 | 2 | 0 | Python-Referenz/Bridge | `python_reference/tests/test_architecture_refactor.py` | noch nicht nativ portiert |
| `tests/test_command_parity.py` | 298 | 11 | 1 | 0 | Python-Referenz/Bridge | `python_reference/tests/test_command_parity.py` | noch nicht nativ portiert |
| `tests/test_py_reta_truth_matrix.py` | 20 | 3 | 0 | 0 | Python-Referenz/Bridge | `python_reference/tests/test_py_reta_truth_matrix.py` | noch nicht nativ portiert |
| `tests/test_py_reta_truth_output_invariants.py` | 35 | 4 | 0 | 0 | Python-Referenz/Bridge | `python_reference/tests/test_py_reta_truth_output_invariants.py` | noch nicht nativ portiert |
