# Portierungsmatrix Python → Mojo

Stand: 1. Juli 2026. Die Matrix unterscheidet echten nativen Mojo-Code von der gebündelten Python-Kompatibilitätsreferenz.

- Ursprüngliche Python-Dateien: **92**
- Ursprüngliche Python-Zeilen insgesamt: **48831**
- Eingebettete Python-Brücken: **0**; expliziter Mojo-Kindprozessadapter: **1**
- Quellzeilen der bereits angegriffenen Architekturmodule: **22387**
- Native Mojo-Quellzeilen: siehe `src/` (inklusive generiertem Kategoriekatalog)

| Python-Datei | Zeilen | Funktionen | Klassen | dynamische Aufrufe | Status | Mojo/Ziel | Anmerkung |
|---|---:|---:|---:|---:|---|---|---|
| `bbcode.py` | 9 | 2 | 1 | 0 | nativ | `src/reta_mojo/compat_text.mojo` | identische Text-Fallbacksemantik ohne Python-Abhängigkeit |
| `grundStrukHtml.py` | 232 | 5 | 0 | 0 | generiert nativ | `src/reta_mojo/grundstrukturen_html.mojo + grundstrukturen_catalog.mojo` | Renderer vollständig nativ; lokalisierter wahl15-Katalog reproduzierbar generiert und bytegleich |
| `generate_html` | 8 | 0 | 0 | 1 | nativ | `src/generate_html_main.mojo + reta_mojo/all_columns.mojo` | zwölfteiliger `--alles`-Plan und vollständige Seitenkomposition ohne Python-/Subprozessbrücke |
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
| `libs/nestedAlx.py` | 24 | 0 | 0 | 0 | nativ | `src/reta_mojo/completion_nested.mojo` | historische Fassade, Bootstrap und Morphismusvertrag vollständig nativ |
| `libs/tableHandling.py` | 68 | 0 | 0 | 0 | teilweise nativ | `src/reta_mojo/table_state.mojo + table_wrapping.mojo + output_modes.mojo` | deterministischer Tabellenzustand, Umbruch und Ausgabemodi; große Tabellenberechnung noch Bridge |
| `libs/word_completerAlx.py` | 10 | 0 | 0 | 0 | nativ | `src/reta_mojo/completion_word.mojo` | historische `WordCompleter`-Fassade durch typisierten Stage-40-Morphismus ersetzt |
| `mojo_bridge.py` | 394 | 19 | 0 | 0 | Python-Referenz/Bridge | `python_reference/mojo_bridge.py` | noch nicht nativ portiert |
| `multis.py` | 34 | 2 | 0 | 0 | nativ | `src/reta_mojo/arithmetic.mojo + prompt_runtime.mojo` | Faktorpaare und öffentliche multis-CLI nativ |
| `multis3.py` | 34 | 1 | 0 | 0 | nativ | `src/reta_mojo/arithmetic.mojo + prompt_runtime.mojo` | Dreifach-Faktorisierung nativ; deterministische lexikographische Ausgabe statt Set-Reihenfolge |
| `reta.py` | 214 | 19 | 1 | 3 | teilweise nativ | `src/reta_native_main.mojo + src/reta_mojo/native_reta_cli.mojo` | häufige deutsche und englische Tabellenaufrufe nativ; vollständige Legacy-Oberfläche bleibt über RETA_NATIVE=0 kompatibel |
| `retaPrompt.py` | 130 | 10 | 0 | 3 | weitgehend nativ | `src/prompt_main.mojo + reta_mojo/prompt_runtime.mojo + terminal_geometry.mojo + native_prompt_input.mojo` | Controller, One-shots, Sitzungszustand, Befehls-/Tabellenframing, dynamische TTY-Breite, Pipe-/Skript- und echter TTY-Editor nativ; Restfallbacks starten direkt am Mojo-Kindprozessadapter, ohne eingebettetes CPython |
| `reta_architecture/__init__.py` | 598 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/__init__.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_activation.py` | 600 | 20 | 9 | 0 | generiert nativ | `src/reta_mojo/architecture_activation.mojo + tools/generate_architecture_activation.py` | 7 Fenster, 34 Units, 34 Commit-Gates, 34 Rollbacks und 7 Transaktionen; Referenz- und native Kreuzvalidierung passed |
| `reta_architecture/architecture_boundaries.py` | 343 | 20 | 8 | 0 | generiert nativ | `src/reta_mojo/architecture_boundaries.mojo + tools/generate_architecture_boundaries.py` | 161 Modulbesitzer, 279 Importkanten, 37 Kapselkanten und 11 Grenzobjekte |
| `reta_architecture/architecture_coherence.py` | 796 | 19 | 7 | 0 | generiert nativ | `src/reta_mojo/architecture_coherence.mojo + tools/generate_architecture_coherence.py` | 11 Kapselkohärenzen, 53 Routen, 42 Natürlichkeits- und 22 Gesetzeskohärenzen |
| `reta_architecture/architecture_contracts.py` | 1190 | 43 | 7 | 6 | generiert nativ | `src/reta_mojo/architecture_contracts.mojo + tools/generate_architecture_contracts.py` | 33 kommutierende Diagramme, 11 Kapselverträge und 22 Gesetze |
| `reta_architecture/architecture_impact.py` | 525 | 24 | 8 | 0 | generiert nativ | `src/reta_mojo/architecture_impact.mojo + tools/generate_architecture_impact.py` | 34 Impact-Quellen, 34 Verträge, 10 Gates und 34 Migrationskandidaten; Validierung passed |
| `reta_architecture/architecture_map.py` | 1568 | 71 | 7 | 0 | generiert nativ | `src/reta_mojo/architecture_map.mojo + tools/generate_architecture_map.py` | 11 Kapseln, 34 Einschließungen, 53 Flüsse, 34 Legacy-Zuordnungen und 42 Stufenschritte |
| `reta_architecture/architecture_migration.py` | 661 | 28 | 8 | 0 | generiert nativ | `src/reta_mojo/architecture_migration.mojo + tools/generate_architecture_migration.py` | 7 Wellen, 34 Schritte, 34 Gate-Bindungen und 7 Invarianten; Validierung passed |
| `reta_architecture/architecture_progress.py` | 839 | 27 | 9 | 1 | generiert nativ | `src/reta_mojo/architecture_progress.mojo + tools/generate_architecture_progress.py` | 30 Oberflächen, 34 Schritte, 7 Wellen und ein dokumentierter Umweltblock; native Kreuzvalidierung konsistent |
| `reta_architecture/architecture_rehearsal.py` | 437 | 16 | 8 | 0 | generiert nativ | `src/reta_mojo/architecture_rehearsal.mojo + tools/generate_architecture_rehearsal.py` | 7 Öffnungen, 34 Moves, 34 Gate-Suiten und 7 Cover; Referenz- und native Kreuzvalidierung passed |
| `reta_architecture/architecture_traces.py` | 352 | 17 | 7 | 0 | generiert nativ | `src/reta_mojo/architecture_traces.mojo + tools/generate_architecture_traces.py` | 34 Komponenten-, 11 Kapsel- und 42 Stufentraces mit 204 Route-Hops |
| `reta_architecture/architecture_validation.py` | 1137 | 29 | 5 | 0 | generiert nativ | `src/reta_mojo/architecture_validation.mojo + tools/generate_architecture_validation.py` | 51 Checks, 17 Schichten und 3.448 geprüfte Objekte; Referenz- und native Kreuzvalidierung passed |
| `reta_architecture/architecture_witnesses.py` | 640 | 26 | 8 | 0 | generiert nativ | `src/reta_mojo/architecture_witnesses.mojo + tools/generate_architecture_witnesses.py` | 536 Anker, 11 Kapselschnitte, 33 Diagramm-, 42 Natürlichkeits-Witnesses und 55 Verpflichtungen |
| `reta_architecture/arithmetic.py` | 273 | 19 | 1 | 0 | nativ | `src/reta_mojo/arithmetic.mojo + parallel_execution.mojo` | arithmetischer Kern sowie typisierte Thread-Chunkausführung für Primfaktoren und Faktorpaare nativ |
| `reta_architecture/category_theory.py` | 1441 | 53 | 8 | 0 | generiert nativ | `src/reta_mojo/category_theory.mojo` | 26 Kategorien, 77 Funktoren, 42 Transformationen |
| `reta_architecture/column_selection.py` | 119 | 7 | 1 | 0 | teilweise nativ | `src/reta_mojo/column_selection.mojo` | 24 typisierte Bucket-Koordinaten und Bucket-Erzeugung; Legacy-Programmbindung noch Bridge |
| `reta_architecture/combi_join.py` | 712 | 12 | 2 | 4 | Python-Referenz/Bridge | `python_reference/reta_architecture/combi_join.py` | noch nicht nativ portiert |
| `reta_architecture/completion_nested.py` | 589 | 37 | 9 | 0 | nativ | `src/reta_mojo/completion_nested.mojo` | vollständige hierarchische Zustandsmaschine, Unicode-Fuzzy-Suche, Näheordnung, Kommafragmente, Snapshots und produktive Editorintegration |
| `reta_architecture/completion_runtime.py` | 192 | 8 | 2 | 1 | generiert nativ | `src/reta_mojo/completion_runtime.mojo + assets/prompt_nested_completion.tsv + scripts/generate_prompt_nested_catalog.py` | besitzender Laufzeitbundle, Sektionen, Startbefehle, Kontextindizes und Snapshots ohne Python-Objektgraph |
| `reta_architecture/completion_word.py` | 265 | 21 | 6 | 0 | nativ | `src/reta_mojo/completion_word.mojo` | Wortgrenzen, Präfix-/Middle-Match, Unicode-Startpositionen, besitzender Completer, erneuerbare Quellen, Muster-Präfixadapter, Snapshot und Dekorationen nativ; aktueller prompt_toolkit-Unicode-Istzustand bewusst konserviert |
| `reta_architecture/concat_csv.py` | 305 | 18 | 2 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/concat_csv.py` | noch nicht nativ portiert |
| `reta_architecture/console_io.py` | 349 | 41 | 6 | 0 | weitgehend nativ | `src/reta_mojo/console_io.mojo + terminal_geometry.mojo` | Chunk-, Deduplikations-, Whitespace-, Debugformatierung und reale TTY-Geometrie nativ; Rich-Eingabe/Styling bleibt Systemgrenze |
| `reta_architecture/execution_network.py` | 412 | 45 | 11 | 3 | nativ | `src/reta_mojo/execution_network.mojo + src/architecture_execution_network_main.mojo` | typisierte FIFO-/LIFO-/Prioritätsplanung, Kanal-/Semaphorgrenzen, native Mojo-Threads und deterministische Reduktion; 0 POSIX-Prozessprimitive; Nutzlastgrenze ist UTF-8-Text mit expliziter Operationskennung |
| `reta_architecture/facade.py` | 709 | 49 | 1 | 1 | Python-Referenz/Bridge | `python_reference/reta_architecture/facade.py` | noch nicht nativ portiert |
| `reta_architecture/generated_columns.py` | 2010 | 38 | 3 | 0 | teilweise nativ | `src/reta_mojo/generated_columns.mojo` | vier Generatorfamilien zweisprachig nativ; restliche Generator- und Metaspalten folgen in Stufe 7 |
| `reta_architecture/input_semantics.py` | 249 | 15 | 4 | 0 | teilweise nativ | `src/reta_mojo/input_semantics.mojo + row_ranges.mojo` | CLI-Normalisierung, Kommasyntax, Polarität, kanonische Spaltenauswahl und schemaabgeleitetes Prompt-Vokabular; dynamischer Prompt-Executor noch Bridge |
| `reta_architecture/meta_columns.py` | 977 | 24 | 2 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/meta_columns.py` | noch nicht nativ portiert |
| `reta_architecture/morphisms.py` | 89 | 13 | 5 | 0 | teilweise nativ | `src/reta_mojo/morphisms.mojo` | Alias-, Bereichs-, Prompt-Split- und Renderer-Modus-Morphismen |
| `reta_architecture/number_theory.py` | 200 | 12 | 1 | 0 | nativ | `src/reta_mojo/number_theory.mojo` | Kernfunktionen vollständig typisiert |
| `reta_architecture/output_semantics.py` | 155 | 13 | 3 | 8 | nativ | `src/reta_mojo/output_modes.mojo` | reine Modusauflösung und vollständige Tabellen-Flaganwendung |
| `reta_architecture/output_syntax.py` | 409 | 13 | 8 | 3 | teilweise nativ | `src/reta_mojo/output_modes.mojo` | statische Syntax und Zeilenfarben |
| `reta_architecture/package_integrity.py` | 232 | 9 | 1 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/package_integrity.py` | noch nicht nativ portiert |
| `reta_architecture/parallel_execution.py` | 1076 | 53 | 6 | 10 | nativ | `src/reta_mojo/parallel_execution.mojo + parallel_row_preparation.mojo + beide Parallel-CLIs` | zehn reine Tabellen-/Zahlenkerne verwenden typisierte Mojo-Thread-Chunks; historische Prozessoptionen sind Alias; der dynamische WorkerPrepare/deepcopy-Pfad ist durch einen besitzenden typisierten Zeilenkontext ersetzt |
| `reta_architecture/parameter_runtime.py` | 894 | 11 | 1 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/parameter_runtime.py` | noch nicht nativ portiert |
| `reta_architecture/persistence.py` | 485 | 27 | 3 | 0 | nativ | `src/reta_mojo/persistence.mojo + src/architecture_persistence_main.mojo` | SQLite-Schema, stabile SHA-256-Digests, Sections, Garben-Snapshots, Runs, Audit, Cache und Batch-Schreibpfade nativ; JSON-Grenze ist kanonischer UTF-8-Text |
| `reta_architecture/presheaves.py` | 150 | 15 | 5 | 0 | teilweise nativ | `src/reta_mojo/presheaves.mojo` | typisierte String-Lokalsektionen und Restriktion |
| `reta_architecture/program_workflow.py` | 379 | 12 | 1 | 4 | Python-Referenz/Bridge | `python_reference/reta_architecture/program_workflow.py` | noch nicht nativ portiert |
| `reta_architecture/prompt_execution.py` | 2516 | 24 | 1 | 3 | weitgehend nativ | `src/reta_mojo/prompt_* + prompt_main.mojo` | zentrale Kurzsprache, Tabellenplanung, numerische Fachbefehle, One-shots sowie `shell`/`python`/`math` nativ; gemischte `vielfache + teiler + 1/n`-Pläne, klassische Bruch-No-ops und gemischte Bruch-/Ganzzahl-Kommatokens bytegenau nativ; Restfallbacktransport und nicht-native `reta`-Zeilen direkt aus Mojo gestartet; echte v-n/m-Restalgorithmen offen |
| `reta_architecture/prompt_interaction.py` | 273 | 15 | 1 | 0 | teilweise nativ | `src/reta_mojo/native_prompt_input.mojo + prompt_line_editor.mojo + prompt_terminal_input.mojo + prompt_main.mojo` | reale Pipe-/TTY-Eingabe, UTF-8-Editor, History, verschachtelte Completion, Mehrzeilen-Wrapping sowie Emacs-/Vi-Kernbindings nativ; hintere dynamische Sitzungs-/Speicherzweige bleiben Referenz/Fallback |
| `reta_architecture/prompt_language.py` | 492 | 23 | 2 | 2 | weitgehend nativ | `src/reta_mojo/prompt_language.mojo + prompt_external_commands.mojo` | kompakte Sprache, Rohbefehlserkennung und UTF-8-sicherer Shell-Parser nativ; Rest-i18n offen |
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
| `reta_architecture/table_output.py` | 769 | 24 | 3 | 2 | weitgehend nativ | `src/reta_mojo/table_rendering.mojo + terminal_geometry.mojo` | CSV/Markdown/Emacs sowie zentrale HTML/BBCode/ANSI-Pfade nativ; individuelle positive und nullhaltige Spaltenbreiten sind formatübergreifend nativ; `--breite=0`, formatübergreifendes `oneTable` und `keineleereninhalte` nativ; Emacs-Primzahlpotenztrenner sowie paginierte Bindestrichtrennung und Shell-Restfarben bytegleich; nur seltene Rich-Sonderfälle außerhalb der Kernpfade offen |
| `reta_architecture/table_preparation.py` | 475 | 19 | 3 | 1 | weitgehend nativ | `src/reta_mojo/table_preparation.mojo + parallel_row_preparation.mojo` | Zeilenauswahl, Tabellenprojektion, Unicode-sicherer Zellenumbruch und typisierte serielle/threadbasierte Vorbereitung unabhängiger Datenzeilen nativ; globale Header-Tag-Mutation bleibt bewusst seriell |
| `reta_architecture/table_runtime.py` | 310 | 42 | 4 | 2 | teilweise nativ | `src/reta_mojo/native_reta_cli.mojo + table_preparation.mojo` | typisierter nativer Laufzeitplan für häufige Zeilen-, Spalten- und Ausgabeparameter einschließlich formatübergreifender Einzelspaltenbreiten-, `oneTable`-, `justtext`- und `keineleereninhalte`-Semantik |
| `reta_architecture/table_state.py` | 137 | 8 | 4 | 1 | nativ | `src/reta_mojo/table_state.mojo` | typisierter Tabellenzustand, Abschnittsnamen und Zeilengrenzen |
| `reta_architecture/table_wrapping.py` | 200 | 16 | 3 | 1 | teilweise nativ | `src/reta_mojo/table_wrapping.mojo` | Unicode-sicherer harter Umbruch, vorhandene Bindestrichtrennung und Breitenlogik nativ; echte Wörterbuchtrennung ohne vorhandenen Bindestrich bleibt externe Grenze |
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


## Stage 12c4l – Breiten- und Rohmarkupbesitz

| Oberfläche | positive `breiten/widths` | Nullwert in Liste | `nocolor`-Markup |
|---|---:|---:|---:|
| Shell | nativ | nativ | nativ |
| HTML | nativ | nativ | nativ |
| BBCode | nativ | nativ | nativ |
| CSV | Referenzfallback | Referenzfallback | – |
| Markdown | Referenzfallback | Referenzfallback | – |
| Emacs | Referenzfallback | Referenzfallback | – |

Der Ownership-Prüfer entscheidet über den vollständigen Argumentvektor; es gibt
keinen gemischten Teilpfad. Positive und explizite Nullbreiten benutzen denselben
typisierten Breitenplan. HTML/BBCode wählen anhand von `color_rows` zwischen
Rich-kompatibel normalisierter Serialisierung und dem rohen `print`-Vertrag;
beide Pfade bleiben vollständig im nativen Renderer.


## Stage 12c4m – Ressourcen- und Installationsbesitz

| Ressource/Oberfläche | Quellbaum | `/usr/local` manuell | `/usr` Paket | Override |
|---|---|---|---|---|
| CSV-Kataloge | `python_reference/csv` | `/usr/local/share/reta/csv` | `/usr/share/reta/csv` | `RETA_DATA_DIR` |
| HTML-/TSV-Assets | `assets` | `/usr/local/share/reta/assets` | `/usr/share/reta/assets` | `RETA_ASSET_DIR` |
| Python-Referenz | `python_reference` | `/usr/local/lib/reta/python_reference` | `/usr/lib/reta/python_reference` | `RETA_REFERENCE_DIR` |
| Mojo-ELF-Ziele | `target/bin` | `/usr/local/lib/reta/target/bin` | `/usr/lib/reta/target/bin` | – |
| Mojo-Runtime | `target/lib/mojo` | `/usr/local/lib/reta/target/lib/mojo` | `/usr/lib/reta/target/lib/mojo` | `RETA_MOJO_RUNTIME_LIBDIR` |

`src/reta_mojo/resource_paths.mojo` besitzt die Pfadentscheidung für alle
nativen CSV- und Assetleser. Es wird kein absoluter Quell-, Build- oder
Installationspfad einkompiliert. `bin/mojo-runtime-exec` setzt die passenden
Wurzeln für Quellbaum und installierte FHS-Struktur; explizite Overrides haben
Vorrang. Die historischen Pfade `python_reference/csv` und `assets` bleiben in
der privaten Installation als relative Symlinks erhalten, sodass native und
noch nicht portierte Referenzpfade dieselben physischen Daten benutzen.


## Stage 12c4n – vollständiger `--alles`-HTMLbesitz

| Teilpfad | Referenz | Native Umsetzung |
|---|---:|---:|
| sichtbare Volltabellenspalten | 807 | 807 |
| Daten-/Generatorspalten | 805 | 805 |
| ungültige Bruchkoordinaten | verworfen | verworfen |
| HTML-Metadatenkatalog | 1.626 semantische Einträge | reproduzierbar geladen |
| Deutsch, eine Datenzeile | 301.206 Byte | bytegleich |
| Englisch, eine Datenzeile | 295.215 Byte | bytegleich |

`fraction_concat_columns.mojo` validiert gebrochen-rationale Anforderungen an
der tatsächlichen CSV-Form. `generated_table_columns.mojo` stellt die
historische Reihenfolge einschließlich `PrimCSV` wieder her.
`html_cell_metadata.mojo` kombiniert semantische Überschriftenidentitäten mit
der exakten 805-Spalten-Referenzposition, sobald die vollständige Ansicht
gerendert wird. Mond- und Kombinationszellen behalten ihre beabsichtigten
HTML-Listenstrukturen.


## Stage 12c4o – formatübergreifender Breitenbesitz

| Oberfläche | positive `breiten/widths` | Nullwert in Liste | physische Fortsetzungszeilen |
|---|---:|---:|---:|
| Shell | nativ | nativ | nativ |
| HTML | nativ | nativ | nativ |
| BBCode | nativ | nativ | nativ |
| CSV | nativ | nativ | nativ |
| Markdown | nativ | nativ | nativ |
| Emacs/Org | nativ | nativ | nativ |

Der flache Renderer erzwingt weiterhin globale Breite null, wertet eine
ausdrückliche Breitenliste aber pro Datenspalte aus. Zählgruppen werden auf
Fortsetzungszeilen wiederholt, Quellzeilennummern nicht. Markdown-/Emacs-
Überschriftentrenner und Emacs-Primzahlpotenztrenner folgen jeder physischen
Sichtzeile. CSV besitzt zusätzlich den exakten historischen Leerfeld-,
Randwhitespace- und unnummerierten `;;`-Strukturvertrag. Der native Ownership-Prüfer akzeptiert diese Vektoren
atomar; unbekannte Optionen bleiben Ganzvektor-Fallback.

## Stage 12c4p – Ganzzahlausdrücke und Generatorbereiche

| Syntax | Native Ownership |
|---|---:|
| Ganzzahlliterale und `+ - * // % **` | ja |
| Listen-/Mengen-/Tupelanzeige | ja |
| eine Variable über `range(…)` | ja |
| additive/subtraktive Zeilenauswahl | ja |
| Generator in Spaltenreihenfolge | ja |
| `/`, beliebige Aufrufe/Importe/Attribute | atomarer Fallback |
| bedingte oder verschachtelte Comprehension | atomarer Fallback |

