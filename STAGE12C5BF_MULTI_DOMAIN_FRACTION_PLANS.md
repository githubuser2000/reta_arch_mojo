# Stage 12c5bf – domänenspezifische Mehrfachpläne für Bruchvielfache

## Ausgangslage

Echte Bruchvielfache `v n/m` waren für Emotion, Strukturgröße, Motive/Galaxie
und Universum jeweils einzeln nativ. Sobald ein Prompt mehrere dieser
physischen Bruchdomänen zugleich auswählte, fiel der gesamte Befehl weiterhin
atomar auf `retaPrompt.py` zurück:

```text
universum motive v2/3
emotion groesse motive universum v2/3
```

Das war keine geeignete Dauerlösung. Die eingefrorene Python-Referenz stürzt
auch bei der Mehrdomänenform in
`reta_architecture/prompt_execution.py:1841` mit `IndexError` ab. Ein einziges
globales Bruchrechteck wäre zugleich fachlich falsch, weil die vier CSV-Dateien
verschiedene Formen besitzen.

## Neuer nativer Vertrag

`prompt_table_execution.mojo` modelliert jede physische Domäne ausdrücklich:

| Domäne | maximaler Zähler | maximaler Nenner |
|---|---:|---:|
| Emotion | 8 | 7 |
| Strukturgröße | 17 | 16 |
| Motive/Galaxie | 22 | 21 |
| Universum | 20 | 21 |

Für jede ausgewählte Domäne wird getrennt erzeugt:

1. das kartesische Vielfachenraster der Zähler- und Nennerachse;
2. die daraus folgenden ganzzahligen Projektionen;
3. die daraus folgenden reziproken Projektionen;
4. die domäneneigenen `--gebrochen-rational_*`-Aufrufe;
5. ausschließlich für Universum die Gleichheitsachse.

Damit besitzt `universum motive v2/3` **26** native Tabellenaufrufe:
13 für Motive/Galaxie und 13 für Universum. Der Vierdomänenbefehl besitzt
**44** Aufrufe in der historischen Familienreihenfolge Emotion →
Strukturgröße → Motive → Universum. Zähler 22 erscheint nur im Galaxieplan;
der Universumsplan endet weiterhin bei 20.

Gemischte Reziprok-/Bruchvielfache bleiben ebenfalls domänenspezifisch.
`emotion universum v1/2,2/3` verwendet in beiden Domänen die reziproken
Vielfachen unterhalb 1024, vereinigt sie aber jeweils nur mit den Projektionen
des eigenen physischen `2/3`-Rasters.

## Bewusst weiterhin atomare Kompositionen

Die neue Grenze besitzt ausschließlich reine Kombinationen der vier
Bruchdomänen plus vorhandene Kontroll-/Ausgabeparameter. Noch nicht
zusammengelegt werden insbesondere:

```text
mond universum motive v2/3
universum motive v2/3,5
```

Der erste Befehl benötigt eine definierte Abbildung des domänenspezifischen
Bruchrasters auf eine zusätzliche klassische Tabellenfamilie. Der zweite
mischt zusätzlich eine gewöhnliche Zeilenachse ein. Beide Befehle bleiben als
Ganzvektor am Fallback; es findet keine teilweise native Ausgabe statt.

## Prüfung

Der Mojo-Test bindet Zweidomänen-, Vierdomänen-, unterschiedlich abgeschnittene
und gemischte Reziprokfälle. Die kleine Probe und
`scripts/check_prompt_true_fraction_multiples.py` prüfen zusätzlich:

- den weiterhin reproduzierbaren Python-`IndexError`;
- 26 beziehungsweise 44 geordnete native Aufrufe;
- die vier verschiedenen CSV-Rechtecke;
- voneinander abweichende Emotion-/Universum-Reziprokprojektionen;
- direkte Ausführung des 26-Aufruf-Plans ohne verfügbaren Python-Fallback;
- atomare Ablehnung der beiden weiterhin unbewiesenen Kompositionen.

## Benutzerlauf

Die Erstellungsumgebung führt keine Mojo-/Native-Kompilierung aus. Zuerst kann
nur diese neue Stage geprüft werden:

```bash
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bf.sh
```

Mit vollständiger Stage-Kette:

```bash
scripts/test_stage12c5bf.sh
```

Danach ist der zuvor bis `test_program_workflow.mojo` gelaufene Gesamttest
fortzusetzen:

```bash
RETA_TEST_HEAVY=1 scripts/test_all.sh
```
