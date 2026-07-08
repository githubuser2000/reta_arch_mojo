# Script-backed CMake targets for reta_arch_mojo.
#
# This is intentionally conservative: CMake orchestrates the existing,
# known-good shell scripts first.  Direct Mojo object-level dependency graphs can
# be introduced later after the script-backed targets have stayed green.

function(reta_script_target target_name)
  set(options)
  set(one_value_args COMMENT)
  set(multi_value_args COMMAND)
  cmake_parse_arguments(RETA_TARGET "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

  if(NOT RETA_TARGET_COMMAND)
    message(FATAL_ERROR "reta_script_target(${target_name}) requires COMMAND")
  endif()

  if(NOT RETA_TARGET_COMMENT)
    set(RETA_TARGET_COMMENT "Run ${target_name}")
  endif()

  add_custom_target(${target_name}
    COMMAND ${RETA_TARGET_COMMAND}
    COMMENT "${RETA_TARGET_COMMENT}"
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    USES_TERMINAL
    VERBATIM
  )
endfunction()
