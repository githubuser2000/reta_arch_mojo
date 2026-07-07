# Stage 12c5fr – Shared-Library-Architektur Copyability-Fix

12c5fo/fp/fq haben die gewünschte Shared-Library-Zielarchitektur eingeführt,
aber der Mojo-Test `test_shared_library_architecture.mojo` konnte lokal nicht
bauen, weil der Plan-Owner Listen und Target-Structs implizit kopierte.

Diese Stage macht den Plan strikt Mojo-kompatibel:

- `libraries` und `starters` werden beim Erzeugen des Plans explizit in den
  `SharedLibraryArchitecturePlan` übertragen.
- Die Starter-Anzahl wird vor dem Move berechnet.
- Validierungsschleifen kopieren `SharedLibraryTarget` explizit aus der Liste,
  statt einen impliziten Copy auszulösen.

Die fachliche Zielarchitektur bleibt unverändert:

```text
libreta-core.so / libreta-core.dll
  Verbraucher: reta, rp, rpl, rpe, rpb, grundStrukHtml

libreta-prompt.so / libreta-prompt.dll
  Verbraucher: rp, rpl, rpe, rpb
  Abhängigkeit: libreta-core

libreta-prompt-interactive.so / libreta-prompt-interactive.dll
  Verbraucher: rp, rpl, rpe
  Abhängigkeit: libreta-prompt
  Nicht verwendet von: rpb
```

Dies ist ein Reparatur-Stage für die Buildbarkeit der Shared-Library-Planstests;
kein neuer ABI-Schnitt wird erzwungen.
