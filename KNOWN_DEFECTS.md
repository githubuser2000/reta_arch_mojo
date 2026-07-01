# Zentraler Fehlerkatalog

Diese Datei wird aus `KNOWN_DEFECTS.json` erzeugt. Der JSON-Katalog ist die
maßgebliche, maschinenlesbare Quelle.

## Arbeitsregel

Während der Transpilierung bleibt python_reference grundsätzlich unverändert. Bestätigte Python-Fehler werden im Mojo-Port sicher korrigiert oder bewusst kompatibel reproduziert und für eine spätere Python-Bereinigungsphase erfasst.

Nach Abschluss der funktionalen Transpilierung werden alle Einträge mit python_status=open oder python_status=candidate einzeln im Python-/PyPy3-Code behoben, gegen neue Soll-Fixtures geprüft und danach auf fixed gesetzt.

**Erfassungsumfang:** Erfasst werden alle reproduzierbaren semantischen, Ausgabe-, Ownership-, Portabilitäts- und Testinfrastrukturfehler, die Verhalten oder Verlässlichkeit beeinflussen. Rein vorübergehende Tipp-, Syntax- oder Compilerfehler während einer noch nicht lauffähigen Änderung werden nur aufgenommen, wenn sie eine eigenständige Architektur- oder Vertragslücke offenlegen.

**Python-Originalregel:** Jeder bestätigte oder plausible Fehler im Python-/PyPy3-Original erhält vor einer absichtlichen Mojo-Abweichung einen PY-OPEN- oder PY-CAND-Eintrag mit Reproduktion, Quellorten, Belegen und konkretem späterem Python-Arbeitsauftrag.

## Übersicht

- Einträge insgesamt: **14**
- offene bestätigte Python-Fehler: **2**
- zu entscheidende Python-Fehlerkandidaten: **3**
- bereits im Python-Baum behobene Fehler: **3**

## Einträge

### PY-OPEN-001 – Beliebige Codeausführung durch eval in Ganzzahlmengen-Ausdrücken

- Ursprung: `python_reference`
- Klasse / Schwere: `bug` / `high`
- Python-Status: `open`
- Mojo-Status: `fixed`
- entdeckt in: `12c4p`
- Reproduktion: `reta -zeilen --vorhervonausschnitt=[__import__('os').system('true')] -spalten --religionen=sternpolygon`
- heutiger Vertrag: Mojo besitzt nur einen endlichen Ganzzahlparser; beliebiger Python-Code fällt atomar auf die eingefrorene Referenz zurück.
- spätere Python-Aktion: Beide eval-Aufrufe im Python-Code durch denselben beschränkten AST-/Ganzzahlparser ersetzen und gefährliche Formen vollständig ablehnen.
- Python-Orte: `python_reference/reta_architecture/row_ranges.py:37`, `python_reference/reta_architecture/prompt_language.py:121`
- Mojo-Orte: `src/reta_mojo/integer_expressions.mojo`, `src/reta_mojo/row_ranges.mojo`
- Belege: `STAGE12C4P_NATIVE_INTEGER_EXPRESSIONS.md`, `tests/test_integer_expression_parity.py`

### PY-OPEN-002 – Prompt-Absturz bei echten Bruchvielfachen v n/m

- Ursprung: `python_reference`
- Klasse / Schwere: `bug` / `high`
- Python-Status: `open`
- Mojo-Status: `fixed`
- entdeckt in: `12c4r`
- Reproduktion: `rpb 'universum v2/3'`
- heutiger Vertrag: Mojo erweitert Zähler- und Nennerachsen innerhalb der real vorhandenen Bruch-CSV-Form, erzeugt Ganzzahl-/Reziprokprojektionen und stürzt nicht ab.
- spätere Python-Aktion: Leere zahlenReiheKeineWteiler sicher behandeln und die Bruchvielfachen-Expansion anhand der tatsächlichen Domänenform statt des globalen Zahlenvorrats aufbauen.
- Python-Orte: `python_reference/reta_architecture/prompt_execution.py:1841`
- Mojo-Orte: `src/reta_mojo/prompt_table_execution.mojo`
- Belege: `STAGE12C4R_DEFECT_LEDGER_FRACTION_MULTIPLES.md`, `tests/test_prompt_table_execution.mojo`, `scripts/check_prompt_true_fraction_multiples.py`

### PY-CAND-001 – Prompt-Ausgabereihenfolge hängt von Python-set und PYTHONHASHSEED ab

