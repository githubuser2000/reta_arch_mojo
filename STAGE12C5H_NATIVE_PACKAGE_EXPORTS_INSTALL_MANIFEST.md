# Stage 12c5h – Native Paketexporte, artefaktbewusste middle.alx-Parität und deterministische Installation

## Umfang

Diese Stage portiert die reine Reexport-Fassade
`reta_architecture/__init__.py` als reproduzierbar generierten, typisierten
Mojo-Katalog. Die Python-Datei enthält keine Fachalgorithmen, sondern bindet
**314** Namen aus **46** Besitzermodulen und veröffentlicht davon **232** in
einer ausdrücklich geordneten `__all__`-Liste.

`src/reta_mojo/architecture_exports.mojo` besitzt nun:

- Import- und `__all__`-Ordinal getrennt,
- Quellmodul, importierten und öffentlichen Namen,
- öffentliche/private Bindung,
- Symbol-, Modul- und Gesamtkatalogabfragen,
- eine native CLI `reta-mojo-exports`.

Die Regeneration erfolgt ausschließlich explizit über
`tools/generate_architecture_exports.py`; zur Laufzeit wird kein Python-Modul
importiert.

## Korrektur des hochgeladenen Python3/PyPy3-Vergleichs

Die vom Benutzer genannten äußeren MD5-Summen sind korrekt:

```text
eff5326745d0c10437b0a61f3f3cc7d4  middle_arch_pypy3.alx
de87dd39666e13632e63c44d88529cef  middle_python3_arch.alx
```

Sie vergleichen jedoch zwei verschiedene **Containerformen**:

- `middle_arch_pypy3.alx` ist direktes HTML mit 24.907.325 Byte.
- `middle_python3_arch.alx` ist trotz `.alx`-Endung ein unkomprimiertes
  POSIX-Tar mit 24.913.920 Byte.
- Das einzige Tar-Mitglied heißt `middle_pypy3_arch.alx`, ist 24.907.325 Byte
  groß und besitzt wiederum MD5
  `eff5326745d0c10437b0a61f3f3cc7d4`.
- Direkter `cmp` zwischen dem entpackten Mitglied und
  `middle_arch_pypy3.alx` ergibt Bytegleichheit.

Damit beweisen die verschiedenen äußeren MD5-Summen keine Python3↔PyPy3-
Abweichung; das vermeintliche Python3-Artefakt enthält tatsächlich erneut die
PyPy3-Datei. `tools/compare_middle_alx.py` meldet deshalb ab jetzt getrennt
Containerart, Containergröße/-MD5, Nutzlastgröße/-MD5 und den kanonischen
Tabellenhash. Diese Unterscheidung ist durch einen Tar-vs.-HTML-Test gesichert.

## Deterministische Installationsmenge

`scripts/install.sh` kopierte früher blind jedes vorhandene
`target/bin/*`. Dadurch konnten lokale Debug- oder Altziele wie
`reta-native-o0` unbeabsichtigt unter `/usr/lib/reta/target/bin` landen.

Die Installation verwendet nun `scripts/install_targets.txt` als explizite
Allowlist:

- **13** reguläre Ziele aus `scripts/build.sh`,
- **18** optionale schwere Ziele aus `scripts/build-heavy.sh`,
- insgesamt **31** offizielle Compilerziele,
- fehlende optionale Ziele werden übersprungen,
- unbekannte oder veraltete Dateien werden niemals installiert.

Bei `PREFIX=/usr` liegen die kompilierten ELFs privat unter
`/usr/lib/reta/target/bin`; `/usr/bin` enthält weiterhin nur relative Symlinks
auf die versionierten Launcher unter `/usr/lib/reta/bin`.

## Öffentliche Abfragen

```sh
./bin/reta-mojo-exports --summary
./bin/reta-mojo-exports --symbol RetaArchitecture
./bin/reta-mojo-exports --module prompt_session --public
./bin/reta-mojo-exports --public
```

Erwartete Zusammenfassung:

```text
imports=314
public_exports=232
private_imports=82
modules=46
```

## Reproduzierbare Prüfungen

- `tests/test_architecture_exports.mojo`
- `tests/test_architecture_exports_catalog.py`
- `tests/test_install_target_manifest.py`
- `tests/test_middle_alx_compare.py`
- `tools/generate_architecture_exports.py`
- `tools/compare_middle_alx.py`
- `scripts/test_stage12c5h.sh`

## Maschinenberechneter Stand

```text
vollständig nativ/generiert: 56/92 = 60,9 %
mindestens teilweise:       76/92 = 82,6 %
angegriffene Referenzzeilen: 34.775/48.831 = 71,2 %
Mojo-Zeilen in src/:         50.224
Mojo-Zeilen in reta_mojo/:   46.785
```

Der neue Exportkatalog wurde in dieser Umgebung mangels installiertem
offiziellem Modular-Mojo-Compiler nicht neu zu einem ELF gelinkt. Die
vorhandenen Python-, Generator-, Installations- und Quelltests sind ausgeführt;
der lokale Gesamtbuild erfolgt wie bisher mit `scripts/build.sh` und
`scripts/build-heavy.sh`.
