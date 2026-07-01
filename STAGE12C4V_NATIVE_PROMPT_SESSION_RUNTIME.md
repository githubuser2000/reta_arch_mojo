# Stage 12c4v – native Prompt-Sitzung und Prompt-Runtime

## Ziel

Stage 12c4v übernimmt zwei noch atomar als Python-Bridge geführte Besitzer des
interaktiven Promptpfads:

- `reta_architecture/prompt_runtime.py` (158 Zeilen)
- `reta_architecture/prompt_session.py` (543 Zeilen)

Die **701 Python-Zeilen** werden nun durch typisierte Mojo-Zustände sowie einen
reproduzierbar erzeugten fünfsprachigen Laufzeitvertrag ersetzt. Die bereits
native POSIX-/TTY-Grenze bleibt der Eingabeadapter; es wird weder ein
`prompt_toolkit`-Objekt noch ein Python-Callback in Mojo gehalten.

## Native Besitzer

### `prompt_session.mojo`

Das neue Modul besitzt:

- `PromptTextState` mit normaler und klammerbewusster Tokenisierung,
- `PromptLoopSetup` und die sieben historischen Promptmodi,
- `NativePromptSession` mit History-, Speicher- und Löschzustand,
- Speicherung vor/nach dem aktuellen Befehl,
- nummerierte gespeicherte Tokens,
- positions-, bereichs- und wertbasierte Löschung,
- selektive und kombinierte Speicherausgabe,
- lokalisierte Promptpräfixe,
- den Snapshotvertrag des früheren `PromptSessionBundle`.

`prompt_main.mojo`, `native_prompt_input.mojo` und die Tests importieren diesen
einzigen Besitzer. Die frühere zweite `NativePromptSession`-Definition in
`prompt_runtime.mojo` wurde entfernt.

### `prompt_runtime.mojo` und `prompt_runtime_catalog.mojo`

Der reine Runtime-Kern besitzt das Primzahlprädikat und typisierte Verträge für
Programm-, Parameter- und Vokabularsicht. Der Generator
`tools/generate_prompt_runtime_catalog.py` startet jede Sprache in einem
frischen Python-Referenzprozess und friert folgende Daten für Deutsch,
Englisch, Vietnamesisch, Chinesisch und Koreanisch ein:

- Hauptparameter und ihre wirksamen Indizes,
- `paraNdataMatrix`, `paraDict` und alle `dataDict`-Größen,
- beide Kombinations-Rückabbildungen,
- einfache Spaltenbefehle und maximale Zeilen,
- elf Vokabulargrößen,
- `wahl15`-Validierung,
- normale, Speicher- und Lösch-Promptpräfixe.

Die frischen Prozesse sind notwendig, weil der Python-Referenzbaum seine
i18n-/Architekturobjekte pro Prozess cached. Der erzeugte Mojo-Katalog ist
reproduzierbar und benötigt zur Laufzeit keine Python-Initialisierung.

## Während der Portierung behobene Mojo-Abweichungen

### History-Umschalter wurden protokolliert

Die bisherige native Eingabe schrieb `loggen`, `nichtloggen` und ihre
lokalisierten Aliase in die History. Das Python-Original schließt genau diese
beiden Umschaltbefehle aus. `history_should_append` klassifiziert jetzt über den
fünfsprachigen Aliasbestand, bevor eine Zeile gespeichert wird.

### Dezimaler Löschwert wurde immer als Position interpretiert

Bei gespeichertem `reta 2 --nocolor` bedeutet die Löschangabe `2` im
Python-Original den literal gespeicherten Wert `2`. Nur wenn kein gleicher
Dezimaltoken existiert, ist `2` die zweite Position. Der native
Löschalgorithmus bildet diese ungewöhnliche Prioritätsregel nun exakt ab.

### Promptpräfixe waren deutsch und enthielten zusätzliche Leerzeichen

Der alte Mojo-Zustand zeigte unabhängig von der Sprache `speichern> `,
`loeschen> ` und `> `. Der Python-Vertrag lautet dagegen exakt `>`,
`was speichern>`/`was löschen>` beziehungsweise
`save what>`/`delete what>`. Die Präfixe sind nun Teil des generierten
Laufzeitvertrags und werden vom produktiven Promptcontroller übernommen.

