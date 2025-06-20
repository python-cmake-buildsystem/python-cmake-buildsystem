cmake_minimum_required(VERSION 3.20.6)

set(PYTHON_VERSION "3.12.10" CACHE STRING "The version of Python to build.")

string(REPLACE "." ";" VERSION_LIST ${PYTHON_VERSION})
list(GET VERSION_LIST 0 PY_VERSION_MAJOR)
list(GET VERSION_LIST 1 PY_VERSION_MINOR)
list(GET VERSION_LIST 2 PY_VERSION_PATCH)
set(PY_VERSION "${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}.${PY_VERSION_PATCH}")

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES Release CACHE STRING "Release configuration" FORCE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Release")
endif()

if(APPLE)
  set(_msg "Checking which MACOSX_DEPLOYMENT_TARGET to use")
  message(STATUS "${_msg}")
  include(cmake/PythonAutoDetectOSX.cmake)
  set(MACOSX_DEPLOYMENT_TARGET ${CMAKE_OSX_DEPLOYMENT_TARGET})
  message(STATUS "${_msg} - ${MACOSX_DEPLOYMENT_TARGET}")
endif()

project(Python C ASM)

if(NOT DEFINED CMAKE_MACOSX_RPATH)
  set(CMAKE_MACOSX_RPATH "")
endif()
if(NOT DEFINED CMAKE_BUILD_WITH_INSTALL_NAME_DIR)
  set(CMAKE_BUILD_WITH_INSTALL_NAME_DIR ON)
endif()

# Include helper functions
include(cmake/Extensions.cmake)
include(CMakeDependentOption)
include(CMakeParseArguments)
include(CTest)

# Options
option(DOWNLOAD_SOURCES "Automatically download the Python sources" ON)
set(_build_libpython_shared_default  0)
set(_build_libpython_shared_desc "Build libpython as a shared library")

if(DEFINED BUILD_SHARED OR DEFINED BUILD_STATIC)
  message(AUTHOR_WARNING "Deprecated options `BUILD_SHARED` or `BUILD_STATIC` are set, "
                         "please change configure options to use `BUILD_LIBPYTHON_SHARED` instead.")
  if(BUILD_SHARED AND BUILD_STATIC)
    message(AUTHOR_WARNING "Both BUILD_SHARED and BUILD_STATIC options are set to ON. Forcing BUILD_SHARED to OFF")
  endif()
  if(BUILD_STATIC)
    set(_build_libpython_shared_default  0)
    set(_build_libpython_shared_desc "Intialized from `BUILD_STATIC` (deprecated)")
  elseif(BUILD_SHARED)
    set(_build_libpython_shared_default  1)
    set(_build_libpython_shared_desc "Intialized from `BUILD_SHARED` (deprecated)")
  endif()
  message(AUTHOR_WARNING "Unsetting cache variables BUILD_SHARED and BUILD_STATIC")
  unset(BUILD_SHARED CACHE)
  unset(BUILD_STATIC CACHE)
endif()

option(BUILD_LIBPYTHON_SHARED ${_build_libpython_shared_desc} ${_build_libpython_shared_default})
option(BUILD_EXTENSIONS_AS_BUILTIN "Default all modules as builtin to libpython" OFF)
option(USE_LIB64 "Search for dependencies and install to prefix/lib64 instead of prefix/lib" OFF)
if(WIN32)
  option(INSTALL_WINDOWS_TRADITIONAL "Install the executable and extensions in the traditional location" OFF)
else()
  set(INSTALL_WINDOWS_TRADITIONAL OFF)
endif()

if(WIN32 AND PY_VERSION VERSION_GREATER_EQUAL "3.10")
  if(DEFINED BUILD_WININST)
    message(AUTHOR_WARNING "BUILD_WININST option is *NOT* supported with Python >= 3.10. Current version is ${PY_VERSION}")
    message(AUTHOR_WARNING "Unsetting cache variable BUILD_WININST")
    unset(BUILD_WININST CACHE)
  endif()
  if(DEFINED BUILD_WININST_ALWAYS)
    message(AUTHOR_WARNING "BUILD_WININST_ALWAYS option is *NOT* supported with Python >= 3.10. Current version is ${PY_VERSION}")
    message(AUTHOR_WARNING "Unsetting cache variable BUILD_WININST_ALWAYS")
    unset(BUILD_WININST_ALWAYS CACHE)
  endif()
endif()

if(WIN32 AND PY_VERSION VERSION_LESS "3.10")
  set(_build_wininst_default ON)
  if(CMAKE_CROSSCOMPILING)
    set(_build_wininst_default OFF)
  endif()
  option(BUILD_WININST "Build 'Windows Installer' program for distutils if not already provided in the source tree." ${_build_wininst_default})
  cmake_dependent_option(BUILD_WININST_ALWAYS "Always build 'Windows installer' program even if provided in the source tree." OFF "BUILD_WININST" OFF)
else()
  set(BUILD_WININST OFF)
  set(BUILD_WININST_ALWAYS OFF)
endif()

option(INSTALL_DEVELOPMENT "Install files required to develop C extensions" ON)
option(INSTALL_MANUAL "Install man files" ON)
option(INSTALL_TEST "Install test files" ON)

# Append an item to a string if it does not already contain it.  Any additional
# arguments are treated as extra "set" arguments
macro(append_if_absent VARNAME VALUE)
    if(NOT ${VARNAME} MATCHES "(^| )${VALUE}($| )")
        if(${VARNAME})
            set(${VARNAME} "${${VARNAME}} ${VALUE}" ${ARGN})
        else()
            set(${VARNAME} "${VALUE}" ${ARGN})
        endif()
    endif()
endmacro()

option(USE_SYSTEM_LIBRARIES "Use system libraries" ON)

# Set platform dependent defaults
set(_use_builtin_zlib_default OFF)
set(_use_system_zlib_default ON)
if(WIN32 AND "${PY_VERSION}" VERSION_LESS "3.7.0")
  set(_use_builtin_zlib_default ON)
  set(_use_system_zlib_default OFF)
