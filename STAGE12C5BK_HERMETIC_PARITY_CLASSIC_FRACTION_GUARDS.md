# Stage 12c5bk – hermetische Kommando-Parität und vollständige Bruchachsen-Grenzen

## Ausgangslücke

Die eingefrorene Python-Steuerung führt `mond`, `richtung`, `primzahlkreuz`,
`alles` und `thomas` ausschließlich im Zweig `if bedingungZahl:` aus.
`bedingungZahl` wird nur durch gewöhnliche Ganzzahlsyntax gesetzt. Ganzzahlige
Zeilen, die erst aus einem echten Bruchvielfachen projiziert werden, aktivieren
diesen Zweig nicht.

Der native Planer verwendete dagegen bisher das gemeinsame `has_integer` auch
für diese klassischen Familien. Bei einem Einzelbereich wie

```text
mond universum v2/3
```

konnte dadurch eine falsche Mondtabelle aus den projizierten Zeilen entstehen.
Bei mehreren physischen Bruchdomänen wie

```text
mond universum motive v2/3
```

fiel der gesamte Vektor vorsichtshalber an Python zurück, obwohl `mond` dort
nur ein wirkungsloses, ganzzahlgebundenes Kommando ist.

## Neuer typisierter Vertrag

Der Planer trennt jetzt:

- `has_integer`: beliebige für physische Tabellen verwendbare Ganzzahlzeilen,
  einschließlich Projektionen aus `n/m`;
- `has_explicit_integer_axis`: ausschließlich tatsächlich geschriebene
  gewöhnliche Ganzzahl-, Bereichs-, Null- oder Ausschlusskomponenten.

Klassische Ganzzahlfamilien verwenden nur noch die zweite Bedingung. Dadurch
laufen reine Bruchdomänen nativ weiter, ohne eine Mond-, Richtungs-,
Primzahlkreuz-, Alles- oder Thomas-Tabelle zu erfinden.

Für mehrere Bruchdomänen sind solche klassischen Wörter als inert erlaubt,
solange keine gewöhnliche Ganzzahlachse vorhanden ist. Die folgenden Pläne sind
nun vollständig nativ:

```text
mond universum motive v2/3
richtung universum motive v2/3
primzahlkreuz universum motive v2/3
alles universum motive v2/3
thomas universum motive v2/3
```

Der erste Plan ist semantisch identisch zu `universum motive v2/3`. Bei einer
Einzeldomäne beeinflusst das zusätzliche erkannte Kommando weiterhin korrekt
die historische Universum-Spaltenunterdrückung, erzeugt aber keinen eigenen
Tabellenaufruf.

## Bewusst verbleibende Grenze

Eine echte Ganzzahlkomponente aktiviert den klassischen Python-Zweig. Die
Reihenfolge einer solchen klassischen Tabelle gegenüber mehreren unabhängig
korrigierten Bruchrechtecken ist noch nicht allgemein festgelegt. Deshalb
bleibt etwa

```text
mond universum motive v2/3,5
```

atomarer Fallback. Es wird keine teilweise Ausgabe erzeugt.

## Referenzbeleg

`scripts/prompt_classic_fraction_guard_reference.py` führt alle Fälle in einem
einzigen eingefrorenen Python-Prozess aus und sammelt die vor dem bekannten
`IndexError` erfolgten Tabellenaufrufe. Für die reinen Bruchfälle entstehen
exakt null klassische Aufrufe. Der Gegenfall mit `,5` beendet sich regulär und
erzeugt genau einen Mondaufruf nach den Bruchfamilien.

## Lokaler Compilerlauf

```sh
scripts/build-all.sh -- -j 5
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bk.sh -- -j 4
```


## Bruchteiler: äußere Zeile 1 bleibt sichtbar

Der gemeinsame Helfer `python_divisor_set_order` bildet bewusst die
nichttriviale Divisormenge der allgemeinen Tabellenlogik nach und entfernt bei
einem positiven Wert die `1`, sobald weitere Divisoren existieren. Die äußere
Prompt-Grammatik für `v n/m,<Ganzzahl> teiler` besitzt jedoch einen zusätzlichen
Vertrag: Sobald mindestens ein positiver gewöhnlicher Wert überlebt, wird Zeile
`1` vor den nichttrivialen Divisoren wieder sichtbar.

Damit gilt für den korrigierten nativen Bruchplan beispielsweise:

```text
universum v2/3,1 teiler  -> 2,1,4,6,3,1,v1
universum v2/3,5 teiler  -> 2,1,4,6,3,1,5,v5
```

Der Spezialfall `1` wird nicht doppelt angefügt. Null- und reine
Ausschlussachsen erzeugen weiterhin keine künstliche Zeile `1`.

## Hermetische native Kommando-Parität

Der Produktionsbinary war in den vier repräsentativen Fällen bereits korrekt.
Der frühere Prüfer übernahm jedoch mit `setdefault` vorhandene
`RETA_ROOT`, `RETA_SHARE_DIR`, `RETA_DATA_DIR`, `RETA_ASSET_DIR` und
`RETA_REFERENCE_DIR` aus der Entwickler-Shell. Dadurch konnte derselbe Binary
gegen einen installierten oder älteren CSV-Bestand laufen und scheinbare
Ausgabedifferenzen erzeugen.

Der Prüfer setzt nun alle Source-Tree-Ressourcen zwingend selbst und entfernt
`RETA_SHARE_DIR`. Der Stage-Test startet ihn absichtlich mit ungültigen
Fremdpfaden; trotzdem müssen alle vier gepinnten Fälle bestehen. Bei einer
echten Differenz wird zusätzlich die erste abweichende Zeichenposition mit
Ausschnitten beider Seiten ausgegeben.

## Konservativ inkrementelle Testkompilierung

`mojo build` erhält weiterhin genau eine Testhauptdatei pro Aufruf. Das Projekt
führt deshalb selbst einen fail-closed Abhängigkeitsfingerabdruck. Er enthält:

- die jeweilige Testquelle;
- alle transitiv aufgelösten lokalen Mojo-Importe;
- nicht auflösbare lokale Importmarker;
- Compilerpfad und `mojo --version`;
- Plattform, Linkprofil und vollständige Compileroptionen;
- ausgewählte buildrelevante Umgebungswerte und die Buildrezepte.

Nur wenn dieser SHA-256-Wert zum vorhandenen gültigen ELF passt, wird das
Testprogramm wiederverwendet. Das globale Ready-Manifest wird während des
Builds weiterhin entfernt und erst nach vollständigem Erfolg atomar
veröffentlicht. Ein Vollbuild bleibt jederzeit erzwingbar:

```sh
scripts/build-tests.sh --rebuild-all --heavy -- -j 4
```

Compilerfreie Orchestrierungsproben bestätigten 131 Erstbuilds, danach 131
Wiederverwendungen; nach ausschließlicher Änderung einer Testhauptdatei wurde
nur dieses eine Testprogramm neu gebaut.

## Nichtwerfender Tabellenruntime-Zugriff

`Dict.__getitem__` kann in Mojo `DictKeyError` auslösen. Der öffentliche
nichtwerfende Accessor `hoechsteZeile()` verwendet deshalb nun `Dict.get()` mit
den historischen Standardwerten 163 beziehungsweise 1024. Die Factory legt die
beiden Schlüssel weiterhin ausdrücklich an; der Accessor kompiliert nun aber
auch für manuell rekonstruierte Zustände ohne `raises`.
