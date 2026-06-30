# reta.arch → Mojo

Dies ist ein inkrementeller, getesteter Port des hochgeladenen Python-Projekts `reta.arch` auf Mojo 1.0.0b2. Das Original umfasst 92 Python-Dateien und 48.831 Zeilen. Wegen der stark dynamischen Architektur werden zusammenhängende Laufzeitpfade typisiert übertragen; die Python-Referenz bleibt sichtbar, bis der jeweilige Pfad vollständig ersetzt ist.

## Fortschritt

```text
abgeschlossene Release-Stufen:       8 von 12 = 66,7 %
Stufen 9/10/11:                       Ausgabe, Prompt und Architektursteuerung in Arbeit
vollständig native Originaldateien:  26 von 92 = 28,3 %
mindestens teilweise portiert:       54 von 92 = 58,7 %
gewichteter Quellzeilenstand:         ca. 41 %
funktionaler Nutzerumfang:            ca. 88–91 %
```

Die Metriken messen Verschiedenes. Die Stufenquote ist höher, weil die noch offenen Stufen die größten dynamischen Python-Module bündeln. Der vollständige Plan steht in [`ROADMAP.md`](ROADMAP.md).

## Installation mit Python 3.14

```bash
RETA_MOJO_PYTHON="$(command -v python3.14)" ./scripts/setup_mojo.sh
```

Das Skript erzeugt `.venv`, installiert den Modular-Mojo-Compiler und baut neun reguläre ELF-Programme nach `target/bin/`. Eine Aktivierung mit `source` ist nicht nötig.

```bash
./scripts/check_build_layout.sh
```

`bin/` enthält nur versionierte Shell-Launcher. `.venv/`, `target/`, `build/` und Laufzeitartefakte stehen in `.gitignore`. Die sehr großen generierten Schema- und Architekturkataloge werden optional gebaut:

```bash
./scripts/build-heavy.sh
```

Details: [`BUILD.md`](BUILD.md).

## Stufen 7–10: Generatoren, Kombinationen, Markup und Prompt

### Native normale Reta-Syntax

```bash
./reta-native \
  -zeilen --vorhervonausschnitt=1-3 \
  -spalten --religionen=sternpolygon \
  -ausgabe --art=csv --breite=40
```

Oder über den historischen Namen:

```bash
RETA_NATIVE=1 ./reta \
  -zeilen --vorhervonausschnitt=1-3 \
  -spalten --religionen=sternpolygon \
  -ausgabe --art=markdown --breite=40
```

Ohne `RETA_NATIVE=1` bleibt `./reta` auf der vollständigen Kompatibilitätsoberfläche. Das verhindert, dass noch nicht portierte Optionen stillschweigend anders behandelt werden.

Auch die tatsächlichen englischen Namen werden unterstützt:

```bash
./reta-native \
  -language=english \
  -lines --thisrangebefore=1-3 \
  -columns --religions=starpolygon \
  -output --type=csv --width=40
```

### CSV-Kern

Nativ sind:

- Semikolon-CSV
- UTF-8
- Quotes und eingebettete Zeilenumbrüche
- schneller Pfad für die großen einfachen Tabellen
- Zeilen- und Spaltenprojektion
- kompletter Referenzbestand mit 16 CSV-Dateien

```bash
./bin/reta-mojo --mojo-csv-info
```

```text
Zeilen: 1025
Spalten: 746
Zellen: 764650
```

### Zeilenfilter

Vollständig nativ umgesetzt wurden:

- absolute und relative Bereiche
- positive und negative Werte
- Teilererweiterung
- Vergangenheit, Gegenwart und Zukunft
- Zählungsgruppen
- innere und äußere Primzahlklassen
- Mond, Sonne, schwarze Sonne und Planet
- Primvielfache und gewöhnliche Vielfache
- Potenzen
- Invertierung
- nachträgliche Positionsfilter

### Generatorspalten

Deutsch und Englisch sind nun für die zentralen historischen Generatorpfade nativ:

