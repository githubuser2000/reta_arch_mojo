# Stage 12c5au – native Start- und Kontrollpfade der `reta.py`-Fassade

## Ausgangslage

Der vom Benutzer ausgeführte Stage-12c5ar-Test reproduzierte weiterhin den
alten Mojo-1.0-Abbruch, weil sein Quellbaum und das nachgereichte
`target.tar.xz` beide die Source-ID
`a168a91cc18b9906030d11dffd621b1afb70ed594f7498407abd9b11eb462050`
tragen. Diese ID gehört exakt zu Commit `1cc9d5c` (12c5ar). Der seit 12c5as
vorhandene injizierbare Parallel-Bootstrap ist erst im neueren Quellstand
enthalten.

## Erweiterter nativer Besitz

`legacy_reta_program.mojo` verwendet innerhalb der historischen
`Program`-Fassade nun dieselben reinen Besitzer wie der native CLI-Launcher:

- `normalize_native_cli_controls()` für `-debug`, `-nichts` und `-nothing`,
- `native_cli_startup()` für leere Aufrufe, reine Sprachwahl und Hilfe,
- `native_reta_tokens_supported()`/`run_native_reta()` für bewiesene Tabellen.

Die Reihenfolge ist absichtlich fest:

1. Kontrollparameter normalisieren,
2. kontroll-only Aufrufe abschließen,
3. Startup/Hilfe klassifizieren,
4. erst danach CSV-Ressourcen auflösen,
5. bewiesene Tabellen nativ ausführen,
6. unbekannte Vektoren mit den originalen Argumenten atomar weiterreichen.

Damit erzeugen Start- und Hilfepfade keine unnötige CSV-I/O und keinen
Python-Kindprozess. Bei einem echten Fallback werden `-debug` und andere
Kontrolltoken nicht doppelt interpretiert; der Referenzprozess erhält den
unveränderten ursprünglichen Vektor.

## Zusätzlich korrigierte Program-Semantik

- `helpPage()` liefert den exakten deutschen beziehungsweise englischen
  Hilfetext aus dem nativen Assetbesitzer statt eines Platzhalterstrings.
- `LegacyRetaProgram.info_log` wird aus dem tatsächlich übergebenen
  `-debug`-Kontrolltoken initialisiert.
- Native Tabellenresultate erhalten den historischen Debugpräfix vor dem
  vollständigen Tabellenstrom.
- Der Besitzer-Snapshot nennt die Startup-/Kontrollmodule ausdrücklich.

## Lokaler Compilerlauf

Der Benutzer führt sämtliche Kompilierungen aus:

```bash
scripts/build-all.sh
scripts/test_stage12c5au.sh
```

Der neue fokussierte Mojo-Test deckt ab:

- leeren Aufruf,
- reine englische Sprachwahl,
- deutsche und englische Hilfe,
- `-debug`,
- `-nichts`,
- kombinierte englische Debug-Hilfe.

Für die vollständige Suite:

```bash
scripts/test_all.sh
RETA_TEST_HEAVY=1 scripts/test_all.sh
```
