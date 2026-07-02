# Stage 12c5e – Native CSV-/Kombinationsverkettung

Stand: 2. Juli 2026

## Ziel

Diese Stage schließt die gemeinsame Tabellenverkettungsgrenze aus:

- `python_reference/reta_architecture/concat_csv.py`
- `python_reference/libs/lib4tables_concat.py`

Die Python-Implementierung verbindet fünf historische CSV-Prägarben mit der
Haupttabelle, erzeugt Bruchpaarrelationen und verwaltet dynamische Metadaten.
Die Legacy-Klasse `Concat` leitet zusätzlich 34 Nicht-Konstruktormethoden an
Generator-, Meta-, Primzahlkreuz- und CSV-Besitzer weiter.

## Neue native Besitzer

- `src/reta_mojo/concat_csv.mojo`
- `src/reta_mojo/legacy_lib4tables_concat.mojo`

`concat_csv.mojo` besitzt nun:

- exakte rationale Werte und Paare ohne Float-Rundung,
- Divisions- und Multiplikationsgruppierung,
- Kombination und Expansion gebrochen-rationaler Paare,
- Auswahl der fünf historischen CSV-Quellen,
- deutsche und englische Überschriften,
- Reziprok-Transposition,
- Primzahlzeilen-Kompaktion für HTML, BBCode und Text,
- Tabellenanhängung und Spaltenauswahl,
- typisierte Metadaten statt dynamischer `generatedSpaltenParameter`-Objekte.

`legacy_lib4tables_concat.mojo` bewahrt die 34 öffentlichen Methoden und die
13 Konstruktorzustände der alten Python-Klasse als expliziten typisierten
Weiterleitungsvertrag.

## Exakte Referenzparität

`scripts/check_concat_csv_parity.py` vergleicht einen nativen Probeprozess mit
der tatsächlichen Python-Referenz. Geprüft werden Quellenauswahl, Domänen,
Reziprokstatus, deutsche/englische Überschriften, Divisions- und
Multiplikationsgruppen, normale und reziproke Bruchpaare, Fassadenbestand und
drei Generatorwerte.

Ergebnis: **20/20 Zeilen byteidentisch**.

## Kompression

Das Sourcearchiv wird ab dieser Stage als `.tar.xz` ausgeliefert. Der
Archivgenerator verwendet standardmäßig:

```sh
xz -T0 -9e
```

`-T0` aktiviert den parallelfähigen XZ-Modus. Der nur rund 34 MiB große
Tarstrom wurde mit dem 64-MiB-Wörterbuch dieser Stufe jedoch als ein Block
kodiert. Erzwungene 4-MiB- beziehungsweise 8-MiB-Blöcke erzeugten 9
beziehungsweise 5 tatsächlich parallel verarbeitbare Blöcke, vergrößerten das
Archiv aber von 3.813.008 auf 4.428.448 beziehungsweise 4.211.228 Byte. Deshalb
bleibt das kleinere Standard-XZ-Ergebnis bestehen. In der Arbeitsumgebung ist
weder `brotli-mt` noch eine andere parallele Brotli-CLI vorhanden; das
Python-Brotli-Modul arbeitet seriell. Brotli bleibt als kompatibles
Archivformat erhalten, ist aber nicht mehr das Übergabeformat.

## Reproduzierbare Fortschrittsmetriken

`tools/porting_metrics.py` berechnet den Portierungsstand direkt aus den 92
Python-Referenzdateien und der autoritativen `NATIVE`-Zuordnung. Dadurch werden
manuell fortgeschriebene Überzählungen vermieden.

Der korrigierte, maschinenberechnete Stand lautet:

- vollständig nativ oder generiert: **51/92 = 55,4 %**,
- mindestens teilweise portiert: **73/92 = 79,3 %**,
- angegriffene Referenzzeilen: **33.198/48.831 = 68,0 %**,
- Mojo-Code in `src/`: **47.584 Zeilen**,
- davon in `src/reta_mojo/`: **44.287 Zeilen**.

Die früheren Stage-12c5d-Texte nannten für „mindestens teilweise portiert“ und
den gewichteten Zeilenstand zu hohe manuell fortgeschriebene Werte. Der
Quellcode- und Matrixstatus war davon nicht betroffen.

## Gates

```text
neue native Modultests:                   12/12
Python↔Mojo-CSV-/Fassadenparität:          20/20 Zeilen
angrenzende Bruch-/Metaspaltentests:        7/7
Source-/Ownership-/Boundary-/Archivtests:  30/30
Portierungsmetriktests:                     2/2
```

Der monolithische Generated-Table-Test überschritt erneut das bekannte
Debug-Link-/Laufzeitlimit, ohne eine Compilerdiagnose auszugeben. Er wird nicht
als bestanden gezählt; die von dieser Stage berührten Pfade sind durch die
fokussierten Tests und den Referenzprobeprozess abgedeckt.
