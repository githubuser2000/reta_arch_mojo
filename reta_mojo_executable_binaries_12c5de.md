# Reta/Mojo Executable-Binaries und Launcher

Stand: Stage `12c5de`, Quelle `reta_arch_mojo_12c5de.tar.xz`.

Diese Datei erklärt die ausführbaren Ziele, die durch die Mojo-Buildskripte entstehen, plus die wichtigsten öffentlichen Shell-Launcher in `bin/`. Ziel ist ausdrücklich, spätere `.so`/`.dll`-Grenzen besser planen zu können.

## Begriffe

- **Target-Binary**: echte kompilierte Datei unter `target/bin/`, normalerweise ELF auf Linux. Diese wird von `mojo build --emit exe` erzeugt, außer `reta-mojo-diagnostics`, dessen Loader per C kompiliert wird.
- **Launcher**: Shellskript unter `bin/`, das ein Target-Binary startet, Ressourcenpfade setzt oder bei fehlendem Target auf `mojo run` zurückfällt.
- **Shared Library**: aktuell vor allem `target/lib/reta/libreta_diagnostics_mojo.so`, gebaut aus Mojo mit `--emit shared-lib` und gestartet über einen kleinen C-Loader.
- **Regulär**: Ziel aus `scripts/build.sh`.
- **Schwer**: Ziel aus `scripts/build-heavy.sh`; meist große generierte Kataloge oder compile-intensive Architektur-/Parallelitätsflächen.

## Schneller Überblick

| Klasse | Anzahl | Bedeutung |
|---|---:|---|
| Reguläre installierbare Targets | 21 | normale Buildziele aus `scripts/build.sh` |
| Schwere Targets | 18 | große Kataloge/Architektur/Parallelität aus `scripts/build-heavy.sh` |
| Optionale Standalone-Diagnose-Targets | 4 | standardmäßig durch `reta-mojo-diagnostics` + `.so` ersetzt |
| Aktuelle Shared Library | 1 | `libreta_diagnostics_mojo.so` |
| Wichtige öffentliche Launcher | 20 Einträge/Gruppen | Shellskripte in `bin/` |

## Empfehlung für `.so`/`.dll`-Grenzen

Nicht jedes Executable sollte später eine eigene Library bekommen. Sinnvoller ist:

```text
CLI-Launcher  -> dünn halten
Core-Logik    -> wenige stabile Libraries
Diagnose      -> optional getrennte Libraries
Architektur   -> große Metadaten-Library oder mehrere Audit-Libraries
```

Gute frühe Kandidaten:

- `libreta-i18n.so/.dll`: aus `reta-mojo-i18n`.
- `libreta-schema.so/.dll`: aus `reta-mojo-schema`, `reta-mojo-semantics`, `reta-mojo-tags`.
- `libreta-diagnostics.so/.dll`: schon teilweise vorhanden durch `libreta_diagnostics_mojo.so`.
- `libreta-architecture.so/.dll`: Architekturmetadaten, aber erst wenn `facade.py` formal abgeschlossen ist.
- `libreta_core_mojo.so/.dll`: erst nach 92/92, für `reta-native`/Workflow/Table/Output.

Noch nicht früh splitten: `reta-prompt-native`, `reta-mojo-compat-bin`, `reta-native`-Core, solange `prompt_execution.py`, `facade.py` und `reta.py` formal noch Restflächen sind.

## Reguläre Target-Binaries aus `scripts/build.sh`

### `reta-mojo-native`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo`
- **Kurz**: Inkrementeller nativer Mojo-Front-End für `--mojo-*`-Prüf- und Hilfsbefehle.
- **Lang**: Dieses Ziel war/ist ein Entwicklungs- und Diagnose-Front-End für den Port. Es verarbeitet nur Befehle, die explizit mit `--mojo-*` beginnen, z. B. Primfaktor-, Range-, Schema-, Tabellenzustands-, Tag- und CSV-Inspektionen. Historische `reta`-Argumente sind nicht sein Hauptzweck; dafür gibt es `reta-mojo-compat-bin` und `reta-native`. Für `.so/.dll` ist es ein schlechter Kernkandidat, aber ein guter dünner CLI-Client gegen spätere Core-Libraries.
- **`.so/.dll`-Hinweis**: Mittel- bis langfristiger Core-/Table-/Output-Kandidat; ABI erst nach Stabilisierung festlegen.

### `reta-mojo-table`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/table_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo table / interne Diagnose`
- **Kurz**: Leichtes Diagnoseprogramm für Tabellenzustand, Wrapping und CSV-Info.
- **Lang**: Dieses Binary testet und demonstriert zentrale Tabellen-Hilfsbausteine: Tabellenzustand mit oberer Zeilengrenze, Unicode-sicheres Wrapping und CSV-Abmessungen. Es ist kein Endnutzer-`reta`, sondern ein kleines Prüfprogramm. Für `.so/.dll` spricht es dafür, `table_state`, `table_wrapping` und `csv_table` als stabile Core-Komponenten zu bündeln.
- **`.so/.dll`-Hinweis**: Mittel- bis langfristiger Core-/Table-/Output-Kandidat; ABI erst nach Stabilisierung festlegen.

### `reta-mojo-tags`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/tags_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo tags / interne Diagnose`
- **Kurz**: Native Inspektion des Tabellen-Tag-Schemas.
- **Lang**: Dieses Ziel liest den generierten Tag-Schema-Katalog und beantwortet Fragen wie: Welche Tag-Namen gibt es, welche Spalten gehören zu welchem Tag, welche Kombinationstabellen sind abgedeckt? Es ist ein Schema-/Metadatenwerkzeug. Für Shared Libraries ist es ein Kandidat für eine kleine `libreta-schema` oder `libreta-tags`, nicht für die Laufzeit-Haupt-CLI.
- **`.so/.dll`-Hinweis**: Guter Library-Kandidat, sobald Datenvertrag stabil bleibt.

