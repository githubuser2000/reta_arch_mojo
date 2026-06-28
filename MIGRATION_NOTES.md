# Migrationsnotizen Python → Mojo

## 1. Keine mechanische Umschrift

Im Python-Bestand wurden 1.117 unvollständig typisierte Funktionen, 89 `getattr`-Aufrufe, 50 `*args`- und 50 `**kwargs`-Stellen gefunden. Diese Dynamik wurde nicht durch ein universelles `PythonObject` im nativen Kern verdeckt. Stattdessen werden stabile Domänen explizit typisiert und noch dynamische Bereiche bleiben sichtbar an der Bridge.

## 2. Ownership und Lebensdauer

Beim Bereichsparser zeigte sich ein konkreter Unterschied: Ein `StringSlice` darf nicht weiterverwendet werden, nachdem der zugrunde liegende `String` verändert wurde. Der Mojo-Port materialisiert solche Ausschnitte deshalb vor Mutationen als besitzende `String`-Werte.

Topologische Auswahlen verwenden ebenfalls Besitzwerte. Mengen werden beim Bilden neuer Auswahlen kopiert oder transferiert; die Eingaben universeller Konstruktionen bleiben unverändert.

## 3. Bereichssyntax ohne `eval`

Die Python-Implementierung akzeptiert Mengen-/Listen-/Tupelliterale über eine dynamische Auswertung. Mojo akzeptiert dieselbe legitime Form wie `{1,2,5}`, `[1,2,5]` oder `(1,2,5)`, parst aber ausschließlich vorzeichenbehaftete Ganzzahlen. Ausführbarer Python-Code wird bewusst nicht akzeptiert.

Das ist eine Sicherheits- und Typverbesserung, keine versehentliche Abweichung.

## 4. Exakte Ganzzahlarithmetik

`moon_number()` prüft Potenzen exakt mit Ganzzahlen. Die Python-Fassung erkennt ganzzahlige Wurzeln über gerundete Fließkommawerte auf fünf Nachkommastellen. Der Mojo-Port vermeidet dadurch mögliche Rundungsfehlklassifikationen.

## 5. Homogene Rückgabetypen

Die historische Prime-Repeat-Darstellung mischt teilweise Zahlen und Zeichenketten. Mojo trennt:

- `prime_repeat_pairs()` → typisierte `(Primzahl, Anzahl)`-Paare
- `prime_repeat_labels()` → homogene `String`-Darstellung

## 6. Dictionary-Invertierung

Die Python-Fassung enthält bei der Prüfung bereits gespeicherter Schlüssel einen String/Integer-Typkonflikt. `invert_int_value_dict()` bewahrt im Mojo-Port alle verschiedenen Quellschlüssel pro Integerwert. Diese Stelle ist als bewusste Fehlerkorrektur markiert.

## 7. Topologie

Python kodiert eine unbeschränkte Dimension als `None` und eine beschränkte als `frozenset`. Mojo verwendet:

```text
SelectionDimension(restricted: Bool, values: Set[String])
```

Dadurch bleiben die mathematisch verschiedenen Fälle

- unbeschränkt und
- beschränkt auf die leere Menge

explizit unterscheidbar. `refine_selection()` bildet den komponentenweisen Meet/Schnitt.

## 8. Kategorien, Funktoren und natürliche Transformationen

Die großen statischen Architekturdaten werden nicht von Hand doppelt gepflegt. `tools/generate_category_theory.py` lädt den Snapshot der Python-Referenz und erzeugt daraus typisierte Mojo-Strukturen. Tests prüfen die Anzahl sowie benannte Elemente.

Die Generierung ist eine Migrationshilfe. Zur Laufzeit benötigt der native Katalog kein Python.

## 9. Prägarben

Die Python-Prägarbe erlaubt beliebige Objekt-Payloads. Der native Kern beginnt bewusst mit `LocalStringSection`. Weitere Payload-Arten sollten als markierte Varianten ergänzt werden, nicht durch Rückkehr zu untypisierten Python-Objekten.

## 10. Ausgabe

Nativ sind Modusauflösung, Flags, statische Tabellen-/Zellensyntax und die Zahlklassen-abhängige HTML-/BBCode-Zeilenfärbung. Der komplexe HTML-Kopf hängt von dynamischen Tabellenmetadaten ab und bleibt vorerst in Python.

## 11. Parallelisierung

