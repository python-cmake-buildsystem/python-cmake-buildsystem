
macro(check_cmake_property_exists propertyname)
  message(STATUS "Looking for CMake property ${propertyname}")
  string(TOUPPER ${propertyname} propertyname_upper)
  execute_process(
    COMMAND ${CMAKE_COMMAND} --help-property ${propertyname_upper}
    OUTPUT_QUIET
    ERROR_QUIET
    RESULT_VARIABLE _result
    )
  if(_result EQUAL 0)
    set(HAVE_${propertyname_upper} TRUE)
    message(STATUS "Looking for CMake property ${propertyname} - found")
  else()
    set(HAVE_${propertyname_upper} FALSE)
    message(STATUS "Looking for CMake property ${propertyname} - not found")
  endif()
endmacro()
