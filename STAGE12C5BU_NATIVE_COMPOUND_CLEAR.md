# Stage 12c5bu – natives zusammengesetztes `leeren`

## Ausgangslage

Das alleinstehende Promptkommando `leeren` war bereits nativ und sendete den
historischen ANSI-Clear- und Home-String. Im Python-Tabellenzweig besitzt
`leeren` jedoch eine andere Semantik: Es wird positionsunabhängig in der
vollständigen Promptwortmenge erkannt und gibt unmittelbar vor dem ersten
Tabellen- oder `mulpri`-Plan `os.get_terminal_size().lines + 1` Leerzeilen aus.
Diese zusammengesetzte Form fiel noch atomar an den Kompatibilitätspfad zurück.

Der erste Benutzerlauf von Stage 12c5bt zeigte außerdem einen Mojo-Testfehler:
`assert_equal` verlangt `Equatable & Writable`, während
`PromptHistoricalCompanionEffects` absichtlich nur `Equatable` ist.

## Native Umsetzung

`terminal_geometry.mojo` besitzt nun neben der Spaltenzahl auch die Terminalhöhe:

1. `ioctl(TIOCGWINSZ)` auf stdout,
2. danach stdin und stderr,
3. `LINES`, wenn kein Dateideskriptor ein Terminal ist,
4. schließlich 24 als portabler Fallback.

`compound_clear_line_count(rows)` bindet die beobachtbare Pythonregel
`max(1, rows) + 1`. Der Promptcontroller führt die Effekte in unveränderter
historischer Reihenfolge aus:

1. Kurzbefehle,
2. Befehle,
3. Hilfe,
4. Terminalzeilen plus eine Leerzeile,
5. Tabellen- beziehungsweise `mulpri`-Plan.

Die Erkennung von `leeren`/`clear` ist lokalisiert und positionsunabhängig. Der
atomare Eigentumswächter bleibt davor: Enthält derselbe Vektor einen unbesessenen
Effekt, wird keine Leerzeile teilweise ausgegeben.

Das alleinstehende `leeren` bleibt davon getrennt und verwendet weiterhin exakt
`ESC[2J ESC[H`.

## Laufzeitvertrag

Der native Prüfer trennt stdin, stdout und stderr vollständig von TTYs und setzt
`LINES=3`. Damit müssen

- `leeren emotion 1`,
- `emotion 1 leeren`,
- `clear emotions 1` im englischen Profil

jeweils genau vier führende Leerzeilen ausgeben und danach den nativen
Tabellenplan fortsetzen. Ein Kommando ohne `leeren` besitzt diesen Präfix nicht;
das alleinstehende `leeren` bleibt bytegenau der ANSI-String.

## Testkorrektur

Die Strukturvergleiche im Mojo-Test verwenden jetzt
`assert_true(first == second)` beziehungsweise
`assert_true(localized == first)`. Dadurch wird nur die vorhandene
`Equatable`-Semantik benötigt; eine künstliche `Writable`-Implementierung am
Produktionsdatentyp ist nicht erforderlich.

## Defekte

- `MOJO-FIXED-072`: zusammengesetztes positionsunabhängiges `leeren` fiel trotz
  bereits nativer Terminalgeometrie und Tabellenplanung an Python zurück.
- `TEST-FIXED-069`: der 12c5bt-Test verwendete `assert_equal` auf einer nicht
  `Writable`-Struktur und ließ sich deshalb nicht kompilieren.

## Benutzerprüfung

```sh
scripts/build-all.sh -- -j 8
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bu.sh -- -j 8
```
