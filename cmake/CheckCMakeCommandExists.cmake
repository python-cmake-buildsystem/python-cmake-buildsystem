#.rst:
#
# ===================================================
# CheckCMakeCommandExists - check for a cmake command
# ===================================================
#
# This test will verify a cmake command is present
#
# .. code-block:: cmake
#
#     include(cmake-modules/CMakeChecks.cmake)
#     check_cmake_command_exists(hello)
#
# .. code-block:: shell-session
#
#     -- Looking for CMake command hello
#     -- Looking for CMake command hello - not found
#
# On success **HAVE_HELLO** will be set to **ON**
#


macro(check_cmake_command_exists commandname)
  string(TOUPPER ${commandname} commandname_upper)
  set(_varname HAVE_${commandname_upper})
  if(NOT DEFINED ${_varname})
    message(STATUS "Looking for CMake command ${commandname}")
    if(COMMAND ${commandname})
      set(${_varname} TRUE CACHE INTERNAL "Have CMake command ${commandname}")
      message(STATUS "Looking for CMake command ${commandname} - found")
    else()
      set(${_varname} FALSE CACHE INTERNAL "Have CMake command ${commandname}")
      message(STATUS "Looking for CMake command ${commandname} - not found")
    endif()
  endif()
endmacro()