### `reta-mojo-i18n`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/i18n_words_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-i18n`
- **Kurz**: Native vollständige i18n-/Wortkatalog-Inspektion.
- **Lang**: Dieses Binary enthält bzw. lädt den vollständigen mehrsprachigen Wortkatalog und prüft Sprachaliasse, Container, Referenzvertrag und verlustfreie Katalogausgabe. Es ist relativ stabil und datenlastig. Für `.so/.dll` ist das einer der besten frühen Kandidaten: `libreta-i18n.so/.dll`, weil Sprache/Kataloge selten mit Prompt-Control-Logik vermischt werden müssen.
- **`.so/.dll`-Hinweis**: Guter Library-Kandidat, sobald Datenvertrag stabil bleibt.

### `reta-mojo-package-integrity`

- **Build**: `scripts/build.sh, linkt libcrypto`
- **Quelle/Entrypoint**: `src/package_integrity_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-package-integrity`
- **Kurz**: Manifest-/Paketintegritätsprüfung für Referenzdaten und Assets.
- **Lang**: Dieses Programm erzeugt Zusammenfassungen und JSON-Manifeste über Dateien des Projekts bzw. der installierten Ressourcen. Es nutzt kryptografische Hashes und hängt an `libcrypto`. Für Shared Libraries ist es eher ein Installations-/Diagnosemodul. Es sollte nicht in die heiße `reta`-Laufzeit, sondern in eine `libreta-package` oder `libreta-diagnostics` wandern.
- **`.so/.dll`-Hinweis**: Eher CLI-/Diagnosewerkzeug; nur bei Bedarf in eine gemeinsame Library ziehen.

### `reta-mojo-exports`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/architecture_exports_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-exports`
- **Kurz**: Query-CLI für den nativen Exportkatalog von `reta_architecture`.
- **Lang**: Dieses Ziel beschreibt öffentliche/private Exporte, Module und Symbole der Architektur-Schicht. Es ist ein Architektur-/Refactor-Werkzeug, kein Endnutzerprogramm. Für `.so/.dll` gehört es in den Architektur-/Metadatenblock, zusammen mit Facade, Boundaries und Contracts.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-facade`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/architecture_facade_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-facade`
- **Kurz**: Native Query-CLI für die RetaArchitecture-Fassade und ihren Kompositionsgraphen.
- **Lang**: Dieses Binary erklärt Felder, Methoden, Bootstrap-Schritte, Snapshot-Einträge und Dependency-Kanten der `facade.py`-Ersatzarchitektur. Da `facade.py` noch eine formale Restfläche ist, würde ich diesen Bereich noch nicht als `.so/.dll` einfrieren. Später gehört er aber logisch in `libreta-architecture`.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-workflow`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/program_workflow_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-workflow`
- **Kurz**: Diagnose-CLI für den nativen Programm-Workflow-Owner.
- **Lang**: Dieses Ziel untersucht den Weg von CLI-/Semantikdaten zu Tabellenworkflow, CSV-Laden, Kombi-Planung, Output-Kind und Zell-Decoding. Es sitzt näher am echten Programmkern als reine Architekturtools. Für `.so/.dll` ist es ein Kandidat für `libreta_core_mojo` oder `libreta-workflow`, aber erst wenn `reta.py` formal abgeschlossen ist.
- **`.so/.dll`-Hinweis**: Mittel- bis langfristiger Core-/Table-/Output-Kandidat; ABI erst nach Stabilisierung festlegen.

### `reta-mojo-sheaves`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/sheaves_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-sheaves`
- **Kurz**: Native Diagnostik für Prägarben/Garben der Architektur.
- **Lang**: Dieses Programm prüft lokale Quellen wie CSV, Übersetzungen, Assets und Prompt sowie globale Sheaf-Strukturen. Es ist stark architekturtheoretisch und test-/metadatenorientiert. Für Shared Libraries gehört es eher zur Architekturdiagnostik als zur Endnutzerlaufzeit.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-diagnostics`

- **Build**: `scripts/build.sh über scripts/build_diagnostics_shared.sh`
- **Quelle/Entrypoint**: `tools/reta_mojo_diagnostics_loader.c + src/reta_diagnostics_abi.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-diagnostics und Subcommand-Wrapper`
- **Kurz**: Kleiner C-Loader für die gemeinsame Mojo-Diagnose-Shared-Library.
- **Lang**: Dieses Ziel ist eine Besonderheit: Das Executable selbst wird mit C gebaut und lädt `target/lib/reta/libreta_diagnostics_mojo.so`. Die eigentliche Logik steckt in der Mojo-Shared-Library. Aktuell bündelt sie Diagnoseflächen wie table-generation, output-syntax, console-io und table-output. Das ist dein vorhandenes Muster für spätere `.so/.dll`: kleine Loader, schmale C-ABI, Logik in Shared Library.
- **`.so/.dll`-Hinweis**: Bereits Shared-Library-Muster; gutes Vorbild für weitere Splits.

### `reta-mojo-domain-probe`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/domain_probe_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-domain-probe`
- **Kurz**: Native Domain-Probe für Parameter-, Alias-, Spalten- und HTML-Domainfragen.
- **Lang**: Dieses Binary ersetzt Python-Probe-Logik für Fragen wie Hauptparameter, Unterparameter, Aliasauflösung, Spaltenmetadaten und teilweise HTML-Nutzlasten. Es dient stark der Parität und Analyse. Für `.so/.dll` wäre es eher Client einer späteren Schema-/Domain-Library, nicht selbst Kernbibliothek.
- **`.so/.dll`-Hinweis**: Eher CLI-/Diagnosewerkzeug; nur bei Bedarf in eine gemeinsame Library ziehen.

