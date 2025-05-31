# Python Common Dashboard Script
#
# This script contains basic dashboard driver code common to all
# clients.
#
# Put this script in a directory such as "~/Dashboards/Scripts" or
# "c:/Dashboards/Scripts".  Create a file next to this script, say
# 'my_dashboard.cmake', with code of the following form:
#
#   # Client maintainer: me@mydomain.net
#   set(CTEST_SITE "machine.site")
#   set(CTEST_BUILD_NAME "Platform-Compiler")
#   set(CTEST_CONFIGURATION_TYPE Debug)
#   set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
#   include(${CTEST_SCRIPT_DIRECTORY}/python_common.cmake)
#
# Then run a scheduled task (cron job) with a command line such as
#
#   ctest -S ~/Dashboards/Scripts/my_dashboard.cmake -V
#
# By default the source and build trees will be placed in the path
# "../MyTests/" relative to your script location.
#
# The following variables may be set before including this script
# to configure it:
#
#   dashboard_model        = Nightly | Experimental | Continuous
#   dashboard_track        = Optional track to submit dashboard to
#   dashboard_disable_loop = For continuous dashboards, disable loop.
#   dashboard_root_name    = Change name of "MyTests" directory. This is
#                            ignored if CTEST_DASHBOARD_ROOT is set.
#   dashboard_source_name  = Name of source directory (default: python-cmake-buildsystem)
#   dashboard_binary_name  = Name of binary directory (default: python-cmake-buildsystem-build)
#   dashboard_cache        = Initial CMakeCache.txt file content
#   dashboard_no_test      = True to disable tests
#   dashboard_do_coverage  = True to enable coverage (ex: gcov)
#   dashboard_do_memcheck  = True to enable memcheck (ex: valgrind)
#   CTEST_CHECKOUT_COMMAND = Custom source tree checkout comamnd (primarilly
#                            for if the VCS is not git).
#   CTEST_BUILD_FLAGS      = build tool arguments (ex: -j2)
#   CTEST_DASHBOARD_ROOT   = Where to put source and build trees
#   CTEST_TEST_CTEST       = Whether to run long CTestTest* tests
#   CTEST_TEST_TIMEOUT     = Per-test timeout length
#   CTEST_TEST_ARGS        = ctest_test args (ex: PARALLEL_LEVEL 4)
#   CMAKE_MAKE_PROGRAM     = Path to "make" tool to use
#
# Options to configure Git:
#   CTEST_GIT_COMMAND      = Path to the git command-line client.
#   dashboard_git_url      = Custom git clone url
#   dashboard_git_branch   = Custom remote branch to track
#   dashboard_git_crlf     = Value of core.autocrlf for repository
#
# The following macros will be invoked before the corresponding step if they
# are defined:
#
#   dashboard_hook_init     = End of initialization, before loop
#   dashboard_hook_start    = Start of loop body, before ctest_start
#   dashboard_hook_started  = Start of loop body, after ctest_start
#   dashboard_hook_build    = Before ctest_build
#   dashboard_hook_test     = Before ctest_test
#   dashboard_hook_end      = End of body loop, after ctest_submit.
#
# For Makefile generators the script may be executed from an
# environment already configured to use the desired compilers.
# Alternatively the environment may be set at the top of the script:
#
#   set(ENV{CC}  /path/to/cc)   # C compiler
#   set(ENV{CXX} /path/to/cxx)  # C++ compiler
#   set(ENV{FC}  /path/to/fc)   # Fortran compiler (optional)
#   set(ENV{LD_LIBRARY_PATH} /path/to/vendor/lib) # (if necessary)

#=============================================================================
# Copyright 2010-2015 Kitware, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
# * Neither the name of Kitware, Inc. nor the names of its contributors
#   may be used to endorse or promote products derived from this
#   software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

cmake_minimum_required(VERSION 3.13.5)

set(CTEST_PROJECT_NAME CPython)
set(dashboard_user_home "$ENV{HOME}")

# Select the top dashboard directory.
if(NOT DEFINED dashboard_root_name)
  set(dashboard_root_name "MyTests")
endif()
if(NOT DEFINED CTEST_DASHBOARD_ROOT)
  get_filename_component(CTEST_DASHBOARD_ROOT "${CTEST_SCRIPT_DIRECTORY}/../${dashboard_root_name}" ABSOLUTE)
endif()

# Select the model (Nightly, Experimental, Continuous).
if(NOT DEFINED dashboard_model)
  set(dashboard_model Nightly)
endif()
if(NOT "${dashboard_model}" MATCHES "^(Nightly|Experimental|Continuous)$")
  message(FATAL_ERROR "dashboard_model must be Nightly, Experimental, or Continuous")
