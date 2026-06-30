# Portierungsfahrplan Python → Mojo

Geplanter Umfang: **12 Release-Stufen**. Eine Stufe zählt erst als abgeschlossen, wenn Quellcode, Referenztests, Compilerziele, Dokumentation und ein source-only Archiv gemeinsam geprüft sind.

## Fortschrittsmaße im aktuellen Stufe-9/10/11-Zwischenstand

| Maß | Stand | Aussage |
|---|---:|---|
| abgeschlossene Release-Stufen | **8/12 = 66,7 %** | Generator-/Meta- und Kombinationspfade sind abgeschlossen; Stufen 9, 10 und 11 sind aktiv |
| vollständig native oder generierte Python-Dateien | **22/92 = 23,9 %** | Datei vollständig ersetzt oder als reproduzierbares Laufzeitasset abgebildet |
| mindestens angegriffene Python-Dateien | **50/92 = 54,3 %** | vollständig oder teilweise nativ |
| gewichtete Quellzeilen | **ca. 37 %** | konservative Schätzung unter Berücksichtigung der großen Teilports |
| funktionaler Nutzerumfang | **ca. 87–90 %** | praktisch nutzbarer Reta-Umfang ohne Python-Algorithmus |

Die Stufenquote ist höher als die Quellzeilenquote, weil die letzten Stufen besonders große dynamische Module bündeln: vollständige Ausgabeaufbereitung, Prompt-Sprache, i18n-Matrix, Architekturvalidierung und Parallelisierung.

## Die zwölf Stufen

1. **Grundlage und Zahlentheorie — abgeschlossen**  
   Mojo-Projekt, Primfaktoren, Teiler, Primzahlkreuz, Bereichssprache, Basistests.

2. **Schema, Aliase und Eingabesemantik — abgeschlossen**  
   Typisierte Parametersemantik, deutsche Aliasauflösung, Spalten-Buckets und CLI-Normalisierung.

3. **Promptprogramme und historische Startnamen — abgeschlossen**  
   `rp`, `rpl`, `rpb`, `rpe`, `retaPrompt`, Sitzungszustand und native Arithmetikbefehle.

4. **HTML-Grundstrukturen und `generate_html` — abgeschlossen**  
   Nativer Grundstrukturenrenderer und Mojo-Orchestrierung der HTML-Gesamtseite.

5. **Buildlayout, Tag-Schema und Tabellenzustand — abgeschlossen**  
   ELF-Buildziele unter `target/`, `.gitignore`, Tabellen-Tags, Wrapping, `multis3`.

6. **CSV, Zeilenfilter und erster nativer Reta-Tabellenpfad — abgeschlossen**  
   Semikolon-CSV, vollständige Zeilenfiltermaschine, zweisprachige Laufzeit-Aliase, erste Generatorspalten, CSV/Markdown/Emacs-Ausgabe und `RETA_NATIVE=1`.

7. **Alle Generator- und Metaspalten — abgeschlossen**  
   Klassifikatoren, Modallogik, Primzahlkreuz, Primzahlwirkung, Primuniversum, `PrimCSV` sowie zwölf allgemeine Meta-/Konkretachsen einschließlich aller 4.095 Teilmengenordnungen.

8. **Kombinationen und CSV-Verkettung — abgeschlossen**  
   Vier gebrochen-rationale CSV-Prägarben, Galaxie-/Universum-Kombi-Join, 173 Aliase, 151 Relationsordnungen, Negativ- und Mehrfachauswahl.

9. **Vollständige Tabellenaufbereitung und Ausgabe — in Arbeit**  
   BBCode und der zentrale ANSI-Shellpfad sind für die geprüften deutschen und englischen Ausgaben bytegleich. HTML besitzt physische und semantische Zellmetadaten, tag-erhaltende Zellen, Wrapping und Seitenteilung. Offen bleiben Rich-/Terminalsonderfälle und restliche dynamische HTML-Familien.