Die native `divisor_range()`- und Bucket-Normalisierung arbeitet momentan deterministisch sequenziell. Die Python-Prozessparallelisierung wurde nicht blind übernommen. Sie sollte erst nach einer nativen Datenfluss- und Kostenanalyse als Mojo-Parallelalgorithmus ergänzt werden.

## 12. Kompatibilitätsprozess

`compat_main.mojo` startet die Python-Referenz in einem separaten Prozess. Ein direkter CPython-In-Process-Aufruf funktionierte für kleine Module, blieb bei der kompletten Reta-Laufzeit wegen globalem Zustand und Laufzeitressourcen beim Beenden hängen. Prozessisolation ist hier die robustere Übergangsarchitektur.

## 13. Bekannte Baseline-Abweichungen des Uploads

Die unveränderte Python-Referenz kompiliert, aber ihre Tests waren beim Eingang nicht vollständig grün: 70 Tests liefen, 3 schlugen fehl und 1 war übersprungen. Zwei Fehler erwarten eine `dataDict`-Größe von 554 statt der tatsächlichen 556; ein weiterer erwartet einen älteren Orchestrierungsnamen. Diese Fehler wurden nicht dem Mojo-Port zugerechnet und nicht heimlich in der Referenz geändert.

## Werkzeug-Namenskonflikt unter Linux

Ein im Snap Store angebotenes Programm namens `mojo` gehört zu Canonicals Juju-Ökosystem und ist nicht der Modular-Mojo-Compiler. Alle Launcher gehen deshalb über `bin/mojo-real`. Dieser Resolver bevorzugt `.venv/bin/mojo`, unterstützt `MOJO_BIN`, verwirft `/snap/mojo/...` und gibt eine gezielte Installationsanleitung aus.


## 14. Reales Kontextschema und Parametersemantik

`schema_catalog.mojo` wird aus dem realen `i18n.words`-Bestand erzeugt. Zur Mojo-Laufzeit werden dafür keine Python-Module mehr importiert. Der Snapshot enthält 33 Hauptparametergruppen, 431 Matrixeinträge, die Kontext-Mappings und sieben Tag-Namen.

`parameter_semantics.mojo` baut daraus besitzende, typisierte Aliasgruppen, kanonische Parameterpaare, direkte Spaltenmengen und die Rückabbildung Spalte → Parameterpaare. Der neue CLI-Pfad `--mojo-columns` nutzt ausschließlich diesen nativen Datenpfad.

## 15. Stabilisierung ungeordneter Python-Alias-Sets

Fünf Einträge der Python-`paraNdataMatrix` verwenden für Unterparameter ein `set`. Vier davon enthalten die Zahlenzeichenketten `2` bis `23`. Die Python-Schicht bestimmt den kanonischen Namen aus dem ersten Set-Element; dieser kann sich durch die Hash-Reihenfolge zwischen Prozessen ändern.

Der Generator normalisiert ausschließlich solche ungeordneten Mengen numerisch bzw. lexikographisch. Geordnete Tupel bleiben unverändert. Damit ist der native Snapshot reproduzierbar und besitzt für diese vier Gruppen einen stabilen kanonischen Namen statt eines zufälligen Hash-Seed-Ergebnisses.

## 16. Vollbestands-Parität ohne riesige Testquellen

Der Schemaabgleich prüft alle 86 Hauptaliase, 1.355 Unterparameter-Aliase und 428 Paare. Statt tausende Erwartungszeilen in eine einzelne Mojo-Testfunktion zu schreiben, erzeugt Python reproduzierbare modulare Fingerprints über jeden Datensatz. Mojo berechnet dieselben UTF-8-basierten Fingerprints aus seinen nativen Strukturen. Zusätzlich prüfen konkrete Beispiele die lesbare Semantik, etwa `religionen/sternpolygon → [0, 6, 36]`.

## 17. Python 3.14

`scripts/setup_mojo.sh` enthält keine feste Python-3.13-Abhängigkeit mehr. Es bevorzugt ein vorhandenes `python3.14`, akzeptiert den offiziell unterstützten Bereich 3.10 bis 3.14 und lässt sich mit `RETA_MOJO_PYTHON` explizit steuern.


## 18. CLI-Normalisierung als besitzende Zwischenrepräsentation

Die historische Parameterlaufzeit trägt einen veränderlichen Integer `lastMainCmd` durch eine große Methode und wertet positive und negative Parameter in zwei getrennten Durchläufen aus. Der Mojo-Port materialisiert zuerst `CliParseResult`, `ParsedCliOption` und `CliValue`. Abschnitt, Optionsname, Gleichheitszeichen, Einzelwerte und Polarität sind dadurch typisiert und unabhängig vom späteren Tabellenzustand testbar.