- Ursprung: `python_reference`
- Klasse / Schwere: `bug_candidate` / `medium`
- Python-Status: `candidate`
- Mojo-Status: `fixed`
- entdeckt in: `10f`
- Reproduktion: `Prompt-Kommandos mit mehreren numerischen Komponenten unter verschiedenen PYTHONHASHSEED-Werten`
- heutiger Vertrag: Mojo reproduziert die bisherige CPython-Reihenfolge für PYTHONHASHSEED=0 deterministisch und plattformunabhängig.
- spätere Python-Aktion: Eine fachlich definierte Reihenfolge festlegen und Python-set-Iteration aus sichtbaren Tokenströmen entfernen; dabei bewusst neue Soll-Fixtures erzeugen.
- Python-Orte: `python_reference/reta_architecture/prompt_preparation.py`, `python_reference/reta_architecture/prompt_execution.py`
- Mojo-Orte: `src/reta_mojo/prompt_language.mojo`, `src/reta_mojo/prime_cross_columns.mojo`
- Belege: `STAGE10F_NATIVE_COMPACT_PROMPT.md`, `STAGE10I_NATIVE_NUMERIC_SELECTORS.md`

### PY-CAND-002 – CSV ohne Nummerierung behält zwei leere Strukturfelder

- Ursprung: `python_reference`
- Klasse / Schwere: `bug_candidate` / `low`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- entdeckt in: `12c4o`
- Reproduktion: `reta -zeilen --vorhervonausschnitt=1 -spalten --religionen=sternpolygon -ausgabe --art=csv --keinenummerierung`
- heutiger Vertrag: Mojo gibt aus Kompatibilitätsgründen weiterhin die führenden Bytes ;; aus.
- spätere Python-Aktion: Entscheiden, ob --keinenummerierung die beiden CSV-Spalten wirklich entfernen soll; bei Bejahung Python und Mojo gemeinsam auf ein neues Format umstellen.
- Python-Orte: `python_reference/reta_architecture/table_output.py`
- Mojo-Orte: `src/reta_mojo/table_rendering.mojo`
- Belege: `STAGE12C4O_NATIVE_FLAT_COLUMN_WIDTHS.md`

### PY-CAND-003 – Reziproke Teilerselektion serialisiert leere Komponenten und historische Leerseiten

- Ursprung: `python_reference`
- Klasse / Schwere: `bug_candidate` / `low`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- entdeckt in: `12c4c`
- Reproduktion: `Prompt: universum teiler 1/2`
- heutiger Vertrag: Mojo erhält den beobachtbaren Selektor mit nachlaufender leerer Komponente, damit die aktuelle Ausgabe bytegleich bleibt.
- spätere Python-Aktion: Leere Selektorkomponenten aus dem Promptvertrag entfernen und die gewünschte Teilersemantik explizit testen.
- Python-Orte: `python_reference/reta_architecture/prompt_execution.py`
- Mojo-Orte: `src/reta_mojo/prompt_table_execution.mojo`
- Belege: `STAGE12C4C_NATIVE_MIXED_RECIPROCAL_MODIFIERS.md`

### PY-FIXED-001 – Prompt a1 scheiterte durch fehlende globale Namen

- Ursprung: `python_reference`
- Klasse / Schwere: `bug` / `high`
- Python-Status: `fixed`
- Mojo-Status: `not_applicable`
- entdeckt in: `python-2026-04-24`
- Reproduktion: `rpb 'a1'`
- heutiger Vertrag: isReTaParameter wird importiert und befehle beim Bootstrap initialisiert.
- spätere Python-Aktion: Keine weitere Aktion; Regressionstest beibehalten.
- Python-Orte: `python_reference/reta_architecture/prompt_execution.py`
- Belege: `python_reference/PROMPT_EXECUTION_FIX_2026-04-24.md`

### PY-FIXED-002 – Vier Txt.liste-Zuweisungen verwendeten die falsche Variable x statt tx

- Ursprung: `python_reference`
- Klasse / Schwere: `bug` / `medium`
- Python-Status: `fixed`
- Mojo-Status: `not_applicable`
- entdeckt in: `python-2026-04-23`
- Reproduktion: `Betroffene Prompt-Vorbereitungszweige`
- heutiger Vertrag: Die vier Zuweisungen verwenden tx.
- spätere Python-Aktion: Keine weitere Aktion; Quelltest beibehalten.
- Python-Orte: `python_reference/reta_architecture/prompt_preparation.py`
- Belege: `python_reference/LEGACY_IMPORT_CLEANUP_2026-04-23.md`

### PY-FIXED-003 – Bruch-/CSV-Pfade referenzierten veraltete Program-Klassenattribute