10. **Vollständige Prompt-Sprache und i18n — in Arbeit**  
    Klammerbewusstes Tokenisieren, kompakte Kurzbefehle, CPython-Set-Reihenfolge, fünfsprachiger Completion-Katalog und persistenter Mojo-Completion-Arbeiter sind nativ. Mojo plant 18 Domänenfamilien plus EIGN/EIGR einschließlich Ganzzahl-, Reziprok- und `n/m`-Achsen, ganzzahliger Vielfachen/Teiler, historischer Bruchbereiche, stabiler Bruchausschlüsse, Bruchteiler und Reziprok-Vielfache. Vollständig besessene Einmalbefehle laufen vor jedem Python-Import und rufen den Tabellenkern im selben Mojo-Prozess auf. Eine getrennte Legacy-Präsentationsschicht besitzt sämtliche kompakten Tabellenfamilien und `mulpri`/`p`. Stage 10h ergänzt positive reine Zahlen-, Bereichs-, Listen- und Bruchkompositionen sowie 365 adressierbare Einträge des fünfsprachigen `15`-/`16`-Katalogs. Vorbereitete Fragmentbreiten, Bindestrichumbrüche, Zählungsmarkierungen und der historische nicht-zeilenorientierte Farbausgabestrom sind bytegenau modelliert. Stage 10i–10n ergänzen Null-/Negativ- und Kollisionsalgebra, wiederholte Katalogauswahl, mehrbereichige Abstände, native Datei-/Pipe-I/O, positive Promptbreiten, komponierte ganzzahlige Vielfachen-/Teilerpfade, verschachtelte CPython-Teiler-Setordnung und dynamische Obergrenzen absoluter `vN`-Selektoren. Offen bleiben echte `v n/m`-Vielfache mit Zähler größer 1, weitere hintere Sonderpfade, die große `--alles`-HTML-Mitteltabelle und die vollständige i18n-Laufzeit außerhalb des Promptvokabulars.

11. **Architektursteuerung und Laufzeitnetze — in Arbeit**  
    Stage 11a portiert Architekturkarte und realen Modul-/Kapsel-Grenzgraph. Stage 11b ergänzt 33 kommutierende Diagramme, 11 Kapselverträge, 22 Gesetze, 536 Witness-Anker, 33 Diagrammnachweise, 42 Natürlichkeitsnachweise und 55 Refactor-Verpflichtungen als getrennte typisierte Mojo-Bundles. Offen bleiben Kohärenz, ausführbare Gesamtvalidierung, Aktivierung, Persistenz, Ausführungsnetz, Parallelisierung und Rehearsal.

12. **Bridge entfernen und Releaseparität — offen**  
    Letzte Python-Grenzen entfernen, vollständige Befehlsmatrix, Leistungsprüfung, Packaging und Release.

Die Zahl **12** ist die geplante Releasegliederung. Interne Teilpakete oder Fehlerkorrekturen erhöhen diese Zahl nicht automatisch.

## Stage 10n – native EIGN/EIGR-Eigenschaftsachsen

- Ein eigener typisierter Planer übernimmt alle 165 deutschen
  `EIGN…`-/`EIGR…`-Katalogbefehle.
- Die Eigenschaftssuffixe werden erst nach CPython-kompatibler Mengenordnung des
  vollständigen Promptbefehls extrahiert.
- EIGN verwendet `--konzept`; EIGR verwendet `--konzept2` und bewahrt bei
  Ganzzahlen die historische zweite `-zeilen`-Sektion.
- Der in der Python-Promptschicht defekte `deepcopy(module)`-Vorlauf von EIGR
  wird nicht imitiert. Maßgeblich ist sein expliziter, direkt über `reta.py`
  ausführbarer Argumentvertrag.
- Vollständig besessene Eigenschaftsbefehle laufen vor jedem Python-Import und
  ohne `reta-native`-Kindprozess.


## Stage 11a – native Architekturkarte und Kapselgrenzen

- `architecture_map.py` ist als vollständiger typisierter Mojo-Snapshot verfügbar.
- `architecture_boundaries.py` ist als typisierter Modulbesitz-, Import- und Kapselgraph verfügbar.
- Die Quellbaum-/AST-Auswertung läuft nur beim expliziten Regenerieren; normale Abfragen und Validierungszugriffe benötigen kein Python.
- `reta-mojo-boundaries` liefert Zusammenfassung, Modulbesitz, Kapselstatistik und Diagramme.
- Generatoren sind über mehrere `PYTHONHASHSEED`-Werte byteidentisch reproduzierbar.


## Stage 11b – native Architekturverträge und Witnesses

- `architecture_contracts.py` ist als typisierter Snapshot mit 33 Diagrammen, 11 Kapselverträgen und 22 Gesetzen verfügbar.
- `architecture_witnesses.py` ist als typisierter Snapshot mit 536 Ankern, 11 Kapselschnitten, 33 Diagramm-, 42 Natürlichkeits-Witnesses und 55 Verpflichtungen verfügbar.
- 351/351 dateiartige Anker sind gegen `python_reference` aufgelöst; 185 symbolische Anker bleiben bewusst symbolisch.
- Beide Generatoren sind über `PYTHONHASHSEED=0`, `1`, `42`, `random` byteidentisch reproduzierbar.
- Verträge und Witnesses bleiben getrennte schwere Ziele, damit Mojo nicht den gesamten Metakatalog in einem Compiler-Monolithen instanziiert.
