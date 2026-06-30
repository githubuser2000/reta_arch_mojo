# Stage 12c4c – native gemischte reziproke Modifier

Stage 12c4c verkleinert den atomaren Promptfallback um eine weitere semantische
Klasse. Kombinationen aus `vielfache`, `teiler` und stabilen reziproken
Brüchen `1/n` werden vollständig im Mojo-Tabellenplaner ausgeführt.

## Referenzvertrag

Die Python-Referenz wurde vor dem Renderer am Aufruf von `retaExecuteNprint`
instrumentiert. Dadurch wird nicht nur der Tabelleninhalt, sondern der genaue
Argumentplan vermessen:

- `universum vielfache teiler 1/2` expandiert zu `2,4,...,1022`;
- `universum v1/2 teiler` ist derselbe semantische Plan;
- `universum vielfache teiler 1/2,-1/4` entfernt alle Vielfachen von vier;
- `teiler` zählt bei der historischen Universum-Spaltenwahl mit, weshalb nur
  Spalte `1` statt `1,2` gewählt wird;
- die bereits vollständig materialisierte Reziprokachse trägt kein zusätzliches
  `--oberesmaximum`;
- der historische Hauptparameter wird exakt als `--Universum` und nicht als
  `--universum` geschrieben;
- echte Vielfache `v n/m` mit Zähler größer eins bleiben Fallback, weil die
  Python-Referenz dort selbst mit `IndexError` abbricht.

Zusätzlich bildet Mojo die historische leere Ganzzahlseite bei einem reinen
positiven `teiler 1/n` bytegenau als abschließendes Komma ab, etwa
`--vorhervonausschnitt=2,`.

## Implementierung

`prompt_table_execution.mojo` unterscheidet nun zwischen stabilen
Reziprok-Vielfachen und undefinierten echten `n/m`-Vielfachen. Die frühere
pauschale Sperre für jede Kombination von Bruch, Vielfachen und Teilern ist
entfernt. Die Universum-Spaltenwahl zählt alle semantischen Promptbefehle,
einschließlich eines aus `v1/n` abgeleiteten impliziten `vielfache`-Befehls.

## Prüfungen

- `scripts/prompt_mixed_reciprocal_reference.py` ermittelt den Python-Plan ohne
  Tabellenrendering;
- `tests/fixtures/prompt_mixed_reciprocal.expected` friert die sieben exakten
  Python-Argumentpläne einschließlich zweier Fallbackgrenzen ein;
- `scripts/check_prompt_mixed_reciprocal_parity.sh` regeneriert diesen Vertrag,
  extrahiert die vollständigen nativen Tokenpläne und vergleicht alle sieben
  Fälle bytegenau;
- `test_prompt_table_execution.mojo` prüft Langform, Kurzpräfix, Ausschluss,
  englische Aliase, Spaltenwahl, fehlendes Maximum und die echte `n/m`-Grenze.

Mit dem offiziellen Mojo-Compiler 1.0.0b2 wurden **28/28** native
Tabellenplaner-Tests ausgeführt. Die vollständigen Python- und Mojo-Pläne waren
für **7/7** Fälle byteidentisch. Die Python-Referenz blieb zusätzlich mit
`PYTHONHASHSEED=0`, `1` und `42` unverändert. Die fokussierten
Source-/Boundary-Pytests bestanden **7/7**.