endif()

# Default to a Debug build.
if(NOT DEFINED CTEST_CONFIGURATION_TYPE AND DEFINED CTEST_BUILD_CONFIGURATION)
  set(CTEST_CONFIGURATION_TYPE ${CTEST_BUILD_CONFIGURATION})
endif()

if(NOT DEFINED CTEST_CONFIGURATION_TYPE)
  set(CTEST_CONFIGURATION_TYPE Debug)
endif()

# Choose CTest reporting mode.
if(dashboard_bootstrap)
  # Launchers do not work during bootstrap: no ctest available.
  set(CTEST_USE_LAUNCHERS 0)
elseif(NOT "${CTEST_CMAKE_GENERATOR}" MATCHES "Make|Ninja")
  # Launchers work only with Makefile and Ninja generators.
  set(CTEST_USE_LAUNCHERS 0)
elseif(NOT DEFINED CTEST_USE_LAUNCHERS)
  # The setting is ignored by CTest < 2.8 so we need no version test.
  set(CTEST_USE_LAUNCHERS 1)
endif()

# Configure testing.
if(NOT DEFINED CTEST_TEST_CTEST)
  set(CTEST_TEST_CTEST 1)
endif()
if(NOT CTEST_TEST_TIMEOUT)
  set(CTEST_TEST_TIMEOUT 1500)
endif()

# Select Git source to use.
if(NOT DEFINED dashboard_git_url)
  set(dashboard_git_url "git://github.com/jcfr/python-cmake-buildsystem.git")
endif()
if(NOT DEFINED dashboard_git_branch)
  set(dashboard_git_branch master)
  #if("${dashboard_model}" STREQUAL "Nightly")
  #  set(dashboard_git_branch nightly)
  #else()
  #  set(dashboard_git_branch next)
  #endif()
endif()
if(NOT DEFINED dashboard_git_crlf)
  if(UNIX)
    set(dashboard_git_crlf false)
  else(UNIX)
    set(dashboard_git_crlf true)
  endif(UNIX)
endif()

# Look for a GIT command-line client.
if(NOT DEFINED CTEST_GIT_COMMAND)
  find_program(CTEST_GIT_COMMAND
    NAMES git git.cmd
    PATH_SUFFIXES Git/cmd Git/bin
    )
endif()
if(NOT CTEST_GIT_COMMAND)
  message(FATAL_ERROR "CTEST_GIT_COMMAND not available!")
endif()

# Select a source directory name.
if(NOT DEFINED CTEST_SOURCE_DIRECTORY)
  if(DEFINED dashboard_source_name)
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_source_name})
  else()
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/python-cmake-buildsystem)
  endif()
endif()

# Select a build directory name.
if(NOT DEFINED CTEST_BINARY_DIRECTORY)
  if(DEFINED dashboard_binary_name)
    set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name})
  else()
    set(CTEST_BINARY_DIRECTORY ${CTEST_SOURCE_DIRECTORY}-build)
  endif()
endif()

# Delete source tree if it is incompatible with current VCS.
if(EXISTS ${CTEST_SOURCE_DIRECTORY})
  if(NOT EXISTS "${CTEST_SOURCE_DIRECTORY}/.git")
    set(vcs_refresh "because it is not managed by git.")
  else()
    execute_process(
      COMMAND ${CTEST_GIT_COMMAND} reset --hard
      WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}"
      OUTPUT_VARIABLE output
      ERROR_VARIABLE output
      RESULT_VARIABLE failed
      )
    if(failed)
      set(vcs_refresh "because its .git may be corrupted.")
    endif()
  endif()
  if(vcs_refresh AND "${CTEST_SOURCE_DIRECTORY}" MATCHES "/CMake[^/]*")
    message("Deleting source tree\n  ${CTEST_SOURCE_DIRECTORY}\n${vcs_refresh}")
    file(REMOVE_RECURSE "${CTEST_SOURCE_DIRECTORY}")
  endif()
endif()

