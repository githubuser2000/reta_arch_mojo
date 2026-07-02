# Stage 12c5c – native Paketintegrität und typisierte Split-i18n-Fassade

## Ziel

Diese Stufe schließt zwei bisher reine Python-Besitzer:

- `reta_architecture/package_integrity.py`,
- `reta_architecture/split_i18n.py`.

Der erste Besitzer ist eine reale Release- und Validierungsgrenze: Er bildet
einen Quellbaum deterministisch ab, erkennt fehlende Pflichtdateien und
Laufzeitartefakte und schützt die CSV-Datenbasis. Der zweite Besitzer war eine
kleine, aber dynamische `SimpleNamespace`-Fassade über die drei aktiven
i18n-Splitmodule. Beide Verträge laufen jetzt ohne Python-Import.

## Nativer Integritätsbaum

`src/reta_mojo/package_integrity.mojo` besitzt den vollständigen beobachtbaren
`RepoManifest`-Vertrag:

- kanonische POSIX-Wurzelauflösung,
- sortierte Aufnahme regulärer Dateien,
- Aufnahme von Symlinks auf reguläre Dateien ohne Traversieren von
  Verzeichnissymlinks,
- Ausschluss und gesonderte Zählung von `.git`, `__pycache__`,
  `.pytest_cache`, `.mypy_cache`, `.pyc` und `.pyo`,
- Bytezählung und binäre SHA-256-Dateidigests,
- identischen Gesamtdigest aus `relativer Pfad + NUL + Dateidigest`,
- Prüfung von 74 Pflichtpfaden,
- Python-kompatible `str.splitlines()`-Zählung der CSV-Dateien einschließlich
  CRLF, NEL, VT, FF, FS, GS, RS, LS und PS,
- Erkennung verdächtig kurzer Religions-CSV-Dateien,
- kompakte JSON- und Textausgabe.

Die SHA-256-Grenze verwendet OpenSSL über die native FFI. Der Dateibaum wird
über native Linux/POSIX-FFI mit `realpath`, `opendir`, `readdir`, `readlink` und `closedir` aufgenommen. Dateiinhalte, Sortierung, Filterung, Zählung, Digestaufbau und JSON-Ausgabe bleiben im Mojo-Prozess. Es gibt weder einen `std.python`-Import noch einen Shell- oder Python-Kindprozess.

Das neue Kommando ist:

```sh
./bin/reta-mojo-package-integrity --summary python_reference
./bin/reta-mojo-package-integrity --json python_reference
./bin/reta-mojo-package-integrity --json-files python_reference
```

Der vollständige eingefrorene Python-Referenzbaum ergibt in Python und Mojo
exakt denselben Snapshot:

```text
Dateien:        457
Bytes:          34.576.137
CSV-Dateien:    79
Pflichtlücken:  0
verdächtige CSV:0
SHA-256:        572fb412ec96f32303f4ec944875112f5274db61094e6ebe8eb5c725972f8d5e
```

Der native Scan benötigte nach Entfernung des Hilfsprozesses in dieser Laufzeit ungefähr 0,25 Sekunden. Diese
Messung ist nur ein Umgebungswert, kein zugesicherter Benchmark.

## Typisierte Split-i18n-Fassade

`src/reta_mojo/split_i18n.mojo` ersetzt das importzeitliche Zusammenkopieren
öffentlicher Modulattribute in einen `SimpleNamespace` durch
`SplitI18nProxy` und `SplitI18nSnapshot`.

Die historische Reihenfolge bleibt erhalten:

1. `i18n.words_context`,
2. `i18n.words_matrix`,
3. `i18n.words_runtime`.

Bei mehrfach vorhandenen Pfaden gewinnt wie beim Python-`setattr`-Ablauf das
später geladene Modul. Sprache, Quellmodule, Knotenwerte, Knotentypen,
Existenzprüfung, Knotenanzahl und Wurzelanzahl sind typisiert abfragbar. Der
bereits eingefrorene fünfsprachige `i18n_words`-Katalog bleibt die einzige
Datenquelle.

## Erkannter Python-Fehlerkandidat

Die Python-Funktion `_normalise_path()` verwendet `lstrip("./")`. Das entfernt
nicht nur ein optionales `./`, sondern beliebig viele führende Punkte und
Schrägstriche. `.hidden` wird dadurch zu `hidden`. Existieren `.hidden` und
`hidden` zugleich, kollidieren ihre Manifestnamen und der Fallback in
`_manifest_file_entry()` kann für beide Einträge dieselbe undotierte Datei
lesen.

Der Mojo-Port reproduziert diesen Vertrag vorerst absichtlich, damit bestehende
Manifeste bytegleich bleiben. Der Befund ist als `PY-CAND-011` dokumentiert.
Nach Abschluss der Transpilierung soll Python auf eine präzise Entfernung nur
des Präfixes `./` umgestellt und das Manifestformat kontrolliert migriert
werden.

## Prüfungen

```text
native Paketintegrität:               27/27
native Split-i18n-Fassade:            12/12
Python↔Mojo-Manifestparität:            2/2 Bäume exakt
Source-/Ownership-/Boundary-/Archiv:   17/17
vollständiger Referenzsnapshot:       457 Dateien exakt
aktive std.python-Brücken:              0
```

Der zweite Paritätsbaum wird zur Testlaufzeit erzeugt. Er enthält absichtlich
`.git`, `__pycache__`, Datei- und Verzeichnissymlinks, einen toten Symlink,
eine FIFO, Binärdaten, Unicode-Zeilentrenner sowie die Kollision `.hidden`/`hidden`. Dadurch prüft er die Sonderfälle, ohne verbotene
Laufzeitartefakte in das Sourcearchiv einzuchecken.

## Fortschritt

- vollständig native oder reproduzierbar generierte Originaldateien:
  **47/92 → 49/92 = 53,3 %**,
- mindestens teilweise portierte Originaldateien:
  **78/92 → 80/92 = 87,0 %**,
- gewichteter Quellzeilenersatz:
  **ca. 70,7 % → ca. 71,2 %**,
- nativer Mojo-Quellcode in `src/`: **46.035 Zeilen**,
- davon in `src/reta_mojo/`: **42.738 Zeilen**.

`package_integrity.py` und `split_i18n.py` verbleiben ausschließlich als
eingefrorene Referenzquellen und für die spätere Python-Bereinigung im Baum.
