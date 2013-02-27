cmake_minimum_required(VERSION 2.8.6)

set(PY_MAJOR_VERSION 2)
set(PY_MINOR_VERSION 7)
set(PY_PATCH_VERSION 3)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES Release CACHE STRING "Release configuration" FORCE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Release")
endif()

project(Python${PY_MAJOR_VERSION}${PY_MINOR_VERSION})

# This is the major version number of Python
set(LIBPYTHON_VERSION ${PY_MAJOR_VERSION}.${PY_MINOR_VERSION})
set(LIBPYTHON python${LIBPYTHON_VERSION})
if(MSVC)
    set(LIBPYTHON python${PY_MAJOR_VERSION}${PY_MINOR_VERSION})
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

# Proceed to the configure checks
include(cmake/ConfigureChecks.cmake)

if(NOT ENABLE_SHARED AND NOT ENABLE_STATIC)
    message(FATAL_ERROR "One or both of ENABLE_SHARED or ENABLE_STATIC must be set")
endif(NOT ENABLE_SHARED AND NOT ENABLE_STATIC)

set(BINDIR "bin")
set(ARCHIVEDIR "libs")

if(USE_LIB64)
    set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS ON)
    set(LIBDIR "lib64")
else(USE_LIB64)
    set(LIBDIR "lib")
endif(USE_LIB64)

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

# Set include directories
include_directories(${CMAKE_SOURCE_DIR})
include_directories(${CMAKE_SOURCE_DIR}/cmake)
include_directories(${CMAKE_SOURCE_DIR}/Include)
include_directories(${CMAKE_SOURCE_DIR}/Python)

if(UNIX)
    configure_file(${CMAKE_SOURCE_DIR}/cmake/config-unix/pyconfig.h.in
                   ${CMAKE_BINARY_DIR}/${BINDIR}/pyconfig.h)
    include_directories(${CMAKE_BINARY_DIR}/${BINDIR})
elseif(WIN32)
    include_directories(${CMAKE_SOURCE_DIR}/PC)
endif(UNIX)

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

if(WIN32)
    set(DYNLOAD "pyd")
else(WIN32)
    set(DYNLOAD "${LIBDIR}/${LIBPYTHON}/lib-dynload")
endif(WIN32)

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
                   ${CMAKE_BINARY_DIR}/${BINDIR}/Makefile)
    install(FILES ${CMAKE_BINARY_DIR}/${BINDIR}/Makefile
            DESTINATION ${PYTHONHOME}/config/
            RENAME Makefile)
endif(UNIX)
if(UNIX)
    install(FILES ${CMAKE_BINARY_DIR}/${BINDIR}/pyconfig.h
            DESTINATION include/${LIBPYTHON}/)
elseif(WIN32)
    install(FILES PC/pyconfig.h
            DESTINATION include/${LIBPYTHON}/)
endif(UNIX)
