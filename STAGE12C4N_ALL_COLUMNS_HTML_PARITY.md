# Stage 12c4n – vollständiger nativer `--alles`-HTMLpfad

## Ziel

Stage 12c4n schließt die bislang nur strukturell geprüfte vollständige
Ein-Zeilen-Ausgabe von `generate_html` gegen die unveränderte Python-Referenz.
Der Vergleich umfasst nicht nur die Anzahl der Spalten, sondern die exakte
Reihenfolge, Überschriftenmetadaten, Klassen, Maskierung und Zellinhalte aller
physischen und generierten Spalten.

## Korrigierter Spaltenplan

Der vorherige native Plan erzeugte **863** Spalten. Die Python-Referenz erzeugt
für `--alles` exakt:

```text
2 Verwaltungs-/Nummernspalten
805 Daten- und Generatorspalten
--------------------------------
807 sichtbare Spalten
```

Die 56 zusätzlichen nativen Spalten entstanden aus Bruchanforderungen, deren
Quellkoordinaten außerhalb der tatsächlichen gebrochen-rationalen CSV-Form
lagen. `fraction_concat_columns.mojo` prüft Anfragen jetzt gegen die reale
Zeilen- und Spaltenform der jeweiligen CSV und ignoriert unmögliche
Koordinaten wie die Python-Referenz.

Außerdem wird `PrimCSV` wieder vor den gebrochen-rationalen Verkettungen
eingefügt. Damit entspricht nicht nur die Spaltenmenge, sondern auch die
historische Generatorreihenfolge dem Original.

## Semantische HTML-Metadaten

Physische Spaltenidentitäten reichen für den vollständigen Plan nicht aus:
mehrere generierte Überschriften sind textgleich oder stammen aus kombinierten
Quellen. Der neue Katalog

```text
assets/html_heading_catalog.tsv
```

enthält **1.626** deutsch/englische semantische Einträge. Bei der vollständigen
805-Datenspaltenansicht darf die exakte Referenzposition eine mehrdeutige
Quellidentität überstimmen. Für kleinere Projektionen bleibt die semantische
Überschriftenauflösung maßgeblich.

Der Katalog wird reproduzierbar aus den eingefrorenen Referenzfixtures und den
16 bewusst kuratierten Sonderfällen erzeugt:

```text
assets/html_heading_catalog_curated.tsv
tests/fixtures/generate_html/middle-all-row1-de.html
tests/fixtures/generate_html/middle-all-row1-en.html
```

## Markupdetails

Zusätzlich wurden drei historische Details übernommen:

- `kein Mond` bleibt in HTML in einem `<ul>…</ul>`-Container;
- Kombinationszellen werden aus ihren nichtleeren relationalen Segmenten als
  echte `<ul><li>…</li></ul>`-Listen serialisiert;
- Anführungszeichen in gewöhnlichen Zellen werden als `&quot;` maskiert,
  während bewusst erzeugte HTML-Tags aktiv bleiben und mathematische
  Vergleichszeichen weiterhin korrekt unterschieden werden.

## Bytegenaue Referenz

Der reale vollständige Pfad wird über

```bash
RETA_GENERATE_HTML_ROWS=1 target/bin/generate-html-native
```

geprüft. `middle.alx` besitzt jeweils zwei Tabellenzeilen mit je 807 Zellen:
Überschrift und Datenzeile 1.

```text
Deutsch:
301.206 Byte
SHA-256 630823c2adf24874c59a1cf44b734c6ee3dedc1ffe31bbadad5b262a4e83d353

Englisch:
295.215 Byte
SHA-256 f9bf50f5c2c9fc6a3d4b6d1d55da221046fcf495ec34f19077b320c66fbe1058
```

Beide nativen Dateien sind bytegleich zu den eingefrorenen Python-Fixtures.

## Prüfungen

```text
Bruchkoordinaten und CSV-Form:          4/4
Generatorreihenfolge und Mond-Markup:   9/9
HTML-Metadaten und Maskierung:          7/7
Kombi-Join einschließlich HTML-Listen:  5/5
vollständiges HTML Deutsch:             bytegleich, 807 Spalten
vollständiges HTML Englisch:            bytegleich, 807 Spalten
Grundstruktur-/generate_html-Parität:    bestanden
Basistabelle CSV/Markdown/Emacs:         4/4 bytegleich
positive Einzelbreiten:                12/12 bytegleich
explizite Nullbreiten:                  12/12 bytegleich
paginierte Shell/HTML/BBCode:            6/6 bytegleich
keineleereninhalte:                     13/13 bytegleich
rohes HTML/BBCode --nocolor:            12/12 bytegleich
Markup-oneTable:                        12/12 bytegleich
Kombi-CSV:                               9/9 bytegleich
```

Die vollständige `--alles`-HTMLausgabe ist damit nativ besessen. Seltene
formatabhängige Volltabellenränder außerhalb des von `generate_html`
verwendeten HTML-Vertrags bleiben weiterhin Teil der allgemeinen
Stage-9-Ausgabegrenze und werden nicht durch diesen Abschluss überdeckt.
