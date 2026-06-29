# Stage 10h – native numerische Promptkomposition

> **Folgestand:** Stage 10i hebt die hier noch dokumentierte Grenze für Nullwerte, rein negative Selektoren und kollidierende Ausschlüsse auf.


Stage 10h übernimmt die reine Zahlenkurzsprache und die katalogisierten `15`-/`16`-Auswahlen in den besitzenden Mojo-One-shot-Pfad. Die Implementierung erzeugt keine zweite Tabellenlogik: Sie komponiert die bereits typisierten Arithmetik-, Zeilen-, Bruch- und Tabellenpläne in derselben historischen Reihenfolge wie `retaPrompt.py`.

## Reine numerische Eingaben

Direkt nativ ausführbar sind nun unter anderem:

```text
1
15
1-3
2,3
1/2
3/2
```

Ganzzahlen und Bereiche komponieren `mulpri`, Motiv/Absicht, Thomas und Teiler mit stiller Befehlsausgabe. Reziproke und echte Brüche verwenden die vorhandenen Ganzzahl-, Reziprok- und `n/m`-Achsen; nicht anwendbare Teilfamilien werden wie in Python übersprungen.

Der Shellrenderer bildet jetzt außerdem die erste historische Zählungsspalte vollständig ab: Gerade Zählungsgruppen beginnen mit `█`, ungerade Gruppen mit einem Leerzeichen. Die Markierung bleibt auf umgebrochenen visuellen Zeilen erhalten.

## Numerische Katalogbefehle

Die fünfsprachigen Assetzeilen werden typisiert auf die Tabellenoptionen abgebildet:

```text
15_<schlüssel>       → Grundstrukturen / basic_structures
16_<schlüssel>       → Multiversum / multiverse
16_15_<schlüssel>    → historische Grundstrukturen-Aliasform
```

Wenn beide Familien vorkommen, wird wie in der Referenz zuerst Multiversum und danach Grundstrukturen ausgeführt. Innerhalb einer Familie bleibt die vorbereitete CPython-Set-Reihenfolge erhalten. Sichtbare Katalogbefehle enden bewusst mit einem Zeilenumbruch, auch wenn gewöhnliche farbige Prompttabellen ihren `reta`-Echo mit dem Tabellenkopf verkleben.

Das Asset enthält 370 Zeilen. Davon sind 365 über die historische Grammatik adressierbar. Die fünf Multiversum-Einträge mit Schlüssel `15` sind syntaktisch unerreichbar, weil `16_15` bereits die Familie-15-Aliasform bezeichnet. Stage 10h bewahrt diese Grammatik und erfindet keine inkompatible Ersatzsyntax.

Doppelte generierte Auswahlinstanzen bleiben atomar am Fallback, solange der native Tabellenzustand keine getrennten Breiten pro identischer Spalteninstanz repräsentiert.

## Besitzgrenze

Reine Zahlenbefehle werden nur nativ übernommen, wenn jedes aus der Promptvorbereitung entstandene Token besessen ist. Die durch das historische `e`-Profil ergänzten sicheren Ausgabeparameter werden explizit validiert. Unbekannte oder nicht vollständig modellierte Bestandteile geben weiterhin die gesamte Eingabe an die Kompatibilitätsgrenze zurück.

Noch nicht übernommen sind insbesondere:

- `0`, das im Original eine besondere All-Zeilen-Ausgabe öffnet,
- rein negative numerische Ausdrücke,
- doppelte generierte Katalogspalten mit instanzabhängiger Breite,
- echte `v n/m`-Vielfache mit Zähler größer 1,
- kollidierende Legacy-Bruchausschlüsse.

## Prüfungen

- 21/21 Tabellenplanertests
- 6/6 Renderer-Unit-Tests
- 19/19 CLI-/Besitztests
- 11/11 vollständige numerische Ausführungsfixtures bytegleich
- 8/8 isolierte numerische One-shot-Klassen ohne Python-Import oder `reta-native`-Kindprozess
- alle 365 adressierbaren Katalogzeilen erzeugen einen nativen typisierten Plan
- vorhandene kompakte, Prompt-, Bruch-, Completion-, Shell-, BBCode- und HTML-Fixtures bleiben grün
