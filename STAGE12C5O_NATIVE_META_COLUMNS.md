# Stage 12c5o – vollständiger nativer Meta-Spaltenbesitzer

## Ziel

`python_reference/reta_architecture/meta_columns.py` war funktional bereits in
mehrere Mojo-Kerne zerlegt, aber in der maßgeblichen Portierungsmatrix noch
vollständig unbesessen. Stage 12c5o schließt die gesamte öffentliche Oberfläche
und friert die hashabhängigen Bruchkombinationen reproduzierbar ein.

## Native Besitzer

- `src/reta_mojo/meta_columns.mojo`
- `src/reta_mojo/prime_effect_columns.mojo`
- `assets/meta_columns_catalog.tsv`
- `scripts/generate_meta_columns_catalog.py`

## Übernommene Oberfläche

Alle 14 öffentlichen Python-Funktionen besitzen nun typisierte Mojo-Einstiege:

- Bundle-Bootstrap und drei Morphismusspezifikationen
- Meta-/Konkreta-/Theorie-/Praxis-Spaltengenerierung
- Ganzzahligkeitsprüfung für rationale Koordinaten
- Vorwort-, Zell-, Überschriften- und Tagbildung
- CSV-Auswahl und Bruchmengenermittlung
- Bruch-/Universums-Strukturalienauflösung
- kanonische Bruchkombinationen
- Primwirkungsfamilie innen/außen/seitlich

Die mutable Python-Receiverstruktur wurde in explizite Werte zerlegt:
`MetaColumnRequest`, `MetaFraction`, `MetaColumnMetadata`,
`MetaColumnsCatalog` und `PrimeEffectColumns`.

## Reproduzierbarer Bruchkatalog

Der Python-Code verwendet bei fehlendem `orderedset` normale Sets. Sichtbare
Iterationsreihenfolge wird deshalb unter `PYTHONHASHSEED=0` eingefroren.

`assets/meta_columns_catalog.tsv` enthält:

- 47 Universumsbrüche
- 40 Galaxiebrüche
- 884 geordnete Kombinationseinträge
- SHA-256 der beiden Quell-CSVs

Der Generator ruft die eingefrorene Python-Referenz auf und verweigert andere
Hash-Seeds. Der Mojo-Lauf lädt ausschließlich das unveränderliche TSV-Asset.

## Entdeckter Python-Kandidat

Im `stern/div`-Zweig vergleicht Python

```python
round(a / b) == round(a / b * 1000)
```

statt die rechte Seite wieder durch 1000 zu teilen. Für die vorhandenen
positiven Bruchmengen bleiben dadurch alle vier `stern/div`-Mengen leer. Der
Istzustand wird kompatibel im Katalog konserviert und als `PY-CAND-013` für die
spätere Python-Bereinigung erfasst.

## Tests

- `tests/test_meta_columns.mojo`
- `tests/test_prime_effect_columns.mojo`
- `tests/test_meta_columns_complete.mojo`
- `tests/test_meta_columns_complete_source.py`
- `scripts/test_stage12c5o.sh`

Die lokalen Mojo-Tests prüfen Bundle, vollständige Oberfläche, Katalogzahlen,
Bruchentdeckung, rationale Ganzzahligkeit, Überschriften/Tags,
Strukturalienauflösung und Primwirkungsweiterleitung.


## Maschinenstand und Verifikation

```text
vollständig nativ/generiert:     60/92 = 65,2 %
mindestens teilweise portiert:  83/92 = 90,2 %
angegriffene Referenzzeilen:      38.174/48.831 = 78,2 %
vollständig native Zeilen:        28.751/48.831 = 58,9 %
Mojo-Zeilen in src/:              52.865
Mojo-Zeilen in src/reta_mojo/:    48.833
Defektkatalog:                    76/76
Python-Bereinigungspunkte:        19
aktive std.python-Brücken:         0
```

In dieser Umgebung bestanden **32/32** ausführbare Source-, Ownership-, Defekt-, Boundary-, Metrik- und Archivgates. `scripts/test_stage12c5o.sh` baut lokal zusätzlich drei Mojo-Testprogramme mit zusammen **11** Testfällen.
