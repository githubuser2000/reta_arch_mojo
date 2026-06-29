# Status – Stufen 9 und 10 in Arbeit

- Zielversion: Mojo 1.0.0b2
- Unterstützte Python-Umgebung für Installation/Referenzbrücken: 3.10–3.14; Setup bevorzugt Python 3.14
- Abgeschlossene Release-Stufen: **8/12 = 66,7 %**
- Stufe 9: **BBCode, zentraler ANSI-Shellpfad und zentrale HTML-Pfade nativ; seltene Ausgabegrenzen offen**
- Stufe 10: **native Kurzsprache, mehrsprachige verschachtelte Completion und Promptvorbereitung in Arbeit**
- Geschätzter funktionaler Portierungsstand: **75–79 %**
- Konservativ vollständig native oder reproduzierbar generierte Originaldateien: **18/92 = 19,6 %**
- Mindestens teilweise portierte Originaldateien: **46/92 = 50,0 %**
- Gewichteter Quellzeilenstand: **ca. 28 %**
- Nativer Mojo-Quellcode in `src/`: **15.751 Zeilen**
- Davon im Paket `reta_mojo`: **14.766 Zeilen**
- Native Mojo-Testdateien und -Probes: **51**
- Native Testfunktionen: **208**
- Aktuell fokussiert dokumentiert: **93/93 bestanden**
- Prompt-Kurzsprache: **27/27 deutsche und englische Referenzkontexte bytegleich**
- Promptvorbereitung: **23/23 deutsche und englische Referenzkontexte bytegleich**
- Verschachtelte Completion: **12/12 Referenzkontexte und 12/12 schnelle Fixtures bytegleich**
- Reguläre Compilerziele: **9 ELF-Executables** unter `target/bin/`
- Schwere optionale Compilerziele: Parameterschema und Architekturkatalog über `scripts/build-heavy.sh`

## Stufe 7 abgeschlossen

- zwölf allgemeine Meta-/Konkretachsen aus `meta_columns.py`
- jeweils zwei Spalten für `n` und `1/n`
- exakte CPython-Mengenreihenfolge für alle **4.095** nichtleeren Teilmengen
- deutsche und englische Aliasauflösung
- historische Identitäts- und Übersetzungssonderfälle

## Stufe 8 abgeschlossen

- vier gebrochen-rationale CSV-Prägarben: Universum, Galaxie, Emotion und Strukturgröße
- nativer relationaler Kombi-Join für Galaxie und Universum
- **173** zweisprachige Kombi-Aliase
- **151** reproduzierbare Relationsordnungen
- Negativauswahl, Mehrfachauswahl und gemischte Galaxie-/Universum-Abfragen
- historische leere Segmente und abschließende Leerzeichen erhalten

## Stufe 9 weit fortgeschritten

- BBCode mit historischer Zählungsfarbe, Zellabständen, Wortumbruch und Seitenteilung
- HTML mit dynamischen Klassen für alle **746** physischen Haupttabellenspalten
- physischer HTML-Katalog mit **1.496** Sprach-/Spalteneinträgen
- semantischer Überschriftenkatalog für Generatorzellen
- tag-erhaltende HTML-Ausgabe für `<ul>`, `<li>`, `<br>` und weitere beabsichtigte Tags
- bytegleiche deutsche und englische HTML-Ausgabe für physische Spalten, Primzahlwirkung, Meta-Spalten und gebrochenes Universum
- nativer ANSI-Shellrenderer mit historischen Zeilenfarben, Wortumbruch, Seitenteilung und signifikanter Leerzeichenbehandlung
- fünf bytegleiche Shell-Fixtures: Deutsch/Englisch, Breite 0/40, ohne Nummerierung und generierte Primzahlwirkung

## Stufe 10 begonnen

- `prompt_language.mojo` als besitzender, mehrsprachiger Promptkatalog
- **28.990** Completion-Werte in **549** Kontextsektionen
- **200** lokalisierte Dispatch-Aliase
- **95** Ein-Zeichen-Ersetzungen
- **370** numerische Kurzbefehlszeilen
- **1.355** Vokabularaliase aus Befehls-, Hauptparameter-, Zeilen-, Ausgabe- und Kombinationsdomänen
- Klammer- und trennzeichenbewusstes Tokenisieren
- `prompt_toolkit`-kompatible Fuzzy-Teilsequenzordnung
- native Expansion kompakter Befehle wie `a15`, `ap15`, `15a`, `p12`, `(1 2)` und `uv3/2`
- exakte CPython-3.13-Set-Reihenfolge bei `PYTHONHASHSEED=0`, einschließlich des Unterschieds zwischen `set(iterable)` und Set-Merge
- persistenter nativer Completion-Arbeiter `reta-prompt-complete`
- GNU Readline bleibt nur Terminal-/Tastaturgrenze; Kandidaten und Kontextauflösung kommen aus Mojo
- interaktiver Pseudoterminaltest ergänzt `reta -ausgabe --art=htm<Tab>` zu `html`
- nativer Bruchparser für die vordere `prompt_execution.py`-Strecke einschließlich Bereichsbildung, Reziprok- und Ganzzahlerkennung
- native Fachbefehle `primfaktorenvergleich`, `abstand` und `abstandPrim`
- besitzende Tabellenplanung in `prompt_table_execution.mojo` für **18 ganzzahlige Promptfamilien**
- nativ geplant sind `mond`, `richtung`, `primzahlkreuz`, `alles`, `thomas`, `emotion`, `wirklichkeit`, `triebe`, `impulse`, `bewusstsein`, `geist`, `freiheit/gleichheit`, `groesse`, `kugeln/kreise`, `netzwerk`, `komplex`, `absicht/motiv` und `universum`
- gemischte Fachbefehle erzeugen mehrere native Tabellenaufrufe wie die unabhängigen Python-`if`-Zweige
- `range`, `invertieren`, Ausgabeparameter und die historische Universum-Spaltenunterdrückung werden in der Planung erhalten
- alle unterstützten Tabellenfamilien verwenden den kompilierten Tabellenkern; Python bleibt nur Prozess-/Readline-Grenze
- relative `--spaltenreihenfolgeundnurdiese=3-6`-Semantik nach der Generatorpipeline korrigiert
- **18/18** Bruchparser-Referenzfälle, **10/10** Tabellenplanertests und **7/7** reale Prompt-Ausführungsfixtures bestanden

## Weiterhin an der Kompatibilitätsgrenze

- seltene Terminalbreiten-, Rich- und kombinierte HTML-Metadatenfälle
- gebrochene `1/n`-/`n/m`-Tabellenzweige, Vielfachen-/Teilerkombinationen und weitere hintere Prompt-Sonderzweige
- vollständige i18n-Laufzeit außerhalb des Promptvokabulars
- dynamische Architekturvalidierung, Persistenz und Parallelisierung

Siehe [`ROADMAP.md`](ROADMAP.md) für alle zwölf Stufen.
