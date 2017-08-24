
set(_x86 "(x86)")  # Indirection required to avoid error related to CMP0053
find_program(PATCH_EXECUTABLE
  NAME patch
  PATHS "$ENV{ProgramFiles}/Git/usr/bin"
        "$ENV{ProgramFiles${_x86}}/Git/usr/bin"
        "$ENV{ProgramFiles}/GnuWin32/bin"
        "$ENV{ProgramFiles${_x86}}/GnuWin32/bin"
        "$ENV{ProgramFiles}/Git/bin"
        "$ENV{ProgramFiles${_x86}}/Git/bin"
        "$ENV{LOCALAPPDATA}/Programs/Git/bin"
        "$ENV{LOCALAPPDATA}/Programs/Git/usr/bin"
        "$ENV{APPDATA}/Programs/Git/bin"
        "$ENV{APPDATA}/Programs/Git/usr/bin"
  )
if(NOT PATCH_EXECUTABLE)
  message(FATAL_ERROR "Could NOT find patch (missing: PATCH_EXECUTABLE)")
endif()

set(patches_dir "${Python_SOURCE_DIR}/patches")

function(_apply_patches _subdir)
  if(NOT EXISTS ${patches_dir}/${_subdir})
    message(STATUS "Skipping patches: Directory '${patches_dir}/${_subdir}' does not exist")
    return()
  endif()
  file(GLOB _patches RELATIVE ${patches_dir} "${patches_dir}/${_subdir}/*.patch")
  if(NOT _patches)
    return()
  endif()
  message(STATUS "")
  list(SORT _patches)
  foreach(patch IN LISTS _patches)
    set(msg "Applying '${patch}'")
    message(STATUS "${msg}")
    set(applied ${PROJECT_BINARY_DIR}/CMakeFiles/patches/${patch}.applied)
    if(EXISTS ${applied})
      message(STATUS "${msg} - skipping (already applied)")
      continue()
    endif()
    execute_process(
      COMMAND ${PATCH_EXECUTABLE} --quiet -p1 -i ${patches_dir}/${patch}
      WORKING_DIRECTORY ${SRC_DIR}
      RESULT_VARIABLE result
      ERROR_VARIABLE error
      ERROR_STRIP_TRAILING_WHITESPACE
      OUTPUT_VARIABLE output
      OUTPUT_STRIP_TRAILING_WHITESPACE
      )
    if(result EQUAL 0)
      message(STATUS "${msg} - done")
      get_filename_component(_dir ${applied} DIRECTORY)
      execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${_dir})
      execute_process(COMMAND ${CMAKE_COMMAND} -E touch ${applied})
    else()
      message(STATUS "${msg} - failed")
      message(FATAL_ERROR "${output}\n${error}")
    endif()
  endforeach()
  message(STATUS "")
endfunction()

# Apply patches
_apply_patches("${PY_VERSION}")
_apply_patches("${PY_VERSION}/${CMAKE_SYSTEM_NAME}")
_apply_patches("${PY_VERSION}/${CMAKE_SYSTEM_NAME}-${CMAKE_C_COMPILER_ID}")
set(_version ${CMAKE_C_COMPILER_VERSION})
if(MSVC)
  set(_version ${MSVC_VERSION})
endif()
_apply_patches("${PY_VERSION}/${CMAKE_SYSTEM_NAME}-${CMAKE_C_COMPILER_ID}/${_version}")
