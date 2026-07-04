# Stage 12c5ay – thread-only Legacy-Prozessaliase

## Vom vollständigen Benutzerlauf aufgedeckter Testfehler

Der vollständige Lauf von Stage 12c5aw kompilierte alle Produktionsziele und
führte die Mojo-Suite bis `tests/test_parallel_number_processes.mojo` aus. Dort
brach der erste Laufzeitvertrag mit folgender Meldung ab:

```text
Unhandled exception caught during execution: moon process mode
```

Das Produktionsmodul war bereits korrekt. Seit der nativen Thread-Migration
werden die historischen Werte `process`, `processes`, `multiprocess`,
`multiprocessing` und `mp` durch `make_parallel_config()` auf `threads`
normalisiert. Die weiterhin vorhandenen Funktionen mit Suffix
`*_in_processes` sind ausschließlich Quellkompatibilitätsaliase und delegieren
an die jeweiligen `*_threaded`-Besitzer. Mojo erzeugt dabei keinen Prozess und
verwendet weder `fork`, Pickle noch Pipes.

Die sechs veralteten Testassertionen erwarteten dennoch weiterhin den
Statistikwert `processes`:

- vier Number-Operationen,
- zwei Row-Decodieroperationen.

Sie prüfen nun den tatsächlich aufgelösten Backendwert `threads`. Die
Kompatibilität des Eingabeworts `processes` bleibt unverändert erhalten.

## Neuer Quellvertrag

`tests/test_parallel_process_alias_source.py` bindet drei Eigenschaften:

1. alle historischen Prozessschreibweisen normalisieren auf `threads`,
2. sämtliche zehn `*_in_processes`-Aliase delegieren an Thread-Besitzer,
3. kein Laufzeittest darf erneut `stats.mode == "processes"` erwarten.

## Enthaltene vorausgehende Portierung

Stage 12c5ay enthält zusätzlich Stage 12c5ax. Dort wird die bisher unnötig
konservative Python-Fallbackgrenze für klassische kompakte Promptfamilien
entfernt. Der neue reine Besitzer
`prompt_historical_ownership.mojo` akzeptiert die bereits vom typisierten
Tabellenplaner vollständig beherrschten Familien atomar.


## Portable Quellprüfung

```text
Gezielte statische Verträge:             76 bestanden
Python-Referenzfälle der neuen Familien:  8 gültig und nichtleer
Bekannte Defekte:                        123
Python-Aufräumpunkte:                     20
Vollständig nativ/generiert:           89/92 = 96,7 %
Mindestens teilweise portiert:         92/92 = 100,0 %
Angegriffene Referenzzeilen:    48.831/48.831 = 100,0 %
```

## Benutzerseitige Prüfung

```sh
scripts/build-all.sh
scripts/test_stage12c5ay.sh
```

Die vollständige Suite kann anschließend wieder an der zuvor erreichten Stelle
fortgesetzt werden:

```sh
scripts/test_all.sh
```

Die Erstellungsumgebung führt entsprechend der Projektvorgabe keine
Mojo-Kompilierung aus.
