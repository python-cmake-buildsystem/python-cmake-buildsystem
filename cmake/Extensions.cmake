function(add_python_extension name)
    parse_arguments(ADD_PYTHON_EXTENSION
        "SOURCES;LIBRARIES;INCLUDEDIRS"
        ""
        ${ARGN}
    )

    # Add a prefix to the target name so it doesn't clash with any system
    # libraries that we might want to link against (eg. readline)
    set(target_name extension_${name})

    # Callers to this function provide source files relative to the Modules/
    # directory.  We need to get absolute paths for them all.
    set(absolute_sources "")
    foreach(source ${ADD_PYTHON_EXTENSION_SOURCES})
        get_filename_component(ext ${source} EXT)

        # Treat assembler sources differently
        if(${ext} STREQUAL ".S")
            add_assembler(absolute_sources Modules/${source} ${ADD_PYTHON_EXTENSION_INCLUDEDIRS})
        else(${ext} STREQUAL ".S")
            list(APPEND absolute_sources ${CMAKE_SOURCE_DIR}/Modules/${source})
        endif(${ext} STREQUAL ".S")
    endforeach(source)

    add_library(${target_name} SHARED ${absolute_sources})
    include_directories(${ADD_PYTHON_EXTENSION_INCLUDEDIRS})
    target_link_libraries(${target_name} ${ADD_PYTHON_EXTENSION_LIBRARIES})

    # Turn off the "lib" prefix
    set_target_properties(${target_name} PROPERTIES
        OUTPUT_NAME "${name}"
        PREFIX ""
    )

    install(TARGETS ${target_name} LIBRARY DESTINATION lib/${LIBPYTHON}/lib-dynload)
endfunction(add_python_extension)
