# Stage 12c4e – Native-first historische `reta`-Oberfläche

Stage 12c4e entfernt die letzte eingebettete CPython-Laufzeitgrenze aus dem
öffentlichen Tabellenlauncher. `compat_main.mojo` entscheidet nun vor jeder
Ausführung konservativ, ob der vollständige Argumentvektor vom nativen
Mojo-Tabellenkern besessen wird.

## Laufzeitentscheidung

Für einen nichtleeren Aufruf gilt:

1. `native_reta_tokens_supported(...)` prüft jede Sektion, Option, jeden Wert,
   positionalen Token und Ausgabemodus.
2. Nur wenn der **gesamte** Vektor unterstützt wird, ruft der Launcher
   `run_native_reta(...)` im selben Prozess auf.
3. Sobald ein Bestandteil unbekannt oder nur teilweise portiert ist, wird der
   unveränderte Argumentvektor atomar über den expliziten Mojo-Kindprozessadapter
   an `python_reference/reta.py` übergeben.
4. Der Exitstatus des Referenzprozesses wird über die libc-Grenze unverändert
   zum Aufrufer weitergereicht.

Die leere historische Kommandozeile bleibt wegen ihrer zusätzlichen Hilfe- und
Defaultsemantik auf der Referenzoberfläche. Mit
`RETA_FORCE_REFERENCE=1` lässt sich die Referenz auch für vollständig native
Aufrufe ausdrücklich erzwingen. `RETA_NATIVE=1 ./reta` bleibt der explizite
Native-Modus ohne Fallback.

## Entfernte Grenze

`src/compat_main.mojo` importiert weder `std.python` noch `PythonObject` und das
resultierende Programm bindet kein `libpython`. Der Python-Referenzpfad ist nur
noch ein normaler, sichtbarer Kindprozess für noch nicht besessene Semantik.
Damit besitzt der Laufzeitquellbaum **null aktive eingebettete Python-Brücken**.

Die in Stage 12c4d bereits logisch entfernten Altdateien
`prompt_python_bridge.mojo` und `prompt_external_python_ffi_probe.mojo` sind nun
auch physisch aus dem Releasebaum entfernt.

## Ownership-Korrektur

Der Audit des strengen Dispatch-Prädikats zeigte, dass `--onetable` irrtümlich
als nativ unterstützt markiert war, obwohl der native Renderer diese Option
noch nicht implementiert. Stage 12c4e entfernt diese Freigabe. Ein solcher
Aufruf fällt jetzt vollständig und atomar auf Python zurück, statt teilweise
nativ interpretiert zu werden.

## Reproduzierbarer Vertrag

Der neue Vertrag prüft unter anderem:

- typisierte Argumentweitergabe einschließlich Leerargumenten, Unicode und
  gemischten Quotes;
- byteidentisches stdout und stderr einschließlich NUL- und Nicht-UTF-8-Bytes;
- unverändertes Arbeitsverzeichnis und echten Kindprozess-Exitstatus;
- native Ausführung bei absichtlich ungültigem `RETA_PYTHON`;
- atomaren Fallback für `--onetable`, die leere Kommandozeile und den expliziten
  Referenzoverride;
- deutsche und englische physische Spalten, Generator-, Modal-, Primzahlkreuz-,
  Primzahlwirkungs-, Meta-, Bruch-, Kombi-, BBCode-, HTML- und explizite
  Spaltenreihenfolgefälle.

```text
Kompatibilitätslauncher-Pytests:       8/8
native-first Referenzvertrag:         12/12 byteidentisch
native CLI Ownership-Tests:           22/22
Kombi-Parität über Launcher:           9/9
Markup-Parität über Launcher:          8/8
Basistabellen-Parität über Launcher:   4/4
aktive std.python-Brücken:               0
explizite Kindprozessadapter:             1
verbotene Parallel-Prozessprimitive:      0
```

Die zwölf Referenzfälle setzen `RETA_PYTHON` absichtlich auf einen nicht
existierenden Pfad. Ein Erfolg beweist daher, dass sie tatsächlich im nativen
Mojo-Kern liefen und nicht unbemerkt die Python-Referenz starteten.

## Build und Prüfung

Für den regulären Gesamtbuild genügen weiterhin:

```bash
scripts/build-heavy.sh
scripts/build.sh
```

Die Stage-spezifischen Prüfungen sind optional:

```bash
scripts/check_compat_launcher.sh
RETA_COMPAT_PARITY_GROUP=1 scripts/check_compat_native_first_parity.sh
RETA_COMPAT_PARITY_GROUP=2 scripts/check_compat_native_first_parity.sh
scripts/test_stage12c.sh
```
