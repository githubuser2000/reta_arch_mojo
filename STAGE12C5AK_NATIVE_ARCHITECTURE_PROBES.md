# Stage 12c5ak – native architecture/domain probes

## Ziel

Die letzte offene Domänenprobe `architecture-json` und die vollständige
`reta_architecture_probe_py.py`-Inspektionsoberfläche werden ohne
Python-Laufzeit bereitgestellt.

## Reproduzierbarer Snapshotvertrag

`tools/generate_architecture_probe_assets.py` bootstrapped die Python-Referenz
mit `PYTHONHASHSEED=0` und `PYTHONDONTWRITEBYTECODE=1`, entfernt vorher `__pycache__`-/`.pyc`-/Testcache-Artefakte und erzeugt 63 kompakte UTF-8-Kommandodateien unter
`assets/architecture_probe/`:

- 51 JSON-Snapshots einschließlich des 48-Abschnitt-Gesamtsnapshots;
- 12 Markdown-/Mermaid-Ansichten;
- ein SHA-256-/Größenmanifest.

Fünf Snapshots enthalten beobachtbare absolute Referenzpfade. Im Asset steht
statt eines Buildmaschinenpfads `@@RETA_REFERENCE_ROOT@@`; der native Loader
setzt zur Laufzeit `RETA_REFERENCE_DIR` beziehungsweise den installierten
Referenzpfad ein. Damit bleiben Quellarchiv und FHS-Installation portabel und
die Ausgabe entspricht dennoch dem Python-Aufruf am tatsächlichen Ort.

`package-integrity-json` wird nicht eingefroren. Es scannt den aktuellen
Referenzbaum weiterhin dynamisch über den bereits nativen binären
SHA-256-Manifestbesitzer.

## Native Oberflächen

- `reta-mojo-domain-probe architecture-json`
- `reta-mojo-architecture-probe <Kommando>`

Die Architekturprobe besitzt 64 Referenzkommandos: 63 Assetoberflächen plus
die dynamische Paketintegrität. Weder `std.python` noch ein Unterprozess wird
verwendet.

## Prüfungen

- Generator-`--check` gegen die aktuelle Python-Referenz, unabhängig vom vorherigen Cachezustand;
- SHA-256-/Größenprüfung aller 63 Assets;
- nativer Modultest für Katalog, Pfadauflösung und Gesamtsnapshot;
- vollständige native Architekturprobe-Parität;
- Domänenprobe-Parität über alle 16 Befehle;
- Build-, Installations- und Launcher-Verträge.

Lokaler vollständiger Lauf:

```sh
./do.sh 12c5ak
```
