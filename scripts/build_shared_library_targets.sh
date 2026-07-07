#!/usr/bin/env sh
set -eu

case ${1:-} in
    -h|--help)
        cat <<'USAGE'
Verwendung: scripts/build_shared_library_targets.sh [--dry-run] [--] [MOJO_BUILD_OPTION ...]

Beschreibt die neue dynamische Zielarchitektur:
  - libreta-core.so / libreta-core.dll
  - libreta-prompt.so / libreta-prompt.dll
  - libreta-prompt-interactive.so / libreta-prompt-interactive.dll

Diese Stage friert die Zielarchitektur und ihre Starter-Abhängigkeiten ein.
Der vorhandene Shared-Diagnostics-Build bleibt der einzige aktiv kompilierte
Shared-Library-Build. Die echten ABI-Dateien für core/prompt/interactive werden
in Folgestages angebunden, sobald diese Source-Guards lokal grün sind.
USAGE
        exit 0
        ;;
esac

DRY_RUN=0
if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN=1
    shift
fi
if [ "${1:-}" = "--" ]; then
    shift
fi
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
. "$ROOT/scripts/mojo_build_options.sh"
mojo_validate_build_options "$@"

cat <<'PLAN'
Geplante Shared-Library-Zielarchitektur:

  libreta-core.so / libreta-core.dll
    Verbraucher: reta, rp, rpl, rpe, rpb, grundStrukHtml
    Inhalt: reta-Kern, Parameter, Tabellen, Ausgaben, Grundstrukturen/HTML-Kern

  libreta-prompt.so / libreta-prompt.dll
    Verbraucher: rp, rpl, rpe, rpb
    Abhängigkeit: libreta-core
    Inhalt: gemeinsame Prompt-Ausführung inklusive One-shot-rpb

  libreta-prompt-interactive.so / libreta-prompt-interactive.dll
    Verbraucher: rp, rpl, rpe
    Abhängigkeit: libreta-prompt
    Inhalt: interaktive Prompteingabe, Session, History, Line-Editor
    Nicht verwendet von: rpb

Dünne Starter:
  reta          -> libreta-core
  grundStrukHtml-> libreta-core
  rpb           -> libreta-prompt + libreta-core
  rp/rpl/rpe    -> libreta-prompt-interactive + libreta-prompt + libreta-core
PLAN

if [ "$DRY_RUN" = 1 ]; then
    printf '%s\n' 'Dry-run: keine Shared Libraries gebaut.'
    exit 0
fi

printf '%s\n' 'Noch kein produktiver Build-Schritt für diese Zielarchitektur aktiv.'
printf '%s\n' 'Nutze --dry-run für die planbare Ausgabe; echte ABI-Builds folgen in der nächsten Stage.'
exit 0
