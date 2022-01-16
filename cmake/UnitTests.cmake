file(GLOB filenames "${PROJECT_BINARY_DIR}/${PYTHONHOME}/test/test_*.py")
list(SORT filenames)

foreach(filename IN LISTS filenames)
  get_filename_component(unittest ${filename} NAME_WE)
  list(APPEND unittests ${unittest})
endforeach()

list(LENGTH filenames testcount)
message(STATUS "Discovered ${testcount} tests")
