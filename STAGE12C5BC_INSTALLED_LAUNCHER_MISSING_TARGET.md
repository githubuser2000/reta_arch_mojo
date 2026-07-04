# Stage 12c5bc – installierter Launcher ohne optionales Compilerziel

## Ausgangspunkt

Der FHS-Layouttest installiert absichtlich nur die drei verpflichtenden
Produktionsziele. `reta-mojo-table` ist dabei optional. Der installierte
Launcher `reta-mojo --mojo-csv-info` fand auf dem Entwicklungssystem dennoch
den Modular-Compiler und versuchte anschließend, die im Binärpaket bewusst
nicht installierte Datei `src/table_main.mojo` zu starten. Das führte zu
Exitstatus 1 statt zum vertraglichen Exitstatus 127.

## Reparatur

`bin/reta-mojo` besitzt nun eine gemeinsame `run_source_or_missing`-Grenze:

- Im Quellbaum bleibt der komfortable `mojo run`-Fallback erhalten, wenn die
  betreffende `src/*.mojo`-Datei existiert.
- Im installierten FHS-Baum wird bei fehlendem optionalem ELF-Ziel nicht mehr
  auf eine nicht vorhandene Quelle zugegriffen.
- Der Launcher meldet das konkrete fehlende Compilerziel und die nicht
  installierte Quelle und beendet sich deterministisch mit 127.

Damit hängt das Verhalten nicht mehr davon ab, ob auf dem Zielsystem zufällig
ein Mojo-Compiler im `PATH` oder in einer Projektumgebung gefunden wird.

## Enthaltener fachlicher Port

Stage 12c5bc übernimmt außerdem vollständig Stage 12c5bb: Positive reziproke
Vielfache mit ausschließlich nachfolgenden ausgeschlossenen echten Brüchen
werden als native einzelne Reziprokachse geplant. Beispiele sind
`universum v1/4,-2/3`, `universum v1/2,-2/3`,
`emotion v1/4,-2/3` und `universum v1/4,-2/3 teiler`.

## Prüfung

Die portable Stage prüft die komplette 12c5bb-Kette, den Quellvertrag des
Launchers und alle FHS-Installationslayouts. Die eigentliche Mojo-Kompilierung
und native Laufzeitparität führt weiterhin der Benutzer aus:

```sh
scripts/build-all.sh -- -j 8
scripts/test_stage12c5bc.sh
```
