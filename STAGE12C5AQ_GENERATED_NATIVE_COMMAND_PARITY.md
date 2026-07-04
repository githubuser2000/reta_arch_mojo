# Stage 12c5aq: generated-native command parity

## Ziel

Der bisher vollständig unberührte Referenztest
`tests/test_command_parity.py` wird als reproduzierbarer nativer
End-to-End-Vertrag übernommen. Seine vier Fälle bleiben die einzige Quelle der
Kommandowahrheit:

- Shell mit `--religionen=sternpolygon`;
- Markdown mit derselben fachlichen Auswahl;
- HTML mit der historischen Normalisierung der `p4_`-Klassen;
- Shell mit gebrochen-universeller CSV-Verkettung.

## Reproduzierbare Assets

`tools/generate_command_parity_assets.py` liest die Fallmatrix direkt aus dem
AST des eingefrorenen Referenztests. Es dupliziert die Befehle daher nicht als
zweite handgeschriebene Wahrheit. Die Python-Referenzausgaben werden unter
`assets/command_parity/` gespeichert; `assets/command_parity.tsv` enthält
Modus, Argumenttokens und SHA-256 jedes Stroms.

Drei Fälle sind bytegenau. HTML verwendet exakt denselben Vertrag wie der
historische Test: Zahlenfolgen nach `p4_` werden numerisch sortiert und
Leerraumläufe auf ein Leerzeichen reduziert.

## Nativer Besitzer

`src/reta_mojo/command_parity.mojo` besitzt:

- einen typisierten `CommandParityCase`;
- den vollständigen Vier-Fälle-Katalog;
- die UTF-8-sichere HTML-Normalisierung;
- den Zugriff auf unveränderliche Erwartungsassets.

Der Besitzer importiert absichtlich weder Python noch den großen Tabellenkern.
Dadurch bleibt sein Unit-Test klein und schnell kompilierbar. Die eigentliche
End-to-End-Prüfung in `scripts/check_command_parity_native.py` startet das
bereits gebaute ELF-Programm `target/bin/reta-native` direkt mit der Modular-
Laufzeitbibliothek. Es wird kein Python-`reta.py` als Laufzeitfallback benutzt.

## Zusätzlich behobene Mojo-1.0-Besitzgrenze

Der echte Compilerlauf des aus 12c5ap übernommenen
`test_parameter_runtime_complete.mojo` fand nach der Tokenlistenreparatur eine
zweite, davon unabhängige Besitzverletzung: `produce_all_spalten_numbers()`
gab das `List[Int]`-Feld eines temporären `ParameterRuntimePlan` implizit
zurück. Die Funktion materialisiert den Plan nun und gibt
`plan.columns.copy()` zurück. Der vollständige Runtime-Test kompiliert und
besteht mit drei Tests.

## Prüfung

```sh
./do.sh 12c5aq
```

Die Stage bestätigt zuerst 12c5ap, verifiziert einmal die ursprüngliche
Python-zu-Python-Baseline, prüft die generierten Assets, baut den leichten
Mojo-Katalogtest und führt anschließend alle vier Fälle gegen das native
Executable aus.

## Fortschritt

- vollständig nativ/generiert: **87/92 = 94,6 %**
- mindestens teilweise portiert: **90/92 = 97,8 %**
- angegriffene Referenzzeilen: **47.027/48.831 = 96,3 %**
- vollständig unberührt bleiben nur `tests/__init__.py` ohne Inhalt und der
  große Architektur-Regressionskatalog `tests/test_architecture_refactor.py`.