endif()

cmake_dependent_option(USE_SYSTEM_BZip2 "Use system BZip2" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_Curses "Use system Curses" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_EXPAT "Use system EXPAT" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_LibFFI "Use system LibFFI" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_OpenSSL "Use system OpenSSL" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_TCL "Use system TCL" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_ZLIB "Use system ZLIB" ${_use_system_zlib_default} "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_GDBM "Use system GDBM" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_READLINE "Use system READLINE" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_SQLite3 "Use system SQLITE3" ON "USE_SYSTEM_LIBRARIES" OFF)
cmake_dependent_option(USE_SYSTEM_LIBMPDEC "Use system LIBMPDEC" OFF "USE_SYSTEM_LIBRARIES" OFF)

cmake_dependent_option(USE_BUILTIN_ZLIB "Use builtin ZLIB" ${_use_builtin_zlib_default} "NOT USE_SYSTEM_ZLIB" OFF)

option(USE_LIBEDIT "Use libedit instead of readline" OFF)

option(WITH_TSC "profile with the Pentium timestamp counter" OFF)
option(ENABLE_IPV6 "Enable IP v6" ON)
option(WITH_DOC_STRINGS "Enable if you want documentation strings in extension modules" ON)
set(Py_DEBUG OFF) # TODO - Build debugging interpreter
option(WITH_PYMALLOC "Define if you want to compile in Python-specific mallocs" ON)
if(UNIX)
    option(WITH_STATIC_DEPENDENCIES "Restrict extensions and external dependencies to static libraries" OFF)
    if(WITH_STATIC_DEPENDENCIES)
            set(_reason " because of WITH_STATIC_DEPENDENCIES=ON")

            set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_STATIC_LIBRARY_SUFFIX})
            message(STATUS "Setting CMAKE_FIND_LIBRARY_SUFFIXES to \"${CMAKE_STATIC_LIBRARY_SUFFIX}\"${_reason}")

            set(BUILD_EXTENSIONS_AS_BUILTIN ON CACHE BOOL "Forced to ON${_reason}" FORCE)
            message(STATUS "Setting BUILD_EXTENSIONS_AS_BUILTIN to ON${_reason}")

            set(BUILD_LIBPYTHON_SHARED OFF CACHE BOOL "Forced to OFF${_reason}" FORCE)
            message(STATUS "Setting BUILD_LIBPYTHON_SHARED to OFF${_reason}")

            append_if_absent(CMAKE_EXE_LINKER_FLAGS "-static")
            message(STATUS "Appending -static to CMAKE_EXE_LINKER_FLAGS${_reason}")
    endif()
else()
    set(WITH_STATIC_DEPENDENCIES 0)
endif()

# Detect source directory
set(_landmark "pyconfig.h.in") # CMake will look for this file.
if(NOT (SRC_DIR AND EXISTS ${SRC_DIR}/${_landmark}))
    foreach(dirname
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/cpython-${PY_VERSION}
        ${CMAKE_CURRENT_SOURCE_DIR}/Python-${PY_VERSION}
        ${CMAKE_CURRENT_BINARY_DIR}/../cpython-${PY_VERSION}
        ${CMAKE_CURRENT_BINARY_DIR}/../Python-${PY_VERSION})
        set(SRC_DIR ${dirname})
        if(EXISTS ${SRC_DIR}/${_landmark})
            break()
        endif()
    endforeach()
endif()

