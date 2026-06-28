# Öffentliche Programme und echte Compilerprodukte

## Wichtige Unterscheidung

Die Dateien in `bin/` sind stabile POSIX-Shell-Launcher. Sie sind ausführbar, aber nicht kompiliert. Die echten Mojo-Compilerprodukte liegen unter `target/bin/` und werden durch `.gitignore` ausgeschlossen.

```bash
./scripts/build.sh
./scripts/check_build_layout.sh
```

## Öffentliche Laufzeitnamen

Alle folgenden Namen existieren in der Projektwurzel und unter `bin/` beziehungsweise `run/`:

```text
reta
reta.english
retaPrompt
retaPrompt.english
rp
rpl
rpb
rpe
prim
prim24
multis
multis3
modulo
math
grundStrukHtml
grundStrukHtml.py
generate_html
```

Zusätzlich bleiben `reta.sh`, `rp.sh` und `rpl.sh` erhalten.

## Zuordnung zu kompilierten Programmen

| Öffentliche Namen | Kompiliertes Ziel | Stand |
|---|---|---|
| `prim`, `prim24`, `multis`, `multis3`, `modulo`, `rp`, `rpl`, `rpb`, `rpe`, `retaPrompt*` | `target/bin/reta-prompt-native` | Promptcontroller und diese Arithmetikbefehle nativ; komplexe Kurzbefehle einzeln über Bridge |
| `grundStrukHtml*` | `target/bin/grundStrukHtml-native` | Renderer nativ |
| `generate_html` | `target/bin/generate-html-native` | Komposition nativ; große `middle.alx`-Berechnung noch Bridge |
| `reta` / `reta.english` | `target/bin/reta-mojo-compat-bin` | vollständige historische Tabellen-CLI noch Bridge |
| `bin/reta-mojo --mojo-*` | mehrere spezialisierte Ziele | native Kern-, Schema-, Tabellen- und Architektur-CLI |

## Beispiele

```bash
./rpb prim 60
./multis3 36
./bin/reta-mojo --mojo-tags 216
./bin/reta-mojo --mojo-wrap 2 'äöü漢字'
./grundStrukHtml.py blank
./generate_html > religionen-tabelle.html
```

## Lokale Installation

```bash
./scripts/install_bins.sh
```

Hierbei werden die Launcher nach `~/.local/bin` verlinkt. Die Launcher finden die lokal kompilierten Dateien in `target/bin`.
