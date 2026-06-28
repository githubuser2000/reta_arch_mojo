# Status

- Zielversion: Mojo 1.0.0b2
- Unterstützte Python-Umgebung: 3.10–3.14; Setup bevorzugt Python 3.14
- Nativer Mojo-Quellcode: 4.118 Zeilen insgesamt, davon 3.870 im Paket `reta_mojo`
- Native Testdateien: 14
- Native Testfälle: 59/59 bestanden
- Python-Kompatibilitätsausgabe des geprüften Tabellenaufrufs: bytegleich
- Vollständig nativ: Zahlentheorie, legitime Zeilenbereichslogik, arithmetischer Kern
- Generiert nativ: Kategorientheorie-Snapshot und realer Kontext-/Parameterschema-Snapshot
- Nativ verfügbar: 86 Hauptaliase, 1.355 Unterparameter-Aliase, 428 kanonische Paare, 838 direkte Spaltenverknüpfungen
- Neu nativ: CLI-Tokenisierung, Abschnittskontext, Top-Level-Kommas, positive/negative Spaltenwerte, kanonische Spaltenauswahl und kompaktes schemaabgeleitetes Prompt-Vokabular
- Teilweise nativ: Topologie, Ausgabe-Modi, Prägarben, universelle Bucket-Normalisierung, Spaltenauswahl, Morphismen, Parametersemantik
- Noch über Bridge: vollständiger Tabellenworkflow, dynamischer Prompt-Executor, CSV-Datenzugriff, Generatorspalten, Architekturvalidierungsnetz

- Launcher-Schutz: verwechselt den Modular-Compiler nicht mehr mit dem gleichnamigen Canonical/Juju-Snap
- Reproduzierbare Installation: `scripts/setup_mojo.sh` erzeugt eine projektlokale `.venv` mit Mojo 1.0.0b2 und bevorzugt Python 3.14
