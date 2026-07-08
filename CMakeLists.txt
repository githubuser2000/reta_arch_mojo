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
set(RETA_INSTALL_PREFIX "/usr/local" CACHE PATH "Installation prefix used by script-backed install targets")

set(RETA_MOJO_BUILD_OPTIONS -- -j ${RETA_MOJO_JOBS})

reta_script_target(reta-toolchain-check
  COMMENT "Check Pixi/CMake/Mojo toolchain without compiling"
  COMMAND scripts/check_pixi_cmake_toolchain.sh
)

reta_script_target(reta-regular
  COMMENT "Build regular native Mojo targets"
  COMMAND scripts/build.sh ${RETA_MOJO_BUILD_OPTIONS}
)

reta_script_target(reta-heavy
  COMMENT "Build heavy native Mojo targets"
  COMMAND scripts/build-heavy.sh ${RETA_MOJO_BUILD_OPTIONS}
)

reta_script_target(reta-core-shared
  COMMENT "Build libreta-core.so and thin reta/grundStrukHtml starters"
  COMMAND scripts/build_core_shared.sh ${RETA_MOJO_BUILD_OPTIONS}
)

reta_script_target(reta-prompt-shared
  COMMENT "Build prompt shared libraries and thin rp/rpl/rpe/rpb starters"
  COMMAND scripts/build_prompt_shared.sh ${RETA_MOJO_BUILD_OPTIONS}
)

reta_script_target(reta-shared
  COMMENT "Build all official shared-library targets"
  COMMAND scripts/build_shared_library_targets.sh ${RETA_MOJO_BUILD_OPTIONS}
)

reta_script_target(reta-all
  COMMENT "Build the complete production target set"
  COMMAND scripts/build-all.sh ${RETA_MOJO_BUILD_OPTIONS}
)

reta_script_target(reta-tests-build
  COMMENT "Compile the Mojo test suite without running it"
  COMMAND scripts/build-tests.sh ${RETA_MOJO_BUILD_OPTIONS}
)

reta_script_target(reta-tests-run
  COMMENT "Run already compiled Mojo tests"
  COMMAND ${CMAKE_COMMAND} -E env RETA_TEST_RUN_TIMEOUT=${RETA_TEST_RUN_TIMEOUT} scripts/run-tests.sh --jobs ${RETA_TEST_RUN_JOBS}
)

add_custom_target(reta-tests
  COMMAND scripts/build-tests.sh ${RETA_MOJO_BUILD_OPTIONS}
  COMMAND ${CMAKE_COMMAND} -E env RETA_TEST_RUN_TIMEOUT=${RETA_TEST_RUN_TIMEOUT} scripts/run-tests.sh --jobs ${RETA_TEST_RUN_JOBS}
  COMMENT "Compile and run the Mojo test suite"
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  USES_TERMINAL
  VERBATIM
)

reta_script_target(reta-test-all
  COMMENT "Run the legacy combined test entrypoint"
  COMMAND scripts/test_all.sh ${RETA_MOJO_BUILD_OPTIONS}
)

reta_script_target(reta-release-check
  COMMENT "Run the release-check gate"
  COMMAND scripts/release_check.sh
)

reta_script_target(reta-release-plan
  COMMENT "Print the release-check plan without running commands"
  COMMAND scripts/release_check.sh --dry-run
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

reta_script_target(reta-install
  COMMENT "Install reta under ${RETA_INSTALL_PREFIX}"
  COMMAND ${CMAKE_COMMAND} -E env PREFIX=${RETA_INSTALL_PREFIX} scripts/install.sh
)

reta_script_target(reta-uninstall
  COMMENT "Uninstall reta from ${RETA_INSTALL_PREFIX}"
  COMMAND ${CMAKE_COMMAND} -E env PREFIX=${RETA_INSTALL_PREFIX} scripts/uninstall.sh
)

reta_script_target(reta-check-install-layout
  COMMENT "Check staged install layout with prefix ${RETA_INSTALL_PREFIX}"
  COMMAND ${CMAKE_COMMAND} -E env PREFIX=${RETA_INSTALL_PREFIX} scripts/check_install_layout.sh
)

reta_script_target(reta-clean-generated
  COMMENT "Clean generated build artifacts with the existing project script"
  COMMAND scripts/clean.sh
)

if(BUILD_TESTING)
  add_test(
    NAME reta_prebuilt_mojo_tests
    COMMAND ${CMAKE_COMMAND} -E env RETA_TEST_RUN_TIMEOUT=${RETA_TEST_RUN_TIMEOUT} ${CMAKE_SOURCE_DIR}/scripts/run-tests.sh --jobs ${RETA_TEST_RUN_JOBS}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  )
  set_tests_properties(reta_prebuilt_mojo_tests PROPERTIES
    LABELS "mojo;prebuilt"
  )

  add_test(
    NAME reta_test_all
    COMMAND ${CMAKE_SOURCE_DIR}/scripts/test_all.sh ${RETA_MOJO_BUILD_OPTIONS}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  )
  set_tests_properties(reta_test_all PROPERTIES
    LABELS "mojo;full"
  )
endif()
