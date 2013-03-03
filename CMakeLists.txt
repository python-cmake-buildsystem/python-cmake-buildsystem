cmake_minimum_required(VERSION 2.8.6)

set(PY_VERSION_MAJOR 2)
set(PY_VERSION_MINOR 7)
set(PY_VERSION_PATCH 3)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES Release CACHE STRING "Release configuration" FORCE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Release")
endif()

project(Python${PY_VERSION_MAJOR}${PY_VERSION_MINOR} C)

# This is the major version number of Python
set(LIBPYTHON_VERSION ${PY_VERSION_MAJOR}.${PY_VERSION_MINOR})
set(LIBPYTHON python${LIBPYTHON_VERSION})
if(MSVC)
    set(LIBPYTHON python${PY_VERSION_MAJOR}${PY_VERSION_MINOR})
endif(MSVC)

# Include helper functions
include(cmake/Assembler.cmake)
include(cmake/Extensions.cmake)
include(CMakeParseArguments)

# Options
option(ENABLE_SHARED "Build a shared libpython library" OFF)
option(ENABLE_STATIC "Build a static libpython library" ON)
option(USE_LIB64 "Search for dependencies and install to prefix/lib64 instead of prefix/lib" OFF)
option(USE_LIBEDIT "Use libedit instead of readline" OFF)
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
        cpython-${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}.${PY_VERSION_PATCH}
        Python-${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}.${PY_VERSION_PATCH}
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
set(_download_link "http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tgz")
set(_extracted_dir "Python-2.7.3")
if(WIN32)
    set(_download_link "https://github.com/jonashaag/cpython/archive/v2.7.3.zip")
    set(_extracted_dir "cpython-2.7.3")
endif(WIN32)
if(NOT EXISTS ${SRC_DIR}/${_landmark})
    message(FATAL_ERROR "Failed to locate python source.
The searched locations were:
   <CMAKE_CURRENT_BINARY_DIR>
   <CMAKE_CURRENT_BINARY_DIR>/../cpython-${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}.${PY_VERSION_PATCH}
   <CMAKE_CURRENT_BINARY_DIR>/../Python-${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}.${PY_VERSION_PATCH}
   <SRC_DIR>
You could try to:
  1) download ${_download_link}
  2) extract the archive in folder: ${_parent_dir}
  3) Check that file \"${_parent_dir}/${_extracted_dir}/${_landmark}\" exists.
  4) re-configure.
If you already downloaded the source, you could try to re-configure this project passing -DSRC_DIR:PATH=/path/to/Python-2.7.3 using cmake or adding an PATH entry named SRC_DIR from cmake-gui.")
endif()
message(STATUS "SRC_DIR: ${SRC_DIR}")


# Proceed to the configure checks
include(cmake/ConfigureChecks.cmake)

if(NOT ENABLE_SHARED AND NOT ENABLE_STATIC)
    message(FATAL_ERROR "One or both of ENABLE_SHARED or ENABLE_STATIC must be set")
endif(NOT ENABLE_SHARED AND NOT ENABLE_STATIC)

# Install tree directory
set(BIN_INSTALL_DIR bin)                         # Contains the python executable
set(CONFIG_INSTALL_DIR share/${LIBPYTHON})
set(INCLUDE_INSTALL_DIR include/${LIBPYTHON})
# Build tree directory
set(BIN_BUILD_DIR ${CMAKE_BINARY_DIR}/bin)
set(CONFIG_BUILD_DIR ${CMAKE_BINARY_DIR}/${CONFIG_INSTALL_DIR})
set(INCLUDE_BUILD_DIR ${SRC_DIR}/Include)

set(ARCHIVEDIR "libs")      # Contains the static (*.a) and import libraries (*.lib)

# Library directory used to compose PYTHONHOME
if(USE_LIB64)
    set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS ON)
    set(LIBDIR "lib64")
else(USE_LIB64)
    set(LIBDIR "lib")
endif(USE_LIB64)

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

# Find any dependencies
find_package(BZip2)
find_package(Curses)
find_package(EXPAT)
find_package(OpenSSL)
find_package(TCL)
find_package(ZLIB)

find_path(DB_INCLUDE_PATH db.h)
find_library(DB_LIBRARY NAMES db-4.8)

find_path(GDBM_INCLUDE_PATH gdbm-ndbm.h)
find_library(GDBM_LIBRARY gdbm)
find_library(GDBM_COMPAT_LIBRARY gdbm_compat)

if(USE_LIBEDIT)
    find_path(READLINE_INCLUDE_PATH editline/readline.h)
    find_library(READLINE_LIBRARY edit)
else()
    find_path(READLINE_INCLUDE_PATH readline/readline.h)
    find_library(READLINE_LIBRARY readline)
endif()

find_path(SQLITE3_INCLUDE_PATH sqlite3.h)
find_library(SQLITE3_LIBRARY sqlite3)

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
        DESTINATION include/${LIBPYTHON}/)

# Set include directories
include_directories(cmake)
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

set(PYTHONHOME "${LIBDIR}/${LIBPYTHON}")
set(DYNLOAD "${PYTHONHOME}/lib-dynload")

# Clear PythonTargets.cmake
file(WRITE ${CONFIG_BUILD_DIR}/PythonTargets.cmake "")

# Add extension modules
set(builtin_extensions "" CACHE INTERNAL "" FORCE)
set(builtin_source "" CACHE INTERNAL "" FORCE)
set(builtin_link_libraries "" CACHE INTERNAL "" FORCE)
set(builtin_includedirs "" CACHE INTERNAL "" FORCE)
set(builtin_definitions "" CACHE INTERNAL "" FORCE)
set(extensions_enabled "" CACHE INTERNAL "" FORCE)
set(extensions_disabled "" CACHE INTERNAL "" FORCE)
add_subdirectory(cmake/extensions)

# Add the other subdirectories
add_subdirectory(cmake/pgen)
add_subdirectory(cmake/libpython)
add_subdirectory(cmake/python)
add_subdirectory(cmake/include)
add_subdirectory(cmake/lib)

show_extension_summary()

if(UNIX)
    # Install some configuration information
    configure_file(cmake/makefile-variables.in
                   ${BIN_BUILD_DIR}/Makefile)
    install(FILES ${BIN_BUILD_DIR}/Makefile
            DESTINATION ${PYTHONHOME}/config/
            RENAME Makefile)
endif(UNIX)

get_property(PYTHON_TARGETS GLOBAL PROPERTY PYTHON_TARGETS)
export(TARGETS ${PYTHON_TARGETS} APPEND FILE ${CONFIG_BUILD_DIR}/PythonTargets.cmake)

install(EXPORT PythonTargets FILE PythonTargets.cmake DESTINATION ${CONFIG_INSTALL_DIR})
