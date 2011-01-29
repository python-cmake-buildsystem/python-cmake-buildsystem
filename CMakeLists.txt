cmake_minimum_required(VERSION 2.6)

# This is the major version number of Python
set(LIBPYTHON_VERSION 2.7)
set(LIBPYTHON python${LIBPYTHON_VERSION})

cmake_policy(SET CMP0011 NEW)

# Include helper functions
include(cmake/Assembler.cmake)
include(cmake/ParseArguments.cmake)
include(cmake/Extensions.cmake)

# Find any dependencies
find_package(BZip2)
find_package(Curses)
find_package(EXPAT)
find_package(OpenSSL)
find_package(TCL)
find_package(Threads)
find_package(ZLIB)

find_path(DB_INCLUDE_PATH db.h)
find_library(DB_LIBRARY NAMES db-4.8)

find_path(GDBM_INCLUDE_PATH gdbm-ndbm.h)
find_library(GDBM_LIBRARY gdbm)
find_library(GDBM_COMPAT_LIBRARY gdbm_compat)

find_path(READLINE_INCLUDE_PATH readline/readline.h)
find_library(READLINE_LIBRARY readline)

find_path(SQLITE3_INCLUDE_PATH sqlite3.h)
find_library(SQLITE3_LIBRARY sqlite3)

# Options
option(ENABLE_SHARED "Build a shared libpython library" OFF)
option(ENABLE_STATIC "Build a static libpython library" ON)

if (NOT ENABLE_SHARED AND NOT ENABLE_STATIC)
    message(FATAL_ERROR "One or both of ENABLE_SHARED or ENABLE_STATIC must be set")
endif (NOT ENABLE_SHARED AND NOT ENABLE_STATIC)

include_directories(${CMAKE_SOURCE_DIR})
include_directories(${CMAKE_SOURCE_DIR}/cmake)
include_directories(${CMAKE_SOURCE_DIR}/Include)
include_directories(${CMAKE_SOURCE_DIR}/Python)

if(UNIX)
    include_directories(${CMAKE_SOURCE_DIR}/cmake/config-unix)
elseif(WIN32)
    include_directories(${CMAKE_SOURCE_DIR}/PC)
endif(UNIX)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-strict-aliasing -fwrapv -Wall -Wstrict-prototypes")

if(NOT WIN32)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
endif(NOT WIN32)

# Install some configuration information
configure_file(cmake/makefile-variables.in
               ${CMAKE_BINARY_DIR}/makefile-variables)
install(FILES ${CMAKE_BINARY_DIR}/makefile-variables
        DESTINATION lib/${LIBPYTHON}/config/
        RENAME Makefile)
install(FILES cmake/pyconfig.h
        DESTINATION include/${LIBPYTHON}/)

# Useful additional variables that extensions can use.
if(UNIX AND NOT APPLE)
    set(LINUX ON)
else(UNIX AND NOT APPLE)
    set(LINUX OFF)
endif(UNIX AND NOT APPLE)

# Add extension modules
set(builtin_extensions "" CACHE INTERNAL "" FORCE)
set(builtin_source "" CACHE INTERNAL "" FORCE)
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
