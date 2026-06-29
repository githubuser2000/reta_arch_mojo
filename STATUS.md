# Status – Stufe 9 in Arbeit

- Zielversion: Mojo 1.0.0b2
- Unterstützte Python-Umgebung für Installation/Referenzbrücken: 3.10–3.14; Setup bevorzugt Python 3.14
- Abgeschlossene Release-Stufen: **8/12 = 66,7 %**
- Stufe 9: **BBCode, zentraler ANSI-Shellpfad und zentrale HTML-Pfade nativ; Restformatierung offen**
- Geschätzter funktionaler Portierungsstand: **65–70 %**
- Konservativ vollständig native oder reproduzierbar generierte Originaldateien: **18/92 = 19,6 %**
- Mindestens teilweise portierte Originaldateien: **39/92 = 42,4 %**
- Gewichteter Quellzeilenstand: **ca. 24 %**
- Nativer Mojo-Quellcode in `src/`: **13.421 Zeilen**
- Davon im Paket `reta_mojo`: **12.475 Zeilen**
- Native Testdateien: **43**
- Native Testfunktionen: **170**
- Aktuell fokussiert erneut ausgeführt: **30/30 bestanden**
- Kern-Markup-Fixtures: **8/8 bytegleich**
- Einzeln gegen Python validierte Markup-Fälle: **16/16 bytegleich**
- Generator-/CSV-Paritätssuiten: **30 Generatorfälle + 9 Kombifälle**
- Reguläre Compilerziele: **8 ELF-Executables** unter `target/bin/`
- Schwere optionale Compilerziele: Parameterschema und Architekturkatalog über `scripts/build-heavy.sh`

## Neu seit dem Stufe-7-Archiv

### Stufe 7 abgeschlossen

- zwölf allgemeine Meta-/Konkretachsen aus `meta_columns.py`
- jeweils zwei Spalten für `n` und `1/n`
- exakte CPython-Mengenreihenfolge für alle **4.095** nichtleeren Teilmengen
- deutsche und englische Aliasauflösung
- historische Identitäts- und Übersetzungssonderfälle

### Stufe 8 abgeschlossen

- vier gebrochen-rationale CSV-Prägarben: Universum, Galaxie, Emotion und Strukturgröße
- nativer relationaler Kombi-Join für Galaxie und Universum
- **173** zweisprachige Kombi-Aliase
- **151** reproduzierbare Relationsordnungen
- Negativauswahl, Mehrfachauswahl und gemischte Galaxie-/Universum-Abfragen
- historische leere Segmente und abschließende Leerzeichen erhalten

### Stufe 9 begonnen

- BBCode mit historischer Zählungsfarbe, Zellabständen, Wortumbruch und Seitenteilung
- HTML mit dynamischen Klassen für alle **746** physischen Haupttabellenspalten
- physischer HTML-Katalog mit **1.496** Sprach-/Spalteneinträgen
- zusätzlicher semantischer Überschriftenkatalog für Generatorzellen
- tag-erhaltende HTML-Ausgabe für `<ul>`, `<li>`, `<br>` und weitere beabsichtigte Tags
- bytegleiche deutsche und englische HTML-Ausgabe für physische Spalten, Primzahlwirkung, Meta-Spalten und gebrochenes Universum
- korrekte CSS-Indizes auch ohne Nummerierung und ohne Überschriften
- nativer ANSI-Shellrenderer mit historischen Zeilenfarben, Wortumbruch, Seitenteilung und signifikanter Leerzeichenbehandlung
- fünf bytegleiche Shell-Fixtures: Deutsch/Englisch, Breite 0/40, ohne Nummerierung und generierte Primzahlwirkung

## Weiterhin an der Kompatibilitätsgrenze

- verbleibende Terminalbreiten-, Rich- und seltene Shell-Sonderfälle
- dynamische HTML-Klassen für noch nicht im Überschriftenkatalog erfasste Generatorfamilien
- einzelne kombinierte Modal-/HTML-Metadatenfälle
- komplexe Prompt-Kurzsprache und vollständige i18n-Wortmatrizen
- dynamische Architekturvalidierung, Persistenz und Parallelisierung

Siehe [`ROADMAP.md`](ROADMAP.md) für alle zwölf Stufen.