Der Ownership-Prüfer validiert die vollständige Ausdrucksgrammatik, bevor der
native Tabellenkern gestartet wird. Damit kann kein formal erkannter, aber
semantisch ignorierter Generatorbereich mehr eine stille Teilmenge ausgeben.

## Stage 12c4q – Start-, Sprach- und Hilfeoberfläche

| Oberfläche | Native Ownership | Datenquelle |
|---|---:|---|
| leerer Aufruf | ja | typisierte Konstante |
| `-language=english/german/deutsch` allein | ja | Startklassifikation |
| deutsche `-h`/`-help` | ja | `assets/reta_help_de.txt` |
| englische `-h`/`-help` | ja | `assets/reta_help_en.txt` |
| mehrfache Hilfe | ja | Wiederholung des exakten Assets |
| unbekannte Sprache/gemischte unbekannte Tokens | atomarer Fallback | Python-Referenz |
| Hauptparameter ohne Nebenoption | kein Tabellenbesitz | Referenz/Leerlaufvertrag |

Die Hilfetexte sind reproduzierbar generierte Laufzeitressourcen, keine
handgepflegten Mojo-Stringkopien. Dadurch bleibt die Ausgabe bytegenau, ohne den
großen Text in jedes importierende Executable einzubetten.

## Stage 12c4r – Defektbesitz und Bruchvielfachengrenze

