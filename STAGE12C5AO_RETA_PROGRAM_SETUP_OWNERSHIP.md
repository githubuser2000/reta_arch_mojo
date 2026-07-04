# Stage 12c5ao – CsvTable-Besitz, reta.py-Fassade und Setup-Metadaten

## Ausgangspunkt

Der lokale Modular-Lauf von Stage 12c5am bestätigte Build, Architekturprobe,
Domänenprobe, I18n und die vollständige retaPrompt-Fassade. Anschließend brach
der Compiler in `tests/test_generated_columns_integration.mojo` ab:

```text
value of type 'CsvTable' cannot be implicitly copied, it does not conform to 'ImplicitlyCopyable'
```

`CsvTable` ist absichtlich `Copyable`, aber nicht `ImplicitlyCopyable`. Der
Testhelfer und die Integrationsgrenze hatten deshalb eine implizite Kopie
verlangt.

## Korrektur der Besitzgrenze

- `_empty_request` verwendet `table.copy()`.
- `GeneratedColumnsRuntime.apply` kopiert alle geliehenen, nicht implizit
  kopierbaren Requestfelder ausdrücklich, bevor sie an den vorhandenen
  Pipelinebesitzer übergeben werden.
- Der Quellvertrag verhindert eine Rückkehr zu impliziten Besitzkopien.
- Die Algorithmusreihenfolge und die zehn Generatorbesitzer bleiben
  unverändert.

## Historische `reta.py`-Oberfläche

`legacy_reta_program.mojo` und der reproduzierbare Katalog bilden nun alle 27
öffentlichen Modulnamen und 18 `Program`-Methodendefinitionen ab. Ein
`LegacyRetaProgram` besitzt Argumente, Parallelkonfiguration,
`ParameterRuntimePlan`, `ProgramWorkflowBundle`, Ausgabezustand und Ergebnis
explizit.

Bewiesene Argumentvektoren laufen über `native_reta_cli.mojo`. Noch nicht vom
nativen Tabellenkern bewiesene Legacy-Vektoren bleiben als klar markierter
Kindprozessrand erhalten; es gibt keine `std.python`-Einbettung. Daher bleibt
`reta.py` bis zur Schließung dieser letzten semantischen Fälle korrekt als
**teilweise nativ** markiert.

## Historische `setup.py`-Oberfläche

`setup_metadata_catalog.mojo` friert reproduzierbar ein:

- Paketname, Version, Beschreibung und Autor,
- sechs historische Python-Abhängigkeiten,
- vier Paketdatenmuster,
- zwei durch `find_packages` sichtbare Pakete,
- fünf Command-Klassen mit acht Methoden,
- vier definierte, aber im finalen `setup()` nicht aktive Build-Kommandos,
- das aktive `extract_messages`-Kommando,
- sechs gettext-Pythonquellen und das POT-Ziel.

`setup_metadata.mojo` bildet daraus typisierte Command-, Gettext- und
Installationspläne. Die tatsächliche native Installation bleibt beim
FHS-Besitzer `scripts/install.sh` plus `scripts/install_targets.txt`; weder
setuptools noch eine Python-Laufzeit werden benötigt.

## Lokaler Compilerlauf

```sh
./do.sh 12c5ao
```

Der Stage-Test führt zuerst die vollständige 12c5an-Kette aus und bestätigt
damit erneut den zuvor fehlgeschlagenen Generated-Columns-Test. Danach baut er
`test_legacy_reta_program.mojo` und `test_setup_metadata.mojo`.
