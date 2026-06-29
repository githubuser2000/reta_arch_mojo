# Stage 10k – mehrbereichige Abstandsberechnung vollständig nativ

Stage 10k entfernt die atomare Python-Grenze für `abstand` und `abstandPrim` mit mehr als zwei Zahlenangaben. Die bisherige Mojo-Implementierung besaß nur die normale Zweibereichsform; drei oder mehr Bereiche wurden im One-shot- und interaktiven Dispatch absichtlich an `prompt_execution.py` zurückgegeben.

## Übernommene Referenzsemantik

Die Python-Referenz bildet jeden erkannten Zahlenbereich zunächst auf ein `frozenset[int]` ab und vereinigt diese Werte einzeln mit einem äußeren `set`. Für die sichtbare Ausgabe ist deshalb nicht nur die mathematische Menge relevant, sondern die konkrete CPython-3.13-Tabellenordnung:

- der vollständige Prompt-Tokenstrom wird vor der Bereichsauswahl wie ein `set[str]` geordnet,
- jeder expandierte Bereich erhält den exakten CPython-`frozenset`-Hash,
- die äußeren Bereiche folgen der Singleton-`set_merge`-Einfügungs- und Resize-Reihenfolge,
- `zahlenBereiche - maxMenge(zahlenBereiche)` erzeugt logisch dieselben Frozensets, aber normalerweise eine zweite Set-Tabelle mit eigener Slotreihenfolge,
- bei stark unterschiedlichen Mengengrößen wird wie in CPython die Copy-and-discard-Strategie gewählt,
- die Ergebniswörterbücher behalten die erste Schlüsselposition, überschreiben bei späteren Treffern aber den Nutzwert.

Diese Besonderheiten erklären die historisch nicht offensichtlichen Ausgaben von Befehlen wie

```text
abstand 1-2 5-6 10-11
abstand 1 2 3 4 5 6 7 8 9
abstand 1-3 5 8-9
```

Sie sind nun nicht angenähert sortiert, sondern reproduzieren die Referenzreihenfolge einschließlich der Überschreibungen.

## Native Typen und Algorithmen

`prompt_runtime.mojo` besitzt nun einen typisierten `_PromptDistanceRange` mit

- ursprünglichem Bereichstext,
- expandierten ganzzahligen Werten,
- CPython-kompatiblem Frozenset-Hash.

Die neue lokale Set-Simulation bildet lineare Probes, Perturbation, Resize, saubere Re-Insertion, Duplikaterkennung und beide Difference-Strategien nach. Negative Werte werden über die bereits vorhandene vorzeichenfähige Integer-Setordnung verarbeitet.

`distance_lines` akzeptiert jetzt beliebig viele stabile Zahlenbereiche. Dies gilt für

- normale Differenzen,
- primfaktorisierte Differenzen,
- doppelte Bereichsausdrücke,
- gemischte Einzelzahlen und Bereiche,
- große Bereiche,
- äußere Set-Resizes,
- den Copy-and-discard-Pfad,
- die historische Fehlermeldung bei zu wenigen Argumenten.

Die `len(command.words) == 3`-Sperren wurden sowohl im interaktiven als auch im One-shot-Dispatch entfernt.

## Besitz- und Paritätsnachweise

- 30/30 Prompt-Runtime-Unit-Tests bestanden
- normale und primfaktorisierte Dreifachbereiche getestet
- doppelte Bereiche und gemischte Bereichsgrößen getestet
- sechs und neun Einzelbereiche prüfen beide CPython-Difference-Pfade
- großer Bereich prüft die größenabhängige Strategieauswahl
- 8/8 vollständige Promptausgaben gegen `PYTHONHASHSEED=0` bytegleich
- 2/2 isolierte One-shot-Klassen ohne Python-Datei und ohne `reta-native`-Kindprozess
- vollständiger `scripts/test_stage10.sh`-Regressionslauf mit Exitcode 0
- alle 9/9 regulären Mojo-Executables aus dem finalen Quellstand gebaut
- `check_build_layout.sh` sowie die nach dem Vollbuild erneut ausgeführten 30/30 Runtime-, 8/8 Byte- und 2/2 Besitzprüfungen bestanden

## Weiter offene Besitzgrenze

- echte `v n/m`-Vielfache mit Zähler größer 1, für die die unveränderte Python-Referenz selbst `IndexError` auslöst,
- seltene hintere Promptzweige außerhalb der stabilen Abstandsgrammatik,
- verbleibende Rich- und kombinierte HTML-Metadatenfälle,
- vollständige i18n-Laufzeit außerhalb des Promptvokabulars.
