
include(cmake/CheckCMakeCommandExists.cmake)

# Detect CMake features

include(CMakePackageConfigHelpers OPTIONAL)
check_cmake_command_exists("configure_package_config_file")
check_cmake_command_exists("write_basic_package_version_file")

# Remove if minimum required version >= 2.8.12
check_cmake_command_exists("add_compile_options")
if(NOT HAVE_ADD_COMPILE_OPTIONS)
    function(add_compile_options)
        foreach(_option ${ARGN})
            if(NOT CMAKE_C_FLAGS MATCHES "(^| )${_option}($| )")
                if(CMAKE_C_FLAGS)
                    set(CMAKE_C_FLAGS "${_option} ${CMAKE_C_FLAGS}" CACHE STRING "" FORCE)
                else()
                    set(CMAKE_C_FLAGS "${_option}" CACHE STRING "" FORCE)
                endif()
            endif()
        endforeach()
    endfunction()
endif()
check_cmake_command_exists("target_compile_definitions")