- Gleichheit/Freiheit/Dominieren, Geist/Energie, Prim-Kreativität und Gestirn
- Vielfachen-Vererbung, Modallogik, Mond-/Exponent-Beziehungen und Liebespolygon
- Primzahlkreuz Pro/Contra
- alle sieben Primzahlwirkungsquellen
- vier ganzzahlige Primuniversum-Familien
- vier gebrochen-rationale Primuniversum-Familien
- die beschriebene Primzahlvielfachen-Spalte `PrimCSV`

Die gebrochen-rationalen Generatoren verwenden einen reproduzierbaren Katalog mit 71.820 geordneten Relationen. Die historische CPython-Mengenreihenfolge wird beim Erzeugen des Assets mit `PYTHONHASHSEED=0` festgeschrieben. Zusätzlich sind nun die zwölf allgemeinen Meta-/Konkretachsen aus `meta_columns.py` portiert; ein Asset hält die exakte Reihenfolge aller 4.095 nichtleeren Teilmengen fest.

Beispiel:

```bash
./reta-native \
  -zeilen --vorhervonausschnitt=1-8 \
  -spalten --multiplikationen=motivgebrstern \
  -ausgabe --art=csv --breite=40
```

### Kombinationen und CSV-Verkettung

Stufe 8 portiert die vier gebrochen-rationalen CSV-Prägarben sowie den relationalen Galaxie-/Universum-Kombi-Join. 173 zweisprachige Aliase und 151 Relationsordnungen werden reproduzierbar geladen. Mehrfachauswahl, Negativauswahl, gemischte Galaxie-/Universum-Abfragen, leere Segmente und historische Rand-Leerzeichen sind erhalten.

### Ausgabe

CSV, Markdown und Emacs sind für die geprüften realen Befehle bytegleich. BBCode reproduziert Zählungsfarben, Zellabstände, Wortumbruch und Seitenteilung. HTML verwendet Klassenmetadaten für alle 746 physischen Haupttabellenspalten und einen semantischen Katalog für Generatorüberschriften. Beabsichtigte Tags wie `<ul>`, `<li>` und `<br>` bleiben aktiv, während mathematische Vergleichszeichen weiter maskiert werden.

Die derzeit bytegleich geprüften HTML-Generatorpfade umfassen Primzahlwirkung, allgemeine Meta-Spalten und gebrochenes Universum auf Deutsch und Englisch. Der zentrale farbige ANSI-Shellpfad ist ebenfalls bytegleich portiert. Offen bleiben seltene Terminal-/Rich-Sonderfälle und noch nicht katalogisierte kombinierte HTML-Familien.

## Stufe 10: native Prompt-Sprache

Die vordere Promptverarbeitung läuft nun in Mojo: klammerbewusstes Tokenisieren, kompakte Kurzbefehle, Ein-Zeichen-Ersetzungen, CPython-kompatible Mengenordnung und kontextabhängige Completion. Ein reproduzierbarer Katalog bündelt 28.990 Completion-Werte in 549 Sektionen und enthält fünf Sprachen sowie 1.355 Vokabularaliase.

Der zusätzliche Compilerprozess `reta-prompt-complete` bleibt während einer interaktiven Sitzung aktiv. GNU Readline übermittelt nur den vollständigen Eingabepuffer; Fuzzy-Suche, Parameterkontext und Kommawert-Completion werden nativ in Mojo berechnet. Noch nicht portierte Fachoperationen erhalten an der Kompatibilitätsgrenze weiterhin unverändert die ursprüngliche Eingabezeile.

Geprüft sind 27 kompakte deutsch/englische Kurzsprachenkontexte, 23 vollständige Vorbereitungskontexte und 12 verschachtelte Completion-Kontexte bytegleich zur Python-Referenz.

### Neu: native Prompt-Fachausführung

`src/reta_mojo/prompt_fraction_execution.mojo` übernimmt die vordere Bruch- und Bereichssprache aus `prompt_execution.py`. `primfaktorenvergleich` sowie `abstand`/`abstandPrim` mit beliebig vielen stabilen Zahlenbereichen werden nativ ausgeführt; die verschachtelte CPython-`set[frozenset[int]]`-Reihenfolge bleibt dabei erhalten.

