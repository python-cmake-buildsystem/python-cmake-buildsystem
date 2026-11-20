# Driver script of the Linux jobs of the GitHub Actions workflow.
#
# The jobs run in a dockcross container (https://github.com/dockcross/dockcross),
# which defines DEFAULT_DOCKCROSS_IMAGE, CROSS_TRIPLE and CMAKE_TOOLCHAIN_FILE.
#
# Python is configured as by "circle_dashboard.cmake" of the "dashboard" branch.
# "python_common.cmake" of that branch is expected to be checked out in
# "<workspace>/scripts" and this repository in "<workspace>/src".

# Sanity checks
foreach(name IN ITEMS
  DEFAULT_DOCKCROSS_IMAGE
  GITHUB_SHA
  GITHUB_WORKSPACE
  PY_VERSION
  )
  if("$ENV{${name}}" STREQUAL "")
    message(FATAL_ERROR "Environment variable '${name}' is not set")
  endif()
endforeach()

# Extract major/minor/patch python versions
set(PY_VERSION $ENV{PY_VERSION})
string(REGEX MATCH "([0-9])\\.([0-9]+)\\.([0-9]+)" _match ${PY_VERSION})
if(_match STREQUAL "")
  message(FATAL_ERROR "Environment variable 'PY_VERSION' is improperly set.")
endif()

file(TO_CMAKE_PATH "$ENV{GITHUB_WORKSPACE}" _workspace)

set(CTEST_SITE "$ENV{DEFAULT_DOCKCROSS_IMAGE}")
set(CTEST_DASHBOARD_ROOT ${_workspace})
set(CTEST_SOURCE_DIRECTORY ${_workspace}/src)

set(CTEST_CONFIGURATION_TYPE Release)
set(CTEST_CMAKE_GENERATOR "Ninja")

set(CTEST_BUILD_FLAGS "-j4")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 8)

# Build name
string(SUBSTRING $ENV{GITHUB_SHA} 0 7 commit)
set(what "#$ENV{GITHUB_HEAD_REF}")
if("$ENV{GITHUB_HEAD_REF}" STREQUAL "")
  set(what "$ENV{GITHUB_REF_NAME}")
endif()
set(CTEST_BUILD_NAME "${PY_VERSION}-$ENV{CROSS_TRIPLE}_${what}_${commit}")

set(dashboard_binary_name build)
set(dashboard_model Experimental)
set(dashboard_track GitHub-Actions)

set(dashboard_cache "PYTHON_VERSION:STRING=${PY_VERSION}
")

# Toolchain
if(EXISTS "$ENV{CMAKE_TOOLCHAIN_FILE}")
  set(dashboard_cache "${dashboard_cache}
CMAKE_TOOLCHAIN_FILE:FILEPATH=$ENV{CMAKE_TOOLCHAIN_FILE}
")
endif()

# Include driver script
include(${_workspace}/scripts/python_common.cmake)
