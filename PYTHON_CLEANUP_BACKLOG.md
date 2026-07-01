# Python-/PyPy3-Bereinigungsrückstand nach der Transpilierung

Diese Datei wird aus `KNOWN_DEFECTS.json` erzeugt. Sie ist die gezielte
Arbeitsliste für die Phase nach dem vollständigen Mojo-Port.

## Vorgehen

1. Den dokumentierten Istzustand mit dem Reproduktionsbefehl bestätigen.
2. Einen eigenständigen korrigierten Solltest anlegen.
3. Den Python-/PyPy3-Code korrigieren, ohne den Mojo-Vertrag zu verschlechtern.
4. Python und Mojo gegen denselben korrigierten Sollvertrag prüfen.
5. Den Eintrag in `KNOWN_DEFECTS.json` auf `fixed` setzen.

Offene oder zu entscheidende Einträge: **12**

## 1. PY-OPEN-001 – Beliebige Codeausführung durch eval in Ganzzahlmengen-Ausdrücken

- Priorität: `high`
- Python-Status: `open`
- Mojo-Status: `fixed`
- Reproduktion: `reta -zeilen --vorhervonausschnitt=[__import__('os').system('true')] -spalten --religionen=sternpolygon`
- heutiger Vertrag: Mojo besitzt nur einen endlichen Ganzzahlparser; beliebiger Python-Code fällt atomar auf die eingefrorene Referenz zurück.
- Python-Arbeitsauftrag: Beide eval-Aufrufe im Python-Code durch denselben beschränkten AST-/Ganzzahlparser ersetzen und gefährliche Formen vollständig ablehnen.
- Python-Orte: `python_reference/reta_architecture/row_ranges.py:37`, `python_reference/reta_architecture/prompt_language.py:121`
- Belege: `STAGE12C4P_NATIVE_INTEGER_EXPRESSIONS.md`, `tests/test_integer_expression_parity.py`

## 2. PY-OPEN-002 – Prompt-Absturz bei echten Bruchvielfachen v n/m

- Priorität: `high`
- Python-Status: `open`
- Mojo-Status: `fixed`
- Reproduktion: `rpb 'universum v2/3'`
- heutiger Vertrag: Mojo erweitert Zähler- und Nennerachsen innerhalb der real vorhandenen Bruch-CSV-Form, erzeugt Ganzzahl-/Reziprokprojektionen und stürzt nicht ab.
- Python-Arbeitsauftrag: Leere zahlenReiheKeineWteiler sicher behandeln und die Bruchvielfachen-Expansion anhand der tatsächlichen Domänenform statt des globalen Zahlenvorrats aufbauen.
- Python-Orte: `python_reference/reta_architecture/prompt_execution.py:1841`
- Belege: `STAGE12C4R_DEFECT_LEDGER_FRACTION_MULTIPLES.md`, `tests/test_prompt_table_execution.mojo`, `scripts/check_prompt_true_fraction_multiples.py`

## 3. PY-CAND-001 – Prompt-Ausgabereihenfolge hängt von Python-set und PYTHONHASHSEED ab

- Priorität: `medium`
- Python-Status: `candidate`
- Mojo-Status: `fixed`
- Reproduktion: `Prompt-Kommandos mit mehreren numerischen Komponenten unter verschiedenen PYTHONHASHSEED-Werten`
- heutiger Vertrag: Mojo reproduziert die bisherige CPython-Reihenfolge für PYTHONHASHSEED=0 deterministisch und plattformunabhängig.
- Python-Arbeitsauftrag: Eine fachlich definierte Reihenfolge festlegen und Python-set-Iteration aus sichtbaren Tokenströmen entfernen; dabei bewusst neue Soll-Fixtures erzeugen.
- Python-Orte: `python_reference/reta_architecture/prompt_preparation.py`, `python_reference/reta_architecture/prompt_execution.py`
- Belege: `STAGE10F_NATIVE_COMPACT_PROMPT.md`, `STAGE10I_NATIVE_NUMERIC_SELECTORS.md`

## 4. PY-CAND-002 – CSV ohne Nummerierung behält zwei leere Strukturfelder

