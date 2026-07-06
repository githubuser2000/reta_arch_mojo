## Stage 12c5bk – hermetische Parität und klassische Bruchgrenzen

- `scripts/check_command_parity_native.py` ignoriert geerbte installierte `RETA_*`-Ressourcenpfade und bindet die vier repräsentativen Fälle zwingend an den aktuellen Source-Tree.
- Der Bruchteilerpfad stellt die äußere Zeile `1` vor nichttrivialen Divisoren wieder her, ohne den Wert-1-Spezialfall zu duplizieren.
- Klassische ganzzahlgebundene Tabellenfamilien werden nur durch tatsächlich geschriebene gewöhnliche Ganzzahlsyntax aktiviert, nicht durch aus echten Brüchen projizierte Ganzzeilen.
- `scripts/test_stage12c5bk.sh` prüft die native Kommando-Parität absichtlich unter verschmutzter Ressourcen-Umgebung und kompiliert anschließend den vollständigen True-Fraction-Probe.

## Stage 12c5bj – read-only gepinnte Kommando-Paritätsassets

- `generate_command_parity_assets.py --check` prüft jetzt fünf fest versionierte SHA-256-Verträge und startet den Python-Renderer nicht.
- `--check-reference` ist der ausdrückliche, interpreterabhängige Entwicklervergleich.
- Die Stages 12c5aq, 12c5bg und 12c5bh migrieren keine Quelldateien mehr.
- Bereits kanonische `--migrate-legacy`-Aufrufe sind ohne Referenzausführung idempotent; unbekannte oder mit dem aktiven Interpreter nicht reproduzierbare Zustände bleiben harte Fehler.
- Der auf Python 3.14 gemeldete Abbruch bei den bereits kanonischen Hashes `a8a0d2a1…` und `9fdefe9a…` ist damit geschlossen.

## Stage 12c5bi – Compileroptionen und verbleibende Bruch-Teilergrammatik

- Testbuildoptionen werden hinter `--` bis zum einzelnen `mojo build` bewahrt; Laufzeitjobs bleiben ein unabhängiger Runnerparameter.
- `String.strip()` wird an mutierbaren Testgrenzen ausdrücklich wieder in einen besitzenden `String` materialisiert.
- Der 19-Aufruf-Mehrdomänenplan besitzt die Blockgrenze Emotion 0–5, Universe-Ganzzahl 6, Universe-Reziprok 7.
- Separat negative Prompttokens sind konsumierte No-ops; nichtpositive Teilerachsen verwenden Divisorvereinigung, optionale Rohwiederholung und abschließende `v`-Formen.
- Eine zusätzliche unabhängige Tabellenfamilie wie `mond` neben mehreren Bruchdomänen bleibt die nächste explizite Kompatibilitätsgrenze.

# Migration Notes – Stage 12c5bg

## Referenzassets besitzen nun ihre Präsentationslaufzeit

Die Kommando-Paritätsmatrix war fachlich kanonisch, ihre Markdown-/HTML-Serialisierung jedoch nicht vollständig reproduzierbar: der eingefrorene Python-Baum importiert optional `rich`, und der Generator erbte die auf dem Testrechner installierte Version. Das widersprach dem Besitzmodell generierter Assets. Stage 12c5bg fügt deshalb keine Änderung in `python_reference` ein, sondern gibt dem Generator eine minimale lokale Präsentationslaufzeit. Sie wird über ein vorangestelltes `PYTHONPATH` geladen, während `PYTHONNOUSERSITE=1` Benutzerpakete ausschließt. Der beobachtbare Referenzstrom entspricht weiterhin den bereits versionierten Assets, ist aber unabhängig von Rich-Version und Python-Umgebung.

## Gewöhnliche Vielfachen sind keine Bruchprojektionen

Bei `v n/m` entstehen aus dem physischen CSV-Rechteck ganzzahlige Projektionen. Eine danebenstehende gewöhnliche Zahl wie `5` bezeichnet dagegen eine eigene Vielfachenachse. Beide Mengen dürfen nicht gemeinsam in `--vielfachevonzahlen` gelangen: Sonst würden bereits projizierte Werte ein zweites Mal expandiert. `_base_projected_fraction_multiple_tokens` bildet daher drei getrennte Abschnitte: projizierte Ganzzahlen, originale positive Komponenten und deren `v`-Präfixe. Die Option erhält nur die originalen Komponenten.

Dieselbe Basis wird für den bisherigen Ein-Domänenpfad und für alle von 12c5bf eingeführten domänenspezifischen Mehrfachpläne verwendet. Damit ist das Kompositionsgesetz nicht dupliziert. `teiler`/`w` bewahrt die Zeilensuffixe, unterdrückt aber die gewöhnliche Vielfachenoption entsprechend der instrumentierten Referenz.

Die Freigabe ist absichtlich eng: ausschließlich positive Werte und positive Bereiche. Null, in-token Ausschlüsse und separat negative Parameter besitzen in Python andere Zweige und bleiben bis zu einer eigenen Stage atomar.

# Migration Notes – Stage 12c5bf

## Domänenspezifische Bruchvielfachen statt eines globalen Rechtecks

Ein Prompt kann mehrere physische `n/m`-Tabellenfamilien zugleich auswählen. Diese Familien sind nicht formgleich; ein gemeinsames Maximum würde entweder Daten abschneiden oder nicht vorhandene CSV-Koordinaten erzeugen. Der native Plan besitzt deshalb vier getrennte `_FractionMultipleDomain`-Werte und erzeugt pro ausgewählter Familie ein eigenes Raster samt Ganzzahl- und Reziprokprojektion.

Die Ausführungsreihenfolge bleibt die historische unabhängige `if`-Reihenfolge: Emotion, Strukturgröße, Motive/Galaxie, Universum. Nur Universum ergänzt die Gleichheitsachse. Bei mehreren Familien verwendet Universum wie die Referenz die schmalen Spaltenmengen, weil Domänenwahl plus implizites `vielfache` bereits mehr als zwei Promptkommandos bilden.

Die neue Grenze ist bewusst enger als „alles mit mehreren Domänen“: gewöhnliche Ganzzahlen, Eigenschaften und zusätzliche klassische Tabellenfamilien werden nicht opportunistisch teilweise ausgeführt, sondern lassen den gesamten Vektor am Kompatibilitätsrand. Damit bleibt die Transaktionalität des Promptcontrollers erhalten.

# Migration Notes – Stage 12c5be

- Ein Konfigurationsfeld ist erst dann Besitz, wenn alle abhängigen I/O-Grenzen es tatsächlich verwenden. `ProgramWorkflowBundle.repo_root` war zuvor nur Snapshotmetadatum; nun fließt es bis Religion- und Motiv-CSV.
- Test-Fixtures werden als typisierte Abhängigkeiten modelliert, nicht als versteckte Prozessumgebung. Dadurch prüfen fokussierter Test und Release-Gesamtsuite denselben Vertrag.
- Zwei Parser dürfen unterschiedliche Oberflächen besitzen, aber ein Workflow darf nicht zwei widersprüchliche Ausgabemodi tragen. Die lokalisierte Rich-Text-Erkennung wird deshalb am Workflow-Gluing-Knoten in den allgemeinen Laufzeitplan synchronisiert; CSV/Markdown/Emacs/Shell bleiben beim allgemeinen Parser.

# Migration Notes – Stage 12c5am

- Unveränderliche Architektursnapshots dürfen keine Hardwareinventur enthalten. Reale Parallelität bleibt dynamisch, der katalogisierte Architekturvertrag verwendet dagegen acht kanonische Kerne.
- `retaPrompt.py` wird nicht als zweiter interaktiver Controller nachgebaut. Seine historische Oberfläche ist eine typisierte Fassade; beobachtbare Terminal-/Prozess-I/O bleibt beim einzigen Besitzer `prompt_main.mojo`.
- `generated_columns.py` erhält keine zweite Algorithmuskopie. Eine typisierte Request-/Result-Grenze ersetzt nur das dynamische `Concat`-Objekt und ruft die vorhandene native Pipeline in historischer Reihenfolge auf.

# Migration Notes – Stage 12c5ae

- Der Python-`ProgramWorkflowBundle` wird jetzt durch einen besitzenden Mojo-Wert mit expliziten Zwischenresultaten ersetzt.
- Positive/negative Parameter, Anzeigeauswahl und Tabellengenerierung werden nicht mehr über beliebige Attributschreibzugriffe auf ein heterogenes `Program`-Objekt gekoppelt.
- Die Renderphase bleibt eine klare Besitzergrenze zu `TableOutput`; sie ist kein dynamischer Callback.
- Private historische Helfer werden in Tests explizit importiert und nicht versehentlich als öffentliche Paketoberfläche behandelt.

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

`compat_main.mojo` ist seit Stage 12c4e native-first. Ein konservativer Ganzvektor-Prüfer führt vollständig unterstützte historische Argumente im selben Mojo-Prozess aus. Nur unbekannte oder teilweise portierte Semantik startet die Python-Referenz als separaten Prozess; `RETA_FORCE_REFERENCE=1` erzwingt diesen Pfad. Ein eingebetteter CPython-In-Process-Aufruf wird nicht mehr verwendet. Prozessisolation bleibt für die Restoberfläche die robuste Übergangsarchitektur.

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

Entwicklungs- und Releasehelfer wie `coden`, `csvs` und `rpmake` gehören nicht zur transpilierten Laufzeit. Sie steuern lokale Git-Branches, Editoren, LibreOffice, Veröffentlichungsarchive oder fest codierte Rechnerpfade. `generate_html` wurde in Stufe 4 dagegen als tatsächlicher Laufzeitgenerator erkannt und portiert.


## Stufe 4: `grundStrukHtml.py` und `generate_html`

- `grundStrukHtml.py` wurde nicht als statischer HTML-Blob übernommen. Die Referenzhierarchie wird als reproduzierbarer, lokalisierter Traversierungskatalog erzeugt; Stacksteuerung, Blattdarstellung, Checkboxattribute und HTML-Ausgabe laufen nativ in Mojo.
- Die historische ungewöhnliche Sortier-/Traversalreihenfolge bleibt erhalten. Der Generator bildet auch den alten Bool-als-Comparator-Effekt bewusst ab.
- Deutsch und der internationale Katalog enthalten jeweils 151 Renderdatensätze und 84 Blätter. Englisch, Vietnamesisch, Chinesisch und Koreanisch teilen in der vorhandenen Referenz für diese Begriffe denselben internationalen Katalog.
- Vier Ausgaben (`normal`/`blank`, Deutsch/Englisch) werden vollständig per `cmp` gegen Python geprüft.
- `generate_html` ist ein Mojo-Einstiegspunkt. Seit Stage 12b werden auch der historische zwölfteilige `--alles`-Plan und der große Tabellenmittelteil direkt über `run_native_reta` ausgeführt; ein Python-Kindprozess ist nicht mehr beteiligt.
- `middle.alx` bleibt als historischer Seiteneffekt erhalten. `head1.alx`, `religionen.js`, `head2.alx` und `footer.alx` liegen als bytegeprüfte Laufzeitassets unter `assets/html/`, nicht mehr nur im Python-Referenzbaum.
- `RETA_GENERATE_HTML_MIDDLE_FILE` ist ausschließlich eine Integrationstest-Naht für einen kleinen, deterministischen Mittelteilsnapshot. `RETA_GENERATE_HTML_ROWS` begrenzt in Integrationstests den echten Tabellenlauf, ohne die normale historische CLI zu verändern.

## Stufe 5: kompilierte Artefakte, Tabellenlaufzeit und `multis3`

### Buildgrenze

Die früheren Archive vermischten in der Dokumentation Launcher und Compilerprodukte. Diese Unterscheidung ist jetzt technisch erzwungen:

- `bin/` enthält ausschließlich versionierbare POSIX-Shell-Launcher.
- `target/bin/` enthält die mit `mojo build` erzeugten ELF-Executables.
- `target/`, `build/` und `.venv/` sind in `.gitignore`.
- `setup_mojo.sh` kompiliert nach der Installation automatisch; `RETA_SKIP_BUILD=1` unterdrückt dies.
- `check_build_layout.sh` lehnt ELF-Dateien in `bin/` ab und prüft alle erwarteten Compilerprodukte.

Die kompilierten Dateien werden nicht in das Quellarchiv aufgenommen. In der verwendeten pip/uv-Distribution referenzieren sie lokale Mojo-Runtimebibliotheken der jeweiligen `.venv`; ein fremd gebautes ELF wäre daher kein ehrliches portables Release.

### Tabellen-Tag-Schema

`tag_schema.mojo` und der generierte Katalog übertragen die sieben Tagarten sowie Primär-, Kombi- und Kombi2-Zuordnungen. Die Rückabbildung wird direkt aus der Python-Referenz erzeugt, damit auch deren Last-write-Semantik bei mehrfachen Spalteneinträgen erhalten bleibt. Vollständige Fingerprints prüfen Vorwärts- und Rückrichtung.

### Tabellenzustand und Wrapping

`table_state.mojo` ersetzt den dynamischen Zustandscontainer durch besitzende Strukturen. `table_wrapping.mojo` verwendet Codepoint-Slices und trennt dadurch Unicode-Zeichen nicht mitten in einer UTF-8-Sequenz. Wörterbuchbasierte Trennung durch externe Python-Pakete bleibt eine bewusst benannte Grenze.

### Ausgabe- und Konsolenlogik

Die reine Anwendung der sieben Ausgabemodi ist vollständig nativ. Auch deterministische Hilfen aus `console_io.py`, `runtime_compat.py`, `bbcode.py` und `html2text.py` sind übertragen. Die reine Terminalgeometrie ist seit Stage 12c1 nativ und verwendet `ioctl(TIOCGWINSZ)`; Rich-Eingabe/Styling und ausdrücklich angeforderte Interpreter-/Shellbefehle bleiben Systemgrenzen.

### `multis3`

Die Dreifach-Faktorisierung aus `multis3.py` ist nativ. Die Referenz lieferte ein Set und druckte dessen nicht zugesicherte Iterationsreihenfolge. Der Mojo-Port bewahrt die Menge, sortiert die Tripel intern und die Ergebnisliste lexikographisch. Ein generierter Referenzfingerprint prüft sämtliche Eingaben 2 bis 256.

## Stufe 6 – CSV, Zeilenfilter und nativer Reta-Pfad

- `row_filtering.py` wurde als besitzender Mojo-Zustandsautomat übertragen. Die Portierung bildet absolute und relative Bereiche, Ausschlüsse, Teiler, Zeit, Zählungsgruppen, Primklassen, Gestirntypen, Primvielfache, Potenzen, gewöhnliche Vielfache, Invertierung und Positionsfilter explizit ab.
- Der CSV-Parser besitzt einen schnellen Pfad für die großen einfachen Semikolondateien und einen vollständigen Pfad für Quotes und eingebettete Zeilenumbrüche.
- Deutsche und englische Parameteraliase werden als reproduzierbare TSV-Laufzeitdaten geladen. Dadurch muss der große Schemakatalog nicht in jedes Laufzeitprogramm einkompiliert werden.
- `reta-native` versteht eine wachsende Teilmenge der historischen deutschen und englischen Oberfläche. Der bestehende Name `reta` wechselt nur bei `RETA_NATIVE=1` auf diesen Pfad; ohne Variable bleibt die vollständige Kompatibilitätsausführung erhalten.
- CSV, Markdown und Emacs reproduzieren im projektlokalen Kompatibilitätsumfeld die Referenzbytes. Das optionale Python-Paket Rich kann die sichtbare Referenzausgabe selbst verändern; die Releaseprüfung verwendet deshalb ausdrücklich den projektlokalen Referenzinterpreter.
- Die Compilerziele wurden weiter entkoppelt: leichtes Tabellenziel, separates Tag-Schema sowie optionale schwere Schema-/Architekturziele.

## Stufe 7 – Generatorreihenfolge, Aliaskollisionen und Bruchrelationen

- Die historische `paraNdataMatrix` ist keine reine Mehrfachzuordnung. Beim Aufbau von `paraDict` überschreibt ein späterer Eintrag einen früheren Eintrag desselben `(Hauptalias, Unteralias)`-Paars. Der generierte Mojo-Aliaskatalog bildet deshalb Last-write-wins ab. So aktiviert das englische `multiplications=motifStar` ausschließlich `primMotivSternGebr`, nicht zusätzlich den älteren Ganzzahlpfad.
- Das Python-Original verwendet für mehrere Generatoren normale Sets als Ersatz für `OrderedSet`. Sichtbare Ausgabereihenfolgen hängen dadurch vom CPython-Hashlayout ab. Die Referenzextraktion läuft mit `PYTHONHASHSEED=0`; Primzahlkreuz und Bruchrelationen bewahren genau diese festgelegte Reihenfolge.
- Die 71.820 Bruchrelationen werden beim Build nicht durch eine ähnlich aussehende Neuimplementierung erzeugt. `generate_fraction_pair_catalog.py` ruft die originalen, isolierten Relationsfunktionen aus `meta_columns.py` und `concat_csv.py` auf und serialisiert deren Ergebnis. Die Mojo-Laufzeit lädt anschließend nur das deterministische TSV-Asset und benötigt für den Algorithmus kein Python.
- Die Referenz benutzt für eigentliche Bruchzellen sowohl bei Galaxie- als auch Universumskoordinaten die Galaxie-Bruchtabelle. Universumsunterschiede werden nur bei ganzzahligen und reziproken Faktoren über zusätzliche physische Spalten sichtbar. Der Mojo-Port übernimmt diese ungewöhnliche, aber beobachtbare Semantik absichtlich.
- Ein erkannter, aber nicht erzeugter Generator darf keine leere Spaltenliste an die Projektion weiterreichen, weil die historische Tabellenhilfe eine leere Liste als „alle Spalten“ interpretiert. Mit der Portierung von `PrimCSV` sowie sämtlichen zehn `generated_command`-Werten gibt es für die derzeit katalogisierten Generatorbefehle keinen solchen stillen Volltabellen-Fallback mehr.

