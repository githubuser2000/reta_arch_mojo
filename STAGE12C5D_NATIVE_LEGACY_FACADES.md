# Stage 12c5d – Native Legacy-Fassaden `center` und `lib4tables`

Stand: 2. Juli 2026

## Ziel

Diese Stage schließt zwei historische Python-Kompatibilitätsoberflächen, deren
Fachlogik bereits auf Architekturmodule verteilt war:

- `python_reference/libs/center.py`
- `python_reference/libs/lib4tables.py`

Die öffentlichen Namen werden nun ohne Python-Import durch typisierte Mojo-
Fassaden angeboten. Die eigentlichen Besitzer bleiben Zeilenbereichs-,
Arithmetik-, Konsolen-, Ausgabesyntax- und Zahlentheoriemodule.

## Neue native Besitzer

- `src/reta_mojo/legacy_center.mojo`
- `src/reta_mojo/legacy_lib4tables.mojo`
- `src/reta_mojo/unicode_digits.mojo`

`legacy_center.mojo` bildet 27 aktive Python-Funktionen und die sechs
`nPmEnum`-Gruppen ab. `legacy_lib4tables.mojo` bildet die vollständige
18-Namen-`__all__`-Oberfläche ab. Der dynamische Python-Rückgabetyp von
`isPrimMultiple(..., dontReturnList=False)` wird in Mojo als separate typisierte
Funktion `isPrimMultipleMatches()` angeboten.

## Reproduzierbare Text- und Unicode-Daten

Die Hilfeinhalte werden aus den eingefrorenen Referenzdokumenten erzeugt:

- `tools/generate_legacy_help_assets.py`
- `assets/reta_help_de.txt`
- `assets/reta_help_en.txt`
- `assets/reta_prompt_help_de.txt`
- `assets/reta_prompt_help_en.txt`

Python `str.isdigit()` erkennt mehr als ASCII-Ziffern. Die 808 akzeptierten
Codepoints des eingefrorenen Python-Vertrags liegen in 83 Bereichen:

- `assets/unicode_digit_ranges.tsv`
- `tools/generate_unicode_digits.py`
- `src/reta_mojo/unicode_digits.mojo`

Damit erkennen Python und die neue Mojo-Fassade unter anderem `2`, `٢`, `²`
und `⑵`, nicht aber `四`.

## Bewusste dokumentierte Abweichung

`PY-OPEN-003` bleibt eine absichtliche Mojo-Korrektur: Die Python-
Dictionary-Invertierung verwirft bei gemeinsamem Integerwert einen früheren
Quellschlüssel. Mojo bewahrt beide. Der Fassaden-Paritätstest erwartet deshalb
alle sonstigen Bytes identisch und prüft diese eine bekannte Korrektur separat.

## Gates

Die Stage wird durch folgende Schichten geprüft:

- native Modultests für beide Fassaden,
- ein gemeinsamer Mojo-Probeprozess,
- Python↔Mojo-Parität für Funktionsoberfläche und vier Hilfetexte,
- regenerierbare Unicode- und Hilfeassets,
- Portierungsmatrix-Ownership,
- Boundary-, Ledger- und Source-only-Archivgates.

Die finalen Messergebnisse stehen in `TEST_RESULTS.md` und `STATUS.md`.

## Ergebnis

```text
native neue Modultests:                   12/12
angrenzende fokussierte native Tests:     26/26
Python↔Mojo-Paritätsgruppen:                5/5
Source-/Ownership-/Boundary-/Archivtests: 15/15
Fehlerkatalog:                            62/62
Python-Bereinigungspunkte:                17
```

Portierungsstand nach dieser Stage:

- vollständig nativ oder generiert: **51/92 = 55,4 %**,
- mindestens teilweise portiert: **82/92 = 89,1 %**,
- gewichteter Quellzeilenstand: **ca. 72,0 %**,
- nativer Mojo-Quellcode in `src/`: **46.615 Zeilen**,
- davon in `src/reta_mojo/`: **43.318 Zeilen**.
