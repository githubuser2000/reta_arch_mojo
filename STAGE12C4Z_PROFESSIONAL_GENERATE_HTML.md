# Stage 12c4z – professioneller FHS-fähiger `generate_html`-Einstieg

## Ziel

Der bereits native HTML-Generator war fachlich vollständig, aber sein öffentlicher
Starter verhielt sich noch wie ein Projektbaumscript: Er wechselte heimlich in den
Installationsstamm und der native Kern schrieb bei jedem Lauf `middle.alx` in das
aktuelle Arbeitsverzeichnis. Unter `/usr/lib/reta` führte das zu Schreibfehlern oder
unerwünschten Dateien im privaten Installationsbaum.

Stage 12c4z macht daraus ein normales Unix-Kommando, das unter `/usr/bin` oder
`/usr/local/bin` installiert werden kann und seine privaten Binär- und
Ressourcendateien über das FHS-Layout findet.

## Öffentlicher Vertrag

```sh
generate_html > reta.html
generate_html --output reta.html --language english
generate_html --middle-file middle.alx --output reta.html
generate_html --middle-output middle.alx > reta.html
```

Unterstützt werden:

- stdout als Standardausgabe,
- atomare Ausgabe mit `-o`/`--output`,
- `--no-clobber`,
- fünf Sprachen,
- vorhandene Mitteltabellen mit `--middle-file`,
- explizite Sicherung mit `--middle-output`,
- der historische Modus `--legacy-middle`,
- `--rows`, `--data-dir` und `--asset-dir`,
- `--help`, `--version` und definierte Exitcodes.

Ohne ausdrückliche Option entsteht keine `middle.alx` mehr. Das Kommando wechselt
sein Arbeitsverzeichnis nicht und kann aus beliebigen Verzeichnissen gestartet
werden.

## FHS-Installation

```text
/usr/bin/generate_html
/usr/lib/reta/bin/generate_html
/usr/lib/reta/target/bin/generate-html-native
/usr/share/reta/...
/usr/share/man/man1/generate_html.1
```

Der öffentliche Starter bleibt ein kleines POSIX-Shell-Frontend. Der kompilierte
Mojo-Kern und seine Laufzeitbibliotheken bleiben privat unter `lib/reta`; Daten und
unveränderliche Assets liegen unter `share/reta`.

## Hochgeladene Python-Referenz

Die vom Nutzer erzeugte Ausgabe

```sh
python reta -spalten --alles --breite=0 \
  -ausgabe --art=html --onetable --nocolor > middle.alx
```

wurde als wiederverwendbares Paket aufgenommen:

```text
tests/references/reta-python-full-all-reference-v1.tar.bz2
```

Originaldaten:

```text
SHA-256: 2ae1b0801ca8efac4d8cee1bcf773d743cc2ef2ac13979a5bc467c8c171a8d93
Bytes:    24.907.325
Zeilen:   458.139
Tabellenzeilen: 198
Tabellenzellen: 149.356
PYTHONHASHSEED: unkontrolliert
```

Da der Lauf ohne festgelegten `PYTHONHASHSEED` entstand, variiert das Python-
Original in der Reihenfolge von 20 Metaspalten und in zehn set-basierten,
trunkierten Generatorspalten. Der neue Vergleich richtet doppelte Überschriften
vorkommensgenau aus, weist die zehn bekannten Hashspalten separat aus und verlangt
für den reproduzierbaren Kern vollständige Gleichheit:

```text
stabile semantische Zellen: 147.506/147.506 = 100 %
Hash-abhängige Zellen:        1.850
abweichende Hash-Zellen:        214
```

Nichts wird stillschweigend als gleich erklärt: Roh-, Text-, ausgerichtete und
stabile Parität werden getrennt ausgegeben.

## Tests

```text
generate_html CLI-/Source-/Installtests: 13/13
Referenzworkflow:                         4/4
FHS-Testinstallation:                    bestanden
HTML-Orchestrierungsparität:             bestanden
native I/O-Grenzen:                      bestanden
vollständiger stabiler Tabellenkern:      147.506/147.506
```

Der spezialisierte Streamingvergleich bewahrt den historischen Vertrag von
198 Tabellenzeilen und 149.356 Zellen, ohne beide 25-MiB-Dokumente als große
allgemeine HTML-Objektbäume zu halten.

## Sourcearchiv

`scripts/create_source_archive.sh` erzeugt das Releasearchiv reproduzierbar und
schließt Buildbäume, `.venv`, Gitdaten, Python-/Pytest-Caches auf jeder
Verzeichnisebene, Bytecode, `middle.alx` und die verbotene alte Prompt-Python-
Bridge aus. Die fertige tar.bz2 wird vor dem Umbenennen nochmals gegen dieselbe
Verbotsliste geprüft.

## Source-only- und Nach-Build-Gates

Der Stage-Runner führt Ledger, CLI-Vertrag, Referenzworkflow und Archivvertrag
ohne `target/` aus. Funktionale Installations-, HTML- und I/O-Prüfungen laufen
erst nach einem Build. Dadurch bleibt das Quellarchiv selbständig prüfbar, ohne
kompilierte ELF-Dateien mitzuliefern.