# Download sources
get_filename_component(_parent_dir ${CMAKE_CURRENT_BINARY_DIR} PATH)
string(REGEX REPLACE "[a-z]+[1-9]$" "" _py_version_patch_no_rc ${PY_VERSION_PATCH})
set(_py_version_no_rc "${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}.${_py_version_patch_no_rc}")
set(_download_link "https://www.python.org/ftp/python/${_py_version_no_rc}/Python-${PY_VERSION}.tgz")
# Variable below represent the set of available python version.
# 3.5.x
set(_download_3.5.1_md5 "be78e48cdfc1a7ad90efff146dce6cfe")
set(_download_3.5.2_md5 "3fe8434643a78630c61c6464fe2e7e72")
set(_download_3.5.3_md5 "6192f0e45f02575590760e68c621a488")
set(_download_3.5.4_md5 "2ed4802b7a2a7e40d2e797272bf388ec")
set(_download_3.5.5_md5 "7c825b747d25c11e669e99b912398585")
set(_download_3.5.6_md5 "99a7e803633a627b264a42ce976d8c19")
set(_download_3.5.7_md5 "92f4c16c55429bf986f5ab45fe3a6659")
set(_download_3.5.8_md5 "c52ac1fc37e5daebb08069ea0e27d293")
set(_download_3.5.9_md5 "5a58675043bde569d235f41dadeada42")
set(_download_3.5.10_md5 "01a2d18075243bef5ef3363f62bf3247")
# 3.6.x
set(_download_3.6.0_md5 "3f7062ccf8be76491884d0e47ac8b251")
set(_download_3.6.1_md5 "2d0fc9f3a5940707590e07f03ecb08b9")
set(_download_3.6.2_md5 "e1a36bfffdd1d3a780b1825daf16e56c")
set(_download_3.6.3_md5 "e9180c69ed9a878a4a8a3ab221e32fa9")
set(_download_3.6.4_md5 "9de6494314ea199e3633211696735f65")
set(_download_3.6.5_md5 "ab25d24b1f8cc4990ade979f6dc37883")
set(_download_3.6.6_md5 "9a080a86e1a8d85e45eee4b1cd0a18a2")
set(_download_3.6.7_md5 "c83551d83bf015134b4b2249213f3f85")
set(_download_3.6.8_md5 "48f393a04c2e66c77bfc114e589ec630")
set(_download_3.6.9_md5 "ff7cdaef4846c89c1ec0d7b709bbd54d")
set(_download_3.6.10_md5 "df5f494ef9fbb03a0264d1e9d406aada")
set(_download_3.6.11_md5 "74763db01ec961ff194eea9ccc001a80")
set(_download_3.6.12_md5 "00c3346f314072fcc810d4a51d06f04e")
set(_download_3.6.13_md5 "92fcbf417c691d42c47a3d82f9c255fd")
set(_download_3.6.14_md5 "54a320cffe046bbbe4321896d67bde2b")
set(_download_3.6.15_md5 "f9e6f91c754a604f4fc6f6c7683723fb")
# 3.7.x
set(_download_3.7.0_md5 "41b6595deb4147a1ed517a7d9a580271")
set(_download_3.7.1_md5 "99f78ecbfc766ea449c4d9e7eda19e83")
set(_download_3.7.2_md5 "02a75015f7cd845e27b85192bb0ca4cb")
set(_download_3.7.3_md5 "2ee10f25e3d1b14215d56c3882486fcf")
set(_download_3.7.4_md5 "68111671e5b2db4aef7b9ab01bf0f9be")
set(_download_3.7.5_md5 "1cd071f78ff6d9c7524c95303a3057aa")
set(_download_3.7.6_md5 "3ef90f064506dd85b4b4ab87a7a83d44")
set(_download_3.7.7_md5 "d348d978a5387512fbc7d7d52dd3a5ef")
set(_download_3.7.8_md5 "4d5b16e8c15be38eb0f4b8f04eb68cd0")
set(_download_3.7.9_md5 "bcd9f22cf531efc6f06ca6b9b2919bd4")
set(_download_3.7.10_md5 "0b19e34a6dabc4bf15fdcdf9e77e9856")
set(_download_3.7.11_md5 "a7e66953dba909d395755b3f2e491f6e")
set(_download_3.7.12_md5 "6fe83678c085a7735a943cf1e4d41c14")
set(_download_3.7.13_md5 "e0d3321026d4a5f3a3890b5d821ad762")
set(_download_3.7.14_md5 "dd65d6708e9c28a9e4fd2e986776ad14")
set(_download_3.7.15_md5 "beff0cd66129ad1761632aafd72ac866")
set(_download_3.7.16_md5 "f21656b51c9907fc6993b64ef216d994")
set(_download_3.7.17_md5 "19726591b0fb1a9658de68955fa8392a")
# 3.8.x
set(_download_3.8.0_md5 "e18a9d1a0a6d858b9787e03fc6fdaa20")
set(_download_3.8.1_md5 "f215fa2f55a78de739c1787ec56b2bcd")
set(_download_3.8.2_md5 "f9f3768f757e34b342dbc06b41cbc844")
set(_download_3.8.3_md5 "a7c10a2ac9d62de75a0ca5204e2e7d07")
set(_download_3.8.4_md5 "387e63fe42c40a29e3408ce231315516")
set(_download_3.8.5_md5 "e2f52bcf531c8cc94732c0b6ff933ff0")
set(_download_3.8.6_md5 "ea132d6f449766623eee886966c7d41f")
set(_download_3.8.7_md5 "e1f40f4fc9ccc781fcbf8d4e86c46660")
set(_download_3.8.8_md5 "d3af3b87e134c01c7f054205703adda2")
set(_download_3.8.9_md5 "41a5eaa15818cee7ea59e578564a2629")
set(_download_3.8.10_md5 "83d71c304acab6c678e86e239b42fa7e")
set(_download_3.8.11_md5 "f22ef46ebf8d15d8e495a237277bf2fa")
set(_download_3.8.12_md5 "f7890dd43302daa5fcb7b0254b4d0f33")
set(_download_3.8.13_md5 "3c49180c6b43df3519849b7e390af0b9")
set(_download_3.8.14_md5 "a82168eb586e19122b747b84038825f2")
set(_download_3.8.15_md5 "28b111e1e97a9e5acb62e1d153f188d9")
set(_download_3.8.16_md5 "060040f864f1003b849b33393c9605df")
set(_download_3.8.17_md5 "d3e789ab828016927a122a0ae9b0e6b0")
set(_download_3.8.18_md5 "1c611d70ba4d0ec32da3a364490fc6f4")
set(_download_3.8.19_md5 "5e3188ce73865fa4545d9e3e89bcd26c")
set(_download_3.8.20_md5 "7e0ff9088be5a3c2fd9b7d8b4b632b5e")
# 3.9.x
set(_download_3.9.0_md5 "e19e75ec81dd04de27797bf3f9d918fd")
set(_download_3.9.1_md5 "429ae95d24227f8fa1560684fad6fca7")
set(_download_3.9.2_md5 "8cf053206beeca72c7ee531817dc24c7")
# 3.9.3: This release has been recalled. See https://www.python.org/downloads/release/python-393/
set(_download_3.9.4_md5 "cc8507b3799ed4d8baa7534cd8d5b35f")
set(_download_3.9.5_md5 "364158b3113cf8ac8db7868ce40ebc7b")
set(_download_3.9.6_md5 "798b9d3e866e1906f6e32203c4c560fa")
set(_download_3.9.7_md5 "5f463f30b1fdcb545f156583630318b3")
set(_download_3.9.8_md5 "83419bd73655813223c2cf2afb11f83c")
set(_download_3.9.9_md5 "a2da2a456c078db131734ff62de10ed5")
set(_download_3.9.10_md5 "1440acb71471e2394befdb30b1a958d1")
set(_download_3.9.11_md5 "daca49063ced330eb933a0fb437dee50")
set(_download_3.9.12_md5 "abc7f7f83ea8614800b73c45cf3262d3")
set(_download_3.9.13_md5 "eafda83543bad127cadef4d288fdab87")
set(_download_3.9.14_md5 "324a9dcaaa11b2b0dafe5614e8f01145")
set(_download_3.9.15_md5 "3e13283a5f4e089db508bf81b60a5cca")
set(_download_3.9.16_md5 "38c99c7313f416dcf3238f5cf444c6c2")
set(_download_3.9.17_md5 "ded6379983f364cf790793ca24dcfe3e")
set(_download_3.9.18_md5 "c3a3e67e35838cadca247237a5a279a7")
set(_download_3.9.19_md5 "b4d723903d0a8266b110c3da2f992416")
set(_download_3.9.20_md5 "896c19e5815ba990a3d1261502ea9f83")
set(_download_3.9.21_md5 "e61b3568082b57d55fd74cfc7ca020b4")
set(_download_3.9.22_md5 "8fe76e248a0e149ac23e8e4886397475")
# 3.10.x
set(_download_3.10.0_md5 "729e36388ae9a832b01cf9138921b383")
set(_download_3.10.1_md5 "91822157a97da16203877400c810d93e")
set(_download_3.10.2_md5 "67c92270be6701f4a6fed57c4530139b")
set(_download_3.10.3_md5 "f276ffcd05bccafe46da023d0a5bb04a")
set(_download_3.10.4_md5 "7011fa5e61dc467ac9a98c3d62cfe2be")
set(_download_3.10.5_md5 "d87193c077541e22f892ff1353fac76c")
set(_download_3.10.6_md5 "d76638ca8bf57e44ef0841d2cde557a0")
set(_download_3.10.7_md5 "1aea68575c0e97bc83ff8225977b0d46")
set(_download_3.10.8_md5 "fbe3fff11893916ad1756b15c8a48834")
set(_download_3.10.9_md5 "25eb3686327c157dcb8ac9f01105c306")
set(_download_3.10.10_md5 "6dbe644dd1a520d9853cf6648084c346")
set(_download_3.10.11_md5 "7e25e2f158b1259e271a45a249cb24bb")
set(_download_3.10.12_md5 "1d64320e0b0df6e9ab7e611bacb2178d")
set(_download_3.10.13_md5 "cbcad7f5e759176bf8ce8a5f9d487087")
set(_download_3.10.14_md5 "f67d78c8323a18fe6b945914c51a7aa6")
set(_download_3.10.15_md5 "b6a2b570ea75ef55f50bfe79d778eb01")
set(_download_3.10.16_md5 "2515d8571c6fdd7fc620aa9e1cc6d202")
set(_download_3.10.17_md5 "763324aa2b396ee10a51bfa6c645d8e9")
# 3.11.x
set(_download_3.11.0_md5 "c5f77f1ea256dc5bdb0897eeb4d35bb0")
set(_download_3.11.1_md5 "5c986b2865979b393aa50a31c65b64e8")
set(_download_3.11.2_md5 "f6b5226ccba5ae1ca9376aaba0b0f673")
set(_download_3.11.3_md5 "016ba65bc80411f9ec20c614ab385e81")
set(_download_3.11.4_md5 "bf6ec50f2f3bfa6ffbdb385286f2c628")
set(_download_3.11.5_md5 "b628f21aae5e2c3006a12380905bb640")
set(_download_3.11.6_md5 "ed23dadb9f1b9fd2e4e7d78619685c79")
set(_download_3.11.7_md5 "ef61f81ec82c490484219c7f0ec96783")
set(_download_3.11.8_md5 "7fb0bfaa2f6aae4aadcdb51abe957825")
set(_download_3.11.9_md5 "bfd4d3bfeac4216ce35d7a503bf02d5c")
set(_download_3.11.10_md5 "35c36069a43dd57a7e9915deba0f864e")
set(_download_3.11.11_md5 "9a5b43fcc06810b8ae924b0a080e6569")
set(_download_3.11.12_md5 "b8bb496014f05f5be180fab74810f40b")
# 3.12.x
set(_download_3.12.0_md5 "d6eda3e1399cef5dfde7c4f319b0596c")
set(_download_3.12.1_md5 "51c5c22dcbc698483734dff5c8028606")
set(_download_3.12.2_md5 "4e64a004f8ad9af1a75607cfd0d5a8c8")
set(_download_3.12.3_md5 "3c5498a34d5226c9b746b1199f0bf2d9")
set(_download_3.12.4_md5 "ead819dab6d165937138daa9e51ccb54")
set(_download_3.12.5_md5 "d23d56b51d36a9d51b2b13d30c849d00")
set(_download_3.12.6_md5 "c2f1dd5c8807ee50b778684b7958ee28")
set(_download_3.12.7_md5 "5d0c0e4c6a022a87165a9addcd869109")
set(_download_3.12.8_md5 "304473cf367fa65e450edf4b06b55fcc")
set(_download_3.12.9_md5 "ce613c72fa9b32fb4f109762d61b249b")
set(_download_3.12.10_md5 "35c03f014408e26e2b06d576c19cac54")

