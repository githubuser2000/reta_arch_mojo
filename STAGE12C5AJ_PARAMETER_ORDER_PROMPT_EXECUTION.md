# Stage 12c5aj – kanonische Parametergarbe und native Prompt-Execution-Fassade

## Lokaler Ausgangsbefund

Der lokale `./do.sh 12c5ai`-Lauf bestätigte zunächst die Reparaturen aus
12c5ai vollständig:

- `test_legacy_table_handling`: 4/4 bestanden,
- `test_meta_columns_complete`: 5/5 bestanden,
- `test_output_semantics_complete`: 3/3 bestanden,
- `test_table_generation_complete`: 4/4 bestanden,
- `test_schema_snapshot`: 1/1 bestanden.

Der anschließende Domänenprobevergleich scheiterte ausschließlich für
`pairs-json religionen`. Python gab die Unterparameter alphabetisch nach ihrem
kanonischen Namen aus; Mojo bewahrte dagegen die Einfügereihenfolge der
Parametermatrix.

## Zentrale Korrektur

Die Abweichung wird nicht im JSON-Renderer versteckt. Stattdessen sortiert
`build_parameter_semantics` nach dem Zusammenführen aller Alias- und
Spalteneinträge beide internen Kataloge kanonisch nach
`(main_canonical, parameter_canonical)`:

- `List[ParameterAliasGroup]`,
- `List[PairColumns]`.

Damit folgen alle Verbraucher demselben Vertrag:

- `params`,
- `pairs`,
- `pairs-json`,
- `main-json`,
- `exact_meta_for_column`,
- Reverse-Metadaten und spätere Architektursnapshots.

Ein eigener Mojo-Test baut die Gruppen absichtlich in der Reihenfolge
`Zeta`, `Alpha`, `Mitte` auf und verlangt anschließend
`Alpha`, `Mitte`, `Zeta`. Der Python/Mojo-Paritätsharness wurde von elf auf
vierzehn Fälle erweitert und prüft nun alle vier unmittelbar betroffenen
Probeoberflächen.

## Weiterer Portierungsschritt

`reta_architecture/prompt_execution.py` war bisher trotz bereits vorhandener
nativer Unterbesitzer vollständig als Referenz/Bridge markiert. Stage 12c5aj
führt erstmals einen expliziten nativen Besitzer ein:

- `prompt_execution.mojo` besitzt `PromptExecutionBundle`, Bootstrap,
  Besitzerzuordnung und den exakten Fünf-Felder-Snapshot;
- `prompt_execution_helpers.mojo` besitzt sechs reine historische Helfer:
  `anotherOberesMaximum`, `returnOnlyParasAsList`, `grKl`,
  `getDictLimtedByKeyList`, `dictToList` und
  `vorherVonAusschnittOderZaehlung`;
- der große interaktive Effektblock `PromptGrosseAusgabe` bleibt sichtbar
  offen, wird aber auf seine bereits nativen Besitzer
  `prompt_table_execution.mojo`, `prompt_fraction_execution.mojo` und
  `native_reta_cli.mojo` abgebildet.

Damit steigt die Zahl mindestens teilweise portierter Referenzdateien von
83 auf 84. Es wird kein Python-Unterprozess aus den neuen Modulen gestartet.

## Lokaler Test

```sh
scripts/test_stage12c5aj.sh
```

Der Stage-Test kompiliert zuerst die korrigierte Parametergarbe, vergleicht die
Domänenprobe in vierzehn Fällen und kompiliert danach die beiden neuen
Prompt-Execution-Testprogramme. `./do.sh 12c5aj` führt anschließend nur bei
vollständigem Erfolg Shared Diagnostics, `test_all.sh` und den Commit aus.
