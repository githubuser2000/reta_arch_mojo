# Stage 12c5cs – legacy bridge reta argument ownership

## Ziel

Die historische `mojo_bridge.py`-Kompatibilitätsfunktion `run_reta_line`
soll keine rohe `reta`-Zeile mehr an einen zweiten line-basierten nativen
Adapter weiterreichen. Die Zeile wird nur noch einmal mit dem bereits nativen
`prompt_external_commands.shell_split` zerlegt und danach als argv-Vektor an
`run_reta_arguments_native` übergeben.

## Änderung

- `legacy_mojo_bridge.run_reta_line` nutzt jetzt `shell_split(line)` plus
  `_reta_child_arguments(...)`.
- Der direkte Aufruf von `run_reta_line_native` verschwindet aus
  `legacy_mojo_bridge.mojo`.
- Der Legacy-Bridge-Snapshot enthält `reta_line_bridge=native-argv-owner`.
- Die älteren Prompt-External-Source-Guards wurden an die bereits erreichte
  Payload-/Argument-Ownership der vorherigen Stages angepasst.

## Bedeutung

Der rohzeilenbasierte Adapter bleibt als externe Kompatibilitätsfläche im
OS-Adapter verfügbar, aber die alte `mojo_bridge.py`-Fassade besitzt nun auch
für `reta`-Zeilen den argv-Vektor selbst. Damit ist eine weitere
Kompatibilitätskante vom alten Python-Brückenmodell auf den nativen
Argument-Owner geschoben.
