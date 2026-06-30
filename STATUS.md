# Status – Stufen 9, 10 und 11 in Arbeit

- Zielversion: Mojo 1.0.0b2
- Unterstützte Python-Umgebung für Installation/Referenzbrücken: 3.10–3.14; Setup bevorzugt Python 3.14
- Abgeschlossene Release-Stufen: **8/12 = 66,7 %**
- Stufe 9: **BBCode, zentraler ANSI-Shellpfad und zentrale HTML-Pfade nativ; seltene Ausgabegrenzen offen**
- Stufe 10: **native Kurzsprache, mehrsprachige verschachtelte Completion und Promptvorbereitung in Arbeit**
- Stufe 11: **Architekturkarte, Grenzen, Verträge, Witnesses, Kohärenzmatrix und Trace-Navigation generiert nativ; ausführbare Gesamtvalidierung und spätere Aktivierungs-/Laufzeitnetze offen**
- Geschätzter funktionaler Portierungsstand: **88–91 %**
- Konservativ vollständig native oder reproduzierbar generierte Originaldateien: **24/92 = 26,1 %**
- Mindestens teilweise portierte Originaldateien: **52/92 = 56,5 %**
- Gewichteter Quellzeilenstand: **ca. 39 %**
- Nativer Mojo-Quellcode in `src/`: **28.570 Zeilen**
- Davon im Paket `reta_mojo`: **26.471 Zeilen**
- Native Mojo-Testdateien und -Probes: **62**
- Native Testfunktionen: **274**
- Stage-11c-Fokus: Kohärenz **11/53/42/22**, Traces **34/11/42/204**, native Tests **19/19**, Python↔Mojo-Abfragen **8/8 byteidentisch**, Generatoren **6/6** byteidentisch und beide Validierungen `passed`
- Stage-11b-Fokus: Verträge **33/11/22**, bekannte Kategorien/Funktoren/Transformationen **26/77/42**, Witnesses **536/11/33/42/55**, Ankerauflösung **351/351**, beide Validierungen `passed`; Generatoren über vier Hash-Seeds byteidentisch
- Stage-11a-Fokus: Architekturkarte **11/34/53/34/42**, Boundary-Graph **161/279/37/11**, Validierung **5/5**, Mojo-Tests **7/7** und Generator-Reproduktion über Hash-Seeds `0`, `1`, `42`, `random` byteidentisch
- Stage-10n-Fokus: **6/6** Unit, **23/23** Integration, **165/165** Katalogbefehle, **5/5** Tabellenströme, **2/2** EIGN-Promptnutzlasten und **6/6** isolierte One-shots bestanden
- Prompt-Kurzsprache: **27/27 deutsche und englische Referenzkontexte bytegleich**
- Promptvorbereitung: **23/23 deutsche und englische Referenzkontexte bytegleich**
- Verschachtelte Completion: **12/12 Referenzkontexte und 12/12 schnelle Fixtures bytegleich**
- Reguläre Compilerziele: **9 ELF-Executables** unter `target/bin/`
- Schwere optionale Compilerziele: Parameterschema, Kategorienkatalog, Architektur-Grenzgraph, Verträge, Witnesses, Kohärenz und Traces über `scripts/build-heavy.sh`

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
- persistenter nativer Completion-Arbeiter `reta-prompt-complete` mit direkter stdin/stdout-`FileHandle`-I/O
- GNU Readline bleibt nur Terminal-/Tastaturgrenze; Kandidaten und Kontextauflösung kommen aus Mojo
- interaktiver Pseudoterminaltest ergänzt `reta -ausgabe --art=htm<Tab>` zu `html`
- nativer Bruchparser für die vordere `prompt_execution.py`-Strecke einschließlich Bereichsbildung, Reziprok- und Ganzzahlerkennung
- native Fachbefehle `primfaktorenvergleich`, `abstand` und `abstandPrim`; Abstände besitzen keine Zweibereichsgrenze mehr und reproduzieren CPython-`set[frozenset[int]]`- sowie Difference-Reihenfolgen
- besitzende Tabellenplanung in `prompt_table_execution.mojo` für **18 Domänenfamilien plus EIGN/EIGR-Eigenschaftsachsen**
- Ganzzahlen einschließlich `0`, rein negative Selektoren, Reziproke und echte `n/m`-Achsen werden gemeinsam geplant
- ganzzahlige `vielfache`, `teiler` und `einzeln` sind nativ
- kombinierte ganzzahlige `vielfache`-/`teiler`-Pfade sind nativ; Teilervereinigung und rohe `vN`-Komposition behalten die verschachtelte CPython-Set-Reihenfolge
- historische Bruchrechtecke und Versätze wie `1/2-3/3` und `4/5+2/2` sind nativ
- stabile und kollidierende Ganzzahl-/Bruchausschlüsse, Bruchteiler sowie `v1/n`-/Reziprok-Vielfache sind nativ
- CPython-kompatible `set[str]`-Reihenfolge für rohe Ganzzahlkomponenten und vorzeichenbehaftete Bruchachsen
- gemischte Fachbefehle erzeugen mehrere native Tabellenaufrufe wie die unabhängigen Python-`if`-Zweige
- `range`, `invertieren`, Ausgabeparameter und die historische Universum-Spaltenunterdrückung werden erhalten
- `--nocolor` wirkt im Shellrenderer; ungültige explizite Ergebnispositionen öffnen nicht mehr alle Spalten
- explizites `--oberesmaximum` hebt wie Python beide historischen Zeilengrenzen an; ohne Angabe gilt die korrekte Kurzgrenze 163
- absolute eingebettete `vN`-Selektoren bestimmen wie Python vorab `max(Auswahl) + 1`, erweitern die native Tabelle über Zeile 1024 und bleiben vom kurzen `--vielfachevonzahlen`-Filter getrennt
- **18/18** Bruchparser-Referenzfälle, **25/25** Tabellenplanertests, **14/14** reale Bruch-/Modifikator-Tokenströme und **7/7** Prompt-Ausführungsfixtures bestanden
- native One-shot-Ausführung vor jedem Python-Import; Tabellenkern direkt im Promptprozess statt über `reta-native`-Kindprozess
- konservativer Besitzervertrag für rohe `reta`-Befehle; **22/22** CLI-Tests und 16 isolierte numerische One-shot-Klassen bestanden
- getrennte Legacy-Echotokens für kanonische native Ausführung
- vorbereitete Fragmentbreiten, vorhandene Bindestrichumbrüche und interne Leerzeichenläufe entsprechen der Python-`textwrap`-Reihenfolge
- `a2`, `ap15`, `p12`, `p13`, `G2`, `B2`, `E2`, `T2`, `W2` und `u2` vollständig bytegleich
- alle kompakten Tabellenfamilien, `mulpri`, reine positive Zahlen-/Bereichs-/Listen-/Bruchkompositionen und 365 adressierbare `15`-/`16`-Katalogauswahlen laufen ohne Python
- zentrale UTF-8-Dateischicht ohne `std.python`; positive Shell-/HTML-/BBCode-Breiten laufen auch im Prompt nativ
- `generate_html` besitzt Asset-, Override- und Seitenorchestrierung nativ; die große `--alles`-Mitteltabelle bleibt ein expliziter Referenzkindprozess
- wiederholte numerische Katalogauswahlen behalten ihr doppeltes Legacy-Echo, werden semantisch wie Python auf eine Generatoranforderung reduziert und laufen ohne Fallback
- die historische Shell-Zählungsmarkierung `█` ist zentral im nativen Renderer modelliert
- alle **165** katalogisierten deutschen `EIGN…`-/`EIGR…`-Eigenschaftsbefehle werden nativ geplant; CPython-Set-Reihenfolge, Ganzzahl-, Reziprok- und gemischte Zweit-`-zeilen`-Achsen bleiben erhalten
- EIGR umgeht den defekten Python-`deepcopy(module)`-Wrapper über dessen expliziten, direkt lauffähigen `reta.py`-Argumentvertrag

## Weiterhin an der Kompatibilitätsgrenze

- seltene Terminalbreiten-, Rich- und kombinierte HTML-Metadatenfälle
- echte `v n/m`-Vielfache mit Zähler größer 1 und weitere hintere Prompt-Sonderzweige
- vollständige i18n-Laufzeit außerhalb des Promptvokabulars
- dynamische Architekturvalidierung, Persistenz und Parallelisierung

Siehe [`ROADMAP.md`](ROADMAP.md) für alle zwölf Stufen.
