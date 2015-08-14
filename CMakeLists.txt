cmake_minimum_required(VERSION 2.8.6)

set(PY_VERSION_MAJOR 2)
set(PY_VERSION_MINOR 7)
if(NOT DEFINED PY_VERSION_PATCH)
    set(PY_VERSION_PATCH 8)
endif()
set(PY_VERSION "${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}.${PY_VERSION_PATCH}")

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES Release CACHE STRING "Release configuration" FORCE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Release")
endif()

project(Python C ASM)

# Include helper functions
include(cmake/Extensions.cmake)
include(CMakeDependentOption)
include(CMakeParseArguments)
include(CTest)

# Options
option(DOWNLOAD_SOURCES "Automatically download the Python sources" ON)
option(BUILD_SHARED "Build a shared libpython library" OFF)
option(BUILD_STATIC "Build a static libpython library" ON)
option(BUILD_EXTENSIONS_AS_BUILTIN "Compile statically all modules into libpython" OFF)
option(USE_LIB64 "Search for dependencies and install to prefix/lib64 instead of prefix/lib" OFF)
if(WIN32)
  option(INSTALL_WINDOWS_TRADITIONAL "Install the executable and extensions in the traditional location" OFF)
else()
  set(INSTALL_WINDOWS_TRADITIONAL OFF)
endif()

option(USE_SYSTEM_LIBRARIES "Use system libraries" ON)

cmake_dependent_option(USE_SYSTEM_BZip2 "Use system BZip2" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_Curses "Use system Curses" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_EXPAT "Use system EXPAT" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_OpenSSL "Use system OpenSSL" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_TCL "Use system TCL" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_ZLIB "Use system ZLIB" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_DB "Use system DB" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_GDBM "Use system GDBM" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_READLINE "Use system READLINE" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_SQLITE3 "Use system SQLITE3" ON "USE_SYSTEM_LIBRARIES" OFF)

cmake_dependent_option(USE_LIBEDIT "Use libedit instead of readline" OFF
                       "USE_SYSTEM_READLINE" OFF)

option(WITH_TSC "profile with the Pentium timestamp counter" OFF)
option(ENABLE_IPV6 "Enable IP v6" ON)
option(WITH_DOC_STRINGS "Enable if you want documentation strings in extension modules" ON)
option(Py_USING_UNICODE "Enable unicode support" ON)
set(Py_DEBUG OFF) # TODO - Build debugging interpreter
option(WITH_PYMALLOC "Define if you want to compile in Python-specific mallocs" ON)
option(WITH_THREAD "Compile in rudimentary thread support" ON)

# Detect source directory
set(_landmark "pyconfig.h.in") # CMake will look for this file.
if(EXISTS ${CMAKE_SOURCE_DIR}/${_landmark})
    set(SRC_DIR ${CMAKE_SOURCE_DIR})
elseif(NOT "${SRC_DIR}" STREQUAL "" AND EXISTS ${SRC_DIR}/${_landmark})
    # Do nothing - SRC_DIR is already set.
else()
    foreach(dirname
        cpython-${PY_VERSION}
        Python-${PY_VERSION}
    )
        set(SRC_DIR "${CMAKE_CURRENT_BINARY_DIR}/../${dirname}")
        if(EXISTS ${SRC_DIR}/${_landmark})
            break()
        endif()
    endforeach()
endif()
if(NOT IS_ABSOLUTE ${SRC_DIR})
    set(SRC_DIR ${CMAKE_CURRENT_BINARY_DIR}/${SRC_DIR})
endif()
get_filename_component(_parent_dir ${CMAKE_CURRENT_BINARY_DIR} PATH)
set(_download_link "http://www.python.org/ftp/python/${PY_VERSION}/Python-${PY_VERSION}.tgz")
# Variable below represent the set of supported python version.
set(_download_2.7.3_md5 "2cf641732ac23b18d139be077bd906cd")
set(_download_2.7.4_md5 "592603cfaf4490a980e93ecb92bde44a")
set(_download_2.7.5_md5 "b4f01a1d0ba0b46b05c73b2ac909b1df")
set(_download_2.7.6_md5 "1d8728eb0dfcac72a0fd99c17ec7f386")
set(_download_2.7.7_md5 "cf842800b67841d64e7fb3cd8acb5663")
set(_download_2.7.8_md5 "d4bca0159acb0b44a781292b5231936f")
set(_download_2.7.9_md5 "5eebcaa0030dc4061156d3429657fb83")
set(_download_2.7.10_md5 "d7547558fd673bd9d38e2108c6b42521")
set(_extracted_dir "Python-${PY_VERSION}")

