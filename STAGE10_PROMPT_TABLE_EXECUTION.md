# Stufe 10 – native Prompt-Tabellenplanung

## Ergebnis

Die hintere `prompt_execution.py`-Strecke besitzt jetzt eine besitzende Mojo-Zwischenrepräsentation:

```text
Promptzeile
  → lokalisierte kanonische Wörter
  → Zahlen-, Bruch- und Modifikatoranalyse
  → PromptTablePlan
  → 1..n PromptTableInvocation
  → kompilierter reta-native-Tabellenkern
```

`src/reta_mojo/prompt_table_execution.mojo` berechnet keine Tabellenzellen. Es plant die historischen CLI-Argumente und übergibt sie an den bereits nativen Tabellenkern. Parser, Planung, Generatoren und Rendering bleiben dadurch getrennte Schichten.

## Nativ geplante Familien

| Promptfamilie | Ganzzahl/Reziprok | echte `n/m`-Spalten |
|---|---|---|
| `emotion`, `E` | ja | Gefühle |
| `groesse` | ja, zwei Tabellen | Strukturgröße |
| `absicht`, `motiv`, `a` | ja | Galaxie |
| `universum`, `u` | ja | Universum plus Gleichheitsachse |
| `wirklichkeit`, `triebe`, `impulse`, `bewusstsein`, `geist` | ja | noch keine eigene Bruchspaltenfamilie im Originalzweig |
| `freiheit/gleichheit`, `kugeln/kreise`, `netzwerk`, `komplex` | ja | noch keine eigene Bruchspaltenfamilie im Originalzweig |
| `mond`, `richtung`, `primzahlkreuz`, `alles`, `thomas` | ja | nicht als Bruchtabellenbefehl definiert |

Insgesamt bleiben die bereits portierten **18 Fachfamilien** erhalten. Neu hinzugekommen sind ihre positiven Bruchachsen, reduzierte Ganzzahl-/Reziprokanteile sowie historische Bruchbereichsausdrücke.

## Native Zahlen- und Bruchsemantik

Nativ geplant werden:

- ganze Zahlenbereiche
- `vielfache` / `v` für ganzzahlige Bereiche
- `teiler` / `w` für ganzzahlige Bereiche
- `einzeln`
- einfache positive Brüche wie `2/3`
- getrennte Achsenbereiche wie `1-3/2-5`
- historische Rechtecksyntax wie `1/2-3/3`
- historische Versatzsyntax wie `4/5+2/2`
- Reduktion auf ganze Zahlen und Reziproke
- gleiche Zähler/Nenner für die besondere Universumsachse

Mehrere Zähler werden in der beobachtbaren positiven Referenzreihenfolge aufsteigend ausgeführt. Nennerreihenfolgen und Mehrfachaufrufe bleiben erhalten.

## Bewusste Fallbackgrenze

Weiterhin vollständig an der Python-Kompatibilitätsgrenze bleiben:

- Bruchausschlüsse wie `-1/2`
- mit `v` präfixierte Bruchausdrücke wie `v1/2`
- Brüche zusammen mit `vielfache` oder `teiler`
- Brüche bei Fachbefehlen ohne historische Bruchtabellensemantik, etwa `mond 1/2`

Der gesamte Befehl fällt zurück. Es gibt keine halb native Ausführung, die nur einen Teil der Legacy-Mengenalgebra verschluckt.

## Kernkorrekturen

Im Zuge der Paritätsprüfung wurden zwei Fehler des nativen Tabellenkerns behoben:

1. `--nocolor` deaktiviert nun tatsächlich ANSI-Sequenzen im Shellrenderer.
2. Eine explizite Ergebnisposition außerhalb der erzeugten Spaltenmenge liefert keine Spalte mehr, statt irrtümlich auf alle Spalten zurückzufallen.

Der Promptcontroller trennt außerdem die ausgegebene `reta`-Befehlszeile wieder durch einen Zeilenumbruch von der ersten Tabellenzeile.

## Prüfung

- 16/16 Mojo-Planertests
- 15/15 Prompt-Sprachtests
- 21/21 Prompt-Laufzeittests
- 8/8 Bruchparser-/Achsentests
- 18/18 reine Bruch-/Bereichsparitätsfälle bytegleich
- 10/10 reale Bruch-/Modifikatorfälle als normalisierte CSV-Tokenströme identisch
- 7/7 bestehende Prompt-Ausführungsfixtures bytegleich
- 11/11 native CLI-Plantests
- 4/4 Renderertests
