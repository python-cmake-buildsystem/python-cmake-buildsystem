# Client maintainer: jchris.fillionr@kitware.com

# Sanity checks
foreach(name IN ITEMS
  CONFIGURATION
  GENERATOR
  PLATFORM
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

set(CTEST_SITE "github-actions-window")
set(CTEST_DASHBOARD_ROOT $ENV{GITHUB_WORKSPACE})
set(CTEST_SOURCE_DIRECTORY $ENV{GITHUB_WORKSPACE}/src)

set(CTEST_CONFIGURATION_TYPE $ENV{CONFIGURATION})
set(CTEST_CMAKE_GENERATOR "$ENV{GENERATOR}")
set(CTEST_CMAKE_GENERATOR_PLATFORM $ENV{PLATFORM})

set(CTEST_BUILD_FLAGS "/m")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 8)

# Build name
# Build name
string(SUBSTRING $ENV{GITHUB_SHA} 0 7 commit)
set(what "#$ENV{GITHUB_HEAD_REF}")
if("$ENV{GITHUB_HEAD_REF}" STREQUAL "")
  set(what "$ENV{GITHUB_REF_NAME}")
endif()
set(CTEST_BUILD_NAME "${PY_VERSION}-${CTEST_CMAKE_GENERATOR_PLATFORM}-${CTEST_CONFIGURATION_TYPE}_${what}_${commit}")

set(dashboard_binary_name build)
set(dashboard_model Experimental)
set(dashboard_track GitHub-Actions)

set(dashboard_cache "BUILD_LIBPYTHON_SHARED:BOOL=ON
PYTHON_VERSION:STRING=${PY_VERSION}
")

# Include driver script
include(${CTEST_SCRIPT_DIRECTORY}/python_common.cmake)

