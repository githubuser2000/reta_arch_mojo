# Stage 12c5g – Nativer Kombi-Join und ordnungsunabhängige middle.alx-Parität

## Umfang

Diese Stage schließt den bisher reinen Python-Besitzer
`reta_architecture/combi_join.py` vollständig und trennt zwei bisher vermischte
Ordnungsbegriffe:

- **fachlich sichtbare Reihenfolge** der ausgegebenen Kombinationszellen und
  ausgewählten Spalten,
- **semantisch irrelevante Containerreihenfolge** von
  Hauptzeile→Kombi-CSV-Zeilen-Relationen.

Für den zweiten Fall benötigt Mojo weder `OrderedDict` noch `OrderedSet`.
Relationen werden typisiert gespeichert und für Prüfung beziehungsweise
Snapshot kanonisch nach Haupt- und Quellzeilennummer sortiert. Die sichtbare
Relationsreihenfolge bleibt weiterhin explizit in
`assets/kombi_relation_order.tsv` erhalten.

## Native Besitzeroberfläche

`src/reta_mojo/combi_join.mojo` besitzt die sechs historischen Morphismen:

| Python-Methode | Native Mojo-Oberfläche |
|---|---|
| `prepareTableJoin` | `prepare_kombi_join_tables` / `prepareTableJoin` |
| `removeOneNumber` | `remove_kombi_number_from_cell` / `removeOneNumber` |
| `tableJoin` | `apply_kombi_join_columns` / `tableJoin` |
| `prepare_kombi` | `select_kombi_lines` / `prepare_kombi` |
| `readKombiCsv` | `load_kombi_join_source` / `readKombiCsv` |
| `kombiNumbersCorrectTestAndSet` | `parse_kombi_number_token` / historischer Alias |

Zusätzlich gehören dazu:

- rekursiver Parser für Vorzeichen, Klammern und `n/m`,
- dekorierte `kombi.csv`- und `kombi-meta.csv`-Abschnitte,
- typisierte bidirektionale Spaltenrelationen,
- kanonische Auswahlmengen,
- vorbereitete Untertabellengruppen,
- öffentlicher Controller `reta-mojo-combi-join`.

Eine historische Besonderheit bleibt bytegenau erhalten: In einer
`kombi.csv`-Zeile besitzt die erste Zelle ein nachlaufendes Leerzeichen. Python
prüft zwar den getrimmten Wert, bettet aber die rohe Schreibweise in dekorierte
Zellen ein. Der native Besitzer macht dasselbe.

## Ordnungsunabhängiger middle.alx-Vergleich

`tools/compare_middle_alx.py` vergleicht `table#bigtable` als Multiset kompletter
Spaltenvektoren. Ein Spaltenvektor enthält:

- normalisierte Kopfmetadaten ohne physische `r_<n>`-/`z_<n>`-Position,
- alle Zellen dieser Spalte in fachlicher Zeilenreihenfolge,
- verschachteltes HTML einschließlich verschachtelter Tabellen,
- alle nichtpositionsbezogenen Attribute und Inhalte.

Ignoriert werden ausschließlich:

- physische Spaltenposition,
- HTML-Attributreihenfolge,
- Reihenfolge der Klassentokens.

Inhalts-, Zeilen-, Markup- oder Attributänderungen bleiben sichtbar. Das
Werkzeug liest außerdem Tar- und Tar-XZ-Dateien sowie Tarströme, die irrtümlich
eine `.alx`-Endung besitzen.

Die in dieser Stage hochgeladenen Dateien konnten nicht als echter
Python3↔PyPy3-Vergleich dienen: `middle_python3_arch.alx` war ein Tar-Archiv mit
dem Mitglied `middle_pypy3_arch.alx`; dessen Inhalt war byteidentisch mit der
separat hochgeladenen PyPy3-Datei. Der strukturelle Vergleich ergab daher
korrekt:

```text
rows=189
columns=807
canonical_sha256=bfb4f802fd6bfcfa24bf2cd5666562975d3754a5255c52f141157b0d9c2fe14d
gleich_ohne_spaltenreihenfolge=ja
```

Für einen echten Laufzeitvergleich muss künftig die tatsächliche Python3-Datei
neben der PyPy3-Datei gepackt werden; die Dateinamen allein werden nicht mehr
vertraut.

## Referenzparität

`tools/probe_combi_join_reference.py` und `tests/probe_combi_join.mojo` prüfen
stabile, ordnungsunabhängige Fingerabdrücke für:

- vier Zahlparserfälle,
- beide realen Kombi-CSV-Dateien,
- 521 Kombinationsdatenzeilen,
- 36 Spaltenrelationen,
- kanonische Auswahlrelationen,
- vorbereitete Untertabellen als Multisets von Zeilenfingerabdrücken,
- Zellbereinigung,
- den vollständigen Bundlevertrag.

Die Probe stimmt in **15/15 Ausgabezeilen** exakt überein.

## Öffentliche Oberfläche

```sh
./scripts/build.sh
./bin/reta-mojo-combi-join --summary
./bin/reta-mojo-combi-join --source galaxy
./bin/reta-mojo-combi-join --source universe
python3 tools/compare_middle_alx.py first.alx second.alx
```

## Reproduzierbare Prüfungen

- `tests/test_combi_join.mojo`
- `tests/probe_combi_join.mojo`
- `tools/probe_combi_join_reference.py`
- `scripts/check_combi_join_parity.sh`
- `tests/test_combi_join_source.py`
- `tests/test_middle_alx_compare.py`
- `scripts/test_stage12c5g.sh`

Abschlussstand vor der Frischentpackprüfung:

```text
native KombiJoin-Modultests:           8/8
Python↔Mojo-Referenzzeilen:           15/15
middle.alx-Strukturtests:              2/2
Stage-Quelltests einschließlich Metriken: 23/23
zusätzliche Archiv-/Boundary-Gates:     20/20
Defektkatalog:                          66/66
Python-Bereinigungspunkte:              17
aktive std.python-Brücken:               0
OrderedDict/OrderedSet im Mojo-Besitzer: 0
```

## Maschinenberechneter Stand

```text
vollständig nativ/generiert: 55/92 = 59,8 %
mindestens teilweise:       75/92 = 81,5 %
angegriffene Referenzzeilen: 34.177/48.831 = 70,0 %
Mojo-Zeilen in src/:         50.012
Mojo-Zeilen in reta_mojo/:   46.622
```
