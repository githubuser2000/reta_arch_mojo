# Stage 12c5af – atomare und nachweisbar frische Builds

## Anlass

Der letzte lokale Ablauf wurde als nicht korrekt kompiliert gemeldet. Der
mitgelieferte Helfer `do.sh` prüfte den Exitstatus mit
`[ "echo $?" == "0" ]`. Diese Bedingung prüft nicht den vorherigen Exitstatus
und ist unter POSIX `sh` zusätzlich nicht portabel. Außerdem sanitisierte
`build-heavy.sh` beim Verlassen pauschal den gesamten Zielordner. Nach einem
Abbruch konnten dadurch alte Binaries einen neuen Dateizeitstempel erhalten,
obwohl sie nicht neu kompiliert worden waren.

## Korrekturen

- `do.sh` verwendet `set -eu`, führt Build und Tests direkt aus und committet
  erst nach vollständigem Erfolg.
- Reguläre und schwere Mojo-Ziele werden zunächst unter einem temporären Namen
  kompiliert, als ELF geprüft, am RUNPATH bereinigt und markiert. Erst danach
  ersetzen zwei `mv`-Operationen Binary und Sidecar.
- Ein Compilerfehler bewahrt das vorherige bekannte Binary unverändert und
  liefert den ursprünglichen Exitstatus weiter.
- Die Shared-Diagnosebibliothek und ihr C-Loader werden vollständig in
  temporäre Dateien gebaut, bevor das Paar veröffentlicht wird.
- Der gefährliche globale `EXIT`-Sanitizer des Heavy-Builds wurde entfernt.
  Nur das gerade erfolgreich erzeugte temporäre Binary wird bearbeitet.
- Die Frische-ID wird aus den aktuellen Inhalten aller Mojo-Quellen, Assets und
  Buildrezepte berechnet. Ein vergessenes `SOURCE_MANIFEST.sha256` kann damit
  keine veralteten Binaries mehr als aktuell erscheinen lassen.
- `build-all.sh` endet erst erfolgreich, nachdem sämtliche regulären und
  schweren Ziele als ELF und mit passender Inhalts-ID geprüft wurden.
- `install.sh` verweigert veraltete oder unmarkierte vorhandene Buildziele.

## Inkrementelles Kompilieren

Die Produktionsskripte bleiben absichtlich **nicht inkrementell**. Eine sichere
Umstellung würde einen vollständigen, compilergetreuen Import- und
Buildabhängigkeitsgraphen einschließlich Package-Exports, generierter Kataloge,
Linkerflags, Compiler-Version und Shared-Library-Grenzen benötigen. Eine nur aus
Zeitstempeln oder oberflächlich geparsten Imports abgeleitete Auswahl könnte
Abhängigkeiten übersehen.

Ein späterer inkrementeller Modus darf deshalb nur optional eingeführt werden
und muss fortlaufend gegen einen leeren Vollbuild geprüft werden. Maßgeblich
sind Zielmenge, Inhalts-IDs, Linkgrenzen und die vollständige Verhaltensparität;
bytegleiche ELF-Dateien sind wegen möglicher nichtdeterministischer
Compiler-Metadaten nicht zwingend zu erwarten.

## Reproduzierbarer Orchestrierungstest

```sh
scripts/test_stage12c5af.sh
```

`test_atomic_build.sh` benutzt einen kleinen kontrollierten C-basierten
Fake-Compiler. In den echten regulären und schweren Buildskripten wird jeweils
das erste Ziel erfolgreich veröffentlicht und beim zweiten Ziel ein
Compilerabbruch erzwungen. Zusätzlich wird das gekoppelte Shared-Library-/Loader-
Paar vollständig gebaut. Der Test beweist, dass Exitstatus 9 erhalten bleibt,
die vorherigen zweiten Binaries bytegleich bleiben und keine temporären
Artefakte zurückbleiben.