### `reta-mojo-architecture-probe`

- **Build**: `scripts/build.sh, linkt libcrypto`
- **Quelle/Entrypoint**: `src/architecture_probe_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-architecture-probe`
- **Kurz**: Native Architektur-Probe für generierte Probe-Assets.
- **Lang**: Dieses Ziel liefert Architektur-Inspektionsdaten, Asset-Inhalte und Manifestinformationen. Es ist wichtig für Regression und Parität, aber nicht für normale `reta`-Ausführung. Für `.so/.dll` gehört es in `libreta-architecture` oder `libreta-diagnostics`, nicht in `libreta_core_mojo`.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-combi-join`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/combi_join_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-combi-join`
- **Kurz**: Diagnose-CLI für Kombinations-/Galaxy-/Universe-Join-Logik.
- **Lang**: Dieses Binary inspiziert native Kombi-Join-Datenquellen, Relationstabellen, Kombinationen und Fingerprints. Es steht näher an echter Tabellenlogik als viele Architekturtools. Für Shared Libraries ist dies ein guter Kandidat für eine spätere `libreta-table` oder `libreta-combi`, weil die Kombi-Join-Algorithmen auch zur Laufzeit gebraucht werden.
- **`.so/.dll`-Hinweis**: Mittel- bis langfristiger Core-/Table-/Output-Kandidat; ABI erst nach Stabilisierung festlegen.

### `reta-native`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/reta_native_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-native`
- **Kurz**: Native Hauptausführung für bereits vollständig unterstützte historische `reta`-Argumente.
- **Lang**: Dieses Binary ruft `run_native_reta(...)` direkt auf und ist der wichtigste Kandidat für die spätere echte Python-freie Haupt-CLI. Es benutzt native CSV-Ressourcen und gibt den fertigen Tabellen-/Textoutput aus. Für `.so/.dll` sollte `reta-native` langfristig nur noch ein dünner CLI-Wrapper gegen `libreta_core_mojo` sein.
- **`.so/.dll`-Hinweis**: Mittel- bis langfristiger Core-/Table-/Output-Kandidat; ABI erst nach Stabilisierung festlegen.

### `reta-mojo-compat-bin`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/compat_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-compat, bin/reta`
- **Kurz**: Native-first Kompatibilitätsstarter für die historische `reta`-CLI mit atomischem Python-Fallback.
- **Lang**: Dieses Ziel prüft zuerst, ob die Argumente nativ vollständig besessen werden. Wenn ja, läuft die native Engine; wenn nein, wird der Python-Referenzprozess atomisch gestartet. Es bettet kein CPython ein. Für `.so/.dll` ist es während der Transpilierung unverzichtbar, aber später sollte es verschwinden oder nur noch als Sicherheits-/Fallback-Wrapper bleiben.
- **`.so/.dll`-Hinweis**: Eher CLI-/Diagnosewerkzeug; nur bei Bedarf in eine gemeinsame Library ziehen.

### `reta-prompt-native`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/prompt_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/retaPrompt, bin/rp, bin/rpl, bin/rpb, bin/rpe`
- **Kurz**: Nativer Controller für `retaPrompt` und Prompt-Profile.
- **Lang**: Dieses Binary ist der native Prompt-Controller für interaktive und one-shot Prompt-Profile. Es besitzt Prompt-Profile, State, History-Policy, viele Dispatch-Pläne, native Tabellenpfade und explizite externe Prozessgrenzen. Weil dort noch Endspiel-Arbeit passiert, sollte dieser Bereich noch nicht früh als `.so/.dll` eingefroren werden.
- **`.so/.dll`-Hinweis**: Mittel- bis langfristiger Core-/Table-/Output-Kandidat; ABI erst nach Stabilisierung festlegen.

### `reta-prompt-complete`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/prompt_completion_main.mojo`
- **Launcher/öffentlicher Zugriff**: `interner Worker für Prompt-Completion`
- **Kurz**: Persistenter nativer Nested-Completion-Worker für GNU readline.
- **Lang**: Dieses Ziel ersetzt Python-Completion-Logik: Kontextübergänge, fuzzy matching, Kandidatenreihenfolge und Pipe-Bytes laufen in Mojo. Der Python-/Shell-Anteil verwaltet höchstens Terminalcallback und Prozesslebenszyklus. Für Shared Libraries kann Completion später in eine eigene `libreta_prompt_mojo` oder `libreta-completion` wandern, muss aber nicht in die Haupt-Core-Library.
- **`.so/.dll`-Hinweis**: Eher CLI-/Diagnosewerkzeug; nur bei Bedarf in eine gemeinsame Library ziehen.

### `grundStrukHtml-native`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/grundstruk_html_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/grundStrukHtml, bin/grundStrukHtml.py`
- **Kurz**: Nativer Generator für Grundstrukturen-HTML.
- **Lang**: Dieses Binary rendert die Grundstrukturen-HTML-Seite in den unterstützten Sprachen. Die `.py`-Launcher-Variante ist nur historische Namenskompatibilität. Für `.so/.dll` ist es ein guter Kandidat für eine spätere kleine Render-/Asset-Library, aber es ist nicht kritisch für die Haupt-CLI.
- **`.so/.dll`-Hinweis**: Mittel- bis langfristiger Core-/Table-/Output-Kandidat; ABI erst nach Stabilisierung festlegen.

### `generate-html-native`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/generate_html_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/generate_html`
- **Kurz**: Professioneller nativer HTML-Gesamtgenerator für Reta-Seiten.
- **Lang**: Dieses Ziel erzeugt die vollständige HTML-Seite, optional mit vorhandener oder neu erzeugter Mitteltabelle. Die Seitenmontage ist nativ; der historische `-spalten --alles`-Mittelteil kann weiterhin Referenz-/Kompatibilitätsdaten nutzen. Für `.so/.dll` sollte man hier später die HTML-Renderer- und Datenladegrenze sauber trennen.
- **`.so/.dll`-Hinweis**: Mittel- bis langfristiger Core-/Table-/Output-Kandidat; ABI erst nach Stabilisierung festlegen.