set(_extracted_dir "Python-${PY_VERSION}")

if(NOT EXISTS ${SRC_DIR}/${_landmark} AND DOWNLOAD_SOURCES)
    get_filename_component(_filename ${_download_link} NAME)
    set(_archive_filepath ${CMAKE_CURRENT_BINARY_DIR}/../${_filename})
    if(EXISTS "${_archive_filepath}")
        message(STATUS "${_filename} already downloaded")
    else()
        message(STATUS "Downloading ${_download_link}")
        if(NOT DEFINED _download_${PY_VERSION}_md5)
            message(FATAL_ERROR "Selected PY_VERSION [${PY_VERSION}] is not associated with any checksum. Consider updating this CMakeLists.txt setting _download_${PY_VERSION}_md5 variable")
        endif()
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

get_filename_component(SRC_DIR "${SRC_DIR}" ABSOLUTE)
if(NOT EXISTS ${SRC_DIR}/${_landmark})
    message(FATAL_ERROR "Failed to locate python source.
The searched locations were:
   <CMAKE_CURRENT_SOURCE_DIR>
   <CMAKE_CURRENT_SOURCE_DIR>/cpython-${PY_VERSION}
   <CMAKE_CURRENT_SOURCE_DIR>/Python-${PY_VERSION}
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

# Extract version string from python source (Copied from FindPythonLibs.cmake)
file(STRINGS "${SRC_DIR}/Include/patchlevel.h" python_version_str
    REGEX "^#define[ \t]+PY_VERSION[ \t]+\"[^\"]+\"")
string(REGEX REPLACE "^#define[ \t]+PY_VERSION[ \t]+\"([^\"]+)\".*" "\\1"
      PY_VERSION_LONG "${python_version_str}")

# Extract version info and set variables PY_VERSION, PY_VERSION_(MAJOR|MINOR|PATCH), PY_RELEASE_(LEVEL|SERIAL)
include(cmake/PythonExtractVersionInfo.cmake)
python_extract_version_info(
  VERSION_STRING "${PY_VERSION_LONG}"
  )
message(STATUS "PY_VERSION     : ${PY_VERSION}")
message(STATUS "PY_VERSION_LONG: ${PY_VERSION_LONG}")

# Extract "Field3" value and set variable PY_FIELD3_VALUE
python_compute_release_field3_value(
    VERSION_PATCH "${PY_VERSION_PATCH}"
    RELEASE_LEVEL "${PY_RELEASE_LEVEL}"
    RELEASE_SERIAL "${PY_RELEASE_SERIAL}"
)
message(STATUS "PY_FIELD3_VALUE: ${PY_FIELD3_VALUE}")

# Check version
if(NOT DEFINED _download_${PY_VERSION_LONG}_md5)
    message(WARNING "warning: selected python version '${PY_VERSION_LONG}' is not tested.")
endif()
if(NOT "${PYTHON_VERSION}" STREQUAL "${PY_VERSION}")
  message(STATUS "Overwriting PYTHON_VERSION with value read from 'patchlevel.h': ${PYTHON_VERSION} -> ${PY_VERSION}")
  set(PYTHON_VERSION "${PY_VERSION}" CACHE STRING "The version of Python to build." FORCE)
endif()

# Apply patches
option(PYTHON_APPLY_PATCHES "Apply patches" ON)
if(PYTHON_APPLY_PATCHES)
  include(cmake/PythonApplyPatches.cmake)
endif()

# Enable CXX language to support building of _distutils_findvs extension
if(WIN32)
  enable_language(CXX)
endif()

# Options depending of the python version
  if(DEFINED USE_SYSTEM_DB)
    message(AUTHOR_WARNING "USE_SYSTEM_DB option is *NOT* supported with Python 3. Current version is ${PY_VERSION}")
  endif()

  if(DEFINED Py_USING_UNICODE)
    message(AUTHOR_WARNING "Py_USING_UNICODE option is *NOT* supported with Python 3. Current version is ${PY_VERSION}")
  endif()

if(PY_VERSION VERSION_GREATER_EQUAL "3.7")
    option(WITH_C_LOCALE_COERCION "Enable C locale coercion to a UTF-8 based locale" ON)
else()
    if(DEFINED WITH_C_LOCALE_COERCION)
        message(AUTHOR_WARNING "WITH_C_LOCALE_COERCION option is *NOT* supported with Python < 3.7. Current version is ${PY_VERSION}")
    endif()
endif()

# See "Improving performance in Python 2.7" - http://lwn.net/Articles/646888/
option(WITH_COMPUTED_GOTOS "Improve performance enabling the computed goto based dispatch" OFF)
set(USE_COMPUTED_GOTOS ${WITH_COMPUTED_GOTOS})

set(WITH_HASH_ALGORITHM "default" CACHE STRING "Define hash algorithm for str, bytes and memoryview.")
set_property(CACHE WITH_HASH_ALGORITHM PROPERTY STRINGS "default" "siphash24" "fnv")

if(PY_VERSION VERSION_LESS "3.7")
    option(WITH_THREAD "Compile in rudimentary thread support" ON)
else()
    if(DEFINED WITH_THREAD)
        message(AUTHOR_WARNING "WITH_THREAD option is *NOT* supported. Threading is always built-in with Python >= 3.7. Current version is ${PY_VERSION}")
    endif()
endif()

if(PY_VERSION VERSION_GREATER_EQUAL "3.10")
    option(WITH_VALGRIND "Enable to disable pymalloc when running under valgrind" OFF)
else()
    if(DEFINED WITH_VALGRIND)
        message(AUTHOR_WARNING "WITH_VALGRIND option is *NOT* supported with Python < 3.10. Current version is ${PY_VERSION}")
    endif()
endif()

if(PY_VERSION VERSION_GREATER_EQUAL "3.7")
set(WITH_SSL_DEFAULT_SUITES "python" CACHE STRING "Override default cipher suites string: python, openssl or a custom string")
if("${WITH_SSL_DEFAULT_SUITES}" STREQUAL "python")
    set(PY_SSL_DEFAULT_CIPHERS 1)
elseif("${WITH_SSL_DEFAULT_SUITES}" STREQUAL "openssl")
    set(PY_SSL_DEFAULT_CIPHERS 2)
else()
    set(PY_SSL_DEFAULT_CIPHERS 0)
    set(PY_SSL_DEFAULT_CIPHER_STRING "${WITH_SSL_DEFAULT_SUITES}")
endif()
message(STATUS "Setting PY_SSL_DEFAULT_CIPHER_STRING to '${WITH_SSL_DEFAULT_SUITES}'")
endif()

if(PY_VERSION VERSION_GREATER_EQUAL "3.8")
    option(WITH_DECIMAL_CONTEXTVAR "Build _decimal module using a coroutine-local rather than a thread-local context" ON)
else()
    if(DEFINED WITH_DECIMAL_CONTEXTVAR)
        message(AUTHOR_WARNING "WITH_DECIMAL_CONTEXTVAR option is *NOT* supported with Python < 3.8. Current version is ${PY_VERSION}")
    endif()
endif()

if(PY_VERSION VERSION_GREATER_EQUAL "3.8")
    option(WITH_TRACE_REFS "Enable tracing references for debugging purpose" OFF)
else()
    if(DEFINED WITH_TRACE_REFS)
        message(AUTHOR_WARNING "WITH_TRACE_REFS option is *NOT* supported with Python < 3.8. Current version is ${PY_VERSION}")
    endif()
endif()

# This is the major version number of Python
set(LIBPYTHON_VERSION ${PY_VERSION_MAJOR}.${PY_VERSION_MINOR})
if(WIN32)
    set(LIBPYTHON_VERSION ${PY_VERSION_MAJOR}${PY_VERSION_MINOR})
endif()
set(LIBPYTHON python${LIBPYTHON_VERSION})

# Proceed to the configure checks
include(cmake/ConfigureChecks.cmake)

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
set(LD_VERSION ${LIBPYTHON_VERSION}${ABIFLAGS})
set(CONFIG_INSTALL_DIR share/${LIBPYTHON})
set(EXTENSION_INSTALL_DIR ${PYTHONHOME}/lib-dynload)

if (${LIBPYTHON_VERSION} GREATER 3.1)
  set(LIB_CONFIG_INSTALL_DIR ${PYTHONHOME}/config-${LD_VERSION})
else()
  set(LIB_CONFIG_INSTALL_DIR ${PYTHONHOME}/config)
endif()

if(INSTALL_WINDOWS_TRADITIONAL)
    set(EXTENSION_INSTALL_DIR DLLs)
endif()
set(INCLUDE_INSTALL_DIR include/python${LD_VERSION})
if(MSVC)
    set(INCLUDE_INSTALL_DIR include)
endif()
# Build tree directory
set(BIN_BUILD_DIR ${PROJECT_BINARY_DIR}/bin)
set(CONFIG_BUILD_DIR ${PROJECT_BINARY_DIR}/${CONFIG_INSTALL_DIR})
set(EXTENSION_BUILD_DIR ${PROJECT_BINARY_DIR}/${PYTHONHOME}/lib-dynload)
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
    if(MINGW)
      set(PYCONFIG_BUILD_DIR cmake/config-mingw)
    endif()
endif()

# Install 'pyconfig.h'
if(INSTALL_DEVELOPMENT)
    install(FILES ${PYCONFIG_BUILD_DIR}/pyconfig.h
            DESTINATION ${INCLUDE_INSTALL_DIR}/
            COMPONENT Development)
endif()

# Set include directories
include_directories(${INCLUDE_BUILD_DIR})
include_directories(${INCLUDE_BUILD_DIR}/internal)
include_directories(${PYCONFIG_BUILD_DIR})
include_directories(${SRC_DIR}/Python)
include_directories(${SRC_DIR}) # Introduced in Python 3.11 for "Python/frozen_modules/.h"

# Set cflags used by all components
if(CMAKE_C_COMPILER_ID MATCHES GNU)
    if(PY_VERSION VERSION_GREATER_EQUAL "3.11")
        append_if_absent(CMAKE_C_FLAGS "-std=c11")
    elseif(PY_VERSION VERSION_GREATER_EQUAL "3.6")
        append_if_absent(CMAKE_C_FLAGS "-std=c99")
    endif()
    append_if_absent(CMAKE_C_FLAGS "-Wall")
    append_if_absent(CMAKE_C_FLAGS "-Wstrict-prototypes")
    append_if_absent(CMAKE_C_FLAGS "-fno-strict-aliasing")
    append_if_absent(CMAKE_C_FLAGS "-fwrapv")
    append_if_absent(CMAKE_C_FLAGS "-g")
elseif(CMAKE_C_COMPILER_ID MATCHES Clang)
    append_if_absent(CMAKE_C_FLAGS "-Wall")
    append_if_absent(CMAKE_C_FLAGS "-g")
elseif(CMAKE_C_COMPILER_ID MATCHES Intel)
    append_if_absent(CMAKE_C_FLAGS "-Wall")
    append_if_absent(CMAKE_C_FLAGS "-no-ansi-alias")
elseif(CMAKE_C_COMPILER_ID MATCHES PGI)
    append_if_absent(CMAKE_C_FLAGS "-alias=traditional")
endif()

if(MSVC)
    append_if_absent(CMAKE_C_FLAGS "/Zm200")
    string(REPLACE "/Ob2" "/Ob1" CMAKE_C_FLAGS_RELEASE ${CMAKE_C_FLAGS_RELEASE}) # InlineFunctionExpansion=1
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}" CACHE STRING "Flags used by the compiler during release builds" FORCE)
endif()

