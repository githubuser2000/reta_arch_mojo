# Stage 12c4m – portable Ressourcenpfade und FHS-Installation

## Ziel

Stage 12c4m trennt erstmals vollständig zwischen Quellbaum, privaten
Programmbestandteilen und unveränderlichen Laufzeitdaten. Ein absolutes
Build-Verzeichnis wird weder für CSV-Dateien noch für native Katalogassets in
die Mojo-Programme einkompiliert.

Unterstützt werden drei Betriebsarten:

1. Entwicklung direkt aus dem Projektverzeichnis;
2. benutzerverwaltete Installation mit `PREFIX=/usr/local` oder
   `PREFIX=$HOME/.local`;
3. paketverwaltete Systeminstallation mit `PREFIX=/usr` und optionalem
   `DESTDIR` für RPM-/DEB-Staging.

## FHS-Layout

Für eine paketverwaltete Installation unter `/usr` gilt:

```text
/usr/bin/                         öffentliche Startnamen als relative Symlinks
/usr/lib/reta/                    private Reta-Laufzeit
/usr/lib/reta/bin/                Shell-Launcher
/usr/lib/reta/target/bin/         kompilierte Mojo-Programme
/usr/lib/reta/target/lib/mojo/    private Mojo-Laufzeitbibliotheken
/usr/lib/reta/python_reference/   noch benötigter Python-Kompatibilitätsbaum
/usr/share/reta/csv/              unveränderliche CSV-Anwendungsdaten
/usr/share/reta/assets/           TSV-/HTML-Laufzeitassets
```

Die CSV-Dateien gehören nach `/usr/share/reta/csv`, weil sie
architekturunabhängige, schreibgeschützte Programmdaten sind. Sie gehören
nicht nach `/usr/bin`, `/usr/lib`, `/var` oder `/etc`:

- `bin` ist für ausführbare Programme;
- `lib` ist für architekturabhängige private Programme und Bibliotheken;
- `share` ist für architekturunabhängige statische Daten;
- `var` ist für veränderliche Laufzeitdaten;
- `etc` ist für administrierbare Konfiguration.

Bei manueller Installation ist `/usr/local` der richtige Standard. Daraus
entsteht `/usr/local/share/reta/csv`. `/usr/share/reta/csv` sollte ein
Distributionspaket oder ein bewusst mit `PREFIX=/usr` ausgeführter
Installationsvorgang verwalten.

## Erhalt der historischen Ordnerstruktur

Der Python-Referenzcode erwartet weiterhin relativ zu seinem privaten
Laufzeitwurzelverzeichnis den Pfad:

```text
python_reference/csv
```

Die Installation dupliziert die etwa 3,8 MiB Tabellen nicht. Stattdessen wird
ein relativer Symlink erzeugt:

```text
/usr/lib/reta/python_reference/csv -> ../../../share/reta/csv
```

Analog verweist:

```text
/usr/lib/reta/assets -> ../../share/reta/assets
```

Damit bleiben alle historischen relativen Pfade funktionsfähig, während die
physischen Daten FHS-gerecht nur einmal unter `share/reta` liegen.

## Native Laufzeitauflösung

`src/reta_mojo/resource_paths.mojo` besitzt den zentralen Pfadvertrag:

```text
RETA_ROOT
RETA_SHARE_DIR
RETA_DATA_DIR
RETA_ASSET_DIR
RETA_REFERENCE_DIR
```

Priorität:

1. direkte Overrides `RETA_DATA_DIR`, `RETA_ASSET_DIR`,
   `RETA_REFERENCE_DIR`;
2. `RETA_SHARE_DIR/csv` und `RETA_SHARE_DIR/assets`;
3. `RETA_ROOT/python_reference/csv`, `RETA_ROOT/assets` und
   `RETA_ROOT/python_reference`;
4. historische relative Quellbaumpfade.

Alle nativen CSV- und Asset-Leser verwenden jetzt diesen Resolver. Dadurch
kann auch ein kompiliertes Programm direkt aus einem fremden Arbeitsverzeichnis
gestartet werden, wenn die Ressourcenvariablen gesetzt sind.

`bin/mojo-runtime-exec` setzt die Variablen für Quellbaum und Installation
automatisch. Explizite Benutzerwerte werden nicht überschrieben.

## Installation

Manuelle lokale Installation:

```bash
scripts/build-heavy.sh
scripts/build.sh
sudo scripts/install.sh
```

Das verwendet standardmäßig:

```text
PREFIX=/usr/local
```

Systempaket-Staging:

```bash
DESTDIR="$pkgdir" PREFIX=/usr scripts/install.sh
```

Benutzerinstallation ohne Root:

```bash
PREFIX="$HOME/.local" scripts/install.sh
```

Deinstallation mit denselben Pfadvariablen:

```bash
sudo scripts/uninstall.sh
```

Die Variablen `BINDIR`, `LIBEXECDIR` und `DATADIR` können für abweichende
Paketregeln einzeln überschrieben werden.

Fedora-/RPM-Pakete verwenden für private ausführbare Hilfsprogramme häufig
`/usr/libexec/reta`. Das wird ohne Änderung der Datenpfade unterstützt:

```bash
DESTDIR="$RPM_BUILD_ROOT" PREFIX=/usr LIBEXECDIR=/usr/libexec/reta \
  scripts/install.sh
```

Die CSV-Dateien bleiben dabei unter `/usr/share/reta/csv`.

## Mojo-Laufzeit

Die installierte private Mojo-Laufzeit benötigt nicht nur die zwei direkten
ELF-Abhängigkeiten, sondern deren vollständige Modular-Closure:

```text
libKGENCompilerRTShared.so
libAsyncRTMojoBindings.so
libMSupportGlobals.so
libAsyncRTRuntimeGlobals.so
libNVPTX.so
```

`configure_mojo_runtime.sh`, `find_mojo_runtime.sh` und `install.sh` behandeln
nun alle fünf Dateien. Eine bereits eingerichtete lokale Laufzeit wird nicht
mehr versehentlich auf sich selbst verlinkt.

## Prüfungen

```text
Ressourcenresolver:                 3/3
Installations-/Runtime-Pytests:     9/9
FHS-Staging nach /usr:              bestanden
Benutzer-Staging nach $HOME/.local:  bestanden
Aufruf aus fremdem cwd:             bestanden
native installierte CSV-Ausgabe:    bytegleich
installierter Python-Fallback:      bytegleich
Deinstallation:                     bestanden
Basistabellenparität:               4/4
positive Einzelbreiten:            12/12
explizite Nullbreiten:             12/12
rohes HTML/BBCode --nocolor:       12/12
```