### `generate-readme-native`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/generate_readme_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/generate4readme`
- **Kurz**: Nativer README-/Dokumentgenerator.
- **Lang**: Dieses Binary generiert README-Dokumente bzw. Dokumentzusammenfassungen in unterstützten Sprachen. Es ist Build-/Release-Hilfslogik, nicht Laufzeitkern. Für Shared Libraries eher unwichtig; es kann ein CLI-Tool bleiben oder später gegen `libreta-i18n`/Asset-Funktionen linken.
- **`.so/.dll`-Hinweis**: Mittel- bis langfristiger Core-/Table-/Output-Kandidat; ABI erst nach Stabilisierung festlegen.

### `reta-extract-html-classes-native`

- **Build**: `scripts/build.sh`
- **Quelle/Entrypoint**: `src/extract_html_classes_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-extract-html-classes`
- **Kurz**: Extrahiert HTML-Klassen/Zellmetadaten aus Reta-HTML-Ausgabe.
- **Lang**: Dieses Ziel erzeugt bzw. liest HTML-Ausgabe und extrahiert daraus Klassen- und Zellinformationen für Tests, CSS-/HTML-Parität und Analyse. Es ist ein Prüf-/Build-Hilfswerkzeug. Für `.so/.dll` sollte die HTML-Parsing-/Metadata-Logik höchstens in eine Diagnosebibliothek, nicht in den Core.
- **`.so/.dll`-Hinweis**: Mittel- bis langfristiger Core-/Table-/Output-Kandidat; ABI erst nach Stabilisierung festlegen.

## Schwere Target-Binaries aus `scripts/build-heavy.sh`

### `reta-mojo-semantics`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/semantics_builder_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-semantics`
- **Kurz**: Vollständige native Parametersemantik und kanonische Wörterbücher.
- **Lang**: Dieses schwere Ziel baut bzw. inspiziert die vollständigen kanonischen Parametersemantik-Dictionaries. Es ist groß, datenlastig und ein zentraler Grund für lange Kompilierzeiten. Für `.so/.dll` ist es ein starker Kandidat für `libreta-semantics` oder `libreta-schema`, sobald sich die Semantik nicht mehr ändert.
- **`.so/.dll`-Hinweis**: Guter Library-Kandidat, sobald Datenvertrag stabil bleibt.

### `reta-mojo-schema`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/schema_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo / Schema-Modus`
- **Kurz**: Schweres natives Parameterschema.
- **Lang**: Dieses Binary enthält den vollständigen Reta-Parameterschema-Katalog mit Aliasauflösung, Spaltenoptionen und Prompt-Vokabular. Es ist compile-schwer und relativ stabil. Für `.so/.dll` ist es wahrscheinlich einer der besten Split-Kandidaten, weil viele Tools Schema brauchen, aber nicht selbst neu kompilieren sollten.
- **`.so/.dll`-Hinweis**: Guter Library-Kandidat, sobald Datenvertrag stabil bleibt.

