# Stage 12c5z – gemeinsame Diagnosebibliothek und portabler Target-Export

## Ausgangslage

Der hochgeladene kompilierte `target/`-Baum enthielt 41 ausführbare Dateien in
`target/bin`, weitere 28 Testprogramme unter `target/tests` und
`target/test-bin` sowie insgesamt 30.858.015 Byte. Die vier zuletzt ergänzten
Diagnoseprogramme

- `reta-mojo-table-generation`,
- `reta-mojo-output-syntax`,
- `reta-mojo-console-io`,
- `reta-mojo-table-output`

belegten zusammen 1.119.016 Byte und banden denselben Mojo-Laufzeit- und großen
Modulbestand jeweils erneut als eigenständiges ELF-Programm ein.

Die fünf Einträge unter `target/lib/mojo` waren absolute Symlinks in den
ursprünglichen Home-/`.venv`-Pfad. Nach Übertragung des Projektordners waren
alle fünf Links gebrochen. Die eigentlichen Executables besaßen bereits den
richtigen relativen RUNPATH `$ORIGIN/../lib/mojo`; nur die Laufzeitclosure war
nicht portabel kopiert worden.

## Neue Binärarchitektur

Stage 12c5z ersetzt die vier installierbaren Diagnose-ELFs standardmäßig durch:

```text
target/bin/reta-mojo-diagnostics
target/lib/reta/libreta-mojo-diagnostics.so
```

`reta-mojo-diagnostics` ist ein kleiner C-Loader. Die Shared Library exportiert
über eine ausdrücklich versionierte C-ABI ausschließlich `argc`, `argv` und
einen Integerstatus. Mojo-eigene Strings, Listen und Fehlerobjekte überschreiten
die ABI-Grenze nicht.

Exportierte Symbole:

```text
reta_mojo_diagnostics_abi_version
reta_mojo_table_generation_entry
reta_mojo_output_syntax_entry
reta_mojo_console_io_entry
reta_mojo_table_output_entry
```

Die bisherigen öffentlichen Befehle bleiben erhalten. Ihre Shell-Launcher
rufen denselben Loader mit einem festen Unterbefehl auf. Der Loader prüft vor
`dlopen`, dass sein eigener und der Bibliotheks-Source-ID-Stempel identisch
sind, verifiziert ABI-Version 1 und löst erst danach das konkrete Symbol auf.

Die vier alten Einzelprogramme können mit
`RETA_BUILD_STANDALONE_DIAGNOSTICS=1 scripts/build.sh` weiterhin als direkte
Vergleichsorakel erzeugt werden. Sie gehören aber nicht mehr zur normalen
Installationsmenge.

## RUNPATH und Installation

Executables unter `target/bin` verwenden weiterhin:

```text
$ORIGIN/../lib/mojo
```

Die Bibliothek unter `target/lib/reta` benötigt dagegen:

```text
$ORIGIN/../mojo
```

`tools/sanitize_mojo_runpath.py` akzeptiert den gewünschten relativen
Komponentenpfad nun explizit. Dadurch wird der Executable-Pfad nicht irrtümlich
auf eine Shared Library übertragen.

Bei `PREFIX=/usr` installiert `scripts/install.sh` das Bundle nach:

```text
/usr/lib/reta/target/bin/reta-mojo-diagnostics
/usr/lib/reta/target/lib/reta/libreta-mojo-diagnostics.so
```

Loader und Bibliothek werden atomar mit beiden Source-ID-Sidecars installiert.
Die normale Menge sinkt von 41 installierbaren Executables auf 38 Executables
plus eine Shared Library: 20 reguläre Executables, 18 schwere Executables und
eine gemeinsame Bibliothek.

## Portabler Target-Export

Lokale inkrementelle Builds dürfen die Modular-Laufzeit weiterhin schnell per
Symlink unter `target/lib/mojo` einhängen. Für eine Übergabe an einen anderen
Rechner erzeugt nun

```bash
scripts/export_target.sh target target-portable.tar.xz
```

ein Archiv, in dem die fünf Laufzeitbibliotheken physisch kopiert sind.
Alternativ kann `configure_mojo_runtime.sh` direkt mit
`RETA_MOJO_RUNTIME_MODE=copy` aufgerufen werden. Der Export bricht ab, falls im
Laufzeitverzeichnis noch ein Symlink verbleibt.

## Teststrategie

Die Testprogramme unter `target/tests*` bleiben absichtlich nicht
installierbare, kurzlebige Executables. Separate Prozesse liefern bei
Compilerabstürzen und ABI-Fehlern die bessere Isolation; eine Test-Shared-Library
würde Fehlerzustände und globale Mojo-Laufzeitdaten unnötig zwischen Tests
koppeln. Installierbare Diagnoseoberflächen werden dagegen schrittweise in
fachlich zusammenhängende Shared Libraries konsolidiert.

Compilerunabhängig geprüft werden:

- C-Loader mit `-Wall -Wextra -Werror`,
- reale `dlopen`-/`dlsym`-Weiterleitung gegen eine künstliche Testbibliothek,
- Wiederherstellung der historischen `argv[0]`-Programmnamen,
- ABI- und Source-ID-Ablehnung,
- FHS-Installation von Loader, Bibliothek und Sidecars,
- Bibliotheks-spezifischer RUNPATH,
- kopierter portabler Runtime-Export,
- alle vier Kompatibilitätslauncher,
- sämtliche bestehenden Source-, Import-, Ownership- und Defektgates.

Der echte Modular-Build ist in `scripts/test_stage12c5z.sh` vorbereitet. Er baut
die Shared Library und zusätzlich die vier früheren Einzelprogramme nur als
Paritätsorakel.

## Compilerunabhängiger Abschlussstand

```text
Source-Tests:                       149 bestanden, 1 Skip
zusätzliche Infrastrukturtests:     58/58
Source-Archivvertrag:                3/3
Defektkatalog:                       97/97
Manifestdateien:                  1.386/1.386
Mojo-Zeilen in src/:               56.849
davon in src/reta_mojo/:           52.292
```
