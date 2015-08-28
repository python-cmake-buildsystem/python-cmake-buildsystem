# Client maintainer: jchris.fillionr@kitware.com
set(CTEST_SITE "appveyor")
set(CTEST_DASHBOARD_ROOT $ENV{APPVEYOR_BUILD_FOLDER}/..)
string(SUBSTRING $ENV{APPVEYOR_REPO_COMMIT} 0 7 commit)
set(PY_VERSION_PATCH 8) # Value should match the default set in CMakeLists.txt
if(NOT "$ENV{PY_VERSION_PATCH}" STREQUAL "")
  set(PY_VERSION_PATCH "$ENV{PY_VERSION_PATCH}")
endif()
set(what "$ENV{APPVEYOR_PULL_REQUEST_TITLE}_#$ENV{APPVEYOR_PULL_REQUEST_NUMBER}")
if($ENV{APPVEYOR_PULL_REQUEST_NUMBER} STREQUAL "")
  set(what "$ENV{APPVEYOR_REPO_BRANCH}")
endif()
set(CTEST_BUILD_NAME "2.7.${PY_VERSION_PATCH}-VS-$ENV{PLATFORM}-$ENV{CONFIGURATION}_${what}_${commit}")
set(CTEST_CONFIGURATION_TYPE $ENV{CONFIGURATION})
set(CTEST_CMAKE_GENERATOR "Visual Studio 9 2008")
if("$ENV{platform}" STREQUAL "x64")
  set(CTEST_CMAKE_GENERATOR "${CTEST_CMAKE_GENERATOR} Win64")
endif()
set(CTEST_BUILD_FLAGS "")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 8)

set(dashboard_binary_name "python-cmake-buildsystem/build")
set(dashboard_model Experimental)
set(dashboard_track AppVeyor-CI)

set(dashboard_cache "BUILD_SHARED:BOOL=ON
BUILD_STATIC:BOOL=OFF
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

# Upload link to appveyor
set(url "${CTEST_DASHBOARD_ROOT}/python-cmake-buildsystem/scratch/appveyor.url")
file(WRITE ${url} "https://ci.appveyor.com/project/$ENV{APPVEYOR_REPO_NAME}/build/$ENV{APPVEYOR_BUILD_VERSION}")
ctest_upload(FILES ${url})
ctest_submit(PARTS Upload)
file(REMOVE ${url})