### `reta-mojo-architecture`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/architecture_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo / Architektur-Modus`
- **Kurz**: Schwerer generierter Kategorie-/Architekturkatalog.
- **Lang**: Dieses Ziel lädt den großen Category-Theory-/Architekturkatalog und gibt Zählungen für Kategorien, Funktoren, natürliche Transformationen und Paradigmenbegriffe aus. Es ist eindeutig Metadaten-/Architekturdiagnostik. Für Shared Libraries: guter Kandidat für `libreta-architecture`, aber erst nach Stabilisierung der Architekturflächen.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-boundaries`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/architecture_boundaries_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-boundaries`
- **Kurz**: Nativer Architektur-Grenzgraph.
- **Lang**: Dieses Programm beantwortet Fragen zu Modulen, Kapseln, Owners, Boundary-Graphen und Diagrammen. Es hilft zu sehen, welche Python-Flächen durch welche Mojo-Owner ersetzt sind. Für `.so/.dll` ist es Architekturdiagnostik und sollte mit Contracts, Witnesses, Traces und Impact in einen gemeinsamen Architekturblock.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-contracts`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/architecture_contracts_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-contracts`
- **Kurz**: Native kommutierende Architekturverträge.
- **Lang**: Dieses Ziel enthält die generierten Verträge, Diagramme, Kapselverträge und Refactor-Laws. Es ist für Beweisbarkeit und Regression wichtig, aber nicht für die normale Ausgabe. Für Shared Libraries gehört es klar in `libreta-architecture-diagnostics`.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-witnesses`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/architecture_witnesses_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-witnesses`
- **Kurz**: Native Architektur-Witnesses/Belege.
- **Lang**: Dieses Binary liefert symbolische oder konkrete Belege für Architekturgesetze und Refactor-Behauptungen. Es ist compile-schwer und testorientiert. Für `.so/.dll` würde ich es nicht in den Runtime-Core nehmen, sondern nur in eine optionale Diagnose-/Audit-Library.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-coherence`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/architecture_coherence_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-coherence`
- **Kurz**: Native Kohärenzmatrix der Architektur.
- **Lang**: Dieses Ziel prüft Kapsel-, Routen-, Transformations- und Law-Kohärenz. Es beantwortet, ob die Architekturabbildungen zusammenpassen. Für Shared Libraries gehört es zu Architektur-Audit, nicht zu Core-CLI.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-traces`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/architecture_traces_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-traces`
- **Kurz**: Native Architektur-Traces.
- **Lang**: Dieses Programm macht Trace-Routen durch die Architektur sichtbar: von Quellen über Kapseln und Diagramme zu Owners oder Gates. Es hilft besonders bei Refactors. Für `.so/.dll` als Teil einer Diagnosebibliothek sinnvoll; für Endnutzer nicht nötig.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-impact`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/architecture_impact_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-impact`
- **Kurz**: Nativer Impact-Kalkül für Architekturänderungen.
- **Lang**: Dieses Ziel zeigt, welche Owners, Gates oder Migrationen durch Änderungen betroffen wären. Es ist wichtig, wenn du später `.so/.dll`-Grenzen ziehst, weil es Impact-Routen sichtbar macht. Es sollte aber eher Analysewerkzeug bleiben als Runtime-Bibliothek.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-migration`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/architecture_migration_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-migration`
- **Kurz**: Nativer Migrationsplan.
- **Lang**: Dieses Binary enthält Wellen, Schritte und Owner-Schritte der Transpilierungs-/Architektur-Migration. Es ist ein Planungswerkzeug. Für `.so/.dll` später nicht in den Core, aber hilfreich, um Split-Reihenfolgen zu planen.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-rehearsal`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/architecture_rehearsal_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-rehearsal`
- **Kurz**: Native Rehearsal-/Trockenlauf-Schicht für Architekturänderungen.
- **Lang**: Dieses Ziel modelliert vorbereitende Trockenläufe vor Aktivierung/Migration. Es ist stärker Prozess- und Auditlogik als Laufzeit. Für Shared Libraries gehört es in Architekturdiagnostik oder bleibt ein eigenständiges Tool.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-activation`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/architecture_activation_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-activation`
- **Kurz**: Native Aktivierungsschicht für geplante Architekturänderungen.
- **Lang**: Dieses Programm fragt Aktivierungsfenster, Units, Gates, Rollbacks und Transaktionen ab. Es ist ein Verwaltungs-/Migrationswerkzeug. Für `.so/.dll` sollte es nicht im Runtime-Core liegen.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-validation`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/architecture_validation_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-validation`
- **Kurz**: Native Architektur-Gesamtvalidierung.
- **Lang**: Dieses Ziel prüft Validierungsregeln über die Architektur und Migration hinweg. Es ist sehr wichtig für Qualitätssicherung. Für Shared Libraries ist es ein Diagnose-/CI-Kandidat, nicht Endnutzerlaufzeit.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-progress`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/architecture_progress_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-progress`
- **Kurz**: Natives Fortschritts-Overlay der Portierung.
- **Lang**: Dieses Binary zeigt Fortschritt, Metriken und ggf. offene Flächen in der Architektur-Migration. Es ist ein Projektsteuerungswerkzeug. Für `.so/.dll` später nicht kritisch.
- **`.so/.dll`-Hinweis**: Eher Architektur-/Diagnose-Library, nicht Runtime-Core.

### `reta-mojo-persistence`

- **Build**: `scripts/build-heavy.sh, linkt sqlite3 und crypto`
- **Quelle/Entrypoint**: `src/architecture_persistence_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-persistence`
- **Kurz**: Native SQLite-Persistenz und Cache-/Audit-Fläche.
- **Lang**: Dieses Ziel verwaltet native Persistenz: Öffnen, Speichern, Cache, Audit-Events, stabile Digests und Sheaf-Snapshots. Wegen SQLite/crypto ist es ein klarer separater Library-Kandidat. Wenn du `.so/.dll` splittest, sollte Persistenz getrennt bleiben, damit der Core ohne DB-Abhängigkeiten baubar ist.
- **`.so/.dll`-Hinweis**: Eher CLI-/Diagnosewerkzeug; nur bei Bedarf in eine gemeinsame Library ziehen.

### `reta-mojo-execution-network`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/architecture_execution_network_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-execution-network`
- **Kurz**: Deterministisches natives Ausführungsnetz.
- **Lang**: Dieses Binary testet und demonstriert Tasks, Reihenfolge, Halb-/Vollduplex-Kanäle und deterministische Reduktion. Es ist parallelitäts-/architekturbezogen. Für Shared Libraries kann es in eine optionale `libreta-execution` wandern, aber nicht in den ersten Core-Split.
- **`.so/.dll`-Hinweis**: Eher CLI-/Diagnosewerkzeug; nur bei Bedarf in eine gemeinsame Library ziehen.

### `reta-mojo-parallel-execution`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/architecture_parallel_execution_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-parallel-execution`
- **Kurz**: Native Thread-Tabellenparallelisierung.
- **Lang**: Dieses Ziel bündelt parallele Dekodierung, Faktorberechnung, Zeilenfilter und Konfiguration. Es ist performance-relevant, aber ABI-sensibel. Für `.so/.dll` später sinnvoll, aber erst wenn die Datenstrukturen über die Grenze als einfache Bytes/JSON/argv oder C-kompatible Strukturen definiert sind.
- **`.so/.dll`-Hinweis**: Eher CLI-/Diagnosewerkzeug; nur bei Bedarf in eine gemeinsame Library ziehen.

### `reta-mojo-row-preparation`

- **Build**: `scripts/build-heavy.sh`
- **Quelle/Entrypoint**: `src/architecture_parallel_row_preparation_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-row-preparation`
- **Kurz**: Typisierte threaded Prepare-row-Pipeline.
- **Lang**: Dieses Binary prüft parallele Zeilenvorbereitung, Row-Konfiguration und Wrapping-Kontext. Es hängt an Tabellenkern und Parallelisierung. Für Shared Libraries eher später, zusammen mit `libreta-table`, nicht als erste Library.
- **`.so/.dll`-Hinweis**: Eher CLI-/Diagnosewerkzeug; nur bei Bedarf in eine gemeinsame Library ziehen.

## Optionale Standalone-Diagnose-Targets

### `reta-mojo-table-generation`

