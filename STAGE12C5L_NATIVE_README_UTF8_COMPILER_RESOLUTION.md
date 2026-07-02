# Stage 12c5l – UTF-8-sicherer Workflow, robuste Mojo-Auflösung und nativer README-Generator

## Ausgangslage

Der lokale Mojo-1.0.0b2-Lauf von Stage 12c5k deckte zwei Fehler auf, die in der
compilerlosen Source-Prüfung nicht sichtbar werden konnten:

1. `scripts/test_stage12c5e.sh` führte seine ersten beiden Mojo-Tests korrekt
   aus, reichte danach aber den Projektresolver `bin/mojo-real` als
   `MOJO_BIN` an `scripts/build_concat_csv_probe.sh` weiter. Der Resolver prüfte
   dadurch sich selbst als vermeintliches Compilerprogramm und meldete
   fälschlich, Modular Mojo sei nicht installiert.
2. Der Religion-JSON-Scanner bewegte einen Byteoffset durch einen Mojo-`String`
   und verwendete diesen Offset anschließend als String-Slice-Grenze. Bei
   koreanischen, chinesischen oder vietnamesischen Nutzlasten konnte der Offset
   mitten in einem UTF-8-Codepoint liegen und löste einen Laufzeit-Assert aus.

Beide Probleme waren Fehler des Mojo-Ports; das hochgeladene source-only Archiv
war vollständig und korrekt.

## Compilerauflösung ohne Selbstreferenz

`scripts/test_stage12c5e.sh` ruft den dedizierten Probe-Builder nun ohne lokal
neu gesetztes `MOJO_BIN` auf. Ein vom Benutzer exportierter echter Compilerpfad
bleibt dabei erhalten.

`bin/mojo-real` besitzt zusätzlich eine defensive zweite Schranke: Zeigt
`MOJO_BIN` nach Pfadauflösung auf den Resolver selbst, wird nur dieser
selbstreferenzielle Wert verworfen. Danach läuft die normale Suche über
Projekt-`.venv`, Pixi, aktive virtuelle Umgebung und `PATH` weiter. Ein
expliziter externer Compilerpfad wird weiterhin strikt validiert.

`tests/test_mojo_resolver_source.py` prüft nicht nur den Quelltext, sondern baut
einen temporären Projektbaum mit einem künstlichen `.venv/bin/mojo` und führt
den Resolver mit `MOJO_BIN=<resolver-selbst>` tatsächlich aus.

## UTF-8-sicherer Religion-JSON-Scanner

`_json_string_for_key` in `parallel_execution.mojo` scannt JSON-Syntax nun über
`json.as_bytes()`. Verglichen werden ausschließlich die ASCII-Bytes für
Anführungszeichen, Backslash, Doppelpunkt und Leerraum. `StringSlice` wird nur
an gefundenen ASCII-Trennzeichen erzeugt; diese Grenzen können nicht innerhalb
eines mehrbyteigen UTF-8-Codepoints liegen.

Die native Testsuite enthält einen direkten Wert mit:

```text
한글 中文 Việt
```

Die Python↔Mojo-Parität wurde von 13 auf 15 Fälle erweitert und prüft den Wert
sowohl als Plaintext als auch innerhalb des HTML-Feldes.

## Vollständiger nativer Ersatz von `libs/generate4readme.py`

Der bisher vollständig referenzierte Dokumentgenerator ist nun als
reproduzierbar generierter nativer Besitzer markiert:

- `tools/generate_readme_assets.py` führt die Python-Referenz ausschließlich
  zur Quellerzeugung unter `PYTHONHASHSEED=0` aus,
- `assets/generated_readme_german.md` enthält die vollständige deutsche
  Ausgabe mit 13.562 Bytes und 206 Zeilenumbrüchen,
- `assets/generated_readme_english.md` enthält die vollständige englische
  Ausgabe mit 12.877 Bytes und 208 Zeilenumbrüchen,
- `assets/generated_readme_manifest.tsv` bindet Sprache, Dateiname, Größe,
  Zeilenzahl, SHA-256 und kanonischen Seed,
- `src/reta_mojo/readme_generator.mojo` lädt und validiert die Assets ohne
  Python oder Subprozess,
- `src/generate_readme_main.mojo` erhält die historische
  `-language=english`-/`-language=englisch`-Oberfläche,
- `bin/generate4readme` startet das neue Ziel `generate-readme-native`.

Der Referenzvergleich deckte dabei `PY-CAND-012` auf: Vier Bruchparameterlisten
ändern im Python-Original ihre Reihenfolge zwischen verschiedenen
`PYTHONHASHSEED`-Werten. Die native Fassung erfindet keine neue Sortierung,
sondern friert den explizit dokumentierten Seed-0-Vertrag bytegenau ein. Der
spätere Python-Cleanup kann die vier mengenbasierten Quellen anschließend in
eine ausdrücklich geordnete Struktur überführen.

## Build- und Installationsoberfläche

Neues reguläres Ziel:

```text
target/bin/generate-readme-native
```

Damit bestehen die offiziellen Ziele aus 16 regulären und 18 schweren
Programmen, insgesamt 34. Das Testskript `scripts/test_stage12c5l.sh` baut:

- den UTF-8-Workflow-Modultest,
- die Workflow-Diagnose-CLI und ihre 15-Fall-Parität,
- den README-Modultest,
- den nativen README-Generator und seine deutsch/englische Byteparität,
- anschließend die Source-, Ownership-, Defekt-, Archiv-, Metrik- und
  Installationsgates.

## Defektkatalog

Neu dokumentiert:

- `MOJO-FIXED-030` – selbstreferenzielles `MOJO_BIN`,
- `MOJO-FIXED-031` – ungültige UTF-8-Stringgrenzen,
- `PY-CAND-012` – hashseedabhängige README-Reihenfolge.

Der Katalog enthält damit 71 Einträge; 18 Python-Bereinigungspunkte bleiben für
die Zeit nach Abschluss der vollständigen Portierung vorgemerkt.

## Fortschritt

- vollständig nativ oder reproduzierbar generiert: **58/92 = 63,0 %**,
- mindestens teilweise portiert: **80/92 = 87,0 %**,
- angegriffene Referenzzeilen: **36.664/48.831 = 75,1 %**,
- vollständig native Referenzzeilen: **27.649/48.831 = 56,6 %**,
- Mojo-Quellzeilen in `src/`: **51.600**,
- davon in `src/reta_mojo/`: **47.950**,
- aktive eingebettete Python-Brücken: **0**.
