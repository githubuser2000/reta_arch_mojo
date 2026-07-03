# Stage 12c5w – Compilerreparatur und vollständige Eingabesemantik

## Ausgangspunkt

Der lokale Gesamtbuild erreichte `src/main.mojo`, brach aber beim Import von
`src/reta_mojo/output_modes.mojo` ab:

```text
output_modes.mojo:239:9: error: unexpected token in expression
    for alias in spec.aliases:
        ^
```

`alias` ist in Mojo ein Deklarationsschlüsselwort und daher kein zulässiger
lokaler Schleifenbezeichner. Die wiederholte Crashpad-Ausgabe ist unabhängig
davon: Die im Log jeweils anschließend als `Erzeugt:` gemeldeten Programme
wurden erfolgreich kompiliert; Crash-Reporting war lediglich nicht verfügbar.

## Compilerreparatur

`_alias_matches` iteriert die Aliasliste nun mit einem expliziten
`alias_index`. Das vermeidet das reservierte Wort und hält zugleich den
Ownership-Zugriff auf `List[String]` eindeutig. `scripts/test_stage12c5w.sh`
baut als erstes `src/main.mojo` selbst. Dadurch wird künftig der vollständige
von `reta_mojo/__init__.mojo` reexportierte Importgraph geprüft, bevor kleinere
Modultests einen falschen Erfolg vortäuschen können.

Der Fehler ist als `MOJO-FIXED-040` im zentralen Defektkatalog erfasst.

## Vollständiger Besitzer von `input_semantics.py`

Die bisherige native Datei deckte nur CLI-Tokenisierung und eine verkürzte
Vokabularoberfläche ab. Stage 12c5w besitzt nun die vier öffentlichen
Python-Klassen vollständig als typisierte Mojo-Strukturen:

- `RowRangeSyntax` und `RowRangeSyntaxSnapshot`;
- `PromptVocabulary` mit allen **18** Feldern;
- `PromptVocabularyBuilder`;
- `InputBundle` und `InputBundleSnapshot`.

`RowRangeSyntax` umfasst den Mehrfachpräfix, das historische
Komma-Split-Muster, kompakte Kommalisten, Integer- und Bruchbereichsmuster,
direkte Tokenklassifikation und reproduzierbare Snapshots. Die bestehende
sichere native Bereichsgrammatik bleibt der ausführende Besitzer; Python-`eval`
wird nicht übernommen.

## Reproduzierbarer Vokabularkatalog

`tools/generate_input_semantics_catalog.py` materialisiert den dynamisch aus
Program-, Schema- und i18n-Objekten gebauten Referenzvertrag nach
`assets/input_semantics_catalog.tsv`. Das Laufzeitmodul lädt diesen Katalog
rein nativ und benötigt weder `std.python` noch einen Unterprozess.

```text
Katalogdatensätze:                 17.741
Hauptparameter:                         7
Spaltenoptionen:                     4.160
spalten_dict-Schlüssel:                 84
Ausgabeparameter:                       14
Kombinationsparameter:                   3
Zeilenparameter:                        15
Befehle:                               386
Befehle2:                              385
erlaubte gebrochene Zahlen:             21
```

Listenreihenfolgen, Duplikate und die beiden leeren Domänen `Licht`/`licht`
bleiben erhalten. Python-Setfelder werden für das native Asset deterministisch
sortiert. Weil die Referenz bereits beim Aufbau von `haupt_for_neben` über ein
Set iteriert, re-execiert sich der Generator vor dem Import mit
`PYTHONHASHSEED=0`. Zwei getrennte Erzeugungsläufe sind dadurch byteidentisch.
Dieser zunächst entdeckte Generatorfehler ist als `TEST-FIXED-023`
dokumentiert.

Zusätzlich prüft die portable Source-Suite ein vorhandenes Concat-Probe-ELF nur noch dann, wenn eine vollständige lokale Mojo-Laufzeit gefunden wird. Ein aus einem anderen Rechner übernommenes, wegen fehlender `libKGENCompilerRTShared.so` nicht startbares Binary erzeugt damit einen begründeten Skip statt eines falschen Quellfehlers (`TEST-FIXED-024`).

