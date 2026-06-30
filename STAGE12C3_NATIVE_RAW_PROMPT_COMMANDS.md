# Stage 12c3 – native rohe Promptbefehle

Stage 12c3 entfernt die unnötige Python-Brücke aus den drei expliziten
Kindprozessbefehlen des Prompts:

- `shell ...`
- `python ...`
- `math ...`

Die öffentlichen Befehle und ihre Argumentsemantik bleiben unverändert.
`prompt_main.mojo` ruft für diese Zweige nun direkt
`src/reta_mojo/prompt_external_commands.mojo` auf.

## Beobachtbare Referenzsemantik

Die Python-Referenz zerlegt `shell` mit `shlex.split`, wechselt in
`python_reference` und vererbt stdin, stdout, stderr sowie die Umgebung an das
Kindprogramm. `python` führt den unveränderten Rest der Zeile mit `python -c`
aus. `math` umschließt den unveränderten Ausdruck mit `print(...)`.

Der Mojo-Adapter reproduziert diese Grenze mit:

- einem UTF-8-sicheren POSIX-Shlex-Parser;
- exakter `partition(" ")[2]`-Nutzlastsemantik;
- sicherem Einzelargument-Quoting für einen kleinen `/bin/sh -c`-Wrapper;
- `posix_spawn` und `waitpid`;
- unvererbten beziehungsweise nicht umcodierten Byte-Streams;
- vollständiger Umgebungsvererbung;
- dem Projektinterpreter `.venv/bin/python` für `python`/`math`, sofern `RETA_PYTHON` nicht ausdrücklich gesetzt ist;
- dem unveränderten Arbeitsverzeichnis `python_reference`.

Das ist absichtliche **Ausführung eines vom Nutzer verlangten
Kindprogramms**, keine prozessbasierte Parallelisierung. Tabellen-, Zahlen- und
Zeilenkerne bleiben vollständig threadbasiert. Der Boundary-Audit erlaubt
`posix_spawn`/`waitpid` ausschließlich in diesem einen Adapter und verbietet
weiterhin `fork`, `pipe` und `_exit` in nativen Mojo-Parallelpfaden.

## Unicode-Fehler im Kompaktparser

Vor Stage 12c3 konnte beispielsweise

```text
python print("ä λ")
```

vor der eigentlichen Ausführung in der kompakten Prompttransformation an einer
UTF-8-Bytegrenze scheitern. Rohe Befehle werden nun vor dem Zusammenfügen und
vor dem kompakten Nutzlastscanner erkannt und unverändert kopiert.

Die historische interne CPython-Set-Reihenfolge der späteren Planungsstufe wird
nicht verändert. Nur der beobachtbare Rohbefehlsstrom umgeht die
Kurzsprachentransformation.

## Byteparität

Die Tests prüfen nicht nur dekodierten Text, sondern auch:

- Unicode in Argumenten und Python-Code;
- Quotes, Leerzeichen und leere Argumente;
- nachgestellte Leerzeichen und mehrere abschließende Newlines;
- nicht-UTF-8-Bytes auf stdout;
- Binärbytes auf stderr;
- vollständige Umgebungsvererbung;
- identische Rückgabecodes.

## Fokussierte Prüfungen

```text
test_prompt_external_commands.mojo:        6/6
test_prompt_raw_commands.mojo:             5/5
Python↔Mojo Kindprozess-/Byteparität:       7/7
Source-Ownership + Boundary-Audit:          4/4
                                             ----
                                            22/22
```

Der schwere Rohbefehlstest wurde mit dem finalen Quellstand separat kompiliert
und ausgeführt. Der monolithische Gesamt-Promptcontroller bleibt wegen der in
dieser Umgebung bekannten langen Mojo-Elaboration Bestandteil des lokalen
Gesamtbuilds.

```bash
scripts/build-heavy.sh
scripts/build.sh
scripts/check_prompt_external_commands.sh
scripts/test_stage12c.sh
```

## Verbleibende Promptbrücke

`std.python` bleibt in `prompt_main.mojo` nur noch für:

- den echten TTY-Editor mit GNU-Readline-/Vi-/Completion-Verhalten;
- noch nicht portierte `reta`-/Fallbackzweige.

Diese Grenze ist Ziel von Stage 12c4.
