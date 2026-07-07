# current-stage history for source contracts: test_stage12c5fp.sh test_stage12c5fo.sh test_stage12c5fn.sh test_stage12c5fm.sh test_stage12c5fl.sh test_stage12c5fk.sh
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
exec "$ROOT/scripts/test_stage12c5fp.sh" "$@"

# previous stage: scripts/test_stage12c5fo.sh test_stage12c5fn.sh test_stage12c5fm.sh test_stage12c5fl.sh test_stage12c5fk.sh test_stage12c5fj.sh