# Useful additional variables that extensions can use.
if(CMAKE_SYSTEM MATCHES Linux)
    set(LINUX ON)
else()
    set(LINUX OFF)
endif()

# Clear PythonTargets.cmake
file(WRITE ${CONFIG_BUILD_DIR}/PythonTargets.cmake "")

# Define python executable wrapper command to ensure
# python executable resolves the expected python library.
set(PYTHON_WRAPPER_COMMAND )
if(BUILD_LIBPYTHON_SHARED AND UNIX)
    set(_envvar LD_LIBRARY_PATH)
    if(APPLE)
        set(_envvar DYLD_LIBRARY_PATH)
    endif()
    set(PYTHON_WRAPPER_COMMAND env ${_envvar}=${PROJECT_BINARY_DIR}/${LIBPYTHON_LIBDIR})
endif()

# Add extension modules
set(extensions_enabled "" CACHE INTERNAL "" FORCE)
set(extensions_disabled "" CACHE INTERNAL "" FORCE)
add_subdirectory(cmake/extensions CMakeBuild/extensions)

# Add the other subdirectories
add_subdirectory(cmake/libpython CMakeBuild/libpython)
add_subdirectory(cmake/python CMakeBuild/python)
add_subdirectory(cmake/include CMakeBuild/include)
add_subdirectory(cmake/lib CMakeBuild/lib)
add_subdirectory(cmake/tools CMakeBuild/tools)
if(BUILD_WININST)
    add_subdirectory(cmake/PC/bdist_wininst CMakeBuild/bdist_wininst)
