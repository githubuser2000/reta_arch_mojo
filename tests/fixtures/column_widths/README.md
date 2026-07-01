# Individuelle Spaltenbreiten

Diese Dateien frieren die stdout-Bytes der Python-Referenz für positive
`--breiten=`-/`--widths=`-Listen ein. Der Vertrag umfasst Shell, HTML und
BBCode, deutsche und englische Syntax, globales `--breite=0` sowie das
historische Ersetzen einer früheren Breitenliste.

Aktualisierung nur bewusst mit:

```sh
RETA_REFRESH_COLUMN_WIDTH_FIXTURES=1 \
RETA_REFERENCE_PYTHON=/pfad/zur/referenz-python \
scripts/check_column_widths_parity.sh
```
