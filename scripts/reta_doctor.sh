#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

status=0

section() {
    printf '\n== %s ==\n' "$1"
}

run_check() {
    name=$1
    shift
    printf '\n-- %s --\n' "$name"
    if "$@"; then
        printf 'OK: %s\n' "$name"
    else
        rc=$?
        printf 'FAIL: %s (exit %s)\n' "$name" "$rc" >&2
        status=1
    fi
}

check_file() {
    path=$1
    if [ -e "$path" ]; then
        printf 'OK   %s\n' "$path"
    else
        printf 'MISS %s\n' "$path" >&2
        status=1
    fi
}

check_executable() {
    path=$1
    if [ -x "$path" ]; then
        printf 'OK   %s\n' "$path"
    else
        printf 'MISS %s nicht ausführbar\n' "$path" >&2
        status=1
    fi
}

section "Buildsystem-Dateien"
check_file pixi.toml
check_file CMakeLists.txt
check_file cmake/RetaScriptTargets.cmake
check_executable scripts/run_build_task.sh
check_executable scripts/run_install_task.sh
check_executable scripts/check_pixi_cmake_toolchain.sh
check_executable scripts/print_build_defaults.sh
check_executable scripts/print_install_layout.sh
check_executable scripts/print_artifact_manifest.sh
check_executable scripts/check_artifact_manifest_consistency.sh
check_executable scripts/print_buildsystem_cleanup_status.sh

section "Shell-Syntax"
for script in \
    scripts/reta_command_runner.sh \
    scripts/reta_build_defaults.sh \
    scripts/reta_install_defaults.sh \
    scripts/reta_artifacts.sh \
    scripts/run_build_task.sh \
    scripts/run_install_task.sh \
    scripts/check_pixi_cmake_toolchain.sh \
    scripts/print_build_defaults.sh \
    scripts/print_install_layout.sh \
    scripts/print_artifact_manifest.sh \
    scripts/check_artifact_manifest_consistency.sh \
    scripts/print_buildsystem_cleanup_status.sh
 do
    run_check "sh -n $script" sh -n "$script"
done

section "Punkt 4 Status"
run_check "Punkt 4 Abschlussstatus" scripts/print_buildsystem_cleanup_status.sh

section "Defaults"
run_check "Build-Defaults" scripts/print_build_defaults.sh
run_check "Install-Layout" scripts/print_install_layout.sh

section "Manifest"
run_check "Artefaktmanifest" scripts/print_artifact_manifest.sh
run_check "Manifest-Konsistenz" scripts/check_artifact_manifest_consistency.sh

section "Toolchain"
run_check "Pixi/CMake/Mojo-Toolchain" scripts/check_pixi_cmake_toolchain.sh

section "CMake"
build_dir=${RETA_CMAKE_BUILD_DIR:-build}
if [ -f "$build_dir/CMakeCache.txt" ]; then
    cache_root=$(sed -n 's/^CMAKE_HOME_DIRECTORY:INTERNAL=//p' "$build_dir/CMakeCache.txt" | head -n 1)
    if [ -n "$cache_root" ] && [ "$cache_root" != "$ROOT" ]; then
        printf 'INFO CMake-Buildverzeichnis gehört zu anderem Quellbaum: %s\n' "$cache_root"
        printf 'INFO Neu konfigurieren mit: pixi run cmake-configure\n'
    elif [ -f "$build_dir/build.ninja" ]; then
        run_check "CMake Targets sichtbar" cmake --build "$build_dir" --target help
    else
        printf 'INFO CMakeCache vorhanden, aber kein Ninja-Buildfile. Neu konfigurieren: pixi run cmake-configure\n'
    fi
elif [ -d "$build_dir" ]; then
    printf 'INFO CMake-Buildverzeichnis ohne Cache vorhanden. Neu konfigurieren: pixi run cmake-configure\n'
else
    printf 'INFO CMake ist noch nicht konfiguriert. Nutze: pixi run cmake-configure\n'
fi

section "Plan-Kommandos"
run_check "Plan build-core-shared" scripts/run_build_task.sh --dry-run build-core-shared
run_check "Plan test" scripts/run_build_task.sh --dry-run test
run_check "Plan install" scripts/run_install_task.sh --dry-run install

if [ "$status" -ne 0 ]; then
    printf '\nReta Doctor: FEHLER gefunden. Es wurde nichts kompiliert und nichts installiert.\n' >&2
    exit "$status"
fi

printf '\nReta Doctor: OK. Es wurde nichts kompiliert und nichts installiert.\n'