- **Build**: `optional: RETA_BUILD_STANDALONE_DIAGNOSTICS=1, sonst Subcommand von reta-mojo-diagnostics`
- **Quelle/Entrypoint**: `src/table_generation_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-table-generation`
- **Kurz**: Diagnose für Table-Generation/Gluing.
- **Lang**: Standardmäßig wird dieses Ziel nicht als eigenes Executable behalten, sondern über `reta-mojo-diagnostics table-generation` aus der Shared Library bedient. Als Standalone ist es nur nützlich, wenn man diese Fläche isoliert debuggen will. Für `.so/.dll` zeigt es, dass table-generation gut als Diagnose-ABI exportierbar ist.
- **`.so/.dll`-Hinweis**: Mittel- bis langfristiger Core-/Table-/Output-Kandidat; ABI erst nach Stabilisierung festlegen.

### `reta-mojo-output-syntax`

- **Build**: `optional: Standalone oder Subcommand von reta-mojo-diagnostics`
- **Quelle/Entrypoint**: `src/output_syntax_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-output-syntax`
- **Kurz**: Diagnose für Output-Semantik und Ausgabesyntax.
- **Lang**: Dieses Ziel prüft Output-Modi, Syntax-Bündel und Renderer-Zustände. Es ist standardmäßig Teil der Diagnose-Shared-Library. Für spätere Splits ist es ein Kandidat für `libreta-render` oder `libreta-output`.
- **`.so/.dll`-Hinweis**: Mittel- bis langfristiger Core-/Table-/Output-Kandidat; ABI erst nach Stabilisierung festlegen.

### `reta-mojo-console-io`

- **Build**: `optional: Standalone oder Subcommand von reta-mojo-diagnostics`
- **Quelle/Entrypoint**: `src/console_io_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-console-io`
- **Kurz**: Diagnose für Console-IO, Wrapping und kleine Utility-Ausgaben.
- **Lang**: Diese Fläche enthält Console-/Help-/Utility-Logik und wird standardmäßig über die Diagnose-Shared-Library angeboten. Für `.so/.dll` ist sie optional; Core sollte nicht unnötig von Terminaldetails abhängen.
- **`.so/.dll`-Hinweis**: Eher CLI-/Diagnosewerkzeug; nur bei Bedarf in eine gemeinsame Library ziehen.

### `reta-mojo-table-output`

- **Build**: `optional: Standalone oder Subcommand von reta-mojo-diagnostics`
- **Quelle/Entrypoint**: `src/table_output_main.mojo`
- **Launcher/öffentlicher Zugriff**: `bin/reta-mojo-table-output`
- **Kurz**: Diagnose für den kompletten TableOutput-Owner.
- **Lang**: Dieses Ziel prüft Tabellenausgabe, Buffer, no-heading/no-numbering, CLI-Out und Renderer-Ergebnis. Für Shared Libraries ist das perspektivisch wichtig, weil Output groß und stabil genug für einen `libreta-render`-Block sein könnte.
- **`.so/.dll`-Hinweis**: Mittel- bis langfristiger Core-/Table-/Output-Kandidat; ABI erst nach Stabilisierung festlegen.

## Aktuelle Shared Library

### `libreta_diagnostics_mojo.so`

- **Build**: `scripts/build_diagnostics_shared.sh`, indirekt aus `scripts/build.sh`.
- **Quelle/Entrypoint**: `src/reta_diagnostics_abi.mojo`.
- **Loader**: `target/bin/reta-mojo-diagnostics`, gebaut aus `tools/reta_mojo_diagnostics_loader.c`.
- **Kurz**: Gemeinsame Mojo-Shared-Library für mehrere Diagnoseflächen.
- **Lang**: Diese Library ist der erste echte Beleg, dass dein Projekt nicht nur einzelne Mojo-Executables bauen kann, sondern auch eine gemeinsam geladene native Bibliothek. Sie exportiert eine schmale C-ABI und bündelt aktuell Diagnosefunktionen wie Table-Generation, Output-Syntax, Console-IO und Table-Output. Der C-Loader benutzt `dlopen`/`dlsym`-artige Mechanik und startet die gewünschte Diagnosefläche per Subcommand.
- **`.so/.dll`-Hinweis**: Dieses Muster ist das beste vorhandene Vorbild für spätere Splits. Für Windows muss aus demselben Prinzip eine `.dll` plus kleiner Loader oder direkter Import entstehen. Die ABI sollte weiterhin klein bleiben: Strings/argv/Bytes/Exit-Code statt komplexer Mojo-Structs.

## Öffentliche Launcher in `bin/`

### `bin/reta`

- **Typ**: Shell-Launcher
- **Kurz**: Startet standardmäßig `reta-mojo-compat`; mit `RETA_NATIVE=1` startet er `reta-native`.
- **Lang**: Historischer Hauptname. Dieser Launcher ist wichtig für Nutzer, aber keine Mojo-Binary. Für spätere Installation sollte er nur ein dünner Wrapper bleiben.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/reta.sh`

- **Typ**: Shell-Launcher
- **Kurz**: Alias/Variante von `bin/reta` mit derselben Auswahl zwischen Kompatibilität und Native.
- **Lang**: Historische Namenskompatibilität. Für `.so/.dll` irrelevant, solange er nur den eigentlichen Loader startet.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/reta.english`

- **Typ**: Shell-Launcher
- **Kurz**: Startet `reta-mojo-compat -language=english`.
- **Lang**: Englischer historischer Einstieg. Kann später direkt auf `reta-native` gehen, wenn Sprachstart vollständig nativ abgesichert ist.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/reta-mojo`

- **Typ**: Shell-Launcher
- **Kurz**: Multiplexer für `reta-mojo-native`, Schema, Architektur, Tags und Table-Diagnosen.
- **Lang**: Entwicklungs-/Debug-Frontend. Nicht als Library-Grenze verwenden; es sollte nur passende Zielprogramme starten.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/reta-mojo-compat`

