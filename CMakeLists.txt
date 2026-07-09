cmake_minimum_required(VERSION 3.25)

project(reta_arch_mojo
  VERSION 0.1.0
  DESCRIPTION "Script-backed CMake entrypoints for the reta Mojo transpilation project"
  LANGUAGES NONE
)

include(CTest)
include(cmake/RetaScriptTargets.cmake)

set(RETA_MOJO_JOBS "8" CACHE STRING "Mojo compiler jobs forwarded as '-j N' to project build scripts")
set(RETA_TEST_RUN_JOBS "1" CACHE STRING "Runtime jobs for scripts/run-tests.sh")
set(RETA_TEST_RUN_TIMEOUT "0" CACHE STRING "Optional per-test timeout in seconds, 0 disables it")
# Keep project-native install targets and standard `cmake --install` on the
# same prefix.  CMake defaults CMAKE_INSTALL_PREFIX to /usr/local on Unix, so
# an empty/minimal configure already installs under /usr/local.
set(RETA_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH "Installation prefix used by script-backed install targets")

reta_script_target(reta-toolchain-check
  COMMENT "Check Pixi/CMake/Mojo toolchain without compiling"
  COMMAND scripts/check_pixi_cmake_toolchain.sh
)


reta_script_target(reta-doctor
  COMMENT "Run non-compiling Shell/Pixi/CMake buildsystem diagnostics"
  COMMAND scripts/reta_doctor.sh
)

reta_script_target(reta-script-cleanup-status
  COMMENT "Print Punkt 4 buildsystem cleanup completion status"
  COMMAND scripts/print_buildsystem_cleanup_status.sh
)

reta_script_target(reta-build-defaults
  COMMENT "Print shared Shell/Pixi/CMake build defaults"
  COMMAND scripts/print_build_defaults.sh
)


reta_script_target(reta-regular
  COMMENT "Build regular native Mojo targets"
  COMMAND ${CMAKE_COMMAND} -E env RETA_MOJO_JOBS=${RETA_MOJO_JOBS} scripts/run_build_task.sh build
)

reta_script_target(reta-heavy
  COMMENT "Build heavy native Mojo targets"
  COMMAND ${CMAKE_COMMAND} -E env RETA_MOJO_JOBS=${RETA_MOJO_JOBS} scripts/run_build_task.sh build-heavy
)

reta_script_target(reta-core-shared
  COMMENT "Build libreta_core_mojo.so and thin reta/grundStrukHtml starters"
  COMMAND ${CMAKE_COMMAND} -E env RETA_MOJO_JOBS=${RETA_MOJO_JOBS} scripts/run_build_task.sh build-core-shared
)

reta_script_target(reta-plan-core-shared
  COMMENT "Print libreta_core_mojo/thin-starter build command without compiling"
  COMMAND ${CMAKE_COMMAND} -E env RETA_DRY_RUN=1 RETA_MOJO_JOBS=${RETA_MOJO_JOBS} scripts/run_build_task.sh build-core-shared
)

reta_script_target(reta-prompt-shared
  COMMENT "Build prompt shared libraries and thin rp/rpl/rpe/rpb starters"
  COMMAND ${CMAKE_COMMAND} -E env RETA_MOJO_JOBS=${RETA_MOJO_JOBS} scripts/run_build_task.sh build-prompt-shared
)

reta_script_target(reta-shared
  COMMENT "Build all official shared-library targets"
  COMMAND ${CMAKE_COMMAND} -E env RETA_MOJO_JOBS=${RETA_MOJO_JOBS} scripts/run_build_task.sh build-shared
)

reta_script_target(reta-all
  COMMENT "Build the complete production target set"
  COMMAND ${CMAKE_COMMAND} -E env RETA_MOJO_JOBS=${RETA_MOJO_JOBS} scripts/run_build_task.sh build-all
)

add_custom_target(reta-default ALL
  COMMENT "Build the complete production target set by default"
)
add_dependencies(reta-default reta-all)

reta_script_target(reta-plan-all
  COMMENT "Print full production build command without compiling"
  COMMAND ${CMAKE_COMMAND} -E env RETA_DRY_RUN=1 RETA_MOJO_JOBS=${RETA_MOJO_JOBS} scripts/run_build_task.sh build-all
)

reta_script_target(reta-tests-build
  COMMENT "Compile the Mojo test suite without running it"
  COMMAND ${CMAKE_COMMAND} -E env RETA_MOJO_JOBS=${RETA_MOJO_JOBS} scripts/run_build_task.sh build-tests
)

reta_script_target(reta-tests-run
  COMMENT "Run already compiled Mojo tests"
  COMMAND ${CMAKE_COMMAND} -E env RETA_TEST_RUN_TIMEOUT=${RETA_TEST_RUN_TIMEOUT} RETA_TEST_RUN_JOBS=${RETA_TEST_RUN_JOBS} scripts/run_build_task.sh run-tests
)

add_custom_target(reta-tests
  COMMAND ${CMAKE_COMMAND} -E env RETA_MOJO_JOBS=${RETA_MOJO_JOBS} scripts/run_build_task.sh build-tests
  COMMAND ${CMAKE_COMMAND} -E env RETA_TEST_RUN_TIMEOUT=${RETA_TEST_RUN_TIMEOUT} RETA_TEST_RUN_JOBS=${RETA_TEST_RUN_JOBS} scripts/run_build_task.sh run-tests
  COMMENT "Compile and run the Mojo test suite"
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  USES_TERMINAL
  VERBATIM
)

