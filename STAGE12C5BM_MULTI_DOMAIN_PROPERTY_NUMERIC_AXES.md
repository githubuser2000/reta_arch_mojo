# Stage 12c5bm – Mehrdomänen-Eigenschafts- und Katalogachsen

Stage 12c5bm erweitert korrigierte echte Bruchvielfache über mehrere physische
CSV-Domänen um zwei bisher atomare Außenachsen:

- `EIGN…` und `EIGR…`-Eigenschaftsselektionen,
- numerische Katalogkürzel der Familien 16 und 15.

## Gemeinsame Projektion ohne Verlust der Domänenrechtecke

Emotion, Strukturgröße, Motive und Universum behalten weiterhin ihre jeweils
eigenen Zähler×Nenner-Rechtecke. Nur die äußeren Ganzzahl- und Reziprokachsen
werden in physischer Domänenreihenfolge dedupliziert vereinigt. Dadurch kann ein
Eigenschafts- oder Katalogaufruf dieselbe korrigierte Bruchprojektion verwenden,
ohne projizierte Ganzzahlen nochmals über `--vielfachevonzahlen` zu expandieren.

## Historische Reihenfolge

Der unabhängige Python-Controller ordnet die Zweige so:

1. Emotion und Strukturgröße,
2. Motive,
3. EIGN/EIGR,
4. Universum,
5. numerische Familie 16 vor 15.

Beispiele:

- `motive EIGNgut universum v2/3` besitzt 27 Aufrufe: 13 Motive,
  einen EIGN-Aufruf und 13 Universum-Aufrufe.
- `motive EIGNgut EIGRwerte universum v2/3` besitzt 28 Aufrufe.
- `motive universum 15_13 16_2 v2/3,5` besitzt 28 Aufrufe; die beiden
  Katalogaufrufe stehen am Ende in der festen Reihenfolge 16 vor 15.

## Bewusste Grenze

Die gleichzeitige Mischung dieser neuen Außenachsen mit einer klassischen Ganzzahlfamilie bleibt vorerst atomarer Fallback, beispielsweise:

```text
mond motive EIGNgut universum v2/3,5
```

Deren vollständige kombinierte Außenreihenfolge wird nicht aus zwei getrennten
Verträgen erraten.

## Referenzprüfung

Der positive Reziprok-/Ausschlussfall `universum v1/4,-2/3` wird nicht mehr aus
dem vollständig gerenderten Python-stdout gelesen. Die Prüfung sammelt direkt
die argv-Aufrufe an der ersetzten `retaExecuteNprint`-Grenze. Das vermeidet
Fehlschläge durch Terminalbreite, Lokalisierung oder veränderte Ankündigungstexte.

Die zusätzliche Referenzprobe bindet die Quellreihenfolge Motive → EIGN/EIGR →
Universum und bestätigt am instrumentierten Python-Plan den numerischen Tail
16 → 15. Sie übernimmt ausdrücklich nicht das defekte gemeinsame n/m-Rechteck.

Die benutzerseitig entdeckte Laufzeitassertion für `emotion v1/4,-2/3`
prüft nun ebenfalls den kanonischen nativen Parameter
`--grundstrukturen=emotion`. Die Großschreibung `--Grundstrukturen=emotion`
gehört nur zur historischen Echo-/Fixture-Oberfläche und war an dieser Stelle ein
reiner Testfehler.