`src/reta_mojo/prompt_table_execution.mojo` plant 18 Domänenfamilien: `mond`, `richtung`, `primzahlkreuz`, `alles`, `thomas`, `emotion`, `wirklichkeit`, `triebe`, `impulse`, `bewusstsein`, `geist`, `freiheit/gleichheit`, `groesse`, `kugeln/kreise`, `netzwerk`, `komplex`, `absicht/motiv` und `universum`. Mehrere Fachwörter in einer Eingabe erzeugen mehrere native Aufrufe wie die unabhängigen Python-Zweige; `range`, Invertierung und Ausgabeparameter werden weitergereicht. Stage 10n ergänzt die zwei dynamischen Eigenschaftsachsen `EIGN…` und `EIGR…` mit allen 165 deutschen Katalogbefehlen.

Neben den Ganzzahlpfaden werden ganzzahlige `vielfache`/`teiler`/`einzeln`, positive `1/n`- und `n/m`-Ausdrücke, reduzierte Achsen sowie historische Rechteck- und Versatzformen wie `1/2-3/3` und `4/5+2/2` nativ geplant. Stage 10d ergänzt stabile negative Bruchausschlüsse, Bruchteiler und Reziprok-Vielfache wie `v1/256,-1/512`; Stage 10i übernimmt zusätzlich Nullwerte, rein negative Selektoren und kollidierende All-Zeilen-Ausschlüsse. Die eigentlichen Tabellen laufen im kompilierten `reta-native`-Kern. Echte `v n/m`-Vielfache mit Zähler größer 1 bleiben an der Kompatibilitätsgrenze, weil die Python-Referenz in diesem Zweig selbst mit `IndexError` abbricht.

`--nocolor` ist im Shellrenderer jetzt wirksam. Außerdem kann eine explizite, nicht vorhandene Ergebnisposition nicht mehr auf die vollständige Spaltenmenge zurückfallen. Ein explizites `--oberesmaximum` hebt nun wie in Python beide historischen Zeilengrenzen an; ohne Angabe bleibt die Kurzgrenze korrekt bei 163.

### Stage 10e: native Einmalbefehle ohne Python-Prozess

Vollständig besessene One-shot-Befehle werden nun vor dem Import von `mojo_bridge.py` ausgeführt. Arithmetik, `abc`, `leeren`, die nativen Tabellenfamilien und streng validierte rohe `reta`-Aufrufe rufen den Tabellenkern direkt im selben Mojo-Prozess auf. Unbekannte Optionen bleiben atomar an der Bridge; positive Shell-/HTML-/BBCode-Breiten gehören nun zum nativen Promptvertrag. Details stehen in [`STAGE10E_NATIVE_PROMPT_ONESHOT.md`](STAGE10E_NATIVE_PROMPT_ONESHOT.md).

### Stage 10f: kompakte Kurzformen mit historischem Echo

Eine getrennte Legacy-Präsentationsschicht gibt nun die ursprüngliche Expansion und gemischt geschriebenen Optionsnamen aus, während der Tabellenplan intern kanonisch bleibt. Rendererstabile Kurzformen der Familien `absicht/motiv`, `geist`, `impulse`, `thomas` und `richtung` sowie der zusammengesetzte `mulpri`/`p`-Ablauf laufen ohne Python-Import. Fünf vollständige Ausgaben sind mit Python 3.13.5 und `PYTHONHASHSEED=0` bytegleich eingefroren. Rendererempfindliche Familien und reine Zahlenkürzel bleiben als ganze Eingabe am Fallback. Details: [`STAGE10F_NATIVE_COMPACT_PROMPT.md`](STAGE10F_NATIVE_COMPACT_PROMPT.md).

### Stage 10g: vollständige kompakte Tabellenfamilien

