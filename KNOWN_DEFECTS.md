# Zentraler Fehlerkatalog

Diese Datei wird aus `KNOWN_DEFECTS.json` erzeugt. Der JSON-Katalog ist die
maßgebliche, maschinenlesbare Quelle.

## Arbeitsregel

Während der Transpilierung bleibt python_reference grundsätzlich unverändert. Bestätigte Python-Fehler werden im Mojo-Port sicher korrigiert oder bewusst kompatibel reproduziert und für eine spätere Python-Bereinigungsphase erfasst.

Nach Abschluss der funktionalen Transpilierung werden alle Einträge mit python_status=open oder python_status=candidate einzeln im Python-/PyPy3-Code behoben, gegen neue Soll-Fixtures geprüft und danach auf fixed gesetzt.

**Erfassungsumfang:** Erfasst werden alle reproduzierbaren semantischen, Ausgabe-, Ownership-, Portabilitäts- und Testinfrastrukturfehler, die Verhalten oder Verlässlichkeit beeinflussen. Rein vorübergehende Tipp-, Syntax- oder Compilerfehler während einer noch nicht lauffähigen Änderung werden nur aufgenommen, wenn sie eine eigenständige Architektur- oder Vertragslücke offenlegen.

**Python-Originalregel:** Jeder bestätigte oder plausible Fehler im Python-/PyPy3-Original erhält vor einer absichtlichen Mojo-Abweichung einen PY-OPEN- oder PY-CAND-Eintrag mit Reproduktion, Quellorten, Belegen und konkretem späterem Python-Arbeitsauftrag.

**Release-Auditregel:** Vor jedem Release werden neue Testfehler und beobachtbare Python↔Mojo-Abweichungen gegen den Katalog geprüft. Ein bestätigter Befund darf nicht ausschließlich in Stage-Berichten, Konsolenausgaben oder Kommentaren verbleiben.

## Rückwirkender Audit

- letzter vollständiger Rückwärtsaudit: `12c4s`
- geprüfte Quellen: **24**
- Reichweite: Vollständig bezogen auf alle bis Stage 12c5bk im Projekt bestätigten oder plausibel begründeten verhaltensrelevanten Befunde; unbekannte künftige Fehler können naturgemäß erst nach ihrer Entdeckung aufgenommen werden.

## Übersicht

- Einträge insgesamt: **152**
- offene bestätigte Python-Fehler: **6**
- zu entscheidende Python-Fehlerkandidaten: **13**
- bereits im Python-Baum behobene Fehler: **7**

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
- Reproduktion: `rpb 'universum v2/3', rpb 'universum motive v2/3', rpb 'universum v1/2,2/3' sowie rpb 'universum v1/4,-1/8,2/3'`
- heutiger Vertrag: Mojo erweitert Zähler- und Nennerachsen innerhalb der real vorhandenen Bruch-CSV-Form und erzeugt Ganzzahl-/Reziprokprojektionen ohne Absturz. Bei mehreren ausgewählten Bruchdomänen erhält jede Domäne ihr eigenes physisches Rechteck: Emotion 8×7, Strukturgröße 17×16, Motive/Galaxie 22×21 und Universum 20×21. universum motive v2/3 besitzt deshalb einen geordneten 26-Aufruf-Plan, der Vierdomänenfall einen 44-Aufruf-Plan. Gemischte 1/n- und echte n/m-Vielfache verwenden getrennte Grenzen: Reziproke bis 1023, echte Brüche ausschließlich innerhalb des jeweiligen Domänenrechtecks. Positive-first Reziprok-Subtraktionen wie v1/4,-1/8,2/3 werden zusätzlich als unabhängige Differenzachse mit derselben domäneneigenen echten Bruchprojektion materialisiert.
- spätere Python-Aktion: Leere zahlenReiheKeineWteiler sicher behandeln, echte Bruchvielfache pro tatsächlicher Domänenform aufbauen, Mehrdomänenbefehle in geordnete domäneneigene Projektionen zerlegen, gemischte 1/n+n/m-Achsen vor der Expansion trennen und positive/ausgeschlossene Reziprokvielfache vor der Vereinigung deterministisch subtrahieren.
- Python-Orte: `python_reference/reta_architecture/prompt_execution.py:1841`
- Mojo-Orte: `src/reta_mojo/prompt_table_execution.mojo`
- Belege: `STAGE12C4R_DEFECT_LEDGER_FRACTION_MULTIPLES.md`, `tests/test_prompt_table_execution.mojo`, `scripts/check_prompt_true_fraction_multiples.py`, `STAGE12C5AZ_MIXED_FRACTION_MULTIPLE_AXES.md`, `tests/test_prompt_mixed_fraction_multiple_source.py`, `STAGE12C5BD_PRESHEAF_INHERITANCE_RECIPROCAL_COLLISION.md`, `tests/test_prompt_reciprocal_collision_source.py`, `STAGE12C5BF_MULTI_DOMAIN_FRACTION_PLANS.md`, `tests/test_prompt_multi_domain_fraction_source.py`

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

### PY-CAND-007 – Standard-Wortgrenze der Promptvervollständigung trennt ASCII und Unicode innerhalb deutscher Wörter

- Ursprung: `python_reference`
- Klasse / Schwere: `completion_unicode_segmentation` / `medium`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- entdeckt in: `12c4t`
- Reproduktion: `python3 -c "from reta_architecture.completion_word import *; d=Document('grö'); print(repr(word_before_cursor(d))); print([x.text for x in iter_word_completions(['größe'], d)])" unter verschiedenen prompt_toolkit-Versionen`
- heutiger Vertrag: Das beobachtbare Python-Verhalten ist von der installierten prompt_toolkit-Version abhängig: ältere Versionen liefern nur 'ö' und keine Größe-Vervollständigung, neuere Versionen liefern 'grö' und 'größe'. Mojo bewahrt bis zur bewussten Vertragsentscheidung den historischen, explizit implementierten Klassenvertrag; Sourcegates akzeptieren beide Python-Zustände statt einen upstream behobenen Fehler zu erzwingen.
- spätere Python-Aktion: Nach Abschluss der Portierung eine konkrete prompt_toolkit-Mindestversion und Unicode-Wortsemantik festlegen. Danach completion_word.py und Mojo gemeinsam auf denselben expliziten Unicode-Vertrag umstellen und die versionsabhängige Kandidatenklassifikation entfernen.
- Python-Orte: `python_reference/reta_architecture/completion_word.py:82-94`
- Mojo-Orte: `src/reta_mojo/completion_word.mojo`
- Belege: `STAGE12C4T_NATIVE_WORD_COMPLETION.md`, `STAGE12C5N_NATIVE_HTML_CLASS_EXTRACTION.md`, `scripts/check_completion_word_parity.py`, `tests/test_documented_python_defects.py`

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
- heutiger Vertrag: Jeder Build kürzt den von Mojo automatisch ergänzten absoluten Compiler-RUNPATH in-place auf $ORIGIN/../lib/mojo; der Runtime-Starter bleibt als Altbinary-Fallback.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `scripts/build.sh`, `scripts/build-heavy.sh`, `bin/mojo-runtime-exec`, `tools/sanitize_mojo_runpath.py`
- Belege: `STAGE12C4L_PORTABLE_RUNTIME_RAW_MARKUP.md`, `tests/test_sanitize_mojo_runpath.py`

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

### PY-OPEN-003 – Dictionary-Invertierung verwirft frühere Quellschlüssel bei gemeinsamem Integerwert

- Ursprung: `python_reference`
- Klasse / Schwere: `bug` / `medium`
- Python-Status: `open`
- Mojo-Status: `fixed`
- entdeckt in: `initial-port-audit`
- Reproduktion: `python3 -c "from reta_architecture.arithmetic import invert_int_value_dict; print(invert_int_value_dict({'a':['1'],'b':['1']}))"`
- heutiger Vertrag: Python liefert für den Integerwert 1 nur den zuletzt besuchten Schlüssel; Mojo bewahrt alle verschiedenen Quellschlüssel typisiert.
- spätere Python-Aktion: In Python bei int_value statt beim ursprünglichen String value auf vorhandene Zielschlüssel prüfen und einen Regressionstest mit zwei Quellschlüsseln für denselben Integerwert ergänzen.
- Python-Orte: `python_reference/reta_architecture/arithmetic.py:126-137`
- Mojo-Orte: `src/reta_mojo/arithmetic.mojo:200-221`
- Belege: `MIGRATION_NOTES.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`

### PY-CAND-004 – Mondzahl-Erkennung verwendet gerundete Fließkommawurzeln statt exakter Potenzprüfung

- Ursprung: `python_reference`
- Klasse / Schwere: `bug_candidate` / `medium`
- Python-Status: `candidate`
- Mojo-Status: `fixed`
- entdeckt in: `initial-port-audit`
- Reproduktion: `Vergleiche moonNumber(n) mit exakter ganzzahliger Potenzprüfung an großen und potenznahen Ganzzahlen.`
- heutiger Vertrag: Mojo akzeptiert eine Basis nur, wenn base**exponent exakt der Eingabe entspricht; Python rundet die Fließkommawurzel auf fünf Nachkommastellen.
- spätere Python-Aktion: Python auf eine begrenzte exakte Integerwurzel-/Potenzprüfung umstellen und zuvor einen Suchtest für falsch positive beziehungsweise negative Rundungsfälle festlegen.
- Python-Orte: `python_reference/reta_architecture/number_theory.py:18-29`
- Mojo-Orte: `src/reta_mojo/number_theory.mojo:18-38`
- Belege: `MIGRATION_NOTES.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`

### PY-OPEN-004 – Zwei Python-Architekturtests erwarten veraltete dataDict-Größe 554 statt 556

- Ursprung: `python_reference_tests`
- Klasse / Schwere: `test_bug` / `medium`
- Python-Status: `open`
- Mojo-Status: `not_applicable`
- entdeckt in: `upload-baseline`
- Reproduktion: `python3 -m pytest -q python_reference/tests/test_architecture_refactor.py`
- heutiger Vertrag: Die unveränderte Referenz erzeugt 556 Einträge; zwei Tests beziehungsweise mehrere Assertions halten noch 554 fest und schlagen reproduzierbar fehl.
- spätere Python-Aktion: Fachlich prüfen, welche zwei Einträge hinzugekommen sind, dann die erwarteten Snapshotgrößen samt erklärendem Fixture aktualisieren oder die unerwünschten Einträge an der Quelle entfernen.
- Python-Orte: `python_reference/tests/test_architecture_refactor.py:163`, `python_reference/tests/test_architecture_refactor.py:982`, `python_reference/tests/test_architecture_refactor.py:986`
- Belege: `MIGRATION_NOTES.md`, `TEST_RESULTS.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`, `scripts/check_documented_python_baseline.py`

### PY-OPEN-005 – Python-Workflowtest erwartet veralteten Orchestrierungsnamen load_/religion_table

- Ursprung: `python_reference_tests`
- Klasse / Schwere: `test_bug` / `low`
- Python-Status: `open`
- Mojo-Status: `not_applicable`
- entdeckt in: `upload-baseline`
- Reproduktion: `python3 -m pytest -q python_reference/tests/test_architecture_refactor.py::ArchitectureRefactorTests::test_program_workflow_layer_is_explicit`
- heutiger Vertrag: Der aktuelle Snapshot enthält load_religion_table; der Test sucht noch den älteren Namen load_/religion_table.
- spätere Python-Aktion: Den fachlich gültigen Orchestrierungsnamen bestätigen und die Testassertion auf den aktuellen stabilen Namen aktualisieren.
- Python-Orte: `python_reference/tests/test_architecture_refactor.py:732-740`
- Belege: `MIGRATION_NOTES.md`, `TEST_RESULTS.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`, `scripts/check_documented_python_baseline.py`

### PY-OPEN-006 – Python-Progress-Test sucht Git-Metadaten im eingefrorenen Unterbaum

- Ursprung: `python_reference_tests`
- Klasse / Schwere: `test_bug` / `low`
- Python-Status: `open`
- Mojo-Status: `not_applicable`
- entdeckt in: `12c5at`
- Reproduktion: `python3 -m pytest -q python_reference/tests/test_architecture_refactor.py::ArchitectureRefactorRegressionTest::test_architecture_progress_layer_is_explicit`
- heutiger Vertrag: REPO_ROOT zeigt innerhalb des eingefrorenen Referenzbaums auf python_reference. Die Git-Metadaten liegen jedoch im Projektwurzelverzeichnis. Der Snapshot meldet deshalb korrekt outstanding_work=0 und status=passed, während der Test fälschlich den Zweig ohne Repositorymetadaten nimmt und mindestens einen offenen Punkt verlangt.
- spätere Python-Aktion: Die Umgebungsentscheidung vom fachlichen Snapshotvertrag trennen oder die tatsächliche Projektwurzel robust bestimmen; anschließend bei status=passed unabhängig vom Ablageort exakt null offene Punkte erwarten.
- Python-Orte: `python_reference/tests/test_architecture_refactor.py:1773-1780`
- Belege: `STAGE12C5AT_NATIVE_PROMPT_EXECUTION.md`, `tests/test_documented_python_defects.py`

### PY-CAND-005 – Kanonischer Parameteralias hängt bei set-Einträgen von Python-Hashreihenfolge ab

- Ursprung: `python_reference`
- Klasse / Schwere: `bug_candidate` / `medium`
- Python-Status: `candidate`
- Mojo-Status: `fixed`
- entdeckt in: `schema-port`
- Reproduktion: `Erzeuge paraDict mit verschiedenen PYTHONHASHSEED-Werten und vergleiche den kanonischen Namen der set-basierten paraNdataMatrix-Einträge.`
- heutiger Vertrag: Der Mojo-Snapshot sortiert ausschließlich ungeordnete Mengen numerisch beziehungsweise lexikographisch; geordnete Tupel bleiben unverändert.
- spätere Python-Aktion: Im Python-Schemabau für set-basierte Aliasgruppen eine fachlich definierte stabile Reihenfolge verwenden und Hash-Seed-Regressionen ergänzen.
- Python-Orte: `python_reference/i18n/words_runtime.py`, `python_reference/reta_architecture/semantics_builder.py`
- Mojo-Orte: `src/reta_mojo/schema_catalog.mojo`, `tools/generate_schema_catalog.py`
- Belege: `MIGRATION_NOTES.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`

### PY-CAND-006 – Legacy-Primwiederholungsfunktion mischt Zahlen und Zeichenketten im selben Rückgabewert

- Ursprung: `python_reference`
- Klasse / Schwere: `api_bug_candidate` / `low`
- Python-Status: `candidate`
- Mojo-Status: `fixed`
- entdeckt in: `initial-port-audit`
- Reproduktion: `python3 -c "from reta_architecture.arithmetic import prime_repeat_legacy; print(prime_repeat_legacy([3,2,2,2]))"`
- heutiger Vertrag: Mojo trennt typisierte Primzahl/Anzahl-Paare von der reinen Stringdarstellung; Python behält vorerst die heterogene Legacy-Liste.
- spätere Python-Aktion: Verwendungen auf prime_repeat_pairs beziehungsweise eine explizite Label-Funktion migrieren und die heterogene Legacy-Schnittstelle anschließend deprecaten.
- Python-Orte: `python_reference/reta_architecture/arithmetic.py:65-94`
- Mojo-Orte: `src/reta_mojo/arithmetic.mojo`
- Belege: `MIGRATION_NOTES.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`

### MOJO-FIXED-006 – -nichts wurde fälschlich als --art=nichts interpretiert und unterdrückte Tabellen

- Ursprung: `mojo_port`
- Klasse / Schwere: `ownership_bug` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c4s`
- Reproduktion: `reta -nichts -zeilen --vorhervonausschnitt=1 -spalten --religionen=sternpolygon`
- heutiger Vertrag: -nichts/-nothing ist ohne weitere wirksame Argumente still, wird innerhalb eines Tabellenvektors aber ignoriert; nur --art=nichts/--type=nothing wählt den stillen Renderer.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Python-Orte: `python_reference/reta_architecture/parameter_runtime.py:188-204`
- Mojo-Orte: `src/reta_mojo/native_cli_controls.mojo`, `src/compat_main.mojo`
- Belege: `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`, `tests/test_compat_launcher.py`

### MOJO-FIXED-007 – --nocolor war erkannt, wurde vom nativen Shellrenderer aber ignoriert

- Ursprung: `mojo_port`
- Klasse / Schwere: `renderer_bug` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `10c`
- Reproduktion: `reta ... -ausgabe --nocolor`
- heutiger Vertrag: Das typisierte color_rows-Flag verhindert bei deaktivierter Farbe sämtliche ANSI-Farbsequenzen.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `src/reta_mojo/table_rendering.mojo`
- Belege: `MIGRATION_NOTES.md`

### MOJO-FIXED-008 – Leere explizite Spaltenreihenfolge wurde als alle Spalten umgedeutet

- Ursprung: `mojo_port`
- Klasse / Schwere: `selection_bug` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `10c`
- Reproduktion: `Explizite relative Spaltenposition anfordern, die nach der Generatorpipeline keine Ergebnisspalte trifft.`
- heutiger Vertrag: explicit_order_requested unterscheidet keine Anforderung von einer ausdrücklich angeforderten, aber leeren Auswahl.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `src/reta_mojo/native_reta_cli.mojo`, `src/reta_mojo/all_columns_plan.mojo`
- Belege: `MIGRATION_NOTES.md`

### MOJO-FIXED-009 – Promptankündigung und erste Tabellenzeile wurden ohne LF zusammengeklebt

- Ursprung: `mojo_port`
- Klasse / Schwere: `serialization_bug` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `10c/12c1`
- Reproduktion: `rpb 'a1'`
- heutiger Vertrag: Jede sichtbare reta-Befehlsankündigung endet vor der Tabellennutzlast mit genau einem LF.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `src/reta_mojo/prompt_controller.mojo`, `src/reta_mojo/compact_prompt.mojo`
- Belege: `MIGRATION_NOTES.md`, `STAGE12C1_NATIVE_TERMINAL_PROMPT_PARITY.md`

### MOJO-FIXED-010 – Kompakter Promptparser konnte bei rohen Unicode-Befehlen an UTF-8-Bytegrenzen abstürzen

- Ursprung: `mojo_port`
- Klasse / Schwere: `unicode_bug` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `10f/12c3`
- Reproduktion: `Prompt: python print("ä λ")`
- heutiger Vertrag: Rohe Interpreter-/Shellbefehle umgehen den kompakten Byte-Scanner vor jeder Nutzlasttransformation.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `src/reta_mojo/prompt_language.mojo`, `src/reta_mojo/prompt_controller.mojo`
- Belege: `STAGE10F_NATIVE_COMPACT_PROMPT.md`, `STAGE12C3_NATIVE_RAW_PROMPT_COMMANDS.md`, `MIGRATION_NOTES.md`

### MOJO-FIXED-011 – Eigene dlsym-Deklaration kollidierte im vollständigen Build mit Mojo-Rückgabetyp

- Ursprung: `mojo_port`
- Klasse / Schwere: `integration_bug` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4a`
- Reproduktion: `Vollständiger gemeinsamer Build von Promptcontroller und früher prompt_python_bridge.mojo.`
- heutiger Vertrag: Die native Kindprozessgrenze verwendet keine abweichende eigene dlsym-Signatur und keine eingebettete CPython-Brücke.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `src/reta_mojo/prompt_external_commands.mojo`
- Belege: `STAGE12C4A_PROMPT_BRIDGE_INTEGRATION.md`, `MIGRATION_NOTES.md`

### MOJO-FIXED-012 – Gemischter Reziprokplan serialisierte --universum mit falscher Groß-/Kleinschreibung

- Ursprung: `mojo_port`
- Klasse / Schwere: `cli_serialization_bug` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c4c`
- Reproduktion: `Promptfall mit gemischtem reziprokem Universumsmodifikator aus check_prompt_mixed_reciprocal_parity.sh.`
- heutiger Vertrag: Der native Plan verwendet den wirksamen historischen Parameter --Universum und ist bytegleich zur instrumentierten Referenz.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `src/reta_mojo/prompt_table_execution.mojo`
- Belege: `STAGE12C4C_NATIVE_MIXED_RECIPROCAL_MODIFIERS.md`, `TEST_RESULTS.md`

### MOJO-FIXED-013 – --onetable wurde vor vorhandener Rendererimplementierung fälschlich nativ beansprucht

- Ursprung: `mojo_port`
- Klasse / Schwere: `ownership_bug` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c4e`
- Reproduktion: `reta ... -ausgabe --onetable im Stage-12c4e-Vorstand`
- heutiger Vertrag: Ownership wird nur bei tatsächlich implementierter Ein-Tabellen-Semantik übernommen; die inzwischen portierten Fälle besitzen dedizierte Tests.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `src/reta_mojo/native_reta_cli.mojo`, `src/reta_mojo/table_rendering.mojo`
- Belege: `STAGE12C4E_NATIVE_FIRST_COMPAT.md`, `TEST_RESULTS.md`

### MOJO-FIXED-014 – Paginierter Renderer brach Überlangwörter und Fortsetzungsfarben abweichend

- Ursprung: `mojo_port`
- Klasse / Schwere: `renderer_bug` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c4i`
- Reproduktion: `scripts/check_paginated_rendering_parity.sh`
- heutiger Vertrag: Vorhandene ASCII-Bindestriche werden vor hartem Schnitt genutzt; nur wirklich fehlende Shellfragmente erhalten die neutrale Restfarbe.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `src/reta_mojo/table_rendering.mojo`
- Belege: `STAGE12C4I_NATIVE_PAGINATED_RENDERING.md`, `TEST_RESULTS.md`

### MOJO-FIXED-015 – Globale Nullbreite verwendete feste 80/73 statt reale Terminalgeometrie

- Ursprung: `mojo_port`
- Klasse / Schwere: `terminal_bug` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c1`
- Reproduktion: `PTY-Ausgabe von rpb a1 bei 120 oder 200 Terminalspalten.`
- heutiger Vertrag: Mojo fragt TIOCGWINSZ ab und fällt danach auf COLUMNS beziehungsweise den historischen 80-Spaltenwert zurück.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `src/reta_mojo/terminal_geometry.mojo`, `src/reta_mojo/table_rendering.mojo`
- Belege: `STAGE12C1_NATIVE_TERMINAL_PROMPT_PARITY.md`, `MIGRATION_NOTES.md`

### MOJO-FIXED-016 – Duplikatsperre entfernte sichtbare wiederholte Prompt-Katalogauswahl

- Ursprung: `mojo_port`
- Klasse / Schwere: `prompt_semantics_bug` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `10j`
- Reproduktion: `Wiederhole dasselbe numerische Aliasbündel in einem Promptkommando.`
- heutiger Vertrag: Das sichtbare Legacy-CLI-Token bewahrt Wiederholungen, während die semantische Generatoranforderung wie in Python dedupliziert bleibt.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `src/reta_mojo/prompt_table_execution.mojo`
- Belege: `STAGE10J_NATIVE_DUPLICATE_CATALOG.md`, `MIGRATION_NOTES.md`

### MOJO-FIXED-017 – Entfernte std.python-Promptbrücke tauchte wieder als tote Quelldatei im Archiv auf

- Ursprung: `packaging_source_tree`
- Klasse / Schwere: `source_hygiene_bug` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4s`
- Reproduktion: `test -e src/reta_mojo/prompt_python_bridge.mojo && grep -n std.python src/reta_mojo/prompt_python_bridge.mojo`
- heutiger Vertrag: Die Datei ist entfernt; Source-Gates verlangen null prompt_python_bridge-Dateien und null aktive std.python-Importe. Stage 12c5a reproduzierte und schloss ein erneutes Auftauchen im hochgeladenen Archiv.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `src/reta_mojo/prompt_python_bridge.mojo`
- Belege: `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`, `tests/test_prompt_external_source.py`, `STAGE12C5A_NATIVE_PROMPT_INTERACTION.md`, `tests/test_prompt_interaction_source.py`

### MOJO-FIXED-018 – Quellmanifest nahm verschachtelte pytest-Cachedateien auf

- Ursprung: `packaging_source_tree`
- Klasse / Schwere: `source_manifest_hygiene_bug` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4t`
- Reproduktion: `mkdir -p python_reference/.pytest_cache/v/cache && scripts/update_source_manifest.sh && grep '/.pytest_cache/' SOURCE_MANIFEST.sha256`
- heutiger Vertrag: Der Manifestgenerator verwirft .pytest_cache-Verzeichnisse auf jeder Baumtiefe; das entpackte releasefähige Archiv kann sein Manifest ohne Cacheartefakte vollständig prüfen.
- spätere Python-Aktion: Keine Python-Produktivcodeänderung erforderlich.
- Mojo-Orte: `scripts/update_source_manifest.sh`
- Belege: `STAGE12C4T_NATIVE_WORD_COMPLETION.md`, `tests/test_known_defects.py`, `scripts/update_source_manifest.sh`

