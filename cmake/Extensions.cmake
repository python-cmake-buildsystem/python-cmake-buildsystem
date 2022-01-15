# This function adds a python extension to the buildsystem.
#
# Usage:
#
# add_python_extension(
#     extension_name
#     SOURCES source1.c source2.c ...
#     [ REQUIRES variable1 variable2 ... ]
#     [ DEFINITIONS define1 define2 ... ]
#     [ LIBRARIES lib1 lib2 ... ]
#     [ INCLUDEDIRS dir1 dir2 ... ]
#     [ BUILTIN | ALWAYS_BUILTIN | NEVER_BUILTIN ]
# )
#
# extension_name: the name of the library without any .so extension.
# SOURCES:     a list of filenames realtive to the Modules/ directory that make
#              up this extension.
# REQUIRES:    this extension will not be built unless all the variables listed
#              here evaluate to true.  You should include any variables you use
#              in the LIBRARIES and INCLUDEDIRS sections.
# DEFINITIONS: an optional list of definitions to pass to the compiler while
#              building this module.  Do not include the -D prefix.
# LIBRARIES:   an optional list of additional libraries.
# INCLUDEDIRS: an optional list of additional include directories.
# BUILTIN:     if this is set the module will be compiled statically into
#              libpython by default.  The user can still override by setting
#              BUILTIN_[extension_name]=OFF.
# ALWAYS_BUILTIN: if this is set the module will always be compiled statically into
#                 libpython.
# NEVER_BUILTIN: if this is set the module will never be compiled statically into
#                libpython. If WITH_STATIC_DEPENDENCIES is ON, extension is disabled.
# NO_INSTALL:   do not install or package the extension.
#
# Two user-settable options are created for each extension added:
# ENABLE_[extension_name]   defaults to ON.  If set to OFF the extension will
#                           not be added at all.
# BUILTIN_[extension_name]  defaults to the value of
#                           BUILD_EXTENSIONS_AS_BUILTIN, which defaults to OFF,
#                           unless BUILTIN is set when calling
#                           add_python_extension.  Adds the extension source
#                           files to libpython instead of compiling a separate
#                           library.
# These options convert the extension_name to upper case first and remove any
# leading underscores.  So add_python_extension(_foo ...) will create the
# options ENABLE_FOO and BUILTIN_FOO.

