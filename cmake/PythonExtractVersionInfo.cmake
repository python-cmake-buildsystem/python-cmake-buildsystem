
# Given a version string of the form "X.Y.Z[rcN|[a-z]N]", extract
# major, minor, patch version as well as release level (rc, any letter)
# and serial (an integer)
#
# The function will systematically set the following variable in the caller
# scope:
#
#   PY_VERSION_MAJOR  - X
#   PY_VERSION_MINOR  - Y
#   PY_VERSION_PATCH  - Z
#   PY_RELEASE_LEVEL  - rc, a, b, c, ..., z or an empty string
#   PY_RELEASE_SERIAL - an integer or an empty string
#   PY_VERSION        - X.Y.Z
#
function(python_extract_version_info)
    set(options)
    set(oneValueArgs
        VERSION_STRING
        )
    set(multiValueArgs)
    cmake_parse_arguments(MY
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
        ${ARGN}
        )

    # Sanity checks
    # XXX TBD

    set(version_str ${MY_VERSION_STRING})

    # version_str             : 2.7.14 | 2.7.14rc1 | 3.6.0a4 | 3.7.0b1
    # version_major           : 2      | 2         | 3       | 3
    # version_minor           :   7    |   7       |   6     |   7
    # version_patch           :     14 |     14    |     0   |     0
    # release_level_and_serial:        |       rc1 |      a4 |      b1
    # release_level           :        |       rc  |      a  |      b
    # release_serial          :        |         1 |       4 |       1
    # version                 : 2.7.14 | 2.7.14    | 3.6.0   | 3.7.0

    # Code adpated from FindPythonLibs.cmake
    string(REGEX REPLACE "([0-9]+)\\..+" "\\1"                version_major            ${version_str})
    string(REGEX REPLACE "[0-9]+\\.([0-9]+)\\..+" "\\1"       version_minor            ${version_str})
    string(REGEX REPLACE "[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" version_patch            ${version_str})
    string(REGEX REPLACE "[0-9]+\\.[0-9]+\\.[0-9]+(.*)" "\\1" release_level_and_serial ${version_str})
    string(REGEX REPLACE "([a-z]+)[0-9]+" "\\1"               release_level            "${release_level_and_serial}")
    string(REGEX REPLACE "[a-z]+([0-9]+)" "\\1"               release_serial           "${release_level_and_serial}")

    set(version "${version_major}.${version_minor}.${version_patch}")

    set(PY_VERSION_MAJOR  ${version_major} PARENT_SCOPE)
    set(PY_VERSION_MINOR  ${version_minor} PARENT_SCOPE)
    set(PY_VERSION_PATCH  ${version_patch} PARENT_SCOPE)
    set(PY_RELEASE_LEVEL  ${release_level} PARENT_SCOPE)
    set(PY_RELEASE_SERIAL ${release_serial} PARENT_SCOPE)
    set(PY_VERSION        ${version} PARENT_SCOPE)
endfunction()

#
# cmake -DTEST_python_extract_version_info:BOOL=ON -P PythonExtractVersionInfo.cmake
#
function(python_extract_version_info_test)

    function(display_output_values)
        foreach(varname
                VERSION_MAJOR
                VERSION_MINOR
                VERSION_PATCH
                RELEASE_LEVEL
                RELEASE_SERIAL
                VERSION
            )
            message("PY_${varname}: ${PY_${varname}}")
        endforeach()
    endfunction()

    set(id 1)
    set(case${id}_input_version_long         "2.7.14")
    set(case${id}_expected_PY_VERSION_MAJOR  "2")
    set(case${id}_expected_PY_VERSION_MINOR  "7")
    set(case${id}_expected_PY_VERSION_PATCH  "14")
    set(case${id}_expected_PY_RELEASE_LEVEL  "")
    set(case${id}_expected_PY_RELEASE_SERIAL "")
    set(case${id}_expected_PY_VERSION        "2.7.14")

    set(id 2)
    set(case${id}_input_version_long         "2.7.14rc1")
    set(case${id}_expected_PY_VERSION_MAJOR  "2")
    set(case${id}_expected_PY_VERSION_MINOR  "7")
    set(case${id}_expected_PY_VERSION_PATCH  "14")
    set(case${id}_expected_PY_RELEASE_LEVEL  "rc")
    set(case${id}_expected_PY_RELEASE_SERIAL "1")
    set(case${id}_expected_PY_VERSION        "2.7.14")

    set(id 3)
    set(case${id}_input_version_long         "3.6.0a4")
    set(case${id}_expected_PY_VERSION_MAJOR  "3")
    set(case${id}_expected_PY_VERSION_MINOR  "6")
    set(case${id}_expected_PY_VERSION_PATCH  "0")
    set(case${id}_expected_PY_RELEASE_LEVEL  "a")
    set(case${id}_expected_PY_RELEASE_SERIAL "4")
    set(case${id}_expected_PY_VERSION        "3.6.0")

    set(id 4)
    set(case${id}_input_version_long         "10.744.42b66")
    set(case${id}_expected_PY_VERSION_MAJOR  "10")
    set(case${id}_expected_PY_VERSION_MINOR  "744")
    set(case${id}_expected_PY_VERSION_PATCH  "42")
    set(case${id}_expected_PY_RELEASE_LEVEL  "b")
    set(case${id}_expected_PY_RELEASE_SERIAL "66")
    set(case${id}_expected_PY_VERSION        "10.744.42")

    foreach(caseid RANGE 1 ${id})
        set(input "${case${caseid}_input_version_long}")
        python_extract_version_info(VERSION_STRING "${input}")
        foreach(varname
                VERSION_MAJOR
                VERSION_MINOR
                VERSION_PATCH
                RELEASE_LEVEL
                RELEASE_SERIAL
                VERSION
            )
            set(expected_varname "case${caseid}_expected_PY_${varname}")
            set(current_varname "PY_${varname}")
            if(NOT "${${expected_varname}}" STREQUAL "${${current_varname}}")
                message("input: ${input}")
                display_output_values()
                message(FATAL_ERROR "error: case ${caseid}: \n  expected: ${expected_varname} [${${expected_varname}}]\n   current: ${current_varname} [${${current_varname}}]")
            endif()
        endforeach()
    endforeach()

    message("SUCCESS")
