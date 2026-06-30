# Stage 11g – native SQLite-Persistenz

## Portierter Referenzbereich

`python_reference/reta_architecture/persistence.py` ist als ausführende Mojo-Laufzeitschicht portiert:

- `src/reta_mojo/persistence.mojo`
- `src/architecture_persistence_main.mojo`
- `bin/reta-mojo-persistence`

Mojo bindet SQLite 3 und SHA-256 direkt über die C-ABI ein. Es gibt keinen Python-Import im Laufzeitpfad.

## Persistenzmodell

Sechs Tabellen speichern:

- offene Kontexte;
- lokale Sections;
- Garben-Snapshots;
- Ausführungsläufe;
- Auditereignisse;
- Cacheeinträge.

Zwölf öffentliche Morphismen decken Einzel- und Batchschreiben, Laden, Audit, Cachezugriff und Invalidierung ab. Batchschreibvorgänge sind seriell und transaktional.

## Kanonische JSON-Grenze

Die Python-Referenz akzeptiert beliebige Objekte und kanonisiert sie intern. Mojo nimmt bereits kanonischen UTF-8-JSON-Text entgegen. Die umschließenden Dokumente werden mit derselben sortierten Schlüsselreihenfolge aufgebaut. Dadurch stimmen SHA-256-Digests einschließlich Unicode überein, ohne dynamisches Python-`Any` nachzubauen.

## Interoperabilität

- Python liest von Mojo erzeugte Sections, Garben-Snapshots, Runs, Audit und Cachezustände.
- Mojo liest von Python erzeugte Sections und Garben-Snapshots.
- SQL-Sonderzeichen werden korrekt gequotet.
- Cacheinvalidierung und Auditlimits entsprechen der Referenzsemantik.

## Build und Test

```bash
./scripts/test_stage11g.sh
./bin/reta-mojo-persistence --summary
./bin/reta-mojo-persistence --demo /tmp/reta-persistence.db
./bin/reta-mojo-persistence --inspect /tmp/reta-persistence.db
```

Der fokussierte Lauf umfasst **47/47** native Prüfungen und **5/5** Python↔Mojo-Paritäts-/Interoperabilitätsprüfungen. Das Compilerziel wird mit `-lsqlite3 -lcrypto` gelinkt.
