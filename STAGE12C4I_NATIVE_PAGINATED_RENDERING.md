# Stage 12c4i – paginierte Rendererparität

Stage 12c4i schließt zwei ältere Referenzabweichungen in horizontal
paginierten Shell-, HTML- und BBCode-Ausgaben.

## Native Korrekturen

- Vorhandene ASCII-Bindestriche werden wie bei der Python-Referenz als
  bevorzugte Trennstellen verwendet, bevor ein überlanges Wort hart geteilt
  wird.
- Der Shellrenderer unterscheidet vorhandene leere Zellfragmente von wirklich
  fehlenden Fortsetzungsfragmenten. Nur letztere erhalten die neutrale
  alternierende Restfarbe.
- Die Korrekturen gelten bei positiver Breite, mehreren horizontalen Seiten,
  deutscher und englischer Oberfläche sowie aktiver No-blank-Semantik.

## Prüfvertrag

```text
Tabellenrenderer:                          13/13
paginierte Shell-/HTML-/BBCode-Fixtures:    6/6 byteidentisch
No-blank-Fixtures:                         13/13 byteidentisch
zentrale HTML-/BBCode-Fixtures:             8/8 byteidentisch
Markup-oneTable ohne Python:               12/12
nativer CLI-/Ownership-Planer:             25/25
Kompatibilitätslauncher:                   10/10
nativer I/O-Boundary-Audit:                bestanden
```

Die sechs neuen Referenzströme prüfen Deutsch und Englisch jeweils in Shell,
HTML und BBCode. `readelf -d` zeigt am Kompatibilitätslauncher weiterhin nur
die Mojo-Laufzeit und libc, nicht `libpython`.