## Stufe 8 – allgemeine Metaachsen, Bruch-Prägarben und Kombi-Join

- Die zwölf Meta-/Konkretachsen werden nicht in CLI-Reihenfolge ausgegeben. Das Python-Original sammelt Anfragen in einem Set; dessen mit `PYTHONHASHSEED=0` beobachtete Reihenfolge ist für jede der 4.095 nichtleeren Teilmengen im Asset `meta_request_order.tsv` festgeschrieben.
- Jede Meta-Anfrage erzeugt historisch ein Paar aus „für n“ und „für 1/n“. Die n-Seite folgt ganzzahligen Multiplikationsketten, die 1/n-Seite zyklisch erkannten rationalen Quotienten. Auch ungewöhnliche Doppelmarker wie `(1/1)(1)` und fehlerhafte alte Übersetzungen bleiben sichtbar kompatibel.
- Die vier Bruch-Prägarben Universum, Galaxie, Emotion und Strukturgröße teilen eine typisierte Koordinatenlogik, behalten aber ihre verschiedenen Tabellen- und Überschriftsquellen.
- Der Kombi-Join ist ein relationaler Morphismus: Zahlen- und Bruchtokens werden auf Hauptzeilen abgebildet, der aktuelle Zeilenwert wird aus dem linken Kombinationspräfix entfernt und passende Zellen werden in Referenzreihenfolge verklebt.
- Mehrfachauswahl bewahrt leere `|`-Segmente. Ein abschließendes Leerzeichen wird nur bei einer nichtletzten CSV-Quelle erhalten; diese inkonsistente Legacy-Grenze ist durch Marker im nativen Zwischenzustand reproduziert.
- `kombi_aliases.tsv` enthält 173 deutsch/englische Aliaszeilen. `kombi_relation_order.tsv` hält 151 Set-Reihenfolgen fest. Beide Assets werden aus der Referenz regeneriert und per `cmp` geprüft.

## Stufe 9 – BBCode, HTML und semantische Zellmetadaten

- BBCode läuft wie die Referenz durch zwei logisch getrennte Schritte: Wortumbruch/Ausrichtung und anschließende Whitespace-Kollabierung des historischen farbigen Konsolenpfads. Dadurch bleibt von Auffüllung höchstens ein sichtbares Leerzeichen übrig.
- Die Seitenteilung verwendet die Referenzbreite 80 abzüglich Zeilennummernbreite. Selbst bei `--keineueberschriften` wird die unsichtbare Überschrift weiterhin zur Breitenberechnung verwendet; Ausgabe- und Breitenreferenztabelle sind deshalb getrennte Werte.
- Der physische HTML-Zellkatalog enthält 1.496 Einträge: zwei Sprachen mal 746 Haupttabellenspalten plus zwei Nummerierungsspalten. Er konserviert `z_`, `r_`, `p1_`, `p2_`, `p3_`, `p4_`, Symbolstile und Zählungsfarben.
- `r_` bezeichnet die Position in der gerenderten Projektion, nicht die physische CSV-Spalte. Bei deaktivierter Nummerierung bleiben die beiden reservierten Nummerierungsslots trotzdem bestehen; die erste Datenspalte beginnt weiterhin bei `r_2`.
- Generatorzellen haben keine stabile physische Quellspalte. `html_heading_catalog.tsv` verwendet daher die tatsächliche Tabellenüberschrift als semantischen Schlüssel und schreibt die Referenzposition auf die aktuelle Projektionsposition um. Doppelte Schlüssel verwenden bewusst den letzten Eintrag.
- HTML-Zellinhalt wird nicht pauschal maskiert. Tagähnliche Sequenzen mit alphabetischem Namen, etwa `<ul>`, `<li>`, `<br>`, `<span>` oder `<table>`, bleiben aktiv. Mathematische Vergleiche wie `m<5`, `n>0` und normales `&` werden weiterhin zu Entities.
- Ein früher englischer Paritätstest verwendete `--universe_meta_concrete`. Dieser Name wird vom Python-Original nicht erkannt und erzeugte eine leere Ausgabe. Der Test verwendet nun den wirksamen Alias `--universeMetaConcrete`; erst damit prüft er die echte nichtleere Metaspaltensemantik.
- Wiederholte Kaltstarts der Python-Referenz können bei Markup-Sammelläufen stark schwanken. Geprüfte Byteausgaben liegen deshalb als Fixtures vor. `RETA_REFRESH_MARKUP_FIXTURES=1` erzeugt sie ausdrücklich neu aus Python; der normale Releasepfad startet nur Mojo und vergleicht deterministisch.

## Stufe 9 – nativer ANSI-Shellrenderer

`table_rendering.mojo` besitzt nun einen eigenen Shellpfad statt des früheren ` | `-Fallbacks. Er reproduziert die historischen ANSI-Hintergründe für Überschrift, Mondzahlen, Primzahlen sowie gerade/ungerade Restzeilen. Der Renderer erhält signifikante interne Doppel-Leerzeichen, trennt Tabellen nach Terminalbreite und behandelt Fortsetzungszeilen wie die Python-Referenz. Die gemeinsame Nummerierungsvorbereitung normalisiert Shellzellen nicht mehr vorzeitig.

## Stufe 10 – native Prompt-Sprache, CPython-Mengenordnung und Completion-Arbeiter

### Katalog statt Laufzeitimport

Die Prompt-Completion wird nicht durch einen Python-Import zur Laufzeit erzeugt. `generate_prompt_nested_catalog.py` extrahiert die wirksame Referenzoberfläche für Deutsch, Englisch, Vietnamesisch, Chinesisch und Koreanisch in kompakte TSV-Assets. 25.834 einzelne Completion-Werte werden dabei in 561 Kontextsektionen gruppiert. Separate Dateien halten 200 Dispatch-Aliase, 95 Ein-Zeichen-Ersetzungen, 370 numerische Kurzbefehlszeilen und 1.355 Vokabularaliase.

Der Generator unterstützt ein alternatives Ausgabeverzeichnis. `check_prompt_language_catalog.sh` regeneriert deshalb alle Dateien in einem temporären Verzeichnis und vergleicht sie byteweise mit dem Releasebestand.

### Tokenisierung und Fuzzy-Reihenfolge

`prompt_language.mojo` trennt Leerzeichen und Kommas nur außerhalb von `()`, `[]` und `{}`. Die Completion verwendet nicht bloß Präfixe: Sie bildet das beobachtete `prompt_toolkit`-Verhalten als Teilsequenzsuche nach, sortiert zuerst nach der frühesten Trefferposition, danach nach der kürzesten Treffspanne und bewahrt anschließend die Quellreihenfolge.

### Kompakte Kurzsprache

Die ehemalige `stextFromKleinKleinKleinBefehl`-Semantik ist als typisierte Mojo-Transformation portiert. Dazu gehören einfache und rotierte Formen wie `a15`, `ap15`, `15a`, `p12`, `(1 2)` und `uv3/2`, Bruchstandardbefehle, selektive Ausgabe, `-e` sowie die historischen `15_…`-/`16_…`-Ausnahmen.

Nicht intuitiv ist die sichtbare Reihenfolge mehrerer expandierter Tokens. Das Python-Original verwendet normale Sets. Der Port implementiert deshalb CPython 3.13 mit `PYTHONHASHSEED=0` für Strings über SipHash-1-3 und das beobachtete offene Hash-Tabellen-Probing. `set(iterable)` und Set-Merge vergrößern ihre Tabellen zu unterschiedlichen Zeitpunkten; beide Pfade werden getrennt nachgebildet.

### Interaktive Systemgrenze

GNU Readline bleibt eine Python-/Betriebssystemgrenze. Die eigentliche Completion läuft jedoch in `reta-prompt-complete`, einem persistenten Mojo-Prozess, der den vollständigen Eingabepuffer erhält und Kandidaten zurückgibt. Der Katalog wird dadurch nur einmal pro Sitzung geladen. Der Python-Adapter besitzt Prozesslebenszyklus, seine Pipehälfte, Readline-Callback und einen statischen Notfallfallback; der Mojo-Arbeiter liest und schreibt seine Dateideskriptoren nativ.

Noch nicht portierte Fachoperationen erhalten an der Kompatibilitätsgrenze weiterhin die unveränderte Originalzeile. Dadurch gehen die historischen späteren Parserwirkungen nicht verloren, obwohl die vordere Kurzsprache und Completion bereits nativ sind.

## Stufe 10 – Bruchausführung und native Fachbefehle

- `prompt_fraction_execution.mojo` portiert `bruchSpalt`, `createRangesForBruchLists`, gleiche Zähler/Nenner, ganzzahlige Quotienten und Reziprok-Ergänzungen.
- Die ungewöhnliche alternierende Legacy-Repräsentation aus Textgruppen und Zweiergruppen bleibt erhalten.
- `primfaktorenvergleich`, `abstand`, `abstandPrim`, `mond` und `richtung` besitzen native Dispatch-Zweige.
- Seit Stage 10k sind auch drei oder mehr unabhängige Abstandsbereiche nativ. Die überschreibende Set-/Dict-Semantik des Originals wird einschließlich CPython-`frozenset`-Hash, äußerer Merge-Reihenfolge, zweiter Difference-Tabelle und Wörterbuchüberschreibungen reproduziert.
- `mond` und `richtung` delegieren nur den Prozessstart an `mojo_bridge.py`; Tabellenplanung, Generatoren und Rendering laufen im kompilierten Mojo-Ziel.
- Explizite Spaltenbereiche werden als Ergebnispositionen auf semantisch erzeugte Spalten angewandt, statt die ursprüngliche Auswahl zu ersetzen.

## Stufe 10 – besitzende Tabellenplanung für Ganzzahlen und positive Brüche

`prompt_table_execution.mojo` trennt die bisher in `PromptGrosseAusgabe` vermischten Aufgaben: lokalisierte Befehlsauflösung, Zahlen- und Bruchsammlung, Modifikatorauswertung, Tabellenargumente und Mehrfachausführung. Das Ergebnis ist ein `PromptTablePlan` mit null, einer oder mehreren `PromptTableInvocation`-Strukturen. Der Promptcontroller führt den Plan aus, ohne die Fachsemantik erneut zu interpretieren.

Portiert sind 18 Tabellenfamilien. Darin enthalten sind alle reinen `n`- und `1/n`-Zweige der zentralen `retaCmdAbstraction_n_and_1pron`-Aufrufe sowie die direkten Tabellenzweige für Mond, Richtung, Primzahlkreuz, Alles und Thomas. Für Emotion, Größe, Motive/Galaxie und Universum werden echte `n/m`-Generatorspalten geplant. `groesse` erzeugt wie die Referenz zwei getrennte Grundtabellenaufrufe; das Universum ergänzt bei gleichen positiven Zählern und Nennern seine besondere Gleichheitsachse.

Der bestehende Port von `bruchSpalt` und `createRangesForBruchLists` ist nun an den Tabellenplaner angeschlossen. Dadurch funktionieren einfache Achsenbereiche, historische Rechtecke (`1/2-3/3`) und Versätze (`4/5+2/2`). Positive Zählergruppen werden in der beobachtbaren Referenzreihenfolge aufsteigend ausgeführt; die Versatzform `4/5+2/2` liefert also zuerst `2/n`, danach `6/n`.

Ganzzahlige `vielfache`, `teiler` und `einzeln` werden vor der Fachfamilie als Zeilenoperatoren ausgewertet. Stage 10d nimmt zusätzlich stabile Bruchausschlüsse, Bruchteiler und Reziprok-Vielfache (`v1/n`) in denselben besitzenden Plan auf. Stage 10i modelliert auch Nullwerte, rein negative Selektoren und kollidierende Ausschlussformen einschließlich der historischen All-Zeilen-Algebra. Atomar am Fallback bleiben echte `v n/m`-Vielfache mit Zähler größer 1, bei denen die Python-Referenz selbst mit `IndexError` endet. Wiederholte numerische Katalogauswahlen werden seit Stage 10j nativ ausgeführt: Das sichtbare Echo bewahrt die Wiederholung, während die semantische Generatoranforderung wie in Python dedupliziert wird.

Die Universumsfamilie behält ihre historische bedingte Spaltenauswahl: Spalte 4 entfällt bei `e`, `ee`, deaktivierten Überschriften, dem Unterdrückungsbefehl oder mehr als zwei kombinierten Fachbefehlen. Für Tabellenoptionen mit Umlauten verwendet der Plan vorhandene ASCII-Aliase (`trieb`, `groesse`).

## Stufe 10c – bei der Parität gefundene Tabellenkernfehler

- `--nocolor` war zuvor nur als Parametername bekannt. Der Shellrenderer erhält nun ein typisiertes `color_rows`-Flag und gibt bei deaktivierter Farbe keine ANSI-Sequenzen aus.
- Eine explizite relative Ergebnisposition, die nach der Generatorpipeline keine Spalte traf, wurde früher als leere Auswahl interpretiert und dadurch in „alle Spalten“ umgedeutet. `explicit_order_requested` unterscheidet nun bewusst zwischen „keine Reihenfolge verlangt“ und „verlangt, aber keine Position vorhanden“.
- Native Tabellenaufrufe werden nach der ausgegebenen `reta`-Befehlszeile mit einem echten Zeilenumbruch begonnen. Die früher zusammengeklebte erste Tabellenzeile war ein Promptcontrollerfehler, kein Renderermerkmal.

Die Bruch-/Modifikatorparität wird als normalisierter geordneter CSV-Tokenstrom geprüft. Das entfernt nur präsentationsbedingte Whitespace-Läufe der Legacy-Renderer und behauptet ausdrücklich keine vollständige Byteparität des Shell-Wrappings.

## Stufe 10d – vorzeichenbehaftete Bruchmengen und obere Zeilengrenzen

- `_PromptFractionPair` trägt Ausschluss- und Vielfachenstatus typisiert statt über nachträgliche Stringtests.
- Positive und vorzeichenbehaftete Ganzzahlmengen besitzen getrennte CPython-Ordnungsabbilder; damit bleibt auch die ungewöhnliche Reihenfolge großer Reziprok-Vielfachen reproduzierbar.
- Reine negative Bruchauswahlen werden als vollständig behandelte leere Pläne erkannt und nicht mehr unnötig an Python delegiert.
- Nicht kollidierende Reziprok- und echte `n/m`-Ausschlüsse sowie Bruchteiler werden nativ in Zeilen- und Generatorachsen zerlegt.
- `--oberesmaximum` setzt nun wie der Python-Setter sowohl die 1024- als auch die historische Kurzgrenze. Ohne explizite Angabe ist diese Kurzgrenze 163, nicht 114. Dadurch bleiben etwa die explizit ausgewählten Reziprok-Vielfachenzeilen 256 und 768 gemeinsam sichtbar.

## Stufe 10e – In-Process-Promptausführung und strenger CLI-Besitz

- Der One-shot-Dispatcher läuft vor `Python.import_module`. Vollständig native Befehle benötigen weder CPython noch einen zweiten Prozess.
- Tabellenpläne rufen `run_native_reta` direkt auf; der bisherige Bridgeadapter `run_native_reta_subprocess_encoded` entfällt.
- Rohe `reta`-Befehle werden nur übernommen, wenn jeder Bereich und jede Option zum nativen Vertrag gehört. Unbekannte Eingaben fallen vollständig zurück.
- Positive Shell-/HTML-/BBCode-Breiten gehören nach den Stage-10l-Byteprüfungen ebenfalls zum nativen Promptvertrag.
- Kompakte/einbuchstabige Befehle bleiben bis zur Typisierung ihrer historischen Echozeile an der Referenzgrenze.
- `leeren` verwendet direkt `ESC[2J ESC[H`; der externe `clear`-Prozess und sein Pythonadapter entfallen.


## Stufe 10f – kompakte Legacy-Präsentation und nativer `mulpri`-Ablauf

- `prompt_legacy_echo.mojo` trennt sichtbare historische Optionsschreibweisen von den kanonischen Ausführungstokens.
- Rendererstabile Kurzformen für Absicht/Motiv, Geist, Impulse, Thomas und Richtung laufen vor jedem Python-Import.
- `mulpri`/`p` komponiert Primfaktorenvergleich, Primfaktorzerlegung und nichttriviale Faktorpaare nativ; Primzahlen behalten die historische Sonderausgabe.
- `multis` gibt wie die Referenz keine triviale Zerlegung `(n, 1)` mehr aus.
- Python-`set`-Reihenfolge in sichtbaren Ankündigungen wird mit dem vorhandenen CPython-3.13-/`PYTHONHASHSEED=0`-Modell erzeugt.
- Rendererempfindliche Kurzformen und reine Zahlenkürzel bleiben atomar an der Bridge, damit kein Teil eines zusammengesetzten Legacybefehls vorzeitig nativ ausgeführt wird.
- Der kompakte Besitzervertrag prüft jedes nichtnumerische Token; Speicher-/Sitzungsbefehle können nicht mehr neben einer nativen Tabelle verloren gehen.
- Die SipHash-13-Nachbildung verarbeitet UTF-8-Bytes direkt und schneidet mehrbyteige deutsche Bezeichner nicht mehr an ungültigen Grenzen.