if(NOT EXISTS ${SRC_DIR}/${_landmark} AND DOWNLOAD_SOURCES)
    get_filename_component(_filename ${_download_link} NAME)
    set(_archive_filepath ${CMAKE_CURRENT_BINARY_DIR}/../${_filename})
    if(EXISTS "${_archive_filepath}")
        message(STATUS "${_filename} already downloaded")
    else()
        message(STATUS "Downloading ${_download_link}")
        file(
          DOWNLOAD ${_download_link} ${_archive_filepath}
          EXPECTED_MD5 ${_download_${PY_VERSION}_md5}
          SHOW_PROGRESS
          )
    endif()

    message(STATUS "Extracting ${_filename}")
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xfz ${_archive_filepath}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/..
        RESULT_VARIABLE rv)
    if(NOT rv EQUAL 0)
        message(FATAL_ERROR "error: extraction of '${_filename}' failed")
    endif()
    set(SRC_DIR ${CMAKE_CURRENT_BINARY_DIR}/../${_extracted_dir})
endif()

if(NOT EXISTS ${SRC_DIR}/${_landmark})
    message(FATAL_ERROR "Failed to locate python source.
The searched locations were:
   <CMAKE_CURRENT_BINARY_DIR>
   <CMAKE_CURRENT_BINARY_DIR>/../cpython-${PY_VERSION}
   <CMAKE_CURRENT_BINARY_DIR>/../Python-${PY_VERSION}
   <SRC_DIR>
You could try to:
  1) download ${_download_link}
  2) extract the archive in folder: ${_parent_dir}
  3) Check that file \"${_parent_dir}/${_extracted_dir}/${_landmark}\" exists.
  4) re-configure.
If you already downloaded the source, you could try to re-configure this project passing -DSRC_DIR:PATH=/path/to/Python-{PY_VERSION} using cmake or adding an PATH entry named SRC_DIR from cmake-gui.")
endif()
message(STATUS "SRC_DIR: ${SRC_DIR}")

# Extract version from python source (Copied from FindPythonLibs.cmake)
file(STRINGS "${SRC_DIR}/Include/patchlevel.h" python_version_str
    REGEX "^#define[ \t]+PY_VERSION[ \t]+\"[^\"]+\"")
string(REGEX REPLACE "^#define[ \t]+PY_VERSION[ \t]+\"([^\"]+)\".*" "\\1"
    _version "${python_version_str}")
string(REGEX REPLACE "([0-9])\\..+" "\\1"
    PY_VERSION_MAJOR ${_version})
string(REGEX REPLACE "[0-9]\\.([0-9]+)\\..+" "\\1"
    PY_VERSION_MINOR ${_version})
string(REGEX REPLACE "[0-9]\\.[0-9]+\\.([0-9]+)" "\\1"
    PY_VERSION_PATCH ${_version})
set(PY_VERSION "${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}.${PY_VERSION_PATCH}")
message(STATUS "PY_VERSION: ${PY_VERSION}")
if(NOT DEFINED _download_${PY_VERSION}_md5)
    message(FATAL_ERROR "error: unknown python version '${PY_VERSION}'. Valid version should match '2.7.[3-10]'")
endif()

# This is the major version number of Python
set(LIBPYTHON_VERSION ${PY_VERSION_MAJOR}.${PY_VERSION_MINOR})
if(MSVC)
    set(LIBPYTHON_VERSION ${PY_VERSION_MAJOR}${PY_VERSION_MINOR})
endif(MSVC)
set(LIBPYTHON python${LIBPYTHON_VERSION})

# Proceed to the configure checks
include(cmake/ConfigureChecks.cmake)

if(NOT BUILD_SHARED AND NOT BUILD_STATIC)
    message(FATAL_ERROR "One or both of BUILD_SHARED or BUILD_STATIC must be set")
endif(NOT BUILD_SHARED AND NOT BUILD_STATIC)

# Set PYTHONHOME
set(LIBDIR "Lib") # See Lib/distutils/sysconfig.py - function 'get_python_lib'
if(UNIX)
    set(LIBDIR "lib")
endif()
if(USE_LIB64)
    set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS ON)
    set(LIBDIR "lib64")
endif()
set(PYTHONHOME "${LIBDIR}")
if(UNIX)
    set(PYTHONHOME "${PYTHONHOME}/${LIBPYTHON}")
endif()

# Install tree directory
set(BIN_INSTALL_DIR bin)                         # Contains the python executable
if(INSTALL_WINDOWS_TRADITIONAL)
    set(BIN_INSTALL_DIR .)                       # Contains the python executable
endif()
set(CONFIG_INSTALL_DIR share/${LIBPYTHON})
set(EXTENSION_INSTALL_DIR ${PYTHONHOME}/lib-dynload)
if(INSTALL_WINDOWS_TRADITIONAL)
    set(EXTENSION_INSTALL_DIR DLLs)
endif()
set(INCLUDE_INSTALL_DIR include/${LIBPYTHON})
if(MSVC)
    set(INCLUDE_INSTALL_DIR include)
