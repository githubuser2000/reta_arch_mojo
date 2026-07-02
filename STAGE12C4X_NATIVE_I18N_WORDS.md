# Stage 12c4x – nativer fünfsprachiger `i18n.words`-Besitz

## Ziel

Stage 12c4x übernimmt den wirksamen Daten- und Funktionsvertrag der fünf
aktiven gesplitteten Python-Besitzer:

- `i18n/words.py`,
- `i18n/words_bootstrap.py`,
- `i18n/words_context.py`,
- `i18n/words_matrix.py`,
- `i18n/words_runtime.py`.

Zusammen umfassen sie **5.485 Python-Zeilen**. Der historische
`i18n/words_legacy_monolith.py` bleibt getrennt als eingefrorene
Kompatibilitätsreferenz sichtbar und wird in dieser Stage ausdrücklich nicht
als portiert gezählt.

## Reproduzierbarer nativer Baumkatalog

`tools/generate_i18n_words_catalog.py` importiert die gefrorene Referenz in
fünf getrennten Sprachzuständen und serialisiert deren effektive öffentliche
Domänenoberfläche nach `assets/i18n_words/*.tsv`.

Der Katalog bewahrt:

- Reihenfolge von Dictionaries, Listen und Tupeln,
- deterministisch sortierte historische Mengen,
- Named-Tuple-Felder von `ParametersMain`,
- 431 Einträge von `paraNdataMatrix`,
- Klassenattribute von `tableHandling`, `concat`, `lib4tables`, `retapy`,
  `nested`, `retaPrompt`, `csvFileNames` und `readMeFileNames`,
- geteilte Objektidentität als explizite `ref`-Knoten,
- alle sprachabhängigen skalaren Werte,
- Funktionssignaturen der eigenen öffentlichen Funktionen,
- die fünf übersetzten Ergebnisse von `classify`.

Der Bestand umfasst:

```text
deutsch        6.927 Knoten
english        6.935 Knoten
vietnamese     6.935 Knoten
chinese        6.935 Knoten
korean         6.935 Knoten
--------------------------------
gesamt        34.667 Knoten
```

`assets/i18n_words/manifest.json` hält Format, Quellmodule, Zeilenzahlen,
Modulanteile und SHA-256-Digests fest. Die Regeneration ist für alle fünf
Sprachen byteidentisch.

## Native Laufzeit

`src/reta_mojo/i18n_words.mojo` besitzt den Laufzeitvertrag ohne
`std.python`, Pythonobjekte, gettext oder dynamische Imports. Er bietet:

- kanonische Sprachaliasauflösung,
- portable Assetpfade über `resource_paths.mojo`,
- byteerhaltendes TSV-Escaping und -Decoding,
- typisierte `I18nWordNode`- und `I18nWordsCatalog`-Strukturen,
- Modul-, Wurzel- und Snapshotzählung,
- Pfad-, String- und Integerabfragen,
- verlustfreie Rückserialisierung,
- `classify_i18n_relation`,
- `duplicate_i18n_strings` als native Entsprechung von
  `finde_mehrfache_vorkommen`,
- die beiden Debugausgabegrenzen des Bootstrapmoduls.

Das öffentliche Inspektionsprogramm `reta-mojo-i18n` kann Zusammenfassungen,
Einzelpfade, Klassifikationen und den vollständigen Baum ausgeben. Es wird als
zehntes reguläres Ziel von `scripts/build.sh` gebaut und bei FHS-Installation
zusammen mit den Katalogassets installiert.

## Parität

```text
native Unit-Tests:                 7/7
Katalogregeneration:               5/5 Sprachen byteidentisch
Mojo-Rückserialisierung:           5/5 Sprachen byteidentisch
native Baumzeilen:            34.667/34.667
Source-/Ownership-Tests:           6/6
aktive std.python-Brücken:           0
```

Die Rückserialisierung ist stärker als eine Stichprobe: Mojo lädt jeden Knoten
aller fünf Sprachen, decodiert ihn in typisierte Strukturen und schreibt ihn
wieder exakt in den generierten TSV-Strom.

## Python-Originalfehler

`PY-CAND-008` dokumentiert einen bereits im Python-Original vorhandenen
Diagnosefehler. `wrongLangSentence` nennt `-languages=` statt des tatsächlich
ausgewerteten Parameters `-language=` und baut die erlaubte Werteliste direkt
aus `sprachen.values()`, wodurch `en`, `de`, `vn`, `cn` und `kr` mehrfach
erscheinen. Mojo konserviert diesen Text zunächst bytegenau. Die spätere
Python-Bereinigungsphase soll Parametername, Deduplizierung und Reihenfolge
bewusst gemeinsam mit neuen Soll-Fixtures korrigieren.

## Fortschrittswirkung

Die fünf aktiven Splitmodule wechseln vollständig aus der Kategorie
Python-Referenz/Bridge in nativen beziehungsweise reproduzierbar generierten
Besitz:

- vollständig native oder generierte Originaldateien:
  **40/92 → 45/92 = 48,9 %**,
- mindestens teilweise portierte Originaldateien:
  **69/92 → 74/92 = 80,4 %**,
- gewichteter Quellzeilenersatz:
  **ca. 56,5 % → ca. 67,7 %**,
- funktionale Oberfläche:
  weiterhin **96–98 %**.

Der starke Sprung beim Quellersatz entsteht nicht durch eine neue
Nutzerfunktion, sondern durch den Besitzerwechsel eines sehr großen, bisher
nur indirekt über kleinere generierte Promptkataloge abgebildeten i18n-Daten-
und Runtimeblocks.

## Reproduzierbare Befehle

```bash
scripts/check_i18n_words_catalog.sh
scripts/check_i18n_words_native_parity.sh
scripts/test_stage12c4x.sh
./bin/reta-mojo-i18n --summary english
./bin/reta-mojo-i18n --classify deutsch 3
```

## FHS-Launcher-Korrektur

Die erweiterte Installationsprüfung entdeckte `MOJO-FIXED-024`: 16 native
Inspektionslauncher bestimmten `ROOT` unmittelbar aus `$0`. Bei der regulären
FHS-Installation ist `$0` jedoch ein öffentlicher Symlink unter `/usr/bin`,
während der eigentliche Launcher unter `/usr/lib/reta/bin` liegt. Dadurch
suchten die Starter ihre Compilerziele fälschlich unter `/usr/target/bin`.

Alle betroffenen Launcher lösen jetzt zuerst den realen Pfad mit `readlink -f`
auf und leiten den Projektstamm anschließend aus diesem Zielpfad ab. Der neue
Source-Test prüft diese Regel für alle 16 Starter; die FHS-Prüfung startet den
installierten `reta-mojo-i18n` aus einem fremden Arbeitsverzeichnis und prüft
Sprach-, Zeilen- und Matrixzählung.

## Portable Katalogpfade

Die separate Entpackprüfung entdeckte `MOJO-FIXED-025`: Die Pythonmodule
exportieren `localedir` beziehungsweise `i18nPath` als absoluten Importpfad.
Der erste Generator übernahm diesen Wert wörtlich, wodurch der Katalog an den
Checkoutpfad der erzeugenden Sandbox gebunden war. Der Generator normalisiert
solche Werte jetzt deterministisch auf `python_reference/i18n`. Damit ist der
Katalog nach Entpacken unter einem beliebigen Pfad byteidentisch regenerierbar
und enthält keine Benutzer-, Sandbox- oder Buildverzeichnisse.