## Stufe 10g – vorbereitete Rendererfragmente und kompakter Farbausgabestrom

Der Shellrenderer bestimmt die Spaltenbreite jetzt nach dem historischen Vorbereitungsumbruch und nicht aus der Rohzelle. Vorhandene Bindestriche sind wie bei Python `textwrap` bevorzugte Umbruchstellen. Farbige Promptankündigungen bewahren ihre historische Darstellung. Sichtbare `reta`-Echos enden dagegen wie der tatsächlich gerenderte Python-`Syntax`-Bytestrom mit einer physischen LF-Grenze vor der Tabelle. Dadurch wechseln `bewusstsein`, `emotion`, `triebe`, `wirklichkeit` und `universum` in den vollständig nativen kompakten One-shot-Pfad. Reine Zahlenkürzel bleiben als eigenständige mehrteilige Komposition offen.


## Stage 10h – numerische Komposition

- Reine positive Zahlen-, Bereichs-, Listen- und Bruchbefehle werden vor dem Python-Import aus den vorhandenen typisierten Tabellen- und `mulpri`-Plänen komponiert.
- `15_…`, `16_…` und `16_15_…` werden direkt aus dem fünfsprachigen Katalog auf Grundstrukturen beziehungsweise Multiversum abgebildet.
- Die historische Reihenfolge ist fest: Multiversum vor Grundstrukturen; Werte innerhalb einer Familie behalten die CPython-Set-Reihenfolge.
- Der Shellrenderer modelliert die Zählungsgruppenmarkierung `█` zentral.
- `0`, rein negative numerische Ausdrücke, doppelte generierte Spalteninstanzen und die fünf durch die Legacygrammatik unerreichbaren Multiversum-Schlüssel 15 bleiben ausdrücklich außerhalb des neuen Besitzvertrags.


## Stage 10i – numerische Selektoralgebra

- Rohe Ganzzahlkomponenten werden in deterministischer CPython-`set[str]`-Reihenfolge geplant.
- Positive und negative Zeilenprädikate werden vor der Auswahl gegeneinander gekürzt; eine leere Restbedingung bedeutet historisch „alle Zeilen“.
- `teiler` entfernt Ausschlüsse vor der Divisorbildung und erhält bei leerer positiver Seite die explizite Komponente `","`.
- Der reine Standardbefehl `0` erzeugt nur den Thomas-Zweig ohne oberes Maximum und ohne Motiv-Zweitaufruf.
- Die Shellnummerierung verwendet das angeforderte obere Maximum nur im allzeiligen Projektionspfad; endliche Selektionen behalten ihre bisherige Breite.
- Offen bleiben echte `v n/m`-Vielfache mit Zähler größer 1 und doppelte generierte Katalogspalteninstanzen.


## Stage 10j – wiederholte Katalogauswahl und Shell-Whitespace-Chunks

- Die frühere Duplikatsperre im Promptplaner wurde entfernt. Mehrfach adressierte identische Katalogwerte bleiben im sichtbaren Legacy-CLI-Token erhalten, erzeugen aber wie in Python nur eine semantische Generatoranforderung.
- Der vermeintliche instanzabhängige Breitenunterschied war tatsächlich eine Abweichung im Shell-Wortumbruch der Primzahlkreuz-Spalte.
- `_shell_word_wrap_cell` zerlegt Zellen nun in Wörter und echte Whitespace-Chunks: interne Läufe behalten ihre Breite; an einem Umbruch verwirft `drop_whitespace` den Chunk am Zeilenende beziehungsweise -anfang.
- Damit bleibt in `gegen 6 |  … | pro 5 |  …` das letzte Trennzeichen auf der ersten visuellen Zeile, während die zwei nachfolgenden Leerzeichen am Beginn der Fortsetzungszeile entfallen – bytegleich zu Python `textwrap`.
- Offen bleiben echte `v n/m`-Vielfache mit Zähler größer 1 sowie seltene hintere Prompt-, Rich- und kombinierte HTML-Sonderzweige.

## Stage 10k – mehrbereichige Abstände und verschachtelte CPython-Setordnung

- Die früheren `len(command.words) == 3`-Grenzen entfallen im interaktiven und im One-shot-Dispatch.
- Prompt-Tokens werden vor der Bereichsauswahl wie der Python-Referenzsatz geordnet und dedupliziert.
- `_PromptDistanceRange` trägt Bereichstext, expandierte Integerwerte und den CPython-3.13-Frozenset-Hash typisiert.
- Die äußere `set[frozenset[int]]`-Tabelle bildet Singleton-Merge, lineare Probes, Perturbation und Resize nach.
- Die innere Mengendifferenz wird als eigene Set-Tabelle rekonstruiert; für kleine Subtraktionsmengen wird auch der Copy-and-discard-Pfad unterschieden.
- Doppelte Bereiche, gemischte Kardinalitäten, große Bereiche und sechs beziehungsweise neun Einzelbereiche besitzen feste Regressionstests.
- Normale und primfaktorisierte Mehrbereichsausgaben laufen vor jedem Python-Import und ohne `reta-native`-Kindprozess.



## Stage 10l – native Datei-, Pipe- und HTML-Orchestrierung

- `csv_table.read_text_file` verwendet natives `open(...).read()` statt `std.python`/`pathlib`; alle darauf aufbauenden CSV-, TSV-, Prompt- und HTML-Assetloader erben diese Besitzgrenze.
- `reta-prompt-complete` liest Dateideskriptor 0 und schreibt Dateideskriptor 1 über `FileHandle`; leere Zeilen, CRLF, EOF und persistente Mehrfachanfragen bleiben erhalten.
- `generate_html_main.mojo` besitzt Argumente, Environment, Override, `middle.alx`, Assets, Hierarchie und stdout. Seit Stage 12b wird auch die zwölfteilige `--spalten --alles`-Mitteltabelle direkt durch `run_native_reta` erzeugt; ein Python-Kindprozess entfällt.
- Die veraltete positive-Breiten-Sperre in `native_reta_tokens_supported` entfällt. Shell, HTML und BBCode mit Breite 40 laufen aus dem Prompt bytegleich vor jedem Python-Import.
- Neue Regressionen prüfen fehlende `libpython`-NEEDED-Einträge, einen absichtlich ungültigen Referenzinterpreter im HTML-Overridepfad sowie Python-quellfreie Tabellen-, Completion- und Promptausführung.

## Stage 10m – Ganzzahl-Modifikatorkomposition und dynamische Tabellenobergrenze

- `vielfache` und `teiler` komponieren bei Ganzzahlen jetzt in einem besitzenden nativen Plan. Der Mischpfad fügt keine separate `--vielfachevonzahlen`-Option hinzu, weil sie die Teilervereinigung wieder schneiden würde.
- Die Teilerreihenfolge bildet nicht bloß eine Ganzzahlmenge nach. Das Original verschachtelt Faktor-Tupelmengen, eine zweite Tupelkonvertierung, zweielementige Ganzzahlmengen und `set |=`. Der Port reproduziert dafür Tupelhash, Probing, direkte Add-Resizes, Merge-Resizes und den leeren Tabellenkopierpfad von CPython 3.13.
- Absolute Selektoren mit eingebettetem `vN` bestimmen ihre Tabellenobergrenze vor dem eigentlichen Zeilenfilter. Die erste 1028-begrenzte Expansion liefert `max(Auswahl) + 1`; die zweite Expansion gegen diese neue Grenze erklärt historische Folgezeilen wie 1029 bei `v2-4`.
- Die native CSV-Tabelle wird für solche Selektoren mit typisierten Leerzeilen erweitert, damit Generatoren auch oberhalb der physischen Zeile 1024 arbeiten können. Der dedizierte `--vielfachevonzahlen`-Pfad behält seine kurze Haupttabellengrenze.

## Stage 10n: EIGN/EIGR ohne Prompt-Bridge

`EIGN<eigenschaft>` und `EIGR<eigenschaft>` gehören nun zum nativen
One-shot-Vertrag. Der deutsche Promptkatalog enthält zusammen 165 solche
Befehle. EIGN wird auf `--konzept`, EIGR auf `--konzept2` abgebildet. Bei EIGR
mit Ganzzahl bleibt die zweite historische `-zeilen`-Sektion hinter den
Ausgabeparametern erhalten.

Die Python-Promptimplementierung von EIGR scheitert derzeit vor der Ausführung
beim tiefen Kopieren eines Modulobjekts. Der Mojo-Port folgt dem unmittelbar im
Referenzzweig gebildeten und über `reta.py` erfolgreich geprüften Argumentvektor
und übernimmt nicht diesen vorgeschalteten Defekt.


## Stage 11a – Architekturkarte und Boundary-Graph

`architecture_map.py` und `architecture_boundaries.py` sind erstmals außerhalb der Python-Laufzeit verfügbar. Zwei deterministische Generatoren lesen die Referenzsnapshots und erzeugen typisierte Mojo-Strukturen. Der Architekturmap-Snapshot umfasst 11 Kapseln, 34 Einschließungen, 53 Flüsse, 34 Legacy-Zuordnungen und 42 Stufenschritte. Der Grenzgraph umfasst 161 Modulbesitzer, 279 aufgelöste interne Importkanten, 37 Cross-Capsule-Kanten, 11 Kapselgrenzen und fünf bestandene Validierungschecks.

Der Python-AST-Scan bleibt bewusst ein Build-/Regenerationswerkzeug. Laufzeitabfragen (`--summary`, `--module`, `--capsule`, Diagramme) und Validierungsnavigation geschehen im neuen `reta-mojo-boundaries` vollständig in Mojo. Der Kategorienkatalog und der Grenzgraph bleiben getrennte schwere Compilerziele, damit der Compiler nicht beide großen Konstantenmengen in einem Monolithen elaborieren muss.


## Stage 11b – Architekturverträge und Witnesses

`architecture_contracts.py` und `architecture_witnesses.py` sind metadata-only und werden deshalb als reproduzierbar generierte, typisierte Mojo-Bundles portiert. Der Python-Code bleibt ausschließlich Wahrheit für den expliziten Generatorlauf; normale Suche, Navigation und Statusprüfung benötigen kein Python.

Der Witness-Generator muss `python_reference` selbst als Repositorywurzel verwenden. Wird irrtümlich die äußere Mojo-Projektwurzel übergeben, erscheinen sämtliche historischen Pfade unter `reta_architecture/`, `libs/`, `i18n/` und `tests/` als fehlend. Mit der richtigen Wurzel werden 351/351 dateiartige Anker aufgelöst.

Kategorienkatalog, Kapselkarte, Verträge und Witnesses werden nicht zu einem einzigen Executable zusammengeklebt. Ein solcher Metamonolith verursacht unverhältnismäßige Compilerelaboration. Die Generatoren validieren die Querverweise und speichern den bestandenen Status; die nativen Programme bleiben getrennte, schnell kompilierbare Inspektionsziele.


## Stage 11c – Kohärenzmatrix und Trace-Navigation

`architecture_coherence.py` und `architecture_traces.py` sind reine Metaschichten und werden als reproduzierbare typisierte Mojo-Snapshots portiert. Die Generatorphase führt die ursprünglichen Python-Bootstraps aus; die Laufzeit besitzt danach Suche, Navigation, Diagramme, Status- und Zählungsvalidierung ohne Python.

Die Compilergrenze bleibt absichtlich fein: Kohärenz und Traces werden nicht zusammen mit Kategorien, Karte, Verträgen und Witnesses in ein einziges Executable instanziiert. Die bereits validierten Querverweise werden als Snapshot übernommen; ein gemeinsamer Metamonolith würde nur die Compilerelaboration vervielfachen.

Der Komponententrace bewahrt die gesamte Navigationskette `Legacy-Besitzer → Kapsel → Kategorie → Funktor/Transformation → Diagramm → Witness → Gesetz`. Damit ist die höhere mathematische Architektur erstmals nativ nicht nur katalogisiert, sondern entlang konkreter Reta-Besitzer navigierbar.


## Stage 11d – Impact-Kalkül und geordnete Migration

`architecture_impact.py` und `architecture_migration.py` sind reine Architekturmetadaten. Die Python-Bootstraps werden deshalb nur bei expliziter Regeneration ausgeführt; der resultierende Impact- und Migrationsgraph liegt anschließend als typisierte Mojo-Struktur vor.

Das Python-`Mapping[str, str]` der Gate-Kommandos wird als geordnete `List[GateCommandSpec]` übertragen. Dadurch bleibt die Einfügereihenfolge erhalten, ohne an der Mojo-Laufzeit ein dynamisches Wörterbuch zu benötigen.

Die öffentliche CLI bleibt bewusst kompakt. Ein erster breiter Controller mit vielen Präsentationszweigen verursachte erneut überproportionale Compilerelaboration, obwohl derselbe vollständige Datensatz in den fokussierten Tests in ungefähr zwölf Sekunden kompiliert. Impact und Migration werden daher getrennt gebaut und bieten die wichtigsten Namensabfragen direkt an.


## Stage 11e – Rehearsal und kontrollierte Aktivierung

`architecture_rehearsal.py` und `architecture_activation.py` sind metadata-only und werden deshalb als reproduzierbare typisierte Snapshots portiert. Die Mojo-Laufzeit führt keine Migration aus; sie navigiert und validiert ausschließlich Öffnungen, Moves, Gates, Cover, Aktivierungseinheiten, Rollbacks und Transaktionen.

Zusätzlich zum gespeicherten Python-Validierungsstatus prüfen neue native Funktionen die Beziehungen der erzeugten Listen direkt. Damit kann ein beschädigter oder unvollständiger Snapshot nicht allein wegen eines alten `passed`-Strings als gültig gelten.

Die öffentlichen Controller werden bewusst mit `--no-optimization` kompiliert. Die optimierten Bundle-Tests zeigen, dass die Datentypen selbst normal kompilierbar sind; nur die Kombination aus großen Konstantenbäumen und argv-basierten Präsentationszweigen verursacht bei O3 unverhältnismäßige Elaborationszeit.


## Stage 11f – Gesamtvalidierung und Fortschritts-Overlay

- `architecture_validation.py` wird als vollständiger Stage-41-Snapshot generiert; Python bleibt nur für die explizite Regeneration der 51 Checks und 17 Schichten nötig.
- Die native Validierung prüft Schichtreferenzen, Summen, Objektzählungen, eindeutige Namen und `failed_checks` erneut, statt nur den gespeicherten Status zu übernehmen.
- `architecture_progress.py` wird aus der Referenz-AST-/Repositoryanalyse als Stage-42-Snapshot erzeugt.
- Der Fortschrittsstatus `attention` ist beabsichtigt: Er bezeichnet `WIP42-01`, eine fehlende externe Command-Parity-Baseline, nicht eine inkonsistente Mojo-Portierung.
- Die native Kreuzvalidierung prüft Oberflächen-, Schritt- und Wellenbindungen sowie alle Statuszählungen.
- Beide Query-Controller werden ohne Optimierung gebaut; die Bundletests bleiben normal optimiert.
- Der im kompilierten Stage-11e-Arbeitsarchiv fehlende, aber manifestierte Stage-11e-Bericht wurde aus dem zuvor verifizierten Quellrelease wiederhergestellt.


## Stage 11g – native SQLite-Persistenz

`reta_architecture/persistence.py` ist nicht als statischer Snapshot, sondern als ausführende Laufzeitschicht portiert. Mojo bindet SQLite und SHA-256 direkt über die C-ABI ein. Die sechs Tabellen, zwölf öffentlichen Operationen, Einzel- und Batchpfade sowie Audit- und Cacheverhalten sind nativ.

Die wichtigste Typentscheidung betrifft JSON: Python nimmt beliebige Objekte entgegen; die native Grenze nimmt kanonischen UTF-8-JSON-Text entgegen. Die bekannten umschließenden Dokumente werden in Mojo mit der exakt sortierten Python-Schlüsselreihenfolge aufgebaut. So bleiben Digests und SQLite-Zeilen interoperabel, ohne dynamisches `Any` in die Architektur einzuführen.

SQLite-Batchschreibvorgänge bleiben seriell und transaktional. Reine In-Memory-Vorbereitung kann seit Stage 11j threadparallel laufen; Datenbankschreibvorgänge selbst werden nicht auf mehrere Worker verteilt.


## Stage 11h – natives deterministisches Ausführungsnetz

`reta_architecture/execution_network.py` ist als ausführende Mojo-Schicht portiert. Queue-Disziplinen, Kanäle, Semaphoren, Task-/Resulttypen, Snapshotbildung und deterministische Reduktion sind nicht generierte Metadaten, sondern tatsächliche Laufzeitlogik.

Historischer Stand von Stage 11h: Der erste native Port verwendete noch `fork()`, private Pipes und `waitpid()`. Stage 12a hat diesen Übergangscode vollständig entfernt. Das Ausführungsnetz begrenzt nun native Mojo-Threadtasks über `max_workers`, schreibt pro Task in einen disjunkten Ergebnisslot und reduziert nach der Threadbarriere deterministisch.

