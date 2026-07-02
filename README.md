# reta.arch → Mojo

Dies ist ein inkrementeller, getesteter Port des hochgeladenen Python-Projekts `reta.arch` auf Mojo 1.0.0b2. Das Original umfasst 92 Python-Dateien und 48.831 Zeilen. Wegen der stark dynamischen Architektur werden zusammenhängende Laufzeitpfade typisiert übertragen; die Python-Referenz bleibt sichtbar, bis der jeweilige Pfad vollständig ersetzt ist.

## Fortschritt

```text
abgeschlossene Release-Stufen:       9 von 12 = 75,0 %
Stufen 9/10/12:                       Ausgabe, Prompt/i18n und Releaseparität in Arbeit
Stufe 11:                             11a–11j = 100 %
Stufe 12:                             12a–12b fertig, 12c zu ca. 99,9 % = ca. 70,8 %
vollständig nativ/generiert:          57 von 92 = 62,0 %
mindestens teilweise portiert:       78 von 92 = 84,8 %
angegriffene Referenzzeilen:          35.903 von 48.831 = 73,5 %
funktionaler Nutzerumfang:            ca. 96–98 %
```

Die Metriken messen **orthogonale Bezugsgrößen** und sind nicht als ein einziges wechselndes Gesamtprozent zu lesen:

- **96–98 % geschätzte Funktionsabdeckung**: Anteil der praktisch relevanten Befehls- und Verhaltensfamilien mit einem nativen Pfad. Der atomare Fallback ist nur eine Sicherheitsgrenze und wird nicht als transpiliert gezählt.
- **62,0 % vollständiger Dateibesitz**: Nur Dateien, deren gesamter wirksamer Vertrag nativ oder reproduzierbar generiert ersetzt ist.
- **73,5 % angegriffene Referenzzeilen**: maschinenberechneter Umfang vollständig und teilweise besessener Referenzdateien.
- **82,9 % Stufenfortschritt**: gewichtete Releaseplanung; eine Stufe kann weit fortgeschritten sein, obwohl große historische Python-Besitzer noch sichtbar bleiben.

Der Port ist daher nicht von über 90 % auf rund 62 % zurückgefallen. Die frühere Zahl bezeichnete die Funktionsoberfläche, die strengere Zahl den Quellersatz. Der vollständige Plan steht in [`ROADMAP.md`](ROADMAP.md).

## Installation mit Python 3.14

```bash
RETA_MOJO_PYTHON="$(command -v python3.14)" ./scripts/setup_mojo.sh
```

Das Skript erzeugt `.venv`, installiert den Modular-Mojo-Compiler und baut die regulären ELF-Programme nach `target/bin/`. Eine Aktivierung mit `source` ist nicht nötig.

```bash
./scripts/check_build_layout.sh
```

`bin/` enthält nur versionierte Shell-Launcher. `.venv/`, `target/`, `build/` und Laufzeitartefakte stehen in `.gitignore`. Die sehr großen generierten Schema- und Architekturkataloge werden optional gebaut:

```bash
./scripts/build-heavy.sh
```

Details: [`BUILD.md`](BUILD.md).

### Python-/PyPy3-Referenz

Die `.venv` ist für den Mojo-Compiler bestimmt. Referenz- und Paritätsskripte
wählen über `scripts/select_reference_python.sh` zuerst explizite Vorgaben,
danach `pypy3`, dann `python3`; `.venv/bin/python` ist nur der letzte
Notfallfallback. Für den historischen Volltabellenlauf gilt daher:

```bash
PYTHONHASHSEED=0 pypy3 reta -spalten --alles --breite=0 \
  -ausgabe --art=html --onetable --nocolor > middle.alx
```

`.venv/`, `.git/`, `target/` und Caches gehören nicht in Quellarchive. Brotli-
Archive (`.tar.br`) werden unterstützt.

Nach jedem Build entfernt `tools/sanitize_mojo_runpath.py` den von Mojo selbst ergänzten absoluten Compilerpfad aus dem ELF-RUNPATH. Ausgelieferte Programme enthalten damit nur `$ORIGIN/../lib/mojo` und bleiben zwischen Rechnern übertragbar.

### Installation der CSV- und Assetdaten

Für eine manuelle Installation ist `/usr/local` der Standard:

```bash
./scripts/build-heavy.sh
./scripts/build.sh
sudo ./scripts/install.sh
```

Die CSV-Dateien liegen dann unter `/usr/local/share/reta/csv`. Ein
Distributionspaket verwendet `DESTDIR="$pkgdir" PREFIX=/usr` und installiert
sie unter `/usr/share/reta/csv`. Eine Installation ohne Root verwendet
`PREFIX="$HOME/.local"` und damit `$HOME/.local/share/reta/csv`. Private
Mojo-Programme und der verbleibende Python-Kompatibilitätsbaum liegen
standardmäßig getrennt unter `lib/reta`; Fedora-/RPM-Pakete können
`LIBEXECDIR=/usr/libexec/reta` setzen. Relative Symlinks erhalten die
historische Projektstruktur ohne Datenkopie. Seit Stage 12c5h kopiert der
Installer ausschließlich die 32 in `scripts/install_targets.txt` deklarierten
regulären und schweren Compilerziele; lokale Debug-/Altdateien unter
`target/bin` werden nicht mehr versehentlich installiert. Details:
[`STAGE12C4M_FHS_RESOURCE_INSTALLATION.md`](STAGE12C4M_FHS_RESOURCE_INSTALLATION.md).

