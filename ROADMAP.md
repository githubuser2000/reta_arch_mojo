# Portierungsfahrplan Python → Mojo

Geplanter Umfang: **12 Release-Stufen**. Eine Stufe zählt erst als abgeschlossen, wenn Quellcode, Referenztests, Compilerziele, Dokumentation und ein source-only Archiv zusammen geprüft sind.

## Fortschrittsmaße im aktuellen Stufe-7-Zwischenstand

| Maß | Stand | Aussage |
|---|---:|---|
| abgeschlossene Release-Stufen | **6/12 = 50,0 %** | Stufe 7 ist aktiv, aber wegen offener allgemeiner Metaspalten noch nicht abgeschlossen |
| vollständig native Python-Dateien | **16/92 = 17,4 %** | Datei vollständig ersetzt oder reproduzierbar generiert |
| mindestens angegriffene Python-Dateien | **36/92 = 39,1 %** | vollständig oder teilweise nativ |
| vollständig ersetzte Python-Zeilen | **4.714/48.831 = 9,7 %** | konservative Quellzeilenmetrik |
| gewichtete Quellzeilen | **ca. 18 %** | konservative Schätzung unter Berücksichtigung der großen Teilports |
| funktionaler Nutzerumfang | **ca. 50–55 %** | geschätzter Anteil praktisch nutzbarer Reta-Funktionen ohne Python-Algorithmus |

Die Stufenquote ist höher als die Quellzeilenquote, weil die späteren Stufen die größten und dynamischsten Module enthalten: Generatorspalten, Kombinations-Joins, Prompt-Sprache, i18n-Matrix, Architekturvalidierung und Parallelisierung.

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

7. **Alle Generator- und Metaspalten — in Arbeit**  
   Die nutzerseitigen Generatorfamilien, Primzahlwirkung, Primzahlkreuz, ganzzahlige und gebrochen-rationale Primuniversum-Spalten sowie `PrimCSV` sind nativ und bytegleich geprüft. Offen bleiben die allgemeinen Metaspalten und weitere dynamische Relationen aus `meta_columns.py`.

8. **Kombinationen und CSV-Verkettung — offen**  
   `combi_join.py`, `concat_csv.py`, `lib4tables_concat.py`, gebrochen-rationale Tabellen und Kombi-Meta.

9. **Vollständige Tabellenaufbereitung und Ausgabe — offen**  
   Mehrzeilige Zellen, Wörterbuchtrennung, Shellbreiten, vollständiges BBCode/HTML, alle Ausgabeparameter.

10. **Vollständige Prompt-Sprache und i18n — offen**  
    Komplexe Kurzbefehle, Completion-Nesting, Promptvorbereitung, Wortmatrizen und alle Sprachen.

11. **Architektursteuerung und Laufzeitnetze — offen**  
    Validierung, Aktivierung, Verträge, Persistenz, Ausführungsnetz, Parallelisierung und Rehearsal.

12. **Bridge entfernen und Releaseparität — offen**  
    Letzte Python-Grenzen entfernen, vollständige Befehlsmatrix, Leistungsprüfung, Packaging und Release.

Die Zahl **12** ist die geplante Releasegliederung. Interne Teilpakete oder Fehlerkorrekturen erhöhen diese Zahl nicht automatisch.
