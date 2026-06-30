# Stage 11b – Native Architekturverträge und Witness-Matrix

## Ziel

Stage 11b überträgt die beiden auf Stage 11a folgenden reinen Metaebenen aus
`reta_architecture` nach Mojo:

- kommutierende Architekturverträge aus `architecture_contracts.py`
- konkrete Repository-Witnesses aus `architecture_witnesses.py`

Die Python-Referenz wird nur noch bei einer expliziten Regeneration ausgewertet.
Die erzeugten Bundles, Suche, Navigation, Statusabfragen und CLI-Ausgaben laufen
anschließend vollständig nativ.

## Native Vertragsdaten

`src/reta_mojo/architecture_contracts.mojo` enthält typisierte Strukturen für:

- Diagrammknoten und Diagrammpfeile
- kommutierende Diagramme
- Kapselverträge
- Refactor-Gesetze
- Referenzvalidierung
- Stage-29-Plan

Der Snapshot umfasst:

```text
33 kommutierende Diagramme
11 Kapselverträge
22 Refactor-Gesetze
11 bekannte Kapseln
26 bekannte Kategorien
77 bekannte Funktoren
42 bekannte natürliche Transformationen
0 fehlende Referenzen
```

Die Referenzvalidierung besitzt den Status `passed`.

## Native Witness-Daten

`src/reta_mojo/architecture_witnesses.mojo` enthält typisierte Strukturen für:

- Datei- und Symbolanker
- vertikale Kapselschnitte
- Diagramm-Witnesses
- Natürlichkeits-Witnesses
- Refactor-Verpflichtungen
- Witness-Abdeckung und Stage-30-Plan

Der Snapshot umfasst:

```text
536 AnchorWitnessSpec
11 CapsuleSliceSpec
33 DiagramWitnessSpec
42 NaturalTransformationWitnessSpec
55 RefactorObligationSpec
351 dateiartige Anker
351 aufgelöste dateiartige Anker
185 symbolische Anker
0 fehlende Dateianbindungen
0 unbedeckte Kapseln, Diagramme, Gesetze oder Transformationen
```

Die Witness-Validierung besitzt den Status `passed`.

## Regeneration

```bash
python3 tools/generate_architecture_contracts.py \
  --reference-root python_reference \
  --output src/reta_mojo/architecture_contracts.mojo

python3 tools/generate_architecture_witnesses.py \
  --reference-root python_reference \
  --output src/reta_mojo/architecture_witnesses.mojo
```

Der Witness-Generator erhält bewusst `python_reference` als Repositorywurzel.
Dadurch werden die historischen Pfade wie `reta_architecture/facade.py` gegen den
unveränderten Referenzbaum aufgelöst und nicht fälschlich als fehlend markiert.

Beide Generatoren sind mit `PYTHONHASHSEED=0`, `1`, `42` und `random`
byteidentisch reproduzierbar:

```text
architecture_contracts.mojo
14f0459c85ac0513381ba92de9fde1fc42231d404a92d6be7385a6a93daf1416

architecture_witnesses.mojo
26ba36ae176cc07e5031d03a3cee9d93315e8d36a59ea5b35de4c53a9ba593d3
```

`scripts/check_architecture_control_generation.sh` prüft nun Karte,
Boundary-Graph, Verträge und Witnesses gemeinsam als **4/4** byteidentische
generierte Architekturdateien.

## Compilergrenzen

Verträge und Witnesses sind absichtlich eigene schwere Ziele:

```text
target/bin/reta-mojo-contracts
target/bin/reta-mojo-witnesses
```

Ein einzelnes Programm, das Kategorienkatalog, Kapselkarte und sämtliche
Vertragsdaten zugleich instanziiert, führt zu unverhältnismäßiger
Compilerelaboration. Die Referenzen werden deshalb beim deterministischen
Generatorlauf geprüft und als validierter Snapshot gespeichert. Die getrennten
nativen Programme kompilieren schnell und benötigen zur Laufzeit kein Python.

Gemessene fokussierte Builds in der Stage-11b-Umgebung:

```text
Vertragsprobe:       11,28 s
Vertragsprogramm:    12,17 s
Witness-Probe:       23,20 s
Witness-Programm:    23,75 s
```

## Öffentliche Abfragen

```bash
./scripts/build-heavy.sh

./bin/reta-mojo-contracts --summary
./bin/reta-mojo-contracts --diagram RawCommandNaturalitySquare
./bin/reta-mojo-contracts --capsule CategoricalMetaCapsule
./bin/reta-mojo-contracts --law ExecutionNetworkPersistenceLaw

./bin/reta-mojo-witnesses --summary
./bin/reta-mojo-witnesses --anchor RetaArchitectureRoot reta_architecture/facade.py
./bin/reta-mojo-witnesses --capsule CategoricalMetaCapsule
./bin/reta-mojo-witnesses --diagram RawCommandNaturalitySquare
./bin/reta-mojo-witnesses --transformation RawToCanonicalParameterTransformation
./bin/reta-mojo-witnesses --obligation ExecutionNetworkPersistenceLaw
```

## Tests

- Vertragsprobe: 20 fachliche Laufzeitbedingungen bestanden
- Witness-Probe: 24 fachliche Laufzeitbedingungen bestanden
- Vertragsgenerator: aktuelle Datei und vier Hash-Seeds byteidentisch
- Witness-Generator: aktuelle Datei und vier Hash-Seeds byteidentisch
- Vertrags-CLI: Summary, Diagramm, Kapsel und Gesetz erfolgreich
- Witness-CLI: Summary, Anker, Kapsel, Diagramm, Transformation und Verpflichtung erfolgreich
- Stage-11a-Boundary- und Kategorienprogramme weiterhin ausführbar
- `RETA_CHECK_HEAVY=1 ./scripts/check_build_layout.sh` erwartet nun fünf schwere Ziele

Die Zählung der `_require`-Aufrufe enthält jeweils die Hilfsfunktionsdefinition;
fachlich ausgeführt werden 20 beziehungsweise 24 Bedingungen.

Kein Test oder Programmaufruf dieser Stage verwendet `--alles`.
