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
- geprüfte Quellen: **14**
- Reichweite: Vollständig bezogen auf alle bis Stage 12c4v im Projekt bestätigten oder plausibel begründeten verhaltensrelevanten Befunde; unbekannte künftige Fehler können naturgemäß erst nach ihrer Entdeckung aufgenommen werden.

## Übersicht

- Einträge insgesamt: **42**
- offene bestätigte Python-Fehler: **5**
- zu entscheidende Python-Fehlerkandidaten: **7**
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

### PY-CAND-007 – Standard-Wortgrenze der Promptvervollständigung trennt ASCII und Unicode innerhalb deutscher Wörter

- Ursprung: `python_reference`
- Klasse / Schwere: `completion_unicode_segmentation` / `medium`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- entdeckt in: `12c4t`
- Reproduktion: `python3 -c "from reta_architecture.completion_word import *; d=Document('grö'); print(repr(word_before_cursor(d))); print([x.text for x in iter_word_completions(['größe'], d)])"`
- heutiger Vertrag: Mojo reproduziert vorerst prompt_toolkits ASCII-/Nicht-ASCII-Klassengrenze und damit den beobachtbaren Python-Istzustand; UTF-8-Cursor und negative Startpositionen bleiben dennoch codepunktkorrekt.
- spätere Python-Aktion: Für den Python-WordCompleter eine explizite Unicode-Wortgrenze verwenden, neue Soll-Fixtures für deutsche und weitere Unicode-Wörter anlegen und Python sowie Mojo anschließend gemeinsam auf das korrigierte Verhalten umstellen.
- Python-Orte: `python_reference/reta_architecture/completion_word.py:82-94`
- Mojo-Orte: `src/reta_mojo/completion_word.mojo`
- Belege: `STAGE12C4T_NATIVE_WORD_COMPLETION.md`, `tests/test_documented_python_defects.py`, `scripts/check_completion_word_parity.py`

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
- heutiger Vertrag: Die Datei ist entfernt; Source-Gates verlangen null prompt_python_bridge-Dateien und null aktive std.python-Importe.
- spätere Python-Aktion: Keine Python-Änderung erforderlich.
- Mojo-Orte: `src/reta_mojo/prompt_python_bridge.mojo`
- Belege: `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`, `tests/test_prompt_external_source.py`

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
