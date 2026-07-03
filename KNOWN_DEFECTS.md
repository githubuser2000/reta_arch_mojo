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
- geprüfte Quellen: **23**
- Reichweite: Vollständig bezogen auf alle bis Stage 12c5g im Projekt bestätigten oder plausibel begründeten verhaltensrelevanten Befunde; unbekannte künftige Fehler können naturgemäß erst nach ihrer Entdeckung aufgenommen werden.

## Übersicht

- Einträge insgesamt: **92**
- offene bestätigte Python-Fehler: **5**
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
