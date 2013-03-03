set(PYTHON_SOURCES
    ${SRC_DIR}/Modules/python.c
)

add_executable(python ${PYTHON_SOURCES})
set_property(
    TARGET python
    PROPERTY RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${BINDIR}
    )

# Link against the shared libpython if it was built, otherwise use the static
# version.
if(ENABLE_SHARED)
    target_link_libraries(python libpython-shared)
else(ENABLE_SHARED)
    target_link_libraries(python libpython-static)
    set_target_properties(python PROPERTIES COMPILE_DEFINITIONS Py_NO_ENABLE_SHARED)
endif(ENABLE_SHARED)

# Export target
set_property(GLOBAL APPEND PROPERTY PYTHON_TARGETS python)

install(TARGETS python EXPORT PythonTargets RUNTIME DESTINATION ${BINDIR} COMPONENT Runtime)
