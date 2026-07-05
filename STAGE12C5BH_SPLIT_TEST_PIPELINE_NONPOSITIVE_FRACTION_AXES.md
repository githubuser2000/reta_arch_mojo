# Stage 12c5bh – getrennte Testphasen, kontrollierte Parallelität und nichtpositive Bruchachsen

## Ausgangslage aus dem Benutzerlauf

Der vollständige Produktionsbuild von Stage 12c5bg war erfolgreich. Die
historische Stage-Kette bestand die Architektur-, i18n-, Legacy-, Parameter-,
Setup- und Py-Reta-Wahrheitsprüfungen. Der erste Abbruch trat erneut in
`test_stage12c5aq.sh` auf:

```text
html-religion-basic.out:
  actual   a8a0d2a1...
  expected 17453b00...
command_parity.tsv:
  actual   9fdefe9a...
  expected 87f6d8c4...
```

Die `actual`-Werte sind bereits die kanonischen, vom isolierten Generator
produzierten Werte. Der lokale Arbeitsbaum enthielt noch zwei ältere
versionierte Assets. Das war kein weiterer Rich- oder Rendererfehler, sondern
eine unvollständige Assetübernahme in einer früheren Patchkette.

## Kontrollierte Migration alter Kommandoassets

`tools/generate_command_parity_assets.py --migrate-legacy` ersetzt nur zwei
exakt bekannte alte SHA-256-Zustände. Jede unbekannte Abweichung bleibt ein
harter Fehler. Dadurch kann der historische Arbeitsbaum repariert werden, ohne
eine wirkliche Referenzänderung stillschweigend zu akzeptieren.

`test_stage12c5aq.sh`, `test_stage12c5bg.sh` und die neue Stage führen zuerst
diese eng begrenzte Migration und danach weiterhin `--check` aus.

## Testkompilierung und Testausführung sind getrennt

Die vollständige Suite besitzt jetzt drei öffentliche Einstiegspunkte:

```sh
scripts/build-tests.sh
scripts/run-tests.sh
scripts/test_all.sh
```

- `build-tests.sh` entfernt zuerst das alte Ready-Manifest, kompiliert
  ausschließlich und veröffentlicht jedes ELF atomar. Erst nach einem
  vollständigen Build schreibt es `target/tests-all/manifest.tsv` samt Inhalts-ID,
  Quellpfad, Binarypfad und Ausführungsklasse.
- `run-tests.sh` kompiliert nichts. Es lehnt fehlende oder gegenüber Quellen,
  Assets und Testrezepten veraltete Binaries mit Exitstatus 78 ab.
- `test_all.sh` bleibt als kompatibler Gesamteinstieg erhalten und ruft beide
  Phasen nacheinander auf.

Damit kann nach einem vollständigen Testbuild die Laufzeitsuite wiederholt
werden, ohne sämtliche Mojo-Testprogramme erneut zu kompilieren.

## Parallelisierungspolitik

Mehrere unabhängige `mojo build`-Prozesse werden standardmäßig nicht parallel
gestartet. Sie teilen Compilerlaufzeit, Dateisystem und hohe RAM-Spitzen. Eine
interne Compileroption wie `-j 4` kann weiterhin explizit an
`build-tests.sh -- -j 4` weitergereicht werden.

Die Laufzeitausführung kann dagegen opt-in parallelisiert werden:

```sh
scripts/run-tests.sh --jobs 4
# oder
RETA_TEST_RUN_JOBS=4 scripts/test_all.sh
```

Der Runner verwendet Manifestbarrieren:

- kleine, rein lesende Tests: `parallel`;
- Tests erhalten ein eigenes `TMPDIR`/`RETA_TEST_SANDBOX`; verbleibende gemeinsame Seiteneffekte wären `serial`;
- bekannte sehr lange oder speicherintensive Tabellen-/UTF-8-Tests:
  `exclusive`.

Jeder Lauf erhält zusätzlich ein eigenes `TMPDIR`. Ausgabe wird trotz
paralleler Prozesse in Manifestreihenfolge ausgegeben. Der Standard bleibt
`--jobs 1`.

## Nichtpositive Ganzzahlachsen neben echten Bruchvielfachen

Kommalokale Null- und Ausschlusskomponenten besitzen in der eingefrorenen
Python-Referenz eine stabile äußere Achse, obwohl das innere echte Bruchraster
weiter den dokumentierten Python-Indexfehler besitzt. Neu nativ behandelt
werden unter anderem:

```text
universum motive v2/3,0
universum motive v2/3,-10
universum motive v2/3,5,-10
universum v2/3,0,-10
universum v2/3,5-7,-6
```

Die Quellschreibweisen werden sowohl an `--vielfachevonzahlen` als auch an die
historischen `v`-Zeilenselektoren weitergegeben. Die korrigierten
Bruchprojektionen bleiben davon getrennt.

Weiterhin atomar bleiben zwei andere Grammatiken:

```text
universum motive v2/3 -10
universum v2/3,0 teiler
universum v2/3,5,-10 teiler
```

Ein separat geschriebenes negatives Token wird vom alten Prompt anders
klassifiziert. Nichtpositive `teiler`-Kompositionen besitzen ebenfalls eine
andere Subtraktions-/Divisorenalgebra und werden nicht mit der gewöhnlichen
Vielfachenregel vermischt.

## Benutzerprüfung

Nur die neue Stage:

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bh.sh
```

Getrennte Gesamtsuite:

```sh
scripts/build-tests.sh --heavy
scripts/run-tests.sh --jobs 2
```

Kompatibler Gesamteinstieg:

```sh
RETA_TEST_HEAVY=1 RETA_TEST_RUN_JOBS=2 scripts/test_all.sh
```
