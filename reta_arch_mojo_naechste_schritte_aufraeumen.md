# Welche alle Schritte sollten noch kommen? Aufräumarbeiten u.a.?

Ja. Grob gesagt seid ihr jetzt bei: **native Core-/Prompt-Shared-Library-Architektur steht**, aber sie muss noch stabilisiert, installiert, bereinigt und gegen Altpfade abgesichert werden. Die Logs zeigen: `build-tests` bleibt bei **133 Programmen**, `run-tests` läuft großflächig grün, und der Release-Check-Plan enthält bereits Build, Installlayout, Paritätschecks und volle Mojo-Test-Suite.

## 1. Sofort als Nächstes

Zuerst muss **12c5fy** getestet werden, weil dort der Smoke-Test-Fix für die absichtlich kaputte Prompt-Library drin ist.

```bash
scripts/build-all.sh -- -j 8 2>&1 | tee build-all.txt && scripts/build-tests.sh -- -j 8 2>&1 | tee build-tests.txt && RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5fy.sh -- -j 6 2>&1 | tee test_stage12c5fy.txt && scripts/run-tests.sh 2>&1 | tee run-tests.txt
```

Danach:

```bash
scripts/release_check.sh --dry-run -- -j 8 | tee release-check-plan.txt
scripts/release_check.sh -- -j 8 2>&1 | tee release-check.txt
```

Der Dry-run-Plan zeigt schon, dass `release_check.sh` Build, Buildlayout, Installlayout, viele Katalog-/Paritätschecks und am Ende die volle Mojo-Test-Suite ausführen soll.

## 2. Release-/Installations-Arbeiten

Danach sollte das Installationssystem fertig gemacht werden:

```text
install.sh
check_install_layout.sh
release_check.sh
uninstall.sh oder install --manifest
DESTDIR-Test
/usr/bin-Launcher-Test
/usr/lib/reta-Library-Test
Sidecar-/Source-ID-Prüfung
```

Wichtig ist: nicht nur `target/bin/...` muss funktionieren, sondern auch ein installierter Baum wie:

```text
/usr/bin/reta
/usr/bin/grundStrukHtml
/usr/bin/rp
/usr/bin/rpl
/usr/bin/rpe
/usr/bin/rpb

/usr/lib/reta/target/lib/reta/libreta_core_mojo.so
/usr/lib/reta/target/lib/reta/libreta_prompt_mojo.so
/usr/lib/reta/target/lib/reta/libreta_prompt_interactive_mojo.so
```

## 3. Öffentliche Starter endgültig festlegen

Dann klären:

```text
Bleiben soll:
  reta
  grundStrukHtml
  rp
  rpl
  rpe
  rpb

Nur intern/diagnostisch:
  reta-native
  grundStrukHtml-native
  reta-mojo-compat-bin
  reta-prompt-native
  reta-prompt-complete
  reta-mojo-*
```

Mein Vorschlag: **nicht sofort löschen**. Erst in `install_targets.txt` klar trennen:

```text
public
diagnostic
internal
legacy
test-only
```

Danach kann man entscheiden, was wirklich nach `/usr/bin` darf.

## 4. Aufräumarbeiten in Skripten

Das ist jetzt wichtig, weil sehr viele Stages Skripte ergänzt haben:

```text
scripts/build.sh
scripts/build-heavy.sh
scripts/build-all.sh
scripts/build_core_shared.sh
scripts/build_prompt_shared.sh
scripts/build_shared_library_targets.sh
scripts/check_build_layout.sh
scripts/check_install_layout.sh
scripts/release_check.sh
scripts/test_current_stage.sh
```

Aufräumen heißt hier:

```text
1. gleiche Optionslogik überall
2. --dry-run überall gleich
3. -- -j 8 überall gleich durchreichen
4. Fehlermeldungen vereinheitlichen
5. keine doppelten Artifact-Listen
6. zentrale Datei für Zielartefakte
7. keine stillen grep/[...]-Fehler
8. klare Skip-Variablen dokumentieren
```

Zum Beispiel:

```text
RETA_SKIP_PROMPT_SHARED_RUNTIME_SMOKE=1
RETA_STAGE_SKIP_PREVIOUS=1
RETA_TEST_HEAVY=1
```

## 5. ABI-/Shared-Library-Stabilisierung

Jetzt gibt es echte `.so`-Grenzen. Dafür fehlen noch saubere Verträge:

```text
libreta_core_mojo.so ABI-Version
libreta_prompt_mojo.so ABI-Version
libreta_prompt_interactive_mojo.so ABI-Version
Symbolnamen dokumentieren
Fehlercodes dokumentieren
Source-ID-Sidecars finalisieren
Library-Suchpfade finalisieren
RPATH/RUNPATH-Strategie klären
```

