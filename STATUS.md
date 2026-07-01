# Status – Stage 12c4p abgeschlossen; Stufen 9, 10 und 12 in Arbeit

- Zielversion: Mojo 1.0.0b2
- Unterstützte Python-Umgebung für Installation/Referenzbrücken: 3.10–3.14; Setup bevorzugt Python 3.14
- Vollständig abgeschlossene Release-Stufen: **9/12 = 75,0 %**; teilgewichtet mit Stage 12c4p: **9,75/12 = 81,3 %**
- Stufe 9: **BBCode, zentraler ANSI-Shellpfad und zentrale HTML-Pfade nativ; seltene Ausgabegrenzen offen**
- Stufe 10: **native Kurzsprache, mehrsprachige verschachtelte Completion und Promptvorbereitung in Arbeit**
- Stufe 11: **11a–11j abgeschlossen; 10/10 Teilstufen = 100 %**
- Stufe 12: **12a–12b abgeschlossen; 12c zu ca. 99,7 %; insgesamt ca. 67 %**
- Geschätzter funktionaler Portierungsstand: **96–98 %**
- Konservativ vollständig native oder reproduzierbar generierte Originaldateien: **33/92 = 35,9 %**
- Mindestens teilweise portierte Originaldateien: **61/92 = 66,3 %**
- Gewichteter Quellzeilenstand: **ca. 52 %**
- Nativer Mojo-Quellcode in `src/`: **41.348 Zeilen**
- Davon im Paket `reta_mojo`: **38.206 Zeilen**
- Test-/Probe-Dateien: **107** (**92 Mojo**, **15 Python** einschließlich PTY-, Boundary-, Eingabe-, Rohbefehl-, Reziprok-, klassischer Bruchplan-, Kompatibilitätslauncher- und Alles-Plan-Audits)
- Native Mojo-Testfunktionen: **334**; Python-Testfunktionen: **61**
- Stage-12c4p-Fokus: sichere native Ganzzahlausdrücke und dokumentierte `range`-Comprehensions in Zeilenbereichen und Spaltenreihenfolge; Ganzzahlarithmetik einschließlich Python-konformem `//`/`%`, ein- bis dreiargumentigem `range`, negativen Schritten sowie additiver/subtraktiver Mengenkomposition. Nicht besessener Python-Code fällt atomar zurück statt still falsch nativ zu laufen. Ausdrucksparser **5/5**, Zeilenbereiche **8/8**, CLI-/Ownership **29/29**, Python↔Mojo-Probe **2/2**, sechs End-to-End-Ströme bytegleich und Prompt-/Boundary-Gates **10/10**; aktive `std.python`-Brücken **0**.
- Stage-12c4o-Fokus: native individuelle `--breiten`/`--widths` nun auch für CSV, Markdown und Emacs/Org; gemeinsamer physischer Zeilenexpander mit wiederholter Zählgruppe, nur erster Quellzeilennummer, Überschriften-/Primzahlpotenztrennern pro Sichtzeile, expliziten Nullbreiten sowie exakter CSV-Randwhitespace-, Leerfeld- und unnummerierter `;;`-Struktursemantik. Flache Breitenfixtures **12/12 byteidentisch** plus kombinierte Randfälle **5/5**, Renderer **20/20**, CLI-/Ownership **26/26**, Kompatibilitätslauncher **14/14**; positive Breiten **12/12**, Nullbreiten **12/12**, Rohmarkup **12/12**, Paginierung **6/6** und No-blank **13/13** bleiben grün; aktive `std.python`-Brücken **0**.
- Stage-12c4n-Fokus: vollständiger nativer `--alles`-HTMLpfad mit exakt **807** statt zuvor 863 Spalten; **56** außerhalb der realen Bruch-CSV-Form liegende Anforderungen entfernt, `PrimCSV` vor Bruchverkettungen eingeordnet, semantischer deutsch/englischer HTML-Katalog mit **1.626** Einträgen, exakte Positionsauflösung für mehrdeutige Überschriften sowie korrektes Mond-/Kombi-Listenmarkup und `&quot;`-Maskierung. Vollständiges `generate_html` Deutsch **301.206 Byte** und Englisch **295.215 Byte** jeweils bytegleich; Bruch **4/4**, Generatoren **9/9**, Metadaten **7/7**, Kombi **5/5**, angrenzende Breiten-/Markup-/Paginierungsparität **76/76**.
- Stage-12c4m-Fokus: zentrale native Ressourcenauflösung ohne einkompilierten CSV-/Assetpfad; FHS-konforme Installation nach `/usr/local/share/reta` beziehungsweise paketverwaltet `/usr/share/reta`, private Programme unter `lib/reta`, historische Quellbaumstruktur über relative Symlinks, `PREFIX`/`DESTDIR`/Benutzerinstallation und Deinstallation; Ressourcenresolver **3/3**, Installations-/Runtime-Pytests **9/9**, FHS-Staging einschließlich fremdem Arbeitsverzeichnis, nativer CSV-Ausgabe und Python-Fallback bestanden; Basistabellen **4/4**, positive Breiten **12/12**, Nullbreiten **12/12**, Rohmarkup **12/12**, Kompatibilitätslauncher **14/14**
- Stage-12c4l-Fokus: portable Mojo-ELF-Laufzeit über den projektrelativen Vertrag `target/lib/mojo`, zusätzlichen `$ORIGIN/../lib/mojo`-RUNPATH und automatischen Runtime-Starter; das Problem übertragener Binärdateien lag an zwei dynamischen Modular-Bibliotheken, nicht an CSV-Pfaden oder CPU-Befehlen. HTML/BBCode mit `--nocolor` besitzen nun den rohen Python-`print`-Vertrag einschließlich interner Leerraumläufe, exaktem Padding und physischer HTML-Zeilenstruktur; Markup-Parität **12/12 byteidentisch**, Renderer **18/18**, CLI-/Ownership **26/26**, Kompatibilitätslauncher **14/14**, Runtime-Pfadtests **4/4**, positive Breiten **12/12**, Nullbreiten **12/12**, paginierte Renderer **6/6**, No-blank **13/13**, Markup-oneTable **12/12**, Source-/Boundary-Pytests **14/14**, aktive `std.python`-Brücken **0**
- Stage-12c4k-Fokus: explizite Nullwerte innerhalb `--breiten`/`--widths` für Shell, HTML und BBCode; Nullbreitenfixtures **12/12**, damalige Renderer **17/17**, Ownership **26/26** und Launcher **13/13**.
- Stage-12c4j-Fokus: native positive Einzelspaltenbreiten über `--breiten`/`--widths` für Shell, HTML und BBCode, typisierte Ersetzungs- und Fallbacksemantik, globale Breite-null-Kombination sowie korrigiertes Shell-Seitenbudget; Breitenfixtures **12/12 byteidentisch**, Renderer **15/15**, CLI-/Ownership **26/26**, Kompatibilitätslauncher **12/12**, Source-/Boundary-Gates **14/14**, aktive `std.python`-Brücken **0**
- Stage-12c4i-Fokus: bytegleiche paginierte Shell-/HTML-/BBCode-Ausgabe; vorhandene ASCII-Bindestriche werden vor hartem Wortumbruch bevorzugt, und wirklich fehlende Shell-Fortsetzungsfragmente erhalten die neutrale Restfarbe; Renderer **13/13**, direkte deutsche/englische Mehrspaltenparität **6/6**, No-blank **13/13**, zentrale Markupfixtures **8/8**, Markup-oneTable **12/12**, CLI-/Ownership **25/25**, Kompatibilitätslauncher **10/10**, I/O-Boundary-Audit bestanden
- Stage-12c4h-Fokus: native `--keineleereninhalte`-/`--noblankcontents`-Semantik mit Unicode-Schwelle kleiner zwei, seiten- und Sichtzeilen-lokaler Filterung für Shell/HTML/BBCode sowie logischer Filterung für CSV/Markdown/Emacs; Emacs-Primzahlpotenztrenner und physische HTML-Heading-Metadatenparität für `Manipulation (1)` korrigiert; No-blank-Fixtures **13/13 byteidentisch**, Rendererkern **3/3**, HTML-Katalog **5/5**, CLI-/Ownership **25/25**, bestehende Markupregression **8/8 + 12/12**, Kompatibilitätslauncher **10/10**
- Stage-12c4g-Fokus: native HTML-/BBCode-Ein-Tabellen-Semantik für `--onetable`/`--endlessscreen`/`--endless`/`--dontwrap`; ein einziger Markup-Block bei positiver Breite, unveränderte Zellmetadaten und Zeilenfarben; Markup-oneTable **12/12** ohne Python, Renderer **11/11**, CLI-/Ownership **24/24**, gezielte Launcher-/Boundary-Pytests **11/11**; öffentliche Endarchitektur: nur `reta` erforderlich, `reta-native` optionaler Diagnosealias, `reta-mojo-compat` nach Entfernung des letzten Fallbacks entbehrlich
- Stage-12c4e-Fokus: native-first historische `reta`-Oberfläche ohne eingebettetes CPython; strenger Ganzvektor-Ownership-Test, atomarer Referenzfallback, echter Exitstatus, `RETA_FORCE_REFERENCE=1`, Entfernung der falschen `--onetable`-Freigabe und physische Bereinigung der alten Prompt-FFI-Dateien; Launcher **10/10** nach Stage-12c4h-Erweiterung, native-first Python↔Mojo-Vertrag **12/12 byteidentisch**, damalige CLI-Ownership **22/22**, Kombi **9/9**, Markup **8/8**, Basistabellen **4/4**, aktive `std.python`-Brücken **0**
- Stage-12c4f-Fokus: native Shell-Ausgabegruppe `--onetable`/`--endlessscreen`/`--endless`/`--dontwrap` und `--justtext`, echte Breite-null-No-wrap-Semantik, Mindestbreite 21, Nullbreiten-Sperre und Unicode-sicherer Python-Textwrap; Ausgabeparität **7/7 byteidentisch ohne Python**, CLI-/Ownership **24/24**, Renderer **10/10**, Kompatibilitäts-/Boundary-Pytests **19/19**, BBCode-Fixtures **3/3**; HTML/BBCode wurden anschließend in Stage 12c4g übernommen
- Stage-12c4d-Fokus: vollständig nativer POSIX-TTY-Editor ohne eingebettetes CPython, UTF-8-sicherer Editorzustand, History, verschachtelte Completion, Emacs-/Vi-Kernbindings und Terminalwiederherstellung; zusätzlich klassische Bruch-No-ops sowie gemischte Kommatokens wie `mond 1/2,3`; Editor **4/4**, History **4/4**, PTY **6/6**, Eingabe-/Boundary-Gates **12/12**, klassische Python↔Mojo-Pläne **8/8 byteidentisch**, Hash-Seeds **3/3** und Tabellenplaner **28/28**
- Stage-12c4c-Fokus: native Komposition von `vielfache`/`teiler` mit stabilen Reziprokbrüchen `1/n`, exakte semantische Befehlszählung für Universum-Spalten, Entfernung des fälschlichen Reziprok-`--oberesmaximum`, historische `teiler 1/n`-Leerseite, exaktes `--Universum`-Casing und ein vollständiger Python↔Mojo-Argumentvergleich über **7** Fälle; Pläne **7/7 byteidentisch**, Python-Referenz stabil über drei Hash-Seeds, native Tabellenplaner-Suite **28/28**, Source-/Boundary-Gates **7/7**
- Stage-12c4b-Fokus: direkte Mojo-Kindprozessgrenze für nicht-native `reta`-Zeilen und atomare Promptfallbacks, typisierte Profilargumente, POSIX-Shlex-/Leerargument-/Unicode-Erhaltung und Reduktion von `prompt_python_bridge.mojo` auf genau den echten TTY-Readline-/Vi-/Completion-Eingang; Mojo-Parser **6/6**, neue Kindprozessproben **2/2** und Source-/Boundary-Gates **9/9**
- Stage-12c4a-Fokus: vollständige Kapselung der verbleibenden Prompt-Python-Grenze in `prompt_python_bridge.mojo`, Entfernung von `std.python`-Typen aus `prompt_main.mojo`, Ersatz der konfliktierenden `dlopen`/`dlsym`-/`environ`-FFI durch den gekapselten libc-`system()`-Adapter sowie ein gemeinsamer FFI-Compilerprobe; Parser **6/6**, FFI-Probe **1/1**, Byteparität **7/7** und Source-/Boundary-Prüfungen **8/8**
- Stage-12c3-Fokus: direkte native Ausführung der Rohbefehle `shell`, `python` und `math` über einen eng begrenzten libc-`system()`-Adapter ohne kollidierende `dlsym`-Deklaration, UTF-8-sicherer Shlex-Parser, früher Rohbefehl-Bypass vor dem Kompaktscanner sowie bytegleiche stdout-/stderr-/Umgebungsvererbung; Parser **6/6**, Rohbefehlssprache **5/5**, Python↔Mojo-Byteparität **7/7** und Source-/Boundary-Gates **4/4**, zusammen **22/22**
- Stage-12c2-Fokus: zielabhängige Linux-/macOS-`TIOCGWINSZ`-Adapter, portabler `COLUMNS`-/80-Fallback, nativer Mojo-Eingabekanal für Pipes und umgeleitete Sessions, best-effort History ohne vorsorglichen Python-Import; Eingabe-/Historytests **3/3**, Pipe-/EOF-Proben **2/2**, Source-Ownership **2/2**, Geometrie **4/4** und Boundary-Audit **1/1**
- Stage-12c1-Fokus: unverändertes `bin/rpb a1`, explizite LF-Grenze zwischen sichtbarem `reta`-Befehl und Tabellenkopf, native `ioctl(TIOCGWINSZ)`-Geometrie für `--breite=0`, PTY-Proben **80→73**, **120→113**, **200→193**, Geometrietests **3/3** und Python-Audits **2/2**; der lokale End-to-End-PTY-Test ist im Releasecheck enthalten
- Stage-12b-Fokus: reproduzierbarer zwölfteiliger `--alles`-Spaltenplan mit **756** Quellwerten, **805** Daten-/Generatorspalten im Ein-Zeilen-HTML-Referenzfixture, vollständig natives `generate_html` und nur noch **2** explizite Laufzeitbrücken; Plan-/Boundary-Pytests **5/5**, Mojo-Loader **1/1**
- Stage-12a-Fokus: vollständige Threadmigration aller nativen Parallelpfade, typisierte Chunks statt Prozess-Stringprotokoll, **0** POSIX-Prozessprimitive, **10** kanonische Thread-APIs; fokussierte native/Paritätsprüfungen **480/480** plus Boundary-Pytest **1/1**
- Stage-11j-Fokus: nativer Threadstandard für In-Memory-Kerne; der damalige Prozess-Isolationsmodus wurde in Stage 12a vollständig entfernt, besitzender `ParallelRowPreparationContext`, deterministische Chunkslot-Reduktion, **36/36** Konfigurations-, **40/40** Zeilenvorbereitungs- und **2/2** Python↔seriell↔Thread-Vollstromparitätsprüfungen; **78/78** ausgeführte fokussierte Prüfungen
- Stage-11i-Fokus (historisch, durch Stage 12a abgelöst): zehn reine Tabellen-/Zahlenkerne und damalige Prozess-Chunkpfade, **29/29** damalige Konfigurations-, **55/55** Zeilenprozess-, **157/157** Zahlenprozess-, **26/26** Tabellen-, **12/12** Paritäts-, **6/6** Prompt-LF- und **1/1** Fixture-Integritätsprüfungen; insgesamt **286/286**
- Stage-11h-Fokus (historisch, durch Stage 12a threadbasiert): typisierte FIFO-/LIFO-/Prioritätsplanung, Kanäle und Semaphoren, deterministische Reduktion, **85/85** native Netzprüfungen, **15/15** Persistenzintegration und **8/8** Python↔Mojo-Paritätsfälle
- Stage-11g-Fokus: echte SQLite-Persistenz mit **6 Tabellen**, **12 Morphismen**, **47/47** nativen Prüfungen und **5/5** Python↔Mojo-Paritäts-/Interoperabilitätsprüfungen; stabile Digests und Datenbanken sind beidseitig lesbar
- Stage-11f-Fokus: Gesamtvalidierung **51/17/3.448**, Fortschritt **30/34/7/1**, native Tests **29/29**, Python↔Mojo-Abfragen **8/8 byteidentisch**, Generatoren **12/12** byteidentisch; Validierung `passed`, Fortschritts-Overlay konsistent `attention`
- Stage-11e-Fokus: Rehearsal **7/34/34/7**, Aktivierung **7/34/34/34/7**, native Tests **30/30**, Python↔Mojo-Abfragen **11/11 byteidentisch**, Generatoren **10/10** byteidentisch und beide native Kreuzvalidierungen `passed`
- Stage-11d-Fokus: Impact **34/34/10/34**, Migration **7/34/34/7**, native Tests **24/24**, Python↔Mojo-Abfragen **8/8 byteidentisch**, Generatoren **8/8** byteidentisch und beide Validierungen `passed`
- Stage-11c-Fokus: Kohärenz **11/53/42/22**, Traces **34/11/42/204**, native Tests **19/19**, Python↔Mojo-Abfragen **8/8 byteidentisch**, Generatoren **6/6** byteidentisch und beide Validierungen `passed`
- Stage-11b-Fokus: Verträge **33/11/22**, bekannte Kategorien/Funktoren/Transformationen **26/77/42**, Witnesses **536/11/33/42/55**, Ankerauflösung **351/351**, beide Validierungen `passed`; Generatoren über vier Hash-Seeds byteidentisch
- Stage-11a-Fokus: Architekturkarte **11/34/53/34/42**, Boundary-Graph **161/279/37/11**, Validierung **5/5**, Mojo-Tests **7/7** und Generator-Reproduktion über Hash-Seeds `0`, `1`, `42`, `random` byteidentisch
- Stage-10n-Fokus: **6/6** Unit, **23/23** Integration, **165/165** Katalogbefehle, **5/5** Tabellenströme, **2/2** EIGN-Promptnutzlasten und **6/6** isolierte One-shots bestanden
- Prompt-Kurzsprache: **27/27 deutsche und englische Referenzkontexte bytegleich**
- Promptvorbereitung: **23/23 deutsche und englische Referenzkontexte bytegleich**
- Verschachtelte Completion: **12/12 Referenzkontexte und 12/12 schnelle Fixtures bytegleich**
- Reguläre Compilerziele: **9 ELF-Executables** unter `target/bin/`
- Schwere optionale Compilerziele: Parameterschema, Kategorienkatalog, Architektur-Grenzgraph, Verträge, Witnesses, Kohärenz, Traces, Impact, Migration, Rehearsal, Aktivierung, Gesamtvalidierung, Fortschritts-Overlay, SQLite-Persistenz, Ausführungsnetz, thread-only Tabellen-/Zahlen-Chunks und typisierte Thread-Zeilenvorbereitung über `scripts/build-heavy.sh`

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
- nativer POSIX-TTY-Editor mit deterministischem Mehrzeilen-Wrapping; der eigenständige Completion-Arbeiter bleibt nur als kompatibles Test-/Werkzeugziel erhalten
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
- `generate_html` besitzt Asset-, `--alles`-Mitteltabelle, Override, Hierarchie und Seitenorchestrierung vollständig nativ; kein Python-Kindprozess
- wiederholte numerische Katalogauswahlen behalten ihr doppeltes Legacy-Echo, werden semantisch wie Python auf eine Generatoranforderung reduziert und laufen ohne Fallback
- die historische Shell-Zählungsmarkierung `█` ist zentral im nativen Renderer modelliert
- alle **165** katalogisierten deutschen `EIGN…`-/`EIGR…`-Eigenschaftsbefehle werden nativ geplant; CPython-Set-Reihenfolge, Ganzzahl-, Reziprok- und gemischte Zweit-`-zeilen`-Achsen bleiben erhalten
- EIGR umgeht den defekten Python-`deepcopy(module)`-Wrapper über dessen expliziten, direkt lauffähigen `reta.py`-Argumentvertrag

## Weiterhin an der Kompatibilitätsgrenze

- wenige verbleibende Rich-/Terminalsonderfälle außerhalb der seit 12c4i bytegleichen paginierten Kernpfade
- echte `v n/m`-Vielfache mit Zähler größer 1 und weitere hintere Prompt-Sonderzweige
- vollständige i18n-Laufzeit außerhalb des Promptvokabulars

Siehe [`ROADMAP.md`](ROADMAP.md) für alle zwölf Stufen.