function(add_python_extension name)
    set(options BUILTIN ALWAYS_BUILTIN NEVER_BUILTIN NO_INSTALL)
    set(oneValueArgs)
    set(multiValueArgs REQUIRES SOURCES DEFINITIONS LIBRARIES INCLUDEDIRS)
    cmake_parse_arguments(ADD_PYTHON_EXTENSION
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
        ${ARGN}
        )

    # Remove _ from the beginning of the name.
    string(REGEX REPLACE "^_" "" pretty_name "${name}")

    # Upper case the name.
    string(TOUPPER "${pretty_name}" upper_name)

    # Add a prefix to the target name so it doesn't clash with any system
    # libraries that we might want to link against (eg. readline)
    set(target_name extension_${pretty_name})

    set(enable_default ON)
    if(ADD_PYTHON_EXTENSION_NEVER_BUILTIN AND WITH_STATIC_DEPENDENCIES)
        set(enable_default OFF)
    endif()

    # Add options that the user can set to control whether this extension is
    # compiled, and whether it is compiled in to libpython itself.
    option(ENABLE_${upper_name}
           "Controls whether the \"${name}\" extension will be built"
           ${enable_default}
    )
    if(ENABLE_${upper_name})
        mark_as_advanced(FORCE ENABLE_${upper_name})
    else()
        mark_as_advanced(CLEAR ENABLE_${upper_name})
    endif()

   if(ADD_PYTHON_EXTENSION_NEVER_BUILTIN AND WITH_STATIC_DEPENDENCIES AND ENABLE_${upper_name})
       set(reason " because extension is declared as NEVER_BUILTIN and WITH_STATIC_DEPENDENCIES is ON")
       set(ENABLE_${upper_name} OFF CACHE BOOL "Forced to OFF${reason}" FORCE)
       message(STATUS "Setting ENABLE_${upper_name} to OFF${reason}")
   endif()

    # Check all the things we require are found.
    set(missing_deps "")
    foreach(dep ${ADD_PYTHON_EXTENSION_REQUIRES} ENABLE_${upper_name})
        string(REPLACE " " ";" list_dep ${dep})
        if(NOT (${list_dep}))
            set(missing_deps "${missing_deps}${dep} ")
        endif()
    endforeach()

    if(ADD_PYTHON_EXTENSION_NEVER_BUILTIN)
        set(BUILTIN_${upper_name} 0)
    elseif(ADD_PYTHON_EXTENSION_ALWAYS_BUILTIN)
        set(BUILTIN_${upper_name} 1)
    else()
        # Add options that the extention is either external to libpython or
        # builtin.  These will be marked as advanced unless different from default
        # values
        if(NOT ADD_PYTHON_EXTENSION_BUILTIN)
            set(ADD_PYTHON_EXTENSION_BUILTIN ${BUILD_EXTENSIONS_AS_BUILTIN})
        endif()
        cmake_dependent_option(
            BUILTIN_${upper_name}
            "If this is set the \"${name}\" extension will be compiled in to libpython"
            ${ADD_PYTHON_EXTENSION_BUILTIN}
            "NOT missing_deps"
            OFF
        )
        if(NOT missing_deps)
            if((BUILTIN_${upper_name} AND BUILD_EXTENSIONS_AS_BUILTIN)
                OR (NOT BUILTIN_${upper_name} AND NOT BUILD_EXTENSIONS_AS_BUILTIN))
                mark_as_advanced(FORCE BUILTIN_${upper_name})
            else()
                mark_as_advanced(CLEAR BUILTIN_${upper_name})
            endif()
        endif()
    endif()

    # If any dependencies were missing don't include this extension.
    if(missing_deps)
        string(STRIP "${missing_deps}" missing_deps)
        set(extensions_disabled "${extensions_disabled}${name} (not set: ${missing_deps});"
             CACHE INTERNAL "" FORCE)
        return()
    else()
        set(extensions_enabled "${extensions_enabled}${name};" CACHE INTERNAL "" FORCE)
    endif()

    # Callers to this function provide source files relative to the Modules/
    # directory.  We need to get absolute paths for them all.
    set(absolute_sources "")
    foreach(source ${ADD_PYTHON_EXTENSION_SOURCES})
        get_filename_component(ext ${source} EXT)

        # Treat assembler sources differently
        if(ext STREQUAL ".S")
            set_source_files_properties(Modules/${source} PROPERTIES LANGUAGE ASM)
        endif()
        set(absolute_src ${source})
        if(NOT IS_ABSOLUTE ${source})
            set(absolute_src ${SRC_DIR}/Modules/${source})
        endif()
        list(APPEND absolute_sources ${absolute_src})
    endforeach()

    if(BUILTIN_${upper_name})
        if(PY_VERSION VERSION_GREATER_EQUAL "3.8")
            list(APPEND ADD_PYTHON_EXTENSION_DEFINITIONS Py_BUILD_CORE_BUILTIN)
        endif()
        # This will be compiled into libpython instead of as a separate library
        set_property(GLOBAL APPEND PROPERTY builtin_extensions ${name})
        set_property(GLOBAL APPEND PROPERTY extension_${name}_sources ${absolute_sources})
        set_property(GLOBAL APPEND PROPERTY extension_${name}_link_libraries ${ADD_PYTHON_EXTENSION_LIBRARIES})
        set_property(GLOBAL APPEND PROPERTY extension_${name}_includedirs ${ADD_PYTHON_EXTENSION_INCLUDEDIRS})
        set_property(GLOBAL APPEND PROPERTY extension_${name}_definitions ${ADD_PYTHON_EXTENSION_DEFINITIONS})
    elseif(WIN32 AND NOT BUILD_LIBPYTHON_SHARED)
        # Extensions cannot be built against a static libpython on windows
    else()

        add_library(${target_name} SHARED ${absolute_sources})
        target_include_directories(${target_name} PUBLIC "${ADD_PYTHON_EXTENSION_INCLUDEDIRS}")

        if(PY_VERSION VERSION_GREATER_EQUAL "3.8")
            list(APPEND ADD_PYTHON_EXTENSION_DEFINITIONS Py_BUILD_CORE_MODULE)
        endif()

        if(WIN32)
            string(REGEX MATCH "Py_LIMITED_API" require_limited_api "${ADD_PYTHON_EXTENSION_DEFINITIONS}")
            if(require_limited_api STREQUAL "")
              list(APPEND ADD_PYTHON_EXTENSION_LIBRARIES libpython-shared)
            else()
              list(APPEND ADD_PYTHON_EXTENSION_LIBRARIES libpython3-shared)
            endif()
        endif()

        target_link_libraries(${target_name} ${ADD_PYTHON_EXTENSION_LIBRARIES})

        if(WIN32)
            #list(APPEND ADD_PYTHON_EXTENSION_DEFINITIONS Py_NO_ENABLE_SHARED)
            if(MINGW)
                set_target_properties(${target_name} PROPERTIES
                    LINK_FLAGS -Wl,--enable-auto-import
                )
            endif()
            set_target_properties(${target_name} PROPERTIES
                SUFFIX .pyd
            )
        endif()

        if(APPLE)
            set_target_properties(${target_name} PROPERTIES
                LINK_FLAGS -Wl,-undefined,dynamic_lookup
                SUFFIX .so
            )
        endif()

        # Turn off the "lib" prefix and add any compiler definitions
        set_target_properties(${target_name} PROPERTIES
            ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/${ARCHIVEDIR}
            LIBRARY_OUTPUT_DIRECTORY ${EXTENSION_BUILD_DIR}
            RUNTIME_OUTPUT_DIRECTORY ${EXTENSION_BUILD_DIR}
            OUTPUT_NAME "${name}"
            PREFIX ""
        )
        set_target_properties(${target_name} PROPERTIES
            POSITION_INDEPENDENT_CODE ON
        )

        if(ADD_PYTHON_EXTENSION_DEFINITIONS)
            set_target_properties(${target_name} PROPERTIES
                COMPILE_DEFINITIONS "${ADD_PYTHON_EXTENSION_DEFINITIONS}")
        endif()

        if(NOT ADD_PYTHON_EXTENSION_NO_INSTALL)
            install(TARGETS ${target_name}
                    ARCHIVE DESTINATION ${ARCHIVEDIR}
                    LIBRARY DESTINATION ${EXTENSION_INSTALL_DIR}
                    RUNTIME DESTINATION ${EXTENSION_INSTALL_DIR})
        endif()
    endif()
endfunction()


function(show_extension_summary)
    if(extensions_disabled)
        message(STATUS "")
        message(STATUS "The following extensions will NOT be built:")
        message(STATUS "")
        foreach(line ${extensions_disabled})
            message(STATUS "    ${line}")
        endforeach()
        message(STATUS "")
    endif()
endfunction()
