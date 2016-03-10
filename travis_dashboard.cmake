# Client maintainer: jchris.fillionr@kitware.com
execute_process(COMMAND hostname OUTPUT_VARIABLE hostname OUTPUT_STRIP_TRAILING_WHITESPACE)
set(CTEST_SITE "${hostname}")
set(CTEST_DASHBOARD_ROOT $ENV{TRAVIS_BUILD_DIR}/..)
get_filename_component(compiler_name $ENV{CC} NAME)
string(SUBSTRING $ENV{TRAVIS_COMMIT} 0 7 commit)

# Extract major/minor/patch python versions
if("$ENV{PY_VERSION}" STREQUAL "")
  message(FATAL_ERROR "Environment variable 'PY_VERSION' is not set")
endif()
set(PY_VERSION $ENV{PY_VERSION})
string(REGEX MATCH "([0-9])\\.([0-9]+)\\.([0-9]+)" _match ${PY_VERSION})
if(_match STREQUAL "")
  message(FATAL_ERROR "Environment variable 'PY_VERSION' is improperly set.")
endif()
set(PY_VERSION_MAJOR ${CMAKE_MATCH_1})
set(PY_VERSION_MINOR ${CMAKE_MATCH_2})
set(PY_VERSION_PATCH ${CMAKE_MATCH_3})

set(what "#$ENV{TRAVIS_PULL_REQUEST}")
if($ENV{TRAVIS_PULL_REQUEST} STREQUAL "false")
  set(what "$ENV{TRAVIS_BRANCH}")
endif()
set(CTEST_BUILD_NAME "2.7.${PY_VERSION_PATCH}-$ENV{TRAVIS_OS_NAME}-${compiler_name}_${what}_${commit}")
set(CTEST_CONFIGURATION_TYPE Release)
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_FLAGS "-j4")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 8)

set(dashboard_model Experimental)
set(dashboard_track Travis-CI)

set(dashboard_cache "PY_VERSION_MAJOR:STRING=${PY_VERSION_MAJOR}
PY_VERSION_MINOR:STRING=${PY_VERSION_MINOR}
PY_VERSION_PATCH:STRING=${PY_VERSION_PATCH}
")

function(downloadFile url dest)
 file(DOWNLOAD ${url} ${dest} STATUS status)
 list(GET status 0 error_code)
 list(GET status 1 error_msg)
 if(error_code)
   message(FATAL_ERROR "error: Failed to download ${url} - ${error_msg}")
 endif()
endfunction()

# Download and include driver script
set(url https://raw.githubusercontent.com/davidsansome/python-cmake-buildsystem/dashboard/python_common.cmake)
set(dest ${CTEST_SCRIPT_DIRECTORY}/python_common.cmake)
downloadfile(${url} ${dest})
include(${dest})

# Upload link to travis
set(travis_url "/tmp/travis.url")
file(WRITE ${travis_url} "https://travis-ci.org/$ENV{TRAVIS_REPO_SLUG}/builds/$ENV{TRAVIS_BUILD_ID}")
ctest_upload(FILES ${travis_url})
ctest_submit(PARTS Upload)
file(REMOVE ${travis_url})