Die dynamische Python-Grenze aus `Any`, Pickle, lokalen Handlern und `importlib` wird bewusst nicht nachgebaut. Tasks tragen besitzende UTF-8-Nutzlasten, kanonisches Metadaten-JSON und eine geprüfte Operation beziehungsweise bekannte `callable_path`. Dadurch bleibt der Scheduler statisch prüfbar und kann später um Reta-spezifische Workeroperationen erweitert werden.

Kanäle und Semaphoren des Ausführungsnetzes bleiben nichtblockierende deterministische Zustandsobjekte. Die konkreten Stage-11j-Tabellenworker benötigen dort keine geteilte Warteschlange: Sie erhalten feste Chunkslots über Mojos Threadpool, schreiben disjunkt und synchronisieren an der `parallelize`-Barriere.

`execution_run_snapshot_json()` verbindet Stage 11h mit der Stage-11g-Persistenz. Der Integrationstest persistiert einen nativen Threadlauf und dessen Auditspur in SQLite. Stage 11i ergänzt reine Chunk-Kerne; Stage 11j ergänzt den typisierten Thread-Zeilenpfad. Stage 12a vereinheitlicht beide auf eine threadbasierte Laufzeit.


## Stage 11i/12a – native Thread-Chunk-Kerne

`reta_architecture/parallel_execution.py` wird nicht als dünne `multiprocessing`-Nachbildung portiert. Die Mojo-Schicht besitzt explizite Konfiguration, CPU-Erkennung, typisierte Ergebnisstatistiken und zehn reine Tabellen-/Zahlenkerne mit serieller Referenz und nativem Threadpfad. Der historische Linux-`fork`-Pfad wurde in Stage 12a entfernt.

Der Python-Transport über Pickle und dynamische Objektgraphen wird durch ein längenpräfixiertes UTF-8-Protokoll ersetzt. Dadurch bleiben Unicode, Leerzeilen und beliebige Trennzeichen erhalten, während der Workervertrag statisch prüfbar bleibt. Die Reduktion erfolgt nach Chunkindex und ist damit unabhängig von der Reihenfolge, in der Kindprozesse beendet werden.

Der große `Prepare`-Objektgraph wird bewusst nicht per `deepcopy` und Pickle imitiert. Stage 11j führt dafür `ParallelRowPreparationContext` ein und verdrahtet Header-, Religionsnummern- und Kombi-Kontext in einen eigenständigen nativen Tabellenpfad.


## Stage 11j – typisierte native Thread-Zeilenvorbereitung

Für reine CPU-Arbeit auf bereits im Mojo-Prozess befindlichen Tabellen ist `auto` nun threadbasiert. Threads teilen die unveränderlichen Eingaben und vermeiden Prozessstart, Copy-on-write-Seiten, Pipeprotokolle und Ergebnisdeserialisierung. Der Modus `processes` bleibt explizit verfügbar, wenn Adressraumisolation wichtiger ist als gemeinsamer Speicher.

`ParallelRowPreparationContext` besitzt alle für Nichtkopfzeilen nötigen Tabellen-, Breiten-, Kombi- und Religionsnummerninformationen. Die Worker erhalten unveränderliche Eingaben, jeder Worker schreibt nur in seinen eigenen vorab angelegten `_PreparedChunk`, und die Hauptfaser reduziert nach dem ursprünglichen Zeilenindex. Dadurch braucht dieser Pfad weder Locks noch `deepcopy`, Pickle oder Python-Objektmutation. Header-Tag-Mutationen, SQLite-Schreibvorgänge und Ausgabe-I/O bleiben seriell.

Der neue Pfad liegt absichtlich in `parallel_row_preparation.mojo`, getrennt vom inzwischen großen `parallel_execution.mojo`. Diese Modulgrenze reduziert Mojos Elaborationslast und macht kleine Zeilenänderungen unabhängig von den übrigen Tabellen- und Zahlenkernen kompilierbar.

Ein vorläufiger Lauf mit 20.000 Zeilen und acht Workern benötigte in der verwendeten Umgebung 4,12 s seriell und 3,22 s threadparallel bei identischer Prüfsumme. Kleine Eingaben bleiben über den Schwellwertmechanismus seriell, weil Schedulingkosten sonst den Nutzen übersteigen können.

### Korrektur der kompakten Prompt-Zeilengrenze

Die frühere Mojo-Portierung hatte Richs internen Aufruf `Console.print(..., end="")` wörtlich kopiert. Das gerenderte Python-`Syntax`-Objekt beendet seine physische Zeile dennoch mit LF. Mojo gab dagegen die nächste `reta`-Zeile direkt anschließend aus. Die neue Funktion `compact_prompt_announcement_line()` macht den beobachtbaren Bytevertrag explizit und liefert genau eine vollständige Zeile einschließlich `\n`.

Ein separater Fixture-Integritätstest verbietet nun `reta-Befehl:reta `, leere Referenzdateien und fehlende zweite Nutzlastzeilen. Damit wird nicht nur der konkrete Fehler, sondern auch seine bisherige Testlücke geschlossen.


## Stage 12b – native `--alles`-Spaltenauswahl und HTML-Gesamtgenerator

- `scripts/generate_all_columns_plan.py` extrahiert die zwölf bereits aufgelösten Buckets des synthetischen Python-Parameters mit festem `PYTHONHASHSEED=0`.
- `all_columns.mojo` lädt 756 Quellwerte als typisierte physische, modale, Meta-, Bruch-, Kombi- und Generatoranforderungen.
- `native_reta_cli.mojo` besitzt `-spalten --alles` und `--onetable`; der HTML-Gesamtgenerator ruft den Tabellenkern direkt im selben Mojo-Prozess auf.
- Das Ein-Zeilen-Fixture enthält 805 Daten-/Generatorspalten plus zwei Nummerierungszellen und wird nach dem lokalen Build bytegenau geprüft.
- Der explizite Boundary-Bestand sinkt von drei auf zwei Runtime-Brücken.


## Stage 12c1 – native Terminalgeometrie und Promptframing

- `terminal_geometry.mojo` fragt stdout, stdin und stderr per Linux-`ioctl(TIOCGWINSZ)` ab und fällt anschließend auf `COLUMNS` beziehungsweise 80 zurück.
- `--breite=0` verwendet wieder die reale Bildschirmbreite minus sieben historische Reservespalten; die feste 80/73-Annahme ist entfernt.
- Der Promptcontroller bildet nicht das interne Rich-Argument `end=""`, sondern dessen beobachtbaren Bytestrom nach: Der sichtbare `reta`-Befehl endet vor dem ersten Tabellenkopf mit genau einem LF.
- Die öffentliche CLI bleibt unverändert. Weder ein zusätzlicher Schalter noch ein Ersatzbefehl ist nötig.
- PTY-Tests prüfen exakt `bin/rpb a1` bei 80, 120 und 200 Spalten; Fixture-Gates verhindern erneut zusammengeklebte Befehls-/Tabellenzeilen.
- Die `std.python`-Grenze des interaktiven Promptcallbacks bleibt für die folgenden 12c-Blöcke offen.

## Stage 12c2 – portable Prompt-Eingabe und OS-Geometrieadapter

- `terminal_geometry.mojo` unterscheidet Linux/WSL und macOS/Darwin statt die
  Linux-Requestnummer stillschweigend als universell zu behandeln.
- Nicht-TTY-Eingabe verwendet Mojos eingebautes `input()` und persistiert
  History best effort; Python wird nicht mehr vorsorglich in `main()` geladen.
- Auf echten TTYs bleibt die historische Readline-/Vi-/Completion-Grenze bis
  zur vollständigen nativen Tasten- und Completion-Parität erhalten.
- `RETA_PROMPT_PLAIN_INPUT=1` erzwingt optional den portablen schlichten
  Eingabekanal, ohne öffentliche Befehlsargumente zu verändern.


## Stage 12c3 – native rohe Promptbefehle

- `shell`, `python` und `math` rufen nicht mehr `mojo_bridge.py` auf.
- `prompt_external_commands.mojo` bildet Python-`partition`, POSIX-`shlex.split`, Arbeitsverzeichnis, Umgebung und Rückgabecode explizit ab.
- Der unveränderte Promptlauncher setzt intern `RETA_PYTHON` auf `.venv/bin/python`, sofern der Nutzer keinen Interpreter vorgibt; damit bleibt die frühere `sys.executable`-Wahl erhalten.
- Der Adapter startet nur ausdrücklich vom Nutzer verlangte Kindprogramme; er ist keine Rückkehr zu Prozessparallelisierung.
- `fork`, `pipe` und `_exit` bleiben durch den Boundary-Audit verboten; der ausdrücklich angeforderte Kindprozessadapter verwendet ausschließlich den gekapselten libc-`system()`-Aufruf.
- stdout und stderr werden nicht als Mojo-String dekodiert oder normalisiert. Nachgestellte Leerzeichen, mehrere Newlines, NUL und nicht-UTF-8-Bytes bleiben erhalten.
- Rohe Befehle umgehen den kompakten Byte-Scanner vor jeder Nutzlasttransformation; dadurch stürzt `python print("ä λ")` nicht mehr an einer UTF-8-Bytegrenze ab.
- Die historische CPython-Set-Reihenfolge der anschließenden Planungsdarstellung bleibt unverändert.
- Fokussierte Prüfungen: **22/22**.

## Stage 12c4a – Prompt-Bridge gekapselt und FFI-Integration repariert

- `prompt_main.mojo` importiert keine `std.python`-Typen mehr.
- Die drei verbleibenden Kompatibilitätsoperationen liegen ausschließlich in
  `prompt_python_bridge.mojo`.
- Der Stage-12c3-Kindprozessadapter verwendet kein `dlopen`/`dlsym` mehr. Die
  frühere eigene `dlsym`-Signatur kollidierte erst im vollständigen
  Promptcontroller mit der Signatur aus `std.python`.
- Ein kleiner Compile-Integrationsprobe importiert absichtlich gleichzeitig
  `std.python` und `prompt_external_commands.mojo`, damit dieser Fehler künftig
  ohne den monolithischen Promptbuild sichtbar wird.
- `scripts/build-heavy.sh` und `scripts/build.sh` genügen zum Kompilieren. Die
  `check_*`- und `test_*`-Skripte sind optionale Korrektheitsprüfungen und
  erzeugen keine zusätzlichen Release-Binaries.


## Stage 12c4b – Restfallback und `reta` ohne eingebettetes CPython

- `prompt_python_bridge.mojo` enthält nur noch den echten TTY-Readline-/Vi-/Completion-Eingang.
- Nicht-native `reta`-Zeilen werden mit POSIX-Shlex-Semantik direkt an `reta.py` übergeben.
- Atomare Promptfallbacks erhalten die typisierten Profilflags und die unveränderten Shellwörter direkt am Mojo-Kindprozessadapter.
- Leere Argumente, Unicode, Arbeitsverzeichnis, Umgebung und unverarbeitete stdout-/stderr-Bytes bleiben erhalten.
- Die Restalgorithmen sind damit noch Python-Kompatibilität, aber keine eingebettete Python-Brücke mehr.


## Stage 12c4c – gemischte reziproke Modifier aus dem Fallback übernommen

Die frühere native Schutzbedingung behandelte jede Kombination aus Bruch,
`vielfache` und `teiler` als unbestimmt. Die Python-Referenz zeigt jedoch eine
saubere Grenze: `1/n` wird erfolgreich bis kleiner 1024 expandiert, während
echtes `v n/m` mit Zähler größer eins im Original selbst mit `IndexError`
abbricht. Mojo besitzt nun genau die stabile Teilmenge und fällt nur an der
wirklich undefinierten Grenze zurück.

Dabei wurden drei ältere Serialisierungsabweichungen korrigiert. Die vollständig
materialisierte Reziprokachse erhält kein künstliches `--oberesmaximum=1025`.
Der Transzendentalien-Hauptparameter besitzt wieder die historische Schreibweise
`--Universum` statt `--universum`. Außerdem zählt die Universum-Spaltenheuristik sämtliche semantischen
Promptbefehle statt nur Tabellenfamilien; ein kompaktes `v1/n` trägt deshalb wie
in der Python-Vorbereitung einen impliziten `vielfache`-Befehl bei. Der
historische leere Ganzzahlanteil von reinem `teiler 1/n` bleibt als
abschließendes Komma erhalten.


## Stage 12c4d – nativer TTY-Editor und klassische Bruchfamilien

- `prompt_python_bridge.mojo` und der kombinierte `std.python`-Promptprobe sind entfernt. `prompt_main.mojo` ruft für Pipe-, Plain- und echte TTY-Eingabe ausschließlich Mojo-Module auf.
- `prompt_line_editor.mojo` trennt UTF-8-sichere Puffer-/Cursoroperationen, History und verschachtelte Completion von der Betriebssystemgrenze.
- `prompt_terminal_input.mojo` kapselt `termios`, `FIONREAD` und byteweise `FileDescriptor`-I/O. Emacs-/Vi-Kernbindings, Ctrl-C/Ctrl-D, Kandidatenanzeige und Terminalwiederherstellung laufen nativ.
- Die Neuzeichnung verwendet explizite CRLF-Wraps und einen mehrzeiligen Renderzustand. Dadurch werden lange Promptbefehle über Terminalzeilengrenzen hinweg gelöscht, neu gezeichnet und positioniert; ein 16-Spalten-PTY-Test öffnet anschließend im selben Prozess eine zweite Rohmodussitzung.
- Ist stdin oder stdout kein TTY oder wurde `RETA_PROMPT_PLAIN_INPUT=1` gesetzt, verwendet der Controller den portablen Mojo-`input()`-Pfad ohne ANSI-Steuersequenzen.
- Reine echte Brüche bei `mond`, `richtung`, `primzahlkreuz`, `alles` und `thomas` sind wie in der Python-Referenz erfolgreiche leere Pläne. Gemischte Tokens wie `mond 1/2,3` bewahren zugleich Bruch- und Ganzzahlanteil.
- Am Abschluss von Stage 12c4d verblieb nur noch die allgemeine `compat_main.mojo`-Brücke; Stage 12c4e entfernt auch deren eingebettete CPython-Laufzeit. Weiterhin nicht portierte Promptfachzweige werden als explizite Kindprozesse gestartet.


## Stage 12c4e – native-first Kompatibilitätslauncher ohne eingebettetes CPython

- `compat_main.mojo` prüft den vollständigen historischen Argumentvektor mit `native_reta_tokens_supported`. Nur vollständig besessene Vektoren erreichen `run_native_reta`; jede unbekannte oder teilweise portierte Option fällt atomar auf die Referenz zurück.
- Der Fallback verwendet den bereits gekapselten Kindprozessadapter, erhält Leerargumente, Unicode, Binärströme, Arbeitsverzeichnis und Exitstatus und bindet kein `libpython`.
- Zum Stand 12c4e blieb die leere Kommandozeile wegen Hilfe-/Defaultsemantik auf Python. Stage 12c4q übernimmt leeren Aufruf, reine Sprachwahl und lokalisierte Hilfe nativ. `RETA_FORCE_REFERENCE=1` erzwingt weiterhin die Referenz; `RETA_NATIVE=1` bleibt der explizite native Modus ohne Fallback.
- `--onetable` wurde in Stage 12c4e vorsorglich aus der nativen Supportliste entfernt, weil der Renderer diese Option damals noch nicht implementierte. Stage 12c4f führt sie für den Shellrenderer kontrolliert wieder ein.
- `prompt_python_bridge.mojo` und der alte kombinierte Python-FFI-Probe sind nun auch physisch aus dem Releasebaum entfernt. Der Boundary-Audit meldet **0 aktive `std.python`-Brücken**, **1 expliziten Kindprozessadapter** und **0 verbotene Parallel-Prozessprimitive**.
- Zwölf Referenzfälle laufen bei absichtlich ungültigem `RETA_PYTHON` byteidentisch. Damit ist nachgewiesen, dass physische, generierte, modale, Meta-, Bruch-, Kombi- und Markupfälle tatsächlich nativ ausgeführt werden.


## Stage 12c4f – native Shell-Ein-Tabellen- und Justtext-Ausgabe

- `NativeRetaPlan.one_table` besitzt `--onetable`, `--endlessscreen`, `--endless` und `--dontwrap`; der Shellrenderer überspringt damit die horizontale Seitenteilung.
- `--justtext` ist nativ das farblose Alias von `--nocolor`.
- `--breite=0 --onetable` verwendet die längste vollständige Zelle und erzeugt deshalb keinen automatischen Terminalumbruch. Positive Breiten behalten das historische Minimum 21; eine vorkommende Nullbreite sperrt spätere Breitenwerte.
- Der Wortumbruch übernimmt bei überlangen Wörtern den verbleibenden Platz der aktuellen Zeile Unicode-sicher, entsprechend Python `textwrap`.
- Zum damaligen Stand 12c4f blieben HTML/BBCode mit Ein-Tabellen-Alias noch atomarer Referenzfallback; Stage 12c4g hat diese Markup-Whitespace-/Metadatenparität inzwischen nativ geschlossen.


## Stage 12c4g – Markup-oneTable und Launcher-Endzustand

- `render_html_table_with_context()` und
  `render_bbcode_table_with_width_reference()` besitzen nun das typisierte
  `one_table`-Planfeld.
- Bei positiver Breite deaktivieren alle vier historischen Aliase die
  horizontale HTML-/BBCode-Seitenteilung; Breite null bleibt bytegleich.
- `native_reta_tokens_supported()` akzeptiert diese Argumentvektoren jetzt
  konservativ, sodass der normale `reta`-Launcher keinen Python-Kindprozess
  startet.