Der Shellrenderer misst Spalten nun an den mit Breite 73 vorbereiteten Fragmenten und übernimmt Python-`textwrap`-Umbrüche an vorhandenen Bindestrichen. Dadurch laufen auch `bewusstsein`, `emotion`, `triebe`, `wirklichkeit` und `universum` als kompakte One-shots vollständig nativ. Zehn komplette Ausgaben sind bytegleich; Ankündigung, sichtbares `reta`-Echo und erste Tabellenzeile behalten den historischen zusammenhängenden Farbausgabestrom. Reine Zahlenkürzel waren in diesem Zwischenstand noch als mehrteilige Komposition an der Bridge. Details: [`STAGE10G_RENDERER_COMPACT_PARITY.md`](STAGE10G_RENDERER_COMPACT_PARITY.md).

### Stage 10h: native Zahlen- und Katalogkomposition

Positive reine Zahlen, Bereiche, Listen und Brüche komponieren nun dieselben typisierten Tabellen- und `mulpri`-Pläne direkt im Mojo-Prozess. Auch `15_<key>`, `16_<key>` und `16_15_<key>` werden aus dem fünfsprachigen Katalog auf Grundstrukturen beziehungsweise Multiversum abgebildet; 365 historisch adressierbare Einträge sind geprüft. Der Shellrenderer gibt die Zählungsgruppenmarkierung `█` wie Python aus. Elf vollständige Zahlenfixtures sind bytegleich, acht repräsentative Klassen laufen isoliert ohne Python oder Kindprozess. `0`, rein negative Ausdrücke und doppelte generierte Spalteninstanzen bleiben bewusst am Fallback. Details: [`STAGE10H_NATIVE_NUMERIC_PROMPT.md`](STAGE10H_NATIVE_NUMERIC_PROMPT.md).

### Stage 10i: native numerische Selektoralgebra

`0`, rein negative Ganzzahlselektoren und kollidierende positive/negative Ganzzahl- und Bruchbedingungen werden jetzt vollständig nativ geplant. Gleiche positive und negative Prädikate kürzen sich vor der Zeilenauswahl; eine danach leere Bedingungsmenge aktiviert wie in Python die All-Zeilen-Semantik. Beim `teiler`-Modifikator erfolgt diese Kürzung vor der Teilerbildung. Die CPython-`set[str]`-Reihenfolge und die besondere Nummernspaltenbreite des All-Zeilen-Pfads sind reproduziert. Wiederholte Katalogauswahlen wurden in Stage 10j übernommen; echte `v n/m`-Vielfache mit Zähler größer 1 bleiben offen. Details: [`STAGE10I_NATIVE_NUMERIC_SELECTORS.md`](STAGE10I_NATIVE_NUMERIC_SELECTORS.md).

Stage 10l ersetzt die zentrale `pathlib`-Dateibrücke durch natives Mojo-I/O, gibt dem persistenten Completion-Arbeiter direkte stdin/stdout-Dateideskriptoren und portiert die äußere `generate_html`-Orchestrierung. Dessen Overridepfad ist vollständig Python-frei; nur die noch offene große `--spalten --alles`-Mitteltabelle bleibt im Normalmodus ein expliziter Referenzkindprozess. Positive Shell-, HTML- und BBCode-Breiten laufen nun auch aus dem Prompt vor jedem Python-Import. Details: [`STAGE10L_NATIVE_IO_ORCHESTRATION.md`](STAGE10L_NATIVE_IO_ORCHESTRATION.md).

### Stage 10m: komponierte Ganzzahlmodifikatoren und dynamische `vN`-Grenzen

Ganzzahlige `vielfache`- und `teiler`-Befehle werden nun auch kombiniert vollständig nativ geplant. Die sichtbare Teilervereinigung reproduziert die verschachtelte CPython-3.13-Semantik aus Faktor-Tupelmengen, zweielementigen Ganzzahlmengen und `set_merge`; dadurch bleibt selbst die Reihenfolge `24 -> 2,3,4,6,8,24,12` erhalten. Absolute `vN`-Selektoren heben die native Tabellenobergrenze wie Python aus `max(Auswahl) + 1` an und können die physische CSV-Tabelle für generierte Zeilen über 1024 erweitern. Details: [`STAGE10M_NATIVE_INTEGER_MODIFIER_COMPOSITION.md`](STAGE10M_NATIVE_INTEGER_MODIFIER_COMPOSITION.md).

