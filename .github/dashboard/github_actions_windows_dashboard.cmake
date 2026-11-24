# Driver script of the Windows jobs of the GitHub Actions workflow.
#
# Python is configured as by "circle_win_dashboard.cmake" of the "dashboard" branch.
# "python_common.cmake" of that branch is expected to be checked out in
# "<workspace>/scripts" and this repository in "<workspace>/src".

# Sanity checks
foreach(name IN ITEMS
  CONFIGURATION
  GENERATOR
  GITHUB_SHA
  GITHUB_WORKSPACE
  PLATFORM
  PY_VERSION
  RUNNER_ARCH
  RUNNER_OS
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

set(CTEST_SITE "$ENV{RUNNER_OS}-$ENV{RUNNER_ARCH}")
set(CTEST_DASHBOARD_ROOT ${_workspace})
set(CTEST_SOURCE_DIRECTORY ${_workspace}/src)

set(CTEST_CONFIGURATION_TYPE $ENV{CONFIGURATION})
set(CTEST_CMAKE_GENERATOR "$ENV{GENERATOR}")
set(CTEST_CMAKE_GENERATOR_PLATFORM $ENV{PLATFORM})

set(CTEST_BUILD_FLAGS "/m")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 8)

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
COPY_OpenSSL_DLLS:BOOL=ON
")
# Use the OpenSSL provided by the workflow (see CI.yml), if any, instead of
# the one installed on the runner
if(NOT "$ENV{OPENSSL_ROOT_DIR}" STREQUAL "")
  file(TO_CMAKE_PATH "$ENV{OPENSSL_ROOT_DIR}" _openssl_root_dir)
  string(APPEND dashboard_cache "OPENSSL_ROOT_DIR:PATH=${_openssl_root_dir}
")
endif()

# Include driver script
include(${_workspace}/scripts/python_common.cmake)