reta_script_target(reta-plan-test
  COMMENT "Print test build/run commands without compiling or running tests"
  COMMAND ${CMAKE_COMMAND} -E env RETA_DRY_RUN=1 RETA_MOJO_JOBS=${RETA_MOJO_JOBS} RETA_TEST_RUN_JOBS=${RETA_TEST_RUN_JOBS} scripts/run_build_task.sh test
)

reta_script_target(reta-test-all
  COMMENT "Run the legacy combined test entrypoint"
  COMMAND ${CMAKE_COMMAND} -E env RETA_MOJO_JOBS=${RETA_MOJO_JOBS} RETA_TEST_RUN_JOBS=${RETA_TEST_RUN_JOBS} scripts/run_build_task.sh test-all
)

reta_script_target(reta-release-check
  COMMENT "Run the release-check gate"
  COMMAND ${CMAKE_COMMAND} -E env RETA_MOJO_JOBS=${RETA_MOJO_JOBS} scripts/run_build_task.sh release-check
)

reta_script_target(reta-release-plan
  COMMENT "Print the release-check plan without running commands"
  COMMAND ${CMAKE_COMMAND} -E env RETA_MOJO_JOBS=${RETA_MOJO_JOBS} scripts/run_build_task.sh release-plan
)

reta_script_target(reta-install-layout
  COMMENT "Print effective install layout defaults"
  COMMAND scripts/print_install_layout.sh
)

reta_script_target(reta-artifact-manifest
  COMMENT "Print central build/install artifact manifest"
  COMMAND scripts/print_artifact_manifest.sh
)

reta_script_target(reta-check-artifact-manifest
  COMMENT "Check install_targets.txt against the central artifact manifest"
  COMMAND scripts/check_artifact_manifest_consistency.sh
)

reta_script_target(reta-check-manpages
  COMMENT "Check public manual pages for reta/rp/rpl/rpe/rpb"
  COMMAND scripts/check_manpages.sh
)

install(CODE "
  execute_process(
    COMMAND \"${CMAKE_COMMAND}\" -E env \"PREFIX=\${CMAKE_INSTALL_PREFIX}\" \"${CMAKE_CURRENT_SOURCE_DIR}/scripts/run_install_task.sh\" install
    WORKING_DIRECTORY \"${CMAKE_CURRENT_SOURCE_DIR}\"
    RESULT_VARIABLE _reta_install_result
  )
  if(NOT _reta_install_result EQUAL 0)
    message(FATAL_ERROR \"reta install failed with exit code \${_reta_install_result}\")
  endif()
")

reta_script_target(reta-install
  COMMENT "Install reta under ${RETA_INSTALL_PREFIX}"
  COMMAND ${CMAKE_COMMAND} -E env PREFIX=${RETA_INSTALL_PREFIX} scripts/run_install_task.sh install
)

reta_script_target(reta-install-plan
  COMMENT "Print install command for ${RETA_INSTALL_PREFIX} without installing"
  COMMAND ${CMAKE_COMMAND} -E env RETA_DRY_RUN=1 PREFIX=${RETA_INSTALL_PREFIX} scripts/run_install_task.sh install
)

reta_script_target(reta-uninstall
  COMMENT "Uninstall reta from ${RETA_INSTALL_PREFIX}"
  COMMAND ${CMAKE_COMMAND} -E env PREFIX=${RETA_INSTALL_PREFIX} scripts/run_install_task.sh uninstall
)

reta_script_target(reta-uninstall-plan
  COMMENT "Print uninstall command for ${RETA_INSTALL_PREFIX} without uninstalling"
  COMMAND ${CMAKE_COMMAND} -E env RETA_DRY_RUN=1 PREFIX=${RETA_INSTALL_PREFIX} scripts/run_install_task.sh uninstall
)

reta_script_target(reta-check-install-layout
  COMMENT "Check staged install layout with prefix ${RETA_INSTALL_PREFIX}"
  COMMAND ${CMAKE_COMMAND} -E env PREFIX=${RETA_INSTALL_PREFIX} scripts/run_install_task.sh check-install-layout
)

reta_script_target(reta-check-install-layout-plan
  COMMENT "Print install-layout check command without checking"
  COMMAND ${CMAKE_COMMAND} -E env RETA_DRY_RUN=1 PREFIX=${RETA_INSTALL_PREFIX} scripts/run_install_task.sh check-install-layout
)

reta_script_target(reta-clean-generated
  COMMENT "Clean generated build artifacts with the existing project script"
  COMMAND scripts/clean.sh
)

if(BUILD_TESTING)
  add_test(
    NAME reta_prebuilt_mojo_tests
    COMMAND ${CMAKE_COMMAND} -E env RETA_TEST_RUN_TIMEOUT=${RETA_TEST_RUN_TIMEOUT} RETA_TEST_RUN_JOBS=${RETA_TEST_RUN_JOBS} ${CMAKE_SOURCE_DIR}/scripts/run_build_task.sh run-tests
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  )
  set_tests_properties(reta_prebuilt_mojo_tests PROPERTIES
    LABELS "mojo;prebuilt"
  )

  add_test(
    NAME reta_test_all
    COMMAND ${CMAKE_COMMAND} -E env RETA_MOJO_JOBS=${RETA_MOJO_JOBS} RETA_TEST_RUN_JOBS=${RETA_TEST_RUN_JOBS} ${CMAKE_SOURCE_DIR}/scripts/run_build_task.sh test-all
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  )
  set_tests_properties(reta_test_all PROPERTIES
    LABELS "mojo;full"
  )
endif()
