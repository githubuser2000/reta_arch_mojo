# Stage 12c5fw – Prompt-Shared-Build- und Install-Smoke

Diese Stage zieht den in 12c5fv vorbereiteten Prompt-Shared-Runtime-Smoke in die
offiziellen Build- und Installationsprüfungen.  Die Shared-Library-Aufteilung
bleibt unverändert:

- `libreta_core_mojo.so` bleibt der gemeinsame Kern für `reta`, `grundStrukHtml` und
  die Prompt-Ausführung.
- `libreta_prompt_mojo.so` bleibt der gemeinsame Prompt-Ausführungskern für `rp`,
  `rpl`, `rpe` und `rpb`.
- `libreta_prompt_interactive_mojo.so` bleibt ausschließlich für `rp`, `rpl` und
  `rpe` zuständig.
- `rpb` darf weiterhin keine interaktive Prompt-Bibliothek laden.

## Neue Build-Sicherung

`scripts/build-all.sh` führt nach erfolgreichem vollständigem Build und nach
`scripts/check_build_layout.sh` den kurzen Prompt-Shared-Runtime-Smoke aus:

```sh
scripts/test_prompt_shared_runtime.sh
```

Der Smoke kann nur für Diagnose- oder Bootstrapping-Situationen übersprungen
werden:

```sh
RETA_SKIP_PROMPT_SHARED_RUNTIME_SMOKE=1 scripts/build-all.sh -- -j 8
```

## Neue Install-Sicherung

`scripts/check_install_layout.sh` prüft nun nicht nur, ob die Prompt-Starter und
Bibliotheken installiert wurden, sondern führt den Runtime-Smoke auf dem
installierten privaten Zielbaum aus:

```sh
RETA_TARGET_DIR="$STAGE/usr/lib/reta/target/bin" \
RETA_TARGET_LIB_DIR="$STAGE/usr/lib/reta/target/lib/reta" \
    scripts/test_prompt_shared_runtime.sh
```

Zusätzlich wird der öffentliche installierte `rpb`-Launcher mit absichtlich
kaputter interaktiver Bibliothek geprüft.  Dadurch bleibt die wichtigste
Architekturregel ausführbar nachgewiesen:

```text
rpb -> libreta_prompt_mojo.so
rpb -> NICHT libreta_prompt_interactive_mojo.so
```

## Erwartete lokale Kommandos

```sh
scripts/build-all.sh -- -j 8 \
  2>&1 | tee build-all.txt
scripts/build-tests.sh -- -j 8 \
  2>&1 | tee build-tests.txt
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5fw.sh -- -j 6 \
  2>&1 | tee test_stage12c5fw.txt
scripts/run-tests.sh \
  2>&1 | tee run-tests.txt
```