# Support initial checkout if necessary.
if(NOT EXISTS "${CTEST_SOURCE_DIRECTORY}"
    AND NOT DEFINED CTEST_CHECKOUT_COMMAND)
  get_filename_component(_name "${CTEST_SOURCE_DIRECTORY}" NAME)

  # Generate an initial checkout script.
  set(ctest_checkout_script ${CTEST_DASHBOARD_ROOT}/${_name}-init.cmake)
  file(WRITE ${ctest_checkout_script} "# git repo init script for ${_name}
execute_process(
  COMMAND \"${CTEST_GIT_COMMAND}\" clone -n -b ${dashboard_git_branch} -- \"${dashboard_git_url}\"
          \"${CTEST_SOURCE_DIRECTORY}\"
  )
if(EXISTS \"${CTEST_SOURCE_DIRECTORY}/.git\")
  execute_process(
    COMMAND \"${CTEST_GIT_COMMAND}\" config core.autocrlf ${dashboard_git_crlf}
    WORKING_DIRECTORY \"${CTEST_SOURCE_DIRECTORY}\"
    )
  execute_process(
    COMMAND \"${CTEST_GIT_COMMAND}\" checkout
    WORKING_DIRECTORY \"${CTEST_SOURCE_DIRECTORY}\"
    )
endif()
")
  set(CTEST_CHECKOUT_COMMAND "\"${CMAKE_COMMAND}\" -P \"${ctest_checkout_script}\"")
endif()

#-----------------------------------------------------------------------------

# Send the main script as a note.
list(APPEND CTEST_NOTES_FILES
  "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}"
  "${CMAKE_CURRENT_LIST_FILE}"
  )

# Check for required variables.
foreach(req
    CTEST_CMAKE_GENERATOR
    CTEST_SITE
    CTEST_BUILD_NAME
    )
  if(NOT DEFINED ${req})
    message(FATAL_ERROR "The containing script must set ${req}")
  endif()
endforeach(req)

# Workaround for a CDash issue where colons (:) in CTEST_SITE cause Update and
# Configure/Build/Test submissions to appear as separate rows. Replace colons
# with underscores to ensure all parts are grouped under a single entry.
# See: https://github.com/Kitware/CDash/issues/2905
string(REPLACE ":" "_" CTEST_SITE "${CTEST_SITE}")

# Print summary information.
set(vars "")
foreach(v
    CTEST_SITE
    CTEST_BUILD_NAME
    CTEST_SOURCE_DIRECTORY
    CTEST_BINARY_DIRECTORY
    CTEST_CMAKE_GENERATOR
    CTEST_CMAKE_GENERATOR_PLATFORM
    CTEST_CONFIGURATION_TYPE
    CTEST_GIT_COMMAND
    CTEST_CHECKOUT_COMMAND
    CTEST_CONFIGURE_COMMAND
    CTEST_SCRIPT_DIRECTORY
    CTEST_USE_LAUNCHERS
    )
  if (DEFINED ${v})
    set(vars "${vars}  ${v}=[${${v}}]\n")
  endif()
endforeach(v)
message("Dashboard script configuration:\n${vars}\n")

# Avoid non-ascii characters in tool output.
set(ENV{LC_ALL} C)

# Helper macro to write the initial cache.
macro(write_cache)
  set(cache_build_type "")
  set(cache_make_program "")
  if(CTEST_CMAKE_GENERATOR MATCHES "Make|Ninja")
    set(cache_build_type CMAKE_BUILD_TYPE:STRING=${CTEST_CONFIGURATION_TYPE})
    if(CMAKE_MAKE_PROGRAM)
      set(cache_make_program CMAKE_MAKE_PROGRAM:FILEPATH=${CMAKE_MAKE_PROGRAM})
    endif()
  endif()
  file(WRITE ${CTEST_BINARY_DIRECTORY}/CMakeCache.txt "
SITE:STRING=${CTEST_SITE}
BUILDNAME:STRING=${CTEST_BUILD_NAME}
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
DART_TESTING_TIMEOUT:STRING=${CTEST_TEST_TIMEOUT}
${cache_build_type}
${cache_make_program}
${dashboard_cache}
")
endmacro(write_cache)

# Start with a fresh build tree.
if(EXISTS "${CTEST_BINARY_DIRECTORY}" AND
    NOT "${CTEST_SOURCE_DIRECTORY}" STREQUAL "${CTEST_BINARY_DIRECTORY}")
  message("Clearing build tree...")
  ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
endif()
file(MAKE_DIRECTORY "${CTEST_BINARY_DIRECTORY}")

set(dashboard_continuous 0)
if("${dashboard_model}" STREQUAL "Continuous")
  set(dashboard_continuous 1)
endif()

if("${dashboard_model}" STREQUAL "Experimental")
  set(CTEST_UPDATE_VERSION_ONLY 1) # Introduced in CMake >= 3.1.0
endif()

# CTest 2.6 crashes with message() after ctest_test.
macro(safe_message)
  if(NOT "${CMAKE_VERSION}" VERSION_LESS 2.8 OR NOT safe_message_skip)
    message(${ARGN})
  endif()
endmacro()

if(COMMAND dashboard_hook_init)
  dashboard_hook_init()
endif()

set(dashboard_done 0)
while(NOT dashboard_done)
  if(dashboard_continuous)
    set(START_TIME ${CTEST_ELAPSED_TIME})
  endif()

  # Start a new submission.
  if(COMMAND dashboard_hook_start)
    dashboard_hook_start()
  endif()
  if(dashboard_track)
    ctest_start(${dashboard_model} TRACK ${dashboard_track})
  else()
    ctest_start(${dashboard_model})
  endif()
  if(COMMAND dashboard_hook_started)
    dashboard_hook_started()
  endif()

  # Look for updates.
  ctest_update(RETURN_VALUE count)
  set(CTEST_CHECKOUT_COMMAND) # checkout on first iteration only
  safe_message("Found ${count} changed files")

  ctest_submit(PARTS Update)

  # Always build if the tree is fresh.
  set(dashboard_fresh 0)
  if(NOT EXISTS "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt")
    set(dashboard_fresh 1)
    safe_message("Starting fresh build...")
    write_cache()
  endif()

  # Additional CMake configure options can be specified in a commit message
  # using one or multiple line of the form "[cmake <ARGUMENT1>;<ARGUMENT2>;...]".
  #
  # If multiple matching lines are found, the project will be configured passing
  # all <ARGUMENT> without doing any particular filtering.

  # 1) Extract additional CMake configure option from last commit message
  #    that is not associated with a merge commit.
  execute_process(
    COMMAND ${CTEST_GIT_COMMAND} log -1 --pretty=%B --max-parents=1
    WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}"
    OUTPUT_VARIABLE output
    ERROR_VARIABLE output
    RESULT_VARIABLE failed
    )
  if(failed)
    message(FATAL_ERROR "Failed to extract last commit message from git history !")
  endif()

  # 2) Split by newlines
  # Copied from http://www.cmake.org/pipermail/cmake/2007-May/014222.html
  string(REGEX REPLACE ";" "\\\\;" output "${output}")
  string(REGEX REPLACE "\n" ";" output "${output}")

  # 3) Loop over all lines, match "[cmake ...] and extract <ARGUMENT>
  set(CMAKE_CONFIGURE_ARGS_FROM_COMMITMSG )
  foreach(line ${output})
    string(REGEX MATCH "^\\[cmake (.+)\\]" raw_cmake_comment ${line})
    if(raw_cmake_comment)
      list(APPEND CMAKE_CONFIGURE_ARGS_FROM_COMMITMSG ${CMAKE_MATCH_1})
    endif()
  endforeach()

  set(ctest_configure_options)
  if(CMAKE_CONFIGURE_ARGS_FROM_COMMITMSG)
    set(ctest_configure_options ${CMAKE_CONFIGURE_ARGS_FROM_COMMITMSG})
    message("CMake configure options from commit msg: ${CMAKE_CONFIGURE_ARGS_FROM_COMMITMSG}")
  else()
    message("CMake configure options from commit msg: Didn't find any [cmake <ARGUMENT>] directives in commit message.")
  endif()

  if(dashboard_fresh OR NOT dashboard_continuous OR count GREATER 0)

    if(ctest_configure_options)
      ctest_configure(OPTIONS "${ctest_configure_options}")
    else()
      ctest_configure()
    endif()

    ctest_submit(PARTS Configure)
    ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})

    # Submit files associated with the CTEST_NOTES_FILES variables
    ctest_submit(PARTS Notes)

    if(COMMAND dashboard_hook_build)
      dashboard_hook_build()
    endif()
    ctest_build()
    ctest_submit(PARTS Build)

    if(COMMAND dashboard_hook_test)
      dashboard_hook_test()
    endif()
    if(NOT dashboard_no_test)
      ctest_test(${CTEST_TEST_ARGS})
      ctest_submit(PARTS Test)
    endif()
    set(safe_message_skip 1) # Block further messages

    if(dashboard_do_coverage)
      ctest_coverage()
      ctest_submit(PARTS Coverage)
    endif()

    if(dashboard_do_memcheck)
      ctest_memcheck(${CTEST_TEST_ARGS})
      ctest_submit(PARTS MemCheck)
    endif()

    if(COMMAND dashboard_hook_end)
      dashboard_hook_end()
    endif()

  endif()

  if(dashboard_continuous AND NOT dashboard_disable_loop)
    # Delay until at least 5 minutes past START_TIME
    ctest_sleep(${START_TIME} 300 ${CTEST_ELAPSED_TIME})
    if(${CTEST_ELAPSED_TIME} GREATER 57600)
      set(dashboard_done 1)
    endif()
  else()
    # Not continuous, so we are done.
    set(dashboard_done 1)
  endif()

  set(ENV{HOME} "${dashboard_user_home}")
endwhile()