endif()
if(WIN32)
    add_subdirectory(cmake/PC/launcher CMakeBuild/launcher)
endif()

# Ensure the "_testcapi" extension introduced in Python 3.12 can find
# find "Python3.lib" as it is specified in "PC/pyconfig." using
# `pragma comment(lib,"python3.lib")`.
if(WIN32 AND TARGET extension_testcapi)
    set(libpython_output_dir "${PROJECT_BINARY_DIR}/CMakeBuild/libpython/$<CONFIG>")
    target_link_directories(extension_testcapi PRIVATE ${libpython_output_dir})
    # Ensure import library is generated before linking the extension
    add_dependencies(extension_testcapi libpython3-shared)
endif()

# Add target to run "Argument Clinic" over all source files
add_custom_target(clinic
    COMMAND python ${SRC_DIR}/Tools/clinic/clinic.py --make
    DEPENDS python
    WORKING_DIRECTORY ${SRC_DIR}
    COMMENT "Running 'Argument Clinic' over all source files"
    VERBATIM
)

# Add target to generate 'Include/graminit.h' and 'Python/graminit.c'
if(PY_VERSION VERSION_GREATER_EQUAL "3.8")
    set(generate_graminit_command python -m Parser.pgen)
else()
    set(generate_graminit_command pgen)
