set -eu
TMP=${TMPDIR:-/tmp}/reta-install-debug.$$
STAGE=$TMP/stage
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP"

DESTDIR=$STAGE PREFIX=/usr scripts/install.sh >"$TMP/install.log"

set -- \
  -zeilen --vorhervonausschnitt=1-2 \
  -spalten --religionen=sternpolygon \
  -ausgabe --art=csv --breite=40

echo '== installed layout =='
find "$STAGE/usr/lib/reta" -maxdepth 2 -type f -o -type l | sort

echo
echo '== reta symlink =='
ls -l "$STAGE/usr/bin/reta"
readlink -f "$STAGE/usr/bin/reta"

echo
echo '== ldd core launcher =='
ldd "$STAGE/usr/lib/reta/reta" || true

echo
echo '== ldd core library =='
ldd "$STAGE/usr/lib/reta/libreta_core_mojo.so" || true

echo
echo '== run reta-native =='
(
  cd "$TMP"
  "$STAGE/usr/bin/reta-native" "$@"
) >"$TMP/native.out" 2>"$TMP/native.err"
echo "status=$?"
cat "$TMP/native.err"

echo
echo '== run thin reta =='
set +e
(
  cd "$TMP"
  "$STAGE/usr/bin/reta" "$@"
) >"$TMP/core.out" 2>"$TMP/core.err"
STATUS=$?
set -e
echo "status=$STATUS"
echo '--- stderr ---'
cat "$TMP/core.err"
echo '--- stdout head ---'
sed -n '1,40p' "$TMP/core.out"

echo
echo '== compare sizes =='
wc -c "$TMP/native.out" "$TMP/core.out" || true