### MOJO-FIXED-019 – Prompt-Kataloggenerator verwendete übersetzte Zeilenwerte statt der wirksamen Python-Schlüssel

- Ursprung: `mojo_port_generator`
- Klasse / Schwere: `completion_catalog_semantics_bug` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c4u`
- Reproduktion: `scripts/check_completion_nested_parity.sh; der englische Kontext 'reta -lines --primes=p' muss Python-konform 'primenumbers' und 'primzahlen' anbieten.`
- heutiger Vertrag: Der Generator übernimmt für allgemeine Zeilenwertkontexte die tatsächlichen Python-Dictionary-Schlüssel und überschreibt ausschließlich die drei vom Original lokalisierten Spezialdomänen. Die erweiterte Deutsch-/Englisch-Probe ist in 67/67 Kontexten byteidentisch.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; Python ist hier die korrekte Referenz.
- Python-Orte: `python_reference/reta_architecture/completion_runtime.py`, `python_reference/reta_architecture/completion_nested.py`
- Mojo-Orte: `scripts/generate_prompt_nested_catalog.py`, `assets/prompt_nested_completion.tsv`, `src/reta_mojo/completion_nested.mojo`
- Belege: `STAGE12C4U_NATIVE_NESTED_COMPLETION.md`, `scripts/check_completion_nested_parity.sh`, `TEST_RESULTS.md`, `tests/test_completion_native_ownership.py`

### MOJO-FIXED-020 – Native Prompt-History protokollierte die Umschaltbefehle für Logging

- Ursprung: `mojo_port`
- Klasse / Schwere: `prompt_history_semantics_bug` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c4v`
- Reproduktion: `History aktivieren und loggen beziehungsweise nichtloggen oder logging_yes beziehungsweise logging_no eingeben; die Befehle dürfen nicht in ~/.ReTaPromptHistory landen.`
- heutiger Vertrag: Leere Zeilen und beide lokalisierten History-Umschalter werden vor dem Anhängen über den nativen fünfsprachigen Befehlsalias-Katalog ausgeschlossen; normale Befehle und Duplikate bleiben erhalten.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; Python ToggleHistory ist die korrekte Referenz.
- Python-Orte: `python_reference/reta_architecture/prompt_session.py`
- Mojo-Orte: `src/reta_mojo/prompt_session.mojo`, `src/reta_mojo/native_prompt_input.mojo`
- Belege: `STAGE12C4V_NATIVE_PROMPT_SESSION_RUNTIME.md`, `tests/test_prompt_session.mojo`, `scripts/check_prompt_session_parity.sh`

### MOJO-FIXED-021 – Dezimale gespeicherte Prompttokens wurden immer als Löschposition interpretiert

- Ursprung: `mojo_port`
- Klasse / Schwere: `prompt_storage_semantics_bug` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c4v`
- Reproduktion: `Speichere reta 2 --nocolor und lösche mit der Auswahl 2; der literal gespeicherte Wert 2 muss entfernt werden, nicht bedingungslos die zweite Position.`
- heutiger Vertrag: Eine reine Dezimalangabe löscht zuerst einen gleichlautenden gespeicherten Tokenwert; nur ohne solchen Wert wird sie als Position behandelt. Bereiche und nichtdezimale Zeilenangaben bleiben positionsbasiert.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; die ungewöhnliche Prioritätsregel des Originals wird byte- und zustandsgleich bewahrt.
- Python-Orte: `python_reference/reta_architecture/prompt_session.py`
- Mojo-Orte: `src/reta_mojo/prompt_session.mojo`
- Belege: `STAGE12C4V_NATIVE_PROMPT_SESSION_RUNTIME.md`, `tests/test_prompt_session.mojo`, `scripts/check_prompt_session_parity.sh`

### MOJO-FIXED-022 – Native Speicher- und Löschprompts waren hart deutsch und enthielten zusätzliche Leerzeichen

- Ursprung: `mojo_port`
- Klasse / Schwere: `prompt_i18n_display_bug` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c4v`
- Reproduktion: `Starte retaPrompt mit -language=english und aktiviere Speichern oder Löschen; der Prompt muss exakt save what> beziehungsweise delete what> statt speichern>  oder loeschen>  lauten.`
- heutiger Vertrag: Normal-, Speicher- und Löschpräfixe werden für alle fünf Sprachen aus frischen Referenzprozessen generiert und ohne zusätzliches Leerzeichen an den nativen Editor übergeben.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; die i18n-Werte des Originals sind die korrekte Referenz.
- Python-Orte: `python_reference/reta_architecture/prompt_session.py`, `python_reference/i18n/words_runtime.py`
- Mojo-Orte: `src/reta_mojo/prompt_runtime.mojo`, `src/reta_mojo/prompt_runtime_catalog.mojo`, `src/reta_mojo/prompt_session.mojo`, `src/prompt_main.mojo`
- Belege: `STAGE12C4V_NATIVE_PROMPT_SESSION_RUNTIME.md`, `scripts/check_prompt_runtime_parity.sh`, `tests/test_prompt_runtime_contract.mojo`, `tests/test_prompt_session.mojo`, `scripts/check_prompt_session_pty_prefix.py`

### TEST-OPEN-001 – Breiter direkter CSV-Paritätsharness verklebt unter einem Python-3.13-Lauf Referenzzeilen

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `test_harness_bug` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `not_applicable`
- entdeckt in: `10c`
- Reproduktion: `scripts/check_native_table_parity.sh unter der in TEST_RESULTS.md beschriebenen Python-3.13.5-Umgebung.`
- heutiger Vertrag: Der breite Fall wird ausdrücklich nicht als bestanden gezählt; feste Byte-Fixtures und normalisierte geordnete CSV-Tokenströme prüfen die betroffenen Pfade separat.
- spätere Python-Aktion: Harness auf einen binärtreuen Referenzaufruf umstellen und erst danach den offenen Eintrag schließen.
- Python-Orte: `scripts/check_native_table_parity.sh`
- Belege: `TEST_RESULTS.md`

### TEST-FIXED-001 – Promptfixtures konnten zusammengeklebte oder leere Referenznutzlasten akzeptieren

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `test_gap` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c1`
- Reproduktion: `Altes Fixture mit reta-Befehl:reta ohne folgende LF-Nutzlastzeile.`
- heutiger Vertrag: Fixture-Gates verbieten zusammengeklebte Ankündigungen, leere Referenzdateien und fehlende zweite Nutzlastzeilen.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `tests/test_prompt_fixture_integrity.py`
- Belege: `MIGRATION_NOTES.md`, `STAGE12C1_NATIVE_TERMINAL_PROMPT_PARITY.md`

### TEST-FIXED-002 – Gemeinsame Kompatibilitäts-Pytest-Prozesse konnten nach bestandenen Knoten im Teardown hängen

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `test_harness_bug` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4s`
- Reproduktion: `RETA_COMPAT_BINARY=target/test-bin/reta-mojo-compat-bin python3 -m pytest -q tests/test_compat_launcher.py`
- heutiger Vertrag: Das Release-Gate startet jeden der 20 Kompatibilitätsknoten in einem eigenen Pytest-Prozess; die vier Gruppen strukturieren nur noch die Berichterstattung. Dadurch kann ein Teardown-Hänger keinen bereits bestandenen Nachbarknoten blockieren.
- spätere Python-Aktion: Keine Python-Produktivcodeänderung erforderlich.
- Python-Orte: `tests/test_compat_launcher.py`
- Mojo-Orte: `scripts/check_compat_launcher.sh`
- Belege: `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`, `scripts/check_compat_launcher.sh`

### TEST-FIXED-003 – Prompt-Katalogcheck setzte eine nicht ausgelieferte Projekt-.venv voraus

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `source_archive_portability_bug` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4u`
- Reproduktion: `Source-only-Archiv ohne .venv entpacken und scripts/check_prompt_language_catalog.sh ausführen.`
- heutiger Vertrag: Der Reproduzierbarkeitscheck verwendet RETA_PYTHON, andernfalls die lokale .venv nur falls vorhanden und schließlich systemweites python3. Er läuft dadurch auch aus einem sauberen Source-only-Archiv.
- spätere Python-Aktion: Keine Python-Produktivcodeänderung erforderlich.
- Mojo-Orte: `scripts/check_prompt_language_catalog.sh`
- Belege: `STAGE12C4U_NATIVE_NESTED_COMPLETION.md`, `scripts/check_prompt_language_catalog.sh`, `tests/test_completion_native_ownership.py`

### MOJO-FIXED-023 – Modallogikgenerator materialisierte mehrere Produkte jenseits der physischen Tabellenlänge

- Ursprung: `mojo_port`
- Klasse / Schwere: `generated_column_boundary_bug` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c4w`
- Reproduktion: `Vollständigen HTML-Lauf mit -spalten --alles --breite=0 -ausgabe --art=html --onetable --nocolor erzeugen und scripts/compare_full_all_html.py gegen Python ausführen; vor der Korrektur unterschied sich Zeile 197, Spalte 700.`
- heutiger Vertrag: Der native Modallogiklauf endet beim ersten Vielfachen an oder hinter der realen Tabellenlänge und reproduziert damit die endliche historische Python-Multiplikationsabbildung. Der vollständige --alles-Lauf ist in 149.356 von 149.356 Zellen semantisch identisch.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; die endliche Referenzabbildung ist korrekt und wird in Mojo bewahrt.
- Python-Orte: `python_reference/libs/lib4tables.py`
- Mojo-Orte: `src/reta_mojo/generated_table_columns.mojo`, `tests/test_generated_table_columns.mojo`
- Belege: `STAGE12C4W_NATIVE_PROMPT_PREPARATION_FULL_ALL.md`, `scripts/compare_full_all_html.py`, `tests/test_generated_table_columns.mojo`

### MOJO-COMPAT-001 – Vollständige HTML-Tabelle ist semantisch, aber noch nicht byteweise serialisierungsgleich

- Ursprung: `mojo_port`
- Klasse / Schwere: `html_serialization_compatibility_gap` / `low`
- Python-Status: `correct_reference`
- Mojo-Status: `compatibility_preserved`
- entdeckt in: `12c4w`
- Reproduktion: `Python und Mojo mit -spalten --alles --breite=0 -ausgabe --art=html --onetable --nocolor ausführen und scripts/compare_full_all_html.py anwenden.`
- heutiger Vertrag: Form und alle 149.356 Zellen sind semantisch identisch. Roh identisch sind 95,572324 Prozent der Zellen; Unterschiede bleiben bei Entity- und Anführungszeichenmaskierung, unsichtbarem Leerraum vor Satzzeichen und der Reihenfolge semantisch ungeordneter HTML-Listenelemente sichtbar.
- spätere Python-Aktion: Den HTML-Serializer später auf byteidentische Maskierung, Leerraumsetzung und historische Listenreihenfolge bringen, ohne die bereits vollständige semantische Parität zu verschlechtern.
- Python-Orte: `python_reference/reta_architecture/table_output.py`, `python_reference/libs/lib4tables.py`
- Mojo-Orte: `src/reta_mojo/table_rendering.mojo`, `scripts/compare_full_all_html.py`
- Belege: `STAGE12C4W_NATIVE_PROMPT_PREPARATION_FULL_ALL.md`, `scripts/compare_full_all_html.py`

### TEST-FIXED-004 – Das frühere --alles-Gate prüfte nur eine kleine Tabellenfixture statt des vollständigen Datenbestands

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `end_to_end_test_gap` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4w`
- Reproduktion: `Den alten Ein-Zeilen-Fixturetest bestehen lassen und anschließend den echten vollständigen --alles-Lauf vergleichen; nur der Vollbestand zeigte die Modallogik-Grenzabweichung.`
- heutiger Vertrag: Ein reproduzierbares schweres Gate erzeugt die vollständigen Python- und Mojo-HTML-Tabellen, prüft identische Form und fordert semantische Gleichheit jeder einzelnen Zelle. Roh- und dekodierte Serialisierungsparität werden zusätzlich getrennt berichtet.
- spätere Python-Aktion: Keine Python-Produktivcodeänderung erforderlich.
- Mojo-Orte: `scripts/check_full_all_parity.sh`, `scripts/compare_full_all_html.py`, `scripts/test_stage12c4w.sh`
- Belege: `STAGE12C4W_NATIVE_PROMPT_PREPARATION_FULL_ALL.md`, `scripts/check_full_all_parity.sh`, `scripts/compare_full_all_html.py`

### TEST-FIXED-005 – Vorderer Promptvorbereitungs-Paritätstest setzte eine lokale Projekt-.venv voraus

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `source_archive_portability_bug` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4w`
- Reproduktion: `Source-only-Archiv ohne .venv entpacken und scripts/check_prompt_preparation_parity.sh ausführen.`
- heutiger Vertrag: Der Prüfer verwendet RETA_PYTHON, andernfalls eine vorhandene lokale .venv und schließlich das systemweite python3. Er ist damit wie die Katalog- und Vollparitätschecks source-archive-portabel.
- spätere Python-Aktion: Keine Python-Produktivcodeänderung erforderlich.
- Mojo-Orte: `scripts/check_prompt_preparation_parity.sh`
- Belege: `STAGE12C4W_NATIVE_PROMPT_PREPARATION_FULL_ALL.md`, `scripts/check_prompt_preparation_parity.sh`, `tests/test_prompt_preparation_source.py`

### TEST-FIXED-006 – Gemeinsamer Stage-12c4w-Pytest-Prozess blieb nach vollständig ausgegebenen Testpunkten im Teardown hängen

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `test_harness_teardown_hang` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4w`
- Reproduktion: `scripts/test_stage12c4w.sh mit allen Source-Gates in einem einzigen python3 -m pytest-Prozess ausführen; 20 Testpunkte erscheinen, der Prozess beendet sich in der Sandbox aber nicht zuverlässig.`
- heutiger Vertrag: Der Sammeltest startet jede Source-Testdatei in einem eigenen Pytest-Prozess. Ein Teardown-Hänger kann dadurch keine bereits bestandenen Nachbargruppen blockieren oder deren Ergebnis verdecken.
- spätere Python-Aktion: Keine Python-Produktivcodeänderung erforderlich.
- Mojo-Orte: `scripts/test_stage12c4w.sh`
- Belege: `STAGE12C4W_NATIVE_PROMPT_PREPARATION_FULL_ALL.md`, `scripts/test_stage12c4w.sh`

### PY-CAND-008 – Sprachfehlertext verwendet den falschen Parameter -languages= und wiederholt erlaubte Sprachcodes

- Ursprung: `python_reference`
- Klasse / Schwere: `i18n_cli_diagnostic_bug` / `low`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- entdeckt in: `12c4x`
- Reproduktion: `PYTHONHASHSEED=0 python3 -c "import sys; sys.path.insert(0,'python_reference'); import i18n.words_runtime as w; print(w.wrongLangSentence)"`
- heutiger Vertrag: Der native i18n-Baumkatalog konserviert den beobachtbaren Text bytegenau: Er nennt historisch -languages= statt des tatsächlich ausgewerteten -language= und übernimmt die mehrfach vorkommenden Werte en, de, vn, cn und kr aus sprachen.values().
- spätere Python-Aktion: Nach Abschluss der Transpilierung den Text auf -language= umstellen, die erlaubten kanonischen Namen oder Codes dedupliziert und in fachlich definierter Reihenfolge ausgeben und Python sowie Mojo gemeinsam auf neue Soll-Fixtures migrieren.
- Python-Orte: `python_reference/i18n/words_runtime.py:540-543`, `python_reference/reta_architecture/parameter_runtime.py:212`
- Mojo-Orte: `assets/i18n_words/deutsch.tsv`, `src/reta_mojo/i18n_words.mojo`
- Belege: `STAGE12C4X_NATIVE_I18N_WORDS.md`, `tests/test_i18n_words_source.py`, `assets/i18n_words/manifest.json`

### MOJO-FIXED-024 – Installierte native Inspektionslauncher leiteten den Projektstamm aus dem Symlinkpfad statt dem realen Launcherpfad ab

- Ursprung: `mojo_port`
- Klasse / Schwere: `fhs_launcher_symlink_resolution` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4x`
- Reproduktion: `DESTDIR=/tmp/reta-stage ./scripts/install.sh /usr und anschließend /tmp/reta-stage/usr/bin/reta-mojo-i18n --summary english ausführen; der alte Launcher suchte /usr/target/bin/reta-mojo-i18n statt /usr/lib/reta/target/bin/reta-mojo-i18n.`
- heutiger Vertrag: Alle 16 nativen Inspektionslauncher lösen einen öffentlichen FHS-Symlink zuerst mit readlink -f auf und bestimmen ROOT anschließend aus dem realen Launcherpfad. Dadurch funktionieren sie sowohl im Quellbaum als auch unter /usr/bin -> /usr/lib/reta/bin.
- spätere Python-Aktion: Keine Python-Produktivcodeänderung erforderlich.
- Mojo-Orte: `bin/reta-mojo-i18n`, `bin/reta-mojo-progress`, `bin/reta-mojo-activation`, `scripts/check_install_layout.sh`
- Belege: `STAGE12C4X_NATIVE_I18N_WORDS.md`, `tests/test_i18n_words_source.py`, `scripts/check_install_layout.sh`

### MOJO-FIXED-025 – Generierter i18n-Baum enthielt den absoluten Checkoutpfad des Generatorrechners

- Ursprung: `mojo_port`
- Klasse / Schwere: `generated_asset_absolute_path_leak` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4x`
- Reproduktion: `Das Source-only-Archiv an einen anderen Pfad entpacken und scripts/check_i18n_words_catalog.sh ausführen; vor der Korrektur unterschieden sich localedir/i18nPath bereits in Zeile 63 durch den jeweiligen absoluten Checkoutpfad.`
- heutiger Vertrag: Importzeitlich absolute Python-Pfade unter dem Referenzbaum werden beim Export deterministisch auf python_reference/... normalisiert. Der fünfsprachige Katalog ist dadurch nach Entpacken an beliebiger Stelle byteidentisch regenerierbar und enthält keinen Sandbox- oder Benutzerpfad.
- spätere Python-Aktion: Keine Python-Produktivcodeänderung erforderlich; der absolute Python-Laufzeitpfad bleibt Referenzverhalten, während das portable native Asset bewusst die projektrelative Ressourcenschreibweise trägt.
- Mojo-Orte: `tools/generate_i18n_words_catalog.py`, `assets/i18n_words/deutsch.tsv`, `assets/i18n_words/english.tsv`
- Belege: `STAGE12C4X_NATIVE_I18N_WORDS.md`, `tests/test_i18n_words_source.py`, `scripts/check_i18n_words_catalog.sh`

### PY-CAND-009 – Obergrenzenhelfer materialisiert hunderte doppelte 1024-Werte und exponiert Mengenreihenfolge

- Ursprung: `python_reference`
- Klasse / Schwere: `parameter_upper_limit_duplicate_sequence` / `low`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- entdeckt in: `12c4y`
- Reproduktion: `PYTHONHASHSEED=0 python3 scripts/parameter_runtime_reference.py --vorhervonausschnitt=v2-4`
- heutiger Vertrag: Für v2-4 liefert Python 685 Werte, darunter 682 identische 1024-Einträge, weil zuerst eine Integer-Menge expandiert und danach jeder Wert einzeln auf mindestens 1024 geklemmt wird. Produktiv wird nur das Maximum verwendet. Mojo bewahrt Anwendungsflag, Multiset und resultierende Obergrenze, serialisiert die Werte jedoch deterministisch in der nativen Bereichsparser-Reihenfolge.
- spätere Python-Aktion: Nach Abschluss der Transpilierung den Obergrenzenvertrag auf einen einzelnen Maximalwert oder eine deduplizierte fachlich sortierte Menge reduzieren und Python sowie Mojo gemeinsam auf diesen Sollvertrag migrieren.
- Python-Orte: `python_reference/reta_architecture/parameter_runtime.py:851-872`, `python_reference/reta_architecture/runtime_compat.py:96-107`
- Mojo-Orte: `src/reta_mojo/parameter_runtime.mojo`, `scripts/compare_parameter_runtime_parity.py`
- Belege: `STAGE12C4Y_NATIVE_PARAMETER_RUNTIME.md`, `scripts/check_parameter_runtime_parity.sh`, `tests/test_parameter_runtime.mojo`

### MOJO-FIXED-026 – Produktiver Parameterplan war als zweite Implementierung im monolithischen CLI-Besitzer eingebettet

- Ursprung: `mojo_port`
- Klasse / Schwere: `duplicate_native_owner_and_compiler_graph` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4y`
- Reproduktion: `Im Stand 12c4x src/reta_mojo/native_reta_cli.mojo nach ParameterRuntimePlan, Aliasauflösung, Breiten- und Spaltenplanlogik durchsuchen; dieselbe fachliche Grenze hatte keinen eigenständigen Besitzer und wurde beim Import des gesamten CLI-Moduls erneut kompiliert.`
- heutiger Vertrag: Der vollständige produktive Parameterplan und die Obergrenzenlogik liegen in parameter_runtime.mojo. native_reta_cli.mojo importiert den typisierten Besitzer und stellt nur noch einen dünnen Adapter bereit; die frühere zweite Implementierung ist entfernt.
- spätere Python-Aktion: Keine Python-Produktivcodeänderung erforderlich.
- Mojo-Orte: `src/reta_mojo/parameter_runtime.mojo`, `src/reta_mojo/native_reta_cli.mojo`
- Belege: `STAGE12C4Y_NATIVE_PARAMETER_RUNTIME.md`, `tests/test_parameter_runtime_source.py`, `tests/test_native_reta_cli.mojo`

### TEST-FIXED-007 – Portierungsmatrix verlor bereits nachgewiesene Completion- und i18n-Besitzer bei jeder Regeneration

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `generated_porting_matrix_ownership_regression` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4y`
- Reproduktion: `python3 tools/generate_porting_matrix.py ausführen und anschließend die Zeilen i18n/words.py, completion_nested.py oder completion_word.py prüfen; vor der Korrektur erschienen sie trotz bestandener nativer Stage-Gates erneut als Python-Referenz/Bridge.`
- heutiger Vertrag: Der Matrixgenerator führt alle in 12c4t, 12c4u und 12c4x übernommenen Wort-, Nested-Completion- und fünf aktiven i18n.words-Dateien explizit als nativ beziehungsweise generiert nativ. Ein Source-Test prüft Generatorabbildung und regenerierte Markdownzeilen.
- spätere Python-Aktion: Keine Python-Produktivcodeänderung erforderlich.
- Mojo-Orte: `tools/generate_porting_matrix.py`, `PORTING_MATRIX.md`
- Belege: `STAGE12C4Y_NATIVE_PARAMETER_RUNTIME.md`, `tests/test_porting_matrix_ownership.py`, `PORTING_MATRIX.md`

### TEST-FIXED-008 – Vollständiger HTML-Paritätsvergleich hielt beide 25-MiB-Tabellen als speicherintensive Zellobjektbäume

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `full_all_comparator_memory_pressure` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4y`
- Reproduktion: `python3 scripts/compare_full_all_html.py <python-all.html> <native-all.html> auf dem vollständigen 149356-Zellen-Bestand unter /usr/bin/time ausführen; der alte Parser hielt Rohteile, Textteile und Listenelemente beider Dokumente gleichzeitig und erreichte hier etwa 553 MiB Spitzenspeicher.`
- heutiger Vertrag: Der Vergleich speichert pro Zelle nur drei SHA-256-Digests und liest semantische Inhalte nur für tatsächlich abweichende Zellen erneut. Die historische verschachtelte Tabellenbehandlung und der 198-Zeilen/149356-Zellen-Vertrag bleiben unverändert; der gemessene Spitzenspeicher sank auf ungefähr 328 MiB.
- spätere Python-Aktion: Keine Python-Produktivcodeänderung erforderlich.
- Mojo-Orte: `scripts/compare_full_all_html.py`, `scripts/check_full_all_against_reference.sh`
- Belege: `STAGE12C4Y_NATIVE_PARAMETER_RUNTIME.md`, `tests/test_full_all_reference_workflow.py`, `scripts/compare_full_all_html.py`

