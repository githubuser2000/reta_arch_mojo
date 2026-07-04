# Stage 12c5aw – monotone obere Grenze der Legacy-Programmfassade

## Vom Compilerlauf aufgedeckter Unterschied

Nach der Reparatur der Compile-Time-`getenv`-Grenze kompiliert
`tests/test_legacy_reta_program.mojo` wieder. Der Benutzerlauf erreichte damit
den zweiten Test und zeigte einen falschen Erwartungswert:

```text
left:  1024
right: 77
```

Der produktive Adapter war bereits korrekt. Die historische Python-Funktion
`apply_upper_limit_argument()` berechnet das Maximum aus dem neuen expliziten
Wert und der bestehenden Tabellenobergrenze. Sie darf eine bereits gesetzte
Grenze nicht verkleinern.

Der Test bootstrapped zuvor `--vorhervonausschnitt=1-3`. Dieser Pfad setzt wie
Python den historischen Boden auf 1024. Ein anschließendes
`--oberesmaximum=77` wird syntaktisch akzeptiert, lässt die wirksame Grenze aber
bei 1024. Erst `--oberesmaximum=2048` erhöht sie auf 2048.

## Neuer Regressionsvertrag

Der Mojo-Test prüft nun beide Seiten ausdrücklich:

1. kleinere explizite Grenze wird erkannt, verkleinert aber nicht,
2. größere explizite Grenze erhöht den typisierten Zustand.

Ein zusätzlicher Source-Vertrag bindet die Werte 77 → 1024 und 2048 → 2048,
damit die alte falsche Erwartung nicht erneut eingeführt wird.

## Enthaltene vorausgehende Arbeit

Stage 12c5aw schließt außerdem ein:

- die nativen Start-, Sprach-, Hilfe- und Kontrollpfade aus 12c5au,
- die durchgereichten Mojo-Compileroptionen aus 12c5av,
- die weiterhin explizite O0-Sicherheitsvorgabe schwerer Ziele, sofern
  `--optimize-heavy` nicht gesetzt ist.


## Portable Abschlussprüfung

```text
Statische Verträge:                    99 bestanden
Bekannte Defekte:                     123
Python-Aufräumpunkte:                  20
Vollständig nativ/generiert:        89/92 = 96,7 %
Mindestens teilweise portiert:      92/92 = 100,0 %
Angegriffene Referenzzeilen: 48.831/48.831 = 100,0 %
```

## Benutzerseitiger Compilerlauf

```sh
scripts/build-all.sh -- --target-cpu <CPU-NAME>
scripts/test_stage12c5aw.sh
```

Alternativ mit optimierten schweren Metadatenzielen:

```sh
scripts/build-all.sh --optimize-heavy -- --optimization-level 2
scripts/test_stage12c5aw.sh
```

Die Erstellungsumgebung führt entsprechend der Projektvorgabe keine
Mojo-Kompilierung aus.
