function (get_unittests outlist)
    set(${outlist})

    # path to tests
    set(test_dir "${CMAKE_BINARY_DIR}/${PYTHONHOME}/test")

    # for debug
    # message(STATUS "get_unittests: test_dir=${test_dir}")

    # get unit tests supplied by distro tarball
    file(GLOB unit_filepaths "${test_dir}/test*.py")

    # format the file names
    foreach(py_filepath ${unit_filepaths})

        # just the file name
        get_filename_component(py_file ${py_filepath} NAME_WE)
        # add to output
        list(APPEND ${outlist} ${py_file})
    endforeach()

    set(${outlist} ${${outlist}} PARENT_SCOPE)

endfunction (get_unittests)
