# Stage 12c5i – Native Architektur-Tabellenadapter

## Umfang

Diese Stage schließt `reta_architecture/table_adapters.py` vollständig. Die
419-zeilige Python-Datei enthält keine eigene tiefe Tabellenlogik, sondern eine
Architektur-Fassade über bereits getrennte Besitzer:

- vier Modulhelfer für Breite, Chunks und Wrapping,
- die historische `Prepare`-Oberfläche,
- die historische `Concat`-Oberfläche.

`src/reta_mojo/table_adapters.mojo` bildet diese Grenze nun ohne Python-Objekte,
`OrderedDict`, `OrderedSet` oder Kindprozess ab.

## Exakte Oberfläche

Der native Snapshot bewahrt die Quellreihenfolge von:

```text
4 Modul-Funktionen
17 logischen Prepare-Methoden
34 Concat-Methoden
8 Prepare-Konstruktorzuständen
13 Concat-Konstruktorzuständen
```

Die drei Python-Properties `breitenn`, `nummeriere` und `textWidth` stehen in
der Python-AST jeweils als Getter und Setter. Mojo bildet sie als je einen
typisierten Lesezugriff und einen expliziten Setter ab; deshalb werden 17
logische statt 20 syntaktische `Prepare`-Definitionen gezählt.

## Typisierte Besitzer

Die Fassade leitet auf folgende native Schichten:

- `row_filtering.mojo`: Zeilenbedingungen und Zählungsgruppen,
- `table_wrapping.mojo`: Breitenwahl, Chunks und Zellenumbruch,
- `table_preparation.mojo`: Zeilenauswahl und serielle/Thread-fähige Vorbereitung,
- `tag_schema.mojo`: primäre und Kombinations-Tagzuordnung,
- `number_theory.mojo`: Mond-/Sonnenklassifikation,
- `legacy_lib4tables_concat.mojo`: vollständige 34-Methoden-`Concat`-Fassade,
- die bereits nativen Generator-, Meta- und CSV-Besitzer dahinter.

`PrepareAdapterState` ersetzt den heterogenen dynamischen Objektzustand durch
explizite Felder für Bereichskonfiguration, Originalzeilen, Terminalbreite,
Zählungsgruppen, Religionsnummern, Breiten, Nummerierung, ausgewählte Spalten
und Wrapping-Laufzeit.

## Bewusste Parallelgrenze

`prepare4out` delegiert Datenzeilen auf `prepare_rows_serial`; derselbe typisierte
Kontext wird bereits von der nativen Thread-Zeilenvorbereitung verwendet.
Header- und Tagmutation bleibt wie in der Python-Architektur bewusst seriell.
Damit wird die Fassade nicht durch einen zweiten, abweichenden
Parallelalgorithmus dupliziert.

## Prüfungen

- `tests/test_table_adapters.mojo`
- `tests/test_table_adapters_source.py`
- `tests/test_porting_matrix_ownership.py`
- `tests/test_porting_metrics.py`
- `scripts/test_stage12c5i.sh`

In der aktuellen Sandbox bestanden die neuen und angrenzenden ausführbaren
Python-/Quelltests mit **42/42**. Ein zusätzlicher alter
`concat_csv`-Paritätstest konnte nicht gestartet werden, weil sein bereits
kompiliertes Mojo-Probe-ELF im hochgeladenen Archiv fehlt; dies ist kein
Testergebnis gegen den neuen Adaptercode. Der offizielle Modular-Mojo-Compiler
ist hier ebenfalls nicht installiert, daher wurde `tests/test_table_adapters.mojo`
für den lokalen Build vorbereitet, aber in dieser Umgebung nicht kompiliert.

## Maschinenberechneter Stand

```text
vollständig nativ/generiert: 57/92 = 62,0 %
mindestens teilweise:       77/92 = 83,7 %
angegriffene Referenzzeilen: 35.194/48.831 = 72,1 %
Mojo-Zeilen in src/:         50.652
Mojo-Zeilen in reta_mojo/:   47.213
aktive std.python-Brücken:        0
```