## Stufen 7–10: Generatoren, Kombinationen, Markup und Prompt

Stage 12c5j behebt den beim lokalen Gesamtbuild entdeckten expliziten Ownership-Transfer im Exportfilter und portiert den statischen Vertrag von `reta_architecture/facade.py` als reproduzierbaren nativen Kompositionsgraphen: 45 Felder, 49 Methoden, 45 Bootstrap-Schritte, 44 Rebuild-Einstiege, 98 Abhängigkeitskanten und 48 Snapshot-Einträge. `reta-mojo-facade` macht den Graphen ohne Python-Import abfragbar; Details: [`STAGE12C5J_NATIVE_ARCHITECTURE_FACADE.md`](STAGE12C5J_NATIVE_ARCHITECTURE_FACADE.md).

Stage 12c5i schließt die 419-zeilige Architektur-Fassade `reta_architecture/table_adapters.py`: vier Modulhelfer, 17 logische `Prepare`-Methoden, 34 `Concat`-Methoden und beide Konstruktorzustände sind typisiert und leiten ausschließlich auf bereits native Besitzer. Details: [`STAGE12C5I_NATIVE_TABLE_ADAPTERS.md`](STAGE12C5I_NATIVE_TABLE_ADAPTERS.md).

Stage 12c5h portiert die reine 598-zeilige `reta_architecture/__init__.py`-
Reexportfassade als typisierten Katalog mit 314 Importbindungen, 232 geordneten
`__all__`-Exporten und 46 Besitzermodulen. `reta-mojo-exports` fragt diese
Oberfläche ohne Python-Import ab. Zugleich trennt der `middle.alx`-Vergleich
Container- von Nutzlastdigests und der Installer verwendet eine feste
31-Ziel-Allowlist; Details: [`STAGE12C5H_NATIVE_PACKAGE_EXPORTS_INSTALL_MANIFEST.md`](STAGE12C5H_NATIVE_PACKAGE_EXPORTS_INSTALL_MANIFEST.md).

Stage 12c5d schließt die beiden historischen Kompatibilitätsfassaden `libs/center.py` und `libs/lib4tables.py`. 27 aktive Center-Wrapper, die vollständige 18-Namen-Tabellenhilfeoberfläche, vier reproduzierbare Hilfetexte und der Python-`str.isdigit()`-Vertrag mit 808 Codepoints sind nun typisiert nativ; Details: [`STAGE12C5D_NATIVE_LEGACY_FACADES.md`](STAGE12C5D_NATIVE_LEGACY_FACADES.md). Stage 12c5c portiert den vollständigen Quellbaum-Integritätsvertrag mit binärem SHA-256, Pflichtpfaden, Laufzeitartefakten, CSV-Zeilenzählung und einer installierbaren Diagnose-CLI. Zugleich ersetzt eine typisierte Split-i18n-Fassade den dynamischen `SimpleNamespace`-Merge; Details: [`STAGE12C5C_NATIVE_PACKAGE_INTEGRITY_SPLIT_I18N.md`](STAGE12C5C_NATIVE_PACKAGE_INTEGRITY_SPLIT_I18N.md). Stage 12c5a aktiviert einen eigenen nativen Besitzer für die produktive Prompt-Interaktionsschleife, Speicher-/Löschmodi, One-shots und Previous-Command-Policy; Details: [`STAGE12C5A_NATIVE_PROMPT_INTERACTION.md`](STAGE12C5A_NATIVE_PROMPT_INTERACTION.md). Stage 12c4z macht `generate_html` zu einem FHS-fähigen Unix-Kommando mit atomarer Dateiausgabe, expliziter Mitteltabelle, Manpage und wiederverwendbarer vollständiger Python-Referenz; Details: [`STAGE12C4Z_PROFESSIONAL_GENERATE_HTML.md`](STAGE12C4Z_PROFESSIONAL_GENERATE_HTML.md). Stage 12c4y gibt der produktiven Spalten-, Zeilen-, Breiten-, Ausgabe- und Obergrenzenplanung einen eigenständigen typisierten Besitzer und ergänzt wiederverwendbare vollständige `--alles`-Referenzpakete; Details: [`STAGE12C4Y_NATIVE_PARAMETER_RUNTIME.md`](STAGE12C4Y_NATIVE_PARAMETER_RUNTIME.md). Stage 12c4x übernimmt den vollständigen fünfsprachigen `i18n.words`-Split als nativen Baumkatalog; Details: [`STAGE12C4X_NATIVE_I18N_WORDS.md`](STAGE12C4X_NATIVE_I18N_WORDS.md). Stage 12c4w ergänzt die native Prompt-Vorbereitung und das vollständige semantische `--alles`-Gate; Details: [`STAGE12C4W_NATIVE_PROMPT_PREPARATION_FULL_ALL.md`](STAGE12C4W_NATIVE_PROMPT_PREPARATION_FULL_ALL.md). Stage 12c4v besitzt Prompt-Sitzung und Prompt-Runtime vollständig nativ beziehungsweise reproduzierbar generiert; Details: [`STAGE12C4V_NATIVE_PROMPT_SESSION_RUNTIME.md`](STAGE12C4V_NATIVE_PROMPT_SESSION_RUNTIME.md).

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

