# Stage 12c5x – Modulimport-Reparatur und vollständiges Console-IO

## Gemeldeter Compilerabbruch

`src/reta_mojo/table_generation.mojo` importierte `.kombi_join`, während das
kanonische Modul `src/reta_mojo/combi_join.mojo` heißt. Modular brach deshalb
beim Parsen von `table_generation_main.mojo` mit
`unable to locate module 'kombi_join'` ab.

Der Import verwendet jetzt `.combi_join`. Zusätzlich prüft
`tests/test_mojo_relative_imports.py` alle derzeit **260** relativen Imports im Paket gegen
die real vorhandenen `.mojo`-Module. Damit wird ein falscher Modulname bereits
in der portablen Source-Suite erkannt, bevor ein Compiler verfügbar sein muss.

## Vollständiger nativer Besitzer für `console_io.py`

Die bislang teilweise native Datei besitzt jetzt einen vollständigen typisierten
Mojo-Vertrag:

- `ConsoleIOMorphismBundle` und vollständiger Snapshot;
- geordnete Chunks und exakte beziehungsweise schlüsselbasierte Eindeutigkeit;
- CLI- und Debug-Effektplanung sowie direkte Print-Morphismen;
- deutsche und englische Reta-/Prompt-Hilfetexte ohne Python-Laufzeit;
- expliziter `ConsoleTextWrapRuntime` mit nativer Terminalbreite;
- insertion-order-stabile `DefaultOrderedDict`-Reduktion für die produktiv
  verwendete String-zu-Stringlisten-Domäne;
- Stage-39-Morphismen, Kompatibilitätsnamen und Architekturmetadaten.

Dynamische Python-Callables, Rich-Klassen und beliebige heterogene
`OrderedDict`-Werte werden nicht emuliert. Ihre tatsächlich beobachtbare
Produktionssemantik ist als typisierte Capability beziehungsweise geordnete
Wertstruktur ausgedrückt.

## Help-Newline-Grenze

Die vorhandenen `reta_help_*.txt`-Assets repräsentieren die vollständige
CLI-Ausgabe und enthalten deshalb eine zusätzliche abschließende Newline.
Python `reta_help_text()` liefert dagegen nur den Dateiinhalt. Der native
Funktionspfad entfernt exakt diese eine generierte Newline, während der
CLI-Startup-Pfad unverändert bytegenau bleibt.

## Compiler- und Paritätsprüfung

```bash
scripts/test_stage12c5x.sh
```

Das Skript kompiliert zuerst den vollständigen `src/main.mojo`-Importgraphen und
anschließend genau `table_generation_main.mojo`. Danach folgen der native
Console-IO-Modultest, die Python-/PyPy3-Parität für Snapshot, Chunks,
Eindeutigkeit, normalisierte CLI-Ausgabe und alle vier Hilfetexte sowie die
portablen Source-, Ownership-, Archiv-, Boundary- und Defektgates.

Die Crashpad-Meldung bleibt eine nicht-fatale Compilerwarnung. Maßgeblich ist
die erste nachfolgende `error:`-Diagnose.

## Compilerunabhängige Abschlussgates

- fokussierte Import-/Ownership-/Installations-/Defekt-/Archivgates: **57/57**;
- gesamter portabler Source-Testbestand: **141 bestanden, 1 begründeter Skip**;
- Defektkatalog: **94/94 konsistent**;
- aktive `std.python`-Brücken: **0**.
