# Stage 12c4r – zentraler Fehlerkatalog und native echte Bruchvielfache

## Ziel

Diese Stufe macht zwei bisher getrennte Arbeitsströme dauerhaft überprüfbar:

1. Alle während der Portierung gefundenen Fehler und fraglichen Altverträge
   werden in einem zentralen, maschinenlesbaren Katalog geführt.
2. Echte Bruchvielfache wie `universum v2/3` erhalten in Mojo eine sichere
   Semantik, obwohl der eingefrorene Python-/PyPy3-Originalcode dabei abstürzt.

Der Python-Baum bleibt während der funktionalen Transpilierung grundsätzlich
unverändert. Dadurch bleibt er als historische Referenz reproduzierbar. Eine
bewusste Mojo-Korrektur wird nicht als scheinbare Parität ausgegeben, sondern
mit Reproduktion, Abweichungsvertrag und späterem Python-Arbeitsauftrag erfasst.

## Zentraler Fehlerkatalog

Maßgebliche Quelle ist:

```text
KNOWN_DEFECTS.json
```

Die vollständige lesbare Fassung und die gezielte spätere Python-Arbeitsliste werden daraus reproduzierbar erzeugt:

```bash
python3 tools/check_known_defects.py --write
python3 tools/check_known_defects.py
# erzeugt/prüft KNOWN_DEFECTS.md und PYTHON_CLEANUP_BACKLOG.md
```

`tests/test_known_defects.py` erzwingt unter anderem:

- eindeutige Fehler-IDs;
- gültige Python- und Mojo-Statuswerte;
- vorhandene Belege;
- einen späteren Python-Korrekturauftrag für jeden offenen oder fraglichen
  Python-Fehler;
- Aktualität von `KNOWN_DEFECTS.md` gegenüber dem JSON-Katalog.

Der Katalog erfasst alle reproduzierbaren Fehler, die Verhalten, Ausgabe, Ownership, Portabilität oder die Verlässlichkeit der Tests beeinflussen. Kurzlebige Tipp- und Syntaxfehler einer noch nicht lauffähigen Zwischenänderung werden nicht einzeln protokolliert, außer sie zeigen eine eigenständige Vertrags- oder Architekturlücke. Jeder bestätigte oder plausible Fehler im Python-/PyPy3-Original muss dagegen vor einer absichtlichen Mojo-Abweichung in den Katalog und damit in `PYTHON_CLEANUP_BACKLOG.md` aufgenommen werden.

Die ID-Gruppen unterscheiden ausdrücklich:

| Präfix | Bedeutung |
|---|---|
| `PY-OPEN-*` | bestätigter Fehler im Python-Original, noch offen |
| `PY-CAND-*` | wahrscheinlich fehlerhafte oder mindestens zu entscheidende Python-Eigenheit |
| `PY-FIXED-*` | bereits im Python-Baum behobener historischer Fehler |
| `MOJO-FIXED-*` | während der Portierung entstandener und behobener Mojo-Fehler |
| `QUIRK-*` | bewusst kompatibel nachgebildete historische Eigenheit |

## Bestätigter Python-Fehler PY-OPEN-002

Reproduktion:

```bash
PYTHONHASHSEED=0 python3 python_reference/rpb 'universum v2/3'
```

Der Originalcode beendet sich mit:

```text
IndexError: string index out of range
```

Auslöser ist `zeiln1234create()` in
`python_reference/reta_architecture/prompt_execution.py`. Für einen reinen
Bruchbefehl ist `zahlenReiheKeineWteiler` leer, wird aber ohne Längenprüfung an
Index `0` und `-1` gelesen.

Eine bloße Längenprüfung wäre noch keine fachliche Reparatur. Der nachfolgende
Altalgorithmus baut echte Bruchvielfache mit dem globalen Vorrat
`gebrochenErlaubteZahlen` auf. Dieser Vorrat kennt nicht die verschiedenen
physischen Formen der vier Bruch-CSV-Dateien. Dadurch kann er beispielsweise
für das Universum einen Zähler erzeugen, für den in der Universum-CSV gar keine
Spalte existiert.

## Korrigierter Mojo-Vertrag

Für ein positives echtes Bruchvielfaches `v n/m` werden beide Achsen unabhängig
vervielfacht:

```text
Zähler: n, 2n, 3n, ...
Nenner: m, 2m, 3m, ...
Ergebnis: kartesisches Produkt beider Achsen
```

Die Achsen enden nicht an einem globalen Zahlenvorrat, sondern an der realen
CSV-Form der genau einen ausgewählten Bruchdomäne:

