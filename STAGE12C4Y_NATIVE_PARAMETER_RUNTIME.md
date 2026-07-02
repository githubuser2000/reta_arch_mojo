# Stage 12c4y – eigenständiger nativer Parameter-Runtime-Besitzer

## Ziel

Stage 12c4y löst die produktive Parameterplanung aus dem monolithischen
`native_reta_cli.mojo` und gibt dem Python-Besitzer
`reta_architecture/parameter_runtime.py` eine eigene typisierte Mojo-Grenze.
Der wirksame native Vertrag umfasst:

- Sprachwahl,
- Ausgabeart,
- Einzel- und Mehrfachbreiten,
- Zeileninklusion und -exklusion,
- physische und generierte Spaltenauswahl,
- explizite Spaltenreihenfolge,
- Modal-, Meta-, Bruch- und Kombinationsanforderungen,
- dynamische Obergrenzen für absolute sowie generierte Zeilenbereiche.

Die historische Python-Datei umfasst 894 Zeilen. Sie wird konservativ als
**weitgehend nativ** gezählt: Der produktive Tabellenplan und seine
Obergrenzenlogik besitzen einen nativen Besitzer; seltene Diagnose-, Hilfe-
und mutable Legacy-Objektseiten bleiben am atomaren Kompatibilitätsrand.

## Neuer Besitzer

`src/reta_mojo/parameter_runtime.mojo` enthält:

- `ParameterRuntimeBundle`,
- `ParameterRuntimePlan`,
- `build_parameter_runtime_plan`,
- `UpperLimitArgument`,
- `upper_limit_values_for_argument`,
- `upper_limit_from_arguments`,
- `AppliedUpperLimit`,
- `apply_upper_limit_argument`,
- `parameter_runtime_effective_highest`.

`native_reta_cli.mojo` importiert diesen Besitzer und hält nur noch den dünnen
produktiven Adapter `build_native_reta_plan`. Die vorher dort eingebettete
zweite Planimplementierung samt Alias-, Zeilen-, Breiten- und
Spaltenhilfsfunktionen wurde entfernt. Dadurch sinkt der monolithische
CLI-Besitzer auf ungefähr die Hälfte seiner vorherigen Größe und es gibt nur
noch eine native Quelle für den Parameterplan.

## Semantik

Die Tests decken insbesondere historische Randregeln ab:

- `--breite=0` sperrt spätere positive Einzelbreiten,
- jede neue `--breiten=`-Angabe ersetzt die vorherige Liste,
- nichtdezimaler und negativer Mehrfachbreiteninhalt wird verworfen,
- explizite Reihenfolge bleibt von semantischer Spaltenauswahl getrennt,
- ein ausschließlich generierter Plan zieht nicht still Spalte 0 hinzu,
- `--oberesmaximum` wirkt mutierend, `--vorhervonausschnitt` nur als
  vorberechnete Obergrenzenquelle,
- absolute `vN`-Selektoren erweitern die native Tabellenobergrenze.

## Python-Originalkandidat PY-CAND-009

`upper_limit_values_for_argument` ruft für `--vorhervonausschnitt` einen
Mengenparser auf, addiert eins und klemmt danach jeden Wert auf mindestens
1024. Für `v2-4` entstehen dadurch 685 Listenelemente, davon 682 identische
`1024`-Werte. Der öffentliche Rückgabewert übernimmt außerdem die
Implementierungsreihenfolge der vorausgehenden Integer-Menge, obwohl der
produktive Aufrufer nur `max()` benötigt.

Mojo bewahrt Anzahl, Multiset und resultierende Obergrenze exakt, gibt den
Strom aber deterministisch in der eigenen Bereichsparser-Reihenfolge aus. Ein
späterer gemeinsamer Sollvertrag sollte direkt eine einzelne Obergrenze oder
eine deduplizierte, fachlich sortierte Menge liefern.

## Wiederverwendbare vollständige `--alles`-Referenz

Ein vollständiger Python-Lauf dauert auf dem Nutzerrechner ungefähr eine
Stunde. Er muss nicht für jede Mojo-Stage erneut ausgeführt werden. Neu sind:

- `scripts/create_full_all_reference_bundle.sh`,
- `scripts/check_full_all_against_reference.sh`,
- `RETA_FULL_ALL_REFERENCE` in `scripts/check_full_all_parity.sh`,
- `FULL_ALL_REFERENCE_WORKFLOW.md`.

Das Referenzpaket enthält HTML, SHA-256, Größe, Zeilenzahl, Tabellenform,
Pythonversion sowie Laufzeit-/Speichermetadaten. Solange Python-Daten,
Referenzrenderer und der vollständige Befehlsvertrag unverändert bleiben,
wird nur die schnelle native Seite neu erzeugt und gegen dieses Paket geprüft.

## Validierung

```text
native Parameter-Runtime-Tests:          8/8
bestehende produktive CLI-Tests:        30/30
Python↔Mojo-Obergrenzenfälle:            6/6 semantisch
rohe Reihenfolge exakt:                  5/6
Source-/Ownership-Tests:                 3/3
aktive std.python-Brücken:                 0
```

Der eine nicht bytegeordnete Fall ist ausschließlich `v2-4`; Multiset,
Anwendungsflag und produktive Maximalwirkung stimmen vollständig überein.

## Fortschrittswirkung

- vollständig native/generierte Originaldateien bleiben konservativ bei
  **45/92 = 48,9 %**,
- mindestens teilweise portierte Originaldateien steigen auf
  **75/92 = 81,5 %**,
- gewichteter Quellzeilenersatz steigt konservativ von etwa **67,7 %** auf
  etwa **68,8 %**,
- funktionale Oberfläche bleibt **96–98 %**.

Der vollständige Dateibesitz steigt absichtlich noch nicht, weil die seltenen
Legacy-Seiten der Python-Datei nicht als ersetzt ausgegeben werden.

## Reproduzierbare Befehle

```bash
scripts/check_parameter_runtime_parity.sh
scripts/test_stage12c4y.sh
RETA_FULL_ALL_HTML=/pfad/python-all.html \
  scripts/create_full_all_reference_bundle.sh /pfad/reta-python-full-all.tar.bz2
RETA_FULL_ALL_REFERENCE=/pfad/reta-python-full-all.tar.bz2 \
  scripts/check_full_all_parity.sh
```

## Korrektur der detaillierten Besitzmatrix

Die Stage-Prüfung entdeckte `TEST-FIXED-007`: Der Generator von
`PORTING_MATRIX.md` kannte die in 12c4t, 12c4u und 12c4x bereits nachgewiesenen
Completion- und `i18n.words`-Besitzer nicht. Die zusammenfassenden
Fortschrittszahlen waren manuell fortgeschrieben, die detaillierten Zeilen
fielen bei jeder Regeneration jedoch wieder auf `Python-Referenz/Bridge`
zurück.

Der Generator enthält jetzt explizite Einträge für alle zehn betroffenen
Dateien. `tests/test_porting_matrix_ownership.py` prüft sowohl die
Generatorquelle als auch die tatsächlich regenerierte Markdownmatrix, damit
ein späterer Generatorlauf keinen bereits erreichten Besitz mehr verlieren
kann.


## Speicherbegrenzter Volltabellenvergleich

`TEST-FIXED-008` ersetzt den bisherigen Objektbaumvergleich der beiden
25-MiB-HTML-Dateien durch einen kompakten Parser. Pro Zelle bleiben nur drei
SHA-256-Digests für Rohmarkup, dekodierten Text und semantische Normalform im
Speicher. Nur bei tatsächlichen Abweichungen werden die wenigen betroffenen
Zellen für eine Diagnose erneut gelesen.

Der Parser bewahrt ausdrücklich die historische Behandlung verschachtelter
Tabellen; der etablierte Vollvertrag bleibt **198 Zeilen / 149.356 Zellen**.
Auf dem aktuellen Vollbestand sank der Spitzenspeicher des Vergleichs von etwa
553 MiB auf etwa 328 MiB.