### Stage 10n: native EIGN/EIGR-Eigenschaftsachsen

Alle 165 im deutschen Promptkatalog veröffentlichten `EIGN…`- und `EIGR…`-Befehle werden vor dem Python-Import geplant. EIGN adressiert `--konzept`, EIGR `--konzept2`; Ganzzahlen, Reziproke, reduzierte Ganzzahlbrüche und die historische zweite `-zeilen`-Sektion werden typisiert erhalten. Die aktuelle Python-Promptschicht scheitert bei EIGR in `deepcopy(module)`; Mojo führt stattdessen den direkt lauffähigen, im Referenzcode explizit gebildeten `reta.py`-Argumentvektor aus. Details: [`STAGE10N_NATIVE_PROMPT_PROPERTIES.md`](STAGE10N_NATIVE_PROMPT_PROPERTIES.md).

### Stage 10j: wiederholte Katalogauswahl und Whitespace-genauer Shellumbruch

Wiederholte `15_…`-/`16_15…`-Katalogauswahlen laufen nun vollständig nativ. Das sichtbare Legacy-Echo behält beide Aliasbündel, während der Generatorregisterpfad sie wie Python semantisch dedupliziert. Die vermeintliche Instanzbreitenlücke war ein Shell-Wrappingfehler: interne Leerzeichenläufe werden jetzt als eigene `textwrap`-Chunks gezählt und nur an Zeilengrenzen verworfen. Dadurch ist auch die lange Primzahlkreuz-Spalte mit `|  Darin …` bytegleich. Details: [`STAGE10J_NATIVE_DUPLICATE_CATALOG.md`](STAGE10J_NATIVE_DUPLICATE_CATALOG.md).

### Stage 10k: mehrbereichige Abstandsberechnung

`abstand` und `abstandPrim` besitzen nun keine Zweibereichsgrenze mehr. Beliebig viele stabile Zahlenbereiche werden vollständig in Mojo verarbeitet, einschließlich doppelter Bereiche, gemischter Kardinalitäten, äußerer Set-Resizes und der größenabhängigen CPython-`set.difference`-Strategien. Die konkrete `set[frozenset[int]]`-Slotordnung sowie die historischen Wörterbuchüberschreibungen sind reproduziert; normale und primfaktorisierte Mehrbereichsausgaben laufen vor jedem Python-Import. Details: [`STAGE10K_NATIVE_MULTI_DISTANCE.md`](STAGE10K_NATIVE_MULTI_DISTANCE.md).

Die explizite Spaltenfolge wird bei semantischen Spaltenauswahlen nach der Generatorpipeline als relative Ergebnisposition angewandt. Dadurch entspricht `--Bedeutung=gestirn --spaltenreihenfolgeundnurdiese=3-6` wieder der Python-Referenz. Auch die historische Unterdrückung der zusätzlichen Universumsspalte bei `e`, `ee`, fehlenden Überschriften oder mehr als zwei kombinierten Fachbefehlen ist modelliert.

## Weitere native Bereiche

- Zahlentheorie, Primzahlkreuz und Arithmetik
- Zeilenbereichssprache
- Parameterschema, Aliase und Spalten-Buckets
- Promptcontroller: `rp`, `rpl`, `rpb`, `rpe`, `retaPrompt`
- `prim`, `prim24`, `multis`, `multis3`, `modulo`
- Tabellen-Tag-Schema
- Tabellenzustand und Unicode-Wrapping
- Topologie, Prägarbenanteile, Morphismen und universelle Bucket-Normalisierung
- Grundstrukturen-HTML
- `generate_html`-Orchestrierung
- generierter Kategorien-/Funktorenkatalog

## Öffentliche Programme

