
include(cmake/CheckCMakeCommandExists.cmake)

# Detect CMake features

include(CMakePackageConfigHelpers OPTIONAL)
check_cmake_command_exists("configure_package_config_file")
check_cmake_command_exists("write_basic_package_version_file")

# Remove if minimum required version >= 2.8.12
check_cmake_command_exists("target_compile_definitions")