- Priorität: `low`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- Reproduktion: `reta -zeilen --vorhervonausschnitt=1 -spalten --religionen=sternpolygon -ausgabe --art=csv --keinenummerierung`
- heutiger Vertrag: Mojo gibt aus Kompatibilitätsgründen weiterhin die führenden Bytes ;; aus.
- Python-Arbeitsauftrag: Entscheiden, ob --keinenummerierung die beiden CSV-Spalten wirklich entfernen soll; bei Bejahung Python und Mojo gemeinsam auf ein neues Format umstellen.
- Python-Orte: `python_reference/reta_architecture/table_output.py`
- Belege: `STAGE12C4O_NATIVE_FLAT_COLUMN_WIDTHS.md`

## 5. PY-CAND-003 – Reziproke Teilerselektion serialisiert leere Komponenten und historische Leerseiten

- Priorität: `low`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- Reproduktion: `Prompt: universum teiler 1/2`
- heutiger Vertrag: Mojo erhält den beobachtbaren Selektor mit nachlaufender leerer Komponente, damit die aktuelle Ausgabe bytegleich bleibt.
- Python-Arbeitsauftrag: Leere Selektorkomponenten aus dem Promptvertrag entfernen und die gewünschte Teilersemantik explizit testen.
- Python-Orte: `python_reference/reta_architecture/prompt_execution.py`
- Belege: `STAGE12C4C_NATIVE_MIXED_RECIPROCAL_MODIFIERS.md`

## 6. QUIRK-001 – Nullbreiten besitzen formatabhängige historische Sondersemantik

- Priorität: `low`
- Python-Status: `intentional_for_now`
- Mojo-Status: `compatibility_preserved`
- Reproduktion: `reta ... -ausgabe --breiten=0,8`
- heutiger Vertrag: Mojo reproduziert Shell-Seitenauslassung sowie rohe Markup-Umbruchmessung bytegenau.
- Python-Arbeitsauftrag: Erst nach der Transpilierung entscheiden, ob die Oberfläche vereinheitlicht werden soll; bis dahin kein Fehlerstatus.
- Python-Orte: `python_reference/reta_architecture/table_wrapping.py`, `python_reference/reta_architecture/table_output.py`
- Belege: `STAGE12C4K_NATIVE_ZERO_COLUMN_WIDTHS.md`

## 7. PY-OPEN-003 – Dictionary-Invertierung verwirft frühere Quellschlüssel bei gemeinsamem Integerwert

- Priorität: `medium`
- Python-Status: `open`
- Mojo-Status: `fixed`
- Reproduktion: `python3 -c "from reta_architecture.arithmetic import invert_int_value_dict; print(invert_int_value_dict({'a':['1'],'b':['1']}))"`
- heutiger Vertrag: Python liefert für den Integerwert 1 nur den zuletzt besuchten Schlüssel; Mojo bewahrt alle verschiedenen Quellschlüssel typisiert.
- Python-Arbeitsauftrag: In Python bei int_value statt beim ursprünglichen String value auf vorhandene Zielschlüssel prüfen und einen Regressionstest mit zwei Quellschlüsseln für denselben Integerwert ergänzen.
- Python-Orte: `python_reference/reta_architecture/arithmetic.py:126-137`
- Belege: `MIGRATION_NOTES.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`

## 8. PY-CAND-004 – Mondzahl-Erkennung verwendet gerundete Fließkommawurzeln statt exakter Potenzprüfung

- Priorität: `medium`
- Python-Status: `candidate`
- Mojo-Status: `fixed`
- Reproduktion: `Vergleiche moonNumber(n) mit exakter ganzzahliger Potenzprüfung an großen und potenznahen Ganzzahlen.`
- heutiger Vertrag: Mojo akzeptiert eine Basis nur, wenn base**exponent exakt der Eingabe entspricht; Python rundet die Fließkommawurzel auf fünf Nachkommastellen.
- Python-Arbeitsauftrag: Python auf eine begrenzte exakte Integerwurzel-/Potenzprüfung umstellen und zuvor einen Suchtest für falsch positive beziehungsweise negative Rundungsfälle festlegen.
- Python-Orte: `python_reference/reta_architecture/number_theory.py:18-29`
- Belege: `MIGRATION_NOTES.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`

