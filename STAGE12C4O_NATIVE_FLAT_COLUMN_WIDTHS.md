# Stage 12c4o – native Einzelspaltenbreiten für CSV, Markdown und Emacs

Stage 12c4o schließt die letzte formatbezogene Ownership-Lücke von
`--breiten`/`--widths`. Positive Werte und explizite Nullwerte waren bereits
für Shell, HTML und BBCode nativ; nun besitzen auch CSV, Markdown und
Emacs/Org denselben typisierten Breitenplan.

## Referenzvertrag

Die drei flachen Formate ignorieren die globale `--breite` für ihren normalen
Renderer, führen eine ausdrücklich angegebene Breitenliste aber weiterhin in
der historischen Tabellenvorbereitung aus. Eine logische Tabellenzeile kann
dadurch mehrere physische Ausgabezeilen erzeugen.

Dabei gelten folgende nicht offensichtliche Regeln:

- `widths[i]` bezieht sich ausschließlich auf die i-te ausgewählte
  Datenspalte; nicht genannte Spalten bleiben ungebrochen.
- `0` bedeutet für genau diese Spalte »nicht umbrechen«.
- Die Zählgruppenmarkierung wird auf jeder Fortsetzungszeile wiederholt.
- Die eigentliche Quellzeilennummer erscheint nur auf der ersten physischen
  Zeile; danach bleibt ihre Zelle leer.
- Markdown und Emacs erzeugen ihren Überschriftentrenner nach jedem physischen
  Fragment der logischen Überschrift.
- Emacs erzeugt den Primzahlpotenztrenner weiterhin nach jedem physischen
  Fragment der betreffenden Datenzeile.
- CSV bewahrt den seltenen CPython-`textwrap`-Fall, in dem ein Trennleerzeichen
  die Breite exakt vor einem überlangen Folgewort auffüllt.
- Fehlende mittlere CSV-Fortsetzungsfelder werden durch die historische
  Rich-Normalisierung als ein Leerzeichen sichtbar; das letzte Feld bleibt
  leer.
- Auch mit `--keinenummerierung` bleiben zwei leere strukturelle CSV-Felder
  am Zeilenanfang erhalten (`;;`); keine Datenspalte wird dabei irrtümlich als
  Nummerierungsspalte behandelt.

## Umsetzung

`src/reta_mojo/table_rendering.mojo` enthält nun einen gemeinsamen flachen
Zeilenexpander. Die Umbruchentscheidung benutzt die rohen Leerraumbreiten,
während Markdown und Emacs sichtbare Fragmente normalisieren. CSV erhält eine
eigene minimale Serialisierung der vorbereiteten Fragmente, damit die
historischen Leerfeld-, Randwhitespace- und unnummerierten Strukturbytes erhalten bleiben.

`native_reta_tokens_supported()` akzeptiert die drei Formate mit positiver,
gemischter oder nullhaltiger Breitenliste. Der native-first-Launcher muss dafür
keinen Python-Kindprozess mehr starten.

## Reproduzierbare Parität

Die dreizehn versionierten Referenzströme unter
`tests/fixtures/flat_column_widths/` prüfen:

- CSV, Markdown und Emacs;
- deutsche und englische Parametersyntax;
- `5,10` als positive Breitenliste;
- `0,8` als gemischte No-wrap-/Wrap-Liste;
- das historische Ersetzen einer früheren Breitenliste;
- unnummeriertes CSV ohne Überschrift mit den zwei leeren Strukturfeldern.

```sh
scripts/check_flat_column_widths_parity.sh
```

Bewusste Regeneration:

```sh
RETA_REFRESH_FLAT_COLUMN_WIDTH_FIXTURES=1 \
RETA_FLAT_COLUMN_WIDTH_FIXTURES_ONLY=1 \
RETA_REFERENCE_PYTHON=/pfad/zur/referenz-python \
scripts/check_flat_column_widths_parity.sh
```

## Geprüfter Stand

```text
CSV/Markdown/Emacs-Breitenparität:       13/13 byteidentisch
zusätzliche kombinierte Randfälle:          4/4 byteidentisch
Tabellenrenderer:                        20/20
nativer CLI-/Ownership-Planer:           26/26
Kompatibilitätslauncher:                 14/14
positive Shell/HTML/BBCode-Breiten:      12/12 byteidentisch
explizite Shell/HTML/BBCode-Nullbreiten: 12/12 byteidentisch
rohes HTML/BBCode --nocolor:             12/12 byteidentisch
paginierte Shell/HTML/BBCode-Ausgabe:     6/6 byteidentisch
keineleereninhalte:                      13/13 byteidentisch
aktive std.python-Brücken:                0
```
