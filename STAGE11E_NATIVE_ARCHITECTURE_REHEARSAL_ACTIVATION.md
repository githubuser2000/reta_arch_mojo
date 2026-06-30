# Stage 11e – Native Architektur-Rehearsal und Aktivierung

Stage 11e überträgt die Stage-35- und Stage-36-Steuerungsschichten aus der
unveränderten Python-Referenz in zwei getrennte, typisierte Mojo-Bundles.
Beide Schichten bleiben metadata-only: Sie verschieben keine produktive
Laufzeitlogik, sondern beschreiben Trockenlauf, Gates, Commit, Rollback und
Transaktionsgrenzen für spätere Refactorings.

## Native Rehearsal-Schicht

`reta_architecture/architecture_rehearsal.py` wird reproduzierbar nach
`src/reta_mojo/architecture_rehearsal.mojo` generiert.

Der Snapshot enthält:

- 7 topologische Rehearsal-Öffnungen
- 34 Rehearsal-Moves
- 34 Gate-Rehearsal-Suiten
- 7 Readiness-Cover
- 5 gespeicherte Referenzchecks
- Validierungsstatus `passed`

Die native Laufzeitvalidierung prüft zusätzlich direkt im Mojo-Bundle:

- genau eine Gate-Suite je Move
- nichtleere Preflight- und Postflight-Kommandos
- den Status `rehearsed` beziehungsweise `ready`
- genau ein Cover je Öffnung
- gleiche Anzahl lokaler Moves und Gate-Suiten je Cover
- den Status `covered`

Öffentliche Abfragen:

```bash
./bin/reta-mojo-rehearsal --summary
./bin/reta-mojo-rehearsal --open-set REH35-OPEN-M0
./bin/reta-mojo-rehearsal --move REH35-MOVE-MIG34-01
./bin/reta-mojo-rehearsal --gate REH35-GATE-MIG34-01
./bin/reta-mojo-rehearsal --cover REH35-COVER-M0
```

## Native Aktivierungsschicht

`reta_architecture/architecture_activation.py` wird reproduzierbar nach
`src/reta_mojo/architecture_activation.mojo` generiert.

Der Snapshot enthält:

- 7 Aktivierungsfenster
- 34 Aktivierungseinheiten
- 34 Commit-Gates
- 34 Rollback-Sektionen
- 7 Aktivierungstransaktionen
- 6 gespeicherte Referenzchecks
- Validierungsstatus `passed`

Die native Laufzeitvalidierung prüft zusätzlich:

- genau ein Commit-Gate und eine Rollback-Sektion je Aktivierungseinheit
- nichtleere Commit- und Rollback-Kommandos
- die Status `activation_ready`, `commit_gated` und `rollback_ready`
- genau eine Transaktion je Fenster
- gleiche Anzahlen von Aktivierungseinheiten, Gate-Suiten und Rollback-Sektionen
- den Status `transaction_ready`

Öffentliche Abfragen:

```bash
./bin/reta-mojo-activation --summary
./bin/reta-mojo-activation --window ACT36-WINDOW-M0
./bin/reta-mojo-activation --unit ACT36-REH35-MOVE-MIG34-01
./bin/reta-mojo-activation --gate ACT36-GATE-MIG34-01
./bin/reta-mojo-activation --rollback ACT36-REH35-MOVE-MIG34-01
./bin/reta-mojo-activation --transaction ACT36-TX-M0
```

## Compilergrenze

Die optimierten Datenbundle-Tests kompilieren normal mit Mojos Standardstufe.
Die beiden öffentlichen, datenlastigen Query-Controller werden in
`scripts/build-heavy.sh` gezielt mit `--no-optimization` gebaut. Das reduziert
hier ihre Buildzeit von einem nicht abgeschlossenen 15-Minuten-O3-Lauf auf:

```text
reta-mojo-rehearsal      14,55 s
reta-mojo-activation     17,21 s
```

Die Abfrageprogramme sind reine Metadateninspektoren; die niedrigere
Optimierungsstufe verändert keinen Vertrag und ist für ihre Laufzeit praktisch
unerheblich.

## Tests

```text
test_architecture_rehearsal     14/14, Build 13,92 s
test_architecture_activation    16/16, Build 16,96 s
                                -----
                                30/30
```

Zusätzlich:

- Python↔Mojo-Abfrageparität: 11/11 byteidentisch
- Stage-11e-Generatorprüfung: 2/2 byteidentisch
- gesamte Architekturkontrollregeneration: 10/10 byteidentisch
- Generatoren mit `PYTHONHASHSEED=0`, `1`, `42`, `random`: byteidentisch
- Rehearsal- und Aktivierungs-Summaries: `passed`

Generator-Hashes:

```text
architecture_rehearsal.mojo
A64F3F121D9DD4B1CFC62362611CC4A53C1D97B9AEFD268B287A9A69C2C47E5B

architecture_activation.mojo
90A60472F14064A55FFF4F0671A7163EE52D7C2390A603F0EA5353106F551078
```

## Buildlayout

`scripts/build-heavy.sh` besitzt jetzt elf getrennte Metadatenziele. Rehearsal
und Aktivierung bleiben eigene Programme, damit Mojo nicht Migration,
Rehearsal, Aktivierung und sämtliche älteren Metakataloge in einem einzigen
Compiler-Monolithen elaborieren muss.

```text
target/bin/reta-mojo-rehearsal
target/bin/reta-mojo-activation
```

## Grenze der Stage

Weiterhin offen innerhalb Stage 11 sind insbesondere:

- `architecture_validation.py` als ausführbare Gesamtvalidierung
- `architecture_progress.py` als dynamisches Fortschritts-Overlay
- Persistenz
- Ausführungsnetz
- Parallelisierung

Es wurde kein Befehl und kein Test mit `--alles` ausgeführt.