endif()
add_custom_target(generate_graminit
    COMMAND ${generate_graminit_command}
        ${SRC_DIR}/Grammar/Grammar
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>:${SRC_DIR}/Grammar/Tokens>
        ${PROJECT_BINARY_DIR}/CMakeFiles/graminit.h
        ${PROJECT_BINARY_DIR}/CMakeFiles/graminit.c
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${PROJECT_BINARY_DIR}/CMakeFiles/graminit.h
        ${SRC_DIR}/Include/graminit.h
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${PROJECT_BINARY_DIR}/CMakeFiles/graminit.c
        ${SRC_DIR}/Python/graminit.c
    DEPENDS $<IF:$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>,python,pgen>
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "Generating '${SRC_DIR}/Include/graminit.h' and '${SRC_DIR}/Python/graminit.c'."
    VERBATIM
)

if(PY_VERSION VERSION_GREATER_EQUAL "3.9")
# Add target to generate `Tools/peg_generator/pegen/grammar_parser.py`
add_custom_target(generate_pegen_metaparser
    COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=${SRC_DIR}/Tools/peg_generator
        ${CMAKE_CROSSCOMPILING_EMULATOR} $<TARGET_FILE:python> -m pegen
            -q python
            ${SRC_DIR}/Tools/peg_generator/pegen/metagrammar.gram
            -o ${PROJECT_BINARY_DIR}/CMakeFiles/grammar_parser.py
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${PROJECT_BINARY_DIR}/CMakeFiles/grammar_parser.py
        ${SRC_DIR}/Tools/peg_generator/pegen/grammar_parser.py
    DEPENDS python
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "Generating '${SRC_DIR}/Tools/peg_generator/pegen/grammar_parser.py'"
    VERBATIM
)

# Add target to generate `Parser/pegen/parse.c`
add_custom_target(generate_pegen_parse
    COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=${SRC_DIR}/Tools/peg_generator
        ${CMAKE_CROSSCOMPILING_EMULATOR} $<TARGET_FILE:python> -m pegen
            -q c
            ${SRC_DIR}/Grammar/python.gram
            ${SRC_DIR}/Grammar/Tokens
            -o ${PROJECT_BINARY_DIR}/CMakeFiles/parse.c
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${PROJECT_BINARY_DIR}/CMakeFiles/parse.c
        ${SRC_DIR}/Parser/pegen/parse.c
    DEPENDS python
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "Generating '${SRC_DIR}/Parser/pegen/parse.c'"
    VERBATIM
)
endif()

# Add target to generate 'opcode.h' header file
add_custom_target(generate_opcode_h
    COMMAND python ${SRC_DIR}/Tools/scripts/generate_opcode_h.py
        ${SRC_DIR}/Lib/opcode.py
        ${PROJECT_BINARY_DIR}/CMakeFiles/opcode.h
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${PROJECT_BINARY_DIR}/CMakeFiles/opcode.h
        ${SRC_DIR}/Include/opcode.h
    DEPENDS python
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "Generating '${SRC_DIR}/Include/opcode.h'."
    VERBATIM
)

# Add target to generate 'Include/Python-ast.h' from 'Python.asdl'
add_custom_target(generate_python_ast_h
    COMMAND python ${SRC_DIR}/Parser/asdl_c.py
        -h ${SRC_DIR}/Include
        ${SRC_DIR}/Parser/Python.asdl
    DEPENDS python
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "Generating '${SRC_DIR}/Include/Python-ast.h'"
    VERBATIM
)

# Add target to generate 'Python/Python-ast.c' from 'Python.asdl'
add_custom_target(generate_python_ast_c
    COMMAND python ${SRC_DIR}/Parser/asdl_c.py
        -c ${SRC_DIR}/Python
        ${SRC_DIR}/Parser/Python.asdl
    DEPENDS python
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "Generating '${SRC_DIR}/Python/Python-ast.c'"
    VERBATIM
)

# If needed, copy 'asdl.py' and 'Python.asdl' into build directory so that 'test_asdl_parser' passes.
set(_asdl_subdir ${LIBDIR})
if(WIN32)
  set(_asdl_subdir )
endif()
file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/${LIBDIR}/Parser)
configure_file(
    ${SRC_DIR}/Parser/Python.asdl
    ${PROJECT_BINARY_DIR}/${_asdl_subdir}/Parser/Python.asdl
    COPYONLY
)
configure_file(
    ${SRC_DIR}/Parser/asdl.py
    ${PROJECT_BINARY_DIR}/${_asdl_subdir}/Parser/asdl.py
    COPYONLY
)

show_extension_summary()

