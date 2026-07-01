# Referenzfixtures für `--keineleereninhalte`

Die Dateien wurden für Stage 12c4h mit `PYTHONHASHSEED=0` aus der
projektlokalen Python-Referenz erzeugt. Sie decken alle sechs Ausgabearten vor
und nach der Filteroption sowie den englischen Alias `--noblankcontents` ab.

Der normale Test startet direkt `reta-native`; ein Python-Fallback ist in
diesem Programm nicht vorhanden. Die konservative Übergabe durch den
Kompatibilitätslauncher wird getrennt in `test_native_reta_cli.mojo` geprüft.

Bewusst neu erzeugen:

```bash
RETA_REFRESH_NO_BLANK_FIXTURES=1 \
  scripts/check_no_blank_contents_parity.sh
```
