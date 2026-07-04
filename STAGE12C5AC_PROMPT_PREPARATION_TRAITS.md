# Stage 12c5ac – Prompt-Preparation-Fassade und Mojo-Testtraits

## Ausgangslage

Der lokale Modular-Build bestätigte die Shared-Diagnostics-Parität vollständig
und die korrigierte Legacy-Prepare-Fassade mit 5/5 nativen Tests. Der folgende
Test von `LibRetaPrompt` scheiterte jedoch bereits beim Parsen:

```text
no matching function in call to 'assert_equal'
List[LegacyPromptMapEntry] ... does not conform to Equatable & Writable
```

## Korrektur des Werttyps

`LegacyPromptMapEntry` war bereits `Equatable`, aber nicht `Writable`.
`std.testing.assert_equal` benötigt für `List[T]` beide Elementtraits, damit es
bei einer Abweichung die Listenwerte ausgeben kann. Der Typ implementiert nun
`Writable.write_to`; der fachliche Vergleich bleibt unverändert bei
`key == key && value == value`.

Der Test bleibt bewusst als Listenvergleich erhalten. Eine elementweise
Sonderlösung im Test hätte die fehlende allgemeine Werttypeigenschaft nur
verdeckt.

## Tatsächliche Entfernung des alten Buildskripts

Im hochgeladenen Projektstand war `scripts/test_stage12c5z.sh` weiterhin als
zweite produktiv bauende Kopie vorhanden. Es wurde entfernt. Der einzige
bewusst bauende tiefe Shared-Diagnostics-Vergleich ist weiterhin:

```text
scripts/build-and-test-shared-diagnostics.sh
```

## Vollständiger nativer Besitzer von prompt_preparation.py

`src/reta_mojo/prompt_preparation.mojo` bildet jetzt zusätzlich zur bereits
produktiven Algorithmik auch die historische Fassadenoberfläche ab:

- `configure_prompt_preparation`
- `bootstrap_prompt_preparation`
- `verdreheWoReTaBefehl`
- `regExReplace`
- `promptVorbereitungGrosseAusgabe`
- `PromptPreparationBundle.prepare_grosse_ausgabe`
- `PromptPreparationLegacySnapshot`

Die vier veränderlichen Python-Caches `zeilen`, `spalten`, `ausgabe` und
`kombination` werden nativ nicht benötigt: Mojo lädt den vollständigen
unveränderlichen Domänenkatalog einmal typisiert. Der Legacy-Snapshot meldet
für die entfernten Lazy-Caches daher wie ein frischer Python-Bootstrap jeweils
null; der produktive Snapshot enthält zusätzlich die tatsächlich geladenen
114 deutschen Domänen.

Rotation, kompakte Befehle, Bereichsumformung, Teiler/Vielfache und
Regex-/Wildcard-Erweiterung bleiben in den bestehenden nativen Besitzern. Die
Legacy-Namen sind dünne typisierte Weiterleitungen und duplizieren keine
Algorithmen.

## Parität und Buildbesitz

Der neue Snapshot-Vergleich prüft Deutsch, Englisch, Vietnamesisch, Chinesisch
und Koreanisch gegen jeweils einen frischen Python-Prozess. Das Stage-Skript
kompiliert außerdem zuerst exakt `tests/test_legacy_libreta_prompt.mojo`, also
die zuvor am fehlenden `Writable`-Trait gescheiterte Listenassertion. Es entsteht
keine installierbare Diagnose-Executable; alle Probeprogramme liegen
ausschließlich unter `target/tests`.

Lokale Prüfung mit Modular Mojo:

```bash
scripts/test_stage12c5ac.sh
```

Der vollständige Produktionsbuild bleibt unverändert:

```bash
scripts/build-all.sh
```
## Compilerunabhängige Prüfung

```text
portable Source-Tests:          161 bestanden, 1 Skip
fokussierte Infrastruktur:      39/39 bestanden
Source-Archivvertrag:            3/3 bestanden
relative Mojo-Importe:           282/282 auflösbar
Manifestdateien:                 1.406
Defektkatalog:                   104 Einträge, konsistent
```

Der eine Skip ist weiterhin ausschließlich compilerabhängig. Die native
Kompilierung des geänderten Testwerttyps und der Legacy-Prompt-Fassade ist in
`scripts/test_stage12c5ac.sh` vorbereitet und muss mit dem lokalen Modular-Mojo-Compiler ausgeführt werden.