```bash
./reta
./reta-native
./retaPrompt
./rp
./rpb prim 60
./multis3 36
./grundStrukHtml.py blank
./generate_html > religionen-tabelle.html
```

Siehe [`BINARIES.md`](BINARIES.md).

## Tests

```bash
./scripts/test_stage7.sh
./scripts/test_stage8.sh
./scripts/test_stage9.sh
./scripts/test_stage10.sh
./scripts/test_stage11c.sh
./scripts/test_stage11d.sh
./scripts/check_architecture_control_generation.sh
./scripts/check_architecture_coherence_trace_parity.sh
./scripts/check_generated_column_parity.sh
./scripts/check_kombi_parity.sh
./scripts/check_markup_parity.sh
./scripts/check_native_table_parity.sh
./scripts/check_runtime_alias_catalog.sh
./scripts/check_schema_catalog.sh
./scripts/check_category_catalog.sh
```

Gesamtbestand:

```text
64 native Testdateien und Probes
274 native Testfunktionen
186/186 aktuell fokussiert dokumentierte Mojo-Tests bestanden
30 Generator- und 9 Kombi-CLI-Fälle in den Paritätssuiten
8 schnelle Markup-Fixtures; 16 Fälle einzeln gegen Python validiert
27 Kurzsprachen-, 23 Vorbereitung- und 12 Completion-Kontexte bytegleich
18 Bruchparserfälle bytegleich; 14 reale Bruch-/Modifikator-Tokenströme identisch
10 vollständige kompakte, 12 numerische und 8 mehrbereichige Abstandsausgaben bytegleich; 14 allgemeine plus 16 numerische plus 2 Abstands-One-shot-Klassen isoliert
2 schwere Katalogtestdateien bleiben im normalen Lauf optional
```

Weitere bestehende Prüfungen:

```bash
./scripts/check_multis3_parity.sh
./scripts/check_tag_schema.sh
./scripts/check_table_runtime_parity.sh
./scripts/test_prompt_bins.sh
./scripts/check_compat_parity.sh
./scripts/check_html_parity.sh
```

Details: [`TEST_RESULTS.md`](TEST_RESULTS.md).

## Nächster Portierungsblock

Stufe 9 wird mit seltenen Terminal-/Rich-Sonderfällen fortgesetzt. Stufe 10 erweitert die bereits native Promptausführung und i18n-Laufzeit. In Stufe 11 sind Karte, Boundary-Graph, Verträge, Witnesses, Kohärenzmatrix, Trace-Navigation, Impact-Kalkül und Migrationsplan nativ; als Nächstes folgen Rehearsal, Aktivierung und ausführbare Gesamtvalidierung.

## Dokumentation

- [`ROADMAP.md`](ROADMAP.md) – zwölf Stufen und Prozentmetriken
- [`STATUS.md`](STATUS.md) – aktueller Stand
- [`BUILD.md`](BUILD.md) – Compilerprodukte und `.gitignore`
- [`BINARIES.md`](BINARIES.md) – öffentliche Namen und Ziele
- [`TEST_RESULTS.md`](TEST_RESULTS.md) – Testnachweise
- [`PORTING_MATRIX.md`](PORTING_MATRIX.md) – Status jeder Python-Datei
- [`MIGRATION_NOTES.md`](MIGRATION_NOTES.md) – semantische Entscheidungen


## Stage 11a: Architekturkarte und Kapselgrenzen

Die bisher ausschließlich pythonische Metaarchitektur besitzt nun zwei separate schwere Mojo-Bundles:

- `architecture_map.mojo`: 11 Kapseln, 34 Einschließungen, 53 Flüsse, 34 Legacy-Zuordnungen und 42 Stufenschritte
- `architecture_boundaries.mojo`: 161 Modulbesitzer, 279 interne Importkanten, 37 Cross-Capsule-Kanten, 11 Kapselgrenzen und fünf bestandene Checks

Die AST-Auswertung der Python-Referenz ist ein expliziter Regenerationsschritt. Das eingecheckte Ergebnis, seine Navigation und die Validierungsabfragen laufen nativ:

