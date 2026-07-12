#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

usage() {
    cat <<'USAGE'
Verwendung: scripts/release_check.sh [--dry-run] [--] [MOJO_BUILD_OPTION ...]

Führt den vollständigen Release-Sicherheitsgurt aus:
  1. vollständiger nativer Build inklusive Core-/Prompt-Shared-Libraries
  2. Buildlayout-Prüfung inklusive .reta-source-id-Frische
  3. FHS-/usr/local-Installationsprüfung mit installierten dünnen Startern
  4. Prompt-Shared-Runtime-Smoke im Build- und Installationsbaum
  5. alle Katalog-, Paritäts- und Test-Suiten

Mojo-Buildoptionen nach -- werden nur an scripts/build-all.sh weitergereicht.
USAGE
}

DRY_RUN=0
while [ "$#" -gt 0 ]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            break
            ;;
    esac
done

run_step() {
    title=$1
    shift
    printf '\n== %s ==\n' "$title"
    if [ "$DRY_RUN" = 1 ]; then
        printf '%s' '+ '
        printf '%s' "$1"
        shift
        for arg in "$@"; do
            printf ' %s' "$arg"
        done
        printf '\n'
        return 0
    fi
    "$@"
}

run_step 'Artefaktmanifest gegen Installationsziele prüfen' \
    "$ROOT/scripts/check_artifact_manifest_consistency.sh"
run_step 'Installprofile für Shell, Pixi und CMake prüfen' \
    "$ROOT/scripts/check_install_profile_matrix.sh"
run_step 'Bridge-/Release-Policy für native Installation prüfen' \
    "$ROOT/scripts/check_release_bridge_policy.sh"
run_step 'vollständiger nativer Build mit Core-/Prompt-Shared-Libraries' \
    "$ROOT/scripts/build-all.sh" -- "$@"
run_step 'Buildlayout inklusive Shared-Libraries prüfen' \
    "$ROOT/scripts/check_build_layout.sh"
run_step 'FHS-/usr/local-Installation inklusive dünner Starter prüfen' \
    "$ROOT/scripts/check_install_layout.sh"
run_step 'Multis3-Parität prüfen' "$ROOT/scripts/check_multis3_parity.sh"
run_step 'Tag-Schema prüfen' "$ROOT/scripts/check_tag_schema.sh"
run_step 'Table-Runtime-Parität prüfen' "$ROOT/scripts/check_table_runtime_parity.sh"
run_step 'Runtime-Alias-Katalog prüfen' "$ROOT/scripts/check_runtime_alias_catalog.sh"
run_step 'Generated-Alias-Katalog prüfen' "$ROOT/scripts/check_generated_alias_catalog.sh"
run_step 'Fraction-Pair-Katalog prüfen' "$ROOT/scripts/check_fraction_pair_catalog.sh"
run_step 'Meta-Request-Reihenfolge prüfen' "$ROOT/scripts/check_meta_request_order.sh"
run_step 'Kombi-Kataloge prüfen' "$ROOT/scripts/check_kombi_catalogs.sh"
run_step 'Generated-Column-Parität prüfen (Mengenlisten reihenfolgentolerant)' "$ROOT/scripts/check_generated_column_parity.sh"
run_step 'Schema-Katalog prüfen' "$ROOT/scripts/check_schema_catalog.sh"
run_step 'Kategorie-Katalog prüfen' "$ROOT/scripts/check_category_catalog.sh"
run_step 'Native-Table-Parität prüfen' "$ROOT/scripts/check_native_table_parity.sh"
run_step 'Prompt-Katalog prüfen' "$ROOT/scripts/check_prompt_catalog.sh"
run_step 'Grundstrukturen-Katalog prüfen' "$ROOT/scripts/check_grundstrukturen_catalog.sh"
run_step 'Prompt-Bin-Kompatibilität prüfen' "$ROOT/scripts/test_prompt_bins.sh"
run_step 'Stage 10 prüfen' "$ROOT/scripts/test_stage10.sh"
run_step 'Stage 12c prüfen' "$ROOT/scripts/test_stage12c.sh"
run_step 'Kompatibilitätsparität prüfen' "$ROOT/scripts/check_compat_parity.sh"
run_step 'Alle-Spalten-Plan prüfen' "$ROOT/scripts/check_all_columns_plan.sh"
run_step 'HTML-Parität prüfen' "$ROOT/scripts/check_html_parity.sh"
run_step 'HTML-Cell-Katalog prüfen' "$ROOT/scripts/check_html_cell_catalog.sh"
run_step 'HTML-Heading-Katalog prüfen' "$ROOT/scripts/check_html_heading_catalog.sh"
run_step 'Markup-Parität prüfen' "$ROOT/scripts/check_markup_parity.sh"
run_step 'Shell-Parität prüfen' "$ROOT/scripts/check_shell_parity.sh"
run_step 'Vollständige Mojo-Test-Suite ausführen' "$ROOT/scripts/test_all.sh"

if [ "$DRY_RUN" = 1 ]; then
    printf '\n%s\n' 'Release-Prüfplan ausgegeben; keine Kommandos ausgeführt.'
else
    printf '\n%s\n' 'Alle Release-Prüfungen bestanden, inklusive FHS-/usr/local-Installation und Prompt-Shared-Runtime-Smoke.'
fi
