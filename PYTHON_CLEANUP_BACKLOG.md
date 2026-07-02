# Python-/PyPy3-Bereinigungsrückstand nach der Transpilierung

Diese Datei wird aus `KNOWN_DEFECTS.json` erzeugt. Sie ist die gezielte
Arbeitsliste für die Phase nach dem vollständigen Mojo-Port.

## Vorgehen

1. Den dokumentierten Istzustand mit dem Reproduktionsbefehl bestätigen.
2. Einen eigenständigen korrigierten Solltest anlegen.
3. Den Python-/PyPy3-Code korrigieren, ohne den Mojo-Vertrag zu verschlechtern.
4. Python und Mojo gegen denselben korrigierten Sollvertrag prüfen.
5. Den Eintrag in `KNOWN_DEFECTS.json` auf `fixed` setzen.

Offene oder zu entscheidende Einträge: **18**

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

## 6. PY-CAND-007 – Standard-Wortgrenze der Promptvervollständigung trennt ASCII und Unicode innerhalb deutscher Wörter

- Priorität: `medium`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- Reproduktion: `python3 -c "from reta_architecture.completion_word import *; d=Document('grö'); print(repr(word_before_cursor(d))); print([x.text for x in iter_word_completions(['größe'], d)])"`
- heutiger Vertrag: Mojo reproduziert vorerst prompt_toolkits ASCII-/Nicht-ASCII-Klassengrenze und damit den beobachtbaren Python-Istzustand; UTF-8-Cursor und negative Startpositionen bleiben dennoch codepunktkorrekt.
- Python-Arbeitsauftrag: Für den Python-WordCompleter eine explizite Unicode-Wortgrenze verwenden, neue Soll-Fixtures für deutsche und weitere Unicode-Wörter anlegen und Python sowie Mojo anschließend gemeinsam auf das korrigierte Verhalten umstellen.
- Python-Orte: `python_reference/reta_architecture/completion_word.py:82-94`
- Belege: `STAGE12C4T_NATIVE_WORD_COMPLETION.md`, `tests/test_documented_python_defects.py`, `scripts/check_completion_word_parity.py`

## 7. QUIRK-001 – Nullbreiten besitzen formatabhängige historische Sondersemantik

- Priorität: `low`
- Python-Status: `intentional_for_now`
- Mojo-Status: `compatibility_preserved`
- Reproduktion: `reta ... -ausgabe --breiten=0,8`
- heutiger Vertrag: Mojo reproduziert Shell-Seitenauslassung sowie rohe Markup-Umbruchmessung bytegenau.
- Python-Arbeitsauftrag: Erst nach der Transpilierung entscheiden, ob die Oberfläche vereinheitlicht werden soll; bis dahin kein Fehlerstatus.
- Python-Orte: `python_reference/reta_architecture/table_wrapping.py`, `python_reference/reta_architecture/table_output.py`
- Belege: `STAGE12C4K_NATIVE_ZERO_COLUMN_WIDTHS.md`

## 8. PY-OPEN-003 – Dictionary-Invertierung verwirft frühere Quellschlüssel bei gemeinsamem Integerwert

- Priorität: `medium`
- Python-Status: `open`
- Mojo-Status: `fixed`
- Reproduktion: `python3 -c "from reta_architecture.arithmetic import invert_int_value_dict; print(invert_int_value_dict({'a':['1'],'b':['1']}))"`
- heutiger Vertrag: Python liefert für den Integerwert 1 nur den zuletzt besuchten Schlüssel; Mojo bewahrt alle verschiedenen Quellschlüssel typisiert.
- Python-Arbeitsauftrag: In Python bei int_value statt beim ursprünglichen String value auf vorhandene Zielschlüssel prüfen und einen Regressionstest mit zwei Quellschlüsseln für denselben Integerwert ergänzen.
- Python-Orte: `python_reference/reta_architecture/arithmetic.py:126-137`
- Belege: `MIGRATION_NOTES.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`

## 9. PY-CAND-004 – Mondzahl-Erkennung verwendet gerundete Fließkommawurzeln statt exakter Potenzprüfung