if(UNIX)

    # python.pc
    configure_file(cmake/python.pc.in
                  ${PROJECT_BINARY_DIR}/Misc/python-${LIBPYTHON_VERSION}.pc @ONLY)
    configure_file(cmake/python.pc.in
                  ${PROJECT_BINARY_DIR}/Misc/python-${PY_VERSION_MAJOR}.pc @ONLY)
    configure_file(cmake/python.pc.in
                  ${PROJECT_BINARY_DIR}/Misc/python.pc @ONLY)
    if(INSTALL_DEVELOPMENT)
        install(FILES
                    ${PROJECT_BINARY_DIR}/Misc/python-${LIBPYTHON_VERSION}.pc
                    ${PROJECT_BINARY_DIR}/Misc/python-${PY_VERSION_MAJOR}.pc
                    ${PROJECT_BINARY_DIR}/Misc/python.pc
                DESTINATION lib/pkgconfig
                COMPONENT Development)
    endif()

    # Makefile
    set(MAKEFILE_LDSHARED_FLAGS "-shared")
    if(APPLE)
        set(MAKEFILE_LDSHARED_FLAGS "-dynamiclib -headerpad_max_install_names -undefined dynamic_lookup")
    endif()
    configure_file(cmake/makefile-variables.in
                   ${BIN_BUILD_DIR}/Makefile @ONLY)
    if(INSTALL_DEVELOPMENT)
        install(FILES ${BIN_BUILD_DIR}/Makefile
                DESTINATION ${LIB_CONFIG_INSTALL_DIR}
                RENAME Makefile
                COMPONENT Development)
    endif()

    # Utility scripts
    if(INSTALL_DEVELOPMENT)
        install(FILES ${SRC_DIR}/install-sh ${SRC_DIR}/Modules/makesetup
                DESTINATION ${LIB_CONFIG_INSTALL_DIR}
                COMPONENT Development)
    endif()

    # Install manual
    if(INSTALL_MANUAL)
        set(_install_man FILES ${SRC_DIR}/Misc/python.man DESTINATION share/man/man1 COMPONENT Runtime)
        install(${_install_man} RENAME python${LIBPYTHON_VERSION}.1)
        install(${_install_man} RENAME python${PY_VERSION_MAJOR}.1)
    endif()

endif()

# Create an empty lib-dynload folder, even if we don't have any extensions
# to go in there.  bin/python uses this to auto-determine the exec_prefix
# and properly generate the _sysconfigdata.py
file(MAKE_DIRECTORY "${EXTENSION_BUILD_DIR}")
install(DIRECTORY DESTINATION ${EXTENSION_INSTALL_DIR})

if(BUILD_TESTING)
    set(SUPPORTED_TEST_RESOURCES network)
    message(STATUS "Supported test resources: ${SUPPORTED_TEST_RESOURCES}")

    list(JOIN SUPPORTED_TEST_RESOURCES "," regrtest_resources)

    set(TESTOPTS
      # Command line option "-l/--findleaks" of regrtest is deprecated since Python 3.7 and
      # removed in Python 3.11. It is superseded by --fail-env-changed.
      $<IF:$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>,--fail-env-changed,-l>
      # Comma-separated list of words indicating the resources to test
      -u ${regrtest_resources}
    )
    set(TESTPROG ${PROJECT_BINARY_DIR}/${PYTHONHOME}/test/regrtest.py)
    set(TESTPYTHONOPTS )
      set(TESTPYTHON $<TARGET_FILE:python> ${TESTPYTHONOPTS})
    set(TESTPYTHON ${CMAKE_CROSSCOMPILING_EMULATOR} ${TESTPYTHON})
    include(cmake/UnitTests.cmake)
    foreach(unittest ${unittests})
      set(EXTRATESTOPTS -v)
      # XXX Running 'test_doctest' in verbose mode always return 1
      if(unittest STREQUAL "test_doctest")
        set(EXTRATESTOPTS )
      endif()
      add_test(NAME ${unittest} COMMAND ${PYTHON_WRAPPER_COMMAND} ${TESTPYTHON} ${TESTPROG} ${TESTOPTS} ${EXTRATESTOPTS} ${unittest})
    endforeach()

    function(add_cmakescript_test testname script)
      add_test(cmake_${testname}_test ${CMAKE_COMMAND}
        -DTEST_${testname}:BOOL=ON
        -P ${PROJECT_SOURCE_DIR}/${script})
      set_tests_properties(cmake_${testname}_test PROPERTIES
        LABELS CMake
        PASS_REGULAR_EXPRESSION "SUCCESS")
    endfunction()
    add_cmakescript_test(
        python_extract_version_info
        cmake/PythonExtractVersionInfo.cmake
        )
    add_cmakescript_test(
        python_compute_release_field3_value
        cmake/PythonExtractVersionInfo.cmake
        )
endif()

include(CMakePackageConfigHelpers)

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
    INSTALL_DESTINATION ${PROJECT_BINARY_DIR}
    PATH_VARS CONFIG_DIR_CONFIG INCLUDE_DIR_CONFIG
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

# Configure 'PythonConfig.cmake' for an install tree
set(CONFIG_DIR_CONFIG ${CONFIG_INSTALL_DIR})
set(INCLUDE_DIR_CONFIG ${INCLUDE_INSTALL_DIR})
set(PYTHON_CONFIG_CODE "")
set(python_install_config ${PROJECT_BINARY_DIR}/CMakeFiles/PythonConfig.cmake)
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

if(INSTALL_DEVELOPMENT)
    # Install 'PythonTargets.cmake', 'PythonConfig.cmake' and 'PythonConfigVersion.cmake
    install(EXPORT PythonTargets
        FILE PythonTargets.cmake
        DESTINATION ${CONFIG_INSTALL_DIR} COMPONENT Development)

    install(
        FILES ${python_install_config} ${python_config_version}
        DESTINATION ${CONFIG_INSTALL_DIR} COMPONENT Development
    )
endif()

# Install License
set(license_destination ${PYTHONHOME})
if(INSTALL_WINDOWS_TRADITIONAL)
  set(license_destination .)
endif()
install(FILES ${SRC_DIR}/LICENSE DESTINATION ${license_destination} COMPONENT Runtime RENAME LICENSE.txt)