- Sechs versionierte Markup-oneTable-Fixtures bilden zwölf Alias-/Sprach-/
  Breitenfälle ab und werden mit absichtlich ungültigem `RETA_PYTHON` geprüft.
- Die im hochgeladenen Baum erneut vorhandenen, aber unbenutzten Dateien
  `prompt_python_bridge.mojo` und `prompt_external_python_ffi_probe.mojo` sind
  physisch entfernt; die vorhandenen Source-Gates verlangen ihre Abwesenheit.
- Während der Migration bleiben `reta`, `reta-native` und
  `reta-mojo-compat` getrennt. Nach vollständiger Transpilierung ist nur
  `reta` als öffentlicher Startname erforderlich. `reta-native` kann optional
  als Diagnosealias bestehen bleiben; `reta-mojo-compat` kann in Stage 12e
  entfallen oder auf `reta` verweisen.


## Stage 12c4h – native No-blank-Inhalte

- `NativeRetaPlan.no_blank_contents` besitzt `--keineleereninhalte` und den
  englischen Alias `--noblankcontents`.
- Die Referenzschwelle ist exakt: getrimmte sichtbare Fragmente mit weniger als
  zwei Unicode-Codepoints gelten als leer. Das betrifft vor allem `?`, aber
  auch andere einstellige Platzhalter.
- Shell, HTML und BBCode filtern pro horizontaler Seite und pro umgebrochener
  Sichtzeile. CSV, Markdown, Emacs und Plain filtern die logische Datenzeile.
- Der Emacs-Renderer besitzt nun die historischen Trenner nach nichtprimen
  Primzahlpotenzen. Der HTML-Pfad entfernt die interne Nummernausrichtung und
  verwendet für `Manipulation (1)` die semantische Heading-Metadatenbrücke.
- 13 versionierte Python-Fixtures sind über alle sechs Ausgabearten und den
  englischen Alias byteidentisch; Renderer **3/3**, HTML-Katalog **5/5** und
  CLI-/Ownership-Planer **25/25** sowie der vollständige Kompatibilitätslauncher
  **10/10** bestehen.


## Stage 12c4i – paginierte Rendererparität

- Der gemeinsame Shell-/Markup-Wortumbruch bevorzugt vorhandene ASCII-
  Bindestriche vor einem harten Überlangwortschnitt. Damit entstehen dieselben
  Fragmente wie im Python-Textwrap-/Hyphenationspfad.
- Der Shellrenderer unterscheidet ein vorhandenes leeres Fragment von einer
  Zelle ohne weiteres Fortsetzungsfragment. Nur der zweite Fall erhält die
  neutrale alternierende Restfarbe.
- Sechs versionierte deutsche und englische Shell-/HTML-/BBCode-Ströme mit
  positiver Breite und horizontaler Seitenteilung sind byteidentisch.
- Der neue Vertrag liegt in `scripts/check_paginated_rendering_parity.sh`; die
  Fixture-Regeneration ist ausschließlich über
  `RETA_REFRESH_PAGINATED_FIXTURES=1` möglich.
- Renderer **13/13**, CLI-/Ownership **25/25**, Kompatibilitätslauncher
  **10/10** und der native I/O-Boundary-Audit bestehen. Es gibt weiterhin
  weder aktive `std.python`-Importe noch eine `libpython`-Abhängigkeit.


## Stage 12c4j

- `NativeRetaPlan.widths` besitzt die historischen Aliase `breiten` und `widths` als typisierte `List[Int]`.
- Shell, HTML und BBCode verwenden pro ausgewählter Datenspalte eine eigene Wrap- und Seitenbreite.
- Der Shell-Seitenplan zählt die Nummerierungstrennung nicht länger doppelt.
- Positive Breiten sind native-first; Nullwerte, CSV/Markdown/Emacs und HTML/BBCode mit ausgeschalteter Farbe bleiben konservativer Ganzvektor-Fallback.
- Zwölf Referenzfixtures sind byteidentisch; der Launcher enthält weiterhin weder `std.python` noch `libpython`.


## Stage 12c4k

- Nullwerte innerhalb `NativeRetaPlan.widths` sind für Shell, HTML und BBCode kein Fallbackgrund mehr.
- Die sichtbare Markup-Tabelle und ihre rohe Breitenreferenz werden getrennt aufgebaut: Ausgabe-Whitespace bleibt normalisiert, die historische Umbruchentscheidung verwendet die ursprünglichen Leerraumläufe.
- Der Shellrenderer reproduziert die Referenzgrenze einer überbreiten ungebrochenen Nullspalte: auf der ersten Datenseite wird sie einmal übersprungen, auf späteren Seiten beendet sie den horizontalen Reststrom.
- Zwölf neue Nullbreitenfixtures decken `0`, `0,8`, `5,0` und `0,0` für Shell, HTML und BBCode ab.
- Der tote `prompt_python_bridge.mojo` samt veraltetem FFI-Probeimport wurde entfernt; alle aktiven Promptmodule sind wieder physisch frei von `std.python`.
- CSV/Markdown/Emacs und farbloses HTML/BBCode bleiben weiterhin atomarer Ganzvektor-Fallback.


## Stage 12c4l

- Der vermeintliche Datenpfadfehler übernommener Binaries wurde auf die ELF-Dynamikgrenze eingegrenzt: `libKGENCompilerRTShared.so` und `libAsyncRTMojoBindings.so` waren wegen eines fremden absoluten `RUNPATH` nicht auffindbar.
- `scripts/find_mojo_runtime.sh`, `scripts/configure_mojo_runtime.sh` und `bin/mojo-runtime-exec` bilden eine portable Runtimeauflösung. Der stabile Vertrag ist `target/lib/mojo`; absolute Installationspfade bleiben rechnerlokal.
- `build.sh` und `build-heavy.sh` linken zusätzlich mit `$ORIGIN/../lib/mojo`. CSV-Dateien werden weiterhin zur Laufzeit relativ zur Projektwurzel gelesen und erhalten keinen einkompilierten Ort.
- Der rohe HTML-/BBCode-Pfad von `--nocolor` bewahrt interne Leerraumläufe, exaktes `ljust`-Padding und die physischen Newlines des Python-`print`-Pfads.
- Die Ownership-Sperre für farbloses Markup ist entfernt; der Kompatibilitätslauncher führt diese Argumentvektoren ohne Python-Kindprozess aus.


## Stage 12c4o

- `--breiten`/`--widths` sind nun auch in CSV, Markdown und Emacs/Org nativ.
- Ein gemeinsamer flacher Zeilenexpander trennt logische von physischen
  Ausgabezeilen und erhält die historischen Nummerierungs- und Trennerregeln.
- CSV serialisiert fehlende mittlere Fortsetzungsfelder und den seltenen
  exakten `textwrap`-Randwhitespace bytegleich; unnummeriertes CSV behält seine zwei leeren Strukturfelder (`;;`). Markdown/Emacs normalisieren
  dieselben Fragmente vor der Ausgabe.
- Der atomare Ownership-Prüfer gibt diese Aufrufe frei; dreizehn Referenzfälle
  und der Kompatibilitätslauncher laufen ohne Python-Kindprozess.
- Der im Eingangsarchiv erneut vorhandene tote `prompt_python_bridge.mojo` ist
  wieder physisch entfernt; aktive `std.python`-Importe bleiben bei null.

## Stage 12c4p

- `integer_expressions.mojo` implementiert eine sichere Teilmenge des früheren
  `eval`-Vertrags für reine Ganzzahlen.
- `row_ranges.mojo` wertet dokumentierte Listen-/Mengen-/Tupelausdrücke und
  einvariable `range`-Comprehensions nativ aus.
- `native_reta_cli.mojo` übernimmt diese Syntax nur nach vollständiger
  Validierung; nicht unterstützte Python-Ausdrücke werden als Ganzvektor an die
  Referenz weitergereicht.
- Generatorausdrücke funktionieren zusätzlich in
  `--spaltenreihenfolgeundnurdiese` und den englischen Aliasen.
- Der irrtümlich native englische Alias `--maximum` wurde entfernt; die
  Referenzoberfläche verwendet `--uppermaximum`.
- Der erneut vorhandene, unbenutzte `prompt_python_bridge.mojo` und eine leere
  temporäre Testdatei wurden entfernt.

## Stage 12c4q

- `native_cli_startup.mojo` übernimmt den leeren Aufruf, reine Sprachwahl und
  lokalisierte Hilfe vor jeder Tabellenplanung.
- Die deutschen und englischen Hilfetexte werden als unveränderliche Assets aus
  der Python-Referenz generiert und unter `share/reta/assets` installiert.
- `compat_main.mojo` und der native Prompt-One-shot-Pfad verwenden dieselbe
  Startklassifikation; `RETA_FORCE_REFERENCE=1` bleibt vorrangig.
- `native_reta_tokens_supported` verlangt für Tabellenbesitz mindestens eine
  Nebenoption. Reine Hauptparameter können dadurch nicht mehr still die
  Standardtabelle erzeugen.
- Die wieder aufgetauchte tote Datei `prompt_python_bridge.mojo` wurde erneut
  entfernt; aktive `std.python`-Importe bleiben bei null.

## Stage 12c4r

- Fehler werden nicht mehr nur in einzelnen Stage-Dateien beschrieben. `KNOWN_DEFECTS.json` führt Ursprung, Klassifikation, Schwere, Python- und Mojo-Status, Reproduktion, Quellorte, Belege und die spätere Python-Aktion zusammen.
- `tools/check_known_defects.py` erzeugt `KNOWN_DEFECTS.md` sowie `PYTHON_CLEANUP_BACKLOG.md` und verweigert fehlende Belege, doppelte IDs oder eine veraltete generierte Fassung.
- Der Python-/PyPy3-Baum bleibt bis zum funktionalen Portabschluss eingefroren. Bewusste Mojo-Korrekturen erhalten einen offenen Python-Eintrag statt den Referenzfehler still zu überschreiben.
- `PY-OPEN-002` dokumentiert den `IndexError` bei `rpb 'universum v2/3'`. Mojo erweitert Zähler und Nenner unabhängig und schneidet sie an der realen CSV-Form ab.
- Die physischen Domänen sind Emotion 7×7 (Zähler 2–8), Strukturgröße 16×16 (2–17), Galaxie 21×21 (2–22) und Universum 21×19 (2–20).
- Ganzzahlige, reziproke und Universum-Gleichheitsprojektionen werden aus dem erzeugten Raster abgeleitet. Zum damaligen Stand blieben Mehrdomänen- und gemischte `1/n`+`n/m`-Vielfache konservativer Ganzvektor-Fallback; spätere Stages 12c5az und 12c5bf schließen beide Klassen domänenspezifisch.

## Stage 12c4s – rückwirkender Defektaudit und Kontroll-Hauptparameter

- Der zentrale Defektkatalog wurde gegen elf historische Migrations-, Test- und
  Stage-Quellen rückwärts geprüft. Er umfasst nun 35 verhaltensrelevante
  Befunde; 12 davon bilden den späteren Python-/PyPy3-Bereinigungsrückstand.
- Bestätigte Python-Abweichungen dürfen nicht mehr ausschließlich in Fließtext
  stehen. Der Katalog enthält jetzt auch die fehlerhafte Dictionary-Invertierung,
  die fließkommabasierte Mondzahlprüfung, die drei roten Baseline-Tests,
  Hashreihenfolge-Aliase und die heterogene Primwiederholungsschnittstelle.
- `-debug` wird als orthogonaler Präfix nativ ausgegeben. `-nichts`/`-nothing`
  ist dagegen kein Ausgabeformat: Ohne wirksame Restargumente bleibt der Aufruf
  leer, in einem echten Tabellenvektor wird der Hauptparameter wie in Python
  ignoriert. Nur `--art=nichts` beziehungsweise `--type=nothing` aktiviert den
  stillen Renderer.
- Der tote, erneut im Archiv aufgetauchte `prompt_python_bridge.mojo` wurde
  entfernt. Source-Gates erzwingen weiterhin null aktive `std.python`-Importe.
- Der von Mojo 1.0.0b2 automatisch ergänzte absolute Runtimepfad wird nach jedem
  Build durch `tools/sanitize_mojo_runpath.py` in-place entfernt. Der endgültige
  ELF-Vertrag lautet ausschließlich `$ORIGIN/../lib/mojo`.
- Der 20-Knoten-Kompatibilitäts-Pytest läuft wegen eines reproduzierten
  Teardown-Hängers in 20 einzeln isolierten Pytest-Prozessen; die vier Gruppen dienen nur der Berichterstattung.


## Stage 12c4t – native Stage-40-Wortvervollständigung

- `completion_word.mojo` ersetzt den allgemeinen Python-`WordCompleter`-Kern
  und die Legacy-Fassade `word_completerAlx.py` durch besitzende Typen.
- Der native `ArchitectureWordCompleter` besitzt Konfiguration und Wortsektion,
  kann von nativen Produzenten erneuert werden und stellt die Stage-40-
  Snapshotmetadaten bereit. Benutzerdefinierte native Muster liefern ihre
  Restriktion über `iter_word_completions_from_prefix`, statt ein untypisiertes
  Python-Regexobjekt im Completer zu halten.
- Der Cursor ist wie im nativen Editor eine UTF-8-Byteposition; die an
  Completion-Konsumenten gemeldete negative Startposition zählt dagegen
  Unicode-Skalare wie Python.
- Die historische Präfixkürzung auf Kandidatenlänge und der ungewöhnliche
  Middle-Match werden absichtlich reproduziert.
- Die aktive Python-Laufzeit übernimmt prompt_toolkits ASCII-basierte
  Standardwortregex. Dadurch wird `grö` in die Klassen `gr` und `ö` getrennt
  und `größe` nicht vervollständigt. `PY-CAND-007` hält diesen wahrscheinlichen
  Originalfehler für die spätere gemeinsame Korrektur fest; Mojo bleibt bis
  dahin kompatibel.

- `MOJO-FIXED-018`: Der Manifestgenerator verwirft `.pytest_cache` nun auf
  jeder Verzeichnistiefe. Dadurch ist das cachefreie Releasearchiv unmittelbar
  gegen `SOURCE_MANIFEST.sha256` prüfbar.


## Stage 12c4u – eigenständige native Completion-Besitzer

Die bereits im Promptpfad genutzte verschachtelte Completion wurde aus dem allgemeinen `prompt_language`-Besitz in zwei explizite Module überführt. `completion_runtime.mojo` ersetzt den dynamischen Laufzeit-Builder und `completion_nested.mojo` die vollständige Kontextzustandsmaschine einschließlich der historischen `nestedAlx`-Fassade. Der TTY-Editor, die Completion-CLI und beide Paritätsproben importieren den neuen Besitzer direkt.
Die frühere zweite Zustandsmaschine wurde aus `prompt_language.mojo` gelöscht, sodass nur noch ein nativer Completion-Besitzer kompiliert und gepflegt wird.

Die Fuzzy-Suche arbeitet nun über Unicode-Skalare statt UTF-8-Bytes. Außerdem übernimmt der Kataloggenerator bei englischen Zeilenwerten die tatsächlichen Python-Dictionary-Schlüssel; nur die drei vom Original lokalisierten Spezialdomänen werden danach überschrieben. Dieser ältere Mojo-Generatorfehler ist als `MOJO-FIXED-019` katalogisiert.

Validiert wurden 3/3 Runtime-Tests, 5/5 Zustandsmaschinentests, 12/12 bestehende sowie 67/67 erweiterte sprachübergreifende Completion-Kontexte.


## Stage 12c4v – native Prompt-Sitzung und Prompt-Runtime

- `prompt_session.mojo` ersetzt den veränderlichen Python-Sitzungsbesitzer mit
  typisierten Text-, Speicher-, Lösch-, Verlaufs- und Moduszuständen. Die
  doppelte `NativePromptSession`-Definition in `prompt_runtime.mojo` ist
  entfernt.
- `prompt_runtime_catalog.mojo` und der leichtgewichtige `prompt_prefix_catalog.mojo` frieren den vollständigen Runtimevertrag für
  Deutsch, Englisch, Vietnamesisch, Chinesisch und Koreanisch aus jeweils
  frischen Python-Prozessen ein. Dadurch werden i18n-/Architekturcacheeffekte
  des Referenzprozesses nicht versehentlich in andere Sprachen getragen.
- Die native Eingabe übernimmt die Python-Regel, dass `loggen`/`nichtloggen`
  und ihre Übersetzungen nicht selbst in der History gespeichert werden.
- Gespeicherte reine Dezimaltokens haben beim Löschen Vorrang vor derselben
  Positionsnummer. `reta 2 --nocolor` plus Löschangabe `2` entfernt damit den
  Wert `2`; ohne gespeicherten Wert `2` wird die zweite Position entfernt.
- Promptpräfixe sind nicht mehr hart deutsch oder um ein zusätzliches
  Leerzeichen erweitert. Der produktive Controller verwendet exakt `>`,
  `was speichern>`/`was löschen>` beziehungsweise
  `save what>`/`delete what>` aus dem generierten Vertrag.
- Die drei älteren Mojo-Abweichungen stehen als `MOJO-FIXED-020` bis
  `MOJO-FIXED-022` im zentralen Fehlerkatalog. Der Python-Baum bleibt
  unverändert, weil er hier die korrekte Referenz liefert.

## Stage 12c4w – native Prompt-Vorbereitung und vollständiges `--alles`