Auch wichtig:

```text
Was passiert, wenn:
  .so fehlt?
  .so falsche Version hat?
  Sidecar fehlt?
  Sidecar nicht passt?
  Loader ohne LD_LIBRARY_PATH gestartet wird?
  installierter Launcher aus anderem Prefix gestartet wird?
```

## 6. Runtime-Parität der neuen dünnen Starter

Die dünnen Starter sollten gegen alte/native Pfade verglichen werden:

```bash
bin/reta -zeilen --vorhervonausschnitt=1 -spalten --alles
target/bin/reta -zeilen --vorhervonausschnitt=1 -spalten --alles
target/bin/reta-native -zeilen --vorhervonausschnitt=1 -spalten --alles
```

Für Prompt:

```bash
bin/rpb "prim 60"
target/bin/rpb "prim 60"
bin/rp
bin/rpl
bin/rpe
```

Tests sollten prüfen:

```text
rpb one-shot
rp interaktiv
rpl interaktiv + Logging
rpe interaktiv mit Emacs/Editor-Verhalten
Abbruch mit q
History/Session
externes Kommando
Ausgabearten html/csv/shell/markdown
```

## 7. Alte Kompatibilitätsbrücken reduzieren

Erst wenn die dünnen Starter stabil sind:

```text
reta-mojo-compat-bin zurückstufen
reta-native intern machen
grundStrukHtml-native intern machen
alte bin/-Shell-Fallbacks entfernen
Python-Fallbacks dokumentiert isolieren
```

Aber: **nicht voreilig löschen**. Lieber zuerst in Tests festhalten:

```text
öffentliche Starter dürfen keine alten Fallbacks nutzen
interne Diagnose-Binaries dürfen bleiben
```

## 8. Python-/Legacy-Aufräumliste

Du hattest ja auch gewünscht, Fehler zu dokumentieren, besonders wenn der Python-Code selbst Fehler hat. Deshalb sollte es weitergeben:

```text
KNOWN_DEFECTS.md
PYTHON_CLEANUP.md
TRANSPILE_LEDGER.md
ARCHITECTURE_MIGRATION.md
```

Deine Metrik steht weiter bei:

```text
169 bekannte Defekte
19 Python-Cleanup-Items
92/92 vollständig nativ/generiert
48831/48831 angegriffene Referenzzeilen
```

## 9. Dokumentation konsolidieren

Die vielen Stage-Dateien sind gut zum Entwickeln, aber später zu viel. Später zusammenführen in:

```text
docs/architecture/shared-libraries.md
docs/build.md
docs/install.md
docs/release-check.md
docs/binaries.md
docs/known-defects.md
```

Stage-Dateien können dann archiviert werden:

```text
docs/stages/STAGE12C5...
```

## 10. Paketierung vorbereiten

Danach erst Paketierung:

```text
tarball ohne .git
install.sh DESTDIR
uninstall oder install-manifest
Fedora/RPM-Vorbereitung
Arch PKGBUILD-Vorbereitung
Debian optional
Termux später separat
```

Noch nicht CMake/Meson erzwingen. Erst wenn Build-/Install-Ziele stabil sind.

## 11. Plattformen später

Später:

```text
Linux x86_64 zuerst final
Fedora/Gentoo/Alma prüfen
Termux extra, weil Shared-Libraries/Loaderpfade anders sind
Windows DLL erst später
macOS dylib erst später
```

## 12. Performance und echte Nutzung

Zum Schluss wieder praktische Befehle:

```text
reta --alles HTML
reta --alles CSV
grundStrukHtml
rpb prim 60
rp interaktiv
rpl Logging
rpe Editor-Modus
```

Und dann Performance:

```text
Startzeit
Speicherverbrauch
--alles Laufzeit
HTML UTF-8-Sicherheit
große Tabellen
Prompt-Latenz
```

## Meine empfohlene Reihenfolge

```text
1. 12c5fy lokal testen
2. release_check.sh echt laufen lassen
3. check_install_layout.sh hart machen
4. public/internal/diagnostic Binaries klassifizieren
5. install_targets.txt bereinigen
6. Runtime-Parität für reta/grundStrukHtml/rpb/rp/rpl/rpe
7. alte Fallbacks aus öffentlichen Launchern verbieten
8. Docs zusammenführen
9. Known defects / Python cleanup final sortieren
10. Release-Tarball ohne .git und mit Installtest
11. Paketierung vorbereiten
12. Plattformtests
```

Der wichtigste Satz: **Jetzt nicht mehr wild weiter transpilieren, sondern die neue Shared-Library-Architektur stabilisieren und aufräumen.** Das ist der Punkt, an dem ein Projekt sonst schnell unübersichtlich wird.
