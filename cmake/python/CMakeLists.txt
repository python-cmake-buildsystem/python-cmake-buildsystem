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

if(UNIX)
  if ("${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}.${PY_VERSION_PATCH}" VERSION_GREATER "2.7.4")
    add_custom_target(build_sysconfigdata ALL
                      COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/build
                      COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR} $<TARGET_FILE:python> "-E" "-S" "-m" "sysconfig" "--generate-posix-vars"
		      COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR}/build find "." "-name" "'*.py'" "-exec" "cp" "{}" "${CMAKE_BINARY_DIR}/${PYTHONHOME}" "\;"
                      COMMENT "Generation of sysconfigdata file")
    
    set_source_files_properties(${CMAKE_BINARY_DIR}/${PYTHONHOME}/_sysconfigdata.py GENERATED)
    
    install(FILES ${CMAKE_BINARY_DIR}/${PYTHONHOME}/_sysconfigdata.py
            DESTINATION ${PYTHONHOME})
  endif ()
  
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