- `prompt_preparation.mojo`, `prompt_regex.mojo` und `prompt_preparation_catalog.mojo` besitzen Rotation, kompakte Befehle, Bereichsprojektion, Teiler-/Vielfachelogik sowie Regex-/Wildcardauflösung ohne Python-Callback.
- `prompt_preparation_domains.tsv` friert 506 fünfsprachige Parameter-/Wertdomänen reproduzierbar ein.
- 60/60 vollständige Vorbereitungskontexte über Deutsch, Englisch, Vietnamesisch, Chinesisch und Koreanisch sind byteidentisch.
- Der echte vollständige `--alles`-Lauf prüft 198 Zeilen und 149.356 Zellen. Eine Modallogik-Grenzabweichung wurde gefunden und geschlossen; anschließend sind 149.356/149.356 Zellen semantisch identisch.
- Rohes HTML bleibt wegen Maskierung, unsichtbarem Leerraum und Listenreihenfolge noch nicht byteidentisch; dieser offene Serialisierungsabstand ist als `MOJO-COMPAT-001` katalogisiert.
- Die direkte Aktivierungsnaht im großen optimierten Promptcontroller bleibt sichtbar, weil der zusätzliche Paketimport den Compilergraphen unverhältnismäßig vergrößert.


## Stage 12c4x – vollständiger Besitz des gesplitteten `i18n.words`-Bestands

- Die fünf aktiven Sprachmodule `i18n.words*` werden in getrennten frischen
  Python-Referenzprozessen in einen reproduzierbaren Baumkatalog exportiert.
- `i18n_words.mojo` lädt 34.667 typisierte Knoten ohne `std.python` und bewahrt
  Reihenfolge, Containerart, Named-Tuple-Felder, Klassenattribute, geteilte
  Objektverweise sowie die beobachtbaren `classify`-Ergebnisse.
- `reta-mojo-i18n` ist das zehnte reguläre Buildziel und bietet Summary-,
  Pfad-, Klassifikations- und Dumpzugriff auf den nativen Bestand.
- `PY-CAND-008` hält den fehlerhaften Python-Diagnosetext `-languages=` und die
  mehrfach aufgelisteten Sprachcodes für die spätere gemeinsame Bereinigung
  fest; Mojo konserviert den Text bis dahin bytegenau.
- `MOJO-FIXED-024` korrigiert alle 16 nativen Inspektionslauncher für eine
  FHS-Installation über Symlinks. Sie lösen `$0` vor der Rootbestimmung mit
  `readlink -f` auf.
- `MOJO-FIXED-025` normalisiert importzeitlich absolute Python-i18n-Pfade
  auf `python_reference/i18n`; das Source-only-Archiv regeneriert die fünf
  Kataloge dadurch unabhängig vom Entpackpfad byteidentisch.
- Vollständiger nativer/generierter Dateibesitz steigt auf 45/92 = 48,9 %,
  mindestens teilweise portierter Besitz auf 74/92 = 80,4 % und der
  gewichtete Quellersatz auf etwa 67,7 %.
- Der echte native `--alles`-Lauf bleibt mit 24.975.753 Byte vollständig. Da
  Stage 12c4x keine Tabellenquelle ändert, bleibt die in 12c4w bewiesene
  semantische Parität von 149.356/149.356 Zellen maßgeblich. Der zusätzliche
  aktuelle Python-Neulauf überschritt das 20-Minuten-Sandboxlimit und wird
  nicht als neuer bestandener Vergleich ausgewiesen.


## Stage 12c4y – eigenständiger nativer Parameter-Runtime-Besitzer

- `parameter_runtime.mojo` besitzt den produktiven typisierten Plan für Sprache,
  Ausgabeart, Breiten, Zeilen, physische/generierte Spalten, explizite
  Reihenfolge und dynamische Obergrenzen.
- `native_reta_cli.mojo` delegiert an diesen Besitzer; die frühere zweite
  Planimplementierung und ihre Alias-/Breiten-/Spaltenhelfer wurden entfernt.
- Native Modultests **8/8**, bestehende produktive CLI-Tests **30/30** und
  Python↔Mojo-Obergrenzenparität **6/6 semantisch**; der einzige
  Reihenfolgeabstand betrifft die vom Python-Original exponierte Setfolge für
  `v2-4`, während Multiset und Maximum identisch sind.
- `PY-CAND-009` dokumentiert hunderte doppelte 1024-Obergrenzenwerte im
  Python-Original; `MOJO-FIXED-026` schließt den doppelten nativen Besitzer.
- `TEST-FIXED-007` korrigiert den Generator der detaillierten
  Portierungsmatrix, der bereits übernommene Completion- und i18n-Dateien bei
  Regeneration fälschlich wieder als Bridge auswies.
- Ein vollständiger Python-`--alles`-Lauf kann als portables Referenzpaket
  gespeichert und für spätere reine Mojo-Stages wiederverwendet werden. Der
  aktuelle native Volltabellenlauf bleibt bei 24.975.753 Byte, 198 Zeilen und
  149.356 Zellen mit dem aus 12c4x bekannten SHA-256.
- Vollständiger Dateibesitz bleibt konservativ **45/92 = 48,9 %**; mindestens
  teilweise portierter Besitz steigt auf **75/92 = 81,5 %**, gewichteter
  Quellersatz auf etwa **68,8 %**.

## Stage 12c4z – professioneller FHS-fähiger `generate_html`-Einstieg

- Der öffentliche Starter wechselt nicht mehr in den Projekt- oder
  Installationsstamm und schreibt standardmäßig ausschließlich nach stdout.
- `--output` schreibt atomar; `--no-clobber` schützt bestehende Dateien.
- `--middle-file`, `--middle-output` und `--legacy-middle` trennen Eingabe,
  explizite Sicherung und historischen Kompatibilitätsmodus.
- Sprache, CSV- und Assetpfade sowie begrenzte Testzeilen sind als dokumentierte
  Optionen verfügbar; Fehler liefern definierte Exitcodes.
- Die FHS-Installation legt die Manpage unter `share/man/man1` ab und hält das
  Mojo-ELF privat unter `lib/reta/target/bin`.
- Die vom Nutzer erzeugte einstündige Python-`--alles`-Ausgabe ist als
  wiederverwendbare Referenz gebündelt. Da ihr `PYTHONHASHSEED` unkontrolliert
  war, richtet das Gate 20 nur umgeordnete Metaspalten anhand ihrer Überschriften
  aus und isoliert zehn nachweislich set-abhängige Spalten. Der stabile Kern ist
  mit 147.506/147.506 Zellen semantisch identisch.

## Stage 12c5a – native Prompt-Interaktions- und Controllergrenze

- `prompt_interaction.mojo` besitzt Startup→Sitzung, One-shot-Zusammenbau,
  Terminalsentinels, Speicher-/Löschmodi und Previous-Command-Policy.
- `prompt_main.mojo` konsumiert typisierte Interaktionspläne und behält nur
  beobachtbare I/O sowie Befehlsdispatch.
- Positionsunabhängige Inline-Speicherzeilen werden vor der Verlaufsaktualisierung
  erneut rein geplant; sie können den letzten ausführbaren Befehl nicht ersetzen.
- `reta_architecture/prompt_interaction.py` wechselt auf vollständigen nativen
  Besitz; `retaPrompt.py` und `libs/LibRetaPrompt.py` auf weitgehend nativ.
- Die erneut vorhandene tote `prompt_python_bridge.mojo` wurde entfernt;
  `MOJO-FIXED-017` und das Source-Gate decken die Regression ab.
- 7/7 native Modultests, 36/36 byteidentische Prompt-Sitzungskontexte und
  18/18 Source-/Ownership-/Boundary-Pytests bestehen.
- Der vollständige Promptquellgraph wurde mit Mojo 1.0.0b2 bis LLVM-IR
  kompiliert. Das abschließende Linken überschritt das 20-Minuten-Limit der
  Sandbox und wird nicht als neu gebautes Produktions-ELF gezählt.
- Vollständiger Dateibesitz: **46/92 = 50,0 %**; mindestens teilweise:
  **78/92 = 84,8 %**; gewichteter Quellersatz: **ca. 69,7 %**.



## Stage 12c5b – vollständige Prompt-Sprache und PyPy3-first

- `prompt_language.mojo` besitzt jetzt die vollständige historische
  `PromptLanguageBundle`-Oberfläche und lädt den fünfsprachigen Bestand aus
  `assets/prompt_language_legacy.tsv`.
- Der reproduzierbare Katalog enthält **17.123** Zeilen; **90/90**
  sprachgebundene Snapshotdatensätze sind byteidentisch zur Referenz.
- `scripts/select_reference_python.sh` vereinheitlicht alle Referenzpfade:
  explizite Vorgabe → `pypy3` → `python3` → `.venv` als letzter Fallback.
- `.venv`, `.git`, `target` und Caches bleiben aus Quellarchiven ausgeschlossen;
  Brotli-`tar.br` ist das neue Übergabeformat.
- `TEST-FIXED-012` dokumentiert die beseitigte falsche `.venv`-Priorität.
- Vollständiger Dateibesitz: **47/92 = 51,1 %**; mindestens teilweise:
  **78/92 = 84,8 %**; gewichteter Quellersatz: **ca. 70,7 %**.

## Stage 12c5c – native Paketintegrität und Split-i18n

- `src/reta_mojo/package_integrity.mojo` ersetzt den vollständigen Python-`RepoManifest`-Vertrag: reguläre Dateien und Dateisymlinks, Runtime-Filter, Bytezählung, binärer SHA-256-Baumdigest, 74 Pflichtpfade und Python-kompatible CSV-`splitlines()`-Zählung.
- Die Baumaufnahme verwendet direkt `realpath`, `opendir`, `readdir`, `readlink` und `closedir`; es wird kein Shell- oder Python-Hilfsprozess gestartet.
- `src/package_integrity_main.mojo` und `bin/reta-mojo-package-integrity` stellen Text-, JSON- und vollständige Dateilistenausgabe bereit; der Build linkt ausschließlich `libcrypto`, nicht Python.
- Der vollständige Referenzbaum stimmt mit **457 Dateien**, **34.576.137 Byte**, **79 CSV-Dateien** und Digest `572fb412ec96f32303f4ec944875112f5274db61094e6ebe8eb5c725972f8d5e` exakt überein.
- `src/reta_mojo/split_i18n.mojo` ersetzt den dynamischen `SimpleNamespace`-Merge durch einen typisierten Proxy mit identischer Modulreihenfolge und Later-wins-Auflösung.
- Native Modultests: **39/39**; Python↔Mojo-Paritätsbäume: **2/2 exakt**; Source-/Ownership-/Boundary-/Archivtests: **17/17**.
- `PY-CAND-011` erfasst die historische `lstrip("./")`-Dotfile-Kollision. Mojo reproduziert sie bis zur späteren kontrollierten Python-/Manifestmigration.
- Vollständiger Dateibesitz: **49/92 = 53,3 %**; mindestens teilweise: **71/92 = 77,2 %**; gewichteter Quellersatz: **ca. 71,2 %**.


## Stage 12c5d – vollständige Legacy-Fassaden `center` und `lib4tables`

- `src/reta_mojo/legacy_center.mojo` übernimmt alle 27 aktiven Wrapper aus `libs/center.py` und die historischen nPm-Gruppen.
- `src/reta_mojo/legacy_lib4tables.mojo` übernimmt die vollständige 18-Namen-Reexportoberfläche über native Ausgabemodi und Zahlentheorie.
- Der dynamische Python-Listenrückweg von `isPrimMultiple` ist als `isPrimMultipleMatches` explizit typisiert.
- Hilfeausgaben werden mit `tools/generate_legacy_help_assets.py` reproduzierbar aus den eingefrorenen Markdowndokumenten erzeugt.
- `tools/generate_unicode_digits.py` erzeugt aus einem TSV-Snapshot 83 Python-`str.isdigit()`-Bereiche mit 808 Codepoints; damit ist `MOJO-FIXED-028` geschlossen.
- `PY-OPEN-003` bleibt die einzige erwartete Differenz im gemeinsamen Fassadenprobe: Mojo bewahrt bei der Dictionary-Invertierung alle Quellschlüssel.
- Neue native Modultests: **12/12**; angrenzende fokussierte Regressionen: **26/26**; Fassaden-/Hilfetextparität: **5/5**; Source-/Ownership-/Boundary-/Archivtests: **15/15**.
- Vollständiger Dateibesitz: **51/92 = 55,4 %**; mindestens teilweise: **82/92 = 89,1 %**; gewichteter Quellersatz: **ca. 72,0 %**.

## Stage 12c5e – native CSV-/Kombinationsverkettung

- `src/reta_mojo/concat_csv.mojo` besitzt exakte Bruchwerte und -paare,
  Divisions-/Multiplikationsgruppen, fünf CSV-Quellen, Reziproktransposition,
  Überschriften, Primzahlkompaktion, Tabellenanhängung und typisierte
  Spaltenmetadaten.
- `src/reta_mojo/legacy_lib4tables_concat.mojo` ersetzt die dynamische
  34-Methoden-Fassade und konserviert die 13 Konstruktorzustände.
- Der Python↔Mojo-Probeprozess vergleicht 20 kanonische Zeilen byteidentisch.
- Sourcearchive werden bevorzugt als `.tar.xz` erzeugt. `xz -T0` aktiviert den
  parallelfähigen Modus; beim aktuellen 34-MiB-Tar blieb das kleinere Ergebnis
  ein Block, da erzwungene Mehrblockarchive größer waren. Brotli bleibt nur als
  serieller Kompatibilitätsweg erhalten.
- `tools/porting_metrics.py` ersetzt manuell inkrementierte Fortschrittswerte.
  `TEST-FIXED-013` dokumentiert die korrigierte Überzählung früherer Statuswerte.
- Maschinenberechneter Stand: **51/92 vollständig**, **73/92 mindestens
  teilweise**, **33.198/48.831 angegriffene Referenzzeilen**.

## Stage 12c5f – native Parametersemantik, Spaltenbindung und Universal-Synchronisation

- `src/reta_mojo/semantics_builder.mojo` ersetzt den vollständigen
  `ParameterSemanticsBuilder` durch getaggte Werte, Parameterpaare,
  Referenzgruppen und 14 typisierte Datenslots.
- `tools/generate_semantics_builder_catalog.py` friert den 431-Familien-Katalog
  als reproduzierbaren Mojo-Quellkatalog ein. Nur ungeordnete Python-Mengen
  werden kanonisiert; Listen und Tupel behalten ihre historische Reihenfolge.
- Normal- und Inversionsmodus stimmen in 20 Zähl-/Fingerprintzeilen exakt mit
  Python überein. Die Fingerabdrücke decken Matrixwerte, Parameterpaare,
  Datenbindungen, Gruppen, Kombinationen, Rückabbildungen und `alles`-Mengen ab.
- Indexierte String→Index-Tabellen ersetzen die zunächst korrekten, aber
  quadratischen linearen Suchen. Der Vollaufbau samt Fingerabdruck sinkt von
  über 20 Minuten auf ungefähr 0,8 Sekunden. 18 generierte Append-Chunks
  vermeiden zusätzlich die vorherige kalte Compilerexplosion; der Probe-Build
  sinkt auf ungefähr 20 Sekunden.
- `column_selection.mojo` besitzt die vollständige 24-Bucket-Oberfläche und
  explizite gebundene Programmsektionen. `universal.mojo` besitzt den
  Parameter-/Datenmerge und die Tabellenzustandssynchronisation.
- `TEST-FIXED-014` korrigiert drei veraltete 554→556-Referenztestwerte.
  `TEST-FIXED-015` beseitigt die Hash-Seed-Abhängigkeit des generierten
  Semantikkatalogs und seiner Vollfingerabdrücke.
- Stand: **54/92 vollständig nativ/generiert**, **74/92 mindestens teilweise**,
  **33.465/48.831 angegriffene Referenzzeilen**.


## Stage 12c5h

- `reta_architecture/__init__.py` ist keine Algorithmusimplementierung, sondern eine geordnete Reexportfassade. Ihr Vertrag liegt nun reproduzierbar in `assets/architecture_exports.tsv` und nativ in `architecture_exports.mojo`.
- Installationspakete dürfen Compilerziele nicht aus einem Wildcard-Verzeichnis ableiten. `scripts/install_targets.txt` ist die autoritative Allowlist; dadurch sind lokale Debugbinaries kein unbeabsichtigter Paketinhalt mehr.
- Artefaktvergleiche unterscheiden Containerbytes und fachliche Nutzlast. Eine `.alx`-Endung garantiert kein direktes HTML.


## 33. Architektur-Fassaden ohne dynamische Selbstobjekte

`reta_architecture/table_adapters.py` war keine neue Fachlogik, sondern ein dynamisches Python-`self` über bereits getrennten Besitzern. Mojo bildet deshalb nicht erneut zwei große mutable Klassen nach. `PrepareAdapterState` enthält nur den beobachtbaren typisierten Zustand; 17 logische `Prepare`-Methoden leiten auf reine Besitzerfunktionen. Die 34 `Concat`-Methoden werden aus der bereits nativen `legacy_lib4tables_concat`-Fassade reexportiert. Python-Properties werden als explizite Getter und Setter dargestellt. Dadurch bleibt die historische Oberfläche prüfbar, ohne `Any`, `getattr`, `OrderedSet` oder eine Python-Brücke in den nativen Kern zurückzubringen.


