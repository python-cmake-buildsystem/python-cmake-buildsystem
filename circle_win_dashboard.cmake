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

set(CTEST_SITE "circleci-window")
set(CTEST_DASHBOARD_ROOT $ENV{CIRCLE_WORKING_DIRECTORY}/..)
set(CTEST_SOURCE_DIRECTORY $ENV{CIRCLE_WORKING_DIRECTORY})

set(CTEST_CONFIGURATION_TYPE $ENV{CONFIGURATION})
set(CTEST_CMAKE_GENERATOR "$ENV{GENERATOR}")
set(CTEST_CMAKE_GENERATOR_PLATFORM $ENV{PLATFORM})

set(CTEST_BUILD_FLAGS "/m")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 8)

# Builtin extensions
set(BUILD_EXTENSIONS_AS_BUILTIN OFF)
set(BUILTIN_CTEST_NAME "")
if(DEFINED ENV{BUILD_EXTENSIONS_AS_BUILTIN} AND $ENV{BUILD_EXTENSIONS_AS_BUILTIN})
  set(BUILD_EXTENSIONS_AS_BUILTIN ON)
  set(BUILTIN_CTEST_NAME "-builtin")
endif()

# Build name
string(SUBSTRING $ENV{CIRCLE_SHA1} 0 7 commit)
set(what "#$ENV{CIRCLE_PR_NUMBER}")
if("$ENV{CIRCLE_PR_NUMBER}" STREQUAL "")
  set(what "$ENV{CIRCLE_BRANCH}")
endif()
set(CTEST_BUILD_NAME "${PY_VERSION}-${CTEST_CMAKE_GENERATOR_PLATFORM}-${CTEST_CONFIGURATION_TYPE}${BUILTIN_CTEST_NAME}_${what}_${commit}")

set(dashboard_binary_name build)
set(dashboard_model Experimental)
set(dashboard_track Circle-CI-Windows)

set(dashboard_cache "BUILD_LIBPYTHON_SHARED:BOOL=ON
PYTHON_VERSION:STRING=${PY_VERSION}
BUILD_EXTENSIONS_AS_BUILTIN:BOOL=${BUILD_EXTENSIONS_AS_BUILTIN}
")

# Include driver script
include(${CTEST_SCRIPT_DIRECTORY}/python_common.cmake)