### PY-CAND-010 – Vollständige --alles-Ausgabe ist ohne festen PYTHONHASHSEED nicht reproduzierbar

- Ursprung: `python_reference`
- Klasse / Schwere: `hash_order_dependent_full_table_output` / `medium`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- entdeckt in: `12c4z`
- Reproduktion: `python reta -spalten --alles --breite=0 -ausgabe --art=html --onetable --nocolor > middle.alx ohne gesetztes PYTHONHASHSEED ausführen und gegen einen zweiten Prozess oder den deterministischen Mojo-Lauf vergleichen.`
- heutiger Vertrag: Die hochgeladene unseeded Referenz besitzt dieselben 198 Tabellenzeilen und 149356 Zellen, permutiert aber 20 Metaspalten und variiert zehn set-basierte Generatorspalten. Das Gate richtet Überschriften vorkommensgenau aus, weist 1850 Hash-Zellen und ihre 214 Abweichungen separat aus und verlangt für den reproduzierbaren Kern 147506/147506 semantisch gleiche Zellen. Mojo bleibt deterministisch.
- spätere Python-Aktion: Nach Abschluss der Transpilierung alle beobachtbaren Mengen- und Frozenset-Iterationen in der Python-Tabellenplanung fachlich sortieren, einen kanonischen PYTHONHASHSEED-unabhängigen Spaltenvertrag festlegen und Python sowie Mojo gegen eine neu erzeugte seed-unabhängige Referenz prüfen.
- Python-Orte: `python_reference/reta_architecture/generated_columns.py:1356-1465`, `python_reference/reta_architecture/column_selection.py`, `python_reference/reta_architecture/table_runtime.py`
- Mojo-Orte: `scripts/compare_full_all_html.py`, `scripts/check_full_all_against_reference.sh`, `tests/references/reta-python-full-all-reference-v1.tar.bz2`
- Belege: `STAGE12C4Z_PROFESSIONAL_GENERATE_HTML.md`, `tests/test_full_all_reference_workflow.py`, `FULL_ALL_REFERENCE_WORKFLOW.md`

### MOJO-FIXED-027 – Installiertes generate_html wechselte in den privaten Programmstamm und schrieb dort ungefragt middle.alx

- Ursprung: `mojo_port`
- Klasse / Schwere: `fhs_unsafe_working_directory_and_implicit_output` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4z`
- Reproduktion: `DESTDIR=/tmp/reta-stage scripts/install.sh /usr ausführen, anschließend als normaler Benutzer aus einem fremden Verzeichnis /tmp/reta-stage/usr/bin/generate_html starten; der alte Launcher wechselte nach /usr/lib/reta und der Kern versuchte dort middle.alx zu schreiben.`
- heutiger Vertrag: generate_html wechselt sein Arbeitsverzeichnis nicht, schreibt standardmäßig ausschließlich nach stdout, erzeugt eine Mitteltabelle nur über --middle-output oder --legacy-middle und schreibt --output atomar. Öffentlicher Starter, privates Mojo-ELF, Daten und Manpage folgen dem FHS-Layout.
- spätere Python-Aktion: Keine Python-Produktivcodeänderung erforderlich.
- Mojo-Orte: `bin/generate_html`, `src/generate_html_main.mojo`, `scripts/install.sh`, `man/generate_html.1`
- Belege: `STAGE12C4Z_PROFESSIONAL_GENERATE_HTML.md`, `tests/test_generate_html_cli.py`, `tests/test_install_layout.py`, `scripts/check_install_layout.sh`

### TEST-FIXED-009 – Volltabellenvergleich hing im allgemeinen HTMLParser und konnte unseeded Python-Ausgaben nicht fachlich einordnen

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `full_table_parser_and_reference_reproducibility` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4z`
- Reproduktion: `scripts/check_full_all_against_reference.sh mit zwei ungefähr 25-MiB-HTML-Dateien ausführen; der allgemeine HTMLParser blieb in dieser Umgebung unzuverlässig hängen und der alte Vergleich behandelte reine Spaltenpermutationen einer unseeded Referenz als Inhaltsfehler.`
- heutiger Vertrag: Ein spezialisierter Streaming-Scanner bewahrt exakt die historische verschachtelte Tabellenform mit 198 Zeilen und 149356 Zellen. Referenzmetadaten tragen den Hashseed-Status; bei uncontrolled werden doppelte Überschriften vorkommensgenau ausgerichtet, bekannte Hashspalten transparent separat berichtet und alle stabilen Zellen müssen semantisch gleich sein.
- spätere Python-Aktion: Keine Python-Produktivcodeänderung erforderlich; die eigentliche Hashabhängigkeit bleibt separat unter PY-CAND-010 erfasst.
- Mojo-Orte: `scripts/compare_full_all_html.py`, `scripts/check_full_all_against_reference.sh`, `scripts/create_full_all_reference_bundle.sh`
- Belege: `STAGE12C4Z_PROFESSIONAL_GENERATE_HTML.md`, `tests/test_full_all_reference_workflow.py`, `scripts/compare_full_all_html.py`

### TEST-FIXED-010 – Ad-hoc-Sourcearchiv schloss nur die oberste Pytest-Cacheebene aus

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `nested_cache_source_archive_leak` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4z`
- Reproduktion: `Ein Sourcearchiv mit --exclude=reta_arch_mojo/.pytest_cache erzeugen, während python_reference/.pytest_cache existiert; die verschachtelten Cachedateien erscheinen weiterhin in tar -tjf.`
- heutiger Vertrag: Der feste Sourcearchivgenerator schließt .pytest_cache und __pycache__ auf jeder Baumtiefe sowie Buildbäume, Bytecode, middle.alx und die verbotene Prompt-Python-Bridge aus. Er prüft die fertige tar.bz2 selbst und veröffentlicht sie nur bei leerem Verbotsfund.
- spätere Python-Aktion: Keine Python-Produktivcodeänderung erforderlich.
- Mojo-Orte: `scripts/create_source_archive.sh`, `scripts/update_source_manifest.sh`
- Belege: `STAGE12C4Z_PROFESSIONAL_GENERATE_HTML.md`, `tests/test_source_archive_contract.py`, `scripts/create_source_archive.sh`

### TEST-FIXED-011 – Stage-12c4z-Runner verlangte gebaute Installationsartefakte auch im source-only Archiv

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `source_only_and_post_build_gate_conflation` / `low`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c4z`
- Reproduktion: `Das finale source-only Archiv entpacken und scripts/test_stage12c4z.sh ausführen; der erste Stand startete tests/test_install_layout.py trotz absichtlich fehlendem target/bin und meldete fünf falsche Fehler.`
- heutiger Vertrag: Reine Source-, Ledger-, Referenz- und Archivtests laufen ohne target-Verzeichnis. Funktionale Installations-, HTML- und I/O-Gates werden nur ausgeführt, wenn generate-html-native gebaut vorliegt; der Runner kennzeichnet das Überspringen ausdrücklich.
- spätere Python-Aktion: Keine Python-Produktivcodeänderung erforderlich.
- Mojo-Orte: `scripts/test_stage12c4z.sh`, `tests/test_install_layout.py`
- Belege: `STAGE12C4Z_PROFESSIONAL_GENERATE_HTML.md`, `scripts/test_stage12c4z.sh`

### TEST-FIXED-012 – Referenz- und Kompatibilitätsskripte bevorzugten die Mojo-.venv statt des historischen PyPy3

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `reference_interpreter_precedence_regression` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5b`
- Reproduktion: `In einem Checkout mit .venv/bin/python und installiertem pypy3 ein bisheriges Referenz- oder Paritätsskript starten; mehrere Skripte wählten zuerst .venv/bin/python und führten die langsame Python-Referenz dadurch unter CPython statt unter PyPy3 aus.`
- heutiger Vertrag: Alle Python-Referenz-, Paritäts- und atomaren Kompatibilitätspfade verwenden einen zentralen Selektor. Explizites RETA_REFERENCE_PYTHON beziehungsweise RETA_PYTHON gewinnt, danach pypy3, danach python3; die lokale Mojo-.venv ist nur noch der letzte Notfallfallback. Ungültige explizite Interpreter brechen sichtbar ab.
- spätere Python-Aktion: Keine Änderung am eingefrorenen Python-/PyPy3-Produktivcode erforderlich.
- Mojo-Orte: `scripts/select_reference_python.sh`, `scripts/create_full_all_reference_bundle.sh`, `bin/reta-mojo-compat`, `bin/reta-prompt-profile`
- Belege: `STAGE12C5B_NATIVE_PROMPT_LANGUAGE_PYPY3.md`, `tests/test_reference_python_selector.py`, `tests/test_prompt_language_ownership.py`, `FULL_ALL_REFERENCE_WORKFLOW.md`

### PY-CAND-011 – Manifestnormalisierung entfernt führende Punkte und kann Dotfile-Pfade kollidieren lassen

- Ursprung: `python_reference`
- Klasse / Schwere: `dotfile_manifest_path_collision` / `medium`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- entdeckt in: `12c5c`
- Reproduktion: `In einem temporären Manifestbaum sowohl .hidden als auch hidden mit verschiedenen Inhalten anlegen und RepoManifest.from_tree(root).snapshot(include_files=True) aufrufen; beide Pfade werden durch lstrip('./') als hidden geführt und _manifest_file_entry kann für beide die undotierte Datei lesen.`
- heutiger Vertrag: Der native Manifestbesitzer reproduziert die historische lstrip('./')-Normalisierung und den Dotfile-Fallback absichtlich, damit bestehende Python-Manifeste einschließlich der Kollision bytegleich bleiben. Der dynamische Paritätsbaum enthält .hidden und hidden mit verschiedenen Inhalten.
- spätere Python-Aktion: Nach Abschluss der funktionalen Portierung in Python nur ein tatsächliches Präfix './' entfernen, führende Punkte erhalten, Kollisionen mit einem neuen Solltest ausschließen und die daraus folgende Manifestdigest-Änderung kontrolliert versionieren.
- Python-Orte: `python_reference/reta_architecture/package_integrity.py:91-92`, `python_reference/reta_architecture/package_integrity.py:122-132`
- Mojo-Orte: `src/reta_mojo/package_integrity.mojo`, `tests/test_package_integrity.mojo`, `scripts/check_package_integrity_parity.py`
- Belege: `STAGE12C5C_NATIVE_PACKAGE_INTEGRITY_SPLIT_I18N.md`, `scripts/check_package_integrity_parity.py`, `tests/test_package_integrity.mojo`

### MOJO-FIXED-028 – Native Ziffernerkennung der Center-Fassade erkannte nur ASCII statt Python-isDigit

- Ursprung: `mojo_port`
- Klasse / Schwere: `unicode_digit_classification_gap` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5d`
- Reproduktion: `Python center.textHatZiffer('abc٢'), center.textHatZiffer('abc²') und center.textHatZiffer('abc⑵') mit dem bisherigen nativen arithmetic.has_digit vergleichen; Python liefert jeweils True, der alte Mojo-Helfer nur für ASCII-Ziffern.`
- heutiger Vertrag: Die zentrale native Arithmetik, die Center-Fassade und runtime_compat verwenden einen eingefrorenen, reproduzierbaren Python-str.isdigit-Vertrag mit 808 Codepoints in 83 Bereichen. ASCII-, arabisch-indische, hochgestellte und eingekreiste Ziffern werden wie Python erkannt; Nichtziffern wie das chinesische Zahlzeichen 四 bleiben false.
- spätere Python-Aktion: Keine Python-Änderung erforderlich. Bei einer späteren Aktualisierung der Python-Unicode-Datenbank den TSV-Snapshot bewusst regenerieren, die Vertragsänderung prüfen und Python sowie Mojo gemeinsam testen.
- Python-Orte: `python_reference/libs/center.py:311-313`, `python_reference/reta_architecture/arithmetic.py:140-145`
- Mojo-Orte: `src/reta_mojo/legacy_center.mojo`, `src/reta_mojo/unicode_digits.mojo`, `assets/unicode_digit_ranges.tsv`, `tools/generate_unicode_digits.py`, `src/reta_mojo/arithmetic.mojo`, `src/reta_mojo/runtime_compat.mojo`, `tests/test_runtime_compat_complete.mojo`
- Belege: `STAGE12C5D_NATIVE_LEGACY_FACADES.md`, `tests/test_legacy_center.mojo`, `tests/test_legacy_facades_source.py`, `scripts/check_legacy_facades_parity.py`, `STAGE12C5Q_UTF8_RENDERING_NATIVE_RUNTIME_COMPAT.md`

### TEST-FIXED-013 – Manuell fortgeschriebene Portierungsprozente überzählten den Matrixstatus

- Ursprung: `test_and_release_infrastructure`
- Klasse / Schwere: `non_reproducible_progress_metrics` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5e`
- Reproduktion: `Die in STATUS.md für Stage 12c5d genannten 82/92 mindestens teilweise portierten Dateien mit den tatsächlichen Statuszeilen der frisch entpackten Stage-12c5d-PORTING_MATRIX.md vergleichen; die Matrix enthält 71/92 explizit zugeordnete Dateien.`
- heutiger Vertrag: Portierungszahlen werden aus allen 92 Referenzdateien und der autoritativen NATIVE-Zuordnung berechnet. Vollständig, mindestens teilweise und gewichtete Referenzzeilen sind getrennte maschinenlesbare Größen; Stage 12c5e steht bei 51/92, 73/92 und 33.198/48.831 Zeilen.
- spätere Python-Aktion: Keine Python-Fachlogikänderung. Künftige Statusdokumente müssen tools/porting_metrics.py verwenden und dürfen Prozentwerte nicht manuell inkrementieren.
- Mojo-Orte: `tools/porting_metrics.py`, `tools/generate_porting_matrix.py`, `tests/test_porting_metrics.py`
- Belege: `STAGE12C5E_NATIVE_CONCAT_CSV.md`, `tools/porting_metrics.py`, `tests/test_porting_metrics.py`

### TEST-FIXED-014 – Parametersemantik-Regressionswerte blieben nach Katalogerweiterung auf 554 statt 556 stehen

- Ursprung: `python_reference_tests`
- Klasse / Schwere: `stale_parameter_semantics_snapshot` / `medium`
- Python-Status: `fixed`
- Mojo-Status: `fixed`
- entdeckt in: `12c5f`
- Reproduktion: `RetaArchitecture.bootstrap(use_cache=False).bootstrap_prompt_runtime(...).program erzeugen und len(AllSimpleCommandSpalten) sowie len(dataDict[0]) mit den bisherigen Assertions in python_reference/tests/test_architecture_refactor.py vergleichen; Istwert 556, alter Sollwert 554.`
- heutiger Vertrag: Der aktuelle 431-Familien-Katalog erzeugt im Python- und Mojo-Normalmodus 556 einfache Spalten und 556 Schlüssel im ersten Datenslot. Zwei vollständige inhaltsabhängige Fingerabdrücke sichern Normal- und Inversionsmodus zusätzlich ab.
- spätere Python-Aktion: Erledigt: ausschließlich die drei veralteten Python-Test-Sollwerte wurden von 554 auf 556 aktualisiert; historische Berichtsdokumente bleiben als Zeitaufnahmen unverändert.
- Python-Orte: `python_reference/tests/test_architecture_refactor.py:163`, `python_reference/tests/test_architecture_refactor.py:982`, `python_reference/tests/test_architecture_refactor.py:986`
- Mojo-Orte: `src/reta_mojo/semantics_builder.mojo`, `src/reta_mojo/semantics_builder_catalog.mojo`, `assets/parameter_semantics_reference.json`
- Belege: `STAGE12C5F_NATIVE_PARAMETER_SEMANTICS.md`, `assets/parameter_semantics_reference.json`, `scripts/check_semantics_builder_parity.py`, `tests/test_semantics_builder_source.py`

### TEST-FIXED-015 – Semantikkatalog und Vollfingerabdruck wechselten mit PYTHONHASHSEED

- Ursprung: `generator_tests`
- Klasse / Schwere: `hash_order_dependent_generated_asset` / `high`
- Python-Status: `fixed`
- Mojo-Status: `fixed`
- entdeckt in: `12c5f`
- Reproduktion: `tools/generate_semantics_builder_catalog.py unter PYTHONHASHSEED=0 und PYTHONHASHSEED=1 ausführen und semantics_builder_catalog.mojo sowie parameter_semantics_reference.json vergleichen; die vier set-basierten Parameternamengruppen und set-basierten Datensätze erzeugten zuvor unterschiedliche Reihenfolgen und Fingerabdrücke.`
- heutiger Vertrag: Nur semantisch ungeordnete set/frozenset-Container werden vor der Katalogerzeugung stabil typ- und wertgeordnet; Listen und Tupel behalten ihre Fachreihenfolge. Generatorausgabe und beide Vollfingerabdrücke sind unter verschiedenen Python-Hash-Seeds byteidentisch.
- spätere Python-Aktion: Erledigt: StableSet und normalized_schema kanonisieren ungeordnete Eingaben reproduzierbar; das Stage-Gate regeneriert beide Assets und vergleicht sie bytegenau.
- Python-Orte: `tools/generate_semantics_builder_catalog.py`, `python_reference/i18n/words_matrix.py`
- Mojo-Orte: `src/reta_mojo/semantics_builder_catalog.mojo`, `assets/parameter_semantics_reference.json`
- Belege: `STAGE12C5F_NATIVE_PARAMETER_SEMANTICS.md`, `tools/generate_semantics_builder_catalog.py`, `tests/test_semantics_builder_source.py`, `scripts/check_semantics_builder.sh`

### TEST-FIXED-016 – middle.alx-Parität war unnötig an physische Spalten- und Containerreihenfolge gekoppelt

- Ursprung: `generator_tests`
- Klasse / Schwere: `order_sensitive_reference_comparison` / `medium`
- Python-Status: `fixed`
- Mojo-Status: `fixed`
- entdeckt in: `12c5g`
- Reproduktion: `Zwei inhaltlich identische table#bigtable-Ausgaben mit vertauschten vollständigen Spalten und entsprechend geänderten r_<n>-Klassen byteweise vergleichen; ein Bytevergleich meldet fälschlich eine Abweichung, obwohl jede vollständige Spalte denselben Inhalt und dieselben semantischen Metadaten besitzt.`
- heutiger Vertrag: Große HTML-Referenzen werden als Multiset vollständiger Spaltenvektoren verglichen. Physische r_/z_-Position, Attributreihenfolge und Klassentokenreihenfolge sind irrelevant; Zeilenfolge, Zellinhalt, sonstige Attribute und verschachteltes Markup bleiben vollständig prüfwirksam. Mengenartige Kombi-Relationen werden analog kanonisch statt über OrderedDict-Iteration verglichen.
- spätere Python-Aktion: Erledigt: BigTableParser trennt direkte Tabellenzeilen von verschachtelten Tabellen, hasht komplette Spaltenvektoren und vergleicht deren Multiset. Synthetische Tests beweisen sowohl akzeptierte Spaltenpermutation als auch erkannte Inhaltsänderung.
- Python-Orte: `tools/compare_middle_alx.py`, `tests/test_middle_alx_compare.py`
- Mojo-Orte: `src/reta_mojo/combi_join.mojo`, `tests/probe_combi_join.mojo`
- Belege: `STAGE12C5G_NATIVE_KOMBI_JOIN_UNORDERED_PARITY.md`, `tools/compare_middle_alx.py`, `tests/test_middle_alx_compare.py`, `scripts/check_combi_join_parity.sh`

### TEST-FIXED-017 – Container- und Nutzlastprüfsummen wurden bei middle.alx verwechselt

- Ursprung: `generator_tests`
- Klasse / Schwere: `artifact_container_payload_confusion` / `medium`
- Python-Status: `fixed`
- Mojo-Status: `fixed`
- entdeckt in: `12c5h`
- Reproduktion: `Die MD5-Summen von direktem HTML middle_arch_pypy3.alx und dem als .alx benannten Tar middle_python3_arch.alx vergleichen; die äußeren Digests unterscheiden sich, obwohl das einzige Tar-Mitglied byteidentisch mit der HTML-Datei ist.`
- heutiger Vertrag: Der Vergleich weist Containerart, Containergröße und Containerdigest getrennt von Größe und Digest der tatsächlich verglichenen HTML-Nutzlast aus. Eine unterschiedliche Archivhülle gilt weder als Inhaltsabweichung noch als Beweis für verschiedene Python-Laufzeitausgaben.
- spätere Python-Aktion: Erledigt: load_html erfasst für rohe HTML- und Tar-Eingaben getrennte Container- und Payload-Metadaten; ein Regressionstest verpackt identisches HTML in Tar und verlangt verschiedene Container-MD5 bei identischer Payload-MD5 und struktureller Gleichheit.
- Python-Orte: `tools/compare_middle_alx.py`, `tests/test_middle_alx_compare.py`
- Mojo-Orte: `src/reta_mojo/architecture_exports.mojo`, `scripts/install_targets.txt`
- Belege: `STAGE12C5H_NATIVE_PACKAGE_EXPORTS_INSTALL_MANIFEST.md`, `tools/compare_middle_alx.py`, `tests/test_middle_alx_compare.py`, `scripts/test_stage12c5h.sh`

### MOJO-FIXED-029 – Exportfilter kopierte einen nicht implizit kopierbaren lokalen Spec ohne Besitzübertragung

- Ursprung: `mojo_port`
- Klasse / Schwere: `explicit_copy_lvalue_not_transferred` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5j`
- Reproduktion: `scripts/build-heavy.sh; scripts/build.sh unter Mojo 1.0.0b2 ausführen; der Build von architecture_exports_main.mojo bricht bei result.append(entry) ab, weil ArchitectureExportSpec nicht ImplicitlyCopyable ist.`
- heutiger Vertrag: Der Modulfilter erzeugt genau eine explizite lokale Kopie des Katalogeintrags und überträgt diese nach der letzten Verwendung mit entry^ in die Ergebnisliste. Eine zweite Kopie und eine implizite lvalue-Kopie sind ausgeschlossen.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; der Befund betrifft ausschließlich die Mojo-Ownership-Semantik.
- Mojo-Orte: `src/reta_mojo/architecture_exports.mojo:94-98`, `tests/test_architecture_facade_source.py`
- Belege: `STAGE12C5J_NATIVE_ARCHITECTURE_FACADE.md`, `tests/test_architecture_facade_source.py`, `src/reta_mojo/architecture_exports.mojo`

### MOJO-FIXED-030 – Stage-12c5e reichte den Mojo-Resolver als MOJO_BIN an denselben Resolver zurück

- Ursprung: `mojo_port`
- Klasse / Schwere: `self_referential_compiler_resolver_environment` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5l`
- Reproduktion: `scripts/test_stage12c5e.sh ausführen, während der offizielle Compiler nur unter .venv/bin/mojo liegt; nach den beiden erfolgreichen Mojo-Tests meldet build_concat_csv_probe.sh fälschlich, bin/mojo-real sei kein Modular-Compiler.`
- heutiger Vertrag: Verschachtelte Projektwerkzeuge erben ein explizit vom Benutzer gesetztes echtes MOJO_BIN unverändert. Der Standardresolver wird dagegen nicht mehr als MOJO_BIN an sich selbst weitergereicht; trifft ein selbstreferenzieller Wert dennoch ein, entfernt bin/mojo-real ihn und setzt die normale Suche in .venv, Pixi, VIRTUAL_ENV und PATH fort.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; der Fehler lag ausschließlich in der POSIX-Compilerauflösung des Mojo-Projekts.
- Mojo-Orte: `scripts/test_stage12c5e.sh`, `scripts/build_concat_csv_probe.sh`, `bin/mojo-real`
- Belege: `tests/test_mojo_resolver_source.py`, `scripts/test_stage12c5e.sh`, `bin/mojo-real`