## 34. Architektur-Composition-Root als typisierter Graph

`RetaArchitecture` aggregiert 45 heterogene Besitzer, deren konkrete Mojo-Typen nicht alle gleichzeitig vollständig portiert sind. Statt die Python-Dynamik durch `Any` oder eine neue Bridge nachzubauen, wird der statische Vertrag aus der AST erzeugt: Feldoberfläche, Methoden, tatsächliche Bootstrap-Reihenfolge, `force_rebuild`-Grenzen, Abhängigkeitskanten und Snapshot-Reihenfolge. Der native Katalog validiert die Bijektion zwischen Feldern und Bootstrap-Zuweisungen, fortlaufende Ordinale, eindeutige Namen und auflösbare Methodenkanten.

Die lokale Exportfilter-Kopie ist ein eigener Ownership-Fall: `.copy()` erzeugt einen besitzenden lvalue; `List.append` darf diesen unter Mojo 1.0.0b2 nicht implizit kopieren. Da der Wert anschließend tot ist, wird er mit `entry^` übertragen.


## Stage 12c5k – ProgramWorkflow und Quellprofil

- `program_workflow.py` wechselt von vollständig referenziert zu teilweise nativ.
- Der native Kern besitzt die deterministischen Datei-, Dekodierungs-, Sprachspalten-, Flag- und Kombi-Planoperationen; die alte heterogene `Program`-Objekthülle bleibt vorläufig Referenz.
- `assets/program_workflow.tsv` wird reproduzierbar aus der Python-AST erzeugt und ist die statische Kontrollfläche für Reihenfolge und interne Aufrufkanten.
- Das offizielle Installationsmanifest enthält nun 33 Ziele einschließlich `reta-mojo-workflow`.
- Für Übergaben ist ausschließlich das von `scripts/create_source_archive.sh` erzeugte Quellarchiv nötig. Lokale Compilerumgebung, Binaries und Caches werden nicht übertragen.


## Stage 12c5l – UTF-8-sichere Dekodierung und nativer README-Besitz

- `bin/mojo-real` erkennt ein selbstreferenzielles `MOJO_BIN` und setzt danach die normale Compilerauflösung fort; `test_stage12c5e.sh` injiziert den Wrapper nicht mehr selbst.
- Der Religion-JSON-Scanner verwendet für syntaktische Suche `String.as_bytes()` und erzeugt String-Slices nur an ASCII-Trennzeichen.
- `libs/generate4readme.py` wechselt zu `generiert nativ`; die vollständigen Ausgaben werden unter `PYTHONHASHSEED=0` reproduzierbar erzeugt und zur Laufzeit rein nativ geladen.
- Das offizielle Installationsmanifest enthält nun 34 Ziele einschließlich `generate-readme-native`.
- Der Python-Defektkandidat `PY-CAND-012` dokumentiert vier hashseedabhängige Bruchparameterlisten.


## Stage 12c5m – reproduzierbare Testumgebung und nativer Domain-Probe-Kern

- `pytest` ist eine Python-Testabhängigkeit, keine Mojo-Bibliothek. `requirements-test.txt`, `scripts/setup_test_dependencies.sh` und `scripts/find_test_python.sh` halten Compiler- und Testinterpreter trotzdem in derselben lokalen `.venv` konsistent.
- `scripts/setup_mojo.sh` installiert die Testabhängigkeiten bei einer Neuinstallation automatisch; eine bestehende Umgebung wird mit `scripts/setup_test_dependencies.sh` ergänzt.
- `requested_religion_output_kind` reproduziert nun die Python-Mitgliedschaftslogik: BBCode hat feste Priorität vor HTML, unabhängig von der Reihenfolge der Argumente.
- Der normale ProgramWorkflow-Test verwendet eine kleine UTF-8-/JSON-Fixture statt bei jedem Lauf die vollständige Religionstabelle mit mehr als 760.000 Zellen zu dekodieren.
- `reta_domain_probe_py.py` wechselt zu teilweise nativ. Neun Kernbefehle werden direkt von `domain_probe_main.mojo` über den nativen Schemakatalog und die Parametersemantik bedient.
- Das reguläre Compilerziel `reta-mojo-domain-probe` ist in Buildlayout und Installationsmanifest aufgenommen; die offizielle Installationsmenge umfasst nun 35 Ziele.
- Ein unveränderter Source-Stand muss nach reinen Builds nicht erneut hochgeladen werden, da alle neu erzeugten Dateien unter dem ausgeschlossenen `target/` liegen.


## Stage 12c5n – CSV-Quotezustand und HTML-Klassenextraktor

- `csv_table.mojo` unterscheidet nun Quotes am Feldanfang von normalen Quotes in unquoted Nutzdaten. Das schließt die Religion-JSON-Lücke ohne quoted CSV-Felder zu verändern.
- Der versionsabhängige `prompt_toolkit`-Kandidat bleibt dokumentiert, aber Sourcegates verlangen kein veraltetes Fremdbibliotheksverhalten mehr.
- `html_class_extractor.mojo` ersetzt Repo-Suche, Stubmodule, Python-Unterprozess, Regex-Attributparser und JSONL-Schreiber des historischen Werkzeugs.
- Der normale Lauf erzeugt die Kopfzeile über `run_native_reta`; `RETA_HTML_CLASSES_INPUT` ist ausschließlich die deterministische Testnaht.


## Stage 12c5o – vollständiger Besitz von `meta_columns.py`

- Die öffentliche 14-Funktionen-Oberfläche ist typisiert in `meta_columns.mojo` und `prime_effect_columns.mojo` abgebildet.
- Mutable Receiverzustände wurden durch `MetaColumnsBundle`, `MetaColumnsSnapshot`, `MetaColumnRequest`, `MetaColumnMetadata`, `MetaColumnsCatalog` und rationale Werttypen ersetzt.
- Der reproduzierbare Katalog enthält 47 Universums- und 40 Galaxiebrüche sowie 884 historische Kombinationseinträge; Quellpfad, SHA-256 und Menge werden mitgeführt.
- Normale native Bruchentdeckung verwendet deterministische Tabellenreihenfolge. Nur die beobachtbare historische Python-Setreihenfolge wird unter `PYTHONHASHSEED=0` als Asset eingefroren.
- Der mathematisch verdächtige `stern/div`-Zweig bleibt aus Kompatibilitätsgründen leer und ist als `PY-CAND-013` für die spätere Python-Bereinigung dokumentiert.
- Fortschritt: **60/92 vollständig**, **83/92 mindestens teilweise**, **38.174/48.831 angegriffene Referenzzeilen**, **28.751/48.831 vollständig native Referenzzeilen**.


## Stage 12c5p – vollständiger Besitz von `morphisms.py` und einheitlicher Pytest-Einstieg

- `AliasMorphisms`, `RangeMorphisms`, `PromptMorphisms`, `RendererMorphisms` und `MorphismBundle` besitzen zusammen alle 13 Python-Methoden nativ.
- Der gemeinsame Topologiekontext wird als `ContextSelection` kopiert; Aliasauflösung und Spaltenbindung bleiben bei `ParameterSemanticsSheaf`.
- `RangeMorphisms.parse_row_range` sortiert und dedupliziert jetzt exakt wie `sorted(set(...))`; die bisherige native Variante sortierte nur.
- `PromptExpansionRequest` ersetzt das untypisierte Callback-Ergebnis der algorithmusfreien Python-Weiterleitung.
- Renderer verwenden direkt `OutputRuntimeState` und `apply_native_output_mode`.
- `scripts/run_pytest.sh` ist der einzige Shell-Pytest-Einstieg. 20 bestehende Skripte wurden migriert; mit dem Stage-Test verwenden 21 Skripte den Resolver.
- `TEST-FIXED-020` dokumentiert, warum `test_stage12c5j.sh` trotz installiertem `.venv`-Pytest zuvor `/usr/bin/python3` verwendete.
- Die Crashpad-Warnung des Modular-Tools wird nicht gefiltert; sie ist nicht fatal und stderr bleibt für echte Diagnosen vollständig sichtbar.
- Fortschritt: **61/92 vollständig**, **83/92 mindestens teilweise**, **38.174/48.831 angegriffene Referenzzeilen**, **28.840/48.831 vollständig native Referenzzeilen**.


## Stage 12c5q – UTF-8-sicherer Tabellenrenderer und vollständiger `runtime_compat`-Besitz

- Die Wortzerleger für Markup, Raw-Markup, Shell und Flat-Formate iterieren `codepoint_slices()` statt rohe Bytepositionen als spätere Stringgrenzen zu verwenden.
- `_slice_after_ascii_prefix` entfernt auch Unicode enthaltende Präfixe mit `removeprefix`; No-Progress-Fälle wechseln deterministisch zu `hard_chunks`.
- Der exakte produktive Aufruf `-zeilen --vorhervonausschnitt=1 -spalten --alles -ausgabe --art=html` ist als Mojo-Regressionsprogramm enthalten.
- Die wirkungslose `pending_space`-Zuweisung im HTML-Klassenextraktor wurde entfernt.
- `runtime_compat.py` besitzt nun seine vollständige öffentliche Oberfläche nativ; dynamische Python-Objekte werden durch `RuntimeCompatTextWrapRuntime` und `RuntimeCompatSnapshot` ersetzt.
- `arithmetic.has_digit` delegiert zentral an die reproduzierbare Unicode-Zifferntabelle und entspricht damit Python `str.isdigit`.
- Fortschritt: **62/92 vollständig**, **83/92 mindestens teilweise**, **38.174/48.831 angegriffene Referenzzeilen**, **29.029/48.831 vollständig native Referenzzeilen**.


## Stage 12c5r – expliziter Wrappingzustand und korrekte Morphismen-Kopien

- Der gemeinsame `ContextSelection`-Wert wird beim Aufbau jedes Teilmorphismus explizit kopiert. Mojo darf aus dem immutable Funktionsparameter keinen Besitz mit `^` übertragen.
- `table_wrapping.mojo` besitzt nun die komplette Python-Oberfläche. `TextWrapRuntimeState` ersetzt `_RUNTIME`, sodass Mutationen und Lebensdauer sichtbar und testbar sind.
- Externe Trennbibliotheken werden als Fähigkeiten modelliert. Ohne passende Capability bleibt der Python-kompatible unveränderte Ein-Element-Fallback erhalten; mit nativer Fähigkeit übernimmt der Codepoint-Wrapper.
- Fortschritt: **63/92 vollständig**, **83/92 mindestens teilweise**, **38.174/48.831 angegriffene Referenzzeilen**, **29.229/48.831 vollständig native Referenzzeilen**.


## Source-only Archive und veraltete Binaries

Da Quellarchive `target/` absichtlich ausschließen, kann ein alter lokaler Build beim Entpacken bestehen bleiben. Ab Stage 12c5s erhält jedes gebaute ELF eine Source-ID. Der zentrale Runtime-Launcher vergleicht diese mit dem aktuellen Manifest und mit den Änderungszeiten unter `src/`; veralteter Code wird nicht mehr still gestartet.

## UTF-8 im HTML-Renderer

Byteindizes werden nur noch zum Erkennen der ASCII-HTML-Syntax verwendet. Das Materialisieren von Text erfolgt aus `codepoint_slices()`. Damit kann auch ein unerwartet nicht ausgerichteter Scanneroffset keinen `String slice ... not a codepoint boundary`-Assert mehr auslösen.

## Stage 12c5t: Prägarben-/Garbengrenze vollständig nativ

- `presheaves.py` und `sheaves.py` wechseln von teilweise nativ auf vollständig nativ.
- Dynamische lokale Nutzlasten werden als kanonischer JSON-Text in einem typisierten `ContextSelection` geführt.
- `assets/presheaf_catalog.tsv` ersetzt die Laufzeit-Glob-Suche reproduzierbar und portabel.
- `assets/html_reference_sheaf.tsv` bewahrt die Python-Last-write-Semantik für 669 Zeile-0-Spalten.
- Parameter-, Generator- und Ausgabesynchronisation kopiert besitzend statt Python-Objektidentität zu teilen.
- `reta-mojo-sheaves` ist ein reguläres Diagnose- und Installationsziel; offiziell sind nun 19 reguläre plus 18 schwere Ziele vorhanden.
- Referenz-Python und pytest-Python werden im Stage-Test getrennt über die bestehenden Resolver gewählt.


## Stage 12c5u: Tabellenbau als typisierter Gluing-Orchestrator

`table_generation.py` mutiert nicht länger implizit einen heterogenen Program-Graph. `TableGenerationPlan` beschreibt Spalten-, Generator-, Bruch- und Kombi-Anforderungen; `TableGenerationResult` besitzt Tabelle, Auswahl, generierte Namen, Bruchschlüssel und beide Kombi-Relationen. Die historische Reihenfolge CSV → Last-Line → Generatoren → Kombi bleibt explizit erhalten.


## Stage 12c5v: vollständige Ausgabesemantik und Syntax

- `output_semantics.py` besitzt nun den kompletten Klassen- und Methodenvertrag einschließlich Aliasauflösung, Syntaxkonstruktion, Zustandsanwendung und sortierter Snapshots.
- `output_syntax.py` wechselt von teilweise nativ zu vollständig nativ; sieben Klassen werden als typisierte immutable Deskriptoren und ein `OutputSyntaxBundle` abgebildet.
- Die optionale Python-Callbackgrenze für erzwungene Breite null ist explizit; ohne Callback bleibt die Breite unverändert.
- HTML-Zellen verwenden den reproduzierbaren `HtmlCellCatalog`, statt dynamische `SpaltenParameter`, `OrderedDict` und generierte Tagobjekte erneut nachzubauen.
- `reta-mojo-output-syntax` ist das 21. reguläre Buildziel; der Installer kennt nun 39 offizielle reguläre und schwere Ziele.
- Fortschritt: **68/92 vollständig**, **83/92 mindestens teilweise**, **30.423/48.831 vollständig native Referenzzeilen**, **55.639 Mojo-Zeilen in `src/`**, aktive `std.python`-Brücken **0**.
- In der compilerlosen Erstellungsumgebung bestanden die fokussierten Gates **43/43** und der portable Source-Testbestand **128/128** mit einem begründeten compilerabhängigen Skip. `MOJO-FIXED-039` entfernt einen unbegründeten `Writable`-Vertrag; `TEST-FIXED-022` macht die Source-Suite archivportabel. `scripts/test_stage12c5v.sh` führt die vorbereitete native Kompilierung und Python/PyPy3-Parität lokal aus.

## Stage 12c5w: Compilerreparatur und vollständige Eingabesemantik

- `alias` ist ein reserviertes Mojo-Schlüsselwort. `_alias_matches` verwendet nun `alias_index`; der Stage-Test baut zuerst den vollständigen `src/main.mojo`-Importgraphen.
- `input_semantics.py` wechselt zu vollständig nativ beziehungsweise reproduzierbar generiert: vier Klassen, 18 Vokabularfelder, Row-Range-Snapshot, Builder und Input-Bundle.
- `assets/input_semantics_catalog.tsv` enthält 17.741 geordnete Datensätze. Listenreihenfolge, Duplikate und leere Domänen bleiben erhalten; Setfelder sind deterministisch.
- Der Generator erzwingt vor dem Referenzimport `PYTHONHASHSEED=0`, nachdem ein hashseedabhängiger Zwischenstand erkannt wurde (`TEST-FIXED-023`).
- Der FHS-Installer liefert die von `mojo-runtime-exec` benötigten Frischehelfer nun mit und prüft den neuen Katalog sowohl unter `share/reta/assets` als auch über den privaten Assetsymlink (`TEST-FIXED-025`).
- `RETA_TARGET_DIR` entkoppelt Paketierung und FHS-Layouttests von zufällig vorhandenen lokalen Compilerzielen (`TEST-FIXED-026`).
- Python-Zeichenschnitte und Regex-Escaping in `RowRangeSyntax` arbeiten auch für mehrbyteige Präfixe über Unicode-Codepoints (`MOJO-FIXED-041`).
- Der öffentliche `reta-mojo`-Launcher kennt den neuen `--mojo-input-snapshot`-Schemaweg (`MOJO-FIXED-042`).
- Maschinenstand: **69/92 vollständig**, **83/92 mindestens teilweise**, **38.174/48.831 angegriffene** und **30.672/48.831 vollständig native Referenzzeilen**; **55.849** Mojo-Zeilen in `src/`.

## Stage 12c5y – vollständiger TableOutput-Besitz

- `reta_architecture/table_output.py` wechselt von teilweise nativ zu vollständig nativ.
- `TableOutputConfig` ersetzt den impliziten heterogenen `Tables`-Objektgraph an der Ausgabegrenze; Modus, Syntaxklasse, Farbe, OneTable, Nummerierung, Breiten, Filter, Sprache, Quellspalten und Nummerierungsobergrenze sind typisiert.
- `TableOutput` besitzt Zustandszugriffe, einbasierte Spaltenprojektion, Ergebnisbuffer, `cliout2`, ANSI-Farbpolitik und die Delegation an sämtliche nativen Serializer.
- `TableOutputBundle`, Runtime-/Bundle-Snapshots, Diagnoseprogramm, Modultest und Python/PyPy3-Paritätsprüfer schließen die öffentliche Besitzergrenze.
- `TEST-FIXED-027` entfernt eine widersprüchliche Alt-Testannahme: Der All-Columns-Katalog bleibt ausschließlich in `parameter_runtime.mojo`; `native_reta_cli.mojo` delegiert ohne Duplikation.
- Compilerunabhängig bestanden **60/60** fokussierte Gates sowie **144** portable Source-Tests mit einem begründeten compilerabhängigen Skip. Der paketweite Resolver bestätigt **264/264** relative Mojo-Importe.
- Maschinenstand: **71/92 vollständig**, **83/92 mindestens teilweise**, **38.174/48.831 angegriffene** und **31.790/48.831 vollständig native Referenzzeilen**; **56.729** Mojo-Zeilen in `src/`.


