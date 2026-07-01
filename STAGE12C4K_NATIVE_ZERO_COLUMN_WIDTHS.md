# Stage 12c4k – native explizite Nullbreiten

Stage 12c4k übernimmt den Wert `0` innerhalb von `--breiten`/`--widths` für
Shell, HTML und BBCode. Damit ist nicht nur die globale Option `--breite=0`,
sondern auch eine einzelne ungebrochene Datenspalte Teil des nativen
Tabellenkerns.

## Semantik

- `--breiten=0` deaktiviert den Wortumbruch der ersten ausgewählten
  Datenspalte.
- `--breiten=0,8` lässt die erste Datenspalte ungebrochen und begrenzt die
  zweite auf acht Zeichen.
- `--breiten=5,0` begrenzt die erste und lässt die zweite ungebrochen.
- `--breiten=0,0` lässt beide ausgewählten Datenspalten ungebrochen.
- Fehlende Listeneinträge verwenden weiterhin die globale Breite.
- Ein späteres `--breiten` ersetzt wie bisher die frühere Liste vollständig.

## Warum die Implementierung nicht nur `0` freischaltet

Die Python-Referenz koppelt an Nullbreiten zwei nicht offensichtliche
Verhaltensweisen:

1. **Markup misst roh, serialisiert normalisiert.** HTML und BBCode entscheiden
   den Zeilenumbruch anhand der ursprünglichen ASCII-Leerraumläufe. Der
   ausgegebene Zelltext enthält dagegen normalisierte einzelne Leerzeichen.
   Sichtbare Tabelle und Breitenreferenz sind deshalb getrennte Datenströme.
2. **Shell besitzt eine historische Seitenkante.** Passt eine ungebrochene
   Nullspalte nicht auf eine horizontale Seite, wird die erste solche
   Datenspalte einmal übersprungen. Tritt derselbe Fall auf einer späteren
   Seite auf, endet der verbleibende horizontale Spaltenstrom.

Diese Regeln sind absichtlich referenzgetreu statt ästhetisch geglättet. Eine
vereinfachte Nullbreitenbehandlung hätte andere Bytes erzeugt.

## Ownership

Der native Ownership-Prüfer akzeptiert Nullbreiten nur für Shell, HTML und
BBCode. CSV, Markdown, Emacs sowie HTML/BBCode mit `--nocolor` bleiben ein
atomarer Referenzfallback. Es gibt keinen gemischten Lauf, in dem ein Teil des
Argumentvektors nativ und ein anderer Teil in Python ausgeführt wird.

## Prüfvertrag

```text
Nullbreitenfixtures:                      12/12 byteidentisch
positive Breitenfixtures:                 12/12 byteidentisch
Tabellenrenderer:                          17/17
CLI-/Ownership-Planer:                     26/26
Kompatibilitätslauncher:                   13/13
paginierte Renderer:                        6/6
No-blank:                                  13/13
Markup-oneTable:                           12/12
Source-Gates:                              13/13
I/O-Boundary-Audit:                        bestanden
```

Die Fixture-Matrix umfasst für jedes der drei Ausgabeformate `0`, `0,8`,
`5,0` und `0,0`:

```bash
scripts/check_column_zero_widths_parity.sh
RETA_REFRESH_COLUMN_ZERO_WIDTH_FIXTURES=1 \
  scripts/check_column_zero_widths_parity.sh
```

Zusätzlich wurde der nicht mehr importierte Altbestand
`prompt_python_bridge.mojo` samt veraltetem FFI-Probeimport entfernt. Aktive
Promptmodule enthalten damit physisch keine `std.python`-Brücke mehr.
