# Stage 12c4l – portable Mojo-Laufzeit und rohes Markup

## Ziel

Stage 12c4l löst zwei voneinander unabhängige Restgrenzen:

1. von einem anderen Rechner übernommene Mojo-ELF-Dateien müssen ohne
   identischen absoluten Installationspfad startbar sein;
2. HTML und BBCode mit `--nocolor` müssen den rohen Python-Ausgabevertrag
   nativ besitzen, auch zusammen mit `--breite` und `--breiten`/`--widths`.

## Ursache des bisherigen Startfehlers

Der Fehler lag nicht an den CSV-Dateien und nicht an speziellen
Prozessorbefehlen. `readelf` weist die geprüften Programme als
`x86-64-baseline` aus. Die von Mojo erzeugten ELF-Dateien benötigen zur Laufzeit
zwei dynamische Bibliotheken:

```text
libKGENCompilerRTShared.so
libAsyncRTMojoBindings.so
```

Der Compiler trug zusätzlich seinen lokalen absoluten Installationspfad als
ELF-`RUNPATH` ein. Ein auf `/home/alex/.../.venv/.../modular/lib` gebautes
Programm konnte deshalb auf einem Rechner ohne genau diesen Pfad nicht vom
dynamischen Loader gestartet werden. Dieser Fehler entsteht vor dem Eintritt
in `main`; die CSV-Pfadauflösung ist daran nicht beteiligt.

## Portable Laufzeitstrategie

Alle Builds erhalten nun zusätzlich den relativen ELF-Suchpfad:

```text
$ORIGIN/../lib/mojo
```

Für ein Programm in `target/bin/` zeigt dieser Ausdruck auf den stabilen,
projektrelativen Ort:

```text
target/lib/mojo
```

`scripts/configure_mojo_runtime.sh` erkennt die lokale Modular-Mojo-Laufzeit
und legt dort zwei Symlinks an. Die echten absoluten Pfade dürfen auf jedem
Rechner verschieden sein. `bin/mojo-runtime-exec` ergänzt außerdem automatisch
`LD_LIBRARY_PATH`; dadurch laufen auch ältere, bereits kompilierte Dateien,
die nur den fremden absoluten `RUNPATH` enthalten.

Erkennungsreihenfolge:

- `RETA_MOJO_RUNTIME_LIBDIR` als expliziter Override;
- Projekt-`.venv` und `.pixi`;
- der über `MOJO_BIN`, `VIRTUAL_ENV` oder `PATH` gefundene Compiler;
- ein entpackter Compiler im lokalen uv-Cache.

Manuelle Einrichtung, falls die automatische Suche nicht genügt:

```bash
RETA_MOJO_RUNTIME_LIBDIR=/pfad/zu/modular/lib \
  ./scripts/configure_mojo_runtime.sh
```

Die CSV-Dateien bleiben normale Laufzeitdaten unter
`python_reference/csv/`. Ihr Ort wird nicht in die ELF-Datei kompiliert; die
öffentlichen Launcher wechseln vor dem Start in die Projektwurzel.

## Arbeitsteilung

Der schnelle Rechner kann weiterhin bauen:

```bash
scripts/build-heavy.sh
scripts/build.sh
```

Nach Übernahme des Archivs genügt auf dem anderen Rechner:

```bash
scripts/configure_mojo_runtime.sh
```

Danach starten die übertragenen Programme über die öffentlichen `bin/`-
Launcher. Ein gemeinsamer absoluter Verzeichnispfad ist nicht erforderlich.
Der gemeinsame Vertrag ist ausschließlich `target/lib/mojo` relativ zur
Projektwurzel.

## Nativer `--nocolor`-Markupvertrag

Die Python-Referenz verwendet für farbiges HTML/BBCode Rich und normalisiert
dabei Leerraum. Mit `--nocolor` wird Rich vollständig umgangen; jeder
Markup-Chunk wird unverändert über `print` ausgegeben. Der native Renderer
besitzt nun beide Verträge explizit:

- farbiger Pfad: normalisierte sichtbare Leerzeichen;
- roher Pfad: exakte interne Leerraumläufe, `str.ljust`-Padding und physische
  HTML-Zeilenumbrüche;
- Umbruch und Spaltenmessung verwenden im Rohpfad dieselben signifikanten
  Leerraumlängen wie Python;
- positive Einzelbreiten, Nullbreiten, globale Breite null und
  `--keineleereninhalte` bleiben kombinierbar.

## Prüfungen

```text
Tabellenrenderer:                         18/18
CLI-/Ownership-Planer:                    26/26
Kompatibilitätslauncher:                  14/14
Markup --nocolor Python↔Mojo:             12/12 byteidentisch
positive Einzelbreiten:                   12/12 byteidentisch
explizite Nullbreiten:                    12/12 byteidentisch
paginierte Kernrenderer:                   6/6 byteidentisch
No-blank-Parität:                         13/13 byteidentisch
Markup-oneTable:                          12/12 byteidentisch
portable Runtime-Pfadtests:                4/4
```
