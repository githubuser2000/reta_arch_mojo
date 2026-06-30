#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

./scripts/build.sh
./scripts/check_build_layout.sh
./scripts/check_multis3_parity.sh
./scripts/check_tag_schema.sh
./scripts/check_table_runtime_parity.sh
./scripts/check_runtime_alias_catalog.sh
./scripts/check_generated_alias_catalog.sh
./scripts/check_fraction_pair_catalog.sh
./scripts/check_meta_request_order.sh
./scripts/check_kombi_catalogs.sh
./scripts/check_generated_column_parity.sh
./scripts/check_schema_catalog.sh
./scripts/check_category_catalog.sh
./scripts/check_native_table_parity.sh
./scripts/check_prompt_catalog.sh
./scripts/check_grundstrukturen_catalog.sh
./scripts/test_prompt_bins.sh
./scripts/test_stage10.sh
./scripts/test_stage12c.sh
./scripts/check_compat_parity.sh
./scripts/check_all_columns_plan.sh
./scripts/check_html_parity.sh
./scripts/check_html_cell_catalog.sh
./scripts/check_html_heading_catalog.sh
./scripts/check_markup_parity.sh
./scripts/check_shell_parity.sh
./scripts/test_all.sh

printf '%s\n' 'Alle Release-Prüfungen bestanden.'
