set(PYTHON_SOURCES
    ${SRC_DIR}/$<IF:$<VERSION_GREATER_EQUAL:${PY_VERSION},3.5>,Programs,Modules>/python.c
)

add_executable(python ${PYTHON_SOURCES})
set_property(
    TARGET python
    PROPERTY RUNTIME_OUTPUT_DIRECTORY ${BIN_BUILD_DIR}
    )
target_compile_definitions(python PRIVATE Py_BUILD_CORE)
add_definitions(-DPy_BUILD_CORE)

# Link against the shared libpython if it was built, otherwise use the static
# version.
if(BUILD_LIBPYTHON_SHARED)
    target_link_libraries(python libpython-shared)
else()
    target_link_libraries(python libpython-static)
    set_target_properties(python PROPERTIES
        COMPILE_DEFINITIONS Py_NO_ENABLE_SHARED
        ENABLE_EXPORTS ON
    )
endif()

if(MSVC)
    set_target_properties(python PROPERTIES LINK_FLAGS /STACK:2000000)
endif()

# Export target
set_property(GLOBAL APPEND PROPERTY PYTHON_TARGETS python)

install(TARGETS python EXPORT PythonTargets RUNTIME DESTINATION ${BIN_INSTALL_DIR} COMPONENT Runtime)

# See "is_python_build()" in sysconfig.py
add_custom_command(TARGET python PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${BIN_BUILD_DIR}/${CMAKE_CFG_INTDIR}/Modules
    COMMAND ${CMAKE_COMMAND} -E touch ${BIN_BUILD_DIR}/${CMAKE_CFG_INTDIR}/Modules/Setup.local
    COMMENT "Creating '${BIN_INSTALL_DIR}/${CMAKE_CFG_INTDIR}/Modules/Setup.local'"
    )

if(WIN32)
    # See "get_config_h_filename()" in sysconfig.py
    add_custom_command(TARGET python POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory ${BIN_BUILD_DIR}/${CMAKE_CFG_INTDIR}/PC
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${SRC_DIR}/PC/pyconfig.h ${BIN_BUILD_DIR}/${CMAKE_CFG_INTDIR}/PC/pyconfig.h
        COMMENT "Copying 'pyconfig.h' to '${BIN_INSTALL_DIR}/${CMAKE_CFG_INTDIR}/PC'"
        )
endif()

if(UNIX)
    # Setup landmark allowing to run the interpreter from a build tree. See 'getpath.c' for details.
    set(_sysconfigdata_py "_sysconfigdata.py")
    if("${PY_VERSION}" VERSION_GREATER_EQUAL "3.6.0")
        # XXX Add support for _PYTHON_SYSCONFIGDATA_NAME env. variable
        set(MULTIARCH "")
        set(_sysconfigdata_py "_sysconfigdata_${ABIFLAGS}_${PY_PLATFORM}_${MULTIARCH}.py")
    endif()
    add_custom_command(
        OUTPUT ${BIN_BUILD_DIR}/pybuilddir.txt ${EXTENSION_BUILD_DIR}/${_sysconfigdata_py}
        COMMAND ${PYTHON_WRAPPER_COMMAND}
          ${CMAKE_CROSSCOMPILING_EMULATOR} $<TARGET_FILE:python> -E -S -m sysconfig --generate-posix-vars
        COMMAND ${CMAKE_COMMAND}
          -DBIN_BUILD_DIR:PATH=${BIN_BUILD_DIR}
          -DSYSCONFIGDATA_PY:STRING=${_sysconfigdata_py}
          -DPYTHON_BINARY_DIR:PATH=${PROJECT_BINARY_DIR}
          -DEXTENSION_INSTALL_DIR:PATH=${EXTENSION_INSTALL_DIR}
          -P ${PROJECT_SOURCE_DIR}/cmake/UpdateSysconfig.cmake
        COMMENT "Relocate ${_sysconfigdata_py} and update pybuilddir.txt"
        WORKING_DIRECTORY ${BIN_BUILD_DIR}
        DEPENDS python
        )
    add_custom_target(update_sysconfig ALL
        DEPENDS ${BIN_BUILD_DIR}/pybuilddir.txt ${EXTENSION_BUILD_DIR}/${_sysconfigdata_py}
        )
    install(FILES ${EXTENSION_BUILD_DIR}/${_sysconfigdata_py}
        DESTINATION ${PYTHONHOME}/)
endif()

if(UNIX AND NOT CMAKE_CROSSCOMPILING)
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
endif()

# Copy up the gdb python hooks into a position where they can be automatically
# loaded by gdb during Lib/test/test_gdb.py
#
# Distributors are likely to want to install this somewhere else e.g. relative
# to the stripped DWARF data for the shared library.

set(SRC_GDB_HOOKS ${SRC_DIR}/Tools/gdb/libpython.py)
configure_file(
    ${SRC_GDB_HOOKS}
    ${BIN_BUILD_DIR}/python-gdb.py
    COPYONLY
)
if(INSTALL_DEVELOPMENT)
    install(FILES ${SRC_GDB_HOOKS} DESTINATION ${BIN_INSTALL_DIR} COMPONENT Development)
endif()
