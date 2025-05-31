file(GLOB filenames "${PROJECT_BINARY_DIR}/${PYTHONHOME}/test/test_*.py")
list(SORT filenames)

set(unittests)
set(skipped_unittests)

# Since some tests call "support.requires(...)" spliting its arguments
# over multiple lines and the current parsing does not support the arguments
# extraction, the associated resource name is hard-coded below.
set(test_zipfile64_resource "extralargefile")

foreach(filename IN LISTS filenames)
  get_filename_component(unittest ${filename} NAME_WE)

  set(skip_unittest 0)

  # Match only unindented support.requires(...) calls
  file(STRINGS "${filename}" matches REGEX "^(support\\.requires|requires)\\([^\\)]*\\)")

  if(matches)  # There are support.requires() calls
    foreach(match IN LISTS matches)
      # Extract the FIRST quoted argument only
      string(REGEX MATCH "['\"]([^'\"]*)['\"]" args "${match}")
      set(expected_resource ${CMAKE_MATCH_1})

      # if not in SUPPORTED_TEST_RESOURCES, skip
      if(NOT "${expected_resource}" IN_LIST SUPPORTED_TEST_RESOURCES)
        set(skip_unittest 1)
        break()
      endif()
    endforeach()
  endif()

  # Handle hardcoded resource override (e.g., due to unsupported multi-line call)
  if(DEFINED "${unittest}_resource")
    set(expected_resource "${${unittest}_resource}")
    if(NOT "${expected_resource}" IN_LIST SUPPORTED_TEST_RESOURCES)
      set(skip_unittest 1)
    endif()
  endif()

  if(skip_unittest)
    list(APPEND skipped_unittests ${unittest})
    message(STATUS "  Ignoring '${unittest}' requiring '${expected_resource}' resource")
    continue()
  endif()

  list(APPEND unittests ${unittest})
endforeach()

list(LENGTH skipped_unittests skippedcount)
list(LENGTH filenames testcount)
message(STATUS "Discovered ${testcount} tests (skipping ${skippedcount})")