- Priorität: `medium`
- Python-Status: `candidate`
- Mojo-Status: `fixed`
- Reproduktion: `Vergleiche moonNumber(n) mit exakter ganzzahliger Potenzprüfung an großen und potenznahen Ganzzahlen.`
- heutiger Vertrag: Mojo akzeptiert eine Basis nur, wenn base**exponent exakt der Eingabe entspricht; Python rundet die Fließkommawurzel auf fünf Nachkommastellen.
- Python-Arbeitsauftrag: Python auf eine begrenzte exakte Integerwurzel-/Potenzprüfung umstellen und zuvor einen Suchtest für falsch positive beziehungsweise negative Rundungsfälle festlegen.
- Python-Orte: `python_reference/reta_architecture/number_theory.py:18-29`
- Belege: `MIGRATION_NOTES.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`

## 10. PY-OPEN-004 – Zwei Python-Architekturtests erwarten veraltete dataDict-Größe 554 statt 556

- Priorität: `medium`
- Python-Status: `open`
- Mojo-Status: `not_applicable`
- Reproduktion: `python3 -m pytest -q python_reference/tests/test_architecture_refactor.py`
- heutiger Vertrag: Die unveränderte Referenz erzeugt 556 Einträge; zwei Tests beziehungsweise mehrere Assertions halten noch 554 fest und schlagen reproduzierbar fehl.
- Python-Arbeitsauftrag: Fachlich prüfen, welche zwei Einträge hinzugekommen sind, dann die erwarteten Snapshotgrößen samt erklärendem Fixture aktualisieren oder die unerwünschten Einträge an der Quelle entfernen.
- Python-Orte: `python_reference/tests/test_architecture_refactor.py:163`, `python_reference/tests/test_architecture_refactor.py:982`, `python_reference/tests/test_architecture_refactor.py:986`
- Belege: `MIGRATION_NOTES.md`, `TEST_RESULTS.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`, `scripts/check_documented_python_baseline.py`

## 11. PY-OPEN-005 – Python-Workflowtest erwartet veralteten Orchestrierungsnamen load_/religion_table

- Priorität: `low`
- Python-Status: `open`
- Mojo-Status: `not_applicable`
- Reproduktion: `python3 -m pytest -q python_reference/tests/test_architecture_refactor.py::ArchitectureRefactorTests::test_program_workflow_layer_is_explicit`
- heutiger Vertrag: Der aktuelle Snapshot enthält load_religion_table; der Test sucht noch den älteren Namen load_/religion_table.
- Python-Arbeitsauftrag: Den fachlich gültigen Orchestrierungsnamen bestätigen und die Testassertion auf den aktuellen stabilen Namen aktualisieren.
- Python-Orte: `python_reference/tests/test_architecture_refactor.py:732-740`
- Belege: `MIGRATION_NOTES.md`, `TEST_RESULTS.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`, `scripts/check_documented_python_baseline.py`

## 12. PY-CAND-005 – Kanonischer Parameteralias hängt bei set-Einträgen von Python-Hashreihenfolge ab

- Priorität: `medium`
- Python-Status: `candidate`
- Mojo-Status: `fixed`
- Reproduktion: `Erzeuge paraDict mit verschiedenen PYTHONHASHSEED-Werten und vergleiche den kanonischen Namen der set-basierten paraNdataMatrix-Einträge.`
- heutiger Vertrag: Der Mojo-Snapshot sortiert ausschließlich ungeordnete Mengen numerisch beziehungsweise lexikographisch; geordnete Tupel bleiben unverändert.
- Python-Arbeitsauftrag: Im Python-Schemabau für set-basierte Aliasgruppen eine fachlich definierte stabile Reihenfolge verwenden und Hash-Seed-Regressionen ergänzen.
- Python-Orte: `python_reference/i18n/words_runtime.py`, `python_reference/reta_architecture/semantics_builder.py`
- Belege: `MIGRATION_NOTES.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`

## 13. PY-CAND-006 – Legacy-Primwiederholungsfunktion mischt Zahlen und Zeichenketten im selben Rückgabewert

