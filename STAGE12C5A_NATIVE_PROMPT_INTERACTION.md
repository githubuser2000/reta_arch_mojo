# Stage 12c5a – native Prompt-Interaktions- und Controllergrenze

## Ziel

Die fachlichen Promptbausteine waren bereits nativ vorhanden: Sprache,
Completion, Sitzung, Vorbereitung, Terminaleditor und Befehlsausführung. Der
produktive Einstieg `prompt_main.mojo` besaß jedoch noch selbst die mutable
Interaktionsschleife. Gleichzeitig wurden `retaPrompt.py`,
`libs/LibRetaPrompt.py` und insbesondere
`reta_architecture/prompt_interaction.py` in der Besitzmatrix weiterhin nur als
Python-Referenz geführt.

Stage 12c5a zieht diese letzte Sitzungs- und Eingabenaht in einen eigenen,
typisierten Mojo-Besitzer. Der Prozesseinstieg bleibt für beobachtbare Ein-/
Ausgabe und Dispatch zuständig, entscheidet aber nicht mehr selbst über
Speicher-, Lösch-, Einmal- oder Previous-Command-Zustände.

## Neuer nativer Besitzer

`src/reta_mojo/prompt_interaction.mojo` enthält:

- `NativePromptInteraction` als mutablen Controllerzustand,
- `PromptInteractionInputPlan` als typisierte Grenze zwischen physischer
  Eingabe und Ausführung,
- Aktivierung einer sprachgebundenen nativen Sitzung aus `PromptStartup`,
- Zusammenbau des Einmalbefehls,
- Ctrl-C-/Ctrl-D-Abschluss,
- Konsumieren des nächsten zu speichernden Befehls,
- Löschselektion und Löschabbruch,
- die historische Regel, welche Befehle `previous_command` aktualisieren,
- einen stabilen Besitzsnapshot für Source- und Release-Gates.

Das Modul importiert weder `std.python` noch `PythonObject`. Die eigentliche
Befehlsausführung bleibt in den bereits vorhandenen nativen Besitzern und am
atomaren Referenzkindprozessrand für noch unbesessene Sonderbefehle.

## Produktive Aktivierung

`src/prompt_main.mojo` erzeugt jetzt genau einen
`NativePromptInteraction`-Zustand und führt jede physische Zeile zunächst durch
`accept_prompt_input`. Das Ergebnis ist einer von drei Plänen:

```text
INTERACTION_EXECUTE   Zeile an den nativen Dispatch übergeben
INTERACTION_CONTINUE  Modus intern abgeschlossen; nur Ausgabelinien drucken
INTERACTION_EXIT      Schleife sauber beenden
```

Die zuvor offene Controller-Aktivierungsnaht ist damit geschlossen. Alle
öffentlichen Starter `rp`, `rpl`, `rpb`, `rpe`, `retaPrompt` und
`retaPrompt.english` wählen weiterhin standardmäßig
`target/bin/reta-prompt-native`.

## Parität

Die ausgelagerten Entscheidungen entsprechen byte- und zustandsgenau dem
vorherigen produktiven Mojo-Controller:

- `store_next` speichert die Eingabe und setzt den Modus zurück,
- `delete_next` akzeptiert Auswahl oder lokalisierten Exitbefehl,
- Ctrl-C und Ctrl-D gelangen nicht in die Befehlsklassifikation,
- Storage- und Loggingkommandos überschreiben den vorherigen Befehl nicht,
- One-shot-Tokens werden unverändert über den Runtimevertrag zusammengesetzt.

Der Python-Controllervertrag ist verteilt vollständig abgebildet: Runtime,
Completion, Sitzung, Vorbereitung und Ausführung lagen bereits in eigenen
nativen Modulen; diese Stage übernimmt die verbleibende Orchestrierung.

## Gefundene Quellhygiene-Regression

Das hochgeladene Stage-12c4z-Archiv enthielt erneut die tote Datei
`src/reta_mojo/prompt_python_bridge.mojo` mit einem `std.python`-Import, obwohl
sie weder gebaut noch verwendet wurde und die dokumentierten Gates ihre
Abwesenheit verlangten. Die Datei ist wieder entfernt. Der vorhandene Eintrag
`MOJO-FIXED-017` wurde um diese erneute Reproduktion und das neue Source-Gate
ergänzt; der zentrale Katalog bleibt bei 59 Einträgen.

## Validierung

```text
native Prompt-Interaktionsmodultests:       7/7
Prompt-Sitzungsparität deutsch:            18/18 byteidentisch
Prompt-Sitzungsparität englisch:           18/18 byteidentisch
Source-/Ownership-/Boundary-Pytests:       18/18
Defektkatalog:                             59 Einträge konsistent
spätere Python-Bereinigungspunkte:         16
aktive std.python-Brücken:                  0
```

Der kleine Modulbuild wurde mit Mojo 1.0.0b2 erzeugt und ausgeführt. Der
vollständige neue `prompt_main.mojo` wurde außerdem erfolgreich bis zu einer
86-MiB-LLVM-IR-Datei kompiliert. Das abschließende Linken des großen
Produktionsprogramms lieferte in der Sandbox auch nach 20 Minuten keinen
Compilerfehler, überschritt aber das Ausführungslimit. Deshalb wird kein in
dieser Umgebung neu gelinktes Produktions-ELF behauptet. Der lokale
reproduzierbare Nachweis lautet:

```bash
RETA_BUILD_PROMPT=1 scripts/test_stage12c5a.sh
```

Ohne diese Variable führt derselbe Runner alle schnellen Modul-, Paritäts-,
Source-, Ownership- und Defektgates aus.

## Fortschrittswirkung

- vollständig native oder reproduzierbar generierte Originaldateien:
  **45/92 → 46/92 = 50,0 %**,
- mindestens teilweise portierte Originaldateien:
  **75/92 → 78/92 = 84,8 %**,
- gewichteter Quellzeilenersatz:
  **ca. 68,8 % → ca. 69,7 %**,
- nativer Mojo-Quellcode in `src/`: **45.068 Zeilen**,
- davon im Paket `reta_mojo`: **41.824 Zeilen**,
- funktionale Oberfläche: weiterhin **96–98 %**.

`prompt_interaction.py` gilt nun als vollständig nativ verteilt. Die beiden
historischen öffentlichen Python-Fassaden gelten als weitgehend nativ, weil
die produktiven Starter den Mojo-Controller aktivieren, während ausdrücklich
noch unbesessene hintere Befehle atomar in die eingefrorene Python-Referenz
wechseln.