`./reta` ist seit Stage 12c4e **native-first**: Ein strenger Ownership-Test führt nur vollständig unterstützte Argumentvektoren direkt im Mojo-Tabellenkern aus. Sobald eine Option oder ein Wert nicht vollständig besessen wird, fällt der gesamte Aufruf unverändert auf die Python-Referenz zurück. `RETA_FORCE_REFERENCE=1 ./reta ...` erzwingt diese Referenz; `RETA_NATIVE=1 ./reta ...` erzwingt weiterhin den nativen Pfad ohne Fallback.

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

Die vordere Promptverarbeitung läuft nun in Mojo: klammerbewusstes Tokenisieren, kompakte Kurzbefehle, Ein-Zeichen-Ersetzungen, CPython-kompatible Mengenordnung und kontextabhängige Completion. Ein reproduzierbarer Katalog bündelt 25.834 Completion-Werte in 561 Sektionen und enthält fünf Sprachen sowie 1.355 Vokabularaliase.

Seit Stage 12c4d liest auch ein reales Terminal vollständig nativ: Ein reiner Mojo-Editor besitzt UTF-8-Cursorlogik, History und verschachtelte Completion; ein kleiner POSIX-Adapter kapselt `termios`, ANSI-Tastenfolgen und Linux-/macOS-`FIONREAD`. Übliche Emacs- und Vi-Kernbindings sind vorhanden. Der frühere GNU-Readline-/CPython-Eingang und der zusätzliche Completion-Kindprozess sind für den Controller nicht mehr erforderlich. Noch nicht portierte Fachoperationen erhalten am expliziten Kindprozessfallback weiterhin unverändert die ursprüngliche Eingabezeile.

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

Stage 10l ersetzt die zentrale `pathlib`-Dateibrücke durch natives Mojo-I/O, gibt dem persistenten Completion-Arbeiter direkte stdin/stdout-Dateideskriptoren und portiert die äußere `generate_html`-Orchestrierung. Stage 12b ergänzt den reproduzierbaren zwölfteiligen `--spalten --alles`-Plan; Normal- und Overridepfad laufen nun vollständig ohne Python-Kindprozess. Positive Shell-, HTML- und BBCode-Breiten laufen nun auch aus dem Prompt vor jedem Python-Import. Details: [`STAGE10L_NATIVE_IO_ORCHESTRATION.md`](STAGE10L_NATIVE_IO_ORCHESTRATION.md).

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
./generate_html --output religionen-tabelle.html --language english
./generate_html --middle-file middle.alx --output religionen-tabelle.html
man generate_html
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
./scripts/test_stage11e.sh
MOJO_BIN="$(pwd)/.venv/bin/mojo" ./scripts/test_stage12c5c.sh
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
172 Test-/Probe-Dateien (127 Mojo, 45 Python)
465 native Mojo-Testfunktionen plus 182 Python-Testfunktionen
Stage 12a aktuell 480/480 fokussierte Mojo-/Paritätsprüfungen plus 1/1 Boundary-Pytest
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

