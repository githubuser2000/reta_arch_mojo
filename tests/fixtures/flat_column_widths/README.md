# Individuelle Spaltenbreiten in flachen Ausgabeformaten

Diese Referenzströme frieren die stdout-Bytes der Python-Implementierung für
`--breiten=`/`--widths=` in CSV, Markdown und Emacs/Org ein. Der Vertrag
umfasst deutsche und englische Syntax, eine explizite Nullbreite sowie das
historische Ersetzen einer früheren Breitenliste sowie unnummeriertes CSV mit zwei leeren Strukturfeldern (`;;`).

Bewusste Aktualisierung:

```sh
RETA_REFRESH_FLAT_COLUMN_WIDTH_FIXTURES=1 \
RETA_FLAT_COLUMN_WIDTH_FIXTURES_ONLY=1 \
RETA_REFERENCE_PYTHON=/pfad/zur/referenz-python \
scripts/check_flat_column_widths_parity.sh
```