Der neue Befehl `--mojo-parse-cli` zeigt diesen Pfad direkt. Für `-spalten` werden Werte anschließend über `ParameterSemanticsSheaf` kanonisiert. Beispiel: `--religionen=sternpolygon,-gleichfoermigespolygon` ergibt positive Spalten `[0, 6, 36]` und negative Spalten `[16, 37]`.

## 19. Schemaabgeleitetes Parameter-Vokabular

Unabhängig vom später portierten Promptcontroller baut Mojo ein kompaktes Parameter-Vokabular aus dem nativen Schema: sieben Hauptparameter, 90 Spaltenoptionen, 33 kanonische Spaltengruppen, 15 Zeilenoptionen, 14 Ausgabeoptionen, drei Kombinationsoptionen und sieben Ausgabemodi.

Dieses Vokabular ist absichtlich dedupliziert. Es ist semantisch kompakter als die historische Python-Liste, die Hauptnamen aus jedem Paar wiederholt. Der vollständige Prompt-Completionkatalog wird getrennt in Abschnitt 23 beschrieben.

## 20. Gemeinsamer nativer Promptcontroller statt fünf Kopien

Die historischen Dateien `retaPrompt`, `rp`, `rpl`, `rpb` und `rpe` unterscheiden sich überwiegend durch vorangestellte Startparameter. Der Port erzeugt deshalb keine fünf divergierenden Mojo-Implementierungen. `PromptProfile` modelliert Vi-/Emacs-Modus, Logging, `-e`, One-shot-Verhalten, Sprache, Intro und Emacs-Ausgabe. Alle öffentlichen Namen starten denselben `prompt_main.mojo`-Controller mit einem anderen Profil.

## 21. Sitzungszustand und Befehlsspeicher

Die interaktive Schleife und ihr Zustand sind nun Mojo. `NativePromptSession` besitzt Loggingstatus, vorherigen Befehl, gespeicherte Tokens sowie den nächsten Speicher- oder Löschmodus. Die historischen Befehle `S`, `s`, `o` und `l` werden nicht mehr durch globale Python-Variablen getragen. Das Löschen akzeptiert sowohl Bereichsausdrücke als auch konkrete Tokenwerte.

## 22. Promptausführung und Fallbackgranularität

`prim`, `prim24`, `multis`, `modulo` und `abc` laufen vollständig nativ. Direkte `reta`-Aufrufe und noch nicht portierte komplexe Kurzbefehle überschreiten eine sichtbare Prozessgrenze. Entscheidend ist die Granularität: Nicht der gesamte Prompt fällt auf Python zurück. Nur der einzelne Befehl wird ausgelagert; Mojo behält Schleife, Profil, Historypolitik und Sitzungszustand.

Die Befehle `shell`, `python` und `math` sind ihrem Zweck nach Prozess-/Interpretergrenzen. Sie werden vom Mojo-Dispatcher erkannt, ihre Betriebssystemausführung bleibt aber im kleinen Bridge-Modul.

## 23. Completion-Katalog

`scripts/generate_prompt_catalog.py` extrahiert 388 Start- und Kurzbefehlswörter aus der Referenz und schreibt sie als `List[String]` nach `prompt_catalog.mojo`. Tab-Vervollständigung benötigt dadurch zur Laufzeit weder den Architektur-Bootstrap noch dynamische Python-Completionobjekte. Die kontextsensitive verschachtelte Completion ist noch nicht vollständig portiert.

## 24. Historische Binärnamen und Pfadkompatibilität

Die dokumentierten Laufzeitnamen sind im Wurzelverzeichnis, in `bin/` und in `run/` verfügbar. `reta.sh`, `rp.sh` und `rpl.sh` bleiben als Aliase bestehen, aktivieren aber keine Umgebung mehr. Der Resolver findet `.venv/bin/mojo` selbst. `scripts/install_bins.sh` verlinkt die Programme optional nach `~/.local/bin`.

Entwicklungs- und Releasehelfer wie `coden`, `csvs`, `rpmake` oder `generate_html` gehören nicht zur transpilierten Laufzeit. Sie steuern lokale Git-Branches, Editoren, LibreOffice, Veröffentlichungsarchive oder fest codierte Rechnerpfade und werden deshalb nicht fälschlich als Mojo-Fachlogik ausgegeben.
