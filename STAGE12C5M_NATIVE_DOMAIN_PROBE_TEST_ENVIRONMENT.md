# Stage 12c5m – ProgramWorkflow-Priorität, Testumgebung und nativer Domain-Probe-Kern

## Ausgangsbefunde

Der lokale Modular-Mojo-Lauf zeigte zwei voneinander unabhängige Probleme:

1. Die Mojo-`.venv` enthielt den Compiler, aber nicht zwingend `pytest`; die
   nachgelagerten Python-Sourcegates brachen deshalb mit
   `No module named pytest` ab.
2. `requested_religion_output_kind` ließ bei gleichzeitigem
   `--art=html --art=bbcode` das zuerst gelesene Argument gewinnen. Die
   Python-Referenz besitzt dagegen eine feste Priorität: BBCode vor HTML.

Der vollständige Religionstabellentest verarbeitete außerdem 3,6 MB und mehr
als 760.000 Zellen, obwohl der Stage-Test nur CSV-, UTF-8-, JSON- und
Auffüllsemantik prüfen muss.

## Korrekturen

- `requirements-test.txt` beschreibt die Python-Testabhängigkeit.
- `scripts/setup_test_dependencies.sh` installiert sie bevorzugt mit `uv` in
  `.venv`, mit `pip`/`ensurepip` als Fallback.
- `scripts/setup_mojo.sh` installiert diese Testabhängigkeiten künftig
  automatisch.
- `scripts/find_test_python.sh` wählt nur einen Interpreter, der `pytest`
  tatsächlich importieren kann, und nennt andernfalls den Reparaturbefehl.
- Die Stage-12c5e/k/l-Skripte verwenden den ausgewählten Testinterpreter.
- ProgramWorkflow prüft erst die gesamte Argumentliste auf BBCode und danach
  auf HTML; Argumentreihenfolge verändert die Priorität nicht mehr.
- Die schnelle Workflow-Fixture enthält ASCII, koreanischen, chinesischen und
  vietnamesischen Text sowie eingebettete JSON-Varianten. Sie wird weiterhin
  bis Zeile 1024 aufgefüllt, liest dafür aber nicht die vollständige
  Produktionstabelle.

## Weiterer Portierungsblock

`python_reference/reta_domain_probe_py.py` besitzt nun einen nativen Kern in
`src/domain_probe_main.mojo`. Er deckt neun zentrale Befehle ab:

- `mains`
- `params`
- `pairs`
- `pairs-json`
- `main-columns`
- `main-json`
- `pair`
- `pair-json`
- `reverse`

Die Implementierung verwendet direkt den nativen Schemakatalog und die native
Parametersemantik. Sie importiert weder Python noch `PythonObject` und ruft
keinen Python-Unterprozess auf. HTML-Metadatenbefehle und der vollständige
Architektursnapshot bleiben vorerst eine explizit abgewiesene Besitzergrenze.

Reguläres Compilerziel:

```text
target/bin/reta-mojo-domain-probe
```

Entwicklungslauncher:

```text
bin/reta-mojo-domain-probe
```

## Uploadvertrag

Ein unveränderter, zuvor von ChatGPT erzeugter Source-Stand muss nicht erneut
hochgeladen werden. Ein neues Sourcearchiv ist erst nötig, wenn lokal
Quelländerungen übernommen wurden oder diese Änderungen in die nächste Runde
einfließen sollen. Reine Builds und Testläufe erzeugen nur `target/`; dieses
Verzeichnis bleibt vom Upload ausgeschlossen. Fehlerausgaben können als Text
übermittelt werden.

## Maschinenstand und Prüfung

```text
vollständig nativ/generiert:    58/92 = 63,0 %
mindestens teilweise portiert:  81/92 = 88,0 %
angegriffene Referenzzeilen:     37.072/48.831 = 75,9 %
vollständig native Zeilen:       27.649/48.831 = 56,6 %
Mojo-Zeilen unter src/:          51.950
installierbare Compilerziele:    35
Defektkatalog:                   73/73
Python-Bereinigungspunkte:       18
```

Die ausführbare Source-, Ownership-, Archiv-, Defekt-, Metrik- und
Installationssuite besteht aus **58/58** bestandenen Python-Tests. Der lokale
Mojo-Lauf wird mit `scripts/test_stage12c5m.sh` ausgeführt und umfasst den
ProgramWorkflow-Modultest, 16 Workflow-Paritätsfälle sowie fünf
Domain-Probe-Paritätsfälle.
