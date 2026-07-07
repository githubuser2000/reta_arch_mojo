# Stage 12c5fx – Release-Check sichert Installation und Shared-Library-Starter

Diese Stage zieht den neuen Core-/Prompt-Shared-Library-Strang in den
Release-Sicherheitsgurt.  `scripts/release_check.sh` prüft nicht mehr nur den
Buildbaum und die Katalog-/Paritätssuiten, sondern auch das installierte
`/usr`-Layout.

## Neuer Release-Ablauf

```text
scripts/release_check.sh
  -> scripts/build-all.sh -- ...
  -> scripts/check_build_layout.sh
  -> scripts/check_install_layout.sh
  -> Katalog-, Paritäts- und Prompt-Checks
  -> scripts/test_all.sh
```

`build-all.sh` baut bereits:

```text
target/lib/reta/libreta-core.so
target/lib/reta/libreta-prompt.so
target/lib/reta/libreta-prompt-interactive.so
target/bin/reta
target/bin/grundStrukHtml
target/bin/rp
target/bin/rpl
target/bin/rpe
target/bin/rpb
```

`check_install_layout.sh` installiert in einen temporären `DESTDIR`-Baum mit
`PREFIX=/usr` und prüft dort:

```text
/usr/bin/reta             -> privater dünner Core-Starter
/usr/bin/grundStrukHtml   -> privater dünner Core-Starter
/usr/bin/rpb              -> privater dünner Prompt-Starter ohne interactive .so
/usr/bin/rp/rpl/rpe       -> private interaktive Prompt-Starter
/usr/lib/reta/target/lib/reta/libreta-core.so
/usr/lib/reta/target/lib/reta/libreta-prompt.so
/usr/lib/reta/target/lib/reta/libreta-prompt-interactive.so
```

Außerdem läuft der Prompt-Shared-Runtime-Smoke im installierten Baum. Damit ist
`rpb` nicht nur im Buildbaum, sondern auch nach Installation gegen die falsche
Abhängigkeit auf `libreta-prompt-interactive.so` abgesichert.

## Dry-run

Zur schnellen Kontrolle ohne Build kann der Release-Plan ausgegeben werden:

```bash
scripts/release_check.sh --dry-run -- -j 8
```

Der Dry-run führt nichts aus, zeigt aber die Reihenfolge inklusive
`check_install_layout.sh`.

## Konsequenz

Vor einem Release reicht nicht mehr nur `scripts/build-all.sh`. Der harte
Paketierungscheck ist jetzt:

```bash
scripts/release_check.sh -- -j 8
```

Für normale Entwicklungsrunden bleibt weiterhin der schnelle Stage-Befehl
sinnvoll.
