# Stage 10i – native Null-, Negativ- und Ausschlussselektoren

Stage 10i schließt die bisherige Lücke zwischen der numerischen Promptplanung und der Zeilenalgebra des nativen Tabellenkerns. Die betroffenen Eingaben werden nicht mehr als Sonderfälle an Python abgegeben, sondern als typisierte positive und negative Zeilenprädikate geplant.

## Übernommene Semantik

Nativ besessen sind nun insbesondere:

```text
0
-2
u 2,-2
u 1-3,-2
u 1/2,-1/2
u 2/4,-2/4
u 2/3,-1/4
u 2/4,-1/2
u teiler 0
u teiler 2,-2
u teiler 1-3,-2
```

Die rohe Reihenfolge mehrerer Ganzzahlkomponenten wird wie im historischen Prompt über die deterministische CPython-`set[str]`-Reihenfolge bei `PYTHONHASHSEED=0` gebildet. Das betrifft beispielsweise `3 1 → 1,3` und `1-3,-2 → -2,1-3`.

## All-Zeilen-Algebra

Positive und negative Zeilenprädikate werden vor der Auswahl gegeneinander gekürzt. Ein identisches Paar wie `2,-2` entfernt beide Bedingungen. Die dadurch leere Bedingungsmenge bedeutet im Legacyvertrag nicht „keine Zeile“, sondern „alle Zeilen“. Diese Bedeutung liegt jetzt zentral im nativen CLI-Planer und gilt gleichermaßen für Ganzzahlen, Reziproke und echte Bruchachsen.

Nur der All-Zeilen-Pfad behält bei expliziter Ergebnisprojektion `--oberesmaximum` als Referenz für die Breite der Shell-Nummerierung. Endliche Auswahlen und gewöhnliche Aliasabfragen bleiben nach ihren tatsächlich sichtbaren Zeilennummern dimensioniert.

## Teiler vor Ausschlüssen

Der historische `teiler`-Zweig entfernt negative Komponenten vor der Teilerbildung. Daher wird aus `u teiler 1-3,-2` zuerst die positive Menge `{1,3}` und anschließend der Tokenstrom `3,-2,1-3`. Wird die positive Seite vollständig entfernt, serialisiert der Plan eine explizite leere Komponente, zum Beispiel `u teiler 2,-2 → ,-2,2`. Ein reines `u teiler 0` ist dagegen ein besessener, leerer Plan und erzeugt keine Tabelle.

## Reiner Null-Standardbefehl

Der kompakte Befehl `0` besitzt einen stabilen historischen Sonderpfad: Er erzeugt nur die Thomas-Tabelle mit Zeilenselektor `0`, ohne `--oberesmaximum` und ohne die sonst zweite Motiv-Tabelle. Dieser Ablauf wird jetzt direkt in Mojo geplant.

## Weiter offene Besitzgrenze

Atomar an der Kompatibilitätsgrenze bleiben:

- echte `v n/m`-Vielfache mit Zähler größer 1, für die die Python-Referenz selbst `IndexError` auslöst,
- doppelte Instanzen derselben generierten Katalogspalte, solange instanzabhängige Breiten nicht im nativen Tabellenzustand repräsentiert sind,
- seltene hintere Prompt-, Rich- und kombinierte HTML-Sonderfälle.

## Prüfungen

- 23/23 Tabellenplanertests
- 20/20 native CLI-/Besitztests
- 7/7 Renderer-Unit-Tests
- 11/11 vollständige numerische Ausführungsfixtures bytegleich
- 15/15 isolierte numerische One-shot-Klassen ohne Python-Datei und ohne `reta-native`-Kindprozess
- 7/7 allgemeine Prompt-Ausführungsfixtures bytegleich
- alle 365 historisch adressierbaren numerischen Katalogeinträge bleiben nativ planbar
- vollständiger `test_stage10.sh`-Regressionslauf bestanden
- alle 9 vorgesehenen Mojo-Executables erfolgreich gebaut und im Layout geprüft