```bash
./scripts/build-heavy.sh
./bin/reta-mojo-boundaries --summary
./bin/reta-mojo-boundaries --module reta.py
./bin/reta-mojo-boundaries --capsule InputPromptCapsule
```

Reproduzierbarkeit:

```bash
./scripts/check_architecture_control_generation.sh
```


## Stage 11b: Architekturverträge und Witness-Matrix

Die beiden auf Stage 11a folgenden Metaebenen sind als getrennte, reproduzierbar generierte Mojo-Bundles verfügbar:

- `architecture_contracts.mojo`: 33 kommutierende Diagramme, 11 Kapselverträge und 22 Refactor-Gesetze
- `architecture_witnesses.mojo`: 536 Anker, 11 Kapselschnitte, 33 Diagrammnachweise, 42 Natürlichkeitsnachweise und 55 Verpflichtungen

Alle 351 dateiartigen Witness-Anker werden gegen den unveränderten Referenzbaum aufgelöst. Beide Validierungen besitzen den Status `passed`.

```bash
./scripts/build-heavy.sh
./bin/reta-mojo-contracts --summary
./bin/reta-mojo-contracts --diagram RawCommandNaturalitySquare
./bin/reta-mojo-witnesses --summary
./bin/reta-mojo-witnesses --anchor RetaArchitectureRoot reta_architecture/facade.py
```

Die Generatorprüfung umfasst Karte, Boundaries, Verträge und Witnesses. Details: [`STAGE11B_NATIVE_ARCHITECTURE_CONTRACTS_WITNESSES.md`](STAGE11B_NATIVE_ARCHITECTURE_CONTRACTS_WITNESSES.md).


## Stage 11c: Kohärenzmatrix und Trace-Navigation

Die nächsten Metaebenen sind ebenfalls als getrennte Mojo-Bundles verfügbar:

- `architecture_coherence.mojo`: 11 Kapselkohärenzen, 53 Routen, 42 Natürlichkeits- und 22 Gesetzeskohärenzen
- `architecture_traces.mojo`: 34 Komponenten-, 11 Kapsel- und 42 Stufentraces mit 204 Route-Hops

```bash
./scripts/build-heavy.sh
./bin/reta-mojo-coherence --summary
./bin/reta-mojo-coherence --route SchemaTopologyCapsule LocalSectionCapsule
./bin/reta-mojo-traces --summary
./bin/reta-mojo-traces --component reta.py
./scripts/test_stage11c.sh
```

Die sechs Architekturkontrollgeneratoren regenerieren byteidentisch; acht repräsentative Python↔Mojo-Abfragen sind vollständig bytegleich. Details: [`STAGE11C_NATIVE_ARCHITECTURE_COHERENCE_TRACES.md`](STAGE11C_NATIVE_ARCHITECTURE_COHERENCE_TRACES.md).


## Stage 11d: Impact-Kalkül und Migrationsplan

Die nächsten beiden Architektursteuerungsschichten sind als getrennte, reproduzierbar generierte Mojo-Bundles verfügbar:

- `architecture_impact.mojo`: 34 Impact-Quellen, 34 Verträge, 10 Regression-Gates und 34 Migrationskandidaten
- `architecture_migration.mojo`: 7 geordnete Wellen, 34 Schritte, 34 Gate-Bindungen und 7 Natürlichkeitsinvarianten

```bash
./scripts/build-heavy.sh
./bin/reta-mojo-impact --summary
./bin/reta-mojo-impact --source reta.py
./bin/reta-mojo-migration --summary
./bin/reta-mojo-migration --wave M3
./scripts/test_stage11d.sh
```

Beide Validierungen besitzen den Status `passed`. Acht repräsentative Python↔Mojo-Abfragen sind byteidentisch, und die Architekturkontrollregeneration umfasst nun acht byteidentische Generatorziele. Details: [`STAGE11D_NATIVE_ARCHITECTURE_IMPACT_MIGRATION.md`](STAGE11D_NATIVE_ARCHITECTURE_IMPACT_MIGRATION.md).
