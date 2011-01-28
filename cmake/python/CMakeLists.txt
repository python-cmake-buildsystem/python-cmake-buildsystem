set(PYTHON_SOURCES
    ${CMAKE_SOURCE_DIR}/Modules/python.c
)

add_executable(python ${PYTHON_SOURCES})
target_link_libraries(python ${LIBPYTHON})

install(TARGETS python RUNTIME DESTINATION bin)