### MOJO-FIXED-031 – Religion-JSON-Parser indexierte UTF-8-Strings an beliebigen Bytepositionen

- Ursprung: `mojo_port`
- Klasse / Schwere: `utf8_codepoint_boundary_violation` / `critical`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5l`
- Reproduktion: `scripts/test_stage12c5k.sh mit religion.csv ausführen; decode_religion_cell erreicht koreanische oder chinesische Nutzlast und bricht in parallel_execution.mojo mit Assert Error: String slice index does not lie on a codepoint boundary ab.`
- heutiger Vertrag: Der Parser sucht JSON-Syntax ausschließlich in json.as_bytes(). StringSlice wird nur zwischen ASCII-Anführungszeichen oder Escape-Markern erzeugt, die sicher auf UTF-8-Codepointgrenzen liegen. Direkte koreanische, chinesische und vietnamesische Werte sowie ASCII-Escapes bleiben unverändert.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; Python-Strings besitzen die fehlerhafte Mojo-Byteindexgrenze nicht.
- Mojo-Orte: `src/reta_mojo/parallel_execution.mojo:598-664`, `tests/test_program_workflow.mojo`, `scripts/check_program_workflow_parity.py`
- Belege: `src/reta_mojo/parallel_execution.mojo`, `tests/test_program_workflow.mojo`, `scripts/check_program_workflow_parity.py`

### PY-CAND-012 – generate4readme ändert vier Bruchparameterlisten mit PYTHONHASHSEED

- Ursprung: `python_reference`
- Klasse / Schwere: `hash_order_dependent_documentation_output` / `medium`
- Python-Status: `candidate`
- Mojo-Status: `fixed`
- entdeckt in: `12c5l`
- Reproduktion: `python_reference/libs/generate4readme.py jeweils mit PYTHONHASHSEED=0 und PYTHONHASHSEED=1 ausführen; die Werte von gebrochengalaxie, gebrochenuniversum, gebrochenemotion und gebrochengroesse erscheinen in unterschiedlicher Reihenfolge.`
- heutiger Vertrag: Die native Ausgabe verwendet vollständige, unter PYTHONHASHSEED=0 erzeugte deutsche und englische Referenzassets. Dadurch ist generate4readme reproduzierbar und für denselben kanonischen Seed byteidentisch, ohne die fachlich sichtbare Reihenfolge nachträglich zu erfinden.
- spätere Python-Aktion: Nach Abschluss der Portierung die vier set-basierten Werte im Python-i18n-Katalog in eine explizit geordnete Struktur überführen oder beim Dokumentgenerator kanonisch sortieren; anschließend den gewählten Sollvertrag versionieren und den Kandidaten auf fixed setzen.
- Python-Orte: `python_reference/libs/generate4readme.py`, `python_reference/i18n/words_matrix.py`
- Mojo-Orte: `src/reta_mojo/readme_generator.mojo`, `assets/generated_readme_german.md`, `assets/generated_readme_english.md`, `tools/generate_readme_assets.py`
- Belege: `tests/test_readme_generator_source.py`, `tools/generate_readme_assets.py`, `assets/generated_readme_manifest.tsv`

### MOJO-FIXED-032 – ProgramWorkflow ließ bei mehreren Ausgabearten die Argumentreihenfolge statt der Referenzpriorität entscheiden

- Ursprung: `mojo_port`
- Klasse / Schwere: `output_mode_precedence_mismatch` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5m`
- Reproduktion: `scripts/test_stage12c5k.sh ausführen; der Paritätstest erwartet für [--art=html, --art=bbcode] gemäß Python bbcode, während Mojo html ausgab.`
- heutiger Vertrag: Die vollständige Argumentliste wird zuerst auf den BBCode-Wert und erst danach auf HTML geprüft. Sobald beide Werte vorkommen, gewinnt BBCode unabhängig von ihrer physischen Reihenfolge, exakt wie in der Python-Referenz.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; die Python-Referenz besaß bereits den festgelegten Prioritätsvertrag.
- Python-Orte: `python_reference/reta_architecture/program_workflow.py:49-55`
- Mojo-Orte: `src/reta_mojo/program_workflow.mojo`, `tests/test_program_workflow.mojo`, `scripts/check_program_workflow_parity.py`
- Belege: `STAGE12C5M_NATIVE_DOMAIN_PROBE_TEST_ENVIRONMENT.md`, `tests/test_program_workflow.mojo`, `scripts/check_program_workflow_parity.py`

### TEST-FIXED-018 – Mojo-Compilerumgebung enthielt nicht automatisch die Python-Testabhängigkeit pytest

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `missing_test_environment_dependency` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5m`
- Reproduktion: `Nach erfolgreichem Mojo-Test scripts/test_stage12c5k.sh in einer aktivierten .venv ohne pytest ausführen; .venv/bin/python3 bricht bei python3 -m pytest mit No module named pytest ab.`
- heutiger Vertrag: Die Projekt-.venv enthält neben dem Modular-Mojo-Compiler auch die Python-Testabhängigkeiten. Stage-Skripte wählen nur einen Interpreter, der pytest importieren kann, und liefern andernfalls einen ausführbaren Installationsbefehl.
- spätere Python-Aktion: Keine Python-Referenzänderung erforderlich; dies betrifft ausschließlich die Entwicklungs- und Testumgebung des Mojo-Ports.
- Mojo-Orte: `scripts/setup_mojo.sh`, `scripts/setup_test_dependencies.sh`, `scripts/find_test_python.sh`, `requirements-test.txt`
- Belege: `STAGE12C5M_NATIVE_DOMAIN_PROBE_TEST_ENVIRONMENT.md`, `tests/test_test_python_setup.py`, `scripts/setup_test_dependencies.sh`, `scripts/find_test_python.sh`

### MOJO-FIXED-033 – CSV-Parser entfernte JSON-Anführungszeichen aus unquoted Religion-Zellen

- Ursprung: `mojo_port`
- Klasse / Schwere: `csv_quote_state_mismatch` / `critical`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5n`
- Reproduktion: `scripts/test_stage12c5k.sh mit tests/fixtures/program_workflow_root/csv/religion.csv ausführen; die Zelle |{"":"plain",...}| wird zu |{:plain,...}| verstümmelt und decode_religion_cell meldet missing religion cell JSON key.`
- heutiger Vertrag: Ein doppeltes Anführungszeichen eröffnet CSV-Quoting ausschließlich als erstes Byte eines Feldes. Quotes mitten in einem unquoted Feld sind Nutzdaten; echte quoted Felder, verdoppelte Quotes, Semikolons und Zeilenumbrüche bleiben unterstützt.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; Python csv.reader besaß bereits den korrekten Feldanfangsvertrag.
- Python-Orte: `python_reference/reta_architecture/program_workflow.py`, `Python csv.reader(delimiter=';')`
- Mojo-Orte: `src/reta_mojo/csv_table.mojo`, `tests/test_csv_table.mojo`, `tests/test_program_workflow.mojo`
- Belege: `STAGE12C5N_NATIVE_HTML_CLASS_EXTRACTION.md`, `tests/test_csv_table.mojo`, `tests/test_program_workflow.mojo`

### TEST-FIXED-019 – Defekttest verlangte dauerhaft das alte prompt_toolkit-Unicode-Fehlverhalten

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `upstream_version_sensitive_defect_reproducer` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5n`
- Reproduktion: `scripts/test_stage12c5e.sh oder scripts/test_stage12c5j.sh mit einer aktuellen prompt_toolkit-Version ausführen; word_before_cursor('grö') liefert korrekt 'grö', der Test erwartet jedoch zwingend das historische 'ö'.`
- heutiger Vertrag: Der Reproducer erkennt sowohl das historische fehlerhafte als auch das neuere upstream korrigierte Python-Verhalten. Er prüft weiterhin, dass PY-CAND-007 dokumentiert ist, macht den Testlauf aber nicht von einer bestimmten Fremdbibliotheksversion abhängig.
- spätere Python-Aktion: Keine unmittelbare Python-Referenzänderung; nach Festlegung einer prompt_toolkit-Mindestversion wird PY-CAND-007 mit einem einheitlichen Unicode-Sollvertrag abgeschlossen.
- Python-Orte: `python_reference/reta_architecture/completion_word.py`, `tests/test_documented_python_defects.py`
- Mojo-Orte: `tests/test_documented_python_defects.py`, `src/reta_mojo/completion_word.mojo`
- Belege: `STAGE12C5N_NATIVE_HTML_CLASS_EXTRACTION.md`, `tests/test_documented_python_defects.py`

### PY-CAND-013 – Meta-Bruchkombination stern/div vergisst die Rückskalierung nach dem Runden

- Ursprung: `python_reference`
- Klasse / Schwere: `fraction_relation_rounding_candidate` / `medium`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- entdeckt in: `12c5o`
- Reproduktion: `PYTHONHASHSEED=0 python3 scripts/generate_meta_columns_catalog.py ausführen und assets/meta_columns_catalog.tsv auswerten; für UniUni, UniGal, GalUni und GalGal enthält stern/div jeweils 0 Paare, obwohl mathematisch ganzzahlige Quotienten existieren.`
- heutiger Vertrag: Der native Katalog konserviert unter PYTHONHASHSEED=0 exakt den beobachtbaren Python-Istzustand einschließlich vier leerer stern/div-Gruppen. Die übrigen 884 Kombinationseinträge und ihre Reihenfolge bleiben bytegenau reproduzierbar.
- spätere Python-Aktion: Nach Abschluss der Portierung fachlich entscheiden, ob die rechte Seite wie bei stern/mul durch 1000 geteilt werden muss. Bei Bestätigung die Python-Bedingung korrigieren, neue Paarfixtures erzeugen und Python sowie Mojo gemeinsam auf den neuen Relationsvertrag migrieren.
- Python-Orte: `python_reference/reta_architecture/meta_columns.py:694-699`
- Mojo-Orte: `assets/meta_columns_catalog.tsv`, `src/reta_mojo/meta_columns.mojo`, `scripts/generate_meta_columns_catalog.py`
- Belege: `STAGE12C5O_NATIVE_META_COLUMNS.md`, `tests/test_meta_columns_complete_source.py`, `assets/meta_columns_catalog.tsv`

### TEST-FIXED-020 – Ältere Stage-Skripte umgingen den pytest-fähigen Projektinterpreter

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `inconsistent_pytest_interpreter_resolution` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5p`
- Reproduktion: `pytest in .venv installieren und scripts/test_stage12c5j.sh ausführen; die Mojo-Tests bestehen, danach scheitert /usr/bin/python3 -m pytest mit No module named pytest.`
- heutiger Vertrag: Alle Shellskripte starten Pytest ausschließlich über scripts/run_pytest.sh. Dieser wählt mit find_test_python.sh zuerst RETA_TEST_PYTHON und danach die pytest-fähige Projekt-.venv, bevor System-python3 oder pypy3 berücksichtigt werden. Direkte python3 -m pytest-Aufrufe sind im Skriptbaum ausgeschlossen.
- spätere Python-Aktion: Keine Python-Referenzänderung erforderlich; der Fehler betraf ausschließlich die Interpreterwahl der Mojo-Testinfrastruktur.
- Mojo-Orte: `scripts/run_pytest.sh`, `scripts/find_test_python.sh`, `scripts/test_stage12c5j.sh`, `scripts/test_stage12c.sh`, `scripts/check_compat_launcher.sh`
- Belege: `STAGE12C5P_NATIVE_MORPHISMS_PYTEST_RESOLVER.md`, `tests/test_test_python_setup.py`, `scripts/run_pytest.sh`, `scripts/test_stage12c5j.sh`

### MOJO-FIXED-034 – RendererMorphisms verwendete terminal statt des Python-Fallbacks shell

- Ursprung: `mojo_port`
- Klasse / Schwere: `renderer_default_mode_mismatch` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5p`
- Reproduktion: `bootstrap_morphisms mit Standardwert erzeugen und renderer_morphisms.canonical_output_mode("unknown") aufrufen; der partielle Mojo-Port lieferte terminal, während RetaOutputSemantics.mode_for_tables bei unbekannter Syntax shell verwendet.`
- heutiger Vertrag: Der native Morphismen-Bootstrap und der kanonische Unknown-Mode-Fallback verwenden shell. Konkrete gültige Modi werden weiterhin über output_modes.mojo kanonisiert und auf OutputRuntimeState angewendet.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; die Python-Referenz besaß bereits den festgelegten shell-Fallback.
- Python-Orte: `python_reference/reta_architecture/output_semantics.py:76-79`, `python_reference/reta_architecture/morphisms.py:58-59`
- Mojo-Orte: `src/reta_mojo/morphisms.mojo`, `tests/test_morphisms.mojo`, `tests/test_morphisms_complete.mojo`
- Belege: `STAGE12C5P_NATIVE_MORPHISMS_PYTEST_RESOLVER.md`, `src/reta_mojo/morphisms.mojo`, `tests/test_morphisms.mojo`

### MOJO-FIXED-035 – HTML-Wortumbruch entfernte Unicode-Präfixe mit Codepointlängen als Byteoffsets

- Ursprung: `mojo_port`
- Klasse / Schwere: `utf8_prefix_byte_slice_boundary` / `critical`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5q`
- Reproduktion: `bin/reta -zeilen --vorhervonausschnitt=1 -spalten --alles -ausgabe --art=html ausführen; ein langes Wort mit Mehrbytezeichen wird nach rekonstruiertem Präfix über einen rohen Byte-Slice gekürzt und der Modular-Runtime-Assert meldet String slice starts on 17 which is not a codepoint boundary.`
- heutiger Vertrag: Alle Renderer-Wortzerleger iterieren Codepoints. Rekonstruierte Präfixe werden mit removeprefix entfernt; No-Progress-Fallbacks zerlegen über hard_chunks. Umlaute, CJK-Zeichen und Emoji können keine ungültige UTF-8-Stringgrenze mehr erzeugen.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; Python textwrap besaß bereits eine Unicode-sichere Zeichenfolgenlogik.
- Python-Orte: `python_reference/reta_architecture/table_output.py`, `Python textwrap.TextWrapper`
- Mojo-Orte: `src/reta_mojo/table_rendering.mojo`, `tests/test_native_reta_utf8_html.mojo`, `tests/test_table_rendering.mojo`
- Belege: `STAGE12C5Q_UTF8_RENDERING_NATIVE_RUNTIME_COMPAT.md`, `tests/test_native_reta_utf8_html.mojo`, `tests/test_utf8_rendering_source.py`

### MOJO-FIXED-036 – HTML-Klassenextraktor enthielt eine wirkungslose pending_space-Zuweisung

- Ursprung: `mojo_port`
- Klasse / Schwere: `unused_state_assignment_warning` / `low`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5q`
- Reproduktion: `scripts/build.sh ausführen; Modular meldet in html_class_extractor.mojo assignment to pending_space was never used, weil False unmittelbar vor einer zustandsbestimmenden Neuzuweisung gesetzt wurde.`
- heutiger Vertrag: Der Collapse-Zustandsautomat schreibt pending_space nur noch an beobachtbaren Übergängen. Die überflüssige Zwischenzuweisung und damit die Compilerwarnung sind entfernt.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; es handelte sich um reine Mojo-Codehygiene.
- Mojo-Orte: `src/reta_mojo/html_class_extractor.mojo`, `tests/test_utf8_rendering_source.py`
- Belege: `STAGE12C5Q_UTF8_RENDERING_NATIVE_RUNTIME_COMPAT.md`, `tests/test_utf8_rendering_source.py`

### MOJO-FIXED-037 – MorphismBundle übertrug Besitz aus einer unveränderlichen ContextSelection-Referenz

- Ursprung: `mojo_port`
- Klasse / Schwere: `immutable_reference_transfer` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5r`
- Reproduktion: `scripts/test_stage12c5p.sh ausführen; Modular bricht beim Parsen von morphisms.mojo mit cannot transfer out of immutable reference an RendererMorphisms(topology_context^, default_output_mode) ab.`
- heutiger Vertrag: ContextSelection ist Copyable. Alle vier Teilmorphismen erhalten aus dem unveränderlichen Eingabeparameter eine explizite Kopie; kein Konstruktor versucht mehr, Besitz mit ^ aus einer immutable Referenz zu entnehmen.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; die Python-Referenz teilt den Kontext ohne Ownership-Verstoß. Die Reparatur betrifft ausschließlich die korrekte Mojo-Besitzsemantik.
- Python-Orte: `python_reference/reta_architecture/morphisms.py:68-78`
- Mojo-Orte: `src/reta_mojo/morphisms.mojo`, `tests/test_morphisms.mojo`, `tests/test_morphisms_complete.mojo`, `tests/test_morphisms_complete_source.py`
- Belege: `STAGE12C5R_NATIVE_TABLE_WRAPPING_MORPHISM_OWNERSHIP.md`, `src/reta_mojo/morphisms.mojo`, `tests/test_morphisms_complete_source.py`

### TEST-FIXED-021 – Source-only Aktualisierung startete unbemerkt ein altes target-Binary

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `stale_binary_after_source_update` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5s`
- Reproduktion: `Ein neues source-only Archiv über einen bestehenden Arbeitsbaum entpacken und anschließend bin/reta-native ohne erneuten scripts/build.sh-Aufruf starten; der Launcher bevorzugt das alte target/bin/reta-native und reproduziert bereits behobene Fehler.`
- heutiger Vertrag: Jedes regulär oder schwer gebaute Mojo-Binary erhält eine Source-ID-Sidecard. Der zentrale Runtime-Launcher vergleicht sie mit SOURCE_MANIFEST.sha256 und prüft zusätzlich, ob src-Dateien neuer als das Binary sind. Veraltete oder unmarkierte target-Binaries werden mit einer eindeutigen Neubau-Anweisung abgewiesen.
- spätere Python-Aktion: Keine Python-Referenzänderung erforderlich; der Befund betrifft ausschließlich inkrementelle Source-only-Updates und lokale Mojo-Buildartefakte.
- Mojo-Orte: `bin/mojo-runtime-exec`, `scripts/current_source_id.sh`, `scripts/stamp_mojo_binary.sh`, `scripts/check_mojo_binary_freshness.sh`, `scripts/build.sh`, `scripts/build-heavy.sh`
- Belege: `STAGE12C5S_STALE_BINARY_UTF8_TABLE_HANDLING.md`, `tests/test_stage12c5s_source.py`, `scripts/check_mojo_binary_freshness.sh`

### MOJO-FIXED-038 – HTML-Escaper behielt einen rohen byteindizierten String-Slice

- Ursprung: `mojo_port`
- Klasse / Schwere: `utf8_html_escape_byte_slice_boundary` / `critical`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5s`
- Reproduktion: `bin/reta-native -zeilen --vorhervonausschnitt=1 -spalten --alles -ausgabe --art=html oder die entsprechende --zeilen --alles-Variante ausführen; ein HTML-Zellpfad kann String slice starts on 17/20 which is not a codepoint boundary auslösen.`
- heutiger Vertrag: HTML-Escaping und HTML-Teilspannrekonstruktion iterieren ausschließlich über codepoint_slices. Selbst versehentlich nicht ausgerichtete Bytepositionen werden auf vollständige Codepoints erweitert, statt einen Modular-Runtime-Assert oder illegal instruction auszulösen.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; Python-Strings und html.escape arbeiten bereits Unicode-sicher.
- Python-Orte: `python_reference/reta_architecture/table_output.py`
- Mojo-Orte: `src/reta_mojo/table_rendering.mojo`, `tests/test_native_reta_utf8_html.mojo`, `tests/test_stage12c5s_source.py`
- Belege: `STAGE12C5S_STALE_BINARY_UTF8_TABLE_HANDLING.md`, `src/reta_mojo/table_rendering.mojo`, `tests/test_stage12c5s_source.py`

### MOJO-FIXED-039 – OutputModeSpec deklarierte Writable ohne write_to-Vertrag

- Ursprung: `mojo_port`
- Klasse / Schwere: `invalid_protocol_conformance` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5v`
- Reproduktion: `Den neuen output_modes.mojo-Besitzer statisch oder mit scripts/test_stage12c5v.sh prüfen; OutputModeSpec führte Writable in der Traitliste, implementierte aber keine write_to-Methode.`
- heutiger Vertrag: OutputModeSpec ist Copyable und Equatable, beansprucht aber keinen nicht implementierten Writer-Vertrag. Diagnoseausgaben serialisieren die einzelnen typisierten Felder explizit.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; Dataclasses benötigen keinen Mojo-Writer-Protocolvertrag.
- Python-Orte: `python_reference/reta_architecture/output_semantics.py`
- Mojo-Orte: `src/reta_mojo/output_modes.mojo`, `tests/test_output_syntax_complete_source.py`
- Belege: `STAGE12C5V_NATIVE_OUTPUT_SEMANTICS_SYNTAX.md`, `src/reta_mojo/output_modes.mojo`, `tests/test_output_syntax_complete_source.py`

### TEST-FIXED-022 – Source-Suite verlangte ein nicht mitgeliefertes Probe-Binary und veraltete Interpreterdetails

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `source_archive_test_assumption` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5v`
- Reproduktion: `python3 -m pytest -q über alle test_*source.py-Dateien in einem frischen source-only Archiv ausführen; concat_csv erwartete target/tests/concat_csv_probe, während zwei Prompttests die vor der Resolverzentralisierung verwendeten .venv- beziehungsweise RETA_PYTHON-Textfragmente verlangten.`
- heutiger Vertrag: Source-only Prüfungen überspringen ausschließlich die echte compilerabhängige Concat-Parität, wenn ihr Probe-Binary fehlt. Prompttests prüfen die zentrale Interpreterauflösung semantisch statt eine überholte Implementierungsform. Der gesamte Source-Testbestand besteht mit 128 Tests und einem begründeten Skip.
- spätere Python-Aktion: Keine Python-Referenzänderung erforderlich; die Reparatur betrifft ausschließlich portable Tests und die bereits zentralisierte Interpreterwahl.
- Mojo-Orte: `tests/test_concat_csv_source.py`, `tests/test_prompt_external_source.py`, `tests/test_prompt_preparation_source.py`, `scripts/select_reference_python.sh`
- Belege: `STAGE12C5V_NATIVE_OUTPUT_SEMANTICS_SYNTAX.md`, `tests/test_concat_csv_source.py`, `tests/test_prompt_external_source.py`, `tests/test_prompt_preparation_source.py`

### MOJO-FIXED-040 – Reserviertes alias-Schlüsselwort wurde als Schleifenvariable verwendet

- Ursprung: `mojo_port`
- Klasse / Schwere: `reserved_keyword_identifier` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5w`
- Reproduktion: `scripts/build.sh ausführen; beim Import von output_modes.mojo bricht Modular an for alias in spec.aliases mit unexpected token in expression ab.`
- heutiger Vertrag: Aliaslisten werden mit alias_index indexiert. Kein lokaler Bezeichner verwendet das reservierte Mojo-Deklarationsschlüsselwort alias; der Stage-Test kompiliert zusätzlich den vollständigen src/main.mojo-Importgraphen.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; alias ist dort ein gewöhnlicher lokaler Name, während Mojo es als Sprachschlüsselwort reserviert.
- Python-Orte: `python_reference/reta_architecture/output_semantics.py`
- Mojo-Orte: `src/reta_mojo/output_modes.mojo`, `tests/test_input_semantics_complete_source.py`, `scripts/test_stage12c5w.sh`
- Belege: `STAGE12C5W_COMPILER_INPUT_SEMANTICS.md`, `src/reta_mojo/output_modes.mojo`, `scripts/test_stage12c5w.sh`

### TEST-FIXED-023 – Input-Semantik-Katalog hing vom zufälligen Python-Hashseed ab

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `nondeterministic_generated_catalog` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5w`
- Reproduktion: `tools/generate_input_semantics_catalog.py zweimal in getrennten Python-Prozessen ohne festes PYTHONHASHSEED ausführen; die aus Set-Iteration stammende haupt_for_neben-Reihenfolge kann unterschiedliche SHA-256-Summen erzeugen.`
- heutiger Vertrag: Der Generator re-execiert sich mit PYTHONHASHSEED=0, bevor die Referenz importiert wird. Wiederholte Erzeugung ist byteidentisch; Listenreihenfolge und Duplikate bleiben Referenzsemantik, Setfelder werden zusätzlich sortiert.
- spätere Python-Aktion: Die Python-Produktionssemantik bleibt unverändert. Nur die reproduzierbare Build-Artefakterzeugung wird auf den bereits projektweit kanonischen Hashseed festgelegt.
- Python-Orte: `python_reference/reta_architecture/input_semantics.py`
- Mojo-Orte: `tools/generate_input_semantics_catalog.py`, `assets/input_semantics_catalog.tsv`, `tests/test_input_semantics_complete_source.py`
- Belege: `STAGE12C5W_COMPILER_INPUT_SEMANTICS.md`, `tools/generate_input_semantics_catalog.py`, `tests/test_input_semantics_complete_source.py`

