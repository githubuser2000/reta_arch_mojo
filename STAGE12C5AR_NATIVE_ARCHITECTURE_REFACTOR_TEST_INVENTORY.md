# Stage 12c5ar – nativer Architektur-Refactor-Testbestand

Der historische Python-Monolith
`python_reference/tests/test_architecture_refactor.py` bündelt 70 fachlich
unabhängige Regressionstests mit insgesamt 1.060 `unittest`-Assertions. Die
Produktionsbesitzer und ihre Laufzeittests sind bereits auf fokussierte
Mojo-Module verteilt. Diese Stage macht diese Verteilung vollständig,
reproduzierbar und verlustfrei sichtbar.

## Neuer Vertrag

`tools/generate_architecture_refactor_contracts.py` liest den Python-Test nur
als AST und erzeugt `assets/architecture_refactor_contracts.tsv`. Jede der 70
Methoden besitzt dort exakt einen Eintrag mit:

- ursprünglicher Reihenfolge und Quellzeile,
- Anzahl ihrer historischen Assertions,
- SHA-256 des normalisierten Methoden-AST,
- fachlicher Kategorie,
- nativem Mojo-Besitzer,
- lebendem nativen Testziel und einem darin überprüften Evidenzsymbol.

Der Generator importiert und startet den Python-Test nicht. Fehlende, neue,
umbenannte oder verschobene Regressionen sowie tote Zieltests brechen die
Prüfung ab.

Der direkte Referenzlauf besitzt weiterhin den bereits dokumentierten
Python-Aufräumpunkt `PY-OPEN-005`: 69 der 70 Tests bestehen, während
`test_program_workflow_layer_is_explicit` noch den veralteten Namen
`load_/religion_table` statt `load_religion_table` erwartet. Die Referenz wird
während der Portierungsphase nicht stillschweigend geändert; der native
Workflowtest prüft bereits den gültigen Besitzervertrag.

`src/reta_mojo/architecture_refactor_contracts.mojo` ist der native Besitzer
dieses Katalogs. `tests/test_architecture_refactor_native.mojo` prüft die
70 Verträge, 1.060 Assertions, 18 Kategorien und 64 verschiedene native
Testziele.

Der leere historische Marker `python_reference/tests/__init__.py` besitzt
keine Semantik und wird durch die explizite native Paketoberfläche
`src/reta_mojo/__init__.mojo` ersetzt.

## Build- und Testtrennung

Die Produktionsskripte `scripts/build.sh`, `scripts/build-heavy.sh` und
`scripts/build-all.sh` kompilieren weiterhin keine Tests. Mojo-Testprogramme
werden durch `scripts/test_current_stage.sh` oder `scripts/test_all.sh`
kompiliert. Dadurch bleibt ein erfolgreicher Produktionsbuild unabhängig von
der Testkompilierung klar interpretierbar.

## Lokale Prüfung

```sh
scripts/build-all.sh
scripts/test_current_stage.sh
```

Nur der neue Mojo-Test:

```sh
bin/mojo-real build -I src -I tests \
  tests/test_architecture_refactor_native.mojo \
  -o target/tests/test_architecture_refactor_native_12c5ar
bin/mojo-runtime-exec target/tests/test_architecture_refactor_native_12c5ar
```
