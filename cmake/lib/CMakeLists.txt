# Install all the python module source from Lib/

set(libdir ${SRC_DIR}/Lib)
file(GLOB_RECURSE libfiles RELATIVE ${libdir} "${libdir}/*")

if(UNIX)
    set(plat_subdir "plat-linux2")
endif()

foreach(file ${libfiles})
    # Don't install files for other platforms
    string(REGEX MATCH "^plat-" is_platform_file "${file}")
    if(plat_subdir)
        string(REGEX MATCH "^${plat_subdir}" is_matching_platform_file "${file}")
    endif()

    # Exclude tests if BUILD_TESTING is OFF
    string(REGEX MATCH "^test" is_test "${file}")
    set(include_file 1)

    if(is_test AND (NOT BUILD_TESTING OR NOT INSTALL_TEST))
        set(include_file 0)
    endif()

    if(include_file AND (NOT is_platform_file OR is_matching_platform_file))
        get_filename_component(path ${file} PATH)

        # Copy lib files to build tree
        file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/${PYTHONHOME}/${path})
        file(COPY ${libdir}/${file} DESTINATION ${CMAKE_BINARY_DIR}/${PYTHONHOME}/${path})

        # Install
        install(FILES ${libdir}/${file} DESTINATION ${PYTHONHOME}/${path})

    endif()
endforeach()

if(PY_VERSION VERSION_LESS "2.7.5")
  # Setup landmark allowing to run the interpreter from a build tree. See 'getpath.c' for details.
  file(MAKE_DIRECTORY ${BIN_BUILD_DIR}/Modules)
  file(WRITE ${BIN_BUILD_DIR}/Modules/Setup "")
endif()

# Generate grammar tables in install directory
# XXX Should a custom target be added to generate file at built time ?
install(CODE "find_program(
  PYTHON_EXECUTABLE python
  HINTS \$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${BIN_INSTALL_DIR}
  NO_DEFAULT_PATH)
execute_process(COMMAND \${PYTHON_EXECUTABLE} -m lib2to3.pgen2.driver
  \$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${PYTHONHOME}/lib2to3/Grammar.txt)
execute_process(COMMAND \${PYTHON_EXECUTABLE} -m lib2to3.pgen2.driver
  \$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${PYTHONHOME}/lib2to3/PatternGrammar.txt)
")