### TEST-FIXED-024 – Portable Source-Suite startete ein fremd gebautes Probe-Binary ohne verfügbare Mojo-Laufzeit

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `unrunnable_compiled_fixture_in_source_test` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5w`
- Reproduktion: `Alle test_*source.py in einem Arbeitsbaum ausführen, der zwar target/tests/concat_csv_probe aus einem anderen Rechner enthält, dessen absolute Modular-Laufzeitsymlinks aber nicht verfügbar sind; der Test startet das ELF allein aufgrund seiner Existenz und scheitert mit libKGENCompilerRTShared.so not found.`
- heutiger Vertrag: Die Source-Suite führt die compilerabhängige Parität nur aus, wenn sowohl das Probe-Binary als auch eine vollständige lokale Mojo-Laufzeit verfügbar sind. Der Paritätsrunner setzt den ermittelten Laufzeitpfad explizit in LD_LIBRARY_PATH; fremde oder unvollständige Buildartefakte führen zu einem begründeten Skip statt zu einem falschen Source-Fehler.
- spätere Python-Aktion: Keine Python-Referenzänderung erforderlich; die Reparatur trennt portable Quellprüfung von lokal ausführbaren Compilerartefakten.
- Mojo-Orte: `tests/test_concat_csv_source.py`, `scripts/check_concat_csv_parity.py`, `scripts/find_mojo_runtime.sh`
- Belege: `STAGE12C5W_COMPILER_INPUT_SEMANTICS.md`, `tests/test_concat_csv_source.py`, `scripts/check_concat_csv_parity.py`

### TEST-FIXED-025 – Installierte Mojo-Launcher verloren den von mojo-runtime-exec benötigten Frischeprüfer

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `missing_installed_runtime_helper` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5w`
- Reproduktion: `DESTDIR mit scripts/install.sh erzeugen und einen installierten Mojo-Launcher starten; mojo-runtime-exec bricht vor der Laufzeitsuche mit scripts/check_mojo_binary_freshness.sh: not found ab.`
- heutiger Vertrag: install.sh installiert neben find_mojo_runtime.sh nun auch check_mojo_binary_freshness.sh und current_source_id.sh in den privaten Skriptbaum. Installierte Launcher erreichen dadurch zuverlässig die Laufzeitsuche; der neue Input-Semantik-Katalog wird im selben FHS-Test unter share/reta/assets und über den privaten Assetsymlink geprüft.
- spätere Python-Aktion: Keine Python-Referenzänderung erforderlich; der Fehler betraf ausschließlich die Zusammenstellung des installierten nativen Laufzeitbaums.
- Mojo-Orte: `scripts/install.sh`, `bin/mojo-runtime-exec`, `scripts/check_mojo_binary_freshness.sh`, `scripts/current_source_id.sh`, `tests/test_install_layout.py`
- Belege: `STAGE12C5W_COMPILER_INPUT_SEMANTICS.md`, `scripts/install.sh`, `tests/test_install_layout.py`

### MOJO-FIXED-041 – Row-Range-Kompatibilität verwendete Python-Zeichenschnitte als UTF-8-Byteschnitte

- Ursprung: `mojo_port`
- Klasse / Schwere: `unicode_codepoint_boundary` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5w`
- Reproduktion: `is_row_range_token("ä{1,2}") oder RowRangeSyntax("ä").integer_range_pattern() ausführen; die frühere Mojo-Fassung schnitt text[1:] am Byteoffset 1 und zerlegte ein mehrbyteiges Präfix byteweise.`
- heutiger Vertrag: Das Entfernen des ersten Python-Zeichens erfolgt über codepoint_slices(); Regex-Escaping iteriert ebenfalls Unicode-Codepoints. ASCII-Syntaxscanner behalten Byteoffsets nur dort, wo Start und Ende nachweislich an ASCII-Grenzen liegen.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; Python text[1:] und Zeicheniteration waren bereits Unicode-korrekt.
- Python-Orte: `python_reference/reta_architecture/row_ranges.py:58`
- Mojo-Orte: `src/reta_mojo/row_ranges.mojo`, `tests/test_input_semantics.mojo`, `tests/test_input_semantics_complete_source.py`
- Belege: `STAGE12C5W_COMPILER_INPUT_SEMANTICS.md`, `src/reta_mojo/row_ranges.mojo`, `tests/test_input_semantics.mojo`

### TEST-FIXED-026 – FHS-Layouttests hingen von zufällig vorhandenen lokalen Compilerzielen ab

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `foreign_build_artifact_dependency` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5w`
- Reproduktion: `tests/test_install_layout.py in einem source-only Archiv ohne target/bin ausführen; install.sh verlangte drei lokale Compilerziele und der Test konnte das Layout ohne fremden Build nicht prüfen.`
- heutiger Vertrag: install.sh akzeptiert RETA_TARGET_DIR als explizite Paketierungsquelle. Der Layouttest erzeugt ausschließlich die drei obligatorischen ausführbaren Platzhalter in tmp_path und prüft fehlende optionale Ziele getrennt; dadurch ist er unabhängig vom Arbeitsbaum und bleibt trotzdem FHS-realistisch.
- spätere Python-Aktion: Keine Python-Referenzänderung erforderlich; betroffen war nur die reproduzierbare Paketierungsprüfung.
- Mojo-Orte: `scripts/install.sh`, `tests/test_install_layout.py`, `tests/test_input_semantics_complete_source.py`
- Belege: `STAGE12C5W_COMPILER_INPUT_SEMANTICS.md`, `scripts/install.sh`, `tests/test_install_layout.py`

### MOJO-FIXED-042 – Neuer Input-Snapshot war über den öffentlichen reta-mojo-Launcher nicht erreichbar

- Ursprung: `mojo_port`
- Klasse / Schwere: `launcher_dispatch_gap` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5w`
- Reproduktion: `bin/reta-mojo --mojo-input-snapshot aufrufen; ohne expliziten Dispatch fiel der Launcher auf src/main.mojo beziehungsweise reta-mojo-native zurück, obwohl schema_main.mojo den Befehl implementierte.`
- heutiger Vertrag: Alle Schema-Diagnosen einschließlich --mojo-input-snapshot werden vom öffentlichen Launcher atomar an reta-mojo-schema beziehungsweise schema_main.mojo weitergereicht.
- spätere Python-Aktion: Keine Python-Referenzänderung erforderlich; betroffen war nur die native Kommandoverteilung.
- Mojo-Orte: `bin/reta-mojo`, `src/schema_main.mojo`, `tests/test_input_semantics_complete_source.py`
- Belege: `STAGE12C5W_COMPILER_INPUT_SEMANTICS.md`, `bin/reta-mojo`, `scripts/check_input_semantics_parity.py`

### MOJO-FIXED-043 – Table-Generation importierte einen nicht existierenden kombi_join-Modulnamen

- Ursprung: `mojo_port`
- Klasse / Schwere: `unresolved_relative_module_import` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5x`
- Reproduktion: `scripts/build.sh oder mojo build -I src src/table_generation_main.mojo ausführen; table_generation.mojo importierte .kombi_join, obwohl das vorhandene Modul combi_join.mojo heißt.`
- heutiger Vertrag: TableGeneration importiert den kanonischen Besitzer .combi_join. Ein paketweiter Source-Test löst alle relativen reta_mojo-Importe gegen tatsächlich vorhandene .mojo-Dateien auf und verhindert erneute Schreibweisenabweichungen vor dem Compilerlauf.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; der Referenzimport und der Modulname waren korrekt.
- Python-Orte: `python_reference/reta_architecture/table_generation.py`, `python_reference/reta_architecture/combi_join.py`
- Mojo-Orte: `src/reta_mojo/table_generation.mojo`, `src/reta_mojo/combi_join.mojo`, `tests/test_mojo_relative_imports.py`
- Belege: `STAGE12C5X_MODULE_IMPORT_CONSOLE_IO.md`, `src/reta_mojo/table_generation.mojo`, `tests/test_mojo_relative_imports.py`

### MOJO-FIXED-044 – CLI-Hilfeasset und reta_help_text wurden durch eine zusätzliche Newline vermischt

- Ursprung: `mojo_port`
- Klasse / Schwere: `function_cli_newline_contract_conflation` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5x`
- Reproduktion: `assets/reta_help_de.txt beziehungsweise reta_help_en.txt byteweise mit Python reta_architecture.console_io.reta_help_text vergleichen; das für reta -h erzeugte Asset enthält genau eine zusätzliche abschließende Newline.`
- heutiger Vertrag: Der native CLI-Startup verwendet das unveränderte Ausgabeasset einschließlich zusätzlicher Newline. console_io.reta_help_text entfernt ausschließlich diese eine generierte Newline und entspricht dadurch wieder dem reinen Python-Dateiinhalt; Prompt-Help-Assets benötigen keine Korrektur.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; Funktions- und CLI-Vertrag sind dort bereits getrennt.
- Python-Orte: `python_reference/reta_architecture/console_io.py:199`, `python_reference/doc/readme-reta.md`, `python_reference/doc/readme-reta-en.md`
- Mojo-Orte: `src/reta_mojo/console_io.mojo`, `assets/reta_help_de.txt`, `assets/reta_help_en.txt`, `scripts/check_console_io_parity.py`
- Belege: `STAGE12C5X_MODULE_IMPORT_CONSOLE_IO.md`, `src/reta_mojo/console_io.mojo`, `scripts/check_console_io_parity.py`

### TEST-FIXED-027 – All-Columns-Quelltest prüfte den vor der Besitzerverlagerung gültigen CLI-Ort

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `stale_owner_assertion` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5y`
- Reproduktion: `tests/test_all_columns_plan.py nach der Stage-12c4y-Verlagerung von load_all_column_selection aus native_reta_cli.mojo nach parameter_runtime.mojo ausführen; der Test verlangte weiterhin das Symbol im delegierenden CLI-Modul und widersprach damit tests/test_parameter_runtime_source.py.`
- heutiger Vertrag: Der All-Columns-Plan besitzt genau einen produktiven Besitzer in parameter_runtime.mojo. native_reta_cli.mojo importiert und delegiert an diesen Besitzer, enthält aber weder den Katalogloader noch eine duplizierte Alles-Option. Beide Quelltests prüfen nun denselben Architekturvertrag.
- spätere Python-Aktion: Keine Python-Referenzänderung erforderlich; betroffen war ausschließlich eine veraltete Source-Testannahme nach einer bereits abgeschlossenen Mojo-Besitzerverlagerung.
- Mojo-Orte: `tests/test_all_columns_plan.py`, `tests/test_parameter_runtime_source.py`, `src/reta_mojo/native_reta_cli.mojo`, `src/reta_mojo/parameter_runtime.mojo`
- Belege: `STAGE12C5Y_NATIVE_TABLE_OUTPUT.md`, `tests/test_all_columns_plan.py`, `tests/test_parameter_runtime_source.py`

### MOJO-FIXED-045 – Executable-RUNPATH wurde ungeprüft auf eine anders platzierte Shared Library übertragen

- Ursprung: `mojo_port`
- Klasse / Schwere: `shared_library_runpath_layout` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5z`
- Reproduktion: `libreta-mojo-diagnostics.so unter target/lib/reta mit dem bisherigen sanitize_mojo_runpath.py bearbeiten; der Helfer fügte immer $ORIGIN/../lib/mojo hinzu, obwohl die Runtime aus diesem Verzeichnis unter $ORIGIN/../mojo liegt.`
- heutiger Vertrag: Der RUNPATH-Sanitizer erhält den layoutabhängigen relativen Runtimepfad explizit. Executables verwenden $ORIGIN/../lib/mojo; die Shared Library unter target/lib/reta verwendet $ORIGIN/../mojo.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; betroffen war ausschließlich die native ELF-Paketierung.
- Mojo-Orte: `tools/sanitize_mojo_runpath.py`, `scripts/build_diagnostics_shared.sh`, `tests/test_mojo_runtime_path.py`
- Belege: `STAGE12C5Z_SHARED_DIAGNOSTIC_LIBRARY.md`, `scripts/build_diagnostics_shared.sh`, `tests/test_mojo_runtime_path.py`

### MOJO-FIXED-046 – Übertragener Target-Baum enthielt absolute und danach gebrochene Runtime-Symlinks

- Ursprung: `mojo_port`
- Klasse / Schwere: `non_portable_runtime_closure` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5z`
- Reproduktion: `Den unter einem anderen Home-Pfad erzeugten target-Ordner archivieren und auf einem zweiten Rechner entpacken; alle fünf Links unter target/lib/mojo zeigen weiterhin absolut in die ursprüngliche .venv und sind dort nicht auflösbar.`
- heutiger Vertrag: Lokale Builds dürfen den schnellen link-Modus verwenden. RETA_MOJO_RUNTIME_MODE=copy und scripts/export_target.sh erzeugen für die Übergabe eine physisch geschlossene Runtime ohne Symlinks und verweigern einen unvollständigen Export.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; die Daten- und Python-Referenzpfade waren nicht Ursache des Binärtransportfehlers.
- Mojo-Orte: `scripts/configure_mojo_runtime.sh`, `scripts/export_target.sh`, `tests/test_mojo_runtime_path.py`
- Belege: `STAGE12C5Z_SHARED_DIAGNOSTIC_LIBRARY.md`, `scripts/export_target.sh`, `tests/test_mojo_runtime_path.py`

### TEST-FIXED-028 – Installationsmanifesttest zählte verpflichtende Source-ID-Sidecar als unerlaubtes Compilerziel

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `manifest_sidecar_misclassification` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5aa`
- Reproduktion: `scripts/build.sh und anschließend scripts/test_stage12c.sh ausführen; tests/test_install_target_manifest.py meldete reta-mojo-diagnostics.reta-source-id als zusätzliches nicht manifestiertes Ziel.`
- heutiger Vertrag: Der Test trennt ausführbare Compilerziele von Source-ID-Sidecars. Nur manifestierte Executables werden als Ziele gezählt; für das atomare Shared-Diagnostics-Bundle ist genau die Loader-Sidecar zusätzlich erlaubt und separat geprüft.
- spätere Python-Aktion: Keine Python-Referenzänderung erforderlich; betroffen war ausschließlich die native Installationsprüfung.
- Mojo-Orte: `scripts/install.sh`, `tests/test_install_target_manifest.py`, `scripts/install_targets.txt`
- Belege: `STAGE12C5AA_BUILD_OWNERSHIP_LEGACY_PREPARE.md`, `tests/test_install_target_manifest.py`

### TEST-FIXED-029 – Stage-Testskripte bauten produktive Ziele und verschleierten den dauerhaften Buildvertrag

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `build_test_ownership_conflation` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5aa`
- Reproduktion: `Mehrere scripts/test_stage*.sh direkt ausführen; sie schrieben produktive Binaries nach target/bin oder bauten die Shared Library, sodass unklar war, ob neben build.sh und build-heavy.sh weitere Stage-Skripte dauerhaft nötig sind.`
- heutiger Vertrag: scripts/build-all.sh ist der einzige Gesamteinstieg für alle installierbaren regulären, schweren und Shared-Library-Artefakte. Stage-Tests bauen nur isolierte Testprogramme; produktive Ziele werden vorausgesetzt und auf Frische geprüft. Die optionale Shared-Diagnostics-Parität trägt build-and-test ausdrücklich im Namen.
- spätere Python-Aktion: Keine Python-Referenzänderung erforderlich; betroffen war ausschließlich die Trennung von Build- und Testinfrastruktur.
- Mojo-Orte: `scripts/build-all.sh`, `scripts/build.sh`, `scripts/build-heavy.sh`, `scripts/require_built_targets.sh`, `scripts/build-and-test-shared-diagnostics.sh`, `tests/test_stage_build_separation.py`
- Belege: `STAGE12C5AA_BUILD_OWNERSHIP_LEGACY_PREPARE.md`, `scripts/build-all.sh`, `tests/test_stage_build_separation.py`

### TEST-FIXED-030 – Prepare-Zeilentest erwartete Umbruch trotz expliziter unbegrenzter Terminalbreite

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `wrapping_context_contract_mismatch` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ab`
- Reproduktion: `scripts/test_stage12c5aa.sh ausführen; cellWork mit direkter Breite 3 bestand, aber prepare4out_LoopBody erhielt einen Kontext mit shell_rows_amount=0 und der Test erwartete dennoch [abc, def] statt der referenzgemäßen ungebrochenen Zelle.`
- heutiger Vertrag: shell_rows_amount=0 bedeutet unbegrenzte Ausgabe und liefert die ungebrochene Zelle. Der Test prüft diesen Fall ausdrücklich und verwendet für die erwartete Teilung zusätzlich shell_rows_amount=80 bei text_width=3.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; die Referenz kodiert die Nullbreite bereits eindeutig als unbegrenzt.
- Python-Orte: `python_reference/reta_architecture/table_wrapping.py:width_for_row`, `python_reference/reta_architecture/table_preparation.py:prepare_row_cells`
- Mojo-Orte: `tests/test_legacy_lib4tables_prepare.mojo`, `src/reta_mojo/table_wrapping.mojo`, `src/reta_mojo/table_preparation.mojo`
- Belege: `STAGE12C5AB_PREPARE_PROMPT_FACADE.md`, `tests/test_legacy_lib4tables_prepare.mojo`

### MOJO-FIXED-047 – Legacy-Bereichsadapter verwendete veraltete String-Längenabfragen und eine überschrieben initialisierte Variable

- Ursprung: `mojo_port`
- Klasse / Schwere: `compiler_warning_string_length_and_dead_assignment` / `low`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ab`
- Reproduktion: `tests/test_legacy_lib4tables_prepare.mojo kompilieren; Mojo warnte dreimal vor len(String) und einmal vor der vor jeder Nutzung überschriebenen Initialisierung von accepted in parametersCmdWithSomeBereich.`
- heutiger Vertrag: String-Leerheit und Präfixvorhandensein werden über byte_length geprüft. accepted wird genau einmal durch einen bedingten Ausdruck initialisiert; der UTF-8-sichere Präfixschnitt bleibt bytebasiert erst nach erfolgreichem startswith.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; betroffen waren ausschließlich aktuelle Mojo-Compilerdiagnosen.
- Python-Orte: `python_reference/libs/lib4tables_prepare.py:parametersCmdWithSomeBereich`
- Mojo-Orte: `src/reta_mojo/table_adapters.mojo:parametersCmdWithSomeBereich`
- Belege: `STAGE12C5AB_PREPARE_PROMPT_FACADE.md`, `src/reta_mojo/table_adapters.mojo`

### TEST-FIXED-031 – Umbenanntes Shared-Diagnostics-Stage-Skript blieb als produktiv bauende Dublette im Quellbaum

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `stale_stage_build_script_duplicate` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ab`
- Reproduktion: `tests/test_stage_build_separation.py ausführen; scripts/test_stage12c5z.sh existierte trotz Umbenennung weiter und rief build_diagnostics_shared.sh auf, wodurch ein test_stage-Skript weiterhin produktive Artefakte erzeugte.`
- heutiger Vertrag: Die veraltete Dublette ist entfernt. Der einzige bewusst bauende tiefe Diagnosevergleich heißt build-and-test-shared-diagnostics.sh; test_stage-Skripte erzeugen keine installierbaren Artefakte.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; dies war ausschließlich ein Build- und Testbesitzfehler.
- Mojo-Orte: `scripts/test_stage12c5z.sh`, `scripts/build-and-test-shared-diagnostics.sh`, `tests/test_stage_build_separation.py`
- Belege: `STAGE12C5AB_PREPARE_PROMPT_FACADE.md`, `tests/test_stage_build_separation.py`

### MOJO-FIXED-048 – LegacyPromptMapEntry war für Listenassertionen nicht schreibbar

- Ursprung: `mojo_port`
- Klasse / Schwere: `missing_writable_test_value_contract` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ac`
- Reproduktion: `scripts/test_stage12c5ab.sh ausführen; Mojo verwirft assert_equal auf List[LegacyPromptMapEntry], weil der Elementtyp zwar Equatable, aber nicht Writable war.`
- heutiger Vertrag: LegacyPromptMapEntry implementiert Equatable und Writable explizit. Listen können dadurch direkt und mit aussagekräftiger Fehlerdarstellung über std.testing.assert_equal verglichen werden.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; betroffen war ausschließlich der Traitvertrag eines nativen Mojo-Testwerttyps.
- Mojo-Orte: `src/reta_mojo/legacy_libreta_prompt.mojo`, `tests/test_legacy_libreta_prompt.mojo`, `tests/test_legacy_libreta_prompt_source.py`
- Belege: `STAGE12C5AC_PROMPT_PREPARATION_TRAITS.md`, `src/reta_mojo/legacy_libreta_prompt.mojo`, `tests/test_legacy_libreta_prompt.mojo`

### TEST-FIXED-032 – Entferntes Shared-Diagnostics-Stage-Skript war im übergebenen Projektstand weiterhin enthalten

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `release_tree_stale_build_script` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ac`
- Reproduktion: `tests/test_stage_build_separation.py im hochgeladenen 12c5ab-Projektstand ausführen; scripts/test_stage12c5z.sh wurde weiterhin als produktiv bauender Verstoß gefunden.`
- heutiger Vertrag: Die alte Datei ist im tatsächlich ausgelieferten Quellbaum entfernt. Nur das ausdrücklich build-and-test benannte optionale Skript darf die gemeinsame Diagnosebibliothek für die tiefe Paritätsprüfung neu bauen.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; der Fehler lag im übergebenen Build-/Releasebaum.
- Mojo-Orte: `scripts/test_stage12c5z.sh`, `scripts/build-and-test-shared-diagnostics.sh`, `tests/test_stage_build_separation.py`
- Belege: `STAGE12C5AC_PROMPT_PREPARATION_TRAITS.md`, `tests/test_stage_build_separation.py`

### TEST-FIXED-033 – Portierungsmetriktest behandelte erfolgreichen Fortschritt als Fehler

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `stale_derived_metric_expectation` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ad`
- Reproduktion: `scripts/test_stage12c5ac.sh nach der vollständigen Portierung von prompt_preparation.py ausführen; tools/porting_metrics.py meldete korrekt 74 vollständig native Dateien, während tests/test_porting_metrics.py weiterhin exakt 73 erwartete.`
- heutiger Vertrag: Unveränderliche Inventargrößen bleiben exakt geprüft. Fortschrittswerte werden als monotoner Mindeststand geprüft und neue vollständig native Besitzer zusätzlich einzeln in der Portierungsmatrix nachgewiesen. Dadurch erkennt der Test Rückschritte, ohne jeden erfolgreichen Portierungsschritt als Fehler zu melden.
- spätere Python-Aktion: Keine Python-Referenzänderung erforderlich; betroffen war ausschließlich eine abgeleitete Fortschrittserwartung der Testinfrastruktur.
- Mojo-Orte: `tests/test_porting_metrics.py`, `tools/porting_metrics.py`, `tools/generate_porting_matrix.py`
- Belege: `STAGE12C5AD_NATIVE_TABLE_PREPARATION_RUNTIME.md`, `tests/test_porting_metrics.py`, `tools/porting_metrics.py`

### MOJO-FIXED-049 – TableRuntime-Gestirn-Metadaten enthielten eine duplizierte unvollständige Zuweisung