| Oberfläche | Python-/PyPy3-Original | Mojo 12c4r | spätere Aktion |
|---|---|---|---|
| `universum v2/3` | `IndexError` in `zeiln1234create` | natives 10×7-Bruchraster plus Ganzzahl-, Reziprok- und Gleichheitsprojektion | Python auf denselben Vertrag umstellen |
| `emotion v2/3` | derselbe Fehlerpfad | Zähler 2,4,6,8; Nenner 3,6 | Python domänenspezifisch begrenzen |
| `groesse v2/3` | derselbe Fehlerpfad | Zähler 2…16; Nenner 3…15 | Python domänenspezifisch begrenzen |
| `motive v2/3` | derselbe Fehlerpfad | Zähler 2…22; Nenner 3…21 | Python domänenspezifisch begrenzen |
| mehrere Bruchdomänen | undefiniert/fehleranfällig | atomarer Fallback | gemeinsamen Domänenvertrag festlegen |
| `1/n` und echtes `n/m` gemeinsam | verschiedene historische Obergrenzen | atomarer Fallback | explizite Mischsemantik festlegen |
| Fehlerdokumentation | über Stage-Dateien verteilt | zentral in JSON + generiertem Markdown | nach Portabschluss offene Python-Einträge abarbeiten |

## Stage 12c4s – Kontrolloberfläche und Fehlerbesitz

