# Stage 12c4s – rückwirkender Fehleraudit und native Kontroll-Hauptparameter

Stage 12c4s verfolgt zwei zusammenhängende Ziele:

1. Der in Stage 12c4r eingeführte zentrale Fehlerkatalog wird rückwirkend gegen
   die Migrationsnotizen, Testergebnisse und Stage-Berichte geprüft. Bereits
   früher gefundene, aber nur verstreut dokumentierte Python-, Mojo-, Paket- und
   Testfehler erhalten eigene stabile IDs.
2. Die historischen Hauptparameter `-debug` sowie `-nichts`/`-nothing` werden
   vor der Tabellenplanung nativ klassifiziert.

## Erfassungsregel

Der Katalog beansprucht nicht, unbekannte Fehler vorwegzunehmen. Er erfasst aber
jeden im Projekt bestätigten oder plausibel begründeten Fehler, sobald er im
Lauf der Portierung sichtbar wird. Insbesondere dürfen Abweichungen des
Python-/PyPy3-Originals nicht nur in Fließtext oder Testausgaben stehen bleiben:
Sie müssen in `KNOWN_DEFECTS.json` und damit im generierten
`PYTHON_CLEANUP_BACKLOG.md` erscheinen.

Vorübergehende Syntaxfehler einer unfertigen Änderung werden nur dann als
Defekt geführt, wenn sie eine eigenständige Architektur-, Ownership-,
Portabilitäts- oder Testlücke zeigen.

## Kontroll-Hauptparameter

Python behandelt `-debug` als orthogonalen Ausgabepräfix. `-nichts` und
`-nothing` sind dagegen keine Aliase von `--art=nichts`: Der Hauptparameter wird
beim Parsing ignoriert. Ohne weitere wirksame Argumente entsteht daher keine
Ausgabe; innerhalb eines echten Tabellenvektors bleibt die normale Ausgabe
aktiv. Nur der explizite Nebenparameter `--art=nichts` beziehungsweise
`--type=nothing` wählt den stillen Renderer.

Der erste Mojo-Entwurf hatte `-nichts` irrtümlich in `--art=nichts` übersetzt und
unterdrückte dadurch gültige Tabellen. Diese Abweichung wurde durch einen
vollständigen Python↔Mojo-Vergleich erkannt und korrigiert.

## Spätere Python-Bereinigung

Die rückwirkend aufgenommenen Python-Einträge werden erst nach Abschluss des
funktionalen Ports im Originalbaum korrigiert. Für jeden Eintrag gelten dann:

1. aktuellen Reproduktionsfall bestätigen;
2. korrigierten Sollvertrag festlegen;
3. Python-/PyPy3-Code korrigieren;
4. Python und Mojo gegen denselben Solltest prüfen;
5. Status erst danach auf `fixed` setzen.

## Rückwirkend nachgetragene Defekte

Der Audit gegen elf zentrale Migrations-/Stage-Quellen erhöhte den Katalog von
14 auf 35 Einträge. Nachgetragen wurden insbesondere:

- Python-Dictionary-Invertierung mit String/Integer-Schlüsselkonflikt;
- mögliche Mondzahl-Fehlklassifikation durch gerundete Fließkommawurzeln;
- die drei reproduzierbar roten Python-Baseline-Tests;
- hash-seed-abhängige kanonische Aliase und heterogene Primwiederholungswerte;
- ältere Mojo-Fehler bei `--nocolor`, explizit leerer Spaltenordnung,
  Prompt-LF, Unicode-Rohbefehlen, `dlsym`, Universum-Casing, `--onetable`,
  Paginierung, Terminalgeometrie und Katalogduplikaten;
- offene beziehungsweise behobene Test-Harness-Fehler;
- die wieder aufgetauchte tote `std.python`-Quelldatei.

Die spätere Python-/PyPy3-Liste enthält nun zwölf offene, fragliche oder bewusst
zu entscheidende Punkte. Bereits behobene Mojo- und Infrastrukturfehler bleiben
im Gesamtkatalog erhalten, erscheinen aber nicht im Python-Rückstand.

## Reproduzierbare Python-Baseline

`scripts/check_documented_python_baseline.py` führt die eingefrorene
Architekturtestsuite aus und akzeptiert ausschließlich diese drei bekannten
Fehler:

- `test_prompt_runtime_layer_is_explicit`;
- `test_parameter_semantics_regression_counts`;
- `test_program_workflow_layer_is_explicit`.

Der bestätigte Stand lautet **67 bestanden, 3 katalogisierte Fehler**. Jede
zusätzliche oder verschwundene Fehlermeldung lässt das Prüfskript scheitern und
erzwingt damit eine Aktualisierung des Katalogs.

## Portabler RUNPATH als Build-Nachbedingung

Mojo 1.0.0b2 ergänzt beim Linken selbstständig den absoluten Pfad seiner lokalen
`modular/lib`-Installation. Ein zusätzliches `$ORIGIN` allein entfernt diesen
Pfad nicht. `tools/sanitize_mojo_runpath.py` kürzt deshalb nach jedem Build den
ELF-Stringtabelleneintrag in-place auf:

```text
$ORIGIN/../lib/mojo
```

Die Stringtabellenposition bleibt unverändert; der entfernte Rest wird mit
NUL-Bytes gefüllt. `build.sh`, `build-heavy.sh` und der Kompatibilitätsbuild
wenden diese Nachbedingung automatisch an. Ein `--check`-Modus verweigert
nichtportable Binaries.

## Testprozess-Isolation

Der monolithische 20-Knoten-Pytest-Lauf des Kompatibilitätslaunchers konnte nach
bereits bestandenen Fällen im Prozess-Teardown hängen. Selbst eine gemeinsame
Fünfergruppe reproduzierte den Hänger in einer frischen Entpackung. Das Release-Gate
startet deshalb jeden Knoten in einem eigenen Pytest-Prozess; die vier Gruppen
strukturieren nur noch die Berichterstattung.

## Ergebnisse

```text
Fehlerkatalog:                         35/35 konsistent
spätere Python-/PyPy3-Arbeitspunkte:      12
Katalog-/Reproduktions-Pytests:          8/8
Python-Baseline:                 67 bestanden, 3 katalogisiert
native Kontrollmodultests:               5/5
Start-/Hilfe-/Kontrollströme:          15/15 byteidentisch
Kompatibilitätslauncher:               20/20 pro Knoten isoliert
Startmodul:                              5/5
CLI-/Ownership-Planer:                 30/30
Generatorbereiche:                       6/6 byteidentisch
flache Einzelbreiten:                   13/13 byteidentisch
keineleereninhalte:                     13/13 byteidentisch
Source-/Installations-/Runtime-/Defekt-Pytests: 32/32
RUNPATH-Sanitizer:                        2/2
aktive std.python-Brücken:                  0
libpython-Abhängigkeiten:                   0
Quellmanifest:                         1064/1064
```