- Ursprung: `mojo_port`
- Klasse / Schwere: `duplicate_assignment_parse_error` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ad`
- Reproduktion: `src/reta_mojo/table_runtime.mojo statisch prüfen oder den neuen Runtime-Test kompilieren; unmittelbar vor der Gestirn-Parameterzuweisung stand dieselbe öffnende Zuweisung zweimal, wodurch der neue Modulpfad nicht parsbar gewesen wäre.`
- heutiger Vertrag: Die generierte Gestirn-Parameterbeschreibung wird genau einmal atomar in den typisierten GeneratedColumnSection geschrieben; Tags und Star-Column-Zustand werden anschließend synchronisiert. Ein Source-Test sichert den vollständigen Besitzerpfad und die Stage kompiliert ihn fokussiert.
- spätere Python-Aktion: Keine spätere Python-Änderung erforderlich; die Referenz enthielt keine doppelte Zuweisung.
- Python-Orte: `python_reference/reta_architecture/table_runtime.py:Tables.Maintable.createSpalteGestirn`
- Mojo-Orte: `src/reta_mojo/table_runtime.mojo:Tables.createSpalteGestirn`, `tests/test_table_runtime_complete_source.py`
- Belege: `STAGE12C5AD_NATIVE_TABLE_PREPARATION_RUNTIME.md`, `src/reta_mojo/table_runtime.mojo`, `tests/test_table_runtime_complete_source.py`

### TEST-FIXED-034 – Prompt-Katalogtest prüfte Interpreterkonfiguration am falschen Skript

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `delegated_configuration_assertion_mismatch` / `low`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ad`
- Reproduktion: `tests/test_completion_native_ownership.py ausführen; der Test verlangte RETA_PYTHON und command -v python3 direkt in check_prompt_language_catalog.sh, obwohl die Interpreterwahl bereits korrekt an select_reference_python.sh delegiert war.`
- heutiger Vertrag: Der Katalogcheck muss den zentralen Referenzinterpreter-Resolver verwenden. Die Priorität RETA_REFERENCE_PYTHON, RETA_PYTHON, PyPy3 und Python3 wird dort geprüft; der aufrufende Check dupliziert diese Logik nicht.
- spätere Python-Aktion: Keine Python-Referenzänderung erforderlich; betroffen war nur eine veraltete Testannahme über die Position der Konfigurationslogik.
- Mojo-Orte: `scripts/check_prompt_language_catalog.sh`, `scripts/select_reference_python.sh`, `tests/test_completion_native_ownership.py`
- Belege: `STAGE12C5AD_NATIVE_TABLE_PREPARATION_RUNTIME.md`, `scripts/select_reference_python.sh`, `tests/test_completion_native_ownership.py`

### MOJO-FIXED-050 – TablePreparation wich bei unregelmäßigen Headern und Generated-Tag-Branchreihenfolge von Python ab

- Ursprung: `mojo_port`
- Klasse / Schwere: `table_preparation_branch_and_header_parity` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ad`
- Reproduktion: `Eine Tabelle mit zweispaltigem Header und dreispaltiger Datenzeile vorbereiten oder einen neuen generierten Parameter zusammen mit einem Override markieren; der erste Port verwendete table.maximum_columns als headingsAmount und wendete Overrides bereits beim ersten Parametereintrag an.`
- heutiger Vertrag: headings_amount ist exakt die Länge von Zeile 0. Ein neuer Ausgabeparameter erhält zunächst die normalen Katalogtags; GeneratedTagOverrides werden nur bei explizit bereits vorhandenem Parameter ausgewertet. Beide Grenzfälle besitzen native Regressionstests.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; die Referenzbranchreihenfolge und Headersemantik waren korrekt.
- Python-Orte: `python_reference/reta_architecture/table_preparation.py:select_display_lines`, `python_reference/reta_architecture/table_preparation.py:tag_output_column`
- Mojo-Orte: `src/reta_mojo/table_preparation.mojo:select_display_lines`, `src/reta_mojo/table_preparation.mojo:tag_output_column`, `tests/test_table_preparation_complete.mojo`
- Belege: `STAGE12C5AD_NATIVE_TABLE_PREPARATION_RUNTIME.md`, `src/reta_mojo/table_preparation.mojo`, `tests/test_table_preparation_complete.mojo`

### TEST-FIXED-035 – Gesamte Mojo-Testsuite vergaß SQLite- und SHA256-Linkerbibliotheken

- Ursprung: `mojo_tests`
- Klasse / Schwere: `test_build_link_contract` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ae`
- Reproduktion: `scripts/test_all.sh bis tests/test_execution_network_persistence.mojo ausführen; der Linker meldete undefinierte Referenzen auf sqlite3_* und SHA256.`
- heutiger Vertrag: test_all.sh ordnet Linkerflags pro Testziel zu: Persistenz erhält -lsqlite3 -lcrypto, Paketintegrität -lcrypto und alle übrigen Tests keine Zusatzbibliotheken.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; dies war ausschließlich ein Test-Buildvertrag.
- Mojo-Orte: `scripts/test_all.sh`, `tests/test_test_all_link_flags.py`
- Belege: `STAGE12C5AE_TEST_ALL_LINKING_PROGRAM_WORKFLOW.md`, `scripts/test_all.sh`, `tests/test_test_all_link_flags.py`

### TEST-FIXED-036 – TableRuntime-Test erwartete private Unterstrichnamen aus einem Sternimport

- Ursprung: `mojo_tests`
- Klasse / Schwere: `test_import_visibility` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ae`
- Reproduktion: `scripts/test_stage12c5ad.sh ausführen; _prepare_class, _concat_class und _get_text_wrap_things waren nach from reta_mojo.table_runtime import * unbekannt.`
- heutiger Vertrag: Historische private Helfer werden explizit aus table_runtime importiert; die öffentliche Paketoberfläche bleibt frei von Unterstrichnamen.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `tests/test_table_runtime_complete.mojo`, `tests/test_table_runtime_complete_source.py`
- Belege: `STAGE12C5AE_TEST_ALL_LINKING_PROGRAM_WORKFLOW.md`, `tests/test_table_runtime_complete.mojo`, `tests/test_table_runtime_complete_source.py`

### MOJO-FIXED-051 – Workflow- und Kombi-Generierung enthielten doppelte lokale Deklarationen

- Ursprung: `mojo_port`
- Klasse / Schwere: `duplicate_local_declaration` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ae`
- Reproduktion: `program_workflow.mojo beziehungsweise table_generation.mojo mit dem Modular-Compiler parsen; pieces und galaxy_output_columns waren jeweils zweimal im selben Gültigkeitsbereich deklariert.`
- heutiger Vertrag: Jeder lokale Arbeitswert wird genau einmal deklariert; Source-Verträge zählen beide kritischen Deklarationen.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; die Referenz enthielt keine doppelten lokalen Deklarationen.
- Python-Orte: `python_reference/reta_architecture/program_workflow.py`
- Mojo-Orte: `src/reta_mojo/program_workflow.mojo`, `src/reta_mojo/table_generation.mojo`, `tests/test_program_workflow_source.py`
- Belege: `STAGE12C5AE_TEST_ALL_LINKING_PROGRAM_WORKFLOW.md`, `src/reta_mojo/program_workflow.mojo`, `src/reta_mojo/table_generation.mojo`, `tests/test_program_workflow_source.py`

### TEST-FIXED-037 – do.sh prüfte den Build-Exitstatus als literalen Text statt als Statuswert

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `build_driver_exit_status` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5af`
- Reproduktion: `./do.sh ausführen; die Bedingung [ "echo $?" == "0" ] ist unter POSIX sh ungültig beziehungsweise immer falsch und übersprang Commit und Tests auch nach erfolgreichem Build.`
- heutiger Vertrag: do.sh verwendet set -eu. Jeder fehlgeschlagene Build oder Test beendet den Ablauf unmittelbar; git commit wird erst nach build-all, Shared-Diagnostics-Parität und test_all ausgeführt.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; dies war ein Buildtreiberfehler.
- Mojo-Orte: `do.sh`, `tests/test_atomic_build_publication.py`
- Belege: `STAGE12C5AF_ATOMIC_BUILD_CORRECTNESS.md`, `do.sh`, `tests/test_atomic_build_publication.py`

### TEST-FIXED-038 – Heavy-Build konnte nach Abbruch alte Binaries durch globalen EXIT-Sanitizer verjüngen

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `non_atomic_build_publication` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5af`
- Reproduktion: `scripts/build-heavy.sh während eines mittleren Compilerziels abbrechen; der frühere EXIT-Trap sanitisierte anschließend den gesamten target/bin-Ordner und änderte damit auch nicht neu gebaute ELF-Dateien.`
- heutiger Vertrag: Jedes Ziel wird unter einem temporären Namen gebaut, geprüft, sanitisiert und markiert. Erst danach wird es veröffentlicht. Alte Ziele werden bei Fehlern nicht berührt; die Inhalts-ID umfasst Quellen, Assets und Buildrezepte, und build-all verifiziert alle Ziele abschließend.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; dies war ein Fehler der nativen Buildinfrastruktur.
- Mojo-Orte: `scripts/build-heavy.sh`, `scripts/build.sh`, `scripts/build_diagnostics_shared.sh`, `scripts/current_source_id.sh`, `scripts/test_atomic_build.sh`
- Belege: `STAGE12C5AF_ATOMIC_BUILD_CORRECTNESS.md`, `scripts/test_atomic_build.sh`, `tests/test_atomic_build_publication.py`

### TEST-FIXED-039 – Input-Semantics-Test erwartete einen transitiven Mojo-Wildcard-Reexport

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `module_export_visibility` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ag`
- Reproduktion: `scripts/test_all.sh ausführen; tests/test_input_semantics.mojo brach mit use of unknown declaration 'is_row_range_token' ab, obwohl die Implementierung in row_ranges.mojo vorhanden war.`
- heutiger Vertrag: Die Input-Semantics-Grenze stellt den nativen Bereichserkenner über eine explizite typisierte Fassade bereit. Der Test kompiliert diese Besitzergrenze direkt und verlässt sich nicht mehr auf transitive Wildcard-Reexports.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; Python-Importsemantik und Mojo-Modulreexports unterscheiden sich hier bewusst.
- Mojo-Orte: `src/reta_mojo/input_semantics.mojo`, `src/reta_mojo/row_ranges.mojo`, `tests/test_input_semantics.mojo`, `scripts/test_stage12c5ag.sh`
- Belege: `STAGE12C5AG_COMPILER_STATUS_GENERATED_REGISTRY.md`, `tests/test_input_semantics_complete_source.py`, `scripts/test_stage12c5ag.sh`

### TEST-FIXED-040 – do.sh leitete bei Aufruf über einen externen Symlink das falsche Projektverzeichnis aus $0 ab

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `build_driver_working_directory` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ah`
- Reproduktion: `do.sh über einen Symlink in /bin oder einem anderen Verzeichnis starten; der frühere dirname-$0-Wechsel konnte /bin als Projektwurzel verwenden und dort falsche oder fehlende Skripte ansprechen.`
- heutiger Vertrag: do.sh bleibt im aktuellen Arbeitsverzeichnis, prüft dort Vollbuild, aktuellen Stage-Test, Shared-Diagnostics und Gesamttests und bricht nach jedem fehlgeschlagenen Schritt mit unverändertem Exitstatus ab. Spätere Tests und der Git-Commit werden nicht ausgeführt; die Originaldiagnose bleibt sichtbar.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; dies war ein Fehler des nativen Buildtreibers.
- Mojo-Orte: `do.sh`, `tests/test_do_sh_fail_fast.py`
- Belege: `STAGE12C5AH_FAIL_FAST_DOMAIN_PROBE_HTML.md`, `tests/test_do_sh_fail_fast.py`, `tests/test_compile_status_reporting.py`

### TEST-FIXED-041 – Acht Mojo-Testfunktionen propagierten mögliche Fehler ohne raises

- Ursprung: `mojo_tests`
- Klasse / Schwere: `missing_raises_effect_annotation` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ai`
- Reproduktion: `scripts/test_all.sh aus Stage 12c5ag ausführen; tests/test_legacy_table_handling.mojo brach beim Parsen an assert_equal, geprüftem Indexzugriff und delegierten Funktionen mit cannot call function that may raise in a context that cannot raise ab.`
- heutiger Vertrag: Jede Mojo-Testfunktion ist explizit mit raises markiert. Ein portabler Quellvertrag durchsucht sämtliche tests/test_*.mojo und verhindert neue Testfunktionen mit implizit nichtwerfendem Kontext.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; betroffen war ausschließlich die Effektannotation der Mojo-Testprogramme.
- Mojo-Orte: `tests/test_legacy_table_handling.mojo`, `tests/test_meta_columns_complete.mojo`, `tests/test_output_semantics_complete.mojo`, `tests/test_table_generation_complete.mojo`, `tests/test_mojo_test_effect_signatures.py`, `scripts/test_stage12c5ai.sh`
- Belege: `STAGE12C5AI_TEST_EFFECTS_NATIVE_SCHEMA_JSON.md`, `tests/test_mojo_test_effect_signatures.py`, `scripts/test_stage12c5ai.sh`

### MOJO-FIXED-052 – Nativer Schemakatalog meldete die Kompatibilitätsfassade statt der realen Splitmodule

- Ursprung: `mojo_port`
- Klasse / Schwere: `schema_snapshot_module_ownership_mismatch` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ai`
- Reproduktion: `Den generierten nativen Schemakatalog mit RetaContextSchema.snapshot vergleichen; context, matrix und runtime standen sämtlich auf i18n.words, und die beiden Kombinationsmatrixgrößen waren im nativen Typ nicht repräsentiert.`
- heutiger Vertrag: Der Generator extrahiert das Schema aus words_context, words_matrix und words_runtime, konserviert die vollständigen Kompatibilitätsmetadaten und serialisiert beide Kombinationsmatrixgrößen sowie alle übrigen Snapshotfelder bytegenau nativ.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; die Python-Referenz besaß die korrekten Splitmodul- und Größeninformationen.
- Python-Orte: `python_reference/reta_architecture/facade.py`, `python_reference/reta_architecture/schema.py`
- Mojo-Orte: `tools/generate_schema_catalog.py`, `src/reta_mojo/schema.mojo`, `src/reta_mojo/schema_catalog.mojo`, `src/reta_mojo/schema_snapshot.mojo`, `tests/test_schema_snapshot.mojo`
- Belege: `STAGE12C5AI_TEST_EFFECTS_NATIVE_SCHEMA_JSON.md`, `tests/test_schema_snapshot_source.py`, `tests/test_schema_snapshot.mojo`

### MOJO-FIXED-053 – Parametergarbe bewahrte Matrix-Einfügereihenfolge statt Python-Kanonsortierung

- Ursprung: `mojo_port`
- Klasse / Schwere: `parameter_semantics_order_mismatch` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ah/12c5ai`
- Reproduktion: `./do.sh 12c5ai ausführen; der aktuelle Stage-Test bricht bei pairs-json religionen ab, weil Python mit Hinduismus beginnt, Mojo aber mit Superkräfte.`
- heutiger Vertrag: Die native Parametergarbe sortiert ParameterAliasGroup und PairColumns nach (main_canonical, parameter_canonical), nachdem Aliase und direkte Spalten vereinigt wurden. Text-, JSON-, Reverse- und Metadatenpfade folgen damit derselben stabilen Python-Reihenfolge; der Paritätstest deckt params, pairs, pairs-json und main-json gemeinsam ab.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; ParameterSemanticsSheaf._rebuild_alias_maps sortiert Parametergruppen und Paarspalten bereits kanonisch.
- Python-Orte: `python_reference/reta_architecture/sheaves.py`, `python_reference/reta_domain_probe_py.py`
- Mojo-Orte: `src/reta_mojo/parameter_semantics.mojo`, `src/domain_probe_main.mojo`, `tests/test_parameter_semantics.mojo`, `scripts/check_domain_probe_parity.py`
- Belege: `STAGE12C5AJ_PARAMETER_ORDER_PROMPT_EXECUTION.md`, `tests/test_parameter_semantics_order_source.py`, `tests/test_parameter_semantics.mojo`

### TEST-FIXED-042 – Architektur-Assetprüfung hing von HOME, Terminal, Git und lokalen Referenzdateien ab

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `non_deterministic_architecture_asset_generation` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5ak`
- Reproduktion: `./do.sh 12c5ak in einem normalen Git-Arbeitsbaum ausführen; generate_architecture_probe_assets.py --check meldete Abweichungen unter anderem in snapshot-json, topology-json, table-wrapping-json, prompt-session-json, sheaves-json und architecture-progress-json.`
- heutiger Vertrag: Statische Architekturassets werden ausschließlich aus einer temporären, manifestbasierten Kopie des Python-Referenzbaums außerhalb von Git erzeugt. HOME und Terminalgeometrie sind während der Generierung kanonisch; Referenzwurzel und Homeverzeichnis werden als portable Token gespeichert und erst im nativen Lauf aufgelöst. Ungetrackte Dateien, target, ein lesbarer Git-Verlauf und das aufrufende Terminal können den Snapshot nicht mehr verändern.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; betroffen war ausschließlich die Reproduzierbarkeit des generierten nativen Architekturkatalogs und seiner Paritätsharnesses.
- Mojo-Orte: `tools/generate_architecture_probe_assets.py`, `src/reta_mojo/architecture_probe_assets.mojo`, `src/reta_mojo/resource_paths.mojo`, `scripts/check_architecture_probe_parity.py`, `scripts/check_domain_probe_parity.py`, `tests/test_architecture_probe_assets_source.py`, `scripts/test_stage12c5al.sh`
- Belege: `STAGE12C5AL_NATIVE_LEGACY_I18N_MONOLITH.md`, `tools/generate_architecture_probe_assets.py`, `tests/test_architecture_probe_assets_source.py`, `scripts/test_stage12c5al.sh`

### TEST-FIXED-043 – Architektursnapshot übernahm die Prozessorkernzahl des Buildrechners

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `host_cpu_dependent_architecture_snapshot` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5al`
- Reproduktion: `./do.sh 12c5al auf einem Rechner mit anderer physischer/logischer Kernzahl ausführen; trotz manifestisolierter Referenzkopie unterschieden sich ausschließlich snapshot-json.json und das daraus abgeleitete manifest.tsv.`
- heutiger Vertrag: Der Architekturassetgenerator importiert die Referenzmodule unter einer kanonischen Prozessortopologie von acht physischen, virtuellen und verfügbaren Kernen. CPU-Zahl, Prozessaffinität und /proc/cpuinfo-Fallback sind vor dem Import kontrolliert; bereits geladene reta_architecture-Module werden verworfen. Ein sitecustomize-Störtest mit abweichenden Kernzahlen muss weiterhin alle 63 Assets byteidentisch bestätigen.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; reale Laufzeitparallelität erkennt weiterhin die tatsächliche Hardware. Nur der unveränderliche Architekturkatalog verwendet kanonische Snapshotwerte.
- Python-Orte: `python_reference/reta_architecture/parallel_execution.py`, `python_reference/reta_architecture/facade.py`
- Mojo-Orte: `tools/generate_architecture_probe_assets.py`, `assets/architecture_probe/snapshot-json.json`, `tests/test_architecture_probe_assets_source.py`, `scripts/test_stage12c5al.sh`
- Belege: `STAGE12C5AM_NATIVE_RETA_PROMPT_GENERATED_INTEGRATION.md`, `tools/generate_architecture_probe_assets.py`, `tests/test_architecture_probe_assets_source.py`

### MOJO-FIXED-054 – Normalisierte Aliasgruppen und exakte Matrixmetadaten verwendeten fälschlich dieselbe Reihenfolge

- Ursprung: `mojo_port`
- Klasse / Schwere: `parameter_alias_dual_order_mismatch` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5am/12c5an`
- Reproduktion: `./do.sh 12c5am ausführen; zunächst wich column 4 ab, weil exact_meta_for_column sortierte Aliasgruppen statt der ursprünglichen Matrixreihenfolge verwendete. Nach reinem Bewahren der Einfügereihenfolge wich params religionen ab, weil Python dort die normalisierte Aliasmenge lexikographisch sortiert.`
- heutiger Vertrag: Die native Parametergarbe besitzt zwei ausdrücklich getrennte Ordnungen wie die Python-Referenz: parameter_alias_groups sortiert die vereinigte Aliasmenge lexikographisch, während raw_parameter_entries die ursprüngliche paraNdataMatrix-Reihenfolge für exact_meta_for_column bytegenau bewahrt. Gruppen und Paarspalten bleiben zusätzlich kanonisch nach Haupt- und Unterparameter sortiert.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; die unterschiedlichen Ordnungen sind beabsichtigte beobachtbare Verträge der normalisierten Garbe und der exakten Matrixinspektion.
- Python-Orte: `python_reference/reta_architecture/sheaves.py`, `python_reference/reta_domain_probe_py.py`
- Mojo-Orte: `src/reta_mojo/parameter_semantics.mojo`, `tests/test_parameter_semantics.mojo`, `tests/test_parameter_semantics_order_source.py`
- Belege: `STAGE12C5AN_NATIVE_MOJO_BRIDGE_PARAMETER_RUNTIME.md`, `tests/test_parameter_semantics.mojo`, `tests/test_parameter_semantics_order_source.py`, `scripts/check_domain_probe_parity.py`

### MOJO-FIXED-055 – Generated-Columns-Test verlangte eine implizite Kopie von CsvTable

- Ursprung: `mojo_port`
- Klasse / Schwere: `non_implicit_copyable_ownership_boundary` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5am`
- Reproduktion: `./do.sh 12c5am ausführen; der Modular-Compiler bricht in tests/test_generated_columns_integration.mojo beim Aufbau von GeneratedColumnsApplicationRequest mit 'CsvTable cannot be implicitly copied' ab.`
- heutiger Vertrag: CsvTable, Listen und Strings der geliehenen GeneratedColumnsApplicationRequest-Grenze werden ausdrücklich mit .copy() in den besitzenden nativen Pipelineaufruf überführt. Der Testhelfer kopiert seinen Tisch ebenfalls sichtbar, sodass der Ursprungswert für nachfolgende Assert-Vergleiche erhalten bleibt.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; betroffen war ausschließlich die strengere Mojo-1.0-Besitzsemantik für Copyable, aber nicht ImplicitlyCopyable.
- Mojo-Orte: `tests/test_generated_columns_integration.mojo`, `src/reta_mojo/generated_columns_integration.mojo`, `tests/test_generated_columns_integration_source.py`, `scripts/test_stage12c5ao.sh`
- Belege: `STAGE12C5AO_RETA_PROGRAM_SETUP_OWNERSHIP.md`, `tests/test_generated_columns_integration.mojo`, `tests/test_generated_columns_integration_source.py`

### TEST-FIXED-044 – Weitergereichte Compilerthreads kollidierten mit drei internen -j-Defaults

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `duplicate_compiler_thread_option` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5az/12c5ba`
- Reproduktion: `scripts/build-all.sh -- -j 8 ausführen; reta-mojo-execution-network brach mit 'Number of threads can only be specified once' ab, weil build-heavy.sh zusätzlich intern -j 4 setzte.`
- heutiger Vertrag: Die öffentlichen Buildskripte akzeptieren höchstens eine benutzerseitige Mojo-Threadoption. Für die drei besonders großen Ziele unterdrückt ein Benutzerwert den lokalen -j-4-Default; ohne Benutzerwert wird dieser Default exakt einmal ergänzt. Zwei explizite Benutzerwerte werden vor dem ersten Compileraufruf mit Exitstatus 2 abgelehnt.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; betroffen war ausschließlich die native Mojo-Buildorchestrierung.
- Mojo-Orte: `scripts/mojo_build_options.sh`, `scripts/build.sh`, `scripts/build-heavy.sh`, `scripts/build-all.sh`, `scripts/build_diagnostics_shared.sh`, `tests/test_build_compiler_options.py`, `tests/test_build_thread_option_dedup.py`
- Belege: `STAGE12C5BA_BUILD_THREADS_RAISES_NEGATIVE_FRACTION_NOOPS.md`, `tests/test_build_compiler_options.py`, `tests/test_build_thread_option_dedup.py`, `scripts/test_stage12c5ba.sh`

### MOJO-FIXED-056 – Gemischte Reziprokachsen konvertierten String nach Int in einem nichtwerfenden Kontext

