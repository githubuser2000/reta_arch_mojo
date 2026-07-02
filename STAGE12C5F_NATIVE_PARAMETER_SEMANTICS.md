# Stage 12c5f – Native Parametersemantik, Spaltenbindung und Universal-Synchronisation

## Umfang

Diese Stage schließt drei bisher nur teilweise oder gar nicht native Besitzer:

- `reta_architecture/semantics_builder.py`
- `reta_architecture/column_selection.py`
- `reta_architecture/universal.py`

## Native Parametersemantik

`src/reta_mojo/semantics_builder.mojo` bildet die heterogenen Python-Strukturen
als getaggte Werte, Parameterpaare, Referenzgruppen und 14 typisierte Datenslots
ab. Der vollständige 431-Familien-Katalog wird durch
`tools/generate_semantics_builder_catalog.py` reproduzierbar in
`src/reta_mojo/semantics_builder_catalog.mojo` erzeugt.

Der Normalmodus besitzt:

- 432 Matrixeinträge einschließlich des synthetischen `alles`-Eintrags,
- 84 Hauptparameter,
- 4.155 kanonische Parameterpaare,
- 46 beziehungsweise 51 Kombinationsrückabbildungen,
- 556 einfache Spalten.

Der Inversionsmodus reproduziert die Python-`alles`-Komplementbildung.

## Vollständige Inhaltsparität

Ein UTF-8-stabiler, reihenfolgeunabhängiger Fingerabdruck erfasst Matrixwerte,
Parameterpaare, Datenbindungen und Referenzgruppen, Kombinationen,
Rückabbildungen und `alles`-Mengen. Die Python- und Mojo-Ergebnisse stimmen in
beiden Modi exakt überein:

```text
normal:   14361:946406030:222404321:921621192:75488621
invertiert: 12624:500592877:712071932:377318734:638165603
```

Vier historische Matrixfamilien verwenden Python-`set` auch für
Parameternamen; viele Datensätze sind ebenfalls Mengen. Der erste Generator war
deshalb von `PYTHONHASHSEED` abhängig. `StableSet` und `normalized_schema`
kanonisieren nun ausschließlich `set`/`frozenset`; Listen und Tupel behalten
ihre fachliche Reihenfolge. Katalog und Referenz-JSON sind unter
`PYTHONHASHSEED=0` und `1` byteidentisch (`TEST-FIXED-015`).

## Leistungsreparatur

Der erste korrekte native Builder verwendete globale lineare Suchen. Ein
Vollkatalogtest benötigte dadurch im Debug-Build mehr als 20 Minuten. Der
endgültige Builder hält `Dict[String, Int]`-Indizes für Hauptparameter,
Parameterpaare und Datenslot-Bindings. Sichtbare Reihenfolge und
Later-wins-Semantik bleiben erhalten. Der Normalaufbau samt vollständigem
Fingerabdruck benötigt in der Prüfmaschine ungefähr 0,8 Sekunden. Der generierte
Katalog ist zusätzlich in 18 kleine Append-Funktionen geteilt; dadurch fällt ein
kalter Probe-Compilerlauf von über 20 Minuten auf ungefähr 20 Sekunden.

## Spaltenbindung und Universal-Konstruktionen

`column_selection.mojo` liefert neben den 24 historischen Buckets einen
expliziten `BoundColumnSections`-Wert für alle zuvor versteckten
Programmutationen: Zeilen, generierte Spalten, Primuniversum, beide
Kombinationsgruppen, Singleton-`ones`, `ka`/`ka2` und Vanilla-Spaltenzahl.

`universal.mojo` besitzt jetzt den typisierten Parameter-/Datenmerge sowie die
Synchronisation generierter Spalten und ausgabemodusspezifischer
Tabellenzustände.

## Referenztestkorrektur

Die Python-Architekturtests enthielten veraltete Erwartungen von 554 einfachen
Spalten. Der aktuelle Referenzkatalog und der reale Prompt-Runtime-Zustand
liefern 556. Nur diese drei Sollwerte wurden aktualisiert; Produktivlogik wurde
nicht verändert (`TEST-FIXED-014`).

## Öffentliche Oberfläche

- `src/semantics_builder_main.mojo`
- `bin/reta-mojo-semantics`
- `reta-mojo-semantics --normal`
- `reta-mojo-semantics --invert`

## Reproduzierbare Prüfungen

- `scripts/check_semantics_builder.sh`
- `scripts/check_semantics_builder_parity.py`
- `scripts/test_stage12c5f.sh`
- `tests/test_semantics_builder.mojo`
- `tests/semantics_builder_probe.mojo`
- `tests/test_column_selection.mojo`
- `tests/test_universal.mojo`
- `tests/test_semantics_builder_source.py`

Ergebnis:

```text
native Semantik-, Spalten- und Universaltests: 12/12
Python↔Mojo-Vollparität:                       20/20 Zeilen
Python-Referenzregressionen:                    4/4
Hash-Seed-Reproduktion:                         2/2 byteidentisch
Source-/Ownership-/Boundary-/Archivtests:      26/26
Defektkatalog:                                 65 konsistent
Python-Bereinigungspunkte:                     17
aktive std.python-Brücken:                      0
```

## Maschinenberechneter Stand

```text
vollständig nativ/generiert: 54/92 = 58,7 %
mindestens teilweise:       74/92 = 80,4 %
angegriffene Referenzzeilen: 33.465/48.831 = 68,5 %
Mojo-Zeilen in src/:         49.537
Mojo-Zeilen in reta_mojo/:   46.183
```
