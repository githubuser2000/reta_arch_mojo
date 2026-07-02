# Stage 12c5p – vollständige Morphismen und einheitlicher Pytest-Resolver

## Anlass

Der lokale Mojo-Lauf zeigte drei unterschiedliche Zustände:

- `scripts/test_stage12c5e.sh` bestand vollständig;
- `scripts/test_stage12c5k.sh` bestand vollständig;
- `scripts/test_stage12c5j.sh` baute und startete die Mojo-Tests, rief danach
  aber fest `/usr/bin/python3 -m pytest` auf und scheiterte deshalb trotz eines
  bereits in `.venv` installierten `pytest`.

Die wiederholte Meldung

```text
Failed to initialize Crashpad. Crash reporting will not be available.
```

stammt vom Modular-Mojo-Werkzeug. Sie ist keine reta-Testniederlage: Die
jeweiligen Mojo-Prozesse liefen anschließend weiter und lieferten erfolgreiche
Testergebnisse. Die Projektwerkzeuge filtern diese Meldung nicht aus `stderr`,
damit echte Compilerfehler nicht versehentlich verborgen werden.

## Einheitliche Python-Testauflösung

Neu ist der einzige öffentliche Pytest-Einstieg:

```text
scripts/run_pytest.sh
```

Er ruft `scripts/find_test_python.sh` auf und startet anschließend exakt den
Interpreter, der `pytest` importieren kann. Die Priorität bleibt:

1. `RETA_TEST_PYTHON`;
2. `.venv/bin/python3`;
3. System-`python3`;
4. `pypy3`.

Alle 20 zuvor direkt `python3 -m pytest` aufrufenden Shellskripte wurden auf
diesen Einstieg umgestellt. Zusammen mit dem neuen Stage-Test verwenden nun 21
Skripte `run_pytest.sh`; kein Shellskript enthält noch einen direkten
`python3 -m pytest`-Aufruf.

Dadurch verwendet `scripts/test_stage12c5j.sh` nach

```sh
uv pip install --python .venv/bin/python3 pytest
```

zuverlässig `.venv/bin/python3`, statt auf `/usr/bin/python3` zurückzufallen.

## Vollständiger nativer Besitz von `morphisms.py`

`python_reference/reta_architecture/morphisms.py` besitzt fünf öffentliche
Klassen mit zusammen 13 Methoden. `src/reta_mojo/morphisms.mojo` deckt diese
Oberfläche nun vollständig typisiert ab:

- `AliasMorphisms`
  - Hauptaliasauflösung;
  - Parameteraliasauflösung;
  - kanonische Paare;
  - direkte Spaltennummern;
- `RangeMorphisms`
  - Bereichsauswertung;
  - Sortierung;
  - echte Deduplikation entsprechend `sorted(set(...))`;
- `PromptMorphisms`
  - Prompt-Split;
  - Befehlswortregel für `reta`;
  - typisierte `PromptExpansionRequest` als Grenze des historischen dynamischen
    Callback-Aufrufs;
- `RendererMorphisms`
  - Moduserkennung aus `OutputRuntimeState`;
  - native Modusanwendung;
  - Python-kompatibler Fallback auf `shell` statt des bisherigen nativen
    Zwischenstands `terminal`;
- `MorphismBundle`
  - typisierter gemeinsamer `ContextSelection`-Topologiekontext;
  - `from_topology_and_sheaves`;
  - Bootstrap;
  - Snapshot in der historischen Reihenfolge
    `alias, ranges, prompt, renderers`.

Die Python-Methode `expand_shorthand` enthielt selbst keinen Algorithmus,
sondern rief nur ein fremdes Callable auf. Mojo bildet diese dynamische Grenze
als besitzende, kopierbare `PromptExpansionRequest` ab, ohne `PythonObject`,
`std.python` oder Subprozess.

## Zusätzlich korrigierter Renderer-Fallback

Die Python-Referenz `RetaOutputSemantics.mode_for_tables()` fällt bei einer
unbekannten oder fehlenden Ausgabesyntax auf `shell` zurück. Der bisherige
partielle Mojo-Vertrag verwendete dagegen `terminal`. Stage 12c5p setzt den
Bootstrap- und Unknown-Mode-Fallback auf `shell` und hält dies als
`MOJO-FIXED-034` fest.

## Tests

Neue beziehungsweise erweiterte Tests:

- `tests/test_morphisms_complete.mojo`
  - gemeinsamer Topologiekontext;
  - Snapshotreihenfolge;
  - echte Bereichsdeduplikation;
  - typisierte Shorthand-Grenze;
  - Renderer-Zustandsanwendung;
- `tests/test_morphisms_complete_source.py`
  - exakte AST-Oberfläche aller fünf Python-Klassen;
  - vollständige Mojo-Methodenabdeckung;
  - keine Python-/Subprozessbrücke;
- `tests/test_test_python_setup.py`
  - ausführbarer gemeinsamer Resolver;
  - kein verbliebener direkter `python3 -m pytest`-Aufruf;
- `scripts/test_stage12c5p.sh`
  - bestehende und vollständige Morphismen-Modultests;
  - Source-, Ownership-, Metrik-, Defekt-, Archiv- und Boundary-Gates.

## Fortschritt

```text
vollständig nativ/generiert:     61/92 = 66,3 %
mindestens teilweise portiert:   83/92 = 90,2 %
angegriffene Referenzzeilen:      38.174/48.831 = 78,2 %
vollständig native Referenzzeilen:28.840/48.831 = 59,1 %
Mojo-Zeilen in src/:              52.950
Mojo-Zeilen in src/reta_mojo/:    48.918
aktive std.python-Brücken:             0
```


## Verifikation

- fokussierte Source-, Ownership-, Defekt-, Boundary- und Metriktests: **31/31**;
- Sourcearchiv-Roundtrips für Bzip2, Brotli und paralleles XZ: **3/3**;
- zusammen ausführbare Python-/Sourcegates: **34/34**;
- Defektkatalog: **78/78 konsistent**;
- Python-Bereinigungspunkte: **19**;
- direkte `python3 -m pytest`-Aufrufe in Shellskripten: **0**;
- Source-Manifest: **1.310/1.310** Dateien;
- relative Symlinks: **114**, absolute Symlinks: **0**;
- verbotene Build-, Cache- und Temporärpfade vor Tests: **0**.
