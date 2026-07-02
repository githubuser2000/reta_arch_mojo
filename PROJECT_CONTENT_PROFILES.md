# Welche Projektinhalte wofür gebraucht werden

## Für weitere Transpilierungsrunden hochladen

Am zuverlässigsten ist das von `scripts/create_source_archive.sh` erzeugte
**Sourcearchiv**. Es enthält alle fachlich relevanten Quellen und Referenzen,
aber keine rechnerabhängigen Buildprodukte.

Erforderlich:

- `src/`: native Mojo-Quellen und Compiler-Einstiege,
- `python_reference/`: Python-Referenzimplementierung samt CSV-/Textressourcen,
- `assets/`: generierte und kuratierte Laufzeitkataloge,
- `tests/`: Mojo-, Python-, Fixture- und Paritätstests,
- `scripts/`: Build-, Test-, Installations- und Paritätsskripte,
- `tools/`: reproduzierbare Generatoren, Audits und Metriken,
- `bin/`: öffentliche Entwicklungslauncher,
- `man/`: Installations-Manpage,
- Rootdateien wie `.gitignore`, `README.md`, `BUILD.md`, `PORTING_MATRIX.md`,
  `KNOWN_DEFECTS.*`, `PYTHON_CLEANUP_BACKLOG.md`, `STATUS.md`,
  `SOURCE_MANIFEST.sha256` und `SOURCE_SYMLINKS.txt`.

Nützlich, aber nicht für jede Änderung zwingend:

- `benchmarks/`,
- ältere `STAGE*.md`-Protokolle,
- historische Markdown-Dokumente unter `python_reference/`,
- Root-Komfortsymlinks wie `reta`, `rp`, `generate_html`.

Nicht hochladen:

- `target/` und `build/`: lokal neu erzeugbare ELF-/Testartefakte,
- `.venv/`: rechner- und Pythonversionsabhängige Mojo-Installation,
- `.git/`: Repository-Historie,
- `.pytest_cache/`, `__pycache__/`, `*.pyc`, `*.pyo`, `*.tmp`, Editor-Backups und Swapdateien,
- absolute Mojo-Runtime-Symlinks unter `target/lib/mojo/`,
- bereits installierte Kopien aus `/usr` oder `/usr/local`,
- alte Projektarchive innerhalb des Projektordners,
- `middle.alx`, außer wenn gerade genau diese Vollausgabe verglichen wird.

Buildfehler werden als Textausgabe benötigt; die erzeugten Binaries selbst
normalerweise nicht. Ein spezielles Probe-Binary wie
`target/tests/concat_csv_probe` soll lokal über sein Buildskript neu erzeugt
werden.

## Für einen lokalen vollständigen Build

Benötigt werden das Sourcearchiv, ein offizieller Modular-Mojo-Compiler und die
Systembibliotheken der jeweiligen Ziele, insbesondere SQLite/OpenSSL für die
entsprechenden schweren Werkzeuge. `.venv/` und `target/` sind lokale,
regenerierbare Arbeitsverzeichnisse und gehören nicht in das Sourcearchiv.

## Für die installierte Laufzeit

`scripts/install.sh` installiert nur die Laufzeitstruktur:

- öffentliche Befehlslinks unter `$PREFIX/bin`,
- private Launcher und Python-Kompatibilitätsreferenz unter
  `$PREFIX/lib/reta`,
- manifestierte native Compilerziele unter
  `$PREFIX/lib/reta/target/bin`,
- Mojo-Runtimebibliotheken unter `$PREFIX/lib/reta/target/lib/mojo`,
- CSV-Daten und Assets unter `$PREFIX/share/reta`,
- die Manpage unter `$PREFIX/share/man/man1`.

Entwicklungsquellen, Tests, Generatoren, Stage-Protokolle, `.venv` und lokale
Buildverzeichnisse werden für die Benutzung der installierten Programme nicht
gebraucht.
