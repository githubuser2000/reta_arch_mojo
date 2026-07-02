# Stage 12c5b – vollständige native Prompt-Sprache und PyPy3-Referenzvertrag

## Ziel

Diese Stufe schließt den bisherigen Restbesitz von
`reta_architecture/prompt_language.py` und stellt zugleich den historischen
Referenzinterpreter wieder eindeutig auf PyPy3-first. Die lokale `.venv` ist
nur die Mojo-Compilerumgebung und darf den Python-/PyPy3-Referenzvertrag nicht
übernehmen.

## Native Prompt-Sprachoberfläche

`src/reta_mojo/prompt_language.mojo` besitzt jetzt zusätzlich zur bereits
produktiven Kurzsprache und Completion die vollständige historische
`PromptLanguageBundle`-Oberfläche:

- Parameter- und Nichtparameterwerte,
- Befehlsmenge,
- erlaubte Bruchzahlen,
- Kurzbefehlsbuchstaben,
- `wahl15`-/`wahl16`-Verträge,
- Bereichs-, Bruch- und ReTa-Parameterklassifikation,
- die historischen Aliasnamen `custom_split`, `custom_split2`,
  `isReTaParameter` und `is15or16command`,
- einen typisierten `PromptLanguageSnapshot` für den Besitztest.

Der große unveränderliche Bestand liegt in
`assets/prompt_language_legacy.tsv`. Er umfasst **17.123 geordnete Zeilen**
über Deutsch, Englisch, Vietnamesisch, Chinesisch und Koreanisch. Deutsch
enthält **4.199** Nichtparameterwerte und **386** Befehle; jede der vier
weiteren Sprachen enthält **2.715** Nichtparameterwerte und **367** Befehle.
Alle Sprachen besitzen **21** erlaubte Bruchzahlen, **21** Kurzbefehle,
**65** `wahl15`- und **9** `wahl16`-Einträge.

`tools/generate_prompt_language_legacy_catalog.py` erzeugt diesen Bestand in
getrennten Referenzprozessen je Sprache. Damit kann die importzeitabhängige
Sprachinitialisierung des Python-Originals nicht zwischen den fünf Läufen
lecken.

## PyPy3-first statt `.venv/bin/python`

`scripts/select_reference_python.sh` definiert nun zentral:

1. `RETA_REFERENCE_PYTHON`,
2. `RETA_PYTHON`,
3. `pypy3`,
4. `python3`,
5. `.venv/bin/python` ausschließlich als letzten Notfallfallback.

Die Referenz-, Paritäts- und Kompatibilitätsskripte verwenden diesen Selektor.
Ein explizit konfigurierter, aber nicht ausführbarer Interpreter führt zu einem
sichtbaren Fehler statt zu einem stillen Wechsel. Die Prompt- und
Kompatibilitätslauncher übernehmen denselben Vertrag.

Der manuelle historische Volltabellenlauf lautet damit weiterhin:

```sh
PYTHONHASHSEED=0 pypy3 reta -spalten --alles --breite=0 \
  -ausgabe --art=html --onetable --nocolor > middle.alx
```

Im Transpilierungsbaum kann die eingefrorene Referenz direkt über
`scripts/create_full_all_reference_bundle.sh` erzeugt werden; das Skript wählt
PyPy3 automatisch, sofern es installiert ist.

Die von CPython 3.14 ausgegebene `pyphen`-/`pkg_resources`-Warnung entsteht,
weil der gezeigte Befehl ausdrücklich `python` startet. Sie ist kein
Mojo-Fehler und verändert nicht automatisch die HTML-Ausgabe, weist aber auf
eine veraltete Abhängigkeit der CPython-Umgebung hin.

## Upload- und Archivvertrag

Nicht in ein Quellarchiv gehören:

- `.venv/`,
- `.git/`,
- `target/` und andere Buildprodukte,
- `__pycache__/`, `.pytest_cache/` und Bytecode,
- große, unveränderte Binär- oder Referenzprodukte, sofern sie nicht für eine
  konkrete Paritätsprüfung benötigt werden.

Benötigt werden Quellcode, Skripte, Tests, Ressourcen, Lock-/Requirements-
Dateien und gezielt erzeugte kleine Referenzpakete. Brotli-Archive werden als
`.tar.br` unterstützt und für die nächste Übergabe verwendet.

## Prüfungen

- nativer Prompt-Sprachtest: **19/19**,
- historischer Sprachvertrag: **90/90 Datensätze byteidentisch**
  (18 je Sprache),
- Katalogregeneration: **17.123/17.123 Zeilen identisch**,
- bestehende kompakte Promptparität: **27/27 Kontexte byteidentisch**,
- bestehende Sitzungsparität: **36/36 Kontexte byteidentisch**,
- PyPy3-Selektor-, Ownership- und Matrix-Pytests: **14/14**,
- aktive eingebettete `std.python`-Brücken: **0**.

Der vollständige produktive `prompt_main.mojo`-Build wurde erneut mit
deaktivierter Optimierung gestartet. Er meldete vor Ablauf des
**40-Minuten-Sandboxlimits keinen Compilerfehler**, erzeugte aber noch kein
abschließend gelinktes ELF. Deshalb wird nur der erfolgreich kompilierte und
ausgeführte Modulvertrag als bestanden gezählt; der lokale Gesamtlink bleibt
über `RETA_BUILD_PROMPT=1 scripts/test_stage12c5a.sh` nachzuweisen.

## Fortschritt

- vollständig native oder reproduzierbar generierte Originaldateien:
  **46/92 → 47/92 = 51,1 %**,
- mindestens teilweise portierte Originaldateien:
  **78/92 = 84,8 %**,
- gewichteter Quellzeilenersatz:
  **ca. 69,7 % → ca. 70,7 %**,
- nativer Mojo-Quellcode in `src/`: **45.270 Zeilen**,
- davon in `src/reta_mojo/`: **42.026 Zeilen**.

`reta_architecture/prompt_language.py` ist damit keine produktive
Python-Besitzlücke mehr. Es bleibt ausschließlich als eingefrorene
Referenzquelle für Reproduktion und spätere Python-Bereinigung erhalten.
