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
| `test_row_ranges.mojo` | 7 | bestanden |
| `test_schema_catalog_parity.mojo` | 2 | bestanden |
| `test_topology.mojo` | 5 | bestanden |
| `test_universal.mojo` | 2 | bestanden |
| **Gesamt** | **59** | **59 bestanden, 0 fehlgeschlagen, 0 übersprungen** |

Die generierten Paritätstests enthalten intern hunderte Einzelvergleiche gegen aus Python erzeugte Erwartungswerte. Der Schemaabgleich umfasst alle 86 Hauptaliase, 1.355 Unterparameter-Aliase, 428 kanonischen Paare und 838 direkten Spaltenverknüpfungen. Die Eingabetests prüfen zusätzlich Abschnittszustand, Klammer-Kommas, Polarität, reale Aliasauflösung und das native Prompt-Vokabular.

## Neuer vollständig nativer CLI-Pfad

```bash
./bin/reta-mojo --mojo-parse-cli \
  -spalten '--religionen=sternpolygon,-gleichfoermigespolygon' \
  -zeilen '--vorhervonausschnitt=1-9,-3'
```

Relevantes Ergebnis:

```text
Auswahl: Religionen / Sternpolygon negativ=False
  Spalten: [0, 6, 36]
Auswahl: Religionen / gleichförmiges_Polygon negativ=True
  Spalten: [16, 37]
Positive Spalten: [0, 6, 36]
Negative Spalten: [16, 37]
```

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

Aktuell erneut ausgeführt:

```text
Ran 70 tests
FAILED (failures=3, skipped=1)
```

Die drei Fehler sind bereits in der Python-Referenz vorhanden:

1. Zweimal wird eine erste `dataDict`-Größe von 554 erwartet, tatsächlich sind es 556.
2. Ein Test erwartet den älteren Orchestrierungsschritt `load_/religion_table`, der Snapshot enthält `load_religion_table`.

Diese Erwartungen wurden nicht verändert, um die Referenz als Referenz zu erhalten.

## Installation und Build

- Offizieller Modular-Compiler projektlokal geprüft: `Mojo 1.0.0b2`
- `scripts/setup_mojo.sh` bevorzugt Python 3.14 und akzeptiert 3.10–3.14
- 59/59 native Tests bestanden
- native CLI, Schema-CLI und Kompatibilitätslauncher erfolgreich gebaut
- nativer Primzahl-, Schema-, Vokabular- und CLI-Normalisierungsaufruf ausgeführt
- falsches gleichnamiges `mojo` im `PATH` wird mit verständlicher Diagnose zurückgewiesen

Die Ausführungsumgebung dieser Erstellung enthielt Python 3.13.5. Ein zusätzlicher Download von Python 3.14 für einen isolierten Installationslauf war wegen fehlender DNS-Auflösung nicht möglich; die Versionsprüfung und Auswahl im Setup-Skript sind dennoch explizit auf 3.14 ausgelegt.