| Domäne | CSV-Form | gültige Zähler | gültige Nenner |
|---|---:|---:|---:|
| Emotion | 7 × 7 | 2–8 | 1–7 |
| Strukturgröße | 16 × 16 | 2–17 | 1–16 |
| Galaxie/Motive | 21 × 21 | 2–22 | 1–21 |
| Universum | 21 × 19 | 2–20 | 1–21 |

Beispiel `universum v2/3`:

```text
Zähler:  2,4,6,8,10,12,14,16,18,20
Nenner:  3,6,9,12,15,18,21
```

Zusätzlich werden aus dem erzeugten Raster dieselben semantischen Projektionen
gebildet wie bei gewöhnlichen Bruchangaben:

- ganzzahlige Quotienten auf die `n`-Achse;
- reziproke ganzzahlige Quotienten auf die `1/n`-Achse;
- gleiche Zähler/Nenner auf die Universum-Gleichheitsachse;
- alle vorhandenen Zählergruppen auf die jeweilige Bruch-CSV.

Der korrigierte Plan besitzt für `universum v2/3` 13 native Aufrufe:

- eine Ganzzahlachse;
- eine Reziprokachse;
- zehn Bruchzählerachsen von 2 bis 20;
- eine Gleichheitsachse für 6, 12 und 18.

## Konservative Ownership-Grenze

Noch nicht zusammengelegt werden:

```text
universum motive v2/3
universum v1/2,2/3
```

Der erste Befehl verlangt gleichzeitig zwei verschieden große CSV-Rechtecke.
Der zweite kombiniert die bis 1023 laufende historische `1/n`-Vielfachachse mit
einem datenbegrenzten echten Bruchraster. Beide Fälle bleiben atomarer
Python-Fallback, bis ein eigener Vertrag festgelegt ist.

Ein Ausdruck mit ausschließlich ausgeschlossenen Bruchvielfachen wird ebenfalls
nicht nativ besessen. Damit erzeugt Mojo nie aus einer rein negativen Menge
unbeabsichtigt eine positive Grundmenge.

## Prüfungen

Die neue Prüfung

```bash
scripts/check_prompt_true_fraction_multiples.sh
```

bestätigt gleichzeitig:

1. Der eingefrorene Python-Code reproduziert weiterhin genau den dokumentierten
   `IndexError`.
2. Die vier CSV-Dateien besitzen weiterhin die erwarteten Rechteckformen.
3. Kompakte und ausgeschriebene Vielfachsyntax liefern denselben Mojo-Plan.
4. Alle vier Domänen werden an ihren realen Grenzen abgeschnitten.
5. Ganzzahl-, Reziprok- und Gleichheitsprojektionen sind vorhanden.
6. Mehrdomänen- und gemischte `1/n`+`n/m`-Fälle bleiben Fallback.

Die Mojo-Planersuite enthält zusätzlich genaue Token- und Reihenfolgeassertionen.

## Spätere Python-/PyPy3-Bereinigung

Nach Abschluss der funktionalen Transpilierung wird `PY-OPEN-002` im
Originalcode in einem eigenen Schritt behoben:

1. leere `zahlenReiheKeineWteiler` vor Indexzugriffen behandeln;
2. die wirkungslosen Vergleiche `==` in den vermeintlichen Klammerzuweisungen
   beseitigen;
3. die vier Bruchdomänenformen explizit modellieren;
4. Zähler- und Nennerachsen je Domäne begrenzen;
5. denselben korrigierten Sollvertrag als Python- und Mojo-Test verwenden;
6. erst danach den Katalogeintrag von `open` auf `fixed` setzen.

Damit geht der Fehler nicht verloren, obwohl Mojo ihn bereits heute korrekt
umgeht.

## Gleichzeitig behobener Testinfrastrukturfehler

Die bisherige Reziprok-Paritätsprüfung startete die gesamte 29-Test-Suite nur,
um fünf serialisierte Pläne auszugeben. Obwohl alle Assertions beendet waren,
konnte der Mojo-Prozess beim Teardown hängen bleiben und musste über ein
Zeitlimit abgeräumt werden. Das ist nun als `MOJO-FIXED-005` dokumentiert.

`scripts/check_prompt_mixed_reciprocal_parity.sh` baut stattdessen die kleine
Probe `tests/prompt_mixed_reciprocal_probe.mojo`. Sie gibt ausschließlich die
fünf benötigten Pläne aus, vergleicht sie bytegenau mit Python und beendet sich
deterministisch.
