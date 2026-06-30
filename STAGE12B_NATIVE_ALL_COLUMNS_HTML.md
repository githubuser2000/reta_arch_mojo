# Stage 12b – native `--alles`-Spaltenauswahl und `generate_html`

Stage 12b entfernt die letzte Renderer-/HTML-Laufzeitbrücke. Der historische
Generator startete für seine Mitteltabelle einen Python-Kindprozess mit

```text
reta -spalten --alles --breite=0 -ausgabe --art=html --onetable --nocolor
```

Nun wird derselbe Plan im laufenden Mojo-Prozess an `run_native_reta` übergeben.
`generate_html_main.mojo` importiert weder `std.python` noch `std.subprocess`.

## Reproduzierbarer `--alles`-Plan

`--alles` ist kein einfaches Intervall. Die Python-Referenz faltet zwölf
historische Buckets zusammen. `scripts/generate_all_columns_plan.py` extrahiert
deren bereits aufgelöste interne Werte mit `PYTHONHASHSEED=0` und erzeugt
`assets/all_columns_plan.tsv`.

| Bucket | Einträge |
|---|---:|
| physische Spalten | 556 |
| Modallogikpaare | 46 |
| PrimCSV-Auslöser | 11 |
| Galaxie-Kombi | 12 |
| Primwirkungsquellen | 7 |
| Bruchspalten Universum | 22 |
| Bruchspalten Galaxie | 22 |
| Generatorbefehle | 10 |
| Universum-Kombi | 14 |
| Bruchspalten Emotion | 22 |
| Bruchspalten Größe | 22 |
| Meta-Paare | 12 |
| **Quellwerte** | **756** |

`src/reta_mojo/all_columns.mojo` lädt diese Werte typisiert als physische
Spalten, Modal-, Meta-, Bruch- und Kombi-Anforderungen sowie Generatorbefehle.
Nach Deduplikation enthält der Plan 556 physische Spalten, 46 Modalspalten,
88 Bruchanforderungen, 26 Kombi-Anforderungen, 17 Generatorbefehle und 12
Meta-Paare.

## Referenzgrenze

Das eingefrorene Ein-Zeilen-Referenzfixture
`tests/fixtures/generate_html/middle-all-row1-de.html` wurde mit CPython und
`PYTHONHASHSEED=0` erzeugt. Es enthält zwei HTML-Zeilen mit jeweils 807 Zellen:
zwei Nummerierungszellen und 805 Daten-/Generatorspalten. Nach dem lokalen
Build vergleicht `scripts/check_html_parity.sh` die native `middle.alx`
bytegenau mit diesem Fixture.

## Tests

```bash
scripts/check_all_columns_plan.sh
scripts/test_stage12b.sh
scripts/build.sh
scripts/check_html_parity.sh
```

Die kleinen Stage-12b-Ziele prüfen Planreproduzierbarkeit, Bucketform,
Fixtureintegrität, Mojo-Loader und das Fehlen einer Laufzeitbrücke. Der große
`generate-html-native`-Build bleibt wegen der bekannten langen Mojo-Elaboration
Teil des lokalen Gesamtbuilds.

## Boundary-Stand

Nach Stage 12b verbleiben zwei explizite Laufzeitbrücken:

1. `compat_main.mojo` – allgemeine Legacy-Kompatibilität, Ziel 12e;
2. `prompt_main.mojo` – TTY-Readline/Vi/Completion und seltene Restbefehle, Ziel 12c4; Pipe-Eingabe ist seit 12c2 nativ.