endfunction()

if(TEST_python_extract_version_info)
    python_extract_version_info_test()
endif()

# Compute the "Field3" value from a Python version's patch, release level, and serial.
#
# The Field3 value is defined as:
#   Field3 = patch * 1000 + release_level_number * 10 + release_serial
#
# Where release_level_number is:
#   - 10 for alpha (a)
#   - 11 for beta (b)
#   - 12 for release candidate (rc)
#   - 15 for final (no pre-release tag)
#
# Arguments:
#   VERSION_PATCH    - Patch version (Z in X.Y.Z)
#   RELEASE_LEVEL    - One of 'a', 'b', 'rc', or empty
#   RELEASE_SERIAL   - An integer (or empty for final)
#
# Output:
#   Sets variable PY_FIELD3_VALUE in the caller's scope.
function(python_compute_release_field3_value)
    set(options)
    set(oneValueArgs
        VERSION_PATCH
        RELEASE_LEVEL
        RELEASE_SERIAL
        )
    set(multiValueArgs)
    cmake_parse_arguments(MY
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
        ${ARGN}
        )

    # Default ReleaseLevelNumber = 15 (final release)
    set(_level_number 15)

    # Map release level string to numeric code
    if(MY_RELEASE_LEVEL STREQUAL "a")
        set(_level_number 10)
    elseif(MY_RELEASE_LEVEL STREQUAL "b")
        set(_level_number 11)
    elseif(MY_RELEASE_LEVEL STREQUAL "rc")
        set(_level_number 12)
    endif()

    # Fallback for empty serial
    if("${MY_RELEASE_SERIAL}" STREQUAL "")
        set(MY_RELEASE_SERIAL 0)
    endif()

    # Convert to integers
    set(_patch "${MY_VERSION_PATCH}")
    set(_serial "${MY_RELEASE_SERIAL}")
    math(EXPR _field3 "${_patch} * 1000 + ${_level_number} * 10 + ${_serial}")

    # Return in the variable specified by caller
    set(PY_FIELD3_VALUE "${_field3}" PARENT_SCOPE)
endfunction()

#
# cmake -DTEST_python_compute_release_field3_value:BOOL=ON -P PythonExtractVersionInfo.cmake
#
function(python_compute_release_field3_value_test)

    function(display_field3_test_values)
        message("  PATCH: ${patch}")
        message("  LEVEL: ${level}")
        message("  SERIAL: ${serial}")
        message("  Expected: ${expected}")
        message("  Computed: ${PY_FIELD3_VALUE}")
    endfunction()

    set(id 1)
    set(case${id}_patch   2)
    set(case${id}_level   "")     # final release
    set(case${id}_serial  "")     # default to 0
    set(case${id}_expected 2150)  # 2*1000 + 15*10 + 0

    set(id 2)
    set(case${id}_patch   2)
    set(case${id}_level   a)
    set(case${id}_serial  1)
    set(case${id}_expected 2101)  # 2*1000 + 10*10 + 1

    set(id 3)
    set(case${id}_patch   5)
    set(case${id}_level   b)
    set(case${id}_serial  0)
    set(case${id}_expected 5110)  # 5*1000 + 11*10 + 0

    set(id 4)
    set(case${id}_patch   14)
    set(case${id}_level   rc)
    set(case${id}_serial  3)
    set(case${id}_expected 14123)  # 14*1000 + 12*10 + 3

    set(id 5)
    set(case${id}_patch   0)
    set(case${id}_level   "")    # final
    set(case${id}_serial  "")    # default 0
    set(case${id}_expected 150)  # 0 * 1000 + 15 * 10 + 0

    foreach(caseid RANGE 1 ${id})
        set(patch   "${case${caseid}_patch}")
        set(level   "${case${caseid}_level}")
        set(serial  "${case${caseid}_serial}")
        set(expected "${case${caseid}_expected}")

        python_compute_release_field3_value(
            VERSION_PATCH "${patch}"
            RELEASE_LEVEL "${level}"
            RELEASE_SERIAL "${serial}"
        )

        if(NOT "${PY_FIELD3_VALUE}" STREQUAL "${expected}")
            message("FAILED: case ${caseid}")
            display_field3_test_values()
            message(FATAL_ERROR "Test failed at case ${caseid}")
        endif()
    endforeach()

    message("SUCCESS")
endfunction()

if(TEST_python_compute_release_field3_value)
    python_compute_release_field3_value_test()
endif()
