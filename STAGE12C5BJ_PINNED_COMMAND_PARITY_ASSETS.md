# Stage 12c5bj – gepinnte Kommando-Paritätsassets

## Ausgangsfehler

Auf dem Python-3.14-Entwicklungsrechner waren die bereits kanonischen Dateien

- `assets/command_parity/html-religion-basic.out` (`a8a0d2a1…`) und
- `assets/command_parity.tsv` (`9fdefe9a…`)

vorhanden. `test_stage12c5bh.sh` rief trotzdem `--migrate-legacy` auf. Der
Generator berechnete seine Erwartung erneut mit dem lokalen CPython und wertete
die kanonischen Dateien wegen einer interpreterabhängigen HTML-Abweichung als
unbekannte Migrationsquelle.

## Neuer Vertrag

`--check` führt den Python-Renderer nicht aus. Es prüft fünf fest versionierte
SHA-256-Verträge: vier Ausgabedateien und das TSV-Manifest. Dadurch ist der
Stage-Gate unabhängig von CPython 3.13/3.14 und von installierten Rich-Versionen.

`--check-reference` bleibt als ausdrückliche Entwicklerdiagnose erhalten. Dieser
Modus führt die eingefrorene Python-Referenz aus und meldet Abweichungen, darf
aber keine Release- oder Stage-Freigabe blockieren, solange nur die beiläufige
Interpreterdarstellung abweicht.

Die historischen Stages `12c5aq`, `12c5bg` und `12c5bh` verwenden nur noch den
read-only `--check`-Pfad. Kein Testlauf migriert oder schreibt Quelldateien.
`--migrate-legacy` ist weiterhin idempotent: Sind die gepinnten Hashes bereits
vorhanden, endet es ohne Referenzausführung erfolgreich. Eine echte Migration
wird nur aus exakt bekannten Altzuständen und nur dann vorgenommen, wenn der
aktive Referenzinterpreter selbst die gepinnten Payloads reproduziert.

## Lokaler Lauf

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bj.sh -- -j 4
```

## Mojo-Typkorrektur im Bruchteilerpfad

Der reale Vollbuild von Stage `12c5bi` fand zusätzlich eine statisch nicht
erkannte Typgrenze: `range_to_numbers(...)` liefert `Set[Int]`, während
`python_divisor_set_order(...)` bewusst `List[Int]` erwartet. Der Teilerpfad
materialisiert die Menge nun ausdrücklich in einer besitzenden `List[Int]`,
bevor die CPython-3.13-Mengenreihenfolge der Divisoren rekonstruiert wird.

`test_stage12c5bj.sh` kompiliert und startet den vollständigen
True-Fraction-Probe auch bei `RETA_STAGE_SKIP_PREVIOUS=1`. Damit wird diese
Modulgrenze künftig vom echten Mojo-Compiler geprüft und nicht nur durch
Python-Quellverträge.
