# Client maintainer: jchris.fillionr@kitware.com

# Sanity checks
foreach(name IN ITEMS
  PY_VERSION
  RUNNER_OS
  RUNNER_ARCH
  CC
  CXX
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

set(CTEST_SITE "$ENV{RUNNER_OS}-$ENV{RUNNER_ARCH}")
set(CTEST_DASHBOARD_ROOT $ENV{GITHUB_WORKSPACE})
set(CTEST_SOURCE_DIRECTORY $ENV{GITHUB_WORKSPACE}/src)

set(CTEST_CMAKE_GENERATOR "Unix Makefiles")

set(CTEST_BUILD_FLAGS "-j4")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 8)

# Build name
string(SUBSTRING $ENV{GITHUB_SHA} 0 7 commit)
set(what "#$ENV{GITHUB_HEAD_REF}")
if("$ENV{GITHUB_HEAD_REF}" STREQUAL "")
  set(what "$ENV{GITHUB_REF_NAME}")
endif()
set(CTEST_BUILD_NAME "${PY_VERSION}_x64-${what}_${commit}")

set(dashboard_binary_name build)
set(dashboard_model Experimental)
set(dashboard_track GitHub-Actions)

# Reading initial dashboard cache
set(_dashboard_cache_path "${CTEST_SCRIPT_DIRECTORY}/initial-dashboard-cache.txt")
set(_msg "Looking for ${_dashboard_cache_path}")
message(STATUS "${_msg}")
if(EXISTS "${_dashboard_cache_path}")
  message(STATUS "${_msg} - found")
  file(READ "${_dashboard_cache_path}" dashboard_cache)
else()
  message(STATUS "${_msg} - not found")
  set(dashboard_cache "")
endif()

set(dashboard_cache "${dashboard_cache}
BUILD_LIBPYTHON_SHARED:BOOL=ON
PYTHON_VERSION:STRING=${PY_VERSION}
")

# Include driver script
include(${CTEST_SCRIPT_DIRECTORY}/python_common.cmake)