- Ursprung: `mojo_port`
- Klasse / Schwere: `missing_raises_effect_annotation` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5az/12c5ba`
- Reproduktion: `scripts/build-all.sh aus Stage 12c5az ausführen; src/prompt_main.mojo brach beim Import von prompt_table_execution.mojo an Int(seed_rows[index]) mit 'cannot call function that may raise in a context that cannot raise' ab.`
- heutiger Vertrag: Die beiden internen Hilfsfunktionen zur Zusammenführung und Expansion reziproker Vielfachenzeilen sind ausdrücklich raises. Der bereits werfende öffentliche Tabellenplaner propagiert mögliche Int(String)-Konvertierungsfehler, ohne sie zu verschlucken oder eine Ersatzsemantik einzuführen.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; betroffen war ausschließlich Mojos explizites Effektsystem.
- Mojo-Orte: `src/reta_mojo/prompt_table_execution.mojo`, `tests/test_prompt_mixed_fraction_multiple_source.py`, `tests/test_stage12c5ba_source.py`, `scripts/test_stage12c5ba.sh`
- Belege: `STAGE12C5BA_BUILD_THREADS_RAISES_NEGATIVE_FRACTION_NOOPS.md`, `tests/test_stage12c5ba_source.py`, `tests/test_prompt_mixed_fraction_multiple_source.py`, `scripts/test_stage12c5ba.sh`

### TEST-FIXED-045 – Prägarbentest verwarf sprachneutrale Sektionen bei sprachspezifischer Restriktion

- Ursprung: `mojo_tests`
- Klasse / Schwere: `overconstrained_presheaf_inheritance_assertion` / `medium`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bc/12c5bd`
- Reproduktion: `scripts/test_all.sh aus Stage 12c5bc ausführen; test_filesystem_sections_preserve_context_and_payload erwartete im ersten cn/csv-Treffer zwingend csv/cn-, obwohl die erste gültige Sektion sprachneutral war.`
- heutiger Vertrag: Eine sprachspezifische Restriktion erbt sowohl explizit chinesische als auch sprachneutrale CSV-Sektionen. Der vollständige Vertrag zählt 16 cn-Sektionen und 16 neutrale Sektionen; alle 32 Resultate tragen nach der Verfeinerung cn im Kontext und bewahren Quelle sowie Nutzlast.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; die Python- und Mojo-Prägarbenverfeinerung war korrekt. Nur der zu positionsabhängige Mojo-Test wurde auf den vollständigen Vererbungsvertrag korrigiert.
- Python-Orte: `python_reference/reta_architecture/presheaves.py`, `python_reference/reta_architecture/topology.py`
- Mojo-Orte: `tests/test_presheaves_complete.mojo`, `src/reta_mojo/presheaves.mojo`, `src/reta_mojo/topology.mojo`, `tests/test_presheaf_inheritance_source.py`
- Belege: `STAGE12C5BD_PRESHEAF_INHERITANCE_RECIPROCAL_COLLISION.md`, `tests/test_presheaves_complete.mojo`, `tests/test_presheaf_inheritance_source.py`, `scripts/test_stage12c5bd.sh`

### MOJO-FIXED-057 – ProgramWorkflowBundle ignorierte sein explizites repo_root beim CSV-Laden

- Ursprung: `mojo_port`
- Klasse / Schwere: `ignored_resource_owner_root` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bd/12c5be`
- Reproduktion: `RETA_TEST_HEAVY=1 scripts/test_all.sh aus Stage 12c5bd ausführen; test_program_workflow_loads_and_pads_religion_table las Jungfrau aus python_reference/csv/religion.csv statt 한글 中文 Việt aus tests/fixtures/program_workflow_root/csv/religion.csv.`
- heutiger Vertrag: Ein konkretes ProgramWorkflowBundle.repo_root besitzt seine CSV-Wurzel und löst jeden Dateinamen als repo_root/csv/basename auf. Nur ein leeres oder punktförmiges Root delegiert an den portablen FHS-/Umgebungsresolver. Religionstabelle und sprachspezifische Motivspalten verwenden denselben expliziten Besitzerwert.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; das Python-Original verwendete repo_root bereits korrekt. Betroffen war ausschließlich der unvollständige Mojo-Besitztransfer.
- Python-Orte: `python_reference/reta_architecture/program_workflow.py:36`, `python_reference/reta_architecture/program_workflow.py:62`
- Mojo-Orte: `src/reta_mojo/program_workflow.mojo`, `tests/test_program_workflow.mojo`, `tests/test_program_workflow_source.py`, `tests/test_stage12c5be_source.py`
- Belege: `STAGE12C5BE_WORKFLOW_ROOT_OUTPUT_MODE_FULL_SUITE.md`, `tests/test_program_workflow.mojo`, `tests/test_stage12c5be_source.py`

### MOJO-FIXED-058 – Workflow dekodierte Rich-Text und plante gleichzeitig Shell-Ausgabe

- Ursprung: `mojo_port`
- Klasse / Schwere: `split_output_mode_ownership` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bd/12c5be`
- Reproduktion: `tests/test_program_workflow.mojo mit argv=['reta','--art=html'] ausführen; _requested_religion_output_kind lieferte html, build_parameter_runtime_plan mangels -ausgabe-Hauptabschnitt jedoch shell.`
- heutiger Vertrag: Der Workflow synchronisiert die lokalisiert erkannten kanonischen Rich-Modi html und bbcode in seinen ParameterRuntimePlan, sodass Zellendekodierung, Tabellengenerierung und Renderergrenze denselben Modus besitzen. Andere Ausgabemodi bleiben im allgemeinen Abschnittsparser. Bei gleichzeitigem HTML und BBCode gewinnt weiterhin BBCode unabhängig von der Argumentfolge.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; der native typisierte Workflow musste lediglich seine zuvor getrennten Dekodier- und Rendererzustände gluen.
- Python-Orte: `python_reference/reta_architecture/program_workflow.py:49`, `python_reference/reta_architecture/program_workflow.py:142`
- Mojo-Orte: `src/reta_mojo/program_workflow.mojo`, `src/reta_mojo/parameter_runtime.mojo`, `tests/test_program_workflow.mojo`, `tests/test_stage12c5be_source.py`
- Belege: `STAGE12C5BE_WORKFLOW_ROOT_OUTPUT_MODE_FULL_SUITE.md`, `tests/test_program_workflow.mojo`, `tests/test_program_workflow_source.py`, `tests/test_stage12c5be_source.py`

### TEST-FIXED-046 – Fokussierter Workflowtest verdeckte eine globale Fixture-Abhängigkeit

- Ursprung: `mojo_tests`
- Klasse / Schwere: `hidden_environment_fixture_dependency` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5k/12c5be`
- Reproduktion: `scripts/test_stage12c5k.sh bestand nur mit extern gesetztem RETA_DATA_DIR; scripts/test_all.sh startete dasselbe Testprogramm ohne diese Variable und erhielt deshalb Produktionsdaten statt Fixture-Daten.`
- heutiger Vertrag: Der Workflowtest konstruiert seinen expliziten Fixture-Root im typisierten ProgramWorkflowBundle. Fokussierter Stage-Test und allgemeine Testsuite führen dasselbe Binärprogramm ohne verstecktes RETA_DATA_DIR aus; die separate CLI-Parität darf weiterhin bewusst den installierbaren Ressourcenresolver per Umgebung testen.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; betroffen war ausschließlich die Isolierung des nativen Mojo-Tests.
- Mojo-Orte: `scripts/test_stage12c5k.sh`, `scripts/test_stage12c5be.sh`, `tests/test_program_workflow.mojo`, `tests/test_stage12c5be_source.py`
- Belege: `STAGE12C5BE_WORKFLOW_ROOT_OUTPUT_MODE_FULL_SUITE.md`, `scripts/test_stage12c5be.sh`, `tests/test_stage12c5be_source.py`

### MOJO-FIXED-059 – Echte Bruchvielfache verloren danebenstehende positive Ganzzahl-Multiplikatoren

- Ursprung: `mojo_port`
- Klasse / Schwere: `fraction_integer_axis_composition_loss` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bf/12c5bg`
- Reproduktion: `Den nativen Plan für universum v2/3,5 beziehungsweise universum motive v2/3,5 prüfen; der Ein-Domänenpfad behandelte 5 nur als sichtbare Einzelzeile ohne --vielfachevonzahlen und v5, der Mehrdomänenpfad fiel vollständig zurück.`
- heutiger Vertrag: Positive gewöhnliche Ganzzahlen und positive Bereiche werden neben echten Bruchvielfachen als eigene Vielfachenachse bewahrt. Ganzzahlige Projektionen des Bruchrasters bleiben davon getrennt, damit sie nicht doppelt vervielfacht werden; Originalschreibweise und v-Präfix bleiben in der historischen Zeilenreihenfolge. Teilerformen behalten die Zeilenachse, reichen --vielfachevonzahlen aber nicht weiter.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; die instrumentierte Referenz bewahrt die äußere Komposition aus Projektionszeilen, Originalausdruck, v-Ausdruck und gewöhnlicher Vielfachenoption. Der bekannte Python-Indexfehler innerhalb des echten Bruchrasters bleibt separat unter PY-OPEN-002 dokumentiert.
- Python-Orte: `python_reference/reta_architecture/prompt_execution.py:1823`, `python_reference/reta_architecture/prompt_execution.py:1864`
- Mojo-Orte: `src/reta_mojo/prompt_table_execution.mojo`, `tests/test_prompt_table_execution.mojo`, `tests/prompt_true_fraction_multiple_probe.mojo`, `scripts/check_prompt_true_fraction_multiples.py`, `tests/test_prompt_fraction_integer_axes_source.py`
- Belege: `STAGE12C5BG_DETERMINISTIC_COMMAND_PARITY_INTEGER_FRACTION_AXES.md`, `tests/test_prompt_table_execution.mojo`, `tests/test_prompt_fraction_integer_axes_source.py`, `scripts/check_prompt_true_fraction_multiples.py`

### TEST-FIXED-047 – Generierte Markdown-/HTML-Paritätsassets hingen von der installierten Rich-Version ab

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `ambient_optional_renderer_dependency` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bf/12c5bg`
- Reproduktion: `Die vollständige Stage-Kette auf dem Fedora-/Python-3.14-System ausführen; test_stage12c5aq meldete ausschließlich markdown-religion-basic.out, html-religion-basic.out und das daraus abgeleitete command_parity.tsv als abweichend, während beide Shell-Assets identisch blieben.`
- heutiger Vertrag: Die eingefrorene Python-Referenz für Kommandoassets läuft mit einem repositoryeigenen textuellen Rich-Minimaladapter vor allen Umgebungs-Site-Packages. Benutzerpakete sind deaktiviert; eine fremde oder defekte Rich-Installation kann die vier kanonischen Asset-Hashes nicht mehr verändern. Abweichungen nennen Ist- und Soll-SHA-256.
- spätere Python-Aktion: Keine Änderung am eingefrorenen Python-Algorithmus erforderlich; betroffen war ausschließlich die Reproduzierbarkeit der generierten nativen Erwartungsassets über verschiedene Testumgebungen.
- Python-Orte: `python_reference/reta_architecture/console_io.py:35`, `python_reference/reta_architecture/console_io.py:282`
- Mojo-Orte: `tools/generate_command_parity_assets.py`, `tools/reference_runtime_stubs/rich/console.py`, `tools/reference_runtime_stubs/rich/markdown.py`, `tools/reference_runtime_stubs/rich/syntax.py`, `tests/test_command_parity_asset_environment.py`, `scripts/test_stage12c5bg.sh`
- Belege: `STAGE12C5BG_DETERMINISTIC_COMMAND_PARITY_INTEGER_FRACTION_AXES.md`, `tools/generate_command_parity_assets.py`, `tests/test_command_parity_asset_environment.py`, `scripts/test_stage12c5bg.sh`

### MOJO-FIXED-060 – Kommalokale Null- und Ausschlussachsen neben echten Bruchvielfachen fielen atomar zurück

- Ursprung: `mojo_port`
- Klasse / Schwere: `fraction_nonpositive_integer_axis_fallback` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bg/12c5bh`
- Reproduktion: `Die nativen Pläne für universum motive v2/3,0, universum motive v2/3,-10 und universum motive v2/3,5,-10 prüfen; trotz stabiler äußerer Python-Achse fiel der gesamte Vektor zurück.`
- heutiger Vertrag: Kommalokale 0-, negative Ausschluss- und Bereich/Ausschluss-Komponenten bleiben als gewöhnliche äußere Ganzzahlachse erhalten. Ihre Quellschreibweisen gehen in --vielfachevonzahlen und in die v-präfigierten Zeilenselektoren ein; die korrigierten Bruchprojektionen werden nicht doppelt vervielfacht. Die in Stage 12c5bh noch offenen separat negativen No-op- und nichtpositiven teiler-Grammatiken sind inzwischen separat durch MOJO-FIXED-061 typisiert.
- spätere Python-Aktion: Keine Änderung am äußeren Python-Vertrag erforderlich. Der bekannte Indexfehler im inneren echten Bruchraster bleibt separat unter PY-OPEN-002 dokumentiert; eine spätere Python-Bereinigung muss diese beiden Ebenen getrennt erhalten.
- Python-Orte: `python_reference/reta_architecture/prompt_execution.py:1823`, `python_reference/reta_architecture/prompt_execution.py:1864`
- Mojo-Orte: `src/reta_mojo/prompt_table_execution.mojo`, `tests/test_prompt_table_execution.mojo`, `tests/prompt_true_fraction_multiple_probe.mojo`, `scripts/check_prompt_true_fraction_multiples.py`, `tests/test_prompt_fraction_integer_axes_source.py`
- Belege: `STAGE12C5BH_SPLIT_TEST_PIPELINE_NONPOSITIVE_FRACTION_AXES.md`, `tests/test_prompt_table_execution.mojo`, `scripts/check_prompt_true_fraction_multiples.py`, `tests/test_prompt_fraction_integer_axes_source.py`

### TEST-FIXED-048 – Frühere Patchkette ließ zwei alte Kommando-Paritätsassets im Arbeitsbaum zurück

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `stale_generated_asset_patch_migration` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bg/12c5bh`
- Reproduktion: `test_stage12c5aq.sh nach erfolgreichem Vollbuild ausführen; der Generator erzeugt für HTML a8a0d2a1… und für das Manifest 9fdefe9a…, während der lokale Arbeitsbaum noch 17453b00… beziehungsweise 87f6d8c4… enthält.`
- heutiger Vertrag: Der Generator kann ausschließlich die zwei exakt bekannten historischen SHA-256-Zustände migrieren und prüft danach erneut kanonisch. Unbekannte oder fehlende Assets werden nicht überschrieben, sondern bleiben ein harter Fehler. Damit wird ein alter Patchstand repariert, ohne neue Referenzänderungen automatisch zu akzeptieren.
- spätere Python-Aktion: Keine Python- oder Mojo-Algorithmusänderung erforderlich; betroffen war die Zustandsübernahme generierter Testassets zwischen Stages.
- Mojo-Orte: `tools/generate_command_parity_assets.py`, `scripts/test_stage12c5aq.sh`, `scripts/test_stage12c5bg.sh`, `scripts/test_stage12c5bh.sh`, `tests/test_stage12c5bh_source.py`
- Belege: `STAGE12C5BH_SPLIT_TEST_PIPELINE_NONPOSITIVE_FRACTION_AXES.md`, `tools/generate_command_parity_assets.py`, `tests/test_stage12c5bh_source.py`

### TEST-FIXED-049 – Gesamttests koppelten jede Ausführung unnötig an eine vollständige Neukompilierung

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `coupled_test_build_and_execution` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bh`
- Reproduktion: `scripts/test_all.sh wiederholt ausführen; vor dieser Stage wurde jedes Mojo-Testprogramm vor jedem Lauf erneut kompiliert, auch wenn ausschließlich Laufzeitresultate wiederholt werden sollten.`
- heutiger Vertrag: build-tests.sh kompiliert atomar und schreibt ein Frischemanifest; run-tests.sh führt nur passende vorhandene Binaries aus und lehnt veraltete Zustände ab. test_all.sh bleibt als kompatibler Wrapper. Laufzeitparallelität ist opt-in; jeder Test erhält ein eigenes RETA_TEST_SANDBOX/TMPDIR und der frühere feste Prompt-History-Pfad verwendet dieses Sandboxverzeichnis. Verbleibende serial/exclusive-Barrieren werden respektiert; mehrere eigenständige Mojo-Compilerprozesse bleiben standardmäßig sequenziell.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; dies ist eine reine Build- und Testinfrastrukturverbesserung.
- Mojo-Orte: `scripts/build-tests.sh`, `scripts/run-tests.sh`, `scripts/test_all.sh`, `scripts/current_test_source_id.sh`, `tools/run_mojo_test_binaries.py`, `tests/test_split_test_pipeline.py`
- Belege: `STAGE12C5BH_SPLIT_TEST_PIPELINE_NONPOSITIVE_FRACTION_AXES.md`, `tests/test_split_test_pipeline.py`, `BUILD.md`

### MOJO-FIXED-061 – Separat negative No-op-Tokens und nichtpositive Teilerachsen fielen bei echten Bruchvielfachen zurück

- Ursprung: `mojo_port`
- Klasse / Schwere: `fraction_divider_and_standalone_negative_composition_gap` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bh/12c5bi`
- Reproduktion: `Die nativen Pläne für universum motive v2/3 -10, universum v2/3,0 teiler und universum v2/3,5,-10 teiler prüfen; alle drei Vektoren fielen trotz stabiler äußerer Promptgrammatik vollständig zurück.`
- heutiger Vertrag: Ein separat geschriebenes negatives Token wird wie in der historischen Promptgrammatik konsumiert und verändert den korrigierten Bruchplan nicht. Im teiler-Zweig werden positive überlebende Werte in ihre Divisorvereinigung überführt, mehrbyteige Rohkomponenten danach bewahrt und v-Formen zuletzt angefügt; Null trägt keinen Divisor und bleibt als v0 sichtbar. --vielfachevonzahlen wird im teiler-Zweig nicht gesetzt.
- spätere Python-Aktion: Keine Änderung der äußeren Python-Grammatik erforderlich. Bei der späteren Behebung von PY-OPEN-002 muss die korrigierte innere Bruchrechteckberechnung diese bestehende No-op-/Divisor-/Rohwert-/v-Reihenfolge bewahren.
- Python-Orte: `python_reference/reta_architecture/prompt_execution.py:2347`, `python_reference/reta_architecture/prompt_execution.py:2367`, `python_reference/reta_architecture/prompt_execution.py:1823`, `python_reference/reta_architecture/prompt_execution.py:1864`
- Mojo-Orte: `src/reta_mojo/prompt_table_execution.mojo`, `tests/test_prompt_table_execution.mojo`, `tests/prompt_true_fraction_multiple_probe.mojo`, `scripts/check_prompt_true_fraction_multiples.py`, `tests/test_prompt_fraction_integer_axes_source.py`
- Belege: `STAGE12C5BI_COMPILER_OPTIONS_PROMPT_STRING_DIVIDER_AXES.md`, `tests/test_prompt_table_execution.mojo`, `scripts/check_prompt_true_fraction_multiples.py`, `tests/test_prompt_fraction_integer_axes_source.py`

### TEST-FIXED-050 – Prompt-History-Sandboxtest inferierte StringSlice und war danach nicht mehr zuweisbar

- Ursprung: `mojo_tests`
- Klasse / Schwere: `borrowed_string_slice_reassignment_compile_failure` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bh/12c5bi`
- Reproduktion: `scripts/build-tests.sh -- -j 4 ausführen; tests/test_native_prompt_input.mojo brach bei root = "/tmp" ab, weil var root durch String(...).strip() als StringSlice inferiert worden war.`
- heutiger Vertrag: Das Sandboxverzeichnis wird zunächst als besitzender String geladen und das Ergebnis von strip anschließend ausdrücklich wieder in einen String kopiert. Leerer Inhalt kann danach typkorrekt auf /tmp zurückgesetzt werden.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; betroffen war ausschließlich ein Mojo-Test und dessen Ownership-Typinferenz.
- Mojo-Orte: `tests/test_native_prompt_input.mojo`, `tests/test_stage12c5bi_source.py`, `scripts/test_stage12c5bi.sh`
- Belege: `STAGE12C5BI_COMPILER_OPTIONS_PROMPT_STRING_DIVIDER_AXES.md`, `tests/test_native_prompt_input.mojo`, `tests/test_stage12c5bi_source.py`

### TEST-FIXED-051 – Mehrdomänen-Bruchtest prüfte die Universe-Ganzzahlachse am Reziprokindex

- Ursprung: `mojo_tests`
- Klasse / Schwere: `wrong_invocation_block_index` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bg/12c5bi`
- Reproduktion: `test_true_fraction_multiples_follow_each_csv_rectangle ausführen; die Assertion erwartete --vielfachevonzahlen=5 in Invocation 7, obwohl der Emotionblock 0–5 belegt, die Universe-Ganzzahlachse 6 und die Universe-Reziprokachse 7 ist.`
- heutiger Vertrag: Der Test bindet die gewöhnliche Universe-Ganzzahlachse an Index 6. Index 7 wird zusätzlich positiv als transzendental-reziproke Achse und negativ als frei von --vielfachevonzahlen geprüft.
- spätere Python-Aktion: Keine Python- oder Mojo-Produktionsänderung erforderlich; betroffen war ausschließlich die Positionsannahme im Test.
- Mojo-Orte: `tests/test_prompt_table_execution.mojo`, `scripts/check_prompt_true_fraction_multiples.py`, `tests/test_stage12c5bi_source.py`
- Belege: `STAGE12C5BI_COMPILER_OPTIONS_PROMPT_STRING_DIVIDER_AXES.md`, `tests/test_prompt_table_execution.mojo`, `tests/test_stage12c5bi_source.py`

### TEST-FIXED-052 – Kombinierter Testeinstieg und fokussierte Stages konnten Compilerthreadoptionen nicht durchreichen

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `test_compiler_option_forwarding_gap` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bh/12c5bi`
- Reproduktion: `scripts/test_all.sh oder scripts/test_stage12c5bh.sh mit einer gewünschten Threadzahl verwenden; der Wrapper bot keine Argumentgrenze für Mojo-Optionen und die Stage hardcodierte -j 4.`
- heutiger Vertrag: Compileroptionen hinter -- werden unverändert an jeden einzelnen mojo build-Aufruf weitergereicht. --run-jobs steuert unabhängig die Laufzeitparallelität. Mehrere eigenständige Compilerprozesse bleiben sequenziell und doppelte Threadoptionen werden früh abgelehnt.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; dies ist eine reine Build- und Testinfrastrukturverbesserung.
- Mojo-Orte: `scripts/test_all.sh`, `scripts/build-tests.sh`, `scripts/test_stage12c5bh.sh`, `scripts/test_stage12c5bi.sh`, `scripts/check_prompt_true_fraction_multiples.sh`, `scripts/mojo_build_options.sh`, `tests/test_split_test_pipeline.py`, `tests/test_stage12c5bi_source.py`
- Belege: `STAGE12C5BI_COMPILER_OPTIONS_PROMPT_STRING_DIVIDER_AXES.md`, `tests/test_split_test_pipeline.py`, `tests/test_stage12c5bi_source.py`, `BUILD.md`

