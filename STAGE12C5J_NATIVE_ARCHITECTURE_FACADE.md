# Stage 12c5j – Ownership-Korrektur und nativer Architektur-Fassadengraph

## Ausgangslage

Der lokale vollständige Build von Stage 12c5i erreichte
`src/architecture_exports_main.mojo`, brach dann aber in
`architecture_exports_for_module` ab. `ArchitectureExportSpec` ist explizit
`Copyable`, aber nicht `ImplicitlyCopyable`. Die Schleife legte bereits eine
lokale Kopie `entry` an und versuchte anschließend, diese lvalue-Kopie ohne
Besitzübertragung an `List.append` zu übergeben.

## Ownership-Korrektur

Der Filter über einen Besitzermodulnamen verwendet nun:

```mojo
var entry = catalog.entries[index].copy()
if entry.module == module and (entry.is_public or not public_only):
    result.append(entry^)
```

`entry^` ist hier die richtige Operation: Die lokale Kopie wird nach dem
Append nicht mehr verwendet und kann deshalb ohne zweite Kopie in die
Ergebnisliste übertragen werden. Ein Source-Regressionstest verbietet das
fehlerhafte `result.append(entry)` ausdrücklich.

## Nativer Vertrag von `reta_architecture/facade.py`

Die Python-Datei ist ein heterogener Composition Root. Sie besitzt nur wenig
eigene Fachlogik, aber vier unterschiedliche geordnete Oberflächen:

- 45 Dataclass-Felder,
- 49 Methoden,
- 45 Bootstrap-Zuweisungen,
- 48 Snapshot-Einträge.

Dazu kommen 44 `force_rebuild`-Einstiege und 98 explizite Abhängigkeitskanten
zwischen Bootstrap-Methoden. Diese Struktur wird aus der eingefrorenen
Python-AST reproduzierbar nach `assets/architecture_facade.tsv` erzeugt und
von `src/reta_mojo/architecture_facade.mojo` ohne Python-Import geladen.

Feld- und Bootstrap-Reihenfolge werden absichtlich getrennt gespeichert. Sie
sind nicht identisch: `architecture_validation` steht im Dataclass-Feldvertrag
früher, wird aber erst nach seinen Architektur- und Legacy-Abhängigkeiten
gebaut. Eine Gleichsetzung beider Ordnungen wäre ein Portierungsfehler.

Der native Besitzer bietet:

- exakte Lookup-Funktionen nach Art und Name,
- typisierte Abhängigkeitsabfragen,
- Zähl-/Kohärenzsnapshot,
- Prüfung von Ordinalen, Duplikaten, Feld↔Bootstrap-Bijektion und
  Methodenkanten,
- native Diagnose-CLI `reta-mojo-facade`.

Die Datei wird zunächst als **teilweise nativ** geführt. Die statische
Kompositions- und Rebuild-Semantik ist vollständig besessen; die tatsächliche
heterogene Objektaggregation bleibt an den Stellen Referenz, deren Besitzer
wie `program_workflow`, `meta_columns` oder `prompt_execution` noch nicht
vollständig nativ sind.

## `concat_csv_probe`

`target/tests/concat_csv_probe` ist ein Testartefakt und gehört nicht in die
Produktionsbuilds `scripts/build.sh` oder `scripts/build-heavy.sh`. Der neue
gezielte Helfer

```sh
scripts/build_concat_csv_probe.sh
```

baut ausschließlich dieses Probe-ELF. `scripts/test_stage12c5e.sh` verwendet
nun den Helfer und startet danach den Python↔Mojo-Paritätsvergleich.

## Prüfungen

- reproduzierbare AST→TSV-Generierung,
- exakte Feld-, Methoden-, Bootstrap- und Snapshot-Reihenfolge,
- bridge-freie Mojo-Quelle,
- Build-/Install-/Launcher-Verdrahtung,
- Ownership-Regression für `ArchitectureExportSpec`,
- Portierungsmatrix und maschinenberechnete Metriken.

Der vollständige native Stage-Test ist `scripts/test_stage12c5j.sh`. Er baut
sowohl den bestehenden Exportkatalogtest als auch den neuen Fassadengraphtest.
