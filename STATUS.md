# Status – Stufe 6 von 12

- Zielversion: Mojo 1.0.0b2
- Unterstützte Python-Umgebung für Installation/Brücken: 3.10–3.14; Setup bevorzugt Python 3.14
- Stufenfortschritt: **6/12 = 50,0 %**
- Geschätzter funktionaler Portierungsstand: **40–45 %**
- Vollständig native/generierte Originaldateien: **16/92 = 17,4 %**
- Mindestens teilweise portierte Originaldateien: **34/92 = 37,0 %**
- Konservativ vollständig ersetzte Originalzeilen: **4.714/48.831 = 9,7 %**
- Gewichteter Quellzeilenstand: **ca. 15,1 %**
- Nativer Mojo-Quellcode in `src/`: **8.717 Zeilen**
- Davon im Paket `reta_mojo`: **7.892 Zeilen**
- Native Testdateien: **32**
- Native Testfunktionen: **127**
- Im aktuellen Stufe-6-Lauf erneut ausgeführt: **122/122 bestanden**
- Unveränderte schwere Katalogtests: **5**, zuletzt in Stufe 5 bestanden; Quellgeneratoren in Stufe 6 bytegleich reproduziert
- Reguläre Compilerziele: **8 ELF-Executables** unter `target/bin/`
- Schwere optionale Compilerziele: Parameterschema und Architekturkatalog über `scripts/build-heavy.sh`

## Neu in Stufe 6

- vollständige native Zustandsmaschine für `row_filtering.py`
- semikolongetreuer CSV-Parser mit Quotes, UTF-8 und eingebetteten Zeilenumbrüchen
- vollständiger Referenzabgleich für 16 CSV-Dateien
- nativer Laufzeit-Aliaskatalog für Deutsch und Englisch
- normale historische Reta-Syntax im nativen Pfad
- `RETA_NATIVE=1 ./reta ...` als expliziter Umschalter
- native Tabellenprojektion und Headerbehandlung
- erste vier Generatorfamilien in Deutsch und Englisch
- native CSV-, Markdown- und Emacs-Renderer für den portierten Pfad
- bytegleiche Referenzausgabe für repräsentative deutsche und englische Aufrufe
- separates leichtes Tabellenziel und separates Tag-Schema-Ziel
- `--mojo-csv-info` für den nativen CSV-Bestand

## Weiterhin an der Kompatibilitätsgrenze

- restliche Generator- und Metaspalten
- Kombinations-Joins und gebrochen-rationale CSV-Verkettung
- vollständige Shell-, BBCode- und HTML-Formatierung
- komplexe Prompt-Kurzsprache und vollständige i18n-Wortmatrizen
- dynamische Architekturvalidierung, Persistenz und Parallelisierung

Siehe [`ROADMAP.md`](ROADMAP.md) für alle zwölf Stufen.
