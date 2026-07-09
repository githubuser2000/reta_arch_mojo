#!/usr/bin/env sh
set -eu

case ${1:-} in
    -h|--help)
        cat <<'USAGE'
Verwendung: scripts/build_shared_library_targets.sh [--dry-run] [--] [MOJO_BUILD_OPTION ...]

Beschreibt die neue dynamische Zielarchitektur:
  - libreta_core_mojo.so / libreta_core_mojo.dll
  - libreta_prompt_mojo.so / libreta_prompt_mojo.dll
  - libreta_prompt_interactive_mojo.so / libreta_prompt_interactive_mojo.dll

Diese Stage friert die Zielarchitektur und ihre Starter-Abhängigkeiten ein.
libreta_core_mojo.so, libreta_prompt_mojo.so und libreta_prompt_interactive_mojo.so
sind offizielle Shared-Library-Zielgruppen. build-all.sh baut alle drei
Bibliotheken und die zugehörigen dünnen Starter.
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

  libreta_core_mojo.so / libreta_core_mojo.dll
    Verbraucher: reta, rp, rpl, rpe, rpb, grundStrukHtml
    Inhalt: reta-Kern, Parameter, Tabellen, Ausgaben, Grundstrukturen/HTML-Kern

  libreta_prompt_mojo.so / libreta_prompt_mojo.dll
    Verbraucher: rp, rpl, rpe, rpb
    Abhängigkeit: libreta_core_mojo
    Inhalt: gemeinsame Prompt-Ausführung inklusive One-shot-rpb

  libreta_prompt_interactive_mojo.so / libreta_prompt_interactive_mojo.dll
    Verbraucher: rp, rpl, rpe
    Abhängigkeit: libreta_prompt_mojo
    Inhalt: interaktive Prompteingabe, Session, History, Line-Editor
    Nicht verwendet von: rpb

Dünne Starter:
  reta          -> libreta_core_mojo  (aktiv über scripts/build_core_shared.sh)
  grundStrukHtml-> libreta_core_mojo  (aktiv über scripts/build_core_shared.sh)
  rpb           -> libreta_prompt_mojo + libreta_core_mojo       (aktiv über scripts/build_prompt_shared.sh)
  rp/rpl/rpe    -> libreta_prompt_interactive_mojo + libreta_prompt_mojo + libreta_core_mojo
                  (aktiv über scripts/build_prompt_shared.sh)
PLAN

if [ "$DRY_RUN" = 1 ]; then
    printf '%s\n' 'Dry-run: keine Shared Libraries gebaut.'
    exit 0
fi

printf '%s\n' 'Baue aktive Core-Shared-Zielgruppe.'
"$ROOT/scripts/build_core_shared.sh" -- "$@"
printf '%s\n' 'Baue offizielle Prompt-Shared-Zielgruppe.'
"$ROOT/scripts/build_prompt_shared.sh" -- "$@"
