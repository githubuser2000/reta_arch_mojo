# Portierungsfahrplan Python → Mojo

Geplanter Umfang: **12 Release-Stufen**. Eine Stufe zählt erst als abgeschlossen, wenn Quellcode, Referenztests, Compilerziele, Dokumentation und ein source-only Archiv gemeinsam geprüft sind.

## Fortschrittsmaße im aktuellen Stufe-9/10-Zwischenstand

| Maß | Stand | Aussage |
|---|---:|---|
| abgeschlossene Release-Stufen | **8/12 = 66,7 %** | Generator-/Meta- und Kombinationspfade sind abgeschlossen; Stufen 9 und 10 sind aktiv |
| vollständig native oder generierte Python-Dateien | **18/92 = 19,6 %** | Datei vollständig ersetzt oder als reproduzierbares Laufzeitasset abgebildet |
| mindestens angegriffene Python-Dateien | **45/92 = 48,9 %** | vollständig oder teilweise nativ |
| gewichtete Quellzeilen | **ca. 28 %** | konservative Schätzung unter Berücksichtigung der großen Teilports |
| funktionaler Nutzerumfang | **ca. 70–74 %** | praktisch nutzbarer Reta-Umfang ohne Python-Algorithmus |

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
    Klammerbewusstes Tokenisieren, kompakte Kurzbefehle, CPython-Set-Reihenfolge, fünfsprachiger Completion-Katalog und persistenter Mojo-Completion-Arbeiter sind nativ. Offen bleiben die hintere fachliche Prompt-Ausführung und die vollständige i18n-Laufzeit außerhalb des Promptvokabulars.

11. **Architektursteuerung und Laufzeitnetze — offen**  
    Validierung, Aktivierung, Verträge, Persistenz, Ausführungsnetz, Parallelisierung und Rehearsal.

12. **Bridge entfernen und Releaseparität — offen**  
    Letzte Python-Grenzen entfernen, vollständige Befehlsmatrix, Leistungsprüfung, Packaging und Release.

Die Zahl **12** ist die geplante Releasegliederung. Interne Teilpakete oder Fehlerkorrekturen erhöhen diese Zahl nicht automatisch.
