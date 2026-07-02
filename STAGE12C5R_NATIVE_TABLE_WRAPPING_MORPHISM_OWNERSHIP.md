# Stage 12c5r – vollständiges natives Table-Wrapping und Morphismen-Ownership

## Anlass

Der lokale Compilerlauf von `scripts/test_stage12c5p.sh` brach in
`MorphismBundle.from_topology_and_sheaves` ab:

```text
error: cannot transfer out of immutable reference
RendererMorphisms(topology_context^, default_output_mode)
```

`ContextSelection` ist `Copyable`, der Funktionsparameter wird jedoch als
immutable Referenz gelesen. Ein Transferoperator darf daraus keinen Besitz
entnehmen.

## Ownership-Reparatur

Alle vier Teilmorphismen erhalten nun eine explizite Kopie des gemeinsam
verwendeten Topologiekontexts. Der letzte Konstruktor verwendet ebenso wie die
drei vorherigen:

```mojo
RendererMorphisms(topology_context.copy(), default_output_mode)
```

Damit bleibt der Eingabekontext unverändert, jeder Teilbesitzer erhält einen
eigenen typisierten Wert und es gibt weder Doppelverbrauch noch versteckte
Alias-Lebenszeit.

## Vollständiger Besitzer für `table_wrapping.py`

`src/reta_mojo/table_wrapping.mojo` besitzt nun die vollständige öffentliche
Oberfläche von `python_reference/reta_architecture/table_wrapping.py`:

- zwölf Modul-Funktionen;
- die drei Wraptype-Werte;
- `TextWrapRuntime.snapshot`;
- alle drei Methoden von `TableWrappingBundle`;
- Unicode-sichere Chunk-, Wrap- und Breitenlogik;
- Bootstrap, Runtime-Refresh sowie Getter und Setter.

Das mutable Python-Modulglobal `_RUNTIME` wird durch
`TextWrapRuntimeState` explizit gemacht. Die dynamischen pyphen-/pyhyphen-
Objekte werden nicht als untypisierte Callables nachgebaut, sondern durch
Capability-Felder beschrieben. Der native Code besitzt den deterministischen
Codepoint-Wrapper und bewahrt bei fehlenden Fähigkeiten den historischen
elementaren Fallback.

Neue typisierte Snapshots:

- `TextWrapRuntimeSnapshot`
- `TableWrappingSnapshot`

Die String-Spezialisierung von `chunks` und sämtliche nachfolgenden Splits
iterieren Codepoints; Mehrbytezeichen können daher keine ungültige Bytegrenze
erzeugen.

## Prüfung

Der lokale Stage-Test kompiliert und startet:

1. `tests/test_morphisms.mojo`
2. `tests/test_morphisms_complete.mojo`
3. `tests/test_table_wrapping.mojo`

Danach folgen Source-, Ownership-, Defekt-, Metrik- und Archivprüfungen über
den gemeinsamen Pytest-Resolver.
