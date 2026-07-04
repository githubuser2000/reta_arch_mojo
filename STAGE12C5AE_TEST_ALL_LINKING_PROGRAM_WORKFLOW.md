# Stage 12c5ae – vollständiger ProgramWorkflow und linkbarer Gesamt-Testlauf

## Ausgangslage

Der lokale `scripts/test_all.sh`-Lauf erreichte die Persistenzintegration, brach
aber beim Linken von `test_execution_network_persistence.mojo` ab. Die Suite
verwendete für alle Testziele denselben allgemeinen Buildbefehl und reichte die
für Persistenz und Paketintegrität erforderlichen Systembibliotheken nicht
weiter. Danach zeigte `scripts/test_stage12c5ad.sh`, dass ein Sternimport die
historischen Unterstrich-Helfer des TableRuntime-Moduls absichtlich nicht
importiert.

## Korrekturen

- `test_execution_network_persistence.mojo` und `test_persistence.mojo` erhalten
  in `test_all.sh` `-lsqlite3 -lcrypto`.
- `test_package_integrity.mojo` erhält `-lcrypto`.
- Alle übrigen Testziele bleiben frei von unnötigen Linkerabhängigkeiten.
- `test_table_runtime_complete.mojo` importiert `_prepare_class`,
  `_concat_class` und `_get_text_wrap_things` explizit statt über `import *`.
- `table_generation.mojo` enthält nur noch eine Deklaration von
  `galaxy_output_columns`.
- `program_workflow_basename` enthält nur noch eine lokale `pieces`-Deklaration.

## Vollständiger nativer ProgramWorkflow-Besitzer

`reta_architecture/program_workflow.py` wird nicht länger nur durch Katalog,
CSV-Helfer und Kombi-Pläne vertreten. `program_workflow.mojo` besitzt nun die
vollständige elf Methoden umfassende Fassadenoberfläche über explizite Typen:

- `ProgramWorkflowI18n`
- `ProgramWorkflowParameterReadResult`
- `ProgramWorkflowBeginResult`
- `ProgramWorkflowExecutionResult`
- `ProgramWorkflowBundle` mit den historischen Methoden
- positive und negative Parameterplanung
- Religionstabellenladen und sprachspezifische Motivspalte
- Anzeigeauswahl und Spaltenkatalog
- Tabellengenerierungsplan und generiertes Ergebnis
- beide Kombi-Verzweigungspläne
- explizite Renderergrenze zu `TableOutput`

Der heterogene Python-`Program`-Objektgraph wird dabei nicht nachgebildet.
Bereits native Besitzer (`parameter_runtime`, `column_selection`,
`row_filtering`, `table_generation`) werden in einem besitzenden Ergebniswert
komponiert.

## Prüfung

Der fokussierte Lauf lautet:

```sh
scripts/test_stage12c5ae.sh
```

Er kompiliert den zuvor gescheiterten TableRuntime-Test, den vollständigen
ProgramWorkflow-Modultest und den diagnostischen Workflow-Main, führt die
Python-Parität aus und prüft Linker-, Import-, Metrik- und Defektverträge.

## Abschlussstand

```text
vollständig nativ/generiert:       77/92 = 83,7 %
vollständig native Referenzzeilen: 33.809/48.831 = 69,2 %
portable Source-Tests:              179 bestanden, 1 Skip
fokussierte Infrastruktur:          67/67 bestanden
relative Mojo-Importe:                 302
Defektkatalog:                         111
Manifest:                             1.420 Dateien, 114 Symlinks
```
