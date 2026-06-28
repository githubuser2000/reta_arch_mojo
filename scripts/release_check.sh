#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

./scripts/build.sh
./scripts/check_build_layout.sh
./scripts/check_multis3_parity.sh
./scripts/check_tag_schema.sh
./scripts/check_table_runtime_parity.sh
./scripts/check_prompt_catalog.sh
./scripts/check_grundstrukturen_catalog.sh
./scripts/test_prompt_bins.sh
./scripts/check_compat_parity.sh
./scripts/check_html_parity.sh
./scripts/test_all.sh

printf '%s\n' 'Alle Release-Prüfungen bestanden.'
