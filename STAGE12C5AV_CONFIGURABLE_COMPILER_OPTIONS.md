# Stage 12c5av – konfigurierbare Mojo-Compileroptionen

## Ziel

Die drei Produktions-Baueinstiege akzeptieren nun denselben unveränderten
Argumentvektor für `mojo build`:

```sh
scripts/build.sh [--] [MOJO_BUILD_OPTION ...]
scripts/build-heavy.sh [--optimize-heavy] [--] [MOJO_BUILD_OPTION ...]
scripts/build-all.sh [--optimize-heavy] [--] [MOJO_BUILD_OPTION ...]
```

Der Trenner `--` ist empfohlen, aber nicht zwingend. Er trennt Skriptoptionen
klar von Mojo-Optionen und verhindert spätere Mehrdeutigkeiten.

## Beispiele

```sh
# Alle regulären Ziele mit O2
scripts/build.sh -- --optimization-level 2

# Vollbuild mit acht Compilerjobs und explizitem CPU-Ziel
scripts/build-all.sh -- --target-cpu <CPU-NAME> -j 8

# Auch die besonders großen, sonst absichtlich mit O0 gebauten Ziele optimieren
scripts/build-all.sh --optimize-heavy -- --optimization-level 2 -j 8
```

Mojos Optimierungsgrad liegt zwischen 0 und 3; ohne Vorgabe verwendet der
Compiler standardmäßig Stufe 3. Das vorhandene `--no-optimization` entspricht
Stufe 0.

## Schwere Ziele

Mehrere sehr große Metadaten-/Konstantenprogramme bleiben aus
Compiler-Skalierungsgründen standardmäßig O0. Weitergereichte CPU-, Debug-,
Define- oder Joboptionen gelten trotzdem. Erst `--optimize-heavy` entfernt die
lokale O0-Sicherheitsvorgabe, sodass ein weitergereichter Optimierungsgrad auch
für diese Ziele gilt.

Die alternative Umgebungsform ist:

```sh
RETA_HEAVY_DEFAULT_NO_OPT=0 \
  scripts/build-heavy.sh -- --optimization-level 2
```

## Shared Diagnostics

Die Mojo-Optionen werden auch an den Build von
`libreta_diagnostics_mojo.so` weitergereicht. Der kleine C-Loader behält seine
separaten festen Optionen `-O2 -Wall -Wextra -Werror`; Mojo-Optionen werden
nicht fälschlich an den C-Compiler übergeben.

## Sicherheit

Quellpfad, Ausgabedatei, ELF-Art, RUNPATH, atomare Veröffentlichung und
Source-ID bleiben im Besitz der Build-Skripte. Ein fehlgeschlagener Compilerlauf
ersetzt weiterhin kein bekannt gutes Ziel.

## Prüfung

`tests/test_build_compiler_options.py` prüft:

- POSIX-Shellsyntax und Hilfe aller betroffenen Skripte,
- bytegetreue Argumentweitergabe einschließlich Argumenten mit Leerzeichen,
- Weitergabe an reguläre, schwere und Shared-Library-Ziele,
- die explizite O0-Sicherheitsvorgabe und deren Abschaltbarkeit,
- Dokumentation der öffentlichen Schnittstelle.

Der Benutzer führt sämtliche Mojo-Kompilierungen aus. Die fokussierte Stage ist:

```sh
scripts/test_stage12c5av.sh
```
