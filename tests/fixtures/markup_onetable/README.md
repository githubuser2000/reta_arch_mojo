# Markup-oneTable-Referenzfixtures

Diese sechs Dateien wurden für Stage 12c4g mit `PYTHONHASHSEED=0` gegen die
projektlokale Python-Referenz bytegenau geprüft. Die normalen Release-Tests
starten nur den native-first Mojo-Launcher mit einem absichtlich ungültigen
`RETA_PYTHON`; dadurch sind die Tests schnell und beweisen zugleich, dass kein
unbemerkter Python-Fallback stattfindet.

Zum bewussten Neugenerieren aus Python:

```bash
RETA_REFRESH_MARKUP_ONETABLE_FIXTURES=1 \
  scripts/check_native_markup_onetable_parity.sh
```
