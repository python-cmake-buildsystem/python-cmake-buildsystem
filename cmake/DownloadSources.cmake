
#
# If needed, this module will download Python sources and set variable SRC_DIR.
#

# Sanity checks
foreach(varname DOWNLOAD_SOURCES _landmark PY_VERSION_MAJOR PY_VERSION_MINOR PY_VERSION_PATCH)
  if(NOT DEFINED ${varname})
    message(FATAL_ERROR "Variable '${varname}' is not defined.")
  endif()
endforeach()

get_filename_component(_parent_dir ${CMAKE_CURRENT_BINARY_DIR} PATH)
string(REGEX REPLACE "rc[1-9]$" "" _py_version_patch_no_rc ${PY_VERSION_PATCH})
set(_py_version_no_rc "${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}.${_py_version_patch_no_rc}")
set(_download_link "http://www.python.org/ftp/python/${_py_version_no_rc}/Python-${PY_VERSION}.tgz")
# Variable below represent the set of supported python version.
set(_download_2.7.3_md5 "2cf641732ac23b18d139be077bd906cd")
set(_download_2.7.4_md5 "592603cfaf4490a980e93ecb92bde44a")
set(_download_2.7.5_md5 "b4f01a1d0ba0b46b05c73b2ac909b1df")
set(_download_2.7.6_md5 "1d8728eb0dfcac72a0fd99c17ec7f386")
set(_download_2.7.7_md5 "cf842800b67841d64e7fb3cd8acb5663")
set(_download_2.7.8_md5 "d4bca0159acb0b44a781292b5231936f")
set(_download_2.7.9_md5 "5eebcaa0030dc4061156d3429657fb83")
set(_download_2.7.10_md5 "d7547558fd673bd9d38e2108c6b42521")
set(_download_2.7.11_md5 "6b6076ec9e93f05dd63e47eb9c15728b")
set(_download_3.5.1_md5 "be78e48cdfc1a7ad90efff146dce6cfe")
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