Die FHS-Installationsprobe deckte außerdem auf, dass `mojo-runtime-exec` nach der Installation seinen Frischeprüfer nicht fand. `install.sh` kopiert nun `check_mojo_binary_freshness.sh` und `current_source_id.sh` mit. Der installierte Launcher erreicht wieder die eigentliche Laufzeitsuche, und `input_semantics_catalog.tsv` wird explizit unter `share/reta/assets` sowie über den privaten Assetsymlink geprüft (`TEST-FIXED-025`).

Ein zweiter Portabilitätsfehler lag im Test selbst: Das FHS-Layout hing von zufällig vorhandenen Dateien in `target/bin` ab. `install.sh` akzeptiert jetzt `RETA_TARGET_DIR`; der Layouttest verwendet drei isolierte ausführbare Platzhalter und prüft optionale Compilerziele getrennt. Damit läuft er auch aus einem echten source-only Archiv (`TEST-FIXED-026`).

Der Unicode-Audit der neuen `RowRangeSyntax` fand außerdem zwei Python-Zeichenoperationen, die noch byteweise übertragen waren: `text[1:]` und Regex-Escaping eines benutzerdefinierten Mehrfachpräfixes. Beide Pfade iterieren nun `codepoint_slices()`. Der native Test deckt `is_row_range_token("ä{1,2}")` und `RowRangeSyntax("ä")` ab (`MOJO-FIXED-041`).

## Diagnose und Parität

`src/schema_main.mojo --mojo-input-snapshot` gibt die elf öffentlichen
Snapshotzähler sowie Mehrfachpräfix, Komma-Muster und Builderverfügbarkeit in
einem stabilen `key=value`-Format aus. Der öffentliche `bin/reta-mojo`-Launcher
leitet diesen neuen Schema-Befehl nun ebenfalls korrekt weiter
(`MOJO-FIXED-042`). Das Paritätsskript vergleicht die Werte exakt mit
`LibRetaPrompt` unter dem gewählten Python-/PyPy3-Interpreter.

Der lokale Compiler- und Paritätslauf lautet:

```bash
scripts/test_stage12c5w.sh
```

Er führt in dieser Reihenfolge aus:

1. vollständiger `src/main.mojo`-Build als Reproducer des gemeldeten Fehlers;
2. nativer `test_input_semantics.mojo`;
3. Build der Schema-Diagnose und Python/PyPy3-Snapshotparität;
4. Source-, Matrix-, Metrik-, Defekt-, Archiv- und Boundary-Gates.

In der Erstellungsumgebung ist kein offizieller Modular-Mojo-Compiler
installiert. Native Kompilierung wird deshalb nicht vorgetäuscht; alle
compilerunabhängigen Prüfungen werden hier ausgeführt und der vollständige
Compilerlauf ist im Stage-Skript vorbereitet.

Die fokussierte compilerunabhängige Suite besteht mit **58 bestandenen Tests** und einem begründeten Skip für ein fremd gebautes, lokal nicht startbares Mojo-Probe-ELF. Der gesamte portable Source-Testbestand besteht mit **134 bestandenen Tests** und demselben begründeten Skip. Der zentrale Defektkatalog ist mit **92/92** Einträgen konsistent; **19** Punkte bleiben für die spätere Python-/PyPy3-Bereinigung.

## Metriken

```text
vollständig nativ/generiert:       69/92 = 75,0 %
mindestens teilweise portiert:     83/92 = 90,2 %
angegriffene Referenzzeilen:        38.174/48.831 = 78,2 %
vollständig native Referenzzeilen:  30.672/48.831 = 62,8 %
produktive Mojo-Zeilen in src/:     55.849
produktive Mojo-Zeilen reta_mojo/:  51.577
aktive std.python-Brücken:               0
```
