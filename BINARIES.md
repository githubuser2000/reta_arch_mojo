# Öffentliche Startprogramme

Die historischen Laufzeit-Startnamen des Python-Projekts sind im Mojo-Port wieder direkt vorhanden. Jeder Name kann aus dem Projektwurzelverzeichnis, über `bin/` oder über `run/` gestartet werden.

| Name | Profil/Funktion | Aktueller Ausführungspfad |
|---|---|---|
| `reta` | vollständige Tabellen-CLI | Mojo-Kompatibilitätslauncher → isolierte Python-Referenz |
| `reta.english` | Tabellen-CLI mit englischen Parametern | wie `reta`, zusätzlich `-language=english` |
| `retaPrompt` | interaktiver Prompt, Emacs-Modus, History | nativer Mojo-Controller |
| `retaPrompt.english` | englisches Promptprofil | nativer Mojo-Controller; noch nicht alle nativen Meldungen übersetzt |
| `rp` | interaktiv, Vi-Modus, History | nativer Mojo-Controller |
| `rpl` | interaktiv, Vi-Modus, reduzierte Startausgabe, kein Logging | nativer Mojo-Controller |
| `rpb` | genau einen Promptbefehl ausführen | nativer Mojo-Controller |
| `rpe` | Einmalbefehl mit Emacs-Ausgabeparametern | nativer Mojo-Controller |
| `prim` | Primfaktorzerlegung | vollständig nativer Mojo-Algorithmus |
| `prim24` | Primfaktoren modulo 24 | vollständig nativer Mojo-Algorithmus |
| `multis` | Faktorpaare | vollständig nativer Mojo-Algorithmus |
| `modulo` | historische Modulo-Tabelle | vollständig nativer Mojo-Algorithmus |
| `math` | Ausdruck wie im historischen Shellskript auswerten | Mojo-Promptcontroller → explizite Prozess-/Python-Grenze |

Zusätzlich bestehen die historischen Aliasnamen `reta.sh`, `rp.sh` und `rpl.sh`. Sie aktivieren keine virtuelle Umgebung mehr, weil die Launcher `.venv/bin/mojo` selbst finden.

## Drei Pfadformen

Diese Aufrufe sind gleichwertig:

```bash
./rp
./bin/rp
./run/rp
```

Für eine Installation in den Benutzer-PATH:

```bash
./scripts/install_bins.sh
```

Standardziel ist `~/.local/bin`. Ein anderes Ziel kann als erstes Argument angegeben werden.

## Native Promptgrenze

Nativ in Mojo sind:

- Profile und Startparameter von `retaPrompt`, `rp`, `rpl`, `rpb`, `rpe`
- interaktive Schleife und Sitzungszustand
- Befehlsklassifikation
- Logging-Umschaltung und History-Politik
- Speichern, Ausgeben und Löschen zusammengesetzter Promptbefehle
- `prim`, `prim24`, `multis`, `modulo`, `abc`
- `rpe`-Umschreibung für Emacs-Ausgabe
- der aus 388 Referenzwörtern erzeugte Completion-Katalog

Betriebssystemdienste bleiben eine schmale Bridge: GNU-readline, Historydatei und Kindprozesserzeugung. Noch nicht portierte komplexe Kurzbefehle, beispielsweise `a 2`, werden einzeln an die Python-Referenz gegeben. Der interaktive Hauptprozess und sein Zustand bleiben dabei Mojo.

`coden`, `csvs`, `rpmake` und die HTML-Paketierungsskripte sind Entwicklungs-/Releasewerkzeuge, keine Laufzeit-Startprogramme. Sie wurden nicht als Mojo-Binaries ausgegeben, weil sie lokale Git-Branches, `fzf`, Neovim, LibreOffice oder fest codierte Rechnerpfade steuern.
