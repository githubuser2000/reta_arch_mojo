# Öffentliche Programme und Compilerziele

## Öffentliche Startnamen

Die historischen Namen bleiben in der Projektwurzel sowie unter `bin/` beziehungsweise `run/` verfügbar:

```text
reta                 reta-native
reta.english         retaPrompt
retaPrompt.english   rp rpl rpb rpe
prim prim24          multis multis3 modulo math
grundStrukHtml       grundStrukHtml.py
generate_html
```

## Wichtige Tabellenpfade

Vollständige Kompatibilität über die Python-Referenz:

```bash
./reta -zeilen --vorhervonausschnitt=1-3 \
  -spalten --religionen=sternpolygon
```

Expliziter nativer Stufe-6-Pfad:

```bash
./reta-native -zeilen --vorhervonausschnitt=1-3 \
  -spalten --religionen=sternpolygon \
  -ausgabe --art=csv --breite=40
```

Derselbe Pfad über den historischen Namen:

```bash
RETA_NATIVE=1 ./reta -zeilen --vorhervonausschnitt=1-3 \
  -spalten --religionen=sternpolygon \
  -ausgabe --art=csv --breite=40
```

Der Umschalter ist absichtlich explizit, solange nicht sämtliche Tabellenfunktionen nativ sind.

## Native Inspektionsprogramme

```bash
./bin/reta-mojo --mojo-prime 60
./bin/reta-mojo --mojo-range '1-9,-3' 100
./bin/reta-mojo --mojo-csv-info
./bin/reta-mojo --mojo-table-state 42
./bin/reta-mojo --mojo-wrap 2 'äöü漢字'
./bin/reta-mojo --mojo-tags 216
./bin/reta-mojo --mojo-tag-columns sternPolygon,universum
```

## Zuordnung

| Oberfläche | Compilerziel | Grenze |
|---|---|---|
| `reta-native`, `RETA_NATIVE=1 ./reta` | `target/bin/reta-native` | erster nativer Tabellenpfad |
| normale `reta`-Ausführung | `target/bin/reta-mojo-compat-bin` | vollständige historische Oberfläche |
| `rp`, `rpl`, `rpb`, `rpe`, `retaPrompt*` | `target/bin/reta-prompt-native` | Kurzsprache, Vorbereitung, Bruchbereiche, stabile Ausschlüsse, Bruchteiler, Reziprok-Vielfache und Kernbefehle nativ; echte `v n/m`-Vielfache und kollidierende Legacy-Sonderoperationen bleiben an der Bridge |
| interaktive verschachtelte Completion | `target/bin/reta-prompt-complete` | persistenter Mojo-Arbeiter; Readline ist nur Terminalgrenze |
| `grundStrukHtml*` | `target/bin/grundStrukHtml-native` | Renderer nativ |
| `generate_html` | `target/bin/generate-html-native` | Komposition nativ, große Mitteltabelle noch Bridge |
| Tabellenzustand/CSV/Wrapping | `target/bin/reta-mojo-table` | nativ |
| Tag-Schema | `target/bin/reta-mojo-tags` | nativ |

Lokale Installation der Launcher:

```bash
./scripts/install_bins.sh
```
