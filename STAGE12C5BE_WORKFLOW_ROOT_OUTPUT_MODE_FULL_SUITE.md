# Stage 12c5be – Workflow-Ressourcenbesitz und konsistenter Rich-Output-Modus

## Ausgangspunkt

Der vollständige Benutzerlauf

```sh
RETA_TEST_HEAVY=1 scripts/test_all.sh
```

lief bis `tests/test_program_workflow.mojo` und zeigte dort zwei voneinander
unabhängig wirkende Fehler:

1. Die erwartete UTF-8-Fixture-Zelle `한글 中文 Việt` wurde durch den ersten
   Datensatz der echten Religionstabelle (`Jungfrau`) ersetzt.
2. Ein typisierter Workflow mit `--art=html` dekodierte seine Religionzellen als
   HTML, der allgemeine Parameterplan blieb jedoch auf `shell`.

Beide Befunde lagen an einer unvollständigen Besitzgrenze im nativen
`ProgramWorkflowBundle`.

## Expliziter Ressourcenbesitz

Das Feld `repo_root` war bisher nur im Snapshot sichtbar. Die CSV-Helfer
verwendeten stets den globalen FHS-/Umgebungsresolver. Dadurch bestand der
fokussierte Stage-Test nur, weil `RETA_DATA_DIR` außerhalb des Testprogramms
gesetzt wurde; die allgemeine Testsuite hatte diese versteckte Voraussetzung
nicht.

Nun gilt derselbe Vertrag wie im Python-Original:

```text
konkretes repo_root -> repo_root/csv/basename
leeres oder "." repo_root -> portabler resource_paths-Resolver
```

`_load_religion_table` und der sprachspezifische Motivspaltenersatz reichen den
expliziten Rootwert durch. Der Mojo-Test konstruiert seinen Fixture-Besitzer
selbst und benötigt keine Prozessumgebung mehr.

## Ein gemeinsamer Rich-Output-Modus

Die Religion-Zelldekodierung erkennt die lokalisierte Oberfläche
`--<art_parameter>=<html|bbcode>` absichtlich auch außerhalb eines vorherigen
`-ausgabe`-Abschnitts. Der allgemeine Parameterparser verlangt dagegen einen
Hauptabschnitt. Dadurch konnten Dekodierer und Renderer im selben Workflow
verschiedene Modi besitzen.

Der Workflow synchronisiert jetzt ausschließlich die beiden reichen Modi
`html` und `bbcode` in den typisierten `ParameterRuntimePlan`. Andere Modi wie
CSV, Markdown, Emacs oder Shell bleiben vollständig im Besitz des allgemeinen
Parameterparsers. Sind HTML und BBCode zugleich vorhanden, gilt weiterhin die
historische Python-Priorität: BBCode gewinnt unabhängig von der Argumentfolge.

## Benutzerseitiger Nachweis

Der vollständige aktuelle Stage-Lauf bewahrt standardmäßig die bisherige
Stage-12c5bd-Kette:

```sh
scripts/test_stage12c5be.sh
```

Nur zur schnellen Wiederholung genau dieser Workflow-Reparatur kann die
vorherige Kette übersprungen werden:

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5be.sh
```

Danach die zuvor abgebrochene Gesamtsuite fortsetzen:

```sh
RETA_TEST_HEAVY=1 scripts/test_all.sh
```

Die Erstellungsumgebung führt weiterhin keine Mojo- oder Native-Kompilierung
aus; diese Nachweise bleiben beim Benutzer.
