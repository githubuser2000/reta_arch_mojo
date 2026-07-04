# Stage 12c5ba – eindeutige Compilerthreads, Effektvertrag und negative Bruch-No-ops

## Gemeldete Buildfehler

Der Benutzerlauf von 12c5az deckte zwei voneinander unabhängige Fehler auf.

### Doppelte Compiler-Threadoption

Drei sehr große Produktionsziele erhielten intern konservativ `-j 4`. Seit den
konfigurierbaren Buildoptionen konnte zusätzlich ein Benutzerwert wie `-j 8`
weitergereicht werden. Mojo lehnt zwei Threadangaben im selben `build`-Aufruf
ab:

```text
error: Number of threads can only be specified once
```

Die Buildskripte verwenden nun einen gemeinsamen POSIX-Shell-Vertrag:

- genau eine benutzerseitige Threadoption ist erlaubt,
- ein Benutzerwert unterdrückt für die drei schweren Ziele das lokale `-j 4`,
- ohne Benutzerwert bleibt `-j 4` erhalten,
- zwei explizite Benutzerwerte brechen vor dem ersten Compileraufruf mit einer
  klaren Meldung ab,
- alle übrigen Mojo-Optionen werden weiterhin bytegetreu weitergereicht.

### Fehlende `raises`-Propagation

Die in 12c5az ergänzte Zusammenführung gemischter Reziprokachsen wandelt bereits
validierte Zeilenstrings mit `Int(...)` zurück in Ganzzahlen. Diese Konvertierung
ist in Mojo 1.0 potenziell werfend. Die beiden internen Hilfsfunktionen

```text
_merge_expanded_reciprocal_multiple_rows
_expanded_reciprocal_multiple_rows
```

sind deshalb nun ausdrücklich `raises`. Der öffentliche Tabellenplaner war
bereits `raises`; es wird kein Fehler geschluckt und keine Ersatzsemantik
eingeführt.

## Weitere native Promptsemantik

Drei historische negative-first Bruchvielfachen-Zweige sind stabile No-ops:

```text
universum v-1/4,2/3
universum v-2/3
universum v-2/3,1/4
```

Die Python-Referenz gibt nur die kompakte Transformationsankündigung aus und
erzeugt keinen `reta`-Aufruf. Mojo bildet dies nun als behandelten Plan mit null
`PromptTableInvocation`-Einträgen ab. Die Reihenfolge ist beobachtbar: Der
positive-first Gegenfall `universum v1/4,-2/3` erzeugt in Python reale Ausgabe
und bleibt deshalb atomarer Fallback. Dadurch wird nur für nachweislich leere
Ergebnispläne kein Python-Kindprozess gestartet.

Der kollidierende Fall

```text
universum v1/4,-1/8,2/3
```

bleibt ebenfalls atomarer Fallback, weil die eingefrorene Referenz dort
weiterhin den dokumentierten `IndexError`-Zweig erreicht.

## Verifikation

Die Stage führt zuerst den vollständigen 12c5az-Promptvertrag aus und prüft
danach mit einem Fake-Compiler:

- Benutzer-`-j 8` erscheint bei jedem schweren Ziel genau einmal,
- ohne Benutzerwert erhalten genau die drei großen Ziele `-j 4`,
- doppelte Benutzerangaben werden vor dem Compiler abgelehnt,
- beide Effekt-Hilfsfunktionen besitzen `raises`,
- die drei negative-first No-op-Pläne sind behandelt und leer,
- der kollidierende positive/negative Reziprokfall bleibt Fallback.

Alle echten Mojo- und Native-Kompilierungen führt weiterhin der Benutzer aus.

Die portable Abschlussprüfung umfasst 115 eindeutige Quell-, Build-, Stage-,
Ledger-, Metrik- und Archivtests. Der Defektledger enthält 125 Einträge bei
weiterhin 20 späteren Python-/PyPy3-Aufräumpunkten.

## Ausführen

```bash
scripts/build-all.sh -- -j 8
scripts/test_stage12c5ba.sh
```
