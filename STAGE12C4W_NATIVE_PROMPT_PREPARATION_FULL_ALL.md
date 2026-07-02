# Stage 12c4w – native Prompt-Vorbereitung und vollständiges `--alles`-Gate

## Ziel

Stage 12c4w portiert den wirksamen Vertrag von
`reta_architecture/prompt_preparation.py` (462 Python-Zeilen) in drei getrennte
native Besitzer und erhebt den vollständigen Tabellenlauf mit `--alles` vom
kleinen Fixturetest zum semantischen Ende-zu-Ende-Gate.

Die Trennung ist absichtlich:

- `prompt_preparation_catalog.mojo` besitzt die reproduzierbaren
  fünfsprachigen Parameter-/Wertdomänen,
- `prompt_regex.mojo` besitzt Regex- und Wildcardauflösung über eine native
  POSIX-ERE-Grenze,
- `prompt_preparation.mojo` besitzt Rotation, kompakte Befehle,
  Bereichsumschreibung, Teiler-/Vielfachelogik und den Ausführungsplan.

Dadurch importiert ein Nutzer der Regexschicht nicht automatisch die gesamte
Zeilen- und Tabellenvorbereitung. Es gibt keine Python-Callbacks und keinen
`std.python`-Import.

## Reproduzierbarer Katalog

`scripts/generate_prompt_nested_catalog.py` erzeugt zusätzlich
`assets/prompt_preparation_domains.tsv`. Der Bestand enthält **506**
sprachgebundene Parameter-/Wertdomänen:

```text
deutsch       114
english        98
vietnamese     98
chinese        98
korean         98
```

`scripts/check_prompt_language_catalog.sh` regeneriert und vergleicht das Asset
auch aus einem Source-only-Archiv.

## Native Prompt-Vorbereitung

Der native Vertrag deckt ab:

- Vertauschung, wenn der vollständige `reta`-Befehl im zweiten Textteil steht,
- normale und klammerbewusste Tokenisierung,
- kompakte Kurzbefehle und CPython-kompatible String-Set-Reihenfolge,
- reine Zahlen, Bereiche und bestehende `reta`-Vektoren,
- Zählung gegenüber `vorhervonausschnitt`,
- Teiler und Vielfache,
- Entfernen einer alten Zeilensektion vor der neuen Bereichsprojektion,
- selektive Ausgabemodi und Exitplan,
- Root-, Hauptparameter-, Nebenparameter- und Wert-Regex,
- `*`-/Wildcardsyntax,
- fünfsprachige Parameter-/Wertdomänen.

Häufige Python-Regexformen wie nichtfangende Gruppen und
`\d`/`\w`/`\s` werden in POSIX ERE übersetzt. Nicht sicher darstellbare
Lookarounds und Rückreferenzen scheitern geschlossen; sie werden nicht mit
veränderter Bedeutung ausgeführt.

Die vollständige Referenzmatrix umfasst **60/60 byteidentische Kontexte**,
je zwölf für Deutsch, Englisch, Vietnamesisch, Chinesisch und Koreanisch.

## Vollständiger `--alles`-Lauf

Geprüfter Befehl:

```bash
reta-native \
  -spalten --alles --breite=0 \
  -ausgabe --art=html --onetable --nocolor
```

Die Python-Referenz wurde mit demselben Argumentvektor und
`PYTHONHASHSEED=0` ausgeführt. Der korrigierte native optimierte Releasebau benötigte **21,33 Sekunden**. Sein vollständiger Lauf benötigte **32,02 Sekunden**, etwa **403 MiB** Spitzenspeicher und erzeugte 24.975.753 Byte. Der Python-Lauf benötigte ungefähr **15 Minuten 47 Sekunden** und erzeugte 24.907.325 Byte. Mojo war damit in diesem vollständigen Lauf rund **29,6-mal schneller**.

Der erste semantische Vergleich fand bei identischer Struktur genau eine echte
Abweichung unter 149.356 Zellen. Der native Modallogikgenerator akzeptierte
mehrere Produkte jenseits der physischen Tabellenlänge, während das
Python-Original durch seine endliche Multiplikationsabbildung nur das erste
Produkt an beziehungsweise hinter der Dateigrenze materialisiert.

`generated_table_columns.mojo` begrenzt den Produktlauf nun auf das erste
Vielfache an oder hinter der realen Tabellenlänge. Ein Regressionstest mit dem
realen Religionsbestand hält die asymmetrischen letzten Zählungen fest.

Der korrigierte unoptimierte Kontrollbau entstand in **36,71 Sekunden**. Sein
vollständiger `--alles`-Lauf benötigte **1:51,54 Minuten**, rund **406 MiB**
Spitzenspeicher und ergab:

```text
Tabellenzeilen:                    198 / 198
Tabellenzellen:                149.356 / 149.356
rohe HTML-Zellen identisch:    142.743 / 149.356 = 95,572324 %
dekodierte Texte identisch:    146.699 / 149.356 = 98,221029 %
semantische Zellen identisch:  149.356 / 149.356 = 100,000000 %
```

Die verbleibenden Rohunterschiede bestehen aus Entity-/Anführungszeichen-
Maskierung, unsichtbarem Leerraum vor Satzzeichen und unterschiedlicher
Reihenfolge innerhalb semantisch ungeordneter HTML-Listen. Sie werden nicht als
Byteparität ausgegeben. `scripts/compare_full_all_html.py` prüft streng Form,
Zellzahl und normalisierten Zellinhalt und meldet diese Serialisierungsebene
separat.

## Compiler- und Integrationsgrenze

Die drei neuen Module und ihre ausführbaren Tests kompilieren optimiert in
wenigen Sekunden. Ein direkter zusätzlicher Import der neuen Regexschicht in
den bereits sehr großen produktiven Promptcontroller ließ den optimierten
Mojo-Paketgraphen in dieser Umgebung dagegen unverhältnismäßig anwachsen. Die
Änderung wurde deshalb nicht als scheinbar fertige Produktverdrahtung im
Controller belassen.

Der native Besitzer ist vollständig aufrufbar und referenzgetestet; die letzte
Aktivierungsnaht des interaktiven Controllers bleibt ausdrücklich sichtbar.
Damit wird `prompt_preparation.py` in der Matrix als **weitgehend nativ mit
offener Aktivierungsnaht**, nicht fälschlich als vollständig aus dem
Produktpfad verschwunden gezählt.

## Fehlerkatalog

- `MOJO-FIXED-023`: Modallogikprodukte liefen über die historische endliche
  Tabellenabbildung hinaus.
- `MOJO-COMPAT-001`: vollständiger Tabelleninhalt ist semantisch paritätisch,
  die HTML-Serialisierung aber noch nicht byteidentisch.
- `TEST-FIXED-004`: das bisherige `--alles`-Gate prüfte nur eine kleine
  Fixturezeile und konnte den Grenzfehler nicht entdecken.
- `TEST-FIXED-005`: der ältere vordere Promptvorbereitungscheck setzte eine
  lokale `.venv/bin/python` voraus; er verwendet nun denselben portablen
  `RETA_PYTHON`/`.venv`/`python3`-Fallback wie die neuen Source-only-Gates.
- `TEST-FIXED-006`: ein gemeinsamer Source-Pytest-Prozess blieb nach
  vollständig ausgegebenen Testpunkten im Teardown hängen; der Stage-Runner
  isoliert die fünf Testdateien nun in eigene Prozesse.

Das Python-Original bleibt unverändert; es ist für die Produktgrenze die
korrekte Referenz.

## Validierung

```text
Prompt-Vorbereitungs-Unit-Tests:          7/7
Generierte-Tabellenspalten-Tests:        10/10
bisherige Frontparität:                  23/23
vollständige Fünfsprachenparität:        60/60
Katalogregeneration:               reproduzierbar
vollständige Tabellenstruktur:          198/198 Zeilen
vollständige semantische Zellparität: 149.356/149.356
aktive std.python-Brücken:                   0
```

Reproduzierbare Befehle:

```bash
scripts/check_prompt_preparation_parity.sh
scripts/check_prompt_preparation_full_parity.sh
scripts/check_prompt_language_catalog.sh
scripts/check_full_all_parity.sh
scripts/test_stage12c4w.sh
```

Der vordere Paritätscheck ist nach der Stage auch aus einem Source-only-Baum ohne Projekt-`.venv` ausführbar. Der schwere Python-Vergleich wird im Sammeltest bewusst mit
`RETA_RUN_FULL_ALL=1` aktiviert; die bereits geprüfte Ausgabe wird nicht bei
jedem kleinen Source-Gate erneut für fast 16 Minuten erzeugt.

## Fortschrittswirkung

Konservativ gezählt steigt `prompt_preparation.py` zunächst nur in die Gruppe
**mindestens teilweise/weitgehend nativ**, weil die letzte produktive
Controller-Aktivierungsnaht noch offen bleibt:

- vollständig native/reproduzierbar generierte Originaldateien:
  **40/92 = 43,5 %**,
- mindestens teilweise portierte Originaldateien:
  **69/92 = 75,0 %**,
- gewichteter Quellzeilenstand:
  **ca. 55,6 % → ca. 56,5 %**,
- funktionale Oberfläche:
  weiterhin **96–98 %**.

Der wichtigere messbare Fortschritt dieser Stage ist die erstmalige
vollständige semantische Parität des realen `--alles`-Tabellenlaufs.