endif(MSVC)
# Build tree directory
set(BIN_BUILD_DIR ${CMAKE_BINARY_DIR}/bin)
set(CONFIG_BUILD_DIR ${CMAKE_BINARY_DIR}/${CONFIG_INSTALL_DIR})
set(EXTENSION_BUILD_DIR ${CMAKE_BINARY_DIR}/${PYTHONHOME}/lib-dynload)
set(INCLUDE_BUILD_DIR ${SRC_DIR}/Include)

set(ARCHIVEDIR "libs")      # Contains the static (*.a) and import libraries (*.lib)

# Directories specific to 'libpython'
set(LIBPYTHON_LIBDIR ${LIBDIR})
set(LIBPYTHON_ARCHIVEDIR ${LIBDIR})
set(LIBPYTHON_STATIC_ARCHIVEDIR ${LIBDIR})
if(WIN32)
    set(LIBPYTHON_LIBDIR ${BIN_INSTALL_DIR})
    set(LIBPYTHON_ARCHIVEDIR ${ARCHIVEDIR})
    set(LIBPYTHON_STATIC_ARCHIVEDIR static-${ARCHIVEDIR})
endif()

set(EXTRA_PYTHONPATH "" CACHE STRING
    "A colon (:) separated list of extra paths to add to the PYTHONPATH")

# Configure 'pyconfig.h'
if(UNIX)
    set(PYCONFIG_BUILD_DIR ${BIN_BUILD_DIR})
    configure_file(cmake/config-unix/pyconfig.h.in
                   ${PYCONFIG_BUILD_DIR}/pyconfig.h)
elseif(WIN32)
    set(PYCONFIG_BUILD_DIR ${SRC_DIR}/PC) # In a windows build tree, 'pyconfig.h' is NOT required to
                                          # live along side the python executable.
                                          # See function '_init_posix()' and '_init_non_posix()'
                                          # in 'Lib/sysconfig.py'
endif(UNIX)

# Install 'pyconfig.h'
install(FILES ${PYCONFIG_BUILD_DIR}/pyconfig.h
        DESTINATION ${INCLUDE_INSTALL_DIR}/)

# Set include directories
include_directories(${INCLUDE_BUILD_DIR})
include_directories(${PYCONFIG_BUILD_DIR})
include_directories(${SRC_DIR}/Python)

# Set cflags used by all components
if(UNIX)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-strict-aliasing -fwrapv -Wall -Wstrict-prototypes")
endif(UNIX)
if(MSVC)
    string(REPLACE "/Ob2" "/Ob1" CMAKE_C_FLAGS_RELEASE ${CMAKE_C_FLAGS_RELEASE}) # InlineFunctionExpansion=1
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}" CACHE STRING "Flags used by the compiler during release builds" FORCE)
endif(MSVC)

if(NOT WIN32)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
endif(NOT WIN32)

# Useful additional variables that extensions can use.
if(UNIX AND NOT APPLE)
    set(LINUX ON)
else(UNIX AND NOT APPLE)
    set(LINUX OFF)
endif(UNIX AND NOT APPLE)

# Clear PythonTargets.cmake
file(WRITE ${CONFIG_BUILD_DIR}/PythonTargets.cmake "")

# Add extension modules
set(extensions_enabled "" CACHE INTERNAL "" FORCE)
set(extensions_disabled "" CACHE INTERNAL "" FORCE)
add_subdirectory(cmake/extensions CMakeBuild/extensions)

# Add the other subdirectories
add_subdirectory(cmake/pgen CMakeBuild/pgen)
add_subdirectory(cmake/libpython CMakeBuild/libpython)
add_subdirectory(cmake/python CMakeBuild/python)
add_subdirectory(cmake/include CMakeBuild/include)
add_subdirectory(cmake/lib CMakeBuild/lib)

show_extension_summary()

if(UNIX)

    # python.pc
    configure_file(cmake/python.pc.in
                  ${CMAKE_BINARY_DIR}/Misc/python-${LIBPYTHON_VERSION}.pc @ONLY)
    configure_file(cmake/python.pc.in
                  ${CMAKE_BINARY_DIR}/Misc/python-${PY_VERSION_MAJOR}.pc @ONLY)
    configure_file(cmake/python.pc.in
                  ${CMAKE_BINARY_DIR}/Misc/python.pc @ONLY)
    install(FILES
                ${CMAKE_BINARY_DIR}/Misc/python-${LIBPYTHON_VERSION}.pc
                ${CMAKE_BINARY_DIR}/Misc/python-${PY_VERSION_MAJOR}.pc
                ${CMAKE_BINARY_DIR}/Misc/python.pc
            DESTINATION lib/pkgconfig)

    # Makefile
    set(MAKEFILE_LDSHARED_FLAGS "-shared")
    if(APPLE)
        set(MAKEFILE_LDSHARED_FLAGS "-dynamiclib -headerpad_max_install_names -undefined dynamic_lookup")
    endif(APPLE)
    configure_file(cmake/makefile-variables.in
                   ${BIN_BUILD_DIR}/Makefile @ONLY)
    install(FILES ${BIN_BUILD_DIR}/Makefile
            DESTINATION ${PYTHONHOME}/config/
            RENAME Makefile)

    # Utility scripts
    install(FILES ${SRC_DIR}/install-sh ${SRC_DIR}/Modules/makesetup
            DESTINATION ${PYTHONHOME}/config/)