- Priorität: `low`
- Python-Status: `candidate`
- Mojo-Status: `fixed`
- Reproduktion: `python3 -c "from reta_architecture.arithmetic import prime_repeat_legacy; print(prime_repeat_legacy([3,2,2,2]))"`
- heutiger Vertrag: Mojo trennt typisierte Primzahl/Anzahl-Paare von der reinen Stringdarstellung; Python behält vorerst die heterogene Legacy-Liste.
- Python-Arbeitsauftrag: Verwendungen auf prime_repeat_pairs beziehungsweise eine explizite Label-Funktion migrieren und die heterogene Legacy-Schnittstelle anschließend deprecaten.
- Python-Orte: `python_reference/reta_architecture/arithmetic.py:65-94`
- Belege: `MIGRATION_NOTES.md`, `STAGE12C4S_DEFECT_BACKFILL_NATIVE_CONTROL_MAINS.md`

## 14. PY-CAND-008 – Sprachfehlertext verwendet den falschen Parameter -languages= und wiederholt erlaubte Sprachcodes

- Priorität: `low`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- Reproduktion: `PYTHONHASHSEED=0 python3 -c "import sys; sys.path.insert(0,'python_reference'); import i18n.words_runtime as w; print(w.wrongLangSentence)"`
- heutiger Vertrag: Der native i18n-Baumkatalog konserviert den beobachtbaren Text bytegenau: Er nennt historisch -languages= statt des tatsächlich ausgewerteten -language= und übernimmt die mehrfach vorkommenden Werte en, de, vn, cn und kr aus sprachen.values().
- Python-Arbeitsauftrag: Nach Abschluss der Transpilierung den Text auf -language= umstellen, die erlaubten kanonischen Namen oder Codes dedupliziert und in fachlich definierter Reihenfolge ausgeben und Python sowie Mojo gemeinsam auf neue Soll-Fixtures migrieren.
- Python-Orte: `python_reference/i18n/words_runtime.py:540-543`, `python_reference/reta_architecture/parameter_runtime.py:212`
- Belege: `STAGE12C4X_NATIVE_I18N_WORDS.md`, `tests/test_i18n_words_source.py`, `assets/i18n_words/manifest.json`

## 15. PY-CAND-009 – Obergrenzenhelfer materialisiert hunderte doppelte 1024-Werte und exponiert Mengenreihenfolge

- Priorität: `low`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- Reproduktion: `PYTHONHASHSEED=0 python3 scripts/parameter_runtime_reference.py --vorhervonausschnitt=v2-4`
- heutiger Vertrag: Für v2-4 liefert Python 685 Werte, darunter 682 identische 1024-Einträge, weil zuerst eine Integer-Menge expandiert und danach jeder Wert einzeln auf mindestens 1024 geklemmt wird. Produktiv wird nur das Maximum verwendet. Mojo bewahrt Anwendungsflag, Multiset und resultierende Obergrenze, serialisiert die Werte jedoch deterministisch in der nativen Bereichsparser-Reihenfolge.
- Python-Arbeitsauftrag: Nach Abschluss der Transpilierung den Obergrenzenvertrag auf einen einzelnen Maximalwert oder eine deduplizierte fachlich sortierte Menge reduzieren und Python sowie Mojo gemeinsam auf diesen Sollvertrag migrieren.
- Python-Orte: `python_reference/reta_architecture/parameter_runtime.py:851-872`, `python_reference/reta_architecture/runtime_compat.py:96-107`
- Belege: `STAGE12C4Y_NATIVE_PARAMETER_RUNTIME.md`, `scripts/check_parameter_runtime_parity.sh`, `tests/test_parameter_runtime.mojo`

## 16. PY-CAND-010 – Vollständige --alles-Ausgabe ist ohne festen PYTHONHASHSEED nicht reproduzierbar

