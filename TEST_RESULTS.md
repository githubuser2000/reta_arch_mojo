# Testergebnisse vom 28. Juni 2026

## Nativer Mojo-Port

Ausgeführt mit Mojo 1.0.0b2:

```bash
./scripts/test_all.sh
```

| Testdatei | Fälle | Ergebnis |
|---|---:|---|
| `test_arithmetic.mojo` | 7 | bestanden |
| `test_category_theory.mojo` | 3 | bestanden |
| `test_column_selection.mojo` | 3 | bestanden |
| `test_generated_parity.mojo` | 5 | bestanden |
| `test_input_semantics.mojo` | 6 | bestanden |
| `test_morphisms.mojo` | 4 | bestanden |
| `test_number_theory.mojo` | 6 | bestanden |
| `test_output_modes.mojo` | 4 | bestanden |
| `test_parameter_semantics.mojo` | 3 | bestanden |
| `test_presheaves.mojo` | 2 | bestanden |
| `test_prompt_runtime.mojo` | 17 | bestanden |
| `test_row_ranges.mojo` | 7 | bestanden |
| `test_schema_catalog_parity.mojo` | 2 | bestanden |
| `test_topology.mojo` | 5 | bestanden |
| `test_universal.mojo` | 2 | bestanden |
| **Gesamt** | **76** | **76 bestanden, 0 fehlgeschlagen, 0 übersprungen** |

## Prompt-Binärintegration

```bash
./scripts/test_prompt_bins.sh
```

Geprüft werden:

- `rpb prim 60`
- `prim24 29`
- `multis 12`
- 24 Zeilen von `modulo 5`
- ein per Pipe bedientes interaktives `rp`
- direkte Weitergabe von `rpb reta ...`
- bytegleiche Ausgabe von Python-Referenz und Mojo-Promptfallback für `a 2`
- Speichern und Ausführen eines Promptbefehls

Ergebnis:

```text
Prompt-Binärtests bestanden.
```

## Prompt-Parität und neue native Semantik

Die 17 Prompttests prüfen:

- historische Standardprofile von `retaPrompt`, `rp`, `rpl`, `rpb`, `rpe`
- Startparameter und Diagnosen
- Befehlsklassifikation
- native Ergebnisse von `prim`, `prim24`, `multis`, `modulo`, `abc`
- die beiden `rpe`-Umschreibungsformen
- 388 generierte Completion-Wörter
- Speichern, Nummerieren und Löschen von Prompttokens

## Reproduzierbarer Completion-Katalog

```bash
./scripts/check_prompt_catalog.sh
```

Der Generator wurde erneut ausgeführt und erzeugte bytegleich denselben Katalog mit 388 Wörtern.

## Generierte Gesamtparität

Die übrigen Tests enthalten hunderte Einzelvergleiche gegen aus Python erzeugte Erwartungswerte, darunter:

- 86 Hauptparameter-Aliase
- 1.355 Unterparameter-Aliase
- 428 kanonische Paare mit 838 direkten Spaltenverknüpfungen
- 257 Prime-Creativity-Werte
- 86 Primfaktorzerlegungen
- 44 Teilermengen
- 288 Primzahlkreuz-Prädikate
- 10 nichttriviale Bereichsausdrücke

## Kompatibilitäts-Launcher

```bash
./scripts/check_compat_parity.sh
```

Für den geprüften realen Tabellenaufruf sind direkte Python-Ausgabe und Ausgabe über den Mojo-Kompatibilitätslauncher bytegleich.

## Unveränderte Python-Baseline

```text
Ran 70 tests
FAILED (failures=3, skipped=1)
```

Die drei Fehler waren bereits im Upload vorhanden: zweimal wird eine ältere `dataDict`-Größe erwartet, einmal ein älterer Orchestrierungsname. Die Referenz wurde nicht angepasst, um rote Python-Erwartungen künstlich grün zu machen.
