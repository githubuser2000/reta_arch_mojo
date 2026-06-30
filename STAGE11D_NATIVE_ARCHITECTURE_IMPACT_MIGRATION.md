# Stage 11d – Native Architektur-Impact- und Migrationsplanung

Stage 11d portiert die nächsten zwei rein deklarativen Architektursteuerungsschichten aus der Python-Referenz nach Mojo:

- `reta_architecture/architecture_impact.py`
- `reta_architecture/architecture_migration.py`

Die Python-Implementierungen werden nur bei einer expliziten Regeneration ausgewertet. Die eingecheckten typisierten Snapshots, ihre Suche, Statusprüfung und öffentlichen Abfragen laufen vollständig nativ.

## 1. Architektur-Impact-Kalkül

`src/reta_mojo/architecture_impact.mojo` enthält:

- **34** `ImpactSourceSpec`
- **34** `ImpactContractSpec`
- **10** `RegressionGateSpec`
- **34** `MigrationCandidateSpec`
- **5** bestandene Impact-Checks
- Validierungsstatus `passed`

Ein Impact-Objekt verbindet einen alten oder neuen Repository-Besitzer mit:

```text
Besitzer
→ Kapsel
→ Kategorie
→ Funktor / natürliche Transformation
→ kommutierendes Diagramm
→ Refactor-Gesetz
→ Boundary-Kante
→ Regression-Gate
```

Öffentliche Abfragen:

```bash
./bin/reta-mojo-impact --summary
./bin/reta-mojo-impact --source reta.py
./bin/reta-mojo-impact --gate CommandParityGate
./bin/reta-mojo-impact --candidate 'Stage33Guard::reta.py'
```

## 2. Geordneter Migrationsplan

`src/reta_mojo/architecture_migration.mojo` enthält:

- **7** geordnete Migrationswellen `M0` bis `M6`
- **34** `MigrationStepSpec`
- **34** `MigrationGateBindingSpec`
- **7** `MigrationInvariantSpec`
- **5** bestandene Migrationschecks
- Validierungsstatus `passed`

Die Wellen ordnen spätere Codebewegungen nach Architekturdomäne:

| Welle | Schwerpunkt |
|---|---|
| `M0` | Meta-Kohärenz und Planungsobjekte |
| `M1` | Topologie, Prägarben und Datenabschnitte |
| `M2` | Prompt- und Input-Morphismen |
| `M3` | Workflow und universelles Gluing |
| `M4` | Table-Core und expliziter Zustand |
| `M5` | generierte Relationen und Endofunktoren |
| `M6` | Ausgabe-Renderer und Parität |

Öffentliche Abfragen:

```bash
./bin/reta-mojo-migration --summary
./bin/reta-mojo-migration --wave M3
./bin/reta-mojo-migration --step MIG34-03
./bin/reta-mojo-migration --owner reta.py
```

## 3. Typisierte Gate-Kommandos

Die Python-Referenz verwendet in `MigrationGateBindingSpec` ein `Mapping[str, str]`. Der native Snapshot modelliert dieses Mapping als geordnete Liste typisierter Paare:

```mojo
struct GateCommandSpec(Copyable):
    var name: String
    var command: String
```

Damit bleiben die Python-Einfügereihenfolge und sämtliche Gate-Kommandos erhalten, ohne zur Laufzeit dynamische Dictionaries oder Python-Objekte zu benötigen.

## 4. Generatoren

Neu:

```text
tools/generate_architecture_impact.py
tools/generate_architecture_migration.py
```

`scripts/check_architecture_control_generation.sh` prüft jetzt acht Architektursteuerungs-Snapshots:

1. Architekturkarte
2. Boundary-Graph
3. Verträge
4. Witnesses
5. Kohärenz
6. Traces
7. Impact
8. Migration

Ergebnis:

```text
architecture-control generation: 8/8 byte-identical
```

Die beiden neuen Generatoren sind unabhängig von `PYTHONHASHSEED` reproduzierbar. Für `0`, `1`, `42` und `random` entstanden jeweils dieselben Hashes:

```text
architecture_impact.mojo
1e3b6e4db332983d796c6792e1a5e4b1cd1f78644e69e9411dee6a8a40f4b688

architecture_migration.mojo
53515a1190aee30f4c6eb8a6a29bbcb059f06367405ca37f4c9121587311d57f
```

## 5. Compilergrenze

Impact und Migration werden als zwei getrennte schwere Ziele gebaut:

```text
target/bin/reta-mojo-impact
target/bin/reta-mojo-migration
```

Der erste breite Impact-Controller mit vielen ausführlichen Präsentationszweigen führte wieder zu überproportionaler Mojo-Compilerelaboration. Die öffentliche Oberfläche wurde deshalb auf die semantisch wichtigsten, kompakten Namensabfragen reduziert. Das Datenbundle selbst blieb unverändert vollständig.

Gemessene Buildzeiten der endgültigen Ziele:

```text
test_architecture_impact       11,63 s
test_architecture_migration    12,24 s
reta-mojo-impact               11,97 s
reta-mojo-migration            12,84 s
```

## 6. Tests

Native Bedingungen:

```text
test_architecture_impact       11/11
test_architecture_migration    13/13
                               -----
                               24/24
```

Python↔Mojo-Ausgabeparität:

```text
Impact summary                 byteidentisch
Impact source reta.py          byteidentisch
Impact gate                    byteidentisch
Impact candidate               byteidentisch
Migration summary              byteidentisch
Migration wave M3              byteidentisch
Migration step MIG34-03        byteidentisch
Migration owner reta.py        byteidentisch
                               -----
                               8/8
```

Fokussierter Lauf:

```bash
./scripts/test_stage11d.sh
```

## 7. Buildintegration

`scripts/build-heavy.sh` besitzt nun neun getrennte Ziele:

```text
reta-mojo-schema
reta-mojo-architecture
reta-mojo-boundaries
reta-mojo-contracts
reta-mojo-witnesses
reta-mojo-coherence
reta-mojo-traces
reta-mojo-impact
reta-mojo-migration
```

Diese Trennung ist beabsichtigt. Sie verhindert, dass der Compiler alle großen Metadatenebenen in einem einzigen Optimierungsgraphen instanziieren muss.

## 8. Nächster Block

Der nächste zusammenhängende Stage-11-Block ist:

```text
architecture_rehearsal.py
architecture_activation.py
```

Danach folgen die ausführbare Gesamtvalidierung und der beobachtete Fortschritts-Overlay.

Kein Stage-11d-Test und kein Stage-11d-Programmaufruf verwendete `--alles`.
