# Stage 12c5aa – Build-Besitz und native lib4tables_prepare-Fassade

## Dauerhafter Buildvertrag

Installierbare Artefakte werden ausschließlich von Buildskripten erzeugt:

```bash
scripts/build.sh        # reguläre Programme + gemeinsame Diagnose-.so
scripts/build-heavy.sh  # schwere Architekturziele
scripts/build-all.sh    # beide Gruppen in einem Aufruf
```

`scripts/build-all.sh` ist damit der einzige vollständige Einstieg. Ein
Stage-Test ist nach dem Build nicht zusätzlich erforderlich, um
`libreta-mojo-diagnostics.so` zu erhalten. Die tiefe optionale
Alt-vs.-Shared-Library-Parität heißt nun ausdrücklich:

```bash
scripts/build-and-test-shared-diagnostics.sh
```

Mehrere historische `test_stage*.sh`-Skripte bauten zuvor zusätzlich
produktive Programme nach `target/bin`. Sie bauen nun nur isolierte
Testprogramme. Benötigte reguläre oder schwere Ziele werden über
`scripts/require_built_targets.sh` auf Existenz und Source-ID-Frische geprüft.
`tests/test_stage_build_separation.py` hält diese Besitzertrennung fest.

## Installationsmanifest

Die Source-ID-Datei `reta-mojo-diagnostics.reta-source-id` ist keine weitere
Executable, sondern Teil des atomaren Loader-/Bibliotheksvertrags. Der
Installationsmanifesttest zählt Compilerziele und Sidecars nun getrennt. Damit
ist der vom lokalen Lauf gemeldete Fehlschlag geschlossen.

## Vollständiger Besitzer von libs/lib4tables_prepare.py

`src/reta_mojo/legacy_lib4tables_prepare.mojo` schließt die historische
Legacy-Fassade ohne neue installierbare Diagnose-Executable. Der Besitzer
umfasst:

- fünf Modulhelfer in Originalreihenfolge,
- expliziten Zustand statt `shellRowsAmount`, `h_de`, `dic`, `fill` und
  `wrappingType`,
- alle 20 aktiven Methoden-/Property-Einträge von `Prepare`,
- Zählgruppen, Bereichsmarker, Mengenbereinigung und Mond-/Sonnenauswahl,
- Zeilenfilterung, Displayauswahl, Zellenumbruch, Breitenberechnung,
  Zeilenvorbereitung und Tagging,
- ausschließlich typisierte Delegation an `table_adapters`, `row_filtering`,
  `table_preparation`, `table_wrapping` und `tag_schema`.

Der native Modultest wird nur unter `target/tests` erzeugt:

```bash
scripts/test_stage12c5aa.sh
```

## Metriken

```text
vollständig nativ/generiert:       72/92 = 78,3 %
mindestens teilweise portiert:     83/92 = 90,2 %
angegriffene Referenzzeilen:        38.174/48.831 = 78,2 %
vollständig native Referenzzeilen:  32.103/48.831 = 65,7 %
Mojo-Zeilen in src/:                57.136
davon in src/reta_mojo/:            52.579
```

## Abschlussprüfungen

```text
portable Source-Tests:                 153 bestanden, 1 Skip
fokussierte Build-/Installer-Gates:     67/67 bestanden
Source-Archivvertrag:                    3/3 bestanden
relative Mojo-Importe:                 270 auflösbar
Defektkatalog:                           99/99 konsistent
```

Die echte Mojo-Kompilierung des neuen Modultests bleibt für den lokalen
Modular-Compiler vorbereitet. Der source-only Arbeitsbaum enthält bewusst
keine `.venv`; eine lange Gesamtkompilierung wurde nicht simuliert.
