# Migrationsnotizen Python → Mojo

## 1. Keine mechanische Umschrift

Im Python-Bestand wurden 1.117 unvollständig typisierte Funktionen, 89 `getattr`-Aufrufe, 50 `*args`- und 50 `**kwargs`-Stellen gefunden. Diese Dynamik wurde nicht durch ein universelles `PythonObject` im nativen Kern verdeckt. Stattdessen werden stabile Domänen explizit typisiert und noch dynamische Bereiche bleiben sichtbar an der Bridge.

## 2. Ownership und Lebensdauer

Beim Bereichsparser zeigte sich ein konkreter Unterschied: Ein `StringSlice` darf nicht weiterverwendet werden, nachdem der zugrunde liegende `String` verändert wurde. Der Mojo-Port materialisiert solche Ausschnitte deshalb vor Mutationen als besitzende `String`-Werte.

Topologische Auswahlen verwenden ebenfalls Besitzwerte. Mengen werden beim Bilden neuer Auswahlen kopiert oder transferiert; die Eingaben universeller Konstruktionen bleiben unverändert.

## 3. Bereichssyntax ohne `eval`

Die Python-Implementierung akzeptiert Mengen-/Listen-/Tupelliterale über eine dynamische Auswertung. Mojo akzeptiert dieselbe legitime Form wie `{1,2,5}`, `[1,2,5]` oder `(1,2,5)`, parst aber ausschließlich vorzeichenbehaftete Ganzzahlen. Ausführbarer Python-Code wird bewusst nicht akzeptiert.

Das ist eine Sicherheits- und Typverbesserung, keine versehentliche Abweichung.

## 4. Exakte Ganzzahlarithmetik

`moon_number()` prüft Potenzen exakt mit Ganzzahlen. Die Python-Fassung erkennt ganzzahlige Wurzeln über gerundete Fließkommawerte auf fünf Nachkommastellen. Der Mojo-Port vermeidet dadurch mögliche Rundungsfehlklassifikationen.

## 5. Homogene Rückgabetypen

Die historische Prime-Repeat-Darstellung mischt teilweise Zahlen und Zeichenketten. Mojo trennt:

- `prime_repeat_pairs()` → typisierte `(Primzahl, Anzahl)`-Paare
- `prime_repeat_labels()` → homogene `String`-Darstellung

## 6. Dictionary-Invertierung

Die Python-Fassung enthält bei der Prüfung bereits gespeicherter Schlüssel einen String/Integer-Typkonflikt. `invert_int_value_dict()` bewahrt im Mojo-Port alle verschiedenen Quellschlüssel pro Integerwert. Diese Stelle ist als bewusste Fehlerkorrektur markiert.

## 7. Topologie

Python kodiert eine unbeschränkte Dimension als `None` und eine beschränkte als `frozenset`. Mojo verwendet:

```text
SelectionDimension(restricted: Bool, values: Set[String])
```

Dadurch bleiben die mathematisch verschiedenen Fälle

- unbeschränkt und
- beschränkt auf die leere Menge

explizit unterscheidbar. `refine_selection()` bildet den komponentenweisen Meet/Schnitt.

## 8. Kategorien, Funktoren und natürliche Transformationen

Die großen statischen Architekturdaten werden nicht von Hand doppelt gepflegt. `tools/generate_category_theory.py` lädt den Snapshot der Python-Referenz und erzeugt daraus typisierte Mojo-Strukturen. Tests prüfen die Anzahl sowie benannte Elemente.

Die Generierung ist eine Migrationshilfe. Zur Laufzeit benötigt der native Katalog kein Python.

## 9. Prägarben

Die Python-Prägarbe erlaubt beliebige Objekt-Payloads. Der native Kern beginnt bewusst mit `LocalStringSection`. Weitere Payload-Arten sollten als markierte Varianten ergänzt werden, nicht durch Rückkehr zu untypisierten Python-Objekten.

## 10. Ausgabe

Nativ sind Modusauflösung, Flags, statische Tabellen-/Zellensyntax und die Zahlklassen-abhängige HTML-/BBCode-Zeilenfärbung. Der komplexe HTML-Kopf hängt von dynamischen Tabellenmetadaten ab und bleibt vorerst in Python.

## 11. Parallelisierung

Die native `divisor_range()`- und Bucket-Normalisierung arbeitet momentan deterministisch sequenziell. Die Python-Prozessparallelisierung wurde nicht blind übernommen. Sie sollte erst nach einer nativen Datenfluss- und Kostenanalyse als Mojo-Parallelalgorithmus ergänzt werden.

## 12. Kompatibilitätsprozess

`compat_main.mojo` startet die Python-Referenz in einem separaten Prozess. Ein direkter CPython-In-Process-Aufruf funktionierte für kleine Module, blieb bei der kompletten Reta-Laufzeit wegen globalem Zustand und Laufzeitressourcen beim Beenden hängen. Prozessisolation ist hier die robustere Übergangsarchitektur.

## 13. Bekannte Baseline-Abweichungen des Uploads

Die unveränderte Python-Referenz kompiliert, aber ihre Tests waren beim Eingang nicht vollständig grün: 70 Tests liefen, 3 schlugen fehl und 1 war übersprungen. Zwei Fehler erwarten eine `dataDict`-Größe von 554 statt der tatsächlichen 556; ein weiterer erwartet einen älteren Orchestrierungsnamen. Diese Fehler wurden nicht dem Mojo-Port zugerechnet und nicht heimlich in der Referenz geändert.

## Werkzeug-Namenskonflikt unter Linux

Ein im Snap Store angebotenes Programm namens `mojo` gehört zu Canonicals Juju-Ökosystem und ist nicht der Modular-Mojo-Compiler. Alle Launcher gehen deshalb über `bin/mojo-real`. Dieser Resolver bevorzugt `.venv/bin/mojo`, unterstützt `MOJO_BIN`, verwirft `/snap/mojo/...` und gibt eine gezielte Installationsanleitung aus.