Die drei Befunde sind als `MOJO-FIXED-020` bis `MOJO-FIXED-022` im zentralen
Fehlerkatalog erfasst. Das Python-Original ist in diesen Fällen die korrekte
Referenz und wird nicht verändert.

## Validierung

```text
Prompt-Runtime-Bestandstests:          30/30
Prompt-Sitzungs-Unit-Tests:            10/10
Prompt-Runtime-Vertragstests:           5/5
Native-Prompt-Input-Tests:              4/4
Python↔Mojo-Sitzungsparität:           36/36 Kontexte byteidentisch
  Deutsch:                             18/18
  Englisch:                            18/18
Python↔Mojo-Runtimevertrag:              5/5 Sprachen byteidentisch
Katalogregeneration:                     reproduzierbar
Produktiver englischer PTY-Präfix:       1/1 exakt
Source-/Ownership-/Manifest-Pytests:   33/33 im gebauten Baum
entpackte reine Source-Gates:             28/28
FHS-Installations-Pytests:                  5/5 im gebauten Baum
aktive std.python-Brücken:                 0
Quellmanifest:                           1092/1092
```

Die Sitzungsmatrix prüft leere, kompakte, wiederholt getrennte und
UTF-8-haltige Texte, Positions-/Bereichs-/Tokenlöschung, den dezimalen
Doppeldeutigkeitsfall, alle Speicherausgabemodi, History-Umschalter sowie die
Kombination gespeicherter und aktueller Befehle. Ein echter PTY-Lauf aktiviert anschließend mit `S` den englischen Speicherzustand und bestätigt sichtbar `save what>` ohne das frühere zusätzliche Leerzeichen.

## Buildbefund

Die veränderten Runtime-, Session- und Eingabemodule wurden als eigenständige
ELF-Tests kompiliert und ausgeführt. Der vollständige produktive
`src/prompt_main.mojo`-Controller wurde anschließend in der Sandbox in
**11,98 Sekunden** kompiliert und mit einem englischen nativen Einmalbefehl
geprüft:

```text
retaPrompt -language=english -befehl prime 12
12: 2^2 3
```

Damit bestätigt bereits der fokussierte Sandboxbuild die vom Nutzer seit Stage
12c4r beobachtete deutliche Buildbeschleunigung. Anschließend lief auch der
vollständige reguläre Build durch: `scripts/build.sh` erzeugte alle **9/9**
Standardziele einschließlich `reta-native` in **2:24,55 Minuten**. Das
Buildlayout, die FHS-Testinstallation und sämtliche ELF-RUNPATHs wurden danach
geprüft; kein Ziel enthält einen Sandbox- oder `.venv`-Pfad. Das endgültige
Source-only-Archiv enthält absichtlich kein `target/`: Nach separatem Entpacken
bestanden dort **28/28** reine Source-Gates. Die fünf Installations-Pytests
benötigen gebaute ELF-Dateien und bestanden deshalb getrennt im gebauten Baum.

## Fortschrittswirkung

- vollständig native/reproduzierbar generierte Originaldateien:
  **38/92 → 40/92 = 43,5 %**
- mindestens teilweise portierte Originaldateien:
  **66/92 → 68/92 = 73,9 %**
- gewichteter Quellzeilenstand:
  **ca. 54,2 % → ca. 55,6 %**
- geschätzte funktionale Oberfläche:
  weiterhin **96–98 %**

Der Funktionswert steigt kaum, weil der Prompt bereits nutzbar war. Der Gewinn
liegt im echten Besitzerwechsel: Sitzungszustand und Runtimeobjekt werden nicht
mehr nur durch vorhandene native Einzelfunktionen angenähert, sondern sind als
geschlossene typisierte Verträge portiert.

## Gesamtprüfung der Stage

```bash
scripts/test_stage12c4v.sh
```

Der Sammeltest baut die vier fokussierten Mojo-Testprogramme, führt beide
Python↔Mojo-Paritätsmatrizen, die reproduzierbare Katalogregeneration, die
Source-/Ownership-Gates und – nach einem regulären Build – den echten
englischen PTY-Präfixtest aus.
