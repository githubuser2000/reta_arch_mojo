#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
python3 scripts/generate_meta_request_order.py --check
[ "$(wc -l < assets/meta_request_order.tsv)" -eq 4095 ]
printf '%s\n' 'Metaspalten-Mengenordnung ist für alle 4095 Teilmengen reproduzierbar.'