endif(UNIX)

# Create an empty lib-dynload folder, even if we don't have any extentions
# to go in there.  bin/python uses this to auto-determine the exec_prefix
# and properly generate the _sysconfigdata.py
file(MAKE_DIRECTORY "${EXTENSION_BUILD_DIR}")
install(DIRECTORY ${EXTENSION_BUILD_DIR} DESTINATION ${PYTHONHOME})

if(BUILD_TESTING)
    set(EXTRATESTOPTS -v)
    set(TESTOPTS -l ${EXTRATESTOPTS})
    set(TESTPROG ${CMAKE_BINARY_DIR}/${PYTHONHOME}/test/regrtest.py)
    set(TESTPYTHONOPTS )
    set(TESTPYTHON $<TARGET_FILE:python> -Wd -3 -E -tt ${TESTPYTHONOPTS})

    include(cmake/UnitTests.cmake)
    foreach(unittest ${unittests})
      add_test(NAME ${unittest} COMMAND ${TESTPYTHON} ${TESTPROG} ${TESTOPTS} ${unittest})
    endforeach(unittest)
endif(BUILD_TESTING)


if(HAVE_CONFIGURE_PACKAGE_CONFIG_FILE AND HAVE_WRITE_BASIC_PACKAGE_VERSION_FILE)

# Configure 'PythonConfig.cmake' for a build tree
set(CONFIG_DIR_CONFIG ${CONFIG_BUILD_DIR})
set(INCLUDE_DIR_CONFIG ${INCLUDE_BUILD_DIR})
set(PYTHON_CONFIG_CODE "####### Expanded from \@PYTHON_CONFIG_CODE\@ #######\n")
set(PYTHON_CONFIG_CODE "${PYTHON_CONFIG_CODE}list(APPEND PYTHON_INCLUDE_DIR \"${PYCONFIG_BUILD_DIR}\")\n")
set(PYTHON_CONFIG_CODE "${PYTHON_CONFIG_CODE}##################################################")
set(python_config ${CONFIG_BUILD_DIR}/PythonConfig.cmake)
configure_package_config_file(
    cmake/PythonConfig.cmake.in
    ${python_config}
    INSTALL_DESTINATION ${CMAKE_BINARY_DIR}
    PATH_VARS CONFIG_DIR_CONFIG INCLUDE_DIR_CONFIG
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

# Configure 'PythonConfig.cmake' for an install tree
set(CONFIG_DIR_CONFIG ${CONFIG_INSTALL_DIR})
set(INCLUDE_DIR_CONFIG ${INCLUDE_INSTALL_DIR})
set(PYTHON_CONFIG_CODE "")
set(python_install_config ${CMAKE_BINARY_DIR}/CMakeFiles/PythonConfig.cmake)
configure_package_config_file(
    cmake/PythonConfig.cmake.in
    ${python_install_config}
    INSTALL_DESTINATION ${CMAKE_INSTALL_PREFIX}/${CONFIG_INSTALL_DIR}
    PATH_VARS CONFIG_DIR_CONFIG INCLUDE_DIR_CONFIG
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

# Configure 'PythonTargets.cmake' and 'PythonConfigVersion.cmake
get_property(PYTHON_TARGETS GLOBAL PROPERTY PYTHON_TARGETS)
export(TARGETS ${PYTHON_TARGETS} APPEND FILE ${CONFIG_BUILD_DIR}/PythonTargets.cmake)

set(python_config_version ${CONFIG_BUILD_DIR}/PythonConfigVersion.cmake)
write_basic_package_version_file(
    ${python_config_version}
    VERSION ${PY_VERSION}
    COMPATIBILITY SameMajorVersion
)

# Install 'PythonTargets.cmake', 'PythonConfig.cmake' and 'PythonConfigVersion.cmake
install(EXPORT PythonTargets FILE PythonTargets.cmake DESTINATION ${CONFIG_INSTALL_DIR})

install(
    FILES ${python_install_config} ${python_config_version}
    DESTINATION ${CONFIG_INSTALL_DIR} COMPONENT Development
)

endif(HAVE_CONFIGURE_PACKAGE_CONFIG_FILE AND HAVE_WRITE_BASIC_PACKAGE_VERSION_FILE)
