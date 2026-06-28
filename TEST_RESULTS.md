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
| `test_generated_parity.mojo` | 5 | bestanden |
| `test_number_theory.mojo` | 6 | bestanden |
| `test_output_modes.mojo` | 4 | bestanden |
| `test_presheaves.mojo` | 2 | bestanden |
| `test_row_ranges.mojo` | 7 | bestanden |
| `test_topology.mojo` | 5 | bestanden |
| `test_universal.mojo` | 2 | bestanden |
| **Gesamt** | **41** | **41 bestanden, 0 fehlgeschlagen, 0 übersprungen** |

Die fünf generierten Paritätstests enthalten intern hunderte Einzelvergleiche gegen aus Python erzeugte Erwartungswerte.

## Kompatibilitäts-Launcher

```bash
./scripts/check_compat_parity.sh
```

Für den geprüften realen Tabellenaufruf waren direkte Python-Ausgabe und Ausgabe über den Mojo-Kompatibilitäts-Launcher bytegleich. Beide Dateien hatten 2.003 Bytes und denselben SHA-256-Wert:

```text
8b3a3ebd821ad9399b4978b2c7f6c5e3500ed0762055b51da7e38839bab2826a
```

## Unveränderte Python-Baseline

```bash
cd python_reference
python -m unittest discover -s tests
```

Ergebnis des hochgeladenen Bestands:

```text
Ran 70 tests
FAILED (failures=3, skipped=1)
```

Die drei Fehler sind bereits in der Python-Referenz vorhanden:

1. Zweimal wird eine erste `dataDict`-Größe von 554 erwartet, tatsächlich sind es 556.
2. Ein Test erwartet den älteren Orchestrierungsschritt `load_/religion_table`, der Snapshot enthält `load_religion_table`.

Diese Erwartungen wurden nicht verändert, um die Referenz als Referenz zu erhalten.

## Nachprüfung des Installationsfixes

- Offizieller Modular-Compiler projektlokal mit `scripts/setup_mojo.sh` installiert: `Mojo 1.0.0b2 (2cf4d08a)`
- 41/41 native Tests erneut bestanden
- Native Beispielbefehle, Architekturkatalog und Kompatibilitätslauncher erneut ausgeführt
- Build von `reta-mojo-native` und `reta-mojo-compat-bin` erfolgreich
- Falsches gleichnamiges `mojo` im `PATH` wird mit verständlicher Diagnose zurückgewiesen