| Teiloberfläche | Python-Vertrag | Mojo 12c4s | Status |
|---|---|---|---|
| `-debug` | einmaliger lokalisierter Präfix vor weiterer Ausgabe | nativ, bytegleich | abgeschlossen |
| `-nichts`/`-nothing` allein | leerer Stream | nativ, leer | abgeschlossen |
| `-nichts` in echter Tabelle | Hauptparameter wird ignoriert, normale Ausgabe | nativ, keine Verwechslung mit `--art=nichts` | abgeschlossen |
| `--art=nichts`/`--type=nothing` | stiller Renderer | bestehender nativer Modus | abgeschlossen |
| bekannte Python-Originalfehler | zuvor über Dokumente verteilt | 35-Einträge-Gesamtkatalog, 12-Punkte-Backlog | abgeschlossen |
| Python-Baseline | 67 grün, 3 bekannte rote Tests | automatisch als genau diese Fehlermenge geprüft | abgeschlossen |
| Mojo-ELF-RUNPATH | Compiler ergänzt absoluten Installationspfad | nach Build ausschließlich `$ORIGIN/../lib/mojo` | abgeschlossen |
| unbekannte oder gemischte Kontrollsyntax | vollständige Python-Semantik | atomarer Originalargument-Fallback | beibehalten |


