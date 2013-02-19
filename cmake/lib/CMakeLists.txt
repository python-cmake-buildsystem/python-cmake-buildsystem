# Install all the python module source from Lib/

set(libdir ${CMAKE_SOURCE_DIR}/Lib)
file(GLOB_RECURSE libfiles RELATIVE ${libdir} "${libdir}/*")

if(UNIX)
    set(plat_subdir "plat-linux2")
endif(UNIX)

foreach(file ${libfiles})
    # Don't install files for other platforms
    string(REGEX MATCH "^plat-" is_platform_file "${file}")
    if(plat_subdir)
        string(REGEX MATCH "^${plat_subdir}" is_matching_platform_file "${file}")
    endif(plat_subdir)

    if(NOT is_platform_file OR is_matching_platform_file)
        get_filename_component(path ${file} PATH)
        install(FILES ${libdir}/${file} DESTINATION ${PYTHONHOME}/${path})
    endif(NOT is_platform_file OR is_matching_platform_file)
endforeach(file)
