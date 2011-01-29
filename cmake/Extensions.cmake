function(add_python_extension name)
    parse_arguments(ADD_PYTHON_EXTENSION
        "REQUIRES;SOURCES;LIBRARIES;INCLUDEDIRS"
        "BUILTIN"
        ${ARGN}
    )

    # Remove _ from the beginning of the name.
    string(REGEX REPLACE "^_" "" pretty_name "${name}")

    # Upper case the name.
    string(TOUPPER "${pretty_name}" upper_name)

    # Add a prefix to the target name so it doesn't clash with any system
    # libraries that we might want to link against (eg. readline)
    set(target_name extension_${pretty_name})

    # Add options that the user can set to control whether this extension is
    # compiled, and whether it is compiled in to libpython itself.
    option(ENABLE_${upper_name}
           "Controls whether the \"${name}\" extension will be built"
           ON
    )
    option(BUILTIN_${upper_name}
           "If this is set the \"${name}\" extension will be compiled in to libpython"
           ${ADD_PYTHON_EXTENSION_BUILTIN}
    )

    # Check all the things we require are found.
    set(missing_deps "")
    foreach(dep ${ADD_PYTHON_EXTENSION_REQUIRES} ENABLE_${upper_name})
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

    if(BUILTIN_${upper_name})
        # This will be compiled into libpython instead of as a separate library
        set(builtin_extensions "${builtin_extensions}${name};" CACHE INTERNAL "" FORCE)
        set(builtin_source "${builtin_source}${absolute_sources};" CACHE INTERNAL "" FORCE)
        set(builtin_link_libraries "${builtin_link_libraries}${ADD_PYTHON_EXTENSION_LIBRARIES};" CACHE INTERNAL "" FORCE)
    elseif(WIN32 AND NOT ENABLE_SHARED)
        # Extensions cannot be built against a static libpython on windows
    else(BUILTIN_${upper_name})
        add_library(${target_name} SHARED ${absolute_sources})
        include_directories(${ADD_PYTHON_EXTENSION_INCLUDEDIRS})
        target_link_libraries(${target_name} ${ADD_PYTHON_EXTENSION_LIBRARIES})

        # Turn off the "lib" prefix
        set_target_properties(${target_name} PROPERTIES
            OUTPUT_NAME "${name}"
            PREFIX ""
        )

        install(TARGETS ${target_name}
                LIBRARY DESTINATION lib/${LIBPYTHON}/lib-dynload
                RUNTIME DESTINATION lib/${LIBPYTHON}/lib-dynload)
    endif(BUILTIN_${upper_name})
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
