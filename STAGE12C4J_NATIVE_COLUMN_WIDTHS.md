# Stage 12c4j – individuelle Spaltenbreiten nativ

Stage 12c4j übernimmt die historischen Ausgabeoptionen `--breiten=` und
`--widths=` in den typisierten Mojo-Tabellenplan. Die Werte beziehen sich auf
die ausgewählten Datenspalten; Nummerierungs- und Zählspalten verschieben die
Zuordnung nicht.

## Referenzsemantik

- Kommagetrennte nichtnegative Dezimalwerte bilden die explizite Breitenliste.
- Ungültige und negative Fragmente werden wie in der Referenz ignoriert.
- Eine spätere `--breiten`-/`--widths`-Option ersetzt die vorherige Liste.
- Fehlende Listeneinträge fallen auf die globale `--breite`/`--width` zurück.
- Positive Einzelbreiten unterliegen nicht dem globalen historischen Minimum
  von 21 Zeichen.
- `--breite=0` darf mit positiven Einzelbreiten kombiniert werden: nur die
  nicht explizit überschriebenen Spalten bleiben ungebrochen.

## Conservative native-first-Grenze

Vollständig nativ besessen sind positive Einzelbreiten für Shell, HTML und
BBCode. Der Ganzvektor-Ownership-Prüfer fällt weiterhin atomar auf die
Python-Referenz zurück bei:

- CSV, Markdown und Emacs mit `--breiten`/`--widths`, weil deren historische
  visuelle Zeilenexpansion noch nicht separat portiert ist;
- expliziten Nullwerten innerhalb der Breitenliste;
- HTML/BBCode mit `--nocolor` oder `--justtext`, weil die Referenz dort einen
  anderen rohen Mehrzeilenserializer verwendet.

Damit gibt es keine teilweise Interpretation eines noch nicht vollständig
besessenen Argumentvektors.

## Zusätzliche Rendererkorrektur

Der Shell-Seitenplan zählt den Nummerierungsseparator nicht mehr doppelt. Eine
Spalte, die exakt in das verbleibende Seitenbudget passt, wird dadurch nicht
mehr verfrüht auf eine neue horizontale Seite verschoben.

## Prüfvertrag

```text
Spaltenbreiten Python↔Mojo:              12/12 byteidentisch
Tabellenrenderer:                        15/15
nativer CLI-/Ownership-Planer:           26/26
Kompatibilitätslauncher:                 12/12
paginierte Rendererparität:               6/6
No-blank-Parität:                        13/13
zentrale HTML-/BBCode-Fixtures:           8/8
Markup-oneTable ohne Python:             12/12
Source-/Boundary-Gates:                  14/14
nativer I/O-Boundary-Audit:              bestanden
aktive std.python-Brücken:                   0
```

Die zwölf Breitenfixtures umfassen Deutsch und Englisch, Shell/HTML/BBCode,
globale Nullbreite und das Ersetzen einer früheren Breitenliste. Die positiven
native-first-Fälle laufen mit einem absichtlich nicht existierenden
`RETA_PYTHON`; die bewusst nicht besessenen Randfälle werden mit einem
instrumentierten Referenzprozess samt unverändertem Argumentvektor und Exitcode
geprüft.