## 9. PY-OPEN-004 – Zwei Python-Architekturtests erwarten veraltete dataDict-Größe 554 statt 556

- Priorität: `medium`
- Python-Status: `open`
- Mojo-Status: `not_applicable`
- Reproduktion: `python3 -m pytest -q python_reference/tests/test_architecture_refactor.py`
- heutiger Vertrag: Die unveränderte Referenz erzeugt 556 Einträge; zwei Tests beziehungsweise mehrere Assertions halten noch 554 fest und schlagen reproduzierbar fehl.
- Python-Arbeitsauftrag: Fachlich prüfen, welche zwei Einträge hinzugekommen sind, dann die erwarteten Snapshotgrößen samt erklärendem Fixture aktualisieren oder die unerwünschten Einträge an der Quelle entfernen.
- Python-Orte: `python_reference/tests/test_architecture_refactor.py:163`, `python_reference/tests/test_architecture_refactor.py:982`, `python_reference/tests/test_architecture_refactor.py:986`
- Belege: `MIGRATION_NOTES.md`, `TEST_RESULTS.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`, `scripts/check_documented_python_baseline.py`

## 10. PY-OPEN-005 – Python-Workflowtest erwartet veralteten Orchestrierungsnamen load_/religion_table

- Priorität: `low`
- Python-Status: `open`
- Mojo-Status: `not_applicable`
- Reproduktion: `python3 -m pytest -q python_reference/tests/test_architecture_refactor.py::ArchitectureRefactorTests::test_program_workflow_layer_is_explicit`
- heutiger Vertrag: Der aktuelle Snapshot enthält load_religion_table; der Test sucht noch den älteren Namen load_/religion_table.
- Python-Arbeitsauftrag: Den fachlich gültigen Orchestrierungsnamen bestätigen und die Testassertion auf den aktuellen stabilen Namen aktualisieren.
- Python-Orte: `python_reference/tests/test_architecture_refactor.py:732-740`
- Belege: `MIGRATION_NOTES.md`, `TEST_RESULTS.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`, `scripts/check_documented_python_baseline.py`

## 11. PY-CAND-005 – Kanonischer Parameteralias hängt bei set-Einträgen von Python-Hashreihenfolge ab

- Priorität: `medium`
- Python-Status: `candidate`
- Mojo-Status: `fixed`
- Reproduktion: `Erzeuge paraDict mit verschiedenen PYTHONHASHSEED-Werten und vergleiche den kanonischen Namen der set-basierten paraNdataMatrix-Einträge.`
- heutiger Vertrag: Der Mojo-Snapshot sortiert ausschließlich ungeordnete Mengen numerisch beziehungsweise lexikographisch; geordnete Tupel bleiben unverändert.
- Python-Arbeitsauftrag: Im Python-Schemabau für set-basierte Aliasgruppen eine fachlich definierte stabile Reihenfolge verwenden und Hash-Seed-Regressionen ergänzen.
- Python-Orte: `python_reference/i18n/words_runtime.py`, `python_reference/reta_architecture/semantics_builder.py`
- Belege: `MIGRATION_NOTES.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`

## 12. PY-CAND-006 – Legacy-Primwiederholungsfunktion mischt Zahlen und Zeichenketten im selben Rückgabewert

- Priorität: `low`
- Python-Status: `candidate`
- Mojo-Status: `fixed`
- Reproduktion: `python3 -c "from reta_architecture.arithmetic import prime_repeat_legacy; print(prime_repeat_legacy([3,2,2,2]))"`
- heutiger Vertrag: Mojo trennt typisierte Primzahl/Anzahl-Paare von der reinen Stringdarstellung; Python behält vorerst die heterogene Legacy-Liste.
- Python-Arbeitsauftrag: Verwendungen auf prime_repeat_pairs beziehungsweise eine explizite Label-Funktion migrieren und die heterogene Legacy-Schnittstelle anschließend deprecaten.
- Python-Orte: `python_reference/reta_architecture/arithmetic.py:65-94`
- Belege: `MIGRATION_NOTES.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`
