
set(CMAKE_MODULE_PATH
  ${CMAKE_CURRENT_LIST_DIR}
  ${CMAKE_MODULE_PATH}
  )
find_package(Patch REQUIRED)

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
    set(applied ${SRC_DIR}/.patches/${patch}.applied)
    # Handle case where source tree was patched using the legacy approach.
    set(legacy_applied ${PROJECT_BINARY_DIR}/CMakeFiles/patches/${patch}.applied)
    if(EXISTS ${legacy_applied})
      set(applied ${legacy_applied})
    endif()
    if(EXISTS ${applied})
      message(STATUS "${msg} - skipping (already applied)")
      continue()
    endif()
    execute_process(
      COMMAND ${Patch_EXECUTABLE} --quiet -p1 -i ${patches_dir}/${patch}
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
_apply_patches("${PY_VERSION_MAJOR}")
_apply_patches("${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}")
_apply_patches("${PY_VERSION}")
_apply_patches("${PY_VERSION}/${CMAKE_SYSTEM_NAME}")
_apply_patches("${PY_VERSION}/${CMAKE_SYSTEM_NAME}-${CMAKE_C_COMPILER_ID}")
set(_version ${CMAKE_C_COMPILER_VERSION})
if(MSVC)
  set(_version ${MSVC_VERSION})
endif()
_apply_patches("${PY_VERSION}/${CMAKE_SYSTEM_NAME}-${CMAKE_C_COMPILER_ID}/${_version}")
