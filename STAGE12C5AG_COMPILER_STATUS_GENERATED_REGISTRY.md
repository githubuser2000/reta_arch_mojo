# Stage 12c5ag – Compilerstatus und Generated-Column-Registry

## Anlass

Der lokale vollständige Build und die Shared-Diagnostics-Prüfung waren
vollständig erfolgreich. Der anschließende Testlauf brach beim Kompilieren von
`tests/test_input_semantics.mojo` ab:

```text
error: use of unknown declaration 'is_row_range_token'
```

Die Funktion war in `row_ranges.mojo` vorhanden. Der Test importierte jedoch
nur `input_semantics.mojo` per Wildcard. Mojo exportiert aus einem Modul
importierte Namen nicht transitiv über einen weiteren Wildcard-Import.

## Korrektur

`input_semantics.mojo` besitzt nun eine explizite, typisierte Fassade für den
nativen Bereichserkenner. Damit ist die Besitzergrenze sichtbar und der Test
hängt nicht von einer in Mojo nicht existierenden Reexport-Annahme ab.

Die drei übergeordneten Kompilierabläufe melden ihren Gesamtstatus über einen
`EXIT`-Handler und bewahren dabei den ursprünglichen Exitstatus:

- `scripts/build-all.sh`
- `scripts/build-and-test-shared-diagnostics.sh`
- `scripts/test_all.sh`

Erfolg endet mit `... erfolgreich: JA`; jeder Abbruch endet mit
`... erfolgreich: NEIN (Exitstatus N)`. Die POSIX-korrekte Prüfung lautet
`[ "$status" -eq 0 ]`. Ein Ausdruck wie `?$==0` oder `[ "$?" == "0" ]` wäre
kein portabler beziehungsweise korrekter `sh`-Test.

## Weitere Transpilierung

Die Registry-, Bundle- und Snapshot-Oberfläche von
`reta_architecture/generated_columns.py` ist jetzt typisiert in Mojo
vorhanden. Die zehn Registry-Einträge behalten die Python-Reihenfolge,
Trigger-Spalten, Tags und Beschreibungen. Die eigentlichen Algorithmen werden
nicht dupliziert, sondern ihren vorhandenen nativen Besitzern zugeordnet:

- `generated_columns.mojo`
- `generated_table_columns.mojo`
- `prime_cross_columns.mojo`
- `prime_universe_columns.mojo`
- `table_runtime.mojo`

Die verbleibende Grenze ist die dynamische Integration in das historischen
Python-`Concat`-Objekt, nicht die Registry oder die einzelnen nativen
Berechnungsfamilien.

## Prüfung

Schneller Regressionslauf:

```sh
scripts/test_stage12c5ag.sh
```

Vollständiger Ablauf ohne Fortsetzung nach einem Fehler:

```sh
scripts/build-all.sh && \
scripts/build-and-test-shared-diagnostics.sh && \
scripts/test_all.sh
```

Weil `&&` nur bei Exitstatus 0 fortsetzt, wird nach einem fehlgeschlagenen
Build keine nachgelagerte Prüfung irrtümlich als Beleg für einen konsistenten
Gesamtstand ausgeführt.
