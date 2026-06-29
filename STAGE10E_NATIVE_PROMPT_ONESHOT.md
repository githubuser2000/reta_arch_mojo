# Stage 10e – native Einmalbefehle und In-Process-Tabellen

Stage 10e entfernt eine unnötige Systemgrenze aus den bereits vollständig
portierten Promptpfaden. Einmalbefehle wurden bisher erst nach dem Import von
`mojo_bridge.py` ausgeführt; Tabellenbefehle starteten zusätzlich das separate
ELF-Ziel `reta-native`. Parser, Tabellenplanung, Generatoren und Renderer lagen
zu diesem Zeitpunkt jedoch bereits in Mojo.

## Neuer Besitzpfad

`prompt_main.mojo` versucht Einmalbefehle jetzt vor jedem Python-Import nativ
auszuführen. Arithmetikbefehle, `abc`, `leeren`, die 18 portierten
Tabellenfamilien und konservativ validierte rohe `reta`-Aufrufe laufen direkt
im Promptprozess. `run_native_reta` wird als Mojo-Funktion aufgerufen; ein
`reta-native`-Kindprozess ist nicht mehr nötig.

Rohe `reta`-Argumente erhalten einen strengen Besitzervertrag. Unbekannte
Hauptbereiche, Zeilenoperatoren, Ausgabeoptionen oder nicht auflösbare
Spalten-/Kombinationspaare verhindern den Fastpfad. Positive Breiten für
Shell, HTML und BBCode bleiben ebenfalls an der Bridge, weil dort weiterhin
die Python-Hyphenator- und Rich-Wrapping-Semantik sichtbar ist. CSV, Markdown,
Emacs, `nichts` und Breite 0 sind unabhängig davon nativ ausführbar.

## Bewusste Echo-Grenze

Kompakte und einbuchstabige Promptformen bleiben zunächst an der Bridge. Ihre
Tabelle ist bereits nativ berechenbar, aber die Python-Referenz gibt davor eine
historische, nicht kanonische Befehlszeile aus. Beispielsweise kündigt `a 2`
`--Menschliches=motivation` an, während der native Plan denselben Inhalt als
`--menschliches=motive` kanonisiert. Stage 10e bewahrt die sichtbare
Byteparität, statt nur wegen gleicher Tabellenwerte die Echoform zu ändern.

## Entfernte Python-Adapter

`mojo_bridge.py` enthält nicht mehr:

- `run_native_reta_subprocess_encoded`
- `clear_terminal`

Terminalbereinigung wird als ANSI-Sequenz direkt in Mojo ausgegeben. Python
bleibt für Readline, Shell-/Python-/Mathekommandos, Persistenzpfade, nicht
portierte Fachzweige und die bewusst erhaltene kompakte Echoform zuständig.

## Tests

`check_prompt_native_oneshot.sh` baut ein isoliertes Laufzeitverzeichnis ohne
`mojo_bridge.py` und ohne `target/bin/reta-native`. Es prüft sechs native
Befehlsarten und bestätigt zugleich, dass ein unbekanntes rohes `reta` sowie
`a 2` weiterhin die fehlende Bridge anfordern.

Der Besitzvalidator besitzt 19 Unit-Tests; acht davon decken die neue
Fastpfadgrenze ab. Der Promptcontroller und die öffentliche Binärmatrix wurden
kompiliert und ausgeführt. Der breite Stage-10-Sammellauf wurde nach mehreren
erfolgreichen Teilgruppen durch einen Neustart der begrenzten
Ausführungsumgebung beendet und wird deshalb nicht als Gesamterfolg gezählt.
