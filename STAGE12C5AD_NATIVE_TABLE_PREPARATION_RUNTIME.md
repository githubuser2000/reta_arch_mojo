# Stage 12c5ad – vollständige TablePreparation-/TableRuntime-Besitzer

## Anlass

Der lokale Stage-12c5ac-Lauf bestätigte sämtliche neuen Mojo-Module und
Python/PyPy3-Snapshots. Danach scheiterte ausschließlich der abgeleitete
Python-Metriktest: Die Portierung war korrekt von 73 auf 74 vollständig native
Dateien gestiegen, während der Test weiterhin exakt 73 erwartete.

Der Test prüft Fortschritt nun nicht mehr als unveränderliche Konstante.
Unveränderliche Inventargrößen bleiben exakt; der Portierungsstand ist ein
monotoner Mindestwert, und jeder neue Besitzer wird zusätzlich namentlich in
der autoritativen Matrix geprüft.

## Vollständiger TablePreparation-Besitzer

`reta_architecture/table_preparation.py` wird vollständig durch
`src/reta_mojo/table_preparation.mojo` besessen. Neu typisiert sind insbesondere:

- `MainTablePreparationResult` und `KombiTablePreparationResult` samt Snapshots;
- `TablePreparationBundle` mit allen sieben historischen Modulgrenzen;
- die eine bidirektionale `ColumnIndexMapping` anstelle zweier synchron zu
  haltender Python-Dictionaries;
- serialisierte Header-/Tag-Gluing-Semantik;
- Haupt- und Kombitabellenorchestrierung;
- Religionnummern, Zeilenbereich, Spaltenabbildung und Ausführungsstatistik;
- explizite `GeneratedTagOverrides` statt des heterogenen `gebrSpalten`-Dicts.

Die unabhängige Threadstrategie bleibt in `parallel_row_preparation.mojo`. Sie
verwendet denselben reinen `prepare_indexed_row`-Kern und dupliziert keine
fachliche Semantik.

Zwei beim Audit erkannte Paritätsgrenzen sind explizit geschlossen:

1. `headingsAmount` stammt wie in Python aus der ersten Tabellenzeile, nicht
   aus der maximalen Breite einer möglicherweise unregelmäßigen Folgelinie.
2. Generierte Tag-Overrides greifen in Python nur, wenn der Ausgabeparameter
   bereits existiert. Dieser Zustand heißt nativ
   `parameter_already_present`; bei einem neuen Parameter werden zuerst die
   normalen Katalogtags installiert.

## Vollständiger TableRuntime-/TableState-Besitzer

`reta_architecture/table_runtime.py` und die bisher fehlende Factory-/Snapshot-
Oberfläche von `table_state.py` besitzen nun vollständige Mojo-Gegenstücke:

- `Tables`, `Maintable`, `TableRuntimeBundle` und ihre Snapshots;
- expliziter Besitz von State, Prepare, Concat, KombiJoin und TableOutput;
- synchronisierte Anzeige-, Ausgabe-, Obergrenzen-, Breiten-, Nummerierungs-
  und Textgrößenzustände;
- `fillBoth` und geordnete Zeilenreduktion;
- Gestirn-Spaltenerzeugung einschließlich physischer Tabellenposition,
  sichtbarer Ausgabeposition, Vanilla-Spaltenoffset, Tags und Metadaten;
- typisierte Ersatzwerte für die historischen Lazy-Klassenimporte;
- `TableStateBundle`, Abschnitts-/Display-/Generated-Column-Snapshots und
  `new_generated_rows`.

Ein während des statischen Audits gefundener doppelter Zuweisungsanfang im
Gestirn-Metadatenpfad wurde vor der Auslieferung entfernt und durch einen
Source-Vertrag gegen Wiederholung abgesichert.

## Teststrategie

Der normale Entwicklungszyklus bleibt:

```bash
scripts/build-all.sh
scripts/test_stage12c5ad.sh
```

`test_stage12c5ad.sh` kompiliert ausschließlich kurzlebige Testprogramme unter
`target/tests` und prüft:

- den vollständigen TablePreparation-Modultest;
- Python- und optional PyPy3-Snapshotparität;
- den vollständigen TableRuntime-/TableState-Modultest;
- Python- und optional PyPy3-Snapshotparität;
- Portierungsmatrix, Importauflösung, Buildbesitz und Defektkatalog.

`scripts/test_all.sh` ist die vollständige native Mojo-Testprogrammsuite. Sie
ist vor Releases, nach mehreren zusammengefassten Stages oder nach tiefen
Querschnittsänderungen sinnvoll, aber nicht nach jedem kleinen Patch nötig.
Sie überspringt standardmäßig die beiden besonders teuren Compilerziele. Für
einen Release-Kandidaten einschließlich dieser Ziele gilt:

```bash
RETA_TEST_HEAVY=1 scripts/test_all.sh
```

Alle Testbinaries werden nun über `bin/mojo-runtime-exec` gestartet. Damit
verwenden auch die Gesamttests dieselbe Runtime-Suche, Source-ID-Frischeprüfung
und FHS-Ressourcenauflösung wie die fokussierten Stage-Tests.

## Neue Prüfoberflächen

```text
src/reta_mojo/table_runtime.mojo
src/reta_mojo/table_preparation.mojo
src/reta_mojo/table_state.mojo
tests/test_table_preparation_complete.mojo
tests/table_preparation_complete_probe.mojo
tests/test_table_preparation_complete_source.py
tests/test_table_runtime_complete.mojo
tests/table_runtime_complete_probe.mojo
tests/test_table_runtime_complete_source.py
scripts/check_table_preparation_complete_parity.py
scripts/check_table_runtime_complete_parity.py
scripts/test_stage12c5ad.sh
```

Es entsteht keine weitere installierbare Diagnose-Executable und keine neue
Shared Library.
