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

# Install tree directory
set(WININST_INSTALL_DIR ${PYTHONHOME}/distutils/command)

# Build tree directory
set(WININST_BUILD_DIR ${CMAKE_BINARY_DIR}/${WININST_INSTALL_DIR})

# Compiler version
set(version "unknown")
foreach(msvcmajver IN ITEMS 90 10 11 12 14)
    if(${MSVC${msvcmajver}})
        string(REGEX REPLACE "0$" "" msvcmajver ${msvcmajver})
        set(version "${msvcmajver}.0")
    endif()
endforeach()

# System architecture
set(arch "")
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(arch "-amd64")
endif()

# Set installer executable name
set(WININST_EXE_NAME "wininst-${version}${arch}")
message(STATUS "bdist_wininst: Generated 'Windows Installer' name is '${WININST_EXE_NAME}'")

# Check if windows installer is already bundled in the source tree
set(_have_wininst_in_source 0)
set(_msg "bdist_wininst: Looking for executable named '${WININST_EXE_NAME}${CMAKE_EXECUTABLE_SUFFIX}' in source tree")
message(STATUS "${_msg}")
set(_expected_wininst ${SRC_DIR}/${WININST_INSTALL_DIR}/${WININST_EXE_NAME}${CMAKE_EXECUTABLE_SUFFIX})
if(EXISTS ${_expected_wininst})
  set(_have_wininst_in_source 1)
  message(STATUS "${_msg} - found \"${_expected_wininst}\"")
else()
  message(STATUS "${_msg} - not found")
endif()

# Skip if installer is already bundled in the source tree and BUILD_WININST_ALWAYS is OFF
set(_configure_reason "")
if(_have_wininst_in_source)
    if(NOT BUILD_WININST_ALWAYS)
        message(STATUS "bdist_wininst: Skipping installer configuration because it is already provided in the source tree.")
        return()
    else()
        set(_configure_reason " because BUILD_WININST_ALWAYS is ON")
    endif()
endif()

message(STATUS "bdist_wininst: Configuring 'Windows Installer' named '${WININST_EXE_NAME}'${_configure_reason}")

# Configure installer
add_executable(bdist_wininst WIN32 ${WININST_HEADERS} ${WININST_SOURCES})
target_link_libraries(bdist_wininst
    imagehlp
    comctl32
)
set_target_properties(bdist_wininst PROPERTIES
    OUTPUT_NAME ${WININST_EXE_NAME}
    RUNTIME_OUTPUT_DIRECTORY ${WININST_BUILD_DIR}
)
if(CMAKE_CONFIGURATION_TYPES)
    add_custom_command(TARGET bdist_wininst POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:bdist_wininst>
            ${WININST_BUILD_DIR}/${WININST_EXE_NAME}${CMAKE_EXECUTABLE_SUFFIX}
        COMMENT "bdist_wininst: Copying installer into '${WININST_INSTALL_DIR}'"
        )
endif()

install(TARGETS bdist_wininst DESTINATION ${WININST_INSTALL_DIR})
