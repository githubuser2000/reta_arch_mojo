# Portierungsmatrix Python → Mojo

Stand: 30. Juni 2026. Die Matrix unterscheidet echten nativen Mojo-Code von der gebündelten Python-Kompatibilitätsreferenz.

- Ursprüngliche Python-Dateien: **92**
- Ursprüngliche Python-Zeilen insgesamt: **48831**
- Zusätzlicher Bridge-Adapter: **1 Python-Datei**
- Konservativ mindestens teilweise portierte Originaldateien: **50/92**
- Native Mojo-Quellzeilen unter `src/`: **26764**
- Native Mojo-Quellzeilen: siehe `src/` (inklusive generiertem Kategoriekatalog)

| Python-Datei | Zeilen | Funktionen | Klassen | dynamische Aufrufe | Status | Mojo/Ziel | Anmerkung |
|---|---:|---:|---:|---:|---|---|---|
| `bbcode.py` | 9 | 2 | 1 | 0 | nativ | `src/reta_mojo/compat_text.mojo` | identische Text-Fallbacksemantik ohne Python-Abhängigkeit |
| `grundStrukHtml.py` | 232 | 5 | 0 | 0 | generiert nativ | `src/reta_mojo/grundstrukturen_html.mojo + grundstrukturen_catalog.mojo` | Renderer vollständig nativ; lokalisierter wahl15-Katalog reproduzierbar generiert und bytegleich |
| `html2text.py` | 9 | 2 | 1 | 0 | nativ | `src/reta_mojo/compat_text.mojo` | identische Text-Fallbacksemantik ohne Python-Abhängigkeit |
| `i18n/words.py` | 24 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/i18n/words.py` | noch nicht nativ portiert |
| `i18n/words_bootstrap.py` | 49 | 2 | 0 | 0 | Python-Referenz/Bridge | `python_reference/i18n/words_bootstrap.py` | noch nicht nativ portiert |
| `i18n/words_context.py` | 753 | 1 | 0 | 0 | Python-Referenz/Bridge | `python_reference/i18n/words_context.py` | noch nicht nativ portiert |
| `i18n/words_legacy_monolith.py` | 5431 | 4 | 8 | 0 | teilweise generiert nativ | `assets/prompt_*.tsv + scripts/generate_prompt_nested_catalog.py` | Prompt-relevante Aliase für fünf Sprachen reproduzierbar extrahiert; vollständige i18n-Laufzeit bleibt Referenz |
| `i18n/words_matrix.py` | 4111 | 0 | 0 | 0 | teilweise generiert nativ | `assets/prompt_*.tsv + scripts/generate_prompt_nested_catalog.py` | Prompt-, Hauptparameter-, Zeilen-, Ausgabe- und Kombinationsvokabular als geprüfte Assets; restliche Matrix offen |
| `i18n/words_runtime.py` | 548 | 1 | 8 | 0 | teilweise nativ | `src/reta_mojo/prompt_language.mojo` | Sprachnormalisierung und Promptkatalogzugriff nativ; allgemeine i18n-Objektlaufzeit bleibt Referenz |
| `libs/LibRetaPrompt.py` | 80 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/libs/LibRetaPrompt.py` | noch nicht nativ portiert |
| `libs/center.py` | 333 | 33 | 1 | 0 | Python-Referenz/Bridge | `python_reference/libs/center.py` | noch nicht nativ portiert |
| `libs/generate4readme.py` | 382 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/libs/generate4readme.py` | noch nicht nativ portiert |
| `libs/lib4tables.py` | 59 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/libs/lib4tables.py` | noch nicht nativ portiert |
| `libs/lib4tables_Enum.py` | 37 | 0 | 0 | 0 | generiert nativ | `src/reta_mojo/tag_schema.mojo + tag_schema_catalog.mojo` | sieben Tagarten und vollständige Tabellen-Tag-Zuordnung |
| `libs/lib4tables_concat.py` | 252 | 35 | 1 | 0 | teilweise nativ | `src/reta_mojo/fraction_concat_columns.mojo + kombi_join_columns.mojo` | gebrochen-rationale Verklebung und relationale Kombi-Sektionen nativ; übrige Legacy-Helfer bleiben Referenz |
| `libs/lib4tables_prepare.py` | 313 | 26 | 1 | 0 | teilweise nativ | `src/reta_mojo/table_preparation.mojo + row_filtering.mojo` | deterministische Zeilenauswahl und Vorbereitung nativ; Generatorverkettung noch Bridge |
| `libs/nestedAlx.py` | 24 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/libs/nestedAlx.py` | noch nicht nativ portiert |
| `libs/tableHandling.py` | 68 | 0 | 0 | 0 | teilweise nativ | `src/reta_mojo/table_state.mojo + table_wrapping.mojo + output_modes.mojo` | deterministischer Tabellenzustand, Umbruch und Ausgabemodi; große Tabellenberechnung noch Bridge |
| `libs/word_completerAlx.py` | 10 | 0 | 0 | 0 | weitgehend nativ | `src/reta_mojo/prompt_language.mojo + src/prompt_completion_main.mojo` | Fuzzy- und Kontextkandidaten nativ; GNU Readline bleibt Terminalgrenze |
| `mojo_bridge.py` | 394 | 18 | 0 | 0 | Systemgrenze | `src/prompt_completion_main.mojo + python_reference/mojo_bridge.py` | Python verwaltet Readline, seine Adapter-Pipehälfte und echte Fallbackprozesse; der Mojo-Arbeiter besitzt natives stdin/stdout, native One-shots und Tabellen benötigen keinen Bridgeimport oder Kindprozess |
| `multis.py` | 34 | 2 | 0 | 0 | nativ | `src/reta_mojo/arithmetic.mojo + prompt_runtime.mojo` | Faktorpaare und öffentliche multis-CLI nativ |
| `multis3.py` | 34 | 1 | 0 | 0 | nativ | `src/reta_mojo/arithmetic.mojo + prompt_runtime.mojo` | Dreifach-Faktorisierung nativ; deterministische lexikographische Ausgabe statt Set-Reihenfolge |
| `reta.py` | 214 | 19 | 1 | 3 | teilweise nativ | `src/reta_native_main.mojo + src/reta_mojo/native_reta_cli.mojo` | häufige deutsche und englische Tabellenaufrufe nativ; relative Ergebnis-Spaltenreihenfolge nach Generatoren unterstützt; vollständige Legacy-Oberfläche bleibt über RETA_NATIVE=0 kompatibel |
| `retaPrompt.py` | 130 | 10 | 0 | 3 | weitgehend nativ | `src/prompt_main.mojo + src/reta_mojo/prompt_runtime.mojo + prompt_language.mojo + prompt_legacy_echo.mojo + prompt_property_execution.mojo` | Controller, Sitzungskern, Kurzsprache, Completion, explizite One-shots, sämtliche kompakte Tabellenfamilien, positive reine Zahlen-/Bruch- und 15/16-Katalogkompositionen sowie alle 165 EIGN/EIGR-Eigenschaftsbefehle nativ; Sonderwerte und noch nicht portierte Fachoperationen gehen unverändert an die Bridge |
| `reta_architecture/__init__.py` | 598 | 0 | 0 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/__init__.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_activation.py` | 600 | 20 | 9 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_activation.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_boundaries.py` | 343 | 20 | 8 | 0 | generiert nativ | `src/reta_mojo/architecture_boundaries.mojo + tools/generate_architecture_boundaries.py` | 161 Modulbesitzer, 279 Importkanten, 37 Kapselkanten, 11 Grenzobjekte und fünf Validierungschecks als typisierter Mojo-Snapshot; Python-AST-Scan nur bei expliziter Regeneration |
| `reta_architecture/architecture_coherence.py` | 796 | 19 | 7 | 0 | generiert nativ | `src/reta_mojo/architecture_coherence.mojo + tools/generate_architecture_coherence.py` | 11 Kapselkohärenzen, 53 funktorielle Routen, 42 Natürlichkeits- und 22 Gesetzeskohärenzen; Validierung `passed` |
| `reta_architecture/architecture_contracts.py` | 1190 | 43 | 7 | 6 | generiert nativ | `src/reta_mojo/architecture_contracts.mojo + tools/generate_architecture_contracts.py` | 33 kommutierende Diagramme, 11 Kapselverträge, 22 Gesetze und validierte Kategorie-/Funktor-/Transformationsreferenzen |
| `reta_architecture/architecture_impact.py` | 525 | 24 | 8 | 0 | generiert nativ | `src/reta_mojo/architecture_impact.mojo + tools/generate_architecture_impact.py` | 34 Impact-Quellen, 34 Impact-Verträge, 10 Regression-Gates und 34 Migrationskandidaten; Validierung `passed` |
| `reta_architecture/architecture_map.py` | 1568 | 71 | 7 | 0 | generiert nativ | `src/reta_mojo/architecture_map.mojo + tools/generate_architecture_map.py` | vollständige Stage-42-Karte mit 11 Kapseln, 34 Einschließungen, 53 Flüssen, 34 Legacy-Zuordnungen und 42 Stufenschritten nativ abfragbar |
| `reta_architecture/architecture_migration.py` | 661 | 28 | 8 | 0 | generiert nativ | `src/reta_mojo/architecture_migration.mojo + tools/generate_architecture_migration.py` | 7 geordnete Wellen, 34 Schritte, 34 Gate-Bindungen und 7 Natürlichkeitsinvarianten; Validierung `passed` |
| `reta_architecture/architecture_progress.py` | 839 | 27 | 9 | 1 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_progress.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_rehearsal.py` | 437 | 16 | 8 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_rehearsal.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_traces.py` | 352 | 17 | 7 | 0 | generiert nativ | `src/reta_mojo/architecture_traces.mojo + tools/generate_architecture_traces.py` | 34 Komponenten-, 11 Kapsel- und 42 Stufentraces mit 204 Route-Hops; Validierung `passed` |
| `reta_architecture/architecture_validation.py` | 1137 | 29 | 5 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/architecture_validation.py` | noch nicht nativ portiert |
| `reta_architecture/architecture_witnesses.py` | 640 | 26 | 8 | 0 | generiert nativ | `src/reta_mojo/architecture_witnesses.mojo + tools/generate_architecture_witnesses.py` | 536 Anker, 11 Kapselschnitte, 33 Diagramm-, 42 Natürlichkeits-Witnesses und 55 Verpflichtungen; 351/351 Dateianbindungen aufgelöst |
| `reta_architecture/arithmetic.py` | 273 | 19 | 1 | 0 | nativ | `src/reta_mojo/arithmetic.mojo` | arithmetischer Kern; Prozessparallelisierung noch nicht |
| `reta_architecture/category_theory.py` | 1441 | 53 | 8 | 0 | generiert nativ | `src/reta_mojo/category_theory.mojo` | 26 Kategorien, 77 Funktoren, 42 Transformationen |
| `reta_architecture/column_selection.py` | 119 | 7 | 1 | 0 | teilweise nativ | `src/reta_mojo/column_selection.mojo` | 24 typisierte Bucket-Koordinaten und Bucket-Erzeugung; Legacy-Programmbindung noch Bridge |
| `reta_architecture/combi_join.py` | 712 | 12 | 2 | 4 | weitgehend nativ | `src/reta_mojo/kombi_join_columns.mojo + assets/kombi_aliases.tsv + assets/kombi_relation_order.tsv` | Galaxie-/Universum-Join, 173 Aliase, 151 Relationsordnungen, Negativ- und Mehrfachauswahl nativ |
| `reta_architecture/completion_nested.py` | 589 | 37 | 9 | 0 | weitgehend nativ | `src/reta_mojo/prompt_language.mojo + assets/prompt_nested_completion.tsv` | 28.990 Werte in 549 Kontextsektionen, Klammer-/Kommakontext und fünf Sprachen nativ |
| `reta_architecture/completion_runtime.py` | 192 | 8 | 2 | 1 | weitgehend nativ | `src/prompt_completion_main.mojo + prompt_language.mojo` | persistenter Anfragearbeiter, Kontextauflösung und worker-seitige Pipe-I/O nativ; Readline-Lebenszyklus bleibt Python-Systemgrenze |
| `reta_architecture/completion_word.py` | 265 | 21 | 6 | 0 | weitgehend nativ | `src/reta_mojo/prompt_language.mojo` | prompt_toolkit-artige Fuzzy-Teilsequenzordnung und stabile Kandidatenreihenfolge nativ |
| `reta_architecture/concat_csv.py` | 305 | 18 | 2 | 0 | weitgehend nativ | `src/reta_mojo/fraction_concat_columns.mojo + prime_universe_columns.mojo + assets/fraction_pairs.tsv` | `PrimCSV`, Primuniversum und vier gebrochen-rationale CSV-Prägarben nativ |
| `reta_architecture/console_io.py` | 349 | 41 | 6 | 0 | teilweise nativ | `src/reta_mojo/console_io.mojo` | reine Chunk-, Deduplikations-, Whitespace- und Debugformatierung nativ; Terminal-/Rich-I/O bleibt Systemgrenze |
| `reta_architecture/execution_network.py` | 412 | 45 | 11 | 3 | Python-Referenz/Bridge | `python_reference/reta_architecture/execution_network.py` | noch nicht nativ portiert |
| `reta_architecture/facade.py` | 709 | 49 | 1 | 1 | Python-Referenz/Bridge | `python_reference/reta_architecture/facade.py` | noch nicht nativ portiert |
| `reta_architecture/generated_columns.py` | 2010 | 38 | 3 | 0 | weitgehend nativ | `src/reta_mojo/generated_columns.mojo + generated_table_columns.mojo + prime_cross_columns.mojo + prime_effect_columns.mojo + prime_universe_columns.mojo` | sämtliche katalogisierten Generatorbefehle sowie Modal-, Mond-, Vielfachen-, Klassifikations- und Primuniversumspfade nativ |
| `reta_architecture/input_semantics.py` | 249 | 15 | 4 | 0 | teilweise nativ | `src/reta_mojo/input_semantics.mojo + row_ranges.mojo` | CLI-Normalisierung, Kommasyntax, Polarität, kanonische Spaltenauswahl und schemaabgeleitetes Prompt-Vokabular; dynamischer Prompt-Executor noch Bridge |
| `reta_architecture/meta_columns.py` | 977 | 24 | 2 | 0 | weitgehend nativ | `src/reta_mojo/meta_columns.mojo + prime_universe_columns.mojo + assets/meta_request_order.tsv + assets/fraction_pairs.tsv` | zwölf Meta-/Konkretachsen, 4.095 Teilmengenordnungen und Bruchrelationen nativ; seltene interne Hilfspfade bleiben Referenz |
| `reta_architecture/morphisms.py` | 89 | 13 | 5 | 0 | teilweise nativ | `src/reta_mojo/morphisms.mojo` | Alias-, Bereichs-, Prompt-Split- und Renderer-Modus-Morphismen |
| `reta_architecture/number_theory.py` | 200 | 12 | 1 | 0 | nativ | `src/reta_mojo/number_theory.mojo` | Kernfunktionen vollständig typisiert |
| `reta_architecture/output_semantics.py` | 155 | 13 | 3 | 8 | nativ | `src/reta_mojo/output_modes.mojo` | reine Modusauflösung und vollständige Tabellen-Flaganwendung |
| `reta_architecture/output_syntax.py` | 409 | 13 | 8 | 3 | weitgehend nativ | `src/reta_mojo/output_modes.mojo + table_rendering.mojo + html_cell_metadata.mojo` | Zeilenfarben, BBCode-/HTML-Zellsyntax, physische CSS-Klassen und semantische Generatorüberschriften nativ |
| `reta_architecture/package_integrity.py` | 232 | 9 | 1 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/package_integrity.py` | noch nicht nativ portiert |
| `reta_architecture/parallel_execution.py` | 1076 | 53 | 6 | 10 | Python-Referenz/Bridge | `python_reference/reta_architecture/parallel_execution.py` | noch nicht nativ portiert |
| `reta_architecture/parameter_runtime.py` | 894 | 11 | 1 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/parameter_runtime.py` | noch nicht nativ portiert |
| `reta_architecture/persistence.py` | 485 | 27 | 3 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/persistence.py` | noch nicht nativ portiert |
| `reta_architecture/presheaves.py` | 150 | 15 | 5 | 0 | teilweise nativ | `src/reta_mojo/presheaves.mojo` | typisierte String-Lokalsektionen und Restriktion |
| `reta_architecture/program_workflow.py` | 379 | 12 | 1 | 4 | Python-Referenz/Bridge | `python_reference/reta_architecture/program_workflow.py` | noch nicht nativ portiert |
| `reta_architecture/prompt_execution.py` | 2516 | 24 | 1 | 3 | weitgehend nativ | `src/reta_mojo/prompt_fraction_execution.mojo + prompt_property_execution.mojo + prompt_table_execution.mojo + prompt_runtime.mojo + prompt_main.mojo` | Bruchparser, historische Bruchbereiche, Quotientenachsen, Primfaktorenvergleich, beliebig viele stabile Abstandsbereiche, 18 Domänenfamilien sowie EIGN/EIGR mit 165 Katalogbefehlen, Null-/Negativselektoren, kollidierende All-Zeilen-Ausschlüsse, Bruchteiler, Reziprok-Vielfache, komponierte ganzzahlige Vielfachen-/Teilerpfade mit verschachtelter CPython-Setordnung und wiederholte numerische Katalogauswahlen nativ; echte `v n/m`-Vielfache und weitere Sonderzweige bleiben Bridge |
| `reta_architecture/prompt_interaction.py` | 273 | 15 | 1 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/prompt_interaction.py` | noch nicht nativ portiert |
| `reta_architecture/prompt_language.py` | 492 | 23 | 2 | 2 | weitgehend nativ | `src/reta_mojo/prompt_language.mojo + assets/prompt_*.tsv` | Tokenisierung, Kurzexpansion, Dispatch, Vokabular und verschachtelte Completion nativ |
| `reta_architecture/prompt_preparation.py` | 462 | 14 | 1 | 4 | teilweise nativ | `src/reta_mojo/prompt_language.mojo` | Kurzexpansion, Ein-Zeichen-Ersetzung und finale CPython-Set-Reihenfolge bytegleich; hintere fachliche Vorbereitung offen |
| `reta_architecture/prompt_runtime.py` | 158 | 9 | 4 | 1 | weitgehend nativ | `src/reta_mojo/prompt_runtime.mojo + prompt_table_execution.mojo + prompt_legacy_echo.mojo + prompt_main.mojo` | native Kernbefehle, Profile, `mulpri`, Primfaktorenvergleich, mehrbereichige Abstände mit CPython-Setordnung, kompakte Legacy-Präsentation sowie ganzzahlige und gebrochen-rationale Tabellenpläne; verbleibende Sonderbefehle bleiben Bridge |
| `reta_architecture/prompt_session.py` | 543 | 37 | 8 | 1 | teilweise nativ | `src/reta_mojo/prompt_runtime.mojo + prompt_main.mojo` | Sitzungsspeicher, Profile und zentrale Zustandsübergänge nativ; erweiterte Historien-/Persistenzpfade offen |
| `reta_architecture/row_filtering.py` | 714 | 13 | 1 | 5 | nativ | `src/reta_mojo/row_filtering.mojo` | Zeilenbereiche, Zeit, Zählgruppen, Primklassen, Gestirne, Vielfache, Potenzen, Invertierung und Positionsfilter |
| `reta_architecture/row_ranges.py` | 329 | 26 | 1 | 1 | nativ | `src/reta_mojo/row_ranges.mojo` | legitime Bereichssyntax; eval bewusst entfernt |
| `reta_architecture/runtime_compat.py` | 189 | 23 | 1 | 0 | teilweise nativ | `src/reta_mojo/runtime_compat.mojo + arithmetic.mojo` | Enums, fill_both und deterministische Arithmetik nativ; dynamische Python-Kompatibilität bleibt Bridge |
| `reta_architecture/schema.py` | 186 | 10 | 2 | 12 | generiert nativ | `src/reta_mojo/schema.mojo + schema_catalog.mojo` | 33 Hauptgruppen, 431 Parametereinträge und Kontext-Mappings als besitzender Snapshot |
| `reta_architecture/semantics_builder.py` | 267 | 6 | 2 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/semantics_builder.py` | noch nicht nativ portiert |
| `reta_architecture/sheaves.py` | 269 | 22 | 5 | 4 | teilweise nativ | `src/reta_mojo/parameter_semantics.mojo` | ParameterSemanticsSheaf: Aliasauflösung, kanonische Paare, direkte Spalten und Rückabbildung |
| `reta_architecture/split_i18n.py` | 33 | 1 | 0 | 3 | Python-Referenz/Bridge | `python_reference/reta_architecture/split_i18n.py` | noch nicht nativ portiert |
| `reta_architecture/table_adapters.py` | 419 | 60 | 2 | 0 | Python-Referenz/Bridge | `python_reference/reta_architecture/table_adapters.py` | noch nicht nativ portiert |
| `reta_architecture/table_generation.py` | 298 | 8 | 2 | 2 | teilweise nativ | `src/reta_mojo/csv_table.mojo + native_reta_cli.mojo + generated_table_columns.mojo` | native UTF-8-Dateischicht, CSV-Grundtabelle, Spaltenprojektion und umfangreicher Ende-zu-Ende-Generatorpfad nativ |
| `reta_architecture/table_output.py` | 769 | 24 | 3 | 2 | weitgehend nativ | `src/reta_mojo/table_rendering.mojo + html_cell_metadata.mojo + assets/html_cell_catalog.tsv + assets/html_heading_catalog.tsv` | CSV/Markdown/Emacs, BBCode, zentraler ANSI-Shellpfad und geprüfte HTML-Pfade bytegleich; seltene Rich-/HTML-Kombinationsfälle offen |
| `reta_architecture/table_preparation.py` | 475 | 19 | 3 | 1 | teilweise nativ | `src/reta_mojo/table_preparation.mojo` | positive/negative Zeilenauswahl, Headerbehandlung, Tabellenprojektion und über die physische CSV-Grenze erweiterbare Generatorzeilen nativ |
| `reta_architecture/table_runtime.py` | 310 | 42 | 4 | 2 | teilweise nativ | `src/reta_mojo/native_reta_cli.mojo + table_preparation.mojo` | typisierter nativer Laufzeitplan für häufige Zeilen-, Spalten- und Ausgabeparameter einschließlich dynamischer `max(Auswahl)+1`-Grenzen und Tabellenextension absoluter `vN`-Selektoren |
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
