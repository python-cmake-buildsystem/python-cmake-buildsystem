# Install all the python module source from Lib/

set(libdir ${SRC_DIR}/Lib)
file(GLOB_RECURSE libfiles RELATIVE ${libdir} "${libdir}/*")

if(UNIX)
    set(plat_subdir "plat-linux")
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
        file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/${PYTHONHOME}/${path})
        file(COPY ${libdir}/${file} DESTINATION ${PROJECT_BINARY_DIR}/${PYTHONHOME}/${path})

        # Install
        install(FILES ${libdir}/${file} DESTINATION ${PYTHONHOME}/${path})

    endif()
endforeach()

# Generate grammar tables in install directory
# XXX Should a custom target be added to generate file at built time ?
install(CODE "find_program(
  PYTHON_EXECUTABLE python
  HINTS \$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${BIN_INSTALL_DIR}
  NO_DEFAULT_PATH)
set(wrapper)
if(UNIX)
  set(_envvar LD_LIBRARY_PATH)
  if(APPLE)
    set(_envvar DYLD_LIBRARY_PATH)
  endif()
  set(wrapper env \${_envvar}=\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${LIBPYTHON_LIBDIR})
endif()
execute_process(COMMAND \${wrapper} \${PYTHON_EXECUTABLE} -m lib2to3.pgen2.driver
  \$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${PYTHONHOME}/lib2to3/Grammar.txt)
execute_process(COMMAND \${wrapper} \${PYTHON_EXECUTABLE} -m lib2to3.pgen2.driver
  \$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${PYTHONHOME}/lib2to3/PatternGrammar.txt)
")
