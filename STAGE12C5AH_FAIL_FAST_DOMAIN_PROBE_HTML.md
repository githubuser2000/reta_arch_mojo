# Stage 12c5ah – Fail-fast-Buildtreiber und native Domain-Probe-HTML-Grenze

## Buildsteuerung

`do.sh` arbeitet ausschließlich im aktuellen Verzeichnis. Es leitet den
Projektpfad nicht mehr aus `$0` ab und wechselt nicht mehr automatisch in ein
Verzeichnis. Dadurch führt ein über `/bin` oder einen anderen Suchpfad
aufgerufener Symlink nicht versehentlich Builds im falschen Verzeichnis aus.

Der Ablauf ist explizit fail-fast:

1. `scripts/build-all.sh`
2. `scripts/test_current_stage.sh`
3. `scripts/build-and-test-shared-diagnostics.sh`
4. `scripts/test_all.sh`
5. `git add -A` und `git commit`

`test_current_stage.sh` ist ein stabiler Zeiger auf den jeweils neuesten
fokussierten Stage-Test. Damit muss der Benutzer den Stage-Test nicht zusätzlich
zu `do.sh` manuell aufrufen.

Jeder Nichtnullstatus wird unverändert zurückgegeben. Alle späteren Schritte
werden ausgelassen und die ursprüngliche Compiler- oder Testdiagnose bleibt auf
stdout/stderr sichtbar.

## Native Domain-Probe

`src/domain_probe_main.mojo` besitzt jetzt zusätzlich:

- `column`
- `column-json`
- `html-json`
- `html-all-json`
- `pair-html-json`

Die HTML-Daten werden aus der bereits nativen `HtmlReferenceSheaf` mit 669
Referenzeinträgen gelesen. Für unbekannte Spalten wird derselbe leere
JSON-Vertrag wie in der Python-Referenz erzeugt. Der Paritätstest vergleicht
jetzt zehn Text- und JSON-Oberflächen einschließlich des vollständigen
669-Zeilen-HTML-Snapshots.

Nur `schema-json` und `architecture-json` verbleiben als große aggregierte
Snapshotgrenzen außerhalb dieses CLI-Besitzers.

## Prüfung

Der fokussierte Lauf ist:

```sh
scripts/test_stage12c5ah.sh
```

Der vollständige lokale Nachweis bleibt:

```sh
./do.sh 12c5ah
```
