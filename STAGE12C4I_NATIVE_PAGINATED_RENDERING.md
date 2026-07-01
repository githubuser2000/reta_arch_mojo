# Stage 12c4i – paginierte Rendererparität

Stage 12c4i schließt zwei verbliebene Referenzabweichungen in horizontal
paginierten Shell-, HTML- und BBCode-Ausgaben. Betroffen waren nicht die
Tabellenauswahl oder Seitengrenzen, sondern die sichtbare Fortsetzungssemantik
innerhalb einer Seite.

## Vorhandene Bindestriche vor hartem Umbruch

Der gemeinsame Mojo-Wortumbruch bevorzugt nun – wie die Python-Referenz mit
ihrem historischen Textwrap-/Hyphenationspfad – einen bereits vorhandenen
ASCII-Bindestrich. Ein Ausdruck wie

```text
(gefährliche Wildkatzen-Außerirdische)
```

wird bei Breite 21 in die Fragmente

```text
(gefährliche
Wildkatzen-
Außerirdische)
```

zerlegt. Der frühere harte Schnitt innerhalb von `Wildkatzen` ist entfernt.
Die Regel gilt für den gemeinsamen Markup- sowie den Shell-Wortumbruch und
bleibt Unicode-sicher.

## Farbe fehlender Fortsetzungsfragmente

Bei mehrzeiligen Shell-Zellen unterscheidet der Renderer jetzt zwischen

- einem tatsächlich vorhandenen, aber leeren Fragment und
- einer Zelle, die für diese visuelle Fortsetzungszeile überhaupt kein Fragment
  mehr besitzt.

Nur der zweite Fall verwendet die neutrale alternierende Restfarbe. Dadurch
stimmen paginierte Fortsetzungszeilen mit der Rich-Referenz überein, ohne die
Farbsemantik echter leerer Zellinhalte zu verändern.

## Referenzvertrag

`scripts/check_paginated_rendering_parity.sh` prüft sechs versionierte
Referenzströme:

- Shell, HTML und BBCode auf Deutsch,
- Shell, HTML und BBCode auf Englisch,
- jeweils mit positiver Breite, horizontaler Seitenteilung und
  `keineleereninhalte`/`noblankcontents`.

Die Fixtures können nur ausdrücklich regeneriert werden:

```bash
RETA_REFRESH_PAGINATED_FIXTURES=1 \
RETA_REFERENCE_PYTHON=/pfad/zur/referenz-python \
  scripts/check_paginated_rendering_parity.sh
```

## Ausgeführte Prüfungen

```text
Tabellenrenderer:                         13/13
paginierte Python↔Mojo-Ausgaben:           6/6 byteidentisch
No-blank-Ausgaben:                        13/13 byteidentisch
zentrale HTML-/BBCode-Fixtures:            8/8 byteidentisch
Markup-oneTable ohne Python:              12/12
CLI-/Ownership-Planer:                    25/25
Kompatibilitätslauncher:                  10/10
nativer Datei-/Pipe-/HTML-I/O-Audit:      bestanden
aktive std.python-Importe:                    0
libpython-Abhängigkeiten:                     0
```

Der Kompatibilitätslauncher bindet weiterhin ausschließlich Mojo-Runtime und
libc. Zwei im hochgeladenen Eingangsarchiv erneut vorhandene, unbenutzte
Altdateien (`prompt_python_bridge.mojo` und
`prompt_external_python_ffi_probe.mojo`) wurden physisch entfernt; die
Source-/Boundary-Gates bestehen danach 15/15. Die Änderungen erweitern keine Fallbackgrenze und benötigen keinen
Python-Kindprozess für die sechs geprüften Tabellenströme.
