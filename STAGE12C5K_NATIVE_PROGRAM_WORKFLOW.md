# Stage 12c5k – nativer Program-Workflow-Kern und klare Inhaltsprofile

## Ziel

`reta_architecture/program_workflow.py` war noch ein vollständig referenzierter
Orchestrierungsbesitzer. Die Datei verbindet CSV-Laden, Parameterlaufzeit,
Spaltenauswahl, Tabellengenerierung, Kombi-Joins und Ausgabe. Der vollständige
historische `Program`-Objektgraph ist heterogen und noch nicht in einem Schritt
sinnvoll typisierbar. Deshalb wird in dieser Stage die eigene deterministische
Logik des Workflow-Besitzers nativ übernommen, ohne dynamische Python-Objekte
nachzubauen.

## Reproduzierbarer Workflow-Vertrag

`tools/generate_program_workflow_catalog.py` liest die eingefrorene Python-AST
und erzeugt `assets/program_workflow.tsv`. Erfasst werden in Quellreihenfolge:

- 4 Dataclass-Felder,
- 11 Methoden,
- 10 interne `self`-Aufrufkanten,
- 12 Snapshot-/Orchestrierungsschritte,
- 1 Bootstrapfunktion.

`src/reta_mojo/program_workflow.mojo` validiert Ordinale, Zählungen und
Methodenkanten ohne Python-Import.

## Echte native Laufzeitlogik

Der neue Besitzer implementiert:

- portable CSV-Pfadnormalisierung über den gemeinsamen Ressourcenresolver,
- Auswahl von `plain`, `html` und `bbcode` aus der lokalisierten
  `--art=`-Oberfläche,
- die Python-kompatible Religion-Zelldekodierung einschließlich JSON-Nutzlast,
- Laden und Semikolonparsen der Religionstabelle,
- serielle oder native Mojo-Thread-Decodierung in stabiler Zeilenreihenfolge,
- Auffüllen der Haupttabelle bis zur historischen höchsten Zeile,
- koreanischen, chinesischen und vietnamesischen Ersatz der Motivspalte,
- typisierten Reset der vier Workflow-Laufzeitflags,
- die exakte `kombi13`-/`kombi15`-Verzweigungsrechnung für CSV-Nummer,
  Zeilenquelle und bisherigen Haupttabellenumfang,
- einen nativen Snapshot und die Diagnose-CLI `reta-mojo-workflow`.

Die Datei bleibt **teilweise nativ**: `workflow_everything` aggregiert im Python-
Original weiterhin mehrere heterogene Besitzer über das alte mutable `Program`-
Objekt. Diese letzte Objekthülle wird erst entfernt, wenn Tabellenlaufzeit,
Generierung und Ausgabe vollständig denselben typisierten Zustandswert teilen.

## Welche Inhalte künftig hochgeladen werden sollen

`PROJECT_CONTENT_PROFILES.md` unterscheidet:

1. das Sourcearchiv für Transpilierung und Review,
2. den lokalen Buildbaum,
3. die installierte Laufzeit unter `/usr` beziehungsweise `/usr/local`.

Für weitere Runden genügt:

```sh
scripts/create_source_archive.sh ../reta_arch_mojo_12c5k.tar.xz
```

Nicht benötigt werden `target/`, `.venv/`, `.git/`, Caches, Bytecode, temporäre Editor-/Testdateien,
absolute Runtime-Symlinks oder bereits installierte `/usr`-Kopien. Eine
`middle.alx`-Vollausgabe ist nur dann sinnvoll, wenn gerade genau diese
Ausgabeparität geprüft wird.

## Build und Tests

Neues reguläres Compilerziel:

```text
target/bin/reta-mojo-workflow
```

Der Installer besitzt damit 33 deklarierte Compilerziele. Der Stage-Test baut
Modultest und CLI und führt anschließend `scripts/check_program_workflow_parity.py`
aus. Die Paritätssuite prüft Zellen, Ausgabemodus, beide Kombi-Zweige und die
vollständige Religionstabellen-Zusammenfassung.

In der aktuellen Sandbox fehlt der offizielle Modular-Mojo-Compiler. Deshalb
wurden hier die reproduzierbaren AST-/Katalog-, Source-, Installations-,
Boundary-, Defekt- und Metriktests ausgeführt; der native Build ist für den
lokalen Mojo-1.0.0b2-Lauf vorbereitet.

## Fortschritt

- vollständig nativ/generiert: **57/92 = 62,0 %**,
- mindestens teilweise portiert: **79/92 = 85,9 %**,
- angegriffene Referenzzeilen: **36.282/48.831 = 74,3 %**,
- Mojo-Quellzeilen in `src/`: **51.456**,
- aktive eingebettete Python-Brücken: **0**.
