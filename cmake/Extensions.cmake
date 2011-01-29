function(add_python_extension name)
    parse_arguments(ADD_PYTHON_EXTENSION
        "REQUIRES;SOURCES;LIBRARIES;INCLUDEDIRS"
        ""
        ${ARGN}
    )

    # Check all the things we require are found.
    set(missing_deps "")
    foreach(dep ${ADD_PYTHON_EXTENSION_REQUIRES})
        if(NOT ${dep})
            set(missing_deps "${missing_deps}${dep} ")
        endif(NOT ${dep})
    endforeach(dep)

    # If any dependencies were missing don't include this extension.
    if(missing_deps)
        string(STRIP "${missing_deps}" missing_deps)
        set(extensions_disabled "${extensions_disabled}${name} (not set: ${missing_deps});"
             CACHE INTERNAL "" FORCE)
        return()
    else(missing_deps)
        set(extensions_enabled "${extensions_enabled}${name};" CACHE INTERNAL "" FORCE)
    endif(missing_deps)

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


function(show_extension_summary)
    if(extensions_disabled)
        message(STATUS "")
        message(STATUS "The following extensions will NOT be built:")
        message(STATUS "")
        foreach(line ${extensions_disabled})
            message(STATUS "    ${line}")
        endforeach(line)
        message(STATUS "")
    endif(extensions_disabled)
endfunction(show_extension_summary)