- Ursprung: `python_reference`
- Klasse / Schwere: `bug` / `high`
- Python-Status: `fixed`
- Mojo-Status: `not_applicable`
- entdeckt in: `python-stage19`
- Reproduktion: `reta.py -zeilen --vorhervonausschnitt=1-3 -spalten --gebrochenuniversum=5 --breite=40`
- heutiger Vertrag: Die Zugriffe verwenden type(self).* und der Bruch-CSV-Gluing-Pfad läuft.
- spätere Python-Aktion: Keine weitere Aktion; Bruch-CSV-Parität beibehalten.
- Python-Orte: `python_reference/reta_architecture/parameter_runtime.py`
- Belege: `python_reference/STAGE19_CHANGES.md`

### MOJO-FIXED-001 – Generator-Comprehensions wurden nativ beansprucht, aber ignoriert

- Ursprung: `mojo_port`
- Klasse / Schwere: `bug` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c4p`
- Reproduktion: `reta -zeilen --vorhervonausschnitt={2*n for n in range(2,5)},10 ...`
- heutiger Vertrag: Sichere Comprehensions werden korrekt ausgewertet; alle anderen fallen atomar zurück.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `src/reta_mojo/integer_expressions.mojo`, `src/reta_mojo/native_reta_cli.mojo`
- Belege: `STAGE12C4P_NATIVE_INTEGER_EXPRESSIONS.md`

### MOJO-FIXED-002 – Reine Sprachwahl erzeugte fälschlich die Standardtabelle

- Ursprung: `mojo_port`
- Klasse / Schwere: `bug` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c4q`
- Reproduktion: `reta -language=english`
- heutiger Vertrag: Reine Sprachwahl schreibt wie Python null Bytes.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `src/reta_mojo/native_cli_startup.mojo`, `src/reta_mojo/native_reta_cli.mojo`
- Belege: `STAGE12C4Q_NATIVE_CLI_STARTUP_HELP.md`

### MOJO-FIXED-003 – Nativer Alles-HTML-Plan erzeugte 863 statt 807 Spalten

- Ursprung: `mojo_port`
- Klasse / Schwere: `bug` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c4n`
- Reproduktion: `RETA_GENERATE_HTML_ROWS=1 target/bin/generate-html-native`
- heutiger Vertrag: Deutsch und Englisch besitzen exakt 807 Spalten und sind bytegleich zur Referenz.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `src/reta_mojo/all_columns_plan.mojo`, `src/reta_mojo/table_rendering.mojo`
- Belege: `STAGE12C4N_ALL_COLUMNS_HTML_PARITY.md`

### MOJO-FIXED-004 – Übertragene Mojo-Binaries enthielten rechnerabhängigen absoluten RUNPATH

- Ursprung: `mojo_port`
- Klasse / Schwere: `packaging_bug` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4l`
- Reproduktion: `ldd target/bin/reta-native auf einem anderen Rechner`
- heutiger Vertrag: Binaries nutzen $ORIGIN/../lib/mojo und die lokale Runtime-Erkennung.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `scripts/build.sh`, `scripts/build-heavy.sh`, `bin/mojo-runtime-exec`
- Belege: `STAGE12C4L_PORTABLE_RUNTIME_RAW_MARKUP.md`

### MOJO-FIXED-005 – Gemischter Reziprok-Paritätstest hing am vollständigen Mojo-Testprozess

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `test_harness_bug` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4r`
- Reproduktion: `scripts/check_prompt_mixed_reciprocal_parity.sh im alten Stand`
- heutiger Vertrag: Die Paritätsprüfung baut eine kleine dedizierte Planprobe und beendet sich deterministisch, statt die komplette TestSuite nur als Datenausgeber zu missbrauchen.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `tests/prompt_mixed_reciprocal_probe.mojo`, `scripts/check_prompt_mixed_reciprocal_parity.sh`
- Belege: `STAGE12C4R_DEFECT_LEDGER_FRACTION_MULTIPLES.md`, `scripts/check_prompt_mixed_reciprocal_parity.sh`

### QUIRK-001 – Nullbreiten besitzen formatabhängige historische Sondersemantik

- Ursprung: `python_reference`
- Klasse / Schwere: `compatibility_quirk` / `low`
- Python-Status: `intentional_for_now`
- Mojo-Status: `compatibility_preserved`
- entdeckt in: `12c4k`
- Reproduktion: `reta ... -ausgabe --breiten=0,8`
- heutiger Vertrag: Mojo reproduziert Shell-Seitenauslassung sowie rohe Markup-Umbruchmessung bytegenau.
- spätere Python-Aktion: Erst nach der Transpilierung entscheiden, ob die Oberfläche vereinheitlicht werden soll; bis dahin kein Fehlerstatus.
- Python-Orte: `python_reference/reta_architecture/table_wrapping.py`, `python_reference/reta_architecture/table_output.py`
- Mojo-Orte: `src/reta_mojo/table_rendering.mojo`
- Belege: `STAGE12C4K_NATIVE_ZERO_COLUMN_WIDTHS.md`
