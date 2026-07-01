# Stage 12c4q – native Start-, Sprach- und Hilfeoberfläche

Vor dem eigentlichen Tabellenplan besitzt die historische Reta-Oberfläche drei
besondere Startpfade:

- ein leerer Aufruf schreibt exakt `Versuche Parameter -h\n`;
- reine `-language=...`-Vektoren initialisieren nur die Sprache und schreiben
  keine Bytes;
- jedes Vorkommen von `-h` oder `-help` schreibt den vollständigen lokalisierten
  Hilfetext einmal.

Der bisherige native Ownership-Prüfer erkannte diese Grenze nicht zuverlässig.
Insbesondere wurde `reta -language=english` als gültiger Tabellenaufruf
beansprucht und erzeugte fälschlich die vollständige Standardtabelle, obwohl die
Python-Referenz einen leeren Strom liefert. Auch reine Hauptparameter wie
`-zeilen` durften nicht ohne Nebenoption in den Tabellenkern gelangen.

Stage 12c4q führt deshalb `native_cli_startup.mojo` vor jeder Tabellenplanung
aus. Die Implementierung besitzt konservativ nur die reproduzierten
Startvektoren. Unbekannte Tokens, nicht unterstützte Sprachen oder gemischte
Argumente bleiben vollständiger atomarer Referenzfallback.

## Bytegenaue Hilfedaten

Die vollständigen deutschen und englischen Hilfetexte liegen als unveränderliche
generierte Ressourcen vor:

```text
assets/reta_help_de.txt    12.042 Byte
assets/reta_help_en.txt    11.409 Byte
```

`tools/generate_native_cli_help_assets.py` erzeugt sie deterministisch aus der
gebündelten Python-Referenz oder prüft sie mit `--check`. Der normale native
Aufruf liest nur diese Dateien und startet weder Python noch eine eingebettete
Python-Laufzeit. Bei einer FHS-Installation werden sie zusammen mit den übrigen
Assets unter `${PREFIX}/share/reta/assets` installiert.

Die historische Regel „erste Sprachwahl gewinnt“ bleibt erhalten. Mehrere
`-h`-/`-help`-Tokens wiederholen den Hilfetext entsprechend oft.

## Ownership-Grenze

`native_reta_tokens_supported` verlangt für den Tabellenpfad nun mindestens eine
wirkliche Nebenoption. Hauptparameter ohne Option werden nicht mehr als
Standardtabelle interpretiert. `RETA_FORCE_REFERENCE=1` hat weiterhin Vorrang
und erzwingt die vollständige Python-Referenzoberfläche.

## Reproduzierbare Prüfungen

```bash
python3 tools/generate_native_cli_help_assets.py --check
scripts/check_native_cli_startup_parity.sh
scripts/check_install_layout.sh
```

Die Startparität umfasst sieben vollständige stdout-/stderr-Ströme: leerer
Aufruf, deutsche und englische reine Sprachwahl, deutsche und englische Hilfe,
doppelte Hilfe und die Regel der ersten Sprachwahl.
