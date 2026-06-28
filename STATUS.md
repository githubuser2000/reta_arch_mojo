# Status – Stufe 5

- Zielversion: Mojo 1.0.0b2
- Unterstützte Python-Umgebung: 3.10–3.14; Setup bevorzugt Python 3.14
- Nativer Mojo-Quellcode in `src/`: **7.243 Zeilen**
- Davon im Paket `reta_mojo`: **6.451 Zeilen**
- Native Testdateien: **24**
- Native Testfälle: **111/111 bestanden**
- Kompilierte Programme: **8 ELF-Executables** unter `target/bin/`
- Git-Regel: `.venv/`, `target/`, `build/` und Laufzeitartefakte werden ignoriert
- `bin/`: ausschließlich versionierte Shell-Launcher, keine ELF-Dateien
- Setup: installiert Mojo und kompiliert standardmäßig automatisch

## Neu in Stufe 5

- vollständiges generiertes Tabellen-Tag-Schema
- sieben Tagarten
- 19 Primärgruppen und 478 Rückabbildungen
- beide Kombinations-Tag-Schemata
- typisierter Tabellenzustand
- Unicode-sicheres hartes Wrapping
- Breiten- und Zeilenlogik
- vollständige reine Ausgabe-Modus-Anwendung
- native Kompatibilitäts-Fallbacks für `bbcode.py` und `html2text.py`
- reine Teile aus `console_io.py` und `runtime_compat.py`
- native Dreifach-Faktorisierung `multis3`
- öffentlicher Startname `multis3` in Projektwurzel, `bin/` und `run/`
- Referenzfingerprint von `multis3` für alle Zahlen 2–256
- reproduzierbares Build-/Release-Prüfskript

## Bereits nativ

- Zahlentheorie und Bereichssprache
- arithmetischer Kern einschließlich `prim`, `prim24`, `multis`, `multis3`, `modulo`
- Parameter- und Eingabesemantik
- Schema- und Aliasauflösung
- Promptcontroller und Sitzungszustand
- Grundstrukturen-HTML
- `generate_html`-Orchestrierung
- Topologie, Prägarbenanteile, Morphismen und universelle Bucket-Normalisierung
- Kategoriekatalog

## Noch an der Kompatibilitätsgrenze

- vollständige große Tabellenberechnung und CSV-Datenpipeline
- Generatorspalten und Kombinations-Join
- sämtliche komplexen historischen Prompt-Kurzbefehle
- Wörterbuchbasierte Silbentrennung
- readline, Historydatei und Kindprozesserzeugung
- dynamische Architekturvalidierungs- und Persistenznetze
