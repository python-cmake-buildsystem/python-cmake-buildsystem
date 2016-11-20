# Client maintainer: jchris.fillionr@kitware.com
if("$ENV{DEFAULT_DOCKCROSS_IMAGE}" STREQUAL "")
  message(FATAL_ERROR "Environment variable 'DEFAULT_DOCKCROSS_IMAGE' is not set")
endif()
set(CTEST_SITE "$ENV{DEFAULT_DOCKCROSS_IMAGE}")
set(CTEST_DASHBOARD_ROOT /work)
set(CTEST_SOURCE_DIRECTORY /work)
string(SUBSTRING $ENV{CIRCLE_SHA1} 0 7 commit)

# Extract major/minor/patch python versions
if("$ENV{PY_VERSION}" STREQUAL "")
  message(FATAL_ERROR "Environment variable 'PY_VERSION' is not set")
endif()
set(PY_VERSION $ENV{PY_VERSION})
string(REGEX MATCH "([0-9])\\.([0-9]+)\\.([0-9]+)" _match ${PY_VERSION})
if(_match STREQUAL "")
  message(FATAL_ERROR "Environment variable 'PY_VERSION' is improperly set.")
endif()

set(what "#$ENV{CIRCLE_PR_NUMBER}")
if("$ENV{CIRCLE_PR_NUMBER}" STREQUAL "")
  set(what "$ENV{CIRCLE_BRANCH}")
endif()
set(CTEST_BUILD_NAME "${PY_VERSION}-$ENV{CROSS_TRIPLE}_${what}_${commit}")
set(CTEST_CONFIGURATION_TYPE Release)
set(CTEST_CMAKE_GENERATOR "Ninja")
set(CTEST_BUILD_FLAGS "-j4")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 8)

set(dashboard_binary_name build)
set(dashboard_model Experimental)
set(dashboard_track Circle-CI)

set(dashboard_cache "PYTHON_VERSION:STRING=${PY_VERSION}
")

# Toolchain
if(EXISTS $ENV{CMAKE_TOOLCHAIN_FILE})
  set(dashboard_cache "${dashboard_cache}
CMAKE_TOOLCHAIN_FILE:FILEPATH=$ENV{CMAKE_TOOLCHAIN_FILE}
")
endif()

# Include driver script
include(${CTEST_SCRIPT_DIRECTORY}/python_common.cmake)

# Upload link to travis
#set(travis_url "/tmp/travis.url")
#file(WRITE ${travis_url} "https://travis-ci.org/$ENV{TRAVIS_REPO_SLUG}/builds/$ENV{TRAVIS_BUILD_ID}")
#ctest_upload(FILES ${travis_url})
#ctest_submit(PARTS Upload)
#file(REMOVE ${travis_url})
