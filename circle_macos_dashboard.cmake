# Client maintainer: jchris.fillionr@kitware.com

# Sanity checks
foreach(name IN ITEMS
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

set(CTEST_SITE "circleci-macos")
set(CTEST_DASHBOARD_ROOT $ENV{CIRCLE_WORKING_DIRECTORY}/..)
set(CTEST_SOURCE_DIRECTORY $ENV{CIRCLE_WORKING_DIRECTORY})

set(CTEST_CMAKE_GENERATOR "Ninja")

set(CTEST_BUILD_FLAGS "-j4")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 8)

# Build name
string(SUBSTRING $ENV{CIRCLE_SHA1} 0 7 commit)
set(what "#$ENV{CIRCLE_PR_NUMBER}")
if("$ENV{CIRCLE_PR_NUMBER}" STREQUAL "")
  set(what "$ENV{CIRCLE_BRANCH}")
endif()
set(CTEST_BUILD_NAME "${PY_VERSION}_x64-${what}_${commit}")

set(dashboard_binary_name build)
set(dashboard_model Experimental)
set(dashboard_track Circle-CI-macOS)

set(dashboard_cache "BUILD_LIBPYTHON_SHARED:BOOL=ON
PYTHON_VERSION:STRING=${PY_VERSION}
")

# Include driver script
include(${CTEST_SCRIPT_DIRECTORY}/python_common.cmake)

