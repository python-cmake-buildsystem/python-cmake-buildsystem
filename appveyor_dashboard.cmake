# Client maintainer: jchris.fillionr@kitware.com

# Sanity checks
foreach(name IN ITEMS
  CONFIGURATION
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

set(CTEST_SITE "appveyor")
set(CTEST_DASHBOARD_ROOT $ENV{APPVEYOR_BUILD_FOLDER}/..)

set(CTEST_CONFIGURATION_TYPE $ENV{CONFIGURATION})
set(CTEST_CMAKE_GENERATOR "$ENV{GENERATOR}")
if("${CTEST_CMAKE_GENERATOR}" STREQUAL "")
  set(CTEST_CMAKE_GENERATOR "Visual Studio 9 2008")
endif()
set(platform $ENV{PLATFORM})
if(platform STREQUAL "x64")
  set(CTEST_CMAKE_GENERATOR "${CTEST_CMAKE_GENERATOR} Win64")
elseif(CTEST_CMAKE_GENERATOR MATCHES "Win64")
  set(platform "x64")
endif()

set(CTEST_BUILD_FLAGS "")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 8)

# Build name
string(SUBSTRING $ENV{APPVEYOR_REPO_COMMIT} 0 7 commit)
set(what "$ENV{APPVEYOR_PULL_REQUEST_TITLE}_#$ENV{APPVEYOR_PULL_REQUEST_NUMBER}")
if("$ENV{APPVEYOR_PULL_REQUEST_NUMBER}" STREQUAL "")
  set(what "$ENV{APPVEYOR_REPO_BRANCH}")
endif()
set(CTEST_BUILD_NAME "${PY_VERSION}-VS-${platform}-$ENV{CONFIGURATION}_${what}_${commit}")

set(dashboard_binary_name "python-cmake-buildsystem/build")
set(dashboard_model Experimental)
set(dashboard_track AppVeyor-CI)

set(dashboard_cache "BUILD_LIBPYTHON_SHARED:BOOL=ON
PYTHON_VERSION:STRING=${PY_VERSION}
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
set(url https://raw.githubusercontent.com/python-cmake-buildsystem/python-cmake-buildsystem/dashboard/python_common.cmake)
set(dest ${CTEST_SCRIPT_DIRECTORY}/python_common.cmake)
downloadfile(${url} ${dest})
include(${dest})

# Upload link to CDash
#set(url "${CTEST_DASHBOARD_ROOT}/python-cmake-buildsystem/scratch/appveyor.url")
#file(WRITE ${url} "https://ci.appveyor.com/project/$ENV{APPVEYOR_REPO_NAME}/build/$ENV{APPVEYOR_BUILD_VERSION}")
#ctest_upload(FILES ${url})
#ctest_submit(PARTS Upload)
#file(REMOVE ${url})
