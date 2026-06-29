# Stufe 10 – native ganzzahlige Prompt-Tabellenplanung

## Ergebnis

Die hintere `prompt_execution.py`-Strecke besitzt jetzt eine besitzende Mojo-Zwischenrepräsentation:

```text
Promptzeile
  → lokalisierte kanonische Wörter
  → Zahlen-/Modifikatoranalyse
  → PromptTablePlan
  → 1..n PromptTableInvocation
  → kompilierter reta-native-Tabellenkern
```

`src/reta_mojo/prompt_table_execution.mojo` enthält keine Tabellenberechnung. Es plant ausschließlich die historischen CLI-Argumente und übergibt sie an den bereits nativen Tabellenkern. Dadurch bleibt Parser-, Planungs- und Renderverantwortung getrennt.

## Nativ geplante Familien

| Promptfamilie | Native Tabellenoption | Ergebnispositionen |
|---|---|---|
| `mond` | `--Bedeutung=gestirn` | `3-6` |
| `richtung`, `r` | `--Primzahlwirkung=Galaxieabsicht` | alle |
| `primzahlkreuz` | `--Bedeutung=primzahlkreuz` | alle |
| `alles` | `--alles` | alle |
| `thomas`, `t` | `--galaxie=thomas` | `2` |
| `emotion`, `E` | `--grundstrukturen=emotion` | `2,3` |
| `wirklichkeit`, `W` | Grundstruktur Wirklichkeit/Wahrnehmung | `1,2` |
| `triebe`, `T` | Grundstrukturen `trieb,System` | `1` |
| `impulse`, `I` | Grundstruktur Impulse | `1,4` |
| `bewusstsein`, `B` | historische 15er-Grundstrukturkombination | `6` |
| `geist`, `G` | `--grundstrukturen=geist` | `3` |
| `freiheit`, `gleichheit` | `--planet=freiheit` | `1-4,8` |
| `groesse` | Organisation plus Größenordnung | `1-3` und `1,2` |
| `kugeln`, `kreise` | `--universum=kreise` | `1-2` |
| `netzwerk` | `--universum=netzwerk` | `1-3` |
| `komplex` | `--universum=komplex` | `1` |
| `absicht`, `motiv`, `a` | `--menschliches=motive` | `1` |
| `universum`, `u` | `--universum=transzendentalien` | bedingt `1,4` oder `1` |

`range` wird als `--zaehlung`, `invertieren` als `--invertieren` und vorhandene Ausgabeparameter unverändert weitergereicht. Mehrere Fachfamilien in einer Promptzeile erzeugen mehrere Invocations.

## Bewusste Fallbackgrenze

Folgende Kombinationen bleiben vollständig bei der Python-Referenz:

- Brüche und gebrochen-rationale Bereiche (`1/n`, `n/m`)
- `vielfache` / `v`
- `teiler` / `w`
- `einzeln`

Das ist eine semantische Sicherheitsgrenze. Ein teilweise ausgeführter gemischter Befehl wäre schlechter als ein vollständiger Referenzfallback.

## Prüfung

- 10/10 Mojo-Planertests
- 15/15 Prompt-Sprachtests
- 21/21 Prompt-Laufzeittests
- 8/8 Bruchausführungstests
- 18/18 Bruch-/Bereichsparitätsfälle
- 7/7 bestehende reale Prompt-Ausführungsfixtures bytegleich
- Rauchtests aller neu hinzugefügten Tabellenfamilien mit Rückgabecode 0
