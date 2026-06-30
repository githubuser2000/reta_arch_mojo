# Stage 12c1 – native Terminalgeometrie und Prompt-Zeilengrenzen

Stage 12c wird in kleinere, kompilierbare Blöcke geteilt. 12c1 korrigiert zwei
beobachtbare Abweichungen des nativen Promptpfads, ohne die öffentliche CLI zu
ändern:

```bash
bin/rpb a1
bin/rpb -befehl a1
```

## Behobene Abweichungen

### 1. Befehlszeile und Tabellenkopf

Die Python-Referenz ruft für die farbige Befehlsdarstellung intern
`Console.print(Syntax(...), end="")` auf. Das `Syntax`-Renderable erzeugt jedoch
selbst eine vollständige physische Zeile. Der frühere Mojo-Port übernahm das
interne `end=""` statt des beobachtbaren Bytestroms und klebte dadurch den
ersten Tabellenkopf an die sichtbare `reta`-Befehlszeile.

Der native Controller beendet die sichtbare Befehlszeile nun immer mit genau
einem LF, bevor der Tabellenrenderer beginnt.

### 2. `--breite=0`

`--breite=0` bedeutet historisch nicht 80 Spalten. Es bedeutet, die aktuelle
TTY-Breite zu verwenden und sieben Spalten für Rand- und Nummerierungslogik zu
reservieren. Der frühere Mojo-Renderer verwendete die Konstanten 80/73.

`terminal_geometry.mojo` fragt auf Linux die reale Fenstergröße per
`ioctl(TIOCGWINSZ)` ab. Die Reihenfolge lautet:

1. stdout,
2. stdin,
3. stderr,
4. Umgebungsvariable `COLUMNS`,
5. historischer Fallback 80.

Positive explizite Breiten werden wie zuvor auf die automatisch verfügbare
Breite begrenzt. Die öffentliche Bedeutung von `--breite=0` entspricht damit
wieder der Python-Referenz.

## Tests

- nativer Geometrietest: 3/3;
- echte PTY-Probe: 80→73, 120→113, 200→193;
- Fixture-Integrität verbietet `reta-Befehl:reta ...` und ANSI-Tabellenbytes auf
  der sichtbaren Befehlszeile;
- elf kompakte Promptfixtures besitzen eine explizite Befehls-/Tabellengrenze;
- der PTY-Paritätstest führt exakt `bin/rpb a1` und die Python-Referenz bei 80,
  120 und 200 Spalten aus und vergleicht die sichtbaren Zeilen bytegleich.

Der letzte PTY-Ende-zu-Ende-Test benötigt das lokal neu gebaute
`target/bin/reta-prompt-native`. In der Sandbox überschritt dessen monolithische
Mojo-Elaboration auch das verdoppelte Compilerlimit; der kleine native
Terminalgeometriebaustein und seine Tests wurden hier vollständig gebaut und
ausgeführt.

## Verbleibender Stage-12c-Umfang

12c1 entfernt noch nicht die `std.python`-Grenze des interaktiven Prompt-
Callbacks. Offen bleiben insbesondere der native interaktive Eingabekanal,
seltene hintere Promptzweige und die restliche i18n-Laufzeit. Deshalb gilt
Stage 12c nach diesem Block als begonnen, nicht als abgeschlossen.


Seit Stage 12c2 ist die ABI-Abhängigkeit explizit gekapselt: Linux/WSL und macOS verwenden getrennte `TIOCGWINSZ`-Requestwerte; andere Ziele nutzen `COLUMNS`/80.