## Stage 12c4t – native Wortvervollständigung

| Originaldatei | Mojo-Besitz | Verifikation |
|---|---|---|
| `reta_architecture/completion_word.py` | vollständige typisierte Completion-Laufzeit in `src/reta_mojo/completion_word.mojo` | 5/5 Unit-Tests, 10/10 Python↔Mojo byteidentisch |
| `libs/word_completerAlx.py` | historische Fassade durch denselben Morphismusvertrag ersetzt | Metadaten- und Bootstrap-Vertrag im nativen Test |

Damit steigen vollständig native/reproduzierbare Originaldateien auf **35/92 = 38,0 %** und mindestens teilweise portierte Dateien auf **63/92 = 68,5 %**. Der Python-Istzustand der ASCII-/Unicode-Wortgrenze bleibt als `PY-CAND-007` ausdrücklich konserviert, bis Python und Mojo gemeinsam auf eine korrigierte Unicode-Semantik migriert werden.


## Stage 12c4u – native verschachtelte Completion-Besitzer

| Originaldatei | Mojo-Besitz | Verifikation |
|---|---|---|
| `reta_architecture/completion_runtime.py` | `completion_runtime.mojo` plus reproduzierbarer fünfsprachiger TSV-Katalog | 3/3 Runtime-Tests |
| `reta_architecture/completion_nested.py` | `completion_nested.mojo` mit typisierter Zustandsmaschine, Unicode-Fuzzy- und Näheordnung | 5/5 native Tests, 67/67 erweiterte Paritätskontexte |
| `libs/nestedAlx.py` | Fassade im selben nativen Morphismusbundle | Bootstrap-/Snapshot-Vertrag im nativen Test |

Damit steigen vollständig native/reproduzierbare Originaldateien auf **38/92 = 41,3 %**, mindestens teilweise portierte Dateien auf **66/92 = 71,7 %** und der gewichtete Quellzeilenstand auf **ca. 54,2 %**. Der funktionale Nutzerumfang bleibt bei **96–98 %**, weil diese Stage bereits vorhandene Funktionalität in die korrekten nativen Besitzer überführt und deren Randsemantik verbreitert.
