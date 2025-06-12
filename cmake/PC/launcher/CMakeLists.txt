
function(_add_executable_without_windows target_name)
  # Work around the lack of a "target_remove_definitions()" CMake command by
  # explicitly undefining _WINDOWS. The following alternatives are either ineffective
  # or not applicable:
  #
  # (1) Modifying and restoring CMAKE_C_FLAGS does not work reliably, as CMake appears
  #     to apply cached values during the generation step after the function executes.
  #
  # (2) Using get_target_property/set_property to manipulate COMPILE_DEFINITIONS
  #     is ineffective, since /D_WINDOWS is introduced via CMAKE_C_FLAGS and not
  #     associated with the target's properties.
  #
  # See: https://gitlab.kitware.com/cmake/cmake/-/issues/19796

  add_executable(${target_name} ${ARGN})

  # Note: /U_WINDOWS overrides the implicit /D_WINDOWS flag, resulting in MSVC warning D9025.
  # This warning is harmless and cannot be suppressed directly.
  target_compile_options(${target_name} PRIVATE /U_WINDOWS)
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
