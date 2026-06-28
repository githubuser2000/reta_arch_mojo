# Markup-Referenzfixtures

Diese Dateien wurden am 28. Juni 2026 einzeln mit `PYTHONHASHSEED=0` gegen die projektlokale Python-Referenz validiert. Der normale Test startet nur `reta-native` und vergleicht dessen Bytes mit den Fixtures, damit wiederholte langsame Kaltstarts der Referenz den Release-Test nicht blockieren.

Neu erzeugen und unmittelbar gegen Python prüfen:

```bash
RETA_REFRESH_MARKUP_FIXTURES=1 ./scripts/check_markup_parity_extended.sh
```

Ohne diese Variable dürfen die Fixtures nicht automatisch überschrieben werden.
