
function(_add_executable_without_windows)
  set(_saved_c_flags "${CMAKE_C_FLAGS}")

  # Workaround the lack of "target_remove_definitions()" CMake command by
  # forcing flags. Note that attempting to update the COMPILE_DEFINITIONS
  # target property using get_target_property/set_property does not apply here
  # as the definition to remove is associated with CMAKE_C_FLAGS cache variable.
  # See https://gitlab.kitware.com/cmake/cmake/-/issues/19796

  # Remove /D_WINDOWS
  string(REPLACE "/D_WINDOWS" "" _c_flags "${CMAKE_C_FLAGS}")
  set(CMAKE_C_FLAGS "${_c_flags}" CACHE STRING "CMake C Flags" FORCE)

  add_executable(${ARGN})

  # Restore original flags
  set(CMAKE_C_FLAGS "${_saved_c_flags}" CACHE STRING "CMake C Flags" FORCE)
endfunction()

# Install tree directory
set(LAUNCHER_INSTALL_DIR ${BIN_BUILD_DIR})

# Build tree directory
set(LAUNCHER_BUILD_DIR ${PROJECT_BINARY_DIR}/${LAUNCHER_INSTALL_DIR})

set(launcher_targets)

set(build_venvlauncher 0)
if(PY_VERSION VERSION_GREATER_EQUAL "3.3")
  set(build_venvlauncher 1)
endif()

if(build_venvlauncher)
  set(target_sources
    ${SRC_DIR}/PC/launcher.c
    ${SRC_DIR}/PC/pylauncher.rc
  )
  set(target_include_dirs
    ${SRC_DIR}/PC/
  )
  set(target_libraries
    version
  )

  # venvlauncher
  set(target_name "venvlauncher")

  _add_executable_without_windows(${target_name} ${target_sources})
  target_include_directories(${target_name} PRIVATE ${target_include_dirs})
  target_link_libraries(${target_name} PRIVATE ${target_libraries})
  target_compile_definitions(${target_name}
    PRIVATE
      _CONSOLE
      _UNICODE
      VENV_REDIRECT
      PY_ICON # For "PC/pylauncher.rc"
      FIELD3=${PY_FIELD3_VALUE}
  )
  list(APPEND launcher_targets ${target_name})

  # venvwlauncher
  set(target_name "venvwlauncher")

  add_executable(${target_name} WIN32 ${target_sources})
  target_include_directories(${target_name} PRIVATE ${target_include_dirs})
  target_link_libraries(${target_name} PRIVATE ${target_libraries})
  target_compile_definitions(${target_name}
    PRIVATE
      _UNICODE
      _WINDOWS
      VENV_REDIRECT
      PYW_ICON # For "PC/pylauncher.rc"
      FIELD3=${PY_FIELD3_VALUE}
  )
  list(APPEND launcher_targets ${target_name})
endif()

set(build_pylauncher 0)
if(PY_VERSION VERSION_GREATER_EQUAL "3.11")
  set(build_pylauncher 1)
endif()

if(build_pylauncher)
  set(target_sources
    ${SRC_DIR}/PC/launcher2.c
    ${SRC_DIR}/PC/pylauncher.rc
  )
  set(target_include_dirs
    ${SRC_DIR}/PC/
  )
  set(target_libraries
    pathcch
    shell32
  )

  # pylauncher
  set(target_name "pylauncher")

  _add_executable_without_windows(${target_name} ${target_sources})
  target_include_directories(${target_name} PRIVATE ${target_include_dirs})
  target_link_libraries(${target_name} PRIVATE ${target_libraries})
  target_compile_definitions(${target_name}
    PRIVATE
      _CONSOLE
      _UNICODE
      FIELD3=${PY_FIELD3_VALUE}
  )
  list(APPEND launcher_targets ${target_name})

  # pywlauncher
  set(target_name "pywlauncher")

  add_executable(${target_name} WIN32 ${target_sources})
  target_include_directories(${target_name} PRIVATE ${target_include_dirs})
  target_link_libraries(${target_name} PRIVATE ${target_libraries})
  target_compile_definitions(${target_name}
    PRIVATE
      _UNICODE
      _WINDOWS
      FIELD3=${PY_FIELD3_VALUE}
  )

  list(APPEND launcher_targets ${target_name})
endif()

if(launcher_targets)
  set_target_properties(${launcher_targets}
    PROPERTIES
      LINK_FLAGS "/MANIFEST:NO"
      RUNTIME_OUTPUT_DIRECTORY ${LAUNCHER_INSTALL_DIR}
  )
  install(TARGETS ${launcher_targets} RUNTIME DESTINATION ${BIN_INSTALL_DIR} COMPONENT Runtime)
endif()
