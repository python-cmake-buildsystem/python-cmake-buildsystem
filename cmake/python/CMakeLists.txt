set(PYTHON_SOURCES
    ${CMAKE_SOURCE_DIR}/Modules/python.c
)

add_executable(python ${PYTHON_SOURCES})

# Link against the shared libpython if it was built, otherwise use the static
# version.
if (ENABLE_SHARED)
    target_link_libraries(python libpython-shared)
else (ENABLE_SHARED)
    target_link_libraries(python libpython-static)
endif (ENABLE_SHARED)

install(TARGETS python RUNTIME DESTINATION bin)