- **Typ**: Shell-Launcher
- **Kurz**: Startet `target/bin/reta-mojo-compat-bin` oder fällt auf `mojo run src/compat_main.mojo` zurück.
- **Lang**: Wichtiger Übergangslauncher. Sobald 92/92 erreicht ist, kann er schrittweise weniger wichtig werden.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/reta-native`

- **Typ**: Shell-Launcher
- **Kurz**: Startet `target/bin/reta-native` oder fällt auf `mojo run src/reta_native_main.mojo` zurück.
- **Lang**: Das ist der direkte Launcher für die native Hauptausführung. Später idealerweise der Standard hinter `bin/reta`.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/retaPrompt`

- **Typ**: Shell-Launcher
- **Kurz**: Profil-Launcher für `reta-prompt-native` mit Profilname `retaPrompt`.
- **Lang**: Historischer Prompt-Einstieg. Er setzt Referenz-Python für explizite Python/math-Kompatibilität und atomische Fallbacks.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/retaPrompt.english`

- **Typ**: Shell-Launcher
- **Kurz**: Profil-Launcher für englischen Prompt.
- **Lang**: Wie `retaPrompt`, aber mit englischem Profil/Namenskontext.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/rp`

- **Typ**: Shell-Launcher
- **Kurz**: Prompt-Profil `rp`.
- **Lang**: Interaktiver oder profilierter Prompt-Einstieg. Teilt sich dasselbe native Binary `reta-prompt-native`.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/rpl`

- **Typ**: Shell-Launcher
- **Kurz**: Prompt-Profil `rpl`.
- **Lang**: Historisches Prompt-Profil, typischerweise mit Log-/Readline-Verhalten. Genaues Verhalten kommt aus `prompt_runtime`.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/rpb`

- **Typ**: Shell-Launcher
- **Kurz**: Prompt-Profil `rpb`; Kurzbefehle wie `prim`, `modulo`, `math` leiten hier hinein.
- **Lang**: Wichtig für one-shot/command-artige Prompt-Nutzung. Kein eigenes Mojo-Binary, sondern Profilargument an `reta-prompt-native`.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/rpe`

- **Typ**: Shell-Launcher
- **Kurz**: Prompt-Profil `rpe`; enthält emacs-/one-shot-artige Flags.
- **Lang**: Dieses Profil war zuletzt relevant für Fallback-argv-Tests: es erzeugt Profilflags wie `-vi`, `-e`, `-befehl`.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/rp.sh, bin/rpl.sh`

- **Typ**: Shell-Launcher
- **Kurz**: Historische `.sh`-Aliasnamen für Promptprofile.
- **Lang**: Nur Namenskompatibilität. Für `.so/.dll` nicht relevant.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/prim, bin/prim24, bin/multis, bin/multis3, bin/modulo, bin/math`

- **Typ**: Shell-Launcher
- **Kurz**: Leiten Kurzbefehle an `bin/rpb` weiter.
- **Lang**: Diese Namen sind bequeme historische Mini-Commands. Sie sollten keine eigenen Libraries bekommen, sondern immer dünne Frontends bleiben.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/grundStrukHtml, bin/grundStrukHtml.py`

- **Typ**: Shell-Launcher
- **Kurz**: Starten `grundStrukHtml-native` oder `mojo run src/grundstruk_html_main.mojo`.
- **Lang**: Die `.py`-Variante ist nur Namenskompatibilität. Logik steckt im nativen Target.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/generate_html`

- **Typ**: Shell-Launcher
- **Kurz**: Professioneller Frontend-Wrapper für `generate-html-native` mit Optionen für Output, Sprache, Middle-Datei, Assets und No-Clobber.
- **Lang**: Dieser Wrapper enthält mehr FHS-/Dateisystemkomfort als die meisten anderen. Die Rechenlogik steckt im nativen Target.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/generate4readme`

- **Typ**: Shell-Launcher
- **Kurz**: Startet `generate-readme-native`.
- **Lang**: Release-/Dokumentationshelfer.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/reta-extract-html-classes`

- **Typ**: Shell-Launcher
- **Kurz**: Startet `reta-extract-html-classes-native`.
- **Lang**: Build-/Testhilfsprogramm für HTML-Klassenextraktion.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/mojo-real`

- **Typ**: Shell-Launcher
- **Kurz**: Findet den echten Modular-Mojo-Compiler und vermeidet den falschen Snap-Namenskonflikt.
- **Lang**: Kein Reta-Programm. Für Build und Fallback-`mojo run` wichtig. Nicht in `.so/.dll` einbeziehen.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

### `bin/mojo-runtime-exec`

- **Typ**: Shell-Launcher
- **Kurz**: Setzt Ressourcen-/Runtime-Umgebung und startet kompilierte ELF-Ziele.
- **Lang**: Sehr wichtig für installierte Layouts: setzt `RETA_ROOT`, `RETA_REFERENCE_DIR`, `RETA_SHARE_DIR`, `RETA_DATA_DIR` usw. Spätere `.so/.dll`-Loader sollten diese Ressourcenlogik entweder übernehmen oder sauber ersetzen.
- **`.so/.dll`-Hinweis**: Launcher sollten später möglichst dünn bleiben und nur Loader-/Pfad-/Profilaufgaben übernehmen.

## `bin/reta-mojo-*`-Wrapper, die nur ein Target starten

Viele `bin/reta-mojo-*` Dateien sind keine eigenen kompilierten Programme, sondern Shell-Wrapper auf gleichnamige Targets. Die wichtigsten:

| Launcher | Target/Subcommand | Build | Zweck |
|---|---|---|---|
| `bin/reta-mojo-activation` | `target/bin/reta-mojo-activation` | `build-heavy.sh` | Aktivierungsabfragen |
| `bin/reta-mojo-boundaries` | `target/bin/reta-mojo-boundaries` | `build-heavy.sh` | Boundary-Graph |
| `bin/reta-mojo-coherence` | `target/bin/reta-mojo-coherence` | `build-heavy.sh` | Kohärenzmatrix |
| `bin/reta-mojo-contracts` | `target/bin/reta-mojo-contracts` | `build-heavy.sh` | Architekturverträge |
| `bin/reta-mojo-execution-network` | `target/bin/reta-mojo-execution-network` | `build-heavy.sh` | Ausführungsnetz |
| `bin/reta-mojo-impact` | `target/bin/reta-mojo-impact` | `build-heavy.sh` | Impact-Kalkül |
| `bin/reta-mojo-migration` | `target/bin/reta-mojo-migration` | `build-heavy.sh` | Migrationsplan |
| `bin/reta-mojo-parallel-execution` | `target/bin/reta-mojo-parallel-execution` | `build-heavy.sh` | Thread-Parallelität |
| `bin/reta-mojo-persistence` | `target/bin/reta-mojo-persistence` | `build-heavy.sh` | SQLite-Persistenz |
| `bin/reta-mojo-progress` | `target/bin/reta-mojo-progress` | `build-heavy.sh` | Portierungsfortschritt |
| `bin/reta-mojo-rehearsal` | `target/bin/reta-mojo-rehearsal` | `build-heavy.sh` | Rehearsal/Trockenlauf |
| `bin/reta-mojo-row-preparation` | `target/bin/reta-mojo-row-preparation` | `build-heavy.sh` | Parallele Zeilenvorbereitung |
| `bin/reta-mojo-semantics` | `target/bin/reta-mojo-semantics` | `build-heavy.sh` | Parametersemantik |
| `bin/reta-mojo-traces` | `target/bin/reta-mojo-traces` | `build-heavy.sh` | Architektur-Traces |
| `bin/reta-mojo-validation` | `target/bin/reta-mojo-validation` | `build-heavy.sh` | Gesamtvalidierung |
| `bin/reta-mojo-witnesses` | `target/bin/reta-mojo-witnesses` | `build-heavy.sh` | Architektur-Witnesses |
| `bin/reta-mojo-console-io` | `target/bin/reta-mojo-diagnostics console-io` | `build.sh` | Diagnose-Shared-Library-Subcommand |
| `bin/reta-mojo-output-syntax` | `target/bin/reta-mojo-diagnostics output-syntax` | `build.sh` | Diagnose-Shared-Library-Subcommand |
| `bin/reta-mojo-table-generation` | `target/bin/reta-mojo-diagnostics table-generation` | `build.sh` | Diagnose-Shared-Library-Subcommand |
| `bin/reta-mojo-table-output` | `target/bin/reta-mojo-diagnostics table-output` | `build.sh` | Diagnose-Shared-Library-Subcommand |

## Priorisierte Split-Reihenfolge

### Phase A: sofort vorbereiten, wenig Risiko

1. `libreta-diagnostics`: vorhandene Diagnose-Shared-Library beibehalten und erweitern.
2. `libreta-i18n`: Sprach-/Wortkataloge aus `reta-mojo-i18n`.
3. `libreta-schema`: Schema, Semantik, Tags; aber nur mit schmaler API.

### Phase B: nach 92/92

1. `libreta_core_mojo`: `run_native_reta`, Workflow, native CLI-Planung.
2. `libreta-table`: CSV, Table-State, Table-Generation, Kombi-Join, Row-Preparation.
3. `libreta-render`: Output-Syntax, Table-Output, HTML/BBCode/Markdown/Emacs.

### Phase C: optional/CI/Audit

1. `libreta-architecture`: Architecture, Boundaries, Contracts, Witnesses, Coherence, Traces, Impact, Migration, Validation.
2. `libreta-persistence`: SQLite/crypto getrennt halten.
3. `libreta-parallel`: Thread-/Execution-Network nur, wenn ABI stabil und performance-relevant.

## Was nicht als eigene Library geplant werden sollte

- `prim`, `prim24`, `multis`, `multis3`, `modulo`, `math`: nur Kurzlauncher auf `rpb`.
- `rp`, `rpl`, `rpb`, `rpe`, `retaPrompt`: Profile, nicht eigene Engines.
- `reta-mojo-*` reine Wrapper: nicht als Library behandeln; nur ihre Target-Binaries zählen.
- Build-/Dokumentationshelfer wie `generate4readme`: nur bei Bedarf an i18n/Assets linken.

## Praktische ABI-Regeln für spätere `.so/.dll`

1. Keine komplexen Mojo-Structs über die Library-Grenze exportieren.
2. Bevorzugt: `argc/argv`, UTF-8-Bytes, JSON, Exit-Code, Datei-/Buffer-Ausgabe.
3. Ressourcenpfade explizit übergeben oder über eine kleine Runtime-Config initialisieren.
4. CLI-Executables bleiben dünne Loader; echte Logik sitzt in wenigen stabilen Libraries.
5. Linux `.so` und Windows `.dll` nicht zu früh vermischen: erst C-ABI stabilisieren, dann Windows-Loader bauen.

## Kurze Entscheidungshilfe

| Frage | Antwort |
|---|---|
| Braucht ein normaler Nutzer dieses Binary direkt? | Dann CLI-Launcher behalten, nicht zwingend Library. |
| Ist es compile-schwer und datenstabil? | Guter `.so/.dll`-Kandidat. |
| Ist es nur Architektur-/Auditlogik? | In Diagnose-/Architecture-Library, nicht Core. |
| Hängt es an SQLite/crypto? | Separat halten. |
| Ändert es sich noch in den letzten 3 Restflächen? | Noch nicht einfrieren. |

