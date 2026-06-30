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

Der Shellrenderer bestimmt die Spaltenbreite jetzt nach dem historischen Vorbereitungsumbruch und nicht aus der Rohzelle. Vorhandene Bindestriche sind wie bei Python `textwrap` bevorzugte Umbruchstellen. Farbige Promptankündigungen und sichtbare `reta`-Echos verwenden die ursprüngliche `cliout`-Semantik ohne zusätzlichen Zeilenumbruch. Dadurch wechseln `bewusstsein`, `emotion`, `triebe`, `wirklichkeit` und `universum` in den vollständig nativen kompakten One-shot-Pfad. Reine Zahlenkürzel bleiben als eigenständige mehrteilige Komposition offen.


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
- `generate_html_main.mojo` besitzt Argumente, Environment, Override, `middle.alx`, Assets, Hierarchie und stdout. Nur die noch unportierte `--spalten --alles`-Mitteltabelle wird im Normalmodus als expliziter Python-Kindprozess erzeugt.
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

Der Python-Prozesspool wird nicht durch eine serielle Attrappe ersetzt. Der native Linux-Pfad startet mit `fork()` echte Kindprozesse, gibt jedem Worker eine private Pipe, liest die vollständige UTF-8-Nutzlast und prüft den Exitstatus mit `waitpid()`. Gleichzeitig aktive Kinder werden durch `max_workers` begrenzt.

Die dynamische Python-Grenze aus `Any`, Pickle, lokalen Handlern und `importlib` wird bewusst nicht nachgebaut. Tasks tragen besitzende UTF-8-Nutzlasten, kanonisches Metadaten-JSON und eine geprüfte Operation beziehungsweise bekannte `callable_path`. Dadurch bleibt der Scheduler statisch prüfbar und kann später um Reta-spezifische Workeroperationen erweitert werden.

Kanäle und Semaphoren des Ausführungsnetzes bleiben nichtblockierende deterministische Zustandsobjekte. Die konkreten Stage-11j-Tabellenworker benötigen dort keine geteilte Warteschlange: Sie erhalten feste Chunkslots über Mojos Threadpool, schreiben disjunkt und synchronisieren an der `parallelize`-Barriere.

`execution_run_snapshot_json()` verbindet Stage 11h mit der Stage-11g-Persistenz. Der Integrationstest persistiert einen echten Prozesslauf und dessen Auditspur in SQLite. Stage 11i ergänzt reine Chunk-Kerne; Stage 11j ergänzt den typisierten Thread-Zeilenpfad. Der Stage-11h-Prozessmodus bleibt bewusst als isolierter Ausführungsmodus bestehen.


## Stage 11i – native Thread-/Prozess-Chunk-Kerne

`reta_architecture/parallel_execution.py` wird nicht als dünne `multiprocessing`-Nachbildung portiert. Die Mojo-Schicht besitzt explizite Konfiguration, CPU-Erkennung, typisierte Ergebnisstatistiken und zehn reine Tabellen-/Zahlenkerne mit serieller Referenz, nativem Threadpfad und echtem Linux-`fork`-Pfad.

Der Python-Transport über Pickle und dynamische Objektgraphen wird durch ein längenpräfixiertes UTF-8-Protokoll ersetzt. Dadurch bleiben Unicode, Leerzeilen und beliebige Trennzeichen erhalten, während der Workervertrag statisch prüfbar bleibt. Die Reduktion erfolgt nach Chunkindex und ist damit unabhängig von der Reihenfolge, in der Kindprozesse beendet werden.

Der große `Prepare`-Objektgraph wird bewusst nicht per `deepcopy` und Pickle imitiert. Stage 11j führt dafür `ParallelRowPreparationContext` ein und verdrahtet Header-, Religionsnummern- und Kombi-Kontext in einen eigenständigen nativen Tabellenpfad.


## Stage 11j – typisierte native Thread-Zeilenvorbereitung

Für reine CPU-Arbeit auf bereits im Mojo-Prozess befindlichen Tabellen ist `auto` nun threadbasiert. Threads teilen die unveränderlichen Eingaben und vermeiden Prozessstart, Copy-on-write-Seiten, Pipeprotokolle und Ergebnisdeserialisierung. Der Modus `processes` bleibt explizit verfügbar, wenn Adressraumisolation wichtiger ist als gemeinsamer Speicher.

`ParallelRowPreparationContext` besitzt alle für Nichtkopfzeilen nötigen Tabellen-, Breiten-, Kombi- und Religionsnummerninformationen. Die Worker erhalten unveränderliche Eingaben, jeder Worker schreibt nur in seinen eigenen vorab angelegten `_PreparedChunk`, und die Hauptfaser reduziert nach dem ursprünglichen Zeilenindex. Dadurch braucht dieser Pfad weder Locks noch `deepcopy`, Pickle oder Python-Objektmutation. Header-Tag-Mutationen, SQLite-Schreibvorgänge und Ausgabe-I/O bleiben seriell.

Der neue Pfad liegt absichtlich in `parallel_row_preparation.mojo`, getrennt vom inzwischen großen `parallel_execution.mojo`. Diese Modulgrenze reduziert Mojos Elaborationslast und macht kleine Zeilenänderungen unabhängig von den älteren Prozessprotokollen kompilierbar.

Ein vorläufiger Lauf mit 20.000 Zeilen und acht Workern benötigte in der verwendeten Umgebung 4,12 s seriell und 3,22 s threadparallel bei identischer Prüfsumme. Kleine Eingaben bleiben über den Schwellwertmechanismus seriell, weil Schedulingkosten sonst den Nutzen übersteigen können.

### Korrektur der kompakten Prompt-Zeilengrenze

Die frühere Mojo-Portierung hatte Richs internen Aufruf `Console.print(..., end="")` wörtlich kopiert. Das gerenderte Python-`Syntax`-Objekt beendet seine physische Zeile dennoch mit LF. Mojo gab dagegen die nächste `reta`-Zeile direkt anschließend aus. Die neue Funktion `compact_prompt_announcement_line()` macht den beobachtbaren Bytevertrag explizit und liefert genau eine vollständige Zeile einschließlich `\n`.

Ein separater Fixture-Integritätstest verbietet nun `reta-Befehl:reta `, leere Referenzdateien und fehlende zweite Nutzlastzeilen. Damit wird nicht nur der konkrete Fehler, sondern auch seine bisherige Testlücke geschlossen.
