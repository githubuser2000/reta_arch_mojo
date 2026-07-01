# Explizite Nullbreiten

Die zwölf Bytefixtures decken `--breiten`-Einträge mit Wert `0` für Shell,
HTML und BBCode ab. Geprüft werden eine führende Nullspalte, eine führende
Nullspalte vor einer exakten Breite, eine Nullspalte nach einer positiven
Breite sowie zwei aufeinanderfolgende Nullspalten.

Neu erzeugen:

```sh
RETA_REFRESH_COLUMN_ZERO_WIDTH_FIXTURES=1 \
  ./scripts/check_column_zero_widths_parity.sh
```
