# Stage 10l – native Datei-, Pipe- und HTML-Orchestrierung

Stage 10l entfernt drei unnötige eingebettete CPython-Grenzen und erweitert den
Promptbesitz auf positive Rendererbreiten. Die fachlichen Fallbacks bleiben
atomar sichtbar; Betriebssystem-I/O ist dagegen kein Grund mehr, Python in ein
Mojo-Executable einzubetten.

## Zentrale native Dateischicht

`src/reta_mojo/csv_table.mojo` lädt UTF-8-Textdateien nun mit Mojos nativer
`open(...).read()`-Schnittstelle. Der frühere `std.python`-/`pathlib`-Import ist
entfernt. Da `read_text_file` die gemeinsame Ladeschicht ist, betrifft dies
unter anderem:

- die physische Religionstabelle,
- generierte TSV-Kataloge,
- Kombinations- und Bruchrelationen,
- Prompt- und Completion-Assets,
- HTML-Kopf-, JavaScript- und Footerdateien.

CSV-Parsing, CRLF-Behandlung, eingebettete Zeilenumbrüche und UTF-8-Inhalte
bleiben unverändert im typisierten Mojo-Code.

## Persistenter Completion-Arbeiter ohne CPython

`reta-prompt-complete` importiert nicht länger `std.python`, um `sys.stdin` und
`sys.stdout` zu erreichen. Der Prozess liest direkt vom Dateideskriptor 0 und
schreibt vollständig auf Dateideskriptor 1. Dadurch bleiben erhalten:

- mehrere Anfragen in demselben Prozess,
- echte leere Anfragezeilen,
- CRLF-Normalisierung,
- EOF nach einer letzten nicht abgeschlossenen Zeile,
- sofortige, vollständige Pipeantworten.

GNU Readline und der Lebenszyklus des Kindprozesses bleiben im Python-Adapter;
Katalog, Kontextlogik, Kandidatenordnung und beide Pipe-Endpunkte des
Mojo-Arbeiters sind nativ.

## `generate_html` nativ orchestriert

`src/generate_html_main.mojo` besitzt jetzt selbst:

- Sprachargumente,
- Umgebungsvariablen,
- Override-Dateien,
- Erzeugung von `middle.alx`,
- Asset-Laden,
- Grundstrukturen-Rendering,
- Seitendokument-Komposition,
- stdout-Ausgabe und Fehlergrenze.

Im Override-Pfad ist das Programm vollständig Python-frei. Im normalen Pfad
bleibt genau ein expliziter Kindprozess für die noch nicht portierte
`reta.py -spalten --alles`-Gesamttabelle. Es wird keine CPython-Laufzeit mehr in
das Mojo-Executable eingebettet. Ein eindeutiger Erfolgsmarker verhindert, dass
ein fehlgeschlagener Referenzprozess als leere erfolgreiche Seite erscheint.

## Positive Promptbreiten

Die frühere Prompt-Sperre für positive Shell-, HTML- und BBCode-Breiten war
überholt: Die zugrunde liegenden nativen Renderer waren bereits durch
Bytefixtures gedeckt. Rohe `reta`-One-shots übernehmen nun auch
`--breite=40`/`--width=40` in allen drei Modi vor jedem Python-Import und ohne
`reta-native`-Kindprozess.

## Neue Besitzprüfungen

- zentrale CSV-Datei wird nativ gelesen und als bekannte Shell-Fixture gerendert,
- Completion-Protokoll `abc` wird ohne Python-Quellbaum bytegleich beantwortet,
- HTML-Override funktioniert selbst mit absichtlich ungültigem
  `RETA_REFERENCE_PYTHON`,
- `readelf` findet in den drei betroffenen Executables keine `libpython`-
  Abhängigkeit,
- positive Shell-, HTML- und BBCode-Promptausgaben sind in einem isolierten
  Verzeichnis bytegleich zu den bestehenden Referenzfixtures.

## Build- und Regressionsergebnis

- 113/113 fokussierte Stage-10-Mojo-Tests bestanden,
- 3/3 positive Promptbreiten bytegleich,
- native I/O-Grenzprüfung einschließlich LF, CRLF und EOF bestanden,
- 12/12 Readline-Completion-Kontexte bytegleich,
- 8/8 zentrale Markup- und 5/5 Shell-Fixtures bytegleich,
- deutscher und englischer realer Ein-Zeilen-HTML-Pfad bytegleich,
- alle 9/9 regulären Executables gebaut und das Buildlayout geprüft,
- 13 zusätzliche kalte Mojo-Suiten ohne Fehler abgeschlossen.

Der übergreifende Releasecheck stoppt weiterhin an der bereits bekannten
Python-3.13.5-CSV-Harnessabweichung, bei der die direkte Referenzausgabe ihre
Zeilen verklebt. Dieser Fall wird weder weg-normalisiert noch als Erfolg der
Stage ausgegeben.

## Verbleibende Grenzen

- `compat_main.mojo` ist absichtlich die vollständige Python-Kompatibilitätsbrücke,
- `prompt_main.mojo` importiert Python erst für tatsächlich unbesessene
  Promptzweige und für die interaktive Readline-Systemgrenze,
- die große `--alles`-Mitteltabelle von `generate_html` bleibt bis zur
  vollständigen All-Spalten-Matrix ein expliziter Referenzkindprozess,
- echte `v n/m`-Vielfache mit Zähler größer 1 besitzen weiterhin keine stabile
  Python-Referenzsemantik, weil das Original dort `IndexError` auslöst.
