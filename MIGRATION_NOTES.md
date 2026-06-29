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

Entwicklungs- und Releasehelfer wie `coden`, `csvs` und `rpmake` gehören nicht zur transpilierten Laufzeit. Sie steuern lokale Git-Branches, Editoren, LibreOffice, Veröffentlichungsarchive oder fest codierte Rechnerpfade. `generate_html` wurde in Stufe 4 dagegen als tatsächlicher Laufzeitgenerator erkannt und portiert.


## Stufe 4: `grundStrukHtml.py` und `generate_html`

- `grundStrukHtml.py` wurde nicht als statischer HTML-Blob übernommen. Die Referenzhierarchie wird als reproduzierbarer, lokalisierter Traversierungskatalog erzeugt; Stacksteuerung, Blattdarstellung, Checkboxattribute und HTML-Ausgabe laufen nativ in Mojo.
- Die historische ungewöhnliche Sortier-/Traversalreihenfolge bleibt erhalten. Der Generator bildet auch den alten Bool-als-Comparator-Effekt bewusst ab.
- Deutsch und der internationale Katalog enthalten jeweils 151 Renderdatensätze und 84 Blätter. Englisch, Vietnamesisch, Chinesisch und Koreanisch teilen in der vorhandenen Referenz für diese Begriffe denselben internationalen Katalog.
- Vier Ausgaben (`normal`/`blank`, Deutsch/Englisch) werden vollständig per `cmp` gegen Python geprüft.
- `generate_html` ist nun ein Mojo-Einstiegspunkt. Die Berechnung des großen Tabellenmittelteils bleibt vorläufig in `reta.py`; die Dateikomposition und der Grundstrukturenabschnitt sind portiert.
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

Die reine Anwendung der sieben Ausgabemodi ist vollständig nativ. Auch deterministische Hilfen aus `console_io.py`, `runtime_compat.py`, `bbcode.py` und `html2text.py` sind übertragen. Terminalerkennung, Rich-Rendering und Prozess-I/O bleiben Systemgrenzen.

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

Die Prompt-Completion wird nicht durch einen Python-Import zur Laufzeit erzeugt. `generate_prompt_nested_catalog.py` extrahiert die wirksame Referenzoberfläche für Deutsch, Englisch, Vietnamesisch, Chinesisch und Koreanisch in kompakte TSV-Assets. 28.990 einzelne Completion-Werte werden dabei in 549 Kontextsektionen gruppiert. Separate Dateien halten 170 Dispatch-Aliase, 95 Ein-Zeichen-Ersetzungen, 370 numerische Kurzbefehlszeilen und 1.355 Vokabularaliase.

Der Generator unterstützt ein alternatives Ausgabeverzeichnis. `check_prompt_language_catalog.sh` regeneriert deshalb alle Dateien in einem temporären Verzeichnis und vergleicht sie byteweise mit dem Releasebestand.

### Tokenisierung und Fuzzy-Reihenfolge

`prompt_language.mojo` trennt Leerzeichen und Kommas nur außerhalb von `()`, `[]` und `{}`. Die Completion verwendet nicht bloß Präfixe: Sie bildet das beobachtete `prompt_toolkit`-Verhalten als Teilsequenzsuche nach, sortiert zuerst nach der frühesten Trefferposition, danach nach der kürzesten Treffspanne und bewahrt anschließend die Quellreihenfolge.

### Kompakte Kurzsprache

Die ehemalige `stextFromKleinKleinKleinBefehl`-Semantik ist als typisierte Mojo-Transformation portiert. Dazu gehören einfache und rotierte Formen wie `a15`, `ap15`, `15a`, `p12`, `(1 2)` und `uv3/2`, Bruchstandardbefehle, selektive Ausgabe, `-e` sowie die historischen `15_…`-/`16_…`-Ausnahmen.

Nicht intuitiv ist die sichtbare Reihenfolge mehrerer expandierter Tokens. Das Python-Original verwendet normale Sets. Der Port implementiert deshalb CPython 3.13 mit `PYTHONHASHSEED=0` für Strings über SipHash-1-3 und das beobachtete offene Hash-Tabellen-Probing. `set(iterable)` und Set-Merge vergrößern ihre Tabellen zu unterschiedlichen Zeitpunkten; beide Pfade werden getrennt nachgebildet.

### Interaktive Systemgrenze

GNU Readline bleibt eine Python-/Betriebssystemgrenze. Die eigentliche Completion läuft jedoch in `reta-prompt-complete`, einem persistenten Mojo-Prozess, der den vollständigen Eingabepuffer erhält und Kandidaten zurückgibt. Der Katalog wird dadurch nur einmal pro Sitzung geladen. Der Python-Adapter besitzt lediglich Prozesslebenszyklus, Pipe-I/O, Readline-Callback und einen statischen Notfallfallback.

Noch nicht portierte Fachoperationen erhalten an der Kompatibilitätsgrenze weiterhin die unveränderte Originalzeile. Dadurch gehen die historischen späteren Parserwirkungen nicht verloren, obwohl die vordere Kurzsprache und Completion bereits nativ sind.