## Gemeinsame Binärgrenzen statt duplizierter Diagnose-Executables

Vier vollständig native Diagnoseoberflächen teilen seit Stage 12c5z eine versionierte C-ABI in `libreta-mojo-diagnostics.so`. Nur triviale C-Werte (`argc`, `argv`, Integerstatus) überschreiten die Grenze; Mojo-Besitzwerte werden innerhalb der Bibliothek erzeugt und vernichtet. Ein kleiner Loader behält die bisherigen Programmnamen und isoliert ABI-/Source-ID-Prüfungen. Testprogramme bleiben dagegen separate, nicht installierte Prozesse, weil ihre Absturz- und Globalzustandsisolation diagnostisch wertvoller ist als eine gemeinsame Test-DSO. Weitere produktive Diagnosefamilien können nach demselben Muster gruppiert werden.

## Stage 12c5ab – Importzeit-Fassade ohne Prozessglobals

- `shell_rows_amount=0` bleibt als unbegrenzte Breite erhalten; Tests dürfen
  diesen Sentinel nicht mit `text_width` überschreiben.
- `libs/LibRetaPrompt.py` wird nicht durch eine neue Monolithklasse ersetzt.
  `LegacyLibRetaPromptBundle` ist eine dünne explizite Besitzgrenze über die
  bereits nativen Prompt-Subsysteme.
- Historische Sets und Dictionaries werden als deterministisch geordnete
  Listen beziehungsweise Einträge abgebildet, damit Snapshot und Parität ohne
  Python-Hashreihenfolge reproduzierbar bleiben.
- Die Fassade ist eine Bibliotheksoberfläche; sie erzeugt kein neues
  installierbares Compilerziel.
## Stage 12c5ac

- `LegacyPromptMapEntry` besitzt nun den vollständigen Mojo-Testwertvertrag `Equatable & Writable`.
- `prompt_preparation.py` wird durch `prompt_preparation.mojo`, `prompt_regex.mojo` und den generierten Domänenkatalog vollständig besessen; historische Namen sind typisierte Weiterleitungen.
- Die entfernten Python-Lazy-Caches werden nicht als mutable Globals nachgebildet, sondern durch den unveränderlichen Katalog ersetzt.
- Die alte produktiv bauende Datei `scripts/test_stage12c5z.sh` ist aus dem ausgelieferten Baum entfernt.

## Stage 12c5ad – TablePreparation und TableRuntime

- Die beiden historischen `old2Rows`-Dictionaries werden als eine typisierte
  Bijektion besessen.
- Header-/Tag-Mutation bleibt serialisiert; Threadparallelität ist eine äußere
  Strategie über denselben reinen Zeilenkern.
- `Tables` besitzt State, Prepare, Concat, KombiJoin, TableOutput und Maintable
  explizit statt über Lazy-Pythonimporte.
- Die sichtbare Gestirn-Ausgabeposition ist von der physischen angehängten
  Tabellenspalte getrennt; der Vanilla-Spaltenoffset wird beim Metadatenindex
  berücksichtigt.
- Fortschrittsmetriken sind monoton statt bei jeder Stage manuell exakt.
- Die vollständige Mojo-Testsuite verwendet den portablen Runtimewrapper.

## Stage 12c5an

- `mojo_bridge.py` wird nicht mehr als eingebettete Python-Brücke benötigt; seine 15 öffentlichen Namen und 19 Funktionsdefinitionen besitzen eine native Mojo-Fassade.
- TTY/History/Completion, externe Befehle und HTML-Gesamtseite sind klar getrennte Besitzer. Nicht vollständig portierte `reta.py`-/Promptpfade bleiben als explizite Kindprozesse sichtbar.
- `parameter_runtime.py` mutiert kein heterogenes Program-Objekt mehr. Spalten-, Breiten-, Parameter- und Obergrenzenauswertung liefern typisierte Planwerte.
- Die Parametergarbe hält zwei getrennte Aliasordnungen: lexikographisch normalisierte Gruppen für `params`/JSON und rohe Matrixeinträge für `column`/`exact_meta_for_column`.

## Stage 12c5ao

- `CsvTable` und die Listenfelder der Generated-Columns-Integration werden an der geliehenen Besitzergrenze ausdrücklich kopiert; Mojo 1.0 muss keine implizite Kopie eines nur `Copyable`-Werts mehr ableiten.
- `legacy_reta_program.mojo` bildet 27 öffentliche `reta.py`-Namen und 18 Methoden über einen expliziten Programzustand ab. Native Tabellenargumente laufen direkt, verbleibende Legacyfälle bleiben ein sichtbarer Kindprozessrand.
- `setup.py` ist vollständig generiert nativ: fünf Command-Klassen, acht Methoden, Paket-/Abhängigkeitsmetadaten, Gettext-Quellen und FHS-Installationsbesitz sind typisiert.
- Maschinenstand: **84/92 vollständig**, **87/92 mindestens teilweise**, **46.674/48.831 angegriffene** und **43.235/48.831 vollständig native Referenzzeilen**; **61.994** Mojo-Zeilen in `src/`.


## Stage 12c5bh – getrennte Testpipeline und nichtpositive Bruchachsen

- `scripts/build-tests.sh` kompiliert die vollständige Testsuite atomar und schreibt ein Inhaltsmanifest; `scripts/run-tests.sh` führt ausschließlich frische vorhandene Binaries aus.
- `scripts/test_all.sh` bleibt als kompatibler kombinierter Einstieg erhalten. `RETA_TEST_RUN_JOBS=N` aktiviert nur die kontrollierte Laufzeitparallelität; verschachtelt parallele und sehr schwere Tests bleiben exklusiv.
- `RETA_TEST_SANDBOX`/`TMPDIR` isoliert temporäre Testdateien. Der native Prompt-History-Test verwendet nicht länger globale feste Dateien als einzige Laufzeitadresse.
- Zwei exakt bekannte alte Kommandoasset-Hashes können kontrolliert migriert werden. Unbekannte Abweichungen bleiben Fehler und werden nicht automatisch neu eingefroren.
- Die äußere Ganzzahlachse kommalokaler `0`-/Ausschlusskomponenten neben echten Bruchvielfachen ist nativ. Separat geschriebene negative Tokens und nichtpositive `teiler`-Algebra bleiben eigene atomare Grenzen.

- Stage 12c5bj korrigiert die reale Mojo-Typgrenze `Set[Int] -> List[Int]` im
  Bruchteilerpfad und bindet den fokussierten Probe an den aktuellen Stage-Test.

## Stage 12c5bk – inkrementelle Tests und nichtwerfender Runtimezugriff

- Testbinaries besitzen nun transitive Inhaltsfingerabdrücke und werden bei
  unverändertem Buildkontext wiederverwendet.
- `--rebuild-all` erzwingt weiterhin die vollständige Testkompilierung.
- `Tables.hoechsteZeile()` verwendet `Dict.get()` statt eines werfenden
  Indexzugriffs in einem nichtwerfenden Kontext.

## 12c5bl

- `mond`, `alles`, `primzahlkreuz`, `richtung` und `thomas` verlassen bei
  mehreren physischen Bruchdomänen mit expliziter Ganzzahlachse die Python-Grenze.
- Die gemeinsame klassische Projektion ist die geordnete Vereinigung der
  domänenspezifisch korrigierten Ganzprojektionen.
- Thomas bleibt historischer Präfix; Mond, Alles, Primzahlkreuz und Richtung
  bleiben historische Suffixe.
- Primzahlkreuz besitzt weiterhin die Sonderachse `--oberesmaximum=1029` ohne
  projizierten Zeilenselektor.
- Die native Kommando-Parität trennt nun auch stdin vom aufrufenden TTY und
  setzt die Referenzgeometrie explizit auf 80×24. Breite Entwicklerterminals
  können die Seitenaufteilung damit nicht mehr verändern.

## Stage 12c5bm

- `_plan_multi_domain_true_fraction_multiples` besitzt nun gemeinsame,
  geordnet deduplizierte Ganzzahl- und Reziprokprojektionen für äußere
  EIGN/EIGR- und 15/16-Achsen.
- EIGN/EIGR werden nach Motive und vor Universum eingefügt; numerische Familie
  16 folgt nach dem physischen Plan vor Familie 15.
- Physische Bruchtabellen behalten ihre vier unabhängigen Rechtecke; die
  gemeinsame Projektion ersetzt diese Rechtecke nicht.
- Klassische Ganzzahlfamilien zusammen mit diesen neuen Erweiterungen bleiben
  zunächst atomar, damit keine unbelegte kombinierte Reihenfolge entsteht.
- `assert_python_positive_first_reciprocal_only` verwendet den instrumentierten
  Referenzsammler statt die vollständig gerenderte Ausgabe von `rpb` zu parsen.

## Stage 12c5bn

- Der Mehrdomänenplaner behandelt klassische Ganzzahlfamilien nicht mehr als
  Konflikt, wenn zugleich EIGN/EIGR oder numerische 15/16-Katalogachsen
  ausgewählt sind.
- Die kombinierte Ordnung ist nun explizit: Thomas, physische Blöcke bis Motive,
  EIGN, EIGR, Universum, Mond, Alles, Primzahlkreuz, Richtung, Familie 16,
  Familie 15.
- Alle äußeren Ganzzahlaufrufe teilen die geordnet deduplizierte Projektion der
  physischen Domänen. Primzahlkreuz behält ausschließlich die explizite
  Vielfachenachse und `--oberesmaximum=1029`.
- Der alte `_has_classic_integer_table_command`-Gate entfällt; unrelated
  Tabellenfamilien bleiben weiterhin an der atomaren Grenze.

## Stage 12c5bo

- Keine Produktionssemantik geändert.
- `scripts/check_prompt_true_fraction_multiples.py` erwartet im nativen
  positive-First-Emotion-Zweig nun die kanonische Option
  `--grundstrukturen=emotion`.
- Die instrumentierte Python-Referenzprüfung bleibt absichtlich bei
  `--Grundstrukturen=emotion`; ein neuer Sourcevertrag schützt diese Trennung.
- Der gemeldete Fehler nach dem erfolgreichen Vollbuild ist als
  `TEST-FIXED-061` dokumentiert.

## Stage 12c5bp – korrigierter Zwischenstand

- Der Stage-Lauf deckte die fehlende Unterscheidung zwischen kompaktem Präfix
  und eigenständigem Vielfachenwort auf.
- Die erste Reparatur vererbte ein führendes kompaktes `v` zu weit auf die
  gesamte Kommaliste; Stage 12c5bq ersetzt diese Annahme.

## Stage 12c5bq

- `_parse_fraction_token` setzt den Vielfachenmodus für jede Kommakomponente
  neu. Präfixe wie `v1/4` oder `v-1/8` bleiben lokal.
- `_fraction_pairs_with_multiple_scope` verarbeitet ausschließlich das
  eigenständige, positionsunabhängige `v` beziehungsweise `vielfache`.
- Nicht markierte echte Brüche werden einmal als Literalachse projektiert; nur
  markierte Komponenten werden im physischen Rechteck expandiert.
- Reziproke Ausschlüsse sind lokal einzelne Zeilen und global Vielfachenmengen.
- Gebundene Größen: lokal 2/4, global 13/19 Aufrufe für Einzel-/Mehrdomäne.
- `tests/test_python_fraction_multiple_scope_reference.py` prüft den Python-Code
  direkt und schützt die Sprachregel unabhängig vom Mojo-Prüfer.

- Der breite Python-Audit korrigiert zusätzlich zwei reine historische Testpfade: Projekt-Gitmarker über `REPO_ROOT.parent` und den realen Workflow-Schritt `load_religion_table`.

## Stage 12c5br

- `historical_prompt_output_parameters()` veröffentlicht die vollständige
  13-Namen-Ausgabeoberfläche als einen gemeinsamen Eigentumsvertrag.
- `historical_prompt_parameter_supported()` löst lokalisierte Namen weiter
  über den generierten Katalog auf, vergleicht anschließend aber gegen die
  vollständige native Oberfläche statt gegen eine manuelle Siebenerliste.
- `_ordered_prompt_parameters()` ordnet nicht die Parameterteilmenge isoliert,
  sondern filtert sie aus `python_string_set_order(words)`. Das entspricht der
  Python-Reihenfolge `Txt.liste = list(Txt.menge)` vor
  `returnOnlyParasAsList(Txt.listeE)`.
- Bereits native Rendereroptionen verlassen damit die explizite
  Kompatibilitätsgrenze, ohne die atomare Behandlung unbekannter Parameter oder
  unbesessener Prozesseffekte aufzuweichen.


- Der reale 12c5bq-Gesamtlauf zeigte zwei veraltete Erwartungen in
  `test_prompt_table_execution`: vollständiger Optionspräfix statt
  kommaabhängigem Teilstring und die neue lokale Reziprok-Setreihenfolge.
  Produktionscode und 13/13-Prüfer waren bereits konsistent.
- `create_source_archive.sh` löst für Brotli nun einen Interpreter auf, der das
  Modul tatsächlich importieren kann (`RETA_BROTLI_PYTHON`, Projekt-`.venv`,
  danach geprüfte Systemkandidaten).
- `generate_architecture_probe_assets.py` entfernt Laufzeitcaches mit
  `ENOTEMPTY`-/`EBUSY`-Retries und wiederholten Sweeps.


## Stage 12c5bs

- Die zweigliedrige `abc`-/`abcd`-Form wird über Mitgliedschaft statt nur über
  das erste Wort erkannt. Der interne `PromptCommand` wird command-first
  normalisiert, `raw` bleibt unverändert.
- `loggen` und `nichtloggen` sind für native Tabellen- und `mulpri`-Vektoren
  reine nachgelagerte Begleiteffekte. Der Eigentumsbeweis akzeptiert ihre
  Position unabhängig; der Controller wendet den Zustand erst nach erfolgreicher
  Ausgabe an.
- Enthält ein Vektor beide Befehle, gewinnt `loggen` wie im historischen
  Python-`if/elif`.
- Die direkte Laufzeitprobe für `universum v1/4,-1/8,2/3` erwartet nun explizit
  den komponentenlokalen Zwei-Aufruf-Plan statt den globalen Standardwert 13.


## Stage 12c5bt

- `PromptHistoricalCompanionEffects` besitzt die positionsunabhängigen
  Informationswirkungen Kurzbefehle, Befehle und Hilfe als typisierten Vertrag.
- `prompt_main.mojo` gibt diese Effekte nur nach vollständigem Eigentumsbeweis
  und vor Tabellen-/`mulpri`-Ausführung in historischer fester Reihenfolge aus.
- Zusammengesetztes `leeren` bleibt aufgrund der Terminalzeilenabhängigkeit
  atomar am Kompatibilitätsrand.
- Ein expliziter Ablehnungswächter steht vor dem Einzelbefehlsdispatch und
  verhindert partielle Hilfe-/Clear-/Loggingwirkungen bei unbesessenen Kommandos.
- Zwei aus dem 12c5bs-Gesamtlauf stammende veraltete Tabellenassertions wurden
  ohne Produktionsänderung korrigiert und in einem fokussierten Mojo-Test
  gebunden.

## 12c5bu

- Portiert die zusammengesetzte Promptwirkung `leeren`/`clear` ohne Python-Fallback.
- Ergänzt native Terminalhöhe und die reine Regel `rows + 1`.
- Bewahrt den getrennten ANSI-Vertrag für das alleinstehende Clear-Kommando.
- Korrigiert den 12c5bt-Testbuild: `assert_equal` wurde auf einer nicht `Writable`-Struktur verwendet.

## Stage 12c5co

- Der interaktive externe `reta`-Promptpfad reparst nicht mehr die rohe Zeile
  über `run_reta_line_native(external_process.raw)`.
- `prompt_interaction.mojo` erzeugt bereits den exakten argv-Vektor; der
  Controller übergibt diesen nun auch für den direkten `reta.py`-Kindprozess an
  `run_reta_arguments_native(external_process.arguments, reference_root())`.
- Shell-, Python- und Math-Befehle bleiben payloadbasiert; der `reta`-Fallback
  ist jetzt ebenfalls argumentbasiert und damit frei von einer zweiten
  Prompt-Split-Grenze.
- Der neue Snapshotmarker `external_reta_child=native-prompt-reta-child-argv`
  schützt diese Eigentumsgrenze.


## Stage 12c5cp – externe Prompt-Rohzeile aus Prozessplan entfernt

- `PromptExternalProcessDispatchPlan` trägt keine `raw`-Befehlszeile mehr.
- Shell, Python und Math verwenden ausschließlich den nativen Payload-Plan; direkte `reta`-Kindprozesse verwenden ausschließlich den argv-Plan.
- Der neue Snapshotmarker `external_raw_line=eliminated-from-external-process-plan` dokumentiert, dass die rohe Zeile nur noch im klassifizierten PromptCommand für Payloadableitung/Fallback-Konservierung existiert, nicht mehr im ausführbaren externen Prozessplan.