Stufe 9 wird mit seltenen Terminal-/Rich-Sonderfällen fortgesetzt. Stufe 10 erweitert die bereits native Promptausführung und i18n-Laufzeit. Stufe 11 ist mit 11a–11j abgeschlossen. Stage 12a und 12b sind abgeschlossen: Sämtliche nativen Parallelpfade verwenden Mojo-Threads, und `generate_html` besitzt nun auch die vollständige `--alles`-Mitteltabelle. Stage 12c ist bis 12c4i fortgesetzt: `rpb a1` trennt Befehlszeile und Tabellenkopf wieder exakt, `--breite=0` verwendet die reale TTY-Breite, und Pipe-, Skript- sowie echte TTY-Eingabe laufen nativ in Mojo. Die Rohbefehle `shell`, `python` und `math`, nicht-native `reta`-Zeilen und atomare Restfallbacks starten direkt am expliziten Mojo-Kindprozessadapter. Stabile Kombinationen aus `vielfache`, `teiler` und `1/n`, klassische Bruch-No-ops und gemischte Tokens wie `mond 1/2,3` werden nativ geplant. Weder Prompt noch historischer Tabellenlauncher betten Python ein; vollständig besessene `./reta`-Argumentvektoren laufen automatisch nativ, während Restsemantik atomar als Referenzkindprozess ausgeführt wird. Offen bleiben echte `v n/m` mit Zähler größer eins, weitere Restalgorithmen sowie 12d–12e.

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
./scripts/test_stage11e.sh
MOJO_BIN="$(pwd)/.venv/bin/mojo" ./scripts/test_stage12c5c.sh
```

Beide Validierungen besitzen den Status `passed`. Acht repräsentative Python↔Mojo-Abfragen sind byteidentisch, und die Architekturkontrollregeneration umfasst nun acht byteidentische Generatorziele. Details: [`STAGE11D_NATIVE_ARCHITECTURE_IMPACT_MIGRATION.md`](STAGE11D_NATIVE_ARCHITECTURE_IMPACT_MIGRATION.md).


## Stage 11e: Rehearsal und Aktivierung

Die Stage-35-/36-Metadaten sind als getrennte, reproduzierbare Mojo-Bundles verfügbar:

- `architecture_rehearsal.mojo`: 7 Öffnungen, 34 Moves, 34 Gate-Suiten und 7 Readiness-Cover
- `architecture_activation.mojo`: 7 Fenster, 34 Units, 34 Commit-Gates, 34 Rollbacks und 7 Transaktionen

```bash
./scripts/build-heavy.sh
./bin/reta-mojo-rehearsal --summary
./bin/reta-mojo-rehearsal --move REH35-MOVE-MIG34-01
./bin/reta-mojo-activation --summary
./bin/reta-mojo-activation --transaction ACT36-TX-M0
./scripts/test_stage11e.sh
MOJO_BIN="$(pwd)/.venv/bin/mojo" ./scripts/test_stage12c5c.sh
```

Beide gespeicherten Referenzvalidierungen und beide nativen Kreuzvalidierungen bestehen. Elf repräsentative Python↔Mojo-Abfragen sind byteidentisch; die Architekturkontrollregeneration umfasst zehn Ziele. Details: [`STAGE11E_NATIVE_ARCHITECTURE_REHEARSAL_ACTIVATION.md`](STAGE11E_NATIVE_ARCHITECTURE_REHEARSAL_ACTIVATION.md).


## Stage 11f: Gesamtvalidierung und Fortschritts-Overlay

Die beiden abschließenden reinen Architektursteuerungsschichten sind als getrennte, reproduzierbare Mojo-Bundles verfügbar:

- `architecture_validation.mojo`: 51 Checks in 17 Schichten, 51 bestanden, 3.448 geprüfte Einzelobjekte
- `architecture_progress.mojo`: 30 Oberflächen, 34 Schritte, 7 Wellen, ein dokumentierter Umweltblock

```bash
./scripts/build-heavy.sh
./bin/reta-mojo-validation --summary
./bin/reta-mojo-validation --check CategoryFunctorReferenceCheck
./bin/reta-mojo-progress --summary
./bin/reta-mojo-progress --surface reta.py
./scripts/test_stage11f.sh
```

Die Gesamtvalidierung steht auf `passed`. Das Fortschritts-Overlay ist intern vollständig konsistent und bewusst `attention`, weil genau die externe ursprüngliche Command-Parity-Baseline fehlt. Acht repräsentative Python↔Mojo-Abfragen sind byteidentisch; die Architekturkontrollregeneration umfasst zwölf Ziele. Details: [`STAGE11F_NATIVE_ARCHITECTURE_VALIDATION_PROGRESS.md`](STAGE11F_NATIVE_ARCHITECTURE_VALIDATION_PROGRESS.md).


## Stage 11g: Native SQLite-Persistenz

`persistence.py` ist nun als reale native SQLite-Laufzeitschicht portiert. Das Modul besitzt sechs Tabellen und zwölf Persistenzmorphismen für Kontexte, Sections, Garben-Snapshots, Ausführungsläufe, Audit und Cache. Stabile SHA-256-Digests stimmen mit der Python-Referenz überein; beide Implementierungen lesen die jeweils andere Datenbank.

```bash
./scripts/test_stage11g.sh
./bin/reta-mojo-persistence --summary
./bin/reta-mojo-persistence --demo /tmp/reta-persistence.db
./bin/reta-mojo-persistence --inspect /tmp/reta-persistence.db
```

Der fokussierte Lauf besteht aus 47/47 nativen Prüfungen und 5/5 Python↔Mojo-Paritäts-/Interoperabilitätsprüfungen. Details: [`STAGE11G_NATIVE_PERSISTENCE.md`](STAGE11G_NATIVE_PERSISTENCE.md).


## Stage 11h: Natives deterministisches Ausführungsnetz

`execution_network.py` ist als reale Mojo-Laufzeitschicht portiert. FIFO-, LIFO- und Prioritätswarteschlangen, Halb-/Vollduplexkanäle, Semaphoren, Snapshotbildung und deterministische Reduktion laufen ohne Python. Seit Stage 12a führen Mojos CPU-Workerthreads die statisch bekannten Operationen aus; Eingaben werden gemeinsam gelesen, jeder Worker schreibt in einen disjunkten Ergebnisslot und die Reduktion bleibt deterministisch.

```bash
./scripts/test_stage11h.sh
./bin/reta-mojo-execution-network --summary
./bin/reta-mojo-execution-network --order priority
./bin/reta-mojo-execution-network --run-threads fifo
./bin/reta-mojo-execution-network --task double_int 21
```

Die statische Mojo-Grenze verwendet UTF-8-Text, kanonisches Metadaten-JSON und geprüfte Operationskennungen anstelle von Python-`Any`, Pickle und dynamischen Imports. Der fokussierte Lauf besteht aus 85/85 nativen Netzprüfungen, 15/15 Persistenzintegrationsprüfungen und 8/8 Python↔Mojo-Paritätsfällen. Details: [`STAGE11H_NATIVE_EXECUTION_NETWORK.md`](STAGE11H_NATIVE_EXECUTION_NETWORK.md).


## Stage 11i/12a: Native Thread-Chunk-Kerne

Der reine Kern von `parallel_execution.py` läuft in Mojo. Zehn Tabellen- und Zahlenoperationen besitzen serielle Referenzpfade und typisierte Thread-Chunks. Stage 12a hat die historischen `fork`-Worker und das längenpräfixierte Prozessprotokoll vollständig entfernt. Ergebnisse werden unabhängig von der Schedulerreihenfolge wieder in die von Python definierte Zeilen-/Zahlenindexordnung zusammengesetzt; Filterwerte werden wie die Referenz dedupliziert.

```bash
./scripts/test_stage11i.sh
./bin/reta-mojo-parallel-execution --summary
./bin/reta-mojo-parallel-execution --demo 2 2
./bin/reta-mojo-parallel-execution --prime-factors 12 18 25 49
```

Die historische Stage-11i-Prüfung bleibt dokumentiert. Der aktuelle Stage-12a-Lauf prüft die Threadmigration mit 480/480 Mojo-/Paritätsfällen plus 1/1 Boundary-Pytest. Alte Namen und Konfigurationswerte mit `process` bleiben vorläufig als Kompatibilitätsalias erhalten, erzeugen aber keinen Prozess. Details: [`STAGE12A_NATIVE_THREAD_MIGRATION.md`](STAGE12A_NATIVE_THREAD_MIGRATION.md).


## Stage 11j: Typisierte Thread-Zeilenvorbereitung

Der letzte dynamische `WorkerPrepare`-/`deepcopy`-Objektgraph ist durch `ParallelRowPreparationContext` ersetzt. Reine In-Memory-Kerne verwenden native Mojo-Threads. Jeder Thread schreibt ausschließlich in seinen vorab zugewiesenen Chunkslot, danach wird seriell nach der ursprünglichen Zeilennummer reduziert. SQLite-Schreibvorgänge, globale Header-Tag-Mutationen und Ausgabe-I/O bleiben bewusst seriell.

```bash
./scripts/test_stage11j.sh
./bin/reta-mojo-row-preparation --summary 8 128 512
./bin/reta-mojo-row-preparation --demo 2 2
./bin/reta-mojo-parallel-execution --demo-threads 2 2
```

Die hier ausgeführten fokussierten Prüfungen umfassen 36/36 Konfigurationsfälle, 40/40 typisierte Zeilenvorbereitungsfälle und 2/2 Python↔seriell↔Thread-Vollstromparitätsfälle. Ein vorläufiger Lauf mit 20.000 Zeilen benötigte in dieser Umgebung 4,12 s seriell und 3,22 s mit acht Thread-Workern bei identischer Prüfsumme. Details: [`STAGE11J_NATIVE_THREADED_ROW_PREPARATION.md`](STAGE11J_NATIVE_THREADED_ROW_PREPARATION.md).

## Stage 12b: Native `--alles`-Mitteltabelle und `generate_html`

Der synthetische Spaltenparameter `--alles` wird als reproduzierbarer zwölfteiliger Plan aus der Python-Referenz eingefroren und zur Laufzeit typisiert in Mojo geladen. Der Plan umfasst 756 Quellwerte und führt für das Ein-Zeilen-HTML-Referenzfixture zu 805 Daten-/Generatorspalten. `generate-html-native` ruft `run_native_reta` direkt auf; `std.subprocess` und der Python-Kindprozess sind entfernt.

```bash
./scripts/check_all_columns_plan.sh
./scripts/test_stage12b.sh
./scripts/build.sh
./scripts/check_html_parity.sh
```

Nach Stage 12b verbleiben nur noch die allgemeine Kompatibilitätsbrücke in `compat_main.mojo` und der interaktive Prompt-Callback in `prompt_main.mojo`. Details: [`STAGE12B_NATIVE_ALL_COLUMNS_HTML.md`](STAGE12B_NATIVE_ALL_COLUMNS_HTML.md).

## Stage 12c1: Native Terminalgeometrie und exakte Prompt-Zeilengrenzen

Der öffentliche Aufruf bleibt unverändert:

```bash
bin/rpb a1
```

Der native Promptcontroller beendet die sichtbare `reta`-Befehlszeile nun wie die Python-Referenz vor dem Tabellenkopf. `--breite=0` liest die aktuelle Terminalbreite per `ioctl(TIOCGWINSZ)` und reserviert anschließend die historischen sieben Spalten; die früher fest verdrahteten 80/73 Spalten sind entfernt. PTY-Proben prüfen 80, 120 und 200 Spalten. Details: [`STAGE12C1_NATIVE_TERMINAL_PROMPT_PARITY.md`](STAGE12C1_NATIVE_TERMINAL_PROMPT_PARITY.md).


## Stage 12c2: Portabler nativer Prompt-Eingabekanal

`ioctl(TIOCGWINSZ)` ist eine kleine OS-ABI-Grenze, nicht Python: Linux/WSL
verwenden `0x5413`, macOS/Darwin `0x40087468`; sonst greifen `COLUMNS` und
der historische 80-Spalten-Fallback. Für stdin-Pipes und umgeleitete Sessions
liest `prompt_main.mojo` nun direkt mit Mojos eingebautem `input()` und
persistiert History best effort. Python wird erst beim tatsächlichen
TTY-Readline-/Vi-/Completion-Eingang importiert. Die öffentlichen
Promptbefehle ändern sich nicht. Details:
[`STAGE12C2_NATIVE_PORTABLE_PROMPT_INPUT.md`](STAGE12C2_NATIVE_PORTABLE_PROMPT_INPUT.md).


## Stage 12c3: Native rohe Promptbefehle

Die expliziten Promptbefehle `shell`, `python` und `math` überschreiten nicht
mehr `mojo_bridge.py`. Ein enger Mojo-Systemadapter reproduziert die
`shlex.split`-/Kindprozesssemantik, vererbt stdin/stdout/stderr und die
Umgebung bytegetreu und verwendet einen eng gekapselten libc-`system()`-Aufruf statt dynamischer `dlsym`-/`environ`-Auflösung. Rohe Unicode-Nutzlasten werden vor dem Kompaktscanner
erkannt, sodass beispielsweise `python print("ä λ")` unverändert ausgeführt
wird. Details: [`STAGE12C3_NATIVE_RAW_PROMPT_COMMANDS.md`](STAGE12C3_NATIVE_RAW_PROMPT_COMMANDS.md).

Stage 12c4a kapselt die verbliebene Python-Grenze in
`prompt_python_bridge.mojo` und behebt die erst im Gesamtbuild sichtbare
`dlsym`-Signaturkollision. Details:
[`STAGE12C4A_PROMPT_BRIDGE_INTEGRATION.md`](STAGE12C4A_PROMPT_BRIDGE_INTEGRATION.md).

Stage 12c4b entfernt daraus die beiden reinen Spawn-Operationen: nicht-native
`reta`-Zeilen und atomare Promptfallbacks laufen nun direkt über den typisierten
Mojo-Kindprozessadapter. Details:
[`STAGE12C4B_NATIVE_PROMPT_FALLBACK_CHILDREN.md`](STAGE12C4B_NATIVE_PROMPT_FALLBACK_CHILDREN.md).

Stage 12c4c übernimmt die stabile Kombination `vielfache + teiler + 1/n`,
korrigiert die Reziprok-Maximum- und Universum-Spaltenparität und bewahrt den
historischen leeren `teiler 1/n`-Anteil. Details:
[`STAGE12C4C_NATIVE_MIXED_RECIPROCAL_MODIFIERS.md`](STAGE12C4C_NATIVE_MIXED_RECIPROCAL_MODIFIERS.md).

Stage 12c4d ersetzt schließlich auch den echten TTY-Readline-Eingang durch einen
UTF-8-sicheren Mojo-Zeileneditor mit History, verschachtelter Completion,
Emacs-/Vi-Kernbindings und einer gekapselten POSIX-`termios`-Grenze. Außerdem
sind die klassischen Bruch-No-ops und gemischte Bruch-/Ganzzahl-Kommatokens
nativ. Details:
[`STAGE12C4D_NATIVE_TTY_EDITOR.md`](STAGE12C4D_NATIVE_TTY_EDITOR.md).


Stage 12c4e entfernt schließlich auch die letzte eingebettete Python-Laufzeit aus
`compat_main.mojo`. Der historische `./reta`-Name wählt jetzt konservativ
native Ausführung oder einen atomaren Python-Kindprozessfallback; es gibt keine
aktive `std.python`-Brücke mehr. Zwölf physische, generierte, modale, Meta-,
Bruch-, Kombi- und Markupfälle laufen mit absichtlich ungültigem
`RETA_PYTHON` bytegleich zur Referenz. Details:
[`STAGE12C4E_NATIVE_FIRST_COMPAT.md`](STAGE12C4E_NATIVE_FIRST_COMPAT.md).

Stage 12c4f übernimmt anschließend die Shell-Ausgabegruppe `--onetable`,
`--endlessscreen`, `--endless`, `--dontwrap` und `--justtext`. Ein-Tabellen-
Ausgabe, Breite-null-No-wrap und der Unicode-sichere Restzeilenumbruch sind
bytegleich. Details:
[`STAGE12C4F_NATIVE_OUTPUT_STREAM_FLAGS.md`](STAGE12C4F_NATIVE_OUTPUT_STREAM_FLAGS.md).

Stage 12c4g erweitert dieselben vier Ein-Tabellen-Aliase auf HTML und BBCode.
Alle Markup-Spalten bleiben nun in einem einzigen `<table>`-/`[table]`-Block;
Metadaten, Wrapping und Zeilenfarben sind bytegleich. Der historische `reta`-
Launcher besitzt diese Kombinationen ohne Python-Kindprozess. Details:
[`STAGE12C4G_NATIVE_MARKUP_ONETABLE.md`](STAGE12C4G_NATIVE_MARKUP_ONETABLE.md).

Stage 12c4h übernimmt `--keineleereninhalte` und `--noblankcontents` in den
nativen Tabellenplan. Die historische Filterentscheidung wird für Shell, HTML
und BBCode pro Seite und umgebrochener Sichtzeile sowie für CSV, Markdown und
Emacs pro logischer Tabellenzeile ausgeführt. Der native-first Launcher besteht
mit diesem neuen Pfad 10/10 Prüfungen; der No-blank-Fall läuft dabei mit einem
absichtlich ungültigen Python-Pfad. Details:
[`STAGE12C4H_NATIVE_NO_BLANK_CONTENTS.md`](STAGE12C4H_NATIVE_NO_BLANK_CONTENTS.md).

Stage 12c4i schließt die verbliebenen Kernabweichungen horizontal paginierter
Shell-, HTML- und BBCode-Ausgaben. Vorhandene Bindestriche werden wie in der
Python-Referenz vor einem harten Überlangwortschnitt genutzt; fehlende
Shell-Fortsetzungsfragmente erhalten die neutrale Restfarbe. Sechs deutsche und
englische Mehrspaltenströme sind byteidentisch. Details:
[`STAGE12C4I_NATIVE_PAGINATED_RENDERING.md`](STAGE12C4I_NATIVE_PAGINATED_RENDERING.md).


Stage 12c4j übernimmt positive individuelle Spaltenbreiten über `--breiten`
und `--widths` für Shell, HTML und BBCode. Die Breitenliste ist typisiert,
spaltenbezogen, ersetzbar und mit globaler Breite null kombinierbar. Details:
[`STAGE12C4J_NATIVE_COLUMN_WIDTHS.md`](STAGE12C4J_NATIVE_COLUMN_WIDTHS.md).

Stage 12c4k übernimmt zusätzlich explizite Nullwerte innerhalb dieser
Breitenliste. Shell reproduziert dabei auch die historische Seitenabbruchlogik
für überbreite ungebrochene Nullspalten; HTML und BBCode trennen rohe
Leerraummessung von normalisierter Serialisierung. Zwölf neue Referenzströme
sind byteidentisch. Details:
[`STAGE12C4K_NATIVE_ZERO_COLUMN_WIDTHS.md`](STAGE12C4K_NATIVE_ZERO_COLUMN_WIDTHS.md).

Stage 12c4l macht übertragene Mojo-ELF-Dateien unabhängig vom absoluten
Compilerpfad des Buildrechners. Alle Builds erhalten den relativen RUNPATH
`$ORIGIN/../lib/mojo`; `scripts/configure_mojo_runtime.sh` füllt den
projektrelativen Ort `target/lib/mojo`, und `bin/mojo-runtime-exec` kann auch
ältere Binaries über `LD_LIBRARY_PATH` starten. Das betrifft die Modular-
Laufzeitbibliotheken, nicht die CSV-Dateien. Gleichzeitig ist der rohe
HTML-/BBCode-Serializer von `--nocolor` einschließlich signifikanter
Leerraumläufe, Einzel- und Nullbreiten nativ. Details:
[`STAGE12C4L_PORTABLE_RUNTIME_RAW_MARKUP.md`](STAGE12C4L_PORTABLE_RUNTIME_RAW_MARKUP.md).


Stage 12c4m trennt Quellbaum, private Laufzeit und unveränderliche Daten nach
FHS. CSV-Dateien liegen je nach `PREFIX` unter `share/reta/csv`, während
relative Symlinks die historischen Pfade `python_reference/csv` und `assets`
erhalten. `DESTDIR`, `/usr`, `/usr/local`, `$HOME/.local` und Fedora-`libexec`
sind getestet. Details:
[`STAGE12C4M_FHS_RESOURCE_INSTALLATION.md`](STAGE12C4M_FHS_RESOURCE_INSTALLATION.md).

Stage 12c4n korrigiert den vollständigen nativen `--alles`-Plan von 863 auf die
807 Referenzspalten. Unmögliche Bruchkoordinaten werden anhand der realen
CSV-Form verworfen, `PrimCSV` steht wieder an der historischen Position und
die semantischen HTML-Metadaten umfassen 1.626 deutsch/englische Einträge.
Die vollständige Ein-Zeilen-Ausgabe von `generate_html` ist deutsch und
englisch bytegleich. Details:
[`STAGE12C4N_ALL_COLUMNS_HTML_PARITY.md`](STAGE12C4N_ALL_COLUMNS_HTML_PARITY.md).


Stage 12c4o übernimmt individuelle `--breiten`/`--widths` nun auch für CSV,
Markdown und Emacs/Org. Der gemeinsame flache Zeilenexpander reproduziert
Fortsetzungsnummerierung, wiederholte Überschriftentrenner, explizite
Nullbreiten und die seltenen CSV-Leerraumbytes des Python-`textwrap`-/Rich-
Pfads. Dreizehn deutsche und englische Referenzströme sind byteidentisch; zusätzlich sind unnummerierte CSV-Ströme mit den zwei historischen leeren Strukturfeldern (`;;`) abgesichert. Details:
[`STAGE12C4O_NATIVE_FLAT_COLUMN_WIDTHS.md`](STAGE12C4O_NATIVE_FLAT_COLUMN_WIDTHS.md).

Stage 12c4p übernimmt die dokumentierten Python-artigen Ganzzahlausdrücke in
Zeilenbereichen sicher nativ. Ein endlicher Mojo-Parser unterstützt
Ganzzahlarithmetik, Listen/Mengen/Tupel und einvariable Comprehensions über
`range`; beliebiger Python-Code, Gleitkomma- und komplexere
Comprehensionsyntax bleibt atomarer Referenzfallback. Sechs reale Tabellenströme
sind bytegleich. Details:
[`STAGE12C4P_NATIVE_INTEGER_EXPRESSIONS.md`](STAGE12C4P_NATIVE_INTEGER_EXPRESSIONS.md).

Stage 12c4q übernimmt die Start-, Sprach- und Hilfeoberfläche vor der
Tabellenplanung nativ. Leerer Aufruf, reine Sprachwahl und die vollständigen
deutschen/englischen Hilfetexte sind bytegleich, ohne Python-Kindprozess. Der
Ownership-Prüfer weist reine Hauptparameter ohne Nebenoption zurück, sodass
`-language=english` oder `-zeilen` nicht mehr fälschlich die Standardtabelle
ausgeben. Details:
[`STAGE12C4Q_NATIVE_CLI_STARTUP_HELP.md`](STAGE12C4Q_NATIVE_CLI_STARTUP_HELP.md).

## Fehlerkatalog und bewusste Referenzabweichungen

Während der Transpilierung bleibt `python_reference` grundsätzlich als reproduzierbare historische Referenz eingefroren. Bestätigte Fehler des Originals werden nicht vergessen und nicht als scheinbare Parität behandelt. Sie stehen mit Reproduktion, Quellorten, Mojo-Vertrag und späterem Python-Arbeitsauftrag in [`KNOWN_DEFECTS.md`](KNOWN_DEFECTS.md); die maßgebliche Quelle ist `KNOWN_DEFECTS.json`. Die daraus erzeugte [`PYTHON_CLEANUP_BACKLOG.md`](PYTHON_CLEANUP_BACKLOG.md) ist die konkrete Arbeitsliste für die spätere Python-/PyPy3-Bereinigungsphase.

Prüfen beziehungsweise neu erzeugen:

```bash
python3 tools/check_known_defects.py --write
python3 tools/check_known_defects.py
python3 -m pytest -q tests/test_known_defects.py
```

Stage 12c4r nutzt diesen Prozess erstmals für eine absichtliche Korrektur gegenüber dem Original: `rpb 'universum v2/3'` stürzt in Python mit `IndexError` ab, während Mojo ein an der realen Bruch-CSV-Form begrenztes Zähler×Nenner-Raster erzeugt. Details: [`STAGE12C4R_DEFECT_LEDGER_FRACTION_MULTIPLES.md`](STAGE12C4R_DEFECT_LEDGER_FRACTION_MULTIPLES.md).

Stage 12c4s hat den Katalog rückwirkend gegen die bisherigen Migrations- und Testberichte geprüft. Er umfasst nun 35 bekannte Befunde; zwölf davon bilden den späteren Python-/PyPy3-Bereinigungsrückstand. `-debug` und `-nichts`/`-nothing` werden nativ behandelt, ohne `-nichts` mit dem echten stillen Renderer `--art=nichts` zu verwechseln. Details: [`STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`](STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md).

Stage 12c4t portiert die allgemeine Wortvervollständigung aus `reta_architecture/completion_word.py` sowie die historische `word_completerAlx`-Fassade. UTF-8-Bytecursor, Unicode-skalare Startpositionen, `WORD`-/Satzmodus, Middle-Match, besitzender Completer, erneuerbare Wortquellen, Muster-Präfixadapter und dekorierte Anzeige-/Metadaten sind nativ; fünf Unit-Tests und zehn byteidentische Python↔Mojo-Proben bestehen. Der Katalog enthält nun 37 Befunde und 13 spätere Python-/PyPy3-Arbeitspunkte. `PY-CAND-007` dokumentiert die vom Original geerbte ASCII-/Unicode-Trennung innerhalb deutscher Wörter. Details: [`STAGE12C4T_NATIVE_WORD_COMPLETION.md`](STAGE12C4T_NATIVE_WORD_COMPLETION.md).
