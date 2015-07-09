# For building the bdist_wininst subdir

set(BDIST_WININST_HEADERS
  ${SRC_DIR}/PC/bdist_wininst/archive.h
  ${SRC_DIR}/PC/bdist_wininst/resource.h
)

set(BDIST_WININST_SOURCES
  ${SRC_DIR}/PC/bdist_wininst/extract.c
  ${SRC_DIR}/PC/bdist_wininst/install.c
)

message(STATUS "CMAKE_C_COMPILER_VERSION = ${CMAKE_C_COMPILER_VERSION}.")
string(REGEX REPLACE "\\..*$" "" msvcmajver "${CMAKE_C_COMPILER_VERSION}")
string(REGEX REPLACE "${msvcmajver}." "" msvcminver "${CMAKE_C_COMPILER_VERSION}")
math(EXPR msvcmajver "${msvcmajver} - 6")
message(STATUS "msvcmajver = ${msvcmajver}.")
string(REGEX REPLACE "\\..*$" "" msvcminver "${msvcminver}")
message(STATUS "msvcminver = ${msvcminver}.")
message(STATUS "CMAKE_SYSTEM_PROCESSOR = ${CMAKE_SYSTEM_PROCESSOR}.")
set(sfx)
if (CMAKE_SYSTEM_PROCESSOR STREQUAL "AMD64")
  set(sfx "-amd64")
endif ()
set(WININST_EXE_NAME wininst-${msvcmajver}.${msvcminver}${sfx})
message(STATUS "WININST_EXE_NAME = ${WININST_EXE_NAME}.")

include_directories(${ZLIB_INCLUDE_DIRS})
add_executable(${WININST_EXE_NAME} ${BDIST_WININST_SOURCES})
target_link_libraries(${WININST_EXE_NAME}
  ${ZLIB_LIBRARIES}
  comctl32
)