### TEST-FIXED-053 – Kanonische Kommando-Paritätsassets wurden unter CPython 3.14 erneut als unbekannte Migration behandelt

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `ambient_interpreter_asset_regeneration_gate` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bh/12c5bj`
- Reproduktion: `scripts/test_stage12c5bh.sh unter der Python-3.14-.venv ausführen, während html-religion-basic.out bereits a8a0d2a1… und command_parity.tsv bereits 9fdefe9a… besitzen; --migrate-legacy verweigerte diese kanonischen Hashes als unbekannt.`
- heutiger Vertrag: Stage- und Releaseprüfungen vergleichen die vier Kommandoausgaben und das TSV-Manifest ausschließlich mit fest versionierten SHA-256-Werten. Der read-only --check-Pfad startet keinen Python-Renderer. --check-reference ist eine ausdrückliche Entwicklerdiagnose für interpreterabhängige Referenzausgaben; Teststages migrieren oder schreiben keine Quellassets mehr. Bereits kanonische Migrationen sind ohne Referenzausführung idempotent.
- spätere Python-Aktion: Keine Änderung am eingefrorenen Python-Algorithmus erforderlich. Eine spätere bewusste Referenzaktualisierung muss die gepinnten Assets und ihre Hashliste in einem überprüften Commit gemeinsam ändern.
- Mojo-Orte: `tools/generate_command_parity_assets.py`, `scripts/test_stage12c5aq.sh`, `scripts/test_stage12c5bg.sh`, `scripts/test_stage12c5bh.sh`, `scripts/test_stage12c5bj.sh`, `tests/test_command_parity_asset_environment.py`, `tests/test_stage12c5bj_source.py`
- Belege: `STAGE12C5BJ_PINNED_COMMAND_PARITY_ASSETS.md`, `tools/generate_command_parity_assets.py`, `tests/test_command_parity_asset_environment.py`, `tests/test_stage12c5bj_source.py`

### TEST-FIXED-054 – Bruchteilerpfad übergab Set[Int] an den List[Int]-Divisorreihenfolgehelfer

- Ursprung: `mojo_port`
- Klasse / Schwere: `set_to_list_compile_boundary` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bi/12c5bj`
- Reproduktion: `scripts/build-all.sh -- -j 5 ausführen; src/prompt_main.mojo brach in _projected_fraction_divisor_rows ab, weil range_to_numbers Set[Int] liefert und python_divisor_set_order List[Int] verlangt.`
- heutiger Vertrag: Der von range_to_numbers gelieferte Set[Int] wird explizit in eine besitzende List[Int] materialisiert. Erst diese Liste wird an python_divisor_set_order übergeben. Der fokussierte Stage-Test kompiliert und startet den True-Fraction-Probe auch bei übersprungener Vorgängerkette.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; dies war ausschließlich eine Mojo-Typgrenze im neuen nativen Teilerpfad.
- Mojo-Orte: `src/reta_mojo/prompt_table_execution.mojo`, `tests/test_prompt_fraction_integer_axes_source.py`, `tests/test_stage12c5bj_source.py`, `scripts/test_stage12c5bj.sh`
- Belege: `STAGE12C5BJ_PINNED_COMMAND_PARITY_ASSETS.md`, `src/reta_mojo/prompt_table_execution.mojo`, `tests/test_stage12c5bj_source.py`, `scripts/test_stage12c5bj.sh`

### MOJO-FIXED-062 – Projizierte Bruch-Ganzzeilen aktivierten klassische Ganzzahlfamilien beziehungsweise erzwangen Mehrdomänen-Fallback

- Ursprung: `mojo_port`
- Klasse / Schwere: `projected_integer_guard_confusion` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bk/12c5bl`
- Reproduktion: `mond universum v2/3 und mond universum motive v2/3 über den nativen Promptplaner ausführen; zuvor entstand im Einzeldomänenfall eine falsche Mondinvokation beziehungsweise im Mehrdomänenfall FALLBACK.`
- heutiger Vertrag: Der Planer trennt explizite gewöhnliche Ganzzahlsyntax von ganzzahligen Zeilen, die erst aus einem echten n/m-Rechteck projiziert werden. Ohne explizite Achse bleiben mond, richtung, primzahlkreuz, alles und thomas inert. Mit expliziter Achse werden sie seit Stage 12c5bl in der historisch belegten Präfix-/Suffixfolge um die korrigierten physischen Domänen komponiert.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; die eingefrorene Referenz besitzt die richtige bedingungZahl-Grenze, stürzt jedoch zuvor im separaten echten-Bruchvielfachenfehler ab.
- Python-Orte: `python_reference/reta_architecture/prompt_execution.py:561`, `python_reference/reta_architecture/prompt_execution.py:1400`
- Mojo-Orte: `src/reta_mojo/prompt_table_execution.mojo`, `tests/test_prompt_table_execution.mojo`, `scripts/prompt_classic_fraction_guard_reference.py`, `scripts/check_prompt_true_fraction_multiples.py`
- Belege: `STAGE12C5BK_HERMETIC_PARITY_CLASSIC_FRACTION_GUARDS.md`, `tests/test_stage12c5bk_source.py`, `tests/test_prompt_table_execution.mojo`, `scripts/prompt_classic_fraction_guard_reference.py`, `STAGE12C5BL_CLASSIC_INTEGER_MULTI_DOMAIN_COMPOSITION.md`

### TEST-FIXED-055 – Native Kommando-Parität erbte installierte Ressourcenpfade aus der Entwickler-Shell

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `ambient_resource_path_parity_contamination` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bj/12c5bk`
- Reproduktion: `scripts/test_stage12c5bj.sh mit gesetztem RETA_SHARE_DIR oder RETA_DATA_DIR auf einen installierten beziehungsweise älteren Datenbestand ausführen; zwei Shell-Paritätsfälle meldeten abweichende Längen, obwohl dasselbe Binary mit den Repository-Ressourcen 4/4 Fälle erfüllt.`
- heutiger Vertrag: Der native Paritätsprüfer entfernt RETA_SHARE_DIR und setzt RETA_ROOT, RETA_REFERENCE_DIR, RETA_DATA_DIR sowie RETA_ASSET_DIR zwingend auf den aktuellen Source-Tree. Die Stage startet den Prüfer absichtlich mit ungültigen Fremdpfaden. Echte Differenzen melden zusätzlich die erste abweichende Zeichenposition.
- spätere Python-Aktion: Keine Python- oder Mojo-Produktionsänderung erforderlich; betroffen war ausschließlich die Hermetik des Laufzeit-Paritätsprüfers.
- Mojo-Orte: `scripts/check_command_parity_native.py`, `scripts/test_stage12c5bk.sh`, `tests/test_command_parity_environment.py`, `tests/test_stage12c5bk_source.py`
- Belege: `STAGE12C5BK_HERMETIC_PARITY_CLASSIC_FRACTION_GUARDS.md`, `scripts/check_command_parity_native.py`, `scripts/test_stage12c5bk.sh`, `tests/test_command_parity_environment.py`

### MOJO-FIXED-063 – Bruchteilerpfad verlor die äußere Zeile-1-Sentinel vor nichttrivialen Divisoren

- Ursprung: `mojo_port`
- Klasse / Schwere: `outer_divider_one_sentinel_omission` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bi/12c5bk`
- Reproduktion: `test_true_fraction_multiples_follow_each_csv_rectangle mit universum v2/3,5 teiler ausführen; der korrigierte Bruchplan enthielt 2,1,4,6,3,5,v5 statt 2,1,4,6,3,1,5,v5.`
- heutiger Vertrag: Sobald im Bruchteilerzweig mindestens ein positiver gewöhnlicher Wert überlebt, wird Zeile 1 vor der nichttrivialen Divisorreihenfolge wieder eingefügt. Der Spezialfall Wert 1 wird nicht dupliziert. Null- und reine Ausschlussachsen erzeugen keine künstliche 1.
- spätere Python-Aktion: Keine Änderung der eingefrorenen Python-Grammatik erforderlich. Bei einer späteren Korrektur des inneren Python-Bruchrechtecks muss diese äußere Zeile-1-/Divisor-/Rohwert-/v-Reihenfolge erhalten bleiben.
- Python-Orte: `python_reference/reta_architecture/prompt_execution.py:1823`, `python_reference/reta_architecture/prompt_execution.py:1864`
- Mojo-Orte: `src/reta_mojo/prompt_table_execution.mojo`, `tests/test_prompt_table_execution.mojo`, `tests/prompt_true_fraction_multiple_probe.mojo`, `scripts/check_prompt_true_fraction_multiples.py`, `tests/test_prompt_fraction_integer_axes_source.py`
- Belege: `STAGE12C5BK_HERMETIC_PARITY_CLASSIC_FRACTION_GUARDS.md`, `tests/test_prompt_table_execution.mojo`, `scripts/check_prompt_true_fraction_multiples.py`, `tests/test_stage12c5bk_source.py`

### TEST-FIXED-056 – Gesamter Testbestand wurde trotz unveränderter transitiver Abhängigkeiten immer neu kompiliert

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `missing_incremental_dependency_fingerprints` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bh/12c5bk`
- Reproduktion: `scripts/test_all.sh zweimal unmittelbar nacheinander ausführen; build-tests.sh kompilierte zuvor sämtliche ausgewählten Testprogramme erneut, obwohl Quellen, Compiler, Linkprofil und Buildoptionen unverändert waren.`
- heutiger Vertrag: Jedes Testbinary besitzt einen konservativen SHA-256-Buildfingerabdruck aus Testquelle, transitiv importierten lokalen Mojo-Modulen, Compileridentität und -version, Zielplattform, Buildoptionen, ausgewählten buildrelevanten Umgebungswerten und Linkprofil. Nur bei identischem Fingerabdruck und gültigem ELF wird wiederverwendet. Ein fehlender oder nicht auflösbarer lokaler Import verändert den Fingerabdruck; --rebuild-all erzwingt den Vollbuild. Das globale Manifest bleibt während eines Builds entfernt und wird erst nach vollständigem Erfolg atomar veröffentlicht.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; dies ist eine konservative Testbuild-Optimierung außerhalb der Programmlogik.
- Mojo-Orte: `scripts/build-tests.sh`, `scripts/test_all.sh`, `scripts/current_test_source_id.sh`, `tools/mojo_test_build_fingerprint.py`, `tests/test_incremental_test_build.py`, `tests/test_split_test_pipeline.py`
- Belege: `STAGE12C5BK_HERMETIC_PARITY_CLASSIC_FRACTION_GUARDS.md`, `tools/mojo_test_build_fingerprint.py`, `tests/test_incremental_test_build.py`, `scripts/build-tests.sh`

### TEST-FIXED-057 – Nichtwerfender Tabellenruntime-Accessor verwendete werfenden Dict-Indexzugriff

- Ursprung: `mojo_port`
- Klasse / Schwere: `non_raising_dict_lookup_compile_failure` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bj/12c5bk`
- Reproduktion: `scripts/test_all.sh --heavy --run-jobs 4 -- -j 4 ausführen; tests/test_table_runtime_complete.mojo brach beim Kompilieren ab, weil hoechsteZeile ohne raises self.state.highest_rows[114] beziehungsweise [1024] aufrief.`
- heutiger Vertrag: Der öffentliche nichtwerfende Accessor verwendet Dict.get mit den historischen Standardwerten 163 für Schlüssel 114 und 1024 für Schlüssel 1024. Die normalen Factorypfade installieren beide Schlüssel weiterhin explizit; auch manuell rekonstruierte Zustände können den Accessor nun ohne DictKeyError-Typgrenze verwenden.
- spätere Python-Aktion: Keine Python-Änderung erforderlich; betroffen war die Mojo-Fehlerwirkung des Dict-Zugriffs.
- Mojo-Orte: `src/reta_mojo/table_runtime.mojo`, `tests/test_table_runtime_complete.mojo`, `tests/test_table_runtime_complete_source.py`, `scripts/test_stage12c5bk.sh`
- Belege: `STAGE12C5BK_HERMETIC_PARITY_CLASSIC_FRACTION_GUARDS.md`, `src/reta_mojo/table_runtime.mojo`, `tests/test_table_runtime_complete_source.py`, `scripts/test_stage12c5bk.sh`

### MOJO-FIXED-064 – Klassische Ganzzahltabellen mit expliziter Achse und mehreren Bruchdomänen blieben atomarer Fallback

- Ursprung: `mojo_port`
- Klasse / Schwere: `classic_integer_multi_domain_fraction_composition_gap` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bf/12c5bl`
- Reproduktion: `mond universum motive v2/3,5 oder die vollständige Kombination mond richtung primzahlkreuz alles thomas universum motive v2/3,5 über plan_prompt_table_commands ausführen; der native Planer lieferte zuvor FALLBACK, obwohl die äußere Python-Aufrufordnung stabil beobachtbar ist.`
- heutiger Vertrag: Thomas läuft vor den korrigierten physischen Bruchdomänen; danach folgen Mond, Alles, Primzahlkreuz und Richtung. Die gemeinsame klassische Ganzzahlachse verwendet die geordnete Vereinigung aller domänenspezifischen Ganzprojektionen und hängt die originale Ganzzahlsyntax genau einmal an. Primzahlkreuz übernimmt nur die originale Vielfachenachse und --oberesmaximum=1029; im Teilerzweig entfällt --vielfachevonzahlen.
- spätere Python-Aktion: Keine Änderung der eingefrorenen äußeren Python-Steuerung erforderlich. Bei einer späteren Reparatur ihres inneren n/m-Rechtecks muss die belegte Thomas-Präfix-/Vierfach-Suffixordnung erhalten bleiben; die domänenspezifische Projektion soll der nativen korrigierten Vereinigung folgen.
- Python-Orte: `python_reference/reta_architecture/prompt_execution.py:591`, `python_reference/reta_architecture/prompt_execution.py:618`, `python_reference/reta_architecture/prompt_execution.py:1528`
- Mojo-Orte: `src/reta_mojo/prompt_table_execution.mojo`, `tests/test_prompt_table_execution.mojo`, `tests/prompt_true_fraction_multiple_probe.mojo`, `scripts/check_prompt_true_fraction_multiples.py`, `scripts/check_prompt_classic_fraction_composition.py`
- Belege: `STAGE12C5BL_CLASSIC_INTEGER_MULTI_DOMAIN_COMPOSITION.md`, `scripts/check_prompt_classic_fraction_composition.py`, `tests/test_stage12c5bl_source.py`, `tests/test_prompt_table_execution.mojo`

### TEST-FIXED-058 – Native Kommando-Parität erbte die Breite des interaktiven stdin-Terminals

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `ambient_tty_geometry_parity_contamination` / `high`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bk/12c5bl`
- Reproduktion: `scripts/test_stage12c5bk.sh aus einem breiten Terminal ausführen; capture_output trennte stdout und stderr, stdin blieb jedoch ein TTY. terminal_columns fragte nach stdout auch stdin per TIOCGWINSZ ab und ordnete mehrere 40-Zeichen-Spalten nebeneinander an, sodass die Shell-Fälle 2830 statt 1990 beziehungsweise 3570 statt 2804 Zeichen lieferten.`
- heutiger Vertrag: Der Paritätsrunner startet das native Binary mit stdin=subprocess.DEVNULL und fester COLUMNS=80/LINES=24-Umgebung. stdout und stderr bleiben Pipes. Damit können weder TIOCGWINSZ auf dem aufrufenden Terminal noch geerbte Spaltenwerte die Seitenaufteilung verändern; ein 180-Spalten-Pseudoterminal reproduziert nun dieselben 4/4 kanonischen Fälle wie ein nichtinteraktiver Lauf.
- spätere Python-Aktion: Keine Python- oder Mojo-Produktionsänderung erforderlich. Dies war eine fehlende Prozess-/TTY-Isolation im Laufzeit-Paritätsprüfer.
- Mojo-Orte: `scripts/check_command_parity_native.py`, `scripts/test_stage12c5bl.sh`, `tests/test_command_parity_environment.py`, `tests/test_stage12c5bl_source.py`
- Belege: `STAGE12C5BL_CLASSIC_INTEGER_MULTI_DOMAIN_COMPOSITION.md`, `scripts/check_command_parity_native.py`, `tests/test_command_parity_environment.py`, `tests/test_stage12c5bl_source.py`

### TEST-FIXED-059 – Positive-First-Bruchprobe wertete gerenderten Python-stdout statt Executor-argv aus

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `rendered_reference_stdout_contract_leak` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bl/12c5bm`
- Reproduktion: `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bl.sh ausführen; die Prüfung brach bei 'universum v1/4,-2/3' mit expected exactly one reta invocation ab, obwohl der native Probeplan und die Referenzsemantik unverändert waren.`
- heutiger Vertrag: Die Referenzprüfung ersetzt retaExecuteNprint und serialisiert die exakten argv-Aufrufe. Sie fordert genau einen gesammelten Reziprokaufruf und prüft dessen Zeilen- und Spaltenoptionen direkt; lokalisierte Ankündigungen, Terminalbreite und gerenderte Tabellen sind nicht mehr Teil dieses Planvertrags.
- spätere Python-Aktion: Keine Produktionsänderung erforderlich. Der Fehler lag ausschließlich in der Beobachtungsschicht des Referenztests.
- Python-Orte: `python_reference/reta_architecture/prompt_execution.py`
- Mojo-Orte: `scripts/check_prompt_true_fraction_multiples.py`, `scripts/prompt_mixed_reciprocal_reference.py`, `tests/test_prompt_multi_domain_extensions_source.py`
- Belege: `STAGE12C5BM_MULTI_DOMAIN_PROPERTY_NUMERIC_AXES.md`, `scripts/check_prompt_true_fraction_multiples.py`, `tests/test_prompt_multi_domain_extensions_source.py`

### TEST-FIXED-060 – True-Fraction-Laufzeittest erwartete historische Echo-Großschreibung statt kanonischen Parameter

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `case_sensitive_canonical_option_assertion_mismatch` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bl/12c5bm`
- Reproduktion: `test_prompt_table_execution.mojo ausführen; test_true_fraction_multiples_follow_each_csv_rectangle scheiterte bei emotion v1/4,-2/3 an Zeile 793, weil die Assertion --Grundstrukturen=emotion verlangte, während der kanonische native Plan wie alle übrigen Tabellenpläne --grundstrukturen=emotion verwendet.`
- heutiger Vertrag: Laufzeitverträge prüfen die kanonische native Option --grundstrukturen=emotion mit kleinem g. Die historische Großschreibung bleibt ausschließlich in Echo-/Fixture-Verträgen erhalten und wird nicht mit dem typisierten Planargument vermischt.
- spätere Python-Aktion: Keine Produktionsänderung erforderlich. Die fehlerhafte Groß-/Kleinschreibung lag ausschließlich in einer neu ergänzten Assertion.
- Mojo-Orte: `tests/test_prompt_table_execution.mojo`, `src/reta_mojo/prompt_table_execution.mojo`, `tests/test_prompt_multi_domain_extensions_source.py`
- Belege: `STAGE12C5BM_MULTI_DOMAIN_PROPERTY_NUMERIC_AXES.md`, `tests/test_prompt_table_execution.mojo`, `tests/test_prompt_multi_domain_extensions_source.py`

### MOJO-FIXED-065 – Mehrdomänen-Bruchpläne mit EIGN/EIGR oder numerischen 15/16-Katalogachsen fielen atomar zurück

- Ursprung: `mojo_port`
- Klasse / Schwere: `multi_domain_fraction_property_numeric_composition_gap` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bf/12c5bm`
- Reproduktion: `motive EIGNgut universum v2/3 oder motive universum 15_13 16_2 v2/3,5 über plan_prompt_table_commands ausführen; der native Mehrdomänenzweig lieferte zuvor FALLBACK, obwohl die unabhängige Zweigreihenfolge und die bereits typisierten Eigenschafts-/Katalogaufrufe feststanden.`
- heutiger Vertrag: Jede physische Bruchfamilie behält ihr eigenes korrigiertes CSV-Rechteck. EIGN/EIGR verwenden die geordnete Vereinigung der domänenspezifischen Ganzzahl- und Reziprokprojektionen und stehen zwischen Motive und Universum. Numerische Familie 16 folgt nach allen physischen Blöcken vor Familie 15. Eine explizite gewöhnliche Achse wird genau einmal angehängt und projizierte Ganzzahlen werden nicht erneut vervielfacht.
- spätere Python-Aktion: Bei einer späteren Reparatur des Python-n/m-Rechtecks soll die unabhängige Zweigreihenfolge Motive – Eigenschaften – Universum – 16 – 15 erhalten bleiben. Die kombinierte Reihenfolge mit klassischen Ganzzahlfamilien bleibt bis zu einem eigenen Beleg atomar.
- Python-Orte: `python_reference/reta_architecture/prompt_execution.py`
- Mojo-Orte: `src/reta_mojo/prompt_table_execution.mojo`, `src/reta_mojo/prompt_property_execution.mojo`, `tests/test_prompt_table_execution.mojo`, `tests/prompt_true_fraction_multiple_probe.mojo`, `scripts/check_prompt_true_fraction_multiples.py`
- Belege: `STAGE12C5BM_MULTI_DOMAIN_PROPERTY_NUMERIC_AXES.md`, `tests/test_prompt_multi_domain_extensions_source.py`, `tests/test_prompt_table_execution.mojo`, `scripts/check_prompt_true_fraction_multiples.py`

### MOJO-FIXED-066 – Kombinierte klassische, Eigenschafts- und Katalogachsen fielen bei Mehrdomänen-Brüchen atomar zurück

- Ursprung: `mojo_port`
- Klasse / Schwere: `combined_multi_domain_outer_axis_gate` / `high`
- Python-Status: `correct_reference`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bm/12c5bn`
- Reproduktion: `mond richtung primzahlkreuz alles thomas motive EIGNgut universum 15_13 16_2 v2/3,5 über plan_prompt_table_commands ausführen; der Planer gab trotz bereits vorhandener vollständiger Außenordnung FALLBACK zurück, sobald klassische Familien und Eigenschafts- oder Katalogachsen gemeinsam vorkamen.`
- heutiger Vertrag: Mehrere physische Bruchdomänen behalten ihre korrigierten unabhängigen Rechtecke. Die gemeinsame Außenordnung lautet Thomas, physische Emotion/Größe/Motive, EIGN vor EIGR, Universum, Mond/Alles/Primzahlkreuz/Richtung, numerische Familie 16 und Familie 15. Alle äußeren Ganzzahlachsen verwenden dieselbe geordnet deduplizierte Projektion; Primzahlkreuz übernimmt nur die explizite Vielfachenachse und sein Maximum 1029.
- spätere Python-Aktion: Bei einer späteren Reparatur des Python-n/m-Rechtecks ist die unabhängig instrumentierte Außenordnung beizubehalten. Das defekte gemeinsame Python-Rechteck darf nicht als Soll für die nativen physischen Domänen übernommen werden.
- Python-Orte: `python_reference/reta_architecture/prompt_execution.py`
- Mojo-Orte: `src/reta_mojo/prompt_table_execution.mojo`, `tests/test_prompt_table_execution.mojo`, `tests/prompt_true_fraction_multiple_probe.mojo`, `scripts/check_prompt_true_fraction_multiples.py`
- Belege: `STAGE12C5BN_COMBINED_OUTER_AXES.md`, `scripts/check_prompt_combined_outer_order_reference.py`, `tests/test_prompt_combined_outer_order_source.py`, `tests/test_prompt_table_execution.mojo`

### TEST-FIXED-061 – Native Emotion-Reziprokprobe verlangte die historische statt der kanonischen Optionsschreibweise

- Ursprung: `test_infrastructure`
- Klasse / Schwere: `native_probe_option_case_mismatch` / `medium`
- Python-Status: `not_applicable`
- Mojo-Status: `fixed`
- entdeckt in: `12c5bm/12c5bo`
- Reproduktion: `RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bm.sh -- -j 4 ausführen; nach erfolgreicher Kompilierung brach scripts/check_prompt_true_fraction_multiples.py bei emotion v1/4,-2/3 mit emotion positive-first reciprocal axis is missing ab.`
- heutiger Vertrag: Die instrumentierte Python-Referenz darf weiterhin das historische argv --Grundstrukturen=emotion liefern. Der typisierte native Tabellenplan verwendet dagegen kanonisch --grundstrukturen=emotion. Der Laufzeitprüfer bindet beide Schreibweisen in getrennten Blöcken und prüft die native Emotionsspaltenachse 4,5 gegen die Kleinbuchstabenoption.
- spätere Python-Aktion: Keine Python- oder Mojo-Produktionsänderung erforderlich. Der Fehler lag ausschließlich in einer case-sensitiven Assertion des Python-Laufzeitprüfers.
- Mojo-Orte: `scripts/check_prompt_true_fraction_multiples.py`, `scripts/test_stage12c5bo.sh`, `tests/test_prompt_positive_first_fraction_multiple_source.py`, `tests/test_stage12c5bo_source.py`
- Belege: `STAGE12C5BO_CANONICAL_EMOTION_OPTION_CHECK.md`, `scripts/check_prompt_true_fraction_multiples.py`, `tests/test_prompt_positive_first_fraction_multiple_source.py`, `tests/test_stage12c5bo_source.py`
