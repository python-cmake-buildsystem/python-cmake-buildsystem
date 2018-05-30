#.rst:
#
# =========================================================================
# SetPythonVersionFrom - inspect the python source and set python variables
# =========================================================================
#
# Inspect the source dir (python) and sets cmake variables
#
# .. code-block:: cmake
#
#     include(cmake/PythonSrcExtractVersion.cmake)
#     set_python_version_from_src(<path-to-patchlevel.h>)
#
# The following variables will be set:
#     
#      #. PY_VERSION_MAJOR 
#      #. PY_VERSION_MINOR 
#      #. PY_VERSION_PATCH 
#      #. PY_VERSION ($PY_VERSION_MAJOR.$PY_VERSION_MINOR.$PY_VERSION_PATCH)
#      #. IS_PY2
#      #. IS_PY3
#

macro(set_python_version_from_txt python_version_str)
    string(REGEX REPLACE "^#define[ \t]+PY_VERSION[ \t]+\"([^\"]+)\".*" "\\1"
        _version "${python_version_str}")
    string(REGEX REPLACE "([0-9])\\..+" "\\1"
        PY_VERSION_MAJOR ${_version})
    string(REGEX REPLACE "[0-9]\\.([0-9]+)\\..+" "\\1"
        PY_VERSION_MINOR ${_version})
    string(REGEX REPLACE "[0-9]\\.[0-9]+\\.([0-9]+)[+]?" "\\1"
        PY_VERSION_PATCH ${_version})
    set(PY_VERSION "${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}.${PY_VERSION_PATCH}")
    set(PYTHON_VERSION "${PY_VERSION}" CACHE STRING "The version of Python to build." FORCE)

    # Convenience boolean variables to easily test python version
    set(IS_PY3 0)
    set(IS_PY2 1)
    if(PY_VERSION_MAJOR VERSION_GREATER 2)
        set(IS_PY3 1)
        set(IS_PY2 0)
    endif()
endmacro()

macro(set_python_version_from_src patchlevel_h)
    # Extract version from python source (Copied from FindPythonLibs.cmake)
    if(EXISTS "${patchlevel_h}")
        file(STRINGS "${patchlevel_h}" python_version_str
            REGEX "^#define[ \t]+PY_VERSION[ \t]+\"[^\"]+\"")
        set_python_version_from_txt("${python_version_str}")
        message(STATUS "Set PY_VERSION: ${PY_VERSION}")
        message(STATUS "Set PY_VERSION_MAJOR: ${PY_VERSION_MAJOR}")
        message(STATUS "Set PY_VERSION_MINOR: ${PY_VERSION_MINOR}")
        message(STATUS "Set PY_VERSION_PATCH: ${PY_VERSION_PATCH}")
        message(STATUS "Set IS_PY2: ${IS_PY2}")
        message(STATUS "Set IS_PY3: ${IS_PY3}")
    else()
        message(FATAL_ERROR "cannot find ${patchlevel_h}")
    endif()
endmacro()
