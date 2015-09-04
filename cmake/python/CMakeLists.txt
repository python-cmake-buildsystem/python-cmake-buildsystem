set(PYTHON_SOURCES
    ${SRC_DIR}/Modules/python.c
)

add_executable(python ${PYTHON_SOURCES})
set_property(
    TARGET python
    PROPERTY RUNTIME_OUTPUT_DIRECTORY ${BIN_BUILD_DIR}
    )

# Link against the shared libpython if it was built, otherwise use the static
# version.
if(BUILD_SHARED)
    target_link_libraries(python libpython-shared)
else(BUILD_SHARED)
    target_link_libraries(python libpython-static)
    set_target_properties(python PROPERTIES COMPILE_DEFINITIONS Py_NO_ENABLE_SHARED)
endif(BUILD_SHARED)

# Export target
set_property(GLOBAL APPEND PROPERTY PYTHON_TARGETS python)

install(TARGETS python EXPORT PythonTargets RUNTIME DESTINATION ${BIN_INSTALL_DIR} COMPONENT Runtime)

if(UNIX AND PY_VERSION VERSION_GREATER "2.7.4")
    # Setup landmark allowing to run the interpreter from a build tree. See 'getpath.c' for details.
    add_custom_command(
        OUTPUT ${BIN_BUILD_DIR}/pybuilddir.txt ${EXTENSION_BUILD_DIR}/_sysconfigdata.py
        COMMAND ${PYTHON_WRAPPER_COMMAND} $<TARGET_FILE:python> -E -S -m sysconfig --generate-posix-vars
        COMMAND ${CMAKE_COMMAND}
          -DBIN_BUILD_DIR:PATH=${BIN_BUILD_DIR}
          -DPYTHON_BINARY_DIR:PATH=${CMAKE_BINARY_DIR}
          -DEXTENSION_INSTALL_DIR:PATH=${EXTENSION_INSTALL_DIR}
          -P ${CMAKE_SOURCE_DIR}/cmake/UpdateSysconfig.cmake
        COMMENT "Relocate _sysconfigdata.py and update pybuilddir.txt"
        WORKING_DIRECTORY ${BIN_BUILD_DIR}
        DEPENDS python
        )
    add_custom_target(update_sysconfig ALL
        DEPENDS ${BIN_BUILD_DIR}/pybuilddir.txt ${EXTENSION_BUILD_DIR}/_sysconfigdata.py
        )
    install(FILES ${EXTENSION_BUILD_DIR}/_sysconfigdata.py
        DESTINATION ${PYTHONHOME}/)
endif()

if(UNIX)
  install(CODE
"message(STATUS \"Creating Python executable symlinks...\")
execute_process(
  COMMAND \${CMAKE_COMMAND} -E create_symlink python
    python${PY_VERSION_MAJOR}
  COMMAND \${CMAKE_COMMAND} -E create_symlink python
    python${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}
  WORKING_DIRECTORY
    \$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${BIN_INSTALL_DIR}
  )"
)
endif(UNIX)
