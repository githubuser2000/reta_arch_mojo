# Wiederverwendbare Python-`--alles`-Referenz

Der vollständige Python-Lauf ist langsam und muss nicht für jede reine
Mojo-Stage wiederholt werden. Solange weder `python_reference`, die CSV-Dateien
noch der Python-Renderer verändert wurden, bleibt dieselbe Referenzausgabe
gültig.

## Referenz einmal lokal erzeugen

```sh
scripts/create_full_all_reference_bundle.sh
```

Das erzeugt standardmäßig:

```text
target/references/reta-python-full-all-reference.tar.bz2
```

Das Paket enthält die vollständige HTML-Ausgabe, SHA-256, Dateigröße,
Tabellenform, Python-Version, Laufzeit und Spitzenspeicher.

Eine bereits vorhandene Ausgabe kann ohne erneuten Stundenlauf verpackt werden:

```sh
RETA_FULL_ALL_HTML=/pfad/python-all.html \
  scripts/create_full_all_reference_bundle.sh
```

## Mojo gegen die gespeicherte Referenz prüfen

```sh
scripts/check_full_all_against_reference.sh \
  target/references/reta-python-full-all-reference.tar.bz2
```

Oder über das bisherige Gesamtgate:

```sh
RETA_FULL_ALL_REFERENCE=/pfad/reta-python-full-all-reference.tar.bz2 \
  scripts/check_full_all_parity.sh
```

Der Python-Lauf wird dann nicht erneut ausgeführt. Die native Tabelle wird neu
erzeugt und vollständig auf Struktur und semantische Zellparität geprüft. Im
Projekt liegt zusätzlich die vom Nutzer erzeugte Referenz bereits unter
`tests/references/reta-python-full-all-reference-v1.tar.bz2`; deshalb funktioniert
`scripts/check_full_all_against_reference.sh` auch ohne Argument.

Wurde die Python-Ausgabe ohne festgelegten `PYTHONHASHSEED` erzeugt, markiert das
Paket sie als `uncontrolled`. Der Vergleich richtet dann gleiche beziehungsweise
doppelte Überschriften vorkommensgenau aus, weist die bekannten set-abhängigen
Generatorspalten separat aus und verlangt für alle reproduzierbaren Zellen 100 %
semantische Gleichheit. Ein neuer lokaler Referenzlauf sollte künftig mit
`PYTHONHASHSEED=0` erzeugt werden.

## Wann eine neue Python-Referenz nötig ist

Eine neue Referenz ist nötig, wenn sich mindestens einer dieser Bereiche ändert:

- Dateien unter `python_reference/`,
- produktive CSV-Daten,
- die gewollte Python-Ausgabe- oder HTML-Semantik,
- der festgelegte `PYTHONHASHSEED` oder die maßgebliche Python-Version.

Reine Mojo-Refactorings, Compileroptimierungen und native Ownership-Verschiebungen
verwenden weiterhin das bestehende Referenzpaket.

## Sinnvolle Arbeitsteilung mit einem schnellen lokalen Rechner

Für große optimierte Gesamtbauten ist der lokale Rechner maßgeblich, wenn dort
`scripts/build.sh` und `scripts/build-heavy.sh` in ungefähr vier Minuten
fertig werden. Der Quellstand wird hier mit fokussierten Besitzer-, Paritäts-
und Source-Gates geprüft; der Nutzer kann anschließend lokal ausführen:

```sh
scripts/build-heavy.sh 2>&1 | tee build-heavy.log
scripts/build.sh 2>&1 | tee build.log
```

Bei einem Fehler reichen das aktuelle Quellarchiv und die beiden Logs. Bereits
fertige Binärdateien müssen nicht in das Sourcearchiv aufgenommen werden.

Das jeweils neueste vollständige Sourcearchiv sollte pro Iteration weiterhin
einmal hochgeladen werden, weil kein gemeinsamer dauerhafter Projektbaum
existiert. Dasselbe unveränderte Archiv muss innerhalb derselben Iteration
nicht mehrfach hochgeladen werden.
