# Stage 12c5ab – Prepare-Wrappingvertrag und vollständige LibRetaPrompt-Fassade

## Korrektur des lokalen Modular-Tests

Der lokale Lauf von `scripts/test_stage12c5aa.sh` zeigte keinen Fehler im
nativen Wrappingkern. Der direkte Vertrag
`Prepare.cellWork("abcdef", 3) -> ["abc", "def"]` bestand bereits. Der
fehlgeschlagene Zeilenvorbereitungstest erzeugte dagegen einen Kontext mit
`shell_rows_amount=0`. Dieser Wert bedeutet in Python und Mojo ausdrücklich
**unbegrenzte Terminalbreite**; deshalb war `["abcdef"]` korrekt.

Der Test besitzt nun beide Grenzfälle explizit:

- `shell_rows_amount=0`: kein erzwungener Umbruch,
- `shell_rows_amount=80`, `text_width=3`: Umbruch zu `["abc", "def"]`.

Damit ist `TEST-FIXED-030` geschlossen, ohne die produktive Semantik an eine
falsche Testerwartung anzupassen.

Die vom Compiler gemeldeten Warnungen in `table_adapters.mojo` sind ebenfalls
beseitigt:

- leere Strings werden mit `byte_length()` statt dem veralteten
  `len(String)` geprüft,
- der boolesche Zustand `accepted` wird nur einmal und tatsächlich genutzt
  initialisiert.

Dies ist als `MOJO-FIXED-047` dokumentiert.

Außerdem war die vor Stage 12c5aa umbenannte Datei
`scripts/test_stage12c5z.sh` noch als alte, produktiv bauende Dublette im
Quellbaum vorhanden. Sie ist entfernt; nur
`scripts/build-and-test-shared-diagnostics.sh` darf den optionalen DSO- und
Orakelbuild ausführen (`TEST-FIXED-031`).

## Vollständiger Besitzer von libs/LibRetaPrompt.py

`src/reta_mojo/legacy_libreta_prompt.mojo` ersetzt die historische
Importzeit-Fassade durch ein explizites `LegacyLibRetaPromptBundle`. Die
Python-Datei definiert keine eigenen Klassen oder Algorithmen, sondern
reexportiert Helfer, bootstrapped fünf Laufzeitbündel und materialisiert
Sammlungen als Modulglobals. Der native Besitzer bildet alle **48** importierten
und materialisierten Namen ab und delegiert an die bereits nativen Besitzer:

- `input_semantics.mojo`,
- `prompt_runtime.mojo` und `prompt_runtime_catalog.mojo`,
- `completion_runtime.mojo`,
- `prompt_language.mojo`,
- `prompt_session.mojo`,
- `legacy_center.mojo`,
- `runtime_compat.mojo`.

Explizit besessen werden unter anderem:

- Runtime-, Completion-, Sprach-, Sitzungs- und Programmvertrag,
- alle 21 historischen Vokabular-, Mengen-, Befehls- und Wahlglobals,
- die sieben `PromptModus`-Werte,
- die Hilfsoberflächen für Reta-Parameter, 15/16-Kommandos,
  Kurzkommandoumsetzung, Dictionary-Verkürzung und Bruch-/Ganzzahlprüfung,
- deterministischer Snapshot und ein 27-Felder-Python-/Mojo-Paritätsprobeweg.

Es entsteht bewusst **keine neue installierbare Executable**. Der fokussierte
Modultest und die Paritätsprobe liegen ausschließlich unter `target/tests`:

```bash
scripts/test_stage12c5ab.sh
```

## Metriken

```text
vollständig nativ/generiert:       73/92 = 79,3 %
mindestens teilweise portiert:     83/92 = 90,2 %
angegriffene Referenzzeilen:        38.174/48.831 = 78,2 %
vollständig native Referenzzeilen:  32.183/48.831 = 65,9 %
Mojo-Zeilen in src/:                57.622
davon in src/reta_mojo/:            53.065
```

## Compilerunabhängige Prüfung

```text
portable Source-Tests:             158 bestanden, 1 Skip
```

Die echte Mojo-Kompilierung des korrigierten Prepare-Tests und der neuen
LibRetaPrompt-Fassade ist im Stage-Skript vorbereitet. In der
Erstellungsumgebung ist kein offizieller Modular-Compiler installiert; der
lokale Lauf beim Nutzer bleibt daher das maßgebliche Compiler-Gate.
