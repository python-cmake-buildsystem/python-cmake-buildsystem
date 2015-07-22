# For building the bdist_wininst subdir

include_directories(
  ${SRC_DIR}/Include
  ${SRC_DIR}/Modules/zlib
)

set(WININST_HEADERS
  ${SRC_DIR}/PC/bdist_wininst/archive.h
  ${SRC_DIR}/PC/bdist_wininst/resource.h
)

set(WININST_SOURCES
  ${SRC_DIR}/PC/bdist_wininst/extract.c
  ${SRC_DIR}/PC/bdist_wininst/install.c
  ${SRC_DIR}/Modules/zlib/adler32.c
  ${SRC_DIR}/Modules/zlib/crc32.c
  ${SRC_DIR}/Modules/zlib/inffast.c
  ${SRC_DIR}/Modules/zlib/inflate.c
  ${SRC_DIR}/Modules/zlib/inftrees.c
  ${SRC_DIR}/Modules/zlib/zutil.c
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

add_executable(${WININST_EXE_NAME} WIN32 ${WININST_SOURCES})
target_link_libraries(${WININST_EXE_NAME}
  ${ZLIB_LIBRARIES}
  imagehlp comctl32
)

install(TARGETS ${WININST_EXE_NAME} DESTINATION lib/distutils/command)