- Priorität: `medium`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- Reproduktion: `python reta -spalten --alles --breite=0 -ausgabe --art=html --onetable --nocolor > middle.alx ohne gesetztes PYTHONHASHSEED ausführen und gegen einen zweiten Prozess oder den deterministischen Mojo-Lauf vergleichen.`
- heutiger Vertrag: Die hochgeladene unseeded Referenz besitzt dieselben 198 Tabellenzeilen und 149356 Zellen, permutiert aber 20 Metaspalten und variiert zehn set-basierte Generatorspalten. Das Gate richtet Überschriften vorkommensgenau aus, weist 1850 Hash-Zellen und ihre 214 Abweichungen separat aus und verlangt für den reproduzierbaren Kern 147506/147506 semantisch gleiche Zellen. Mojo bleibt deterministisch.
- Python-Arbeitsauftrag: Nach Abschluss der Transpilierung alle beobachtbaren Mengen- und Frozenset-Iterationen in der Python-Tabellenplanung fachlich sortieren, einen kanonischen PYTHONHASHSEED-unabhängigen Spaltenvertrag festlegen und Python sowie Mojo gegen eine neu erzeugte seed-unabhängige Referenz prüfen.
- Python-Orte: `python_reference/reta_architecture/generated_columns.py:1356-1465`, `python_reference/reta_architecture/column_selection.py`, `python_reference/reta_architecture/table_runtime.py`
- Belege: `STAGE12C4Z_PROFESSIONAL_GENERATE_HTML.md`, `tests/test_full_all_reference_workflow.py`, `FULL_ALL_REFERENCE_WORKFLOW.md`

## 17. PY-CAND-011 – Manifestnormalisierung entfernt führende Punkte und kann Dotfile-Pfade kollidieren lassen

- Priorität: `medium`
- Python-Status: `candidate`
- Mojo-Status: `compatibility_preserved`
- Reproduktion: `In einem temporären Manifestbaum sowohl .hidden als auch hidden mit verschiedenen Inhalten anlegen und RepoManifest.from_tree(root).snapshot(include_files=True) aufrufen; beide Pfade werden durch lstrip('./') als hidden geführt und _manifest_file_entry kann für beide die undotierte Datei lesen.`
- heutiger Vertrag: Der native Manifestbesitzer reproduziert die historische lstrip('./')-Normalisierung und den Dotfile-Fallback absichtlich, damit bestehende Python-Manifeste einschließlich der Kollision bytegleich bleiben. Der dynamische Paritätsbaum enthält .hidden und hidden mit verschiedenen Inhalten.
- Python-Arbeitsauftrag: Nach Abschluss der funktionalen Portierung in Python nur ein tatsächliches Präfix './' entfernen, führende Punkte erhalten, Kollisionen mit einem neuen Solltest ausschließen und die daraus folgende Manifestdigest-Änderung kontrolliert versionieren.
- Python-Orte: `python_reference/reta_architecture/package_integrity.py:91-92`, `python_reference/reta_architecture/package_integrity.py:122-132`
- Belege: `STAGE12C5C_NATIVE_PACKAGE_INTEGRITY_SPLIT_I18N.md`, `scripts/check_package_integrity_parity.py`, `tests/test_package_integrity.mojo`

## 18. PY-CAND-012 – generate4readme ändert vier Bruchparameterlisten mit PYTHONHASHSEED

- Priorität: `medium`
- Python-Status: `candidate`
- Mojo-Status: `fixed`
- Reproduktion: `python_reference/libs/generate4readme.py jeweils mit PYTHONHASHSEED=0 und PYTHONHASHSEED=1 ausführen; die Werte von gebrochengalaxie, gebrochenuniversum, gebrochenemotion und gebrochengroesse erscheinen in unterschiedlicher Reihenfolge.`
- heutiger Vertrag: Die native Ausgabe verwendet vollständige, unter PYTHONHASHSEED=0 erzeugte deutsche und englische Referenzassets. Dadurch ist generate4readme reproduzierbar und für denselben kanonischen Seed byteidentisch, ohne die fachlich sichtbare Reihenfolge nachträglich zu erfinden.
- Python-Arbeitsauftrag: Nach Abschluss der Portierung die vier set-basierten Werte im Python-i18n-Katalog in eine explizit geordnete Struktur überführen oder beim Dokumentgenerator kanonisch sortieren; anschließend den gewählten Sollvertrag versionieren und den Kandidaten auf fixed setzen.
- Python-Orte: `python_reference/libs/generate4readme.py`, `python_reference/i18n/words_matrix.py`
- Belege: `tests/test_readme_generator_source.py`, `tools/generate_readme_assets.py`, `assets/generated_readme_manifest.tsv`
